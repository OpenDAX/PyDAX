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

cdef void cdt_callback(cdt_iter member, void* udata):
    print(member.name)

class Member():
    def __init__(self, client, name, type, count=1):
        self.client = client
        self.name = name
        self.type = type
        self.count = count
        #self.handle = handle
        self.members = None
        self.__value = [None] * count
        self.index = None

    def __getitem__(self, index):
        self.index = index
        return self
        print("index {}".format(index))

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
        if x != 0:  #TODO Better error description
            raise RuntimeError()
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
            else:  #TODO Better error description
                raise RuntimeError()


    def add_cdt(self, name, members):
        cdef dax_cdt *cdt
        cdef tag_type t
        cdef int error

        cdt = dax_cdt_new(name, &error)
        try:
            for m in members:
                x = dax_cdt_member(self.__ds, cdt, m[0], m[1], m[2])
                if x != 0:
                    raise RuntimeError
            x = dax_cdt_create(self.__ds, cdt, &t)
            if x != 0:
                raise RuntimeError
        finally:
            dax_cdt_free(cdt)


    def get_cdt(self, name):
        cdef tag_type t
        t = dax_string_to_type(self.__ds, name)

        x = dax_cdt_iter(self.__ds, t, NULL, cdt_callback)

    # Direct wrappers for libdax library functions
    def dax_configure(self):
        x = dax_configure(self.__ds, 1, [self.name], 0)
        if x != 0:  #TODO Better error description
            raise RuntimeError()

    def dax_connect(self):
        x = dax_connect(self.__ds)
        if x != 0:  #TODO Better error description
            raise RuntimeError()

    def dax_tag_add(self, name, type, size):
        cdef Handle h
        x = dax_tag_add(self.__ds, &h, name, type, size)
        if x != 0:  #TODO Better error description
            raise RuntimeError()

        # self.__tags[name] = Member(self, name, h)
        # print(self.__tags)
        # return self.__tags[name]
