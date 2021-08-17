============
Introduction
============

PyDAX is a package for writing OpenDAX client modules in Python.  OpenDAX is an
open source data acquisition system.  PyDAX is written in cython and is a fairly
simple wrapper for the libdax library.  Libdax is the standard library that is
used to create client modules for the OpenDAX.

OpenDAX is an open source, modular, data acquisition and control system. It is
licensed under the GPL (GNU General Public License) and therefore is completely
free to use and modify.

Most of the work that is done in OpenDAX is done in modules.  The modules are
simply client processes that communicate to a central database server.  Modules
can communicate over a local domain socket or a TCP/IP connection. The details
of this communication are abstracted by the libdax library.
