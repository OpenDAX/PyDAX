#  PyDAX - A Python extension module for OpenDAX
#  OpenDAX - An open source data acquisition and control system
#  Copyright (c) 2011 Phil Birkelbach
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
#  This is the setup script for the extension module

from setuptools import setup
from setuptools import Extension
from Cython.Build import cythonize

with open("README.rst", "r") as fh:
    long_description = fh.read()

mod_dax = Extension("pydax", ["pydax/pydax.pyx"], libraries=["dax"])

setup(name='PyDAX',
      version="0.1.0",
      author="Phil Birkelbach",
      author_email="phil@petrasoft.net",
      description="PyDAX: Python interface for OpenDAX",
      long_description=long_description,
      test_suite='tests',
      ext_modules=cythonize([mod_dax]))
