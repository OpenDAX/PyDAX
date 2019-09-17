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

import sys

cimport pydax

cdef class Client(object):
    cdef dax_state *ds
    cdef char *name

    def __cinit__(self, name):
        self.name = name
        self.ds = dax_init(name)
        if self.ds is NULL:
            raise MemoryError()
        x = dax_init_config(self.ds, name)
        print(x)

    def configure(self):
        x = dax_configure(self.ds, 1, [self.name], 0)

    def connect(self):
        x = dax_connect(self.ds)
        print(x)
