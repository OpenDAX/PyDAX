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

include "constants.pxi"
cimport pydax

cdef TYPESIZE(u_int32_t t):
    return 0x0001 << (t & 0x0F)

cdef IS_CUSTOM(u_int32_t t):
    return t & DAX_CUSTOM

class Member():
    def __init__(self, client, name, datatype, count=1):
        self.client = client
        self.name = name
        self.datatype = datatype
        self.count = count
        #self.handle = handle
        if IS_CUSTOM(datatype):
            self.members = {}
            cdt = self.client.get_cdt(datatype)
            for member in cdt:
                m = Member(self.client, member[0], member[1], member[2])
            self.__value = None
        else:
            print("not custom")
            self.members = None
            self.__value = [None] * count
        self.index = None

    def __getitem__(self, index):
        self.index = index
        return self

    def __setitem__(self, index, value):
        print("index {} = {}".format(index, value))

    def getValue(self):
        if self.index is None:
            if self.count == 1:
                return self.__value[0]
            else:
                return self.__value
        else:
            val = self.__value[self.index]
            self.index = None
            return val

    def setValue(self, value):
        if self.index is None:
            if self.count == 1:
                self.__value[0] = value
            else:
                raise NotImplemented
        else:
            self.__value[self.index] = value
            self.index = None

    value = property(getValue, setValue)

# The client class represents one connection to an OpenDAX Tag Server
cdef class Client():
    cdef dax_state *__ds
    cdef char *name
    cdef dict __tags

    def __cinit__(self, name):
        self.name = name
        self.__ds = dax_init(name)
        if self.__ds is NULL:
            raise MemoryError()
        x = dax_init_config(self.__ds, name)
        if x != 0: raise getError(x)
        self.__tags = {}

    def __dealloc__(self):
        dax_free_config(self.__ds)
        dax_free(self.__ds)

    def __getattr__(self, name):
        try:
            return self.__find_tag(name)
        except:
            raise AttributeError

    def __setattr__(self, name, value):
        print("You tried to set {} to {}".format(name, value))
        if name in self.__tags:
            self.__tags[name].__setattr__(name, value)
        else:
            raise AttributeError

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
            raise e
            dax_cdt_free(cdt)
        return t

    def get_cdt(self, datatype):
        cdef tag_type t
        tlist = []
        if isinstance(datatype, str):
            t = dax_string_to_type(self.__ds, datatype)
        else:
            t = datatype

        x = dax_cdt_iter(self.__ds, t, <void*>tlist, cdt_callback)
        return tlist

    # Direct wrappers for libdax library functions
    def dax_configure(self):
        x = dax_configure(self.__ds, 1, [self.name], 0)
        if x != 0: raise getError(x)

    def dax_connect(self):
        x = dax_connect(self.__ds)
        if x != 0: raise getError(x)

    def dax_tag_add(self, name, datatype, size):
        cdef Handle h
        cdef tag_type t
        if isinstance(datatype, str):
            t = dax_string_to_type(self.__ds, datatype)
        else:
            t = datatype
        x = dax_tag_add(self.__ds, &h, name, t, size)
        if x != 0: raise getError(x)

        # self.__tags[name] = Member(self, name, h)
        # print(self.__tags)
        # return self.__tags[name]

# This is the callback function for getting the compound data type from
# the OpenDAX server.  The client calls the dax_cdt_iter() function with
# this function as the callback.  It is expected that udata is a Python
# list and this funtion will append the CDT member represented by the
# call to this function to that list as a Tuple.
cdef void cdt_callback(cdt_iter member, void* udata):
    l = (<object>udata)
    l.append((member.name, member.type, member.count))

# TODO: Probably should make some DAX only Exceptions for all of these
# This function returns an exception object that depends on the value of the
# error 'e'
def getError(e):
    print(e)
    exceptions = {
                    ERR_GENERIC:RuntimeError,
                    ERR_NO_SOCKET:RuntimeError,
                    ERR_2BIG:RuntimeError,
                    ERR_ARG:AttributeError,
                    ERR_NOTFOUND:AttributeError,
                    ERR_MSG_SEND:RuntimeError,
                    ERR_MSG_RECV:RuntimeError,
                    ERR_TAG_BAD:RuntimeError,
                    ERR_TAG_DUPL:RuntimeError,
                    ERR_ALLOC:MemoryError,
                    ERR_MSG_BAD:RuntimeError,
                    ERR_DUPL:RuntimeError,
                    ERR_NO_INIT:RuntimeError,
                    ERR_TIMEOUT:RuntimeError,
                    ERR_ILLEGAL:RuntimeError,
                    ERR_INUSE:RuntimeError,
                    ERR_PARSE:RuntimeError,
                    ERR_ARBITRARY:RuntimeError,
                    ERR_NOTNUMBER:RuntimeError,
                    ERR_EMPTY:RuntimeError,
                    ERR_BADTYPE:TypeError,
                    ERR_AUTH:RuntimeError
                }
    descriptions = {
                    ERR_GENERIC:"",
                    ERR_NO_SOCKET:"No Socket Found",
                    ERR_2BIG:"Argument Too Big",
                    ERR_ARG:"Argument",
                    ERR_NOTFOUND:"Not Found",
                    ERR_MSG_SEND:"Message Send Failure",
                    ERR_MSG_RECV:"Message Receive Failure",
                    ERR_TAG_BAD:"Bad Tag",
                    ERR_TAG_DUPL:"Duplicate Tag",
                    ERR_ALLOC:"Allocation Error",
                    ERR_MSG_BAD:"Bad Argument",
                    ERR_DUPL:"Duplicate",
                    ERR_NO_INIT:"Not Initialized",
                    ERR_TIMEOUT:"Timeout",
                    ERR_ILLEGAL:"Illegal",
                    ERR_INUSE:"In Use",
                    ERR_PARSE:"Parsing Error",
                    ERR_ARBITRARY:"Arbitrary",
                    ERR_NOTNUMBER:"Not a Number",
                    ERR_EMPTY:"Empty",
                    ERR_BADTYPE:"Bad Type",
                    ERR_AUTH:"Not Authorized"
                   }

    if e in exceptions.keys():
        d = descriptions[e]
        ex = exceptions[e]
        return ex(d)
    else:
        return RuntimeError("Unknown Error")
