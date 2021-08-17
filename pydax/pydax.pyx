#  PyDAX - A Python extension module for OpenDAX
#  OpenDAX - An open source data acquisition and control system
#  Copyright (c) 2019 Phil Birkelbach
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# This is a cython based module for interfacing to the OpenDAX server

# cython: c_string_type=unicode, c_string_encoding=utf8

import sys
import datetime
from libc.stdlib cimport malloc, free
from libc.string cimport memset

include "constants.pxi"
include "exceptions.pxi"
cimport pydax

# cdef TYPESIZE(u_int32_t t):
    # return 0x0001 << (t & 0x0F)

cdef IS_CUSTOM(u_int32_t t):
    return t & DAX_CUSTOM

class Member():
    def __init__(self, client, name, datatype, count=1):
        self.client = client
        self.name = name
        self.datatype = datatype
        self.count = count
        if IS_CUSTOM(datatype):
            self.custom = True
            self.members = {}
            cdt = self.client.get_cdt(datatype)
            for member in cdt:
                m = Member(self.client, member[0], member[1], member[2])
                self.members[member[0]] = m
        else:
            self.custom = False
            self.members = None
        self.index = None
        self.path = name

    def __getitem__(self, index):
        if index < 0 or index >= self.count:
            raise IndexError
        self.index = index
        return self

    def __setitem__(self, index, value):
        print("index {} = {}".format(index, value))

    def __getattr__(self, name):
        try:
            m = self.members[name]
            if self.count > 1:
                if self.index is None:
                    raise IndexError("{} has a count greater than 1 and needs an index".format(self.name))
                m.path = self.path + "[" + str(self.index) + "]." + name
            else:
                m.path = self.path + "." + name

            return m
        except KeyError:
            raise AttributeError
        except Exception as e:
            raise e

    def getValue(self):
        """"property function that reads the tag from the server and returns the result"""
        if self.custom:
            raise AttributeError
        if self.index is None:
            val = self.client.read_tag(self.path)
        else:
            val = self.client.read_tag(f"{self.path}[{self.index)}]")
            self.index = None
        return val

    def setValue(self, value):
        """property function that writes the gat to the server"""
        if self.custom:
            raise AttributeError
        if self.index is None:
            self.client.write_tag(self.path, value)
        else:
            self.client.write_tag(f"{self.path}[{self.index)}]", value)
            self.index = None

    value = property(getValue, setValue)

cdef class Client():
    """Represents one connection to an OpenDAX Tag Server"""
    cdef dax_state *__ds
    cdef char *name
    cdef dict __tags
    cdef bint clip

    def __cinit__(self, name):
        self.name = name
        self.__ds = dax_init(name)
        if self.__ds is NULL:
            raise MemoryError()
        x = dax_init_config(self.__ds, name)
        if x != 0: raise getError(x)
        self.__tags = {}
        # If true, data writes will clip to bounds instead of raising Exceptions
        self.clip = False

    def __dealloc__(self):
        dax_free_config(self.__ds)
        dax_free(self.__ds)

    def __getattr__(self, name):
        try:
            return self.__find_tag(name)
        except:
            raise AttributeError(f"{name} is not a member of Client")

    def __setattr__(self, name, value):
        print("You tried to set {} to {}".format(name, value))
        if name in self.__tags:
            self.__tags[name].__setattr__(name, value)
        else:
            raise AttributeError(f"{name} is not a member of Client")

    def __find_tag(self, name):
        cdef dax_tag tag
        if name in self.__tags:
            return self.__tags[name]
        else:
            x = dax_tag_byname(self.__ds, &tag, name)
            if x == 0:
                m = Member(self, tag.name, tag.type, tag.count)
                self.__tags[name] = m
                return m
            else:
                raise getError(x)

    def add_cdt(self, name, members):
        cdef dax_cdt *cdt
        cdef tag_type t
        cdef int error

        cdt = dax_cdt_new(name, &error)
        try:
            for m in members:
                if isinstance(m[1], str):
                    t = dax_string_to_type(self.__ds, m[1])
                else:
                    t = m[1]
                x = dax_cdt_member(self.__ds, cdt, m[0], t, m[2])
                if x != 0: raise getError(x)
            x = dax_cdt_create(self.__ds, cdt, &t)
            if x != 0: raise getError(x)
        except Exception as e:
            dax_cdt_free(cdt)
            raise e
        return t

    def get_cdt(self, datatype):
        """Retrieves the custom data type and returns a list of it's members"""
        cdef tag_type t
        tlist = []
        if isinstance(datatype, str):
            t = dax_string_to_type(self.__ds, datatype)
        else:
            t = datatype

        x = dax_cdt_iter(self.__ds, t, <void*>tlist, cdt_callback)
        return tlist

    def read_tag(self, name, unsigned int count=0):
        """Reads a tag or part of a tag from the server"""
        cdef tag_handle h
        cdef void *buff
        x = dax_tag_handle(self.__ds, &h, name, count)
        if x != 0: raise getError(x)
        buff = malloc(h.size)
        if buff == NULL:
            raise MemoryError
        try:
            x = dax_read_tag(self.__ds, h, buff)
            if x != 0:
                raise getError(x)
            if h.count > 1:
                result = []
                for n in range(h.count):
                    result.append(__dax_to_python(buff, h.type, n))
            else:
                result = __dax_to_python(buff, h.type)
        finally:
            free(buff)
        return result

    def write_tag(self, name, data, clip=False):
        """Writes the data to the server as tagname 'name'"""
        cdef tag_handle h
        cdef void *buff

        try:
            count = len(data)
        except TypeError:
            count = 0
        x = dax_tag_handle(self.__ds, &h, name, count)
        if x != 0: raise getError(x)
        buff = malloc(h.size)
        if buff == NULL:
            raise MemoryError
        memset(buff, 0, h.size)
        try:
            if h.count > 1:
                for n in range(h.count):
                    __python_to_dax(buff, data[n], h.type, n, clip=clip)
            else:
                __python_to_dax(buff, data, h.type, 0, clip=clip)
            x = dax_write_tag(self.__ds, h, buff)
            if x != 0: raise getError(x)
        finally:
            free(buff)

    # Lower level wrappers for libdax library functions
    def dax_configure(self):
        x = dax_configure(self.__ds, 1, [self.name], 0)
        if x != 0: raise getError(x)

    def dax_connect(self):
        x = dax_connect(self.__ds)
        if x != 0: raise getError(x)

    def dax_tag_add(self, name, datatype, count=1, attr=0):
        cdef tag_handle h
        cdef tag_type t
        if isinstance(datatype, str):
            t = dax_string_to_type(self.__ds, datatype)
        else:
            t = datatype
        x = dax_tag_add(self.__ds, &h, name, t, count, attr)
        if x != 0: raise getError(x)


cdef __dax_to_python(void *buff, tag_type t, idx=0):
    """Converts a DAX buffer of data from the server to a Python type"""
    if t == DAX_BOOL:
        B = idx // 8
        b = idx %8
        if ((<dax_byte *>buff)[B] & (0x01 << b)) == 0:
            return False
        else:
            return True
    # 8 Bits
    elif t == DAX_BYTE:
        return (<dax_byte *>buff)[idx]
    elif t == DAX_SINT:
        return (<dax_sint *>buff)[idx]
    elif t == DAX_CHAR:
        return (<dax_char *>buff)[idx]
    # 16 Bits
    elif t == DAX_WORD:
        return (<dax_word *>buff)[idx]
    elif t == DAX_INT:
        return (<dax_int *>buff)[idx]
    elif t == DAX_UINT:
        return (<dax_uint *>buff)[idx]
    # 32 Bits
    elif t == DAX_DWORD:
        return (<dax_dword *>buff)[idx]
    elif t == DAX_DINT:
        return (<dax_dint *>buff)[idx]
    elif t == DAX_UDINT:
        return (<dax_udint *>buff)[idx]
    elif t == DAX_TIME:
        return datetime.datetime.fromtimestamp((<dax_time *>buff)[idx])
    elif t == DAX_REAL:
        return (<dax_real *>buff)[idx]
    # 64 Bits
    elif t == DAX_LWORD:
        return (<dax_lword *>buff)[idx]
    elif t == DAX_LINT:
        return (<dax_lint *>buff)[idx]
    elif t == DAX_ULINT:
        return (<dax_ulint *>buff)[idx]
    elif t == DAX_LREAL:
        return (<dax_lreal *>buff)[idx]

__limits =  {DAX_BYTE:  (DAX_BYTE_MIN,  DAX_BYTE_MAX),
             DAX_SINT:  (DAX_SINT_MIN,  DAX_SINT_MAX),
             DAX_CHAR:  (DAX_CHAR_MIN,  DAX_CHAR_MAX),
             DAX_WORD:  (DAX_WORD_MIN,  DAX_WORD_MAX),
             DAX_INT:   (DAX_INT_MIN,   DAX_INT_MAX),
             DAX_UINT:  (DAX_UINT_MIN,  DAX_UINT_MAX),
             DAX_DWORD: (DAX_DWORD_MIN, DAX_DWORD_MAX),
             DAX_DINT:  (DAX_DINT_MIN,  DAX_DINT_MAX),
             DAX_UDINT: (DAX_UDINT_MIN, DAX_UDINT_MAX),
             DAX_TIME:  (DAX_TIME_MIN,  DAX_TIME_MAX),
             DAX_LWORD: (DAX_LWORD_MIN, DAX_LWORD_MAX),
             DAX_LINT:  (DAX_LINT_MIN,  DAX_LINT_MAX),
             DAX_ULINT: (DAX_ULINT_MIN, DAX_ULINT_MAX),
             DAX_REAL: (DAX_REAL_MIN, DAX_REAL_MAX),
             DAX_LREAL: (DAX_LREAL_MIN, DAX_LREAL_MAX)
            }

cdef __python_to_dax(void *buff, data, tag_type t, idx=0, clip=False):
    """converts python data to a DAX buffer than can be written to the server"""
    if t != DAX_BOOL: # Bounds check
        l = __limits[t]
        if data < l[0]:
            if clip:
                data = l[0]
            else:
                raise OverflowError()
        elif data > l[1]:
            if clip:
                data = l[1]
            else:
                raise OverflowError
    if t == DAX_BOOL:
        B = idx // 8
        b = idx %8
        if data:
            (<dax_byte *>buff)[B] |= (0x01 << b)
        else:
            (<dax_byte *>buff)[B] &= ~(0x01 << b)
    # 8 Bits
    elif t == DAX_BYTE:
        (<dax_byte *>buff)[idx] = data
    elif t == DAX_SINT:
        (<dax_sint *>buff)[idx] = data
    elif t == DAX_CHAR:
        (<dax_char *>buff)[idx] = data
    # 16 Bits
    elif t == DAX_WORD:
        (<dax_word *>buff)[idx] = data
    elif t == DAX_INT:
        (<dax_int *>buff)[idx] = data
    elif t == DAX_UINT:
        (<dax_uint *>buff)[idx] = data
    # 32 Bits
    elif t == DAX_DWORD:
        (<dax_dword *>buff)[idx] = data
    elif t == DAX_DINT:
        (<dax_dint *>buff)[idx] = data
    elif t == DAX_UDINT:
        (<dax_udint *>buff)[idx] = data
    elif t == DAX_TIME:
        (<dax_time *>buff)[idx] = data.timestamp()
    elif t == DAX_REAL:
        (<dax_real *>buff)[idx] = data
    # 64 Bits
    elif t == DAX_LWORD:
        (<dax_lword *>buff)[idx] = data
    elif t == DAX_LINT:
        (<dax_lint *>buff)[idx] = data
    elif t == DAX_ULINT:
        (<dax_ulint *>buff)[idx] = data
    elif t == DAX_LREAL:
        (<dax_lreal *>buff)[idx] = data

# This is the callback function for getting the compound data type from
# the OpenDAX server.  The client calls the dax_cdt_iter() function with
# this function as the callback.  It is expected that udata is a Python
# list and this funtion will append the CDT member represented by the
# call to this function to that list as a Tuple.
cdef void cdt_callback(cdt_iter member, void* udata):
    l = (<object>udata)
    l.append((member.name, member.type, member.count))
