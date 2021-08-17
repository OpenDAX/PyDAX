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
# This file contains constants for use in the Module

from libc.float cimport FLT_MAX, DBL_MAX

# Data types
DAX_BOOL    = 0x0010
DAX_BYTE    = 0x0003
DAX_SINT    = 0x0013
DAX_CHAR    = 0x0023
DAX_WORD    = 0x0004
DAX_INT     = 0x0014
DAX_UINT    = 0x0024
DAX_DWORD   = 0x0005
DAX_DINT    = 0x0015
DAX_UDINT   = 0x0025
DAX_TIME    = 0x0035
DAX_REAL    = 0x0045
DAX_LWORD   = 0x0006
DAX_LINT    = 0x0016
DAX_ULINT   = 0x0026
DAX_LREAL   = 0x0036

DAX_CUSTOM  = 0x80000000

DAX_1BIT    = 0x0000
DAX_8BITS   = 0x0003
DAX_16BITS  = 0x0004
DAX_32BITS  = 0x0005
DAX_64BITS  = 0x0006

# Logger
LOG_ERROR   = 0x00000001
LOG_MAJOR   = 0x00000002
LOG_MINOR   = 0x00000004
LOG_FUNC    = 0x00000008
LOG_COMM    = 0x00000010
LOG_MSG     = 0x00000020
LOG_MSGERR  = 0x00000040
LOG_CONFIG  = 0x00000080
LOG_MODULE  = 0x00000100
LOG_VERBOSE = 0x80000000
LOG_ALL     = 0xFFFFFFFF

# Library Errors
ERR_GENERIC   = -1
ERR_NO_SOCKET = -2
ERR_2BIG      = -3
ERR_ARG       = -4
ERR_NOTFOUND  = -5
ERR_MSG_SEND  = -6
ERR_MSG_RECV  = -7
ERR_TAG_BAD   = -8
ERR_TAG_DUPL  = -9
ERR_ALLOC     = -10
ERR_MSG_BAD   = -11
ERR_DUPL      = -12
ERR_NO_INIT   = -13
ERR_TIMEOUT   = -14
ERR_ILLEGAL   = -15
ERR_INUSE     = -16
ERR_PARSE     = -17
ERR_ARBITRARY = -18
ERR_NOTNUMBER = -19
ERR_EMPTY     = -20
ERR_BADTYPE   = -21
ERR_BADINDEX  = -22
ERR_AUTH      = -23
ERR_OVERFLOW  = -24
ERR_UNDERFLOW = -25
ERR_DELETED   = -26
ERR_READONLY  = -27
ERR_WRITEONLY = -28
ERR_NOTIMPLEMENTED  = -29
ERR_FILE_CLOSED = -30


CFG_ARG_NONE     = 0x00
CFG_ARG_OPTIONAL = 0x01
CFG_ARG_REQUIRED = 0x02
CFG_CMDLINE      = 0x04
CFG_MODCONF      = 0x10
CFG_NO_VALUE     = 0x20

EVENT_READ     = 0x01
EVENT_WRITE    = 0x02
EVENT_CHANGE   = 0x03
EVENT_SET      = 0x04
EVENT_RESET    = 0x05
EVENT_EQUAL    = 0x06
EVENT_GREATER  = 0x07
EVENT_LESS     = 0x08
EVENT_DEADBAND = 0x09

EVENT_OPT_SEND_DATA = 0x01

ATOMIC_OP_INC  = 0x0001
ATOMIC_OP_DEC  = 0x0002
ATOMIC_OP_NOT  = 0x0003
ATOMIC_OP_OR   = 0x0004
ATOMIC_OP_AND  = 0x0005
ATOMIC_OP_NOR  = 0x0006
ATOMIC_OP_NAND = 0x0007
ATOMIC_OP_XOR  = 0x0008

DAX_BYTE_MIN    = 0
DAX_BYTE_MAX    = 255
DAX_SINT_MIN    = -128
DAX_SINT_MAX    = 127
DAX_CHAR_MIN    = -128
DAX_CHAR_MAX    = 127
DAX_WORD_MIN    = 0
DAX_WORD_MAX    = 65535
DAX_UINT_MIN    = DAX_WORD_MIN
DAX_UINT_MAX    = DAX_WORD_MAX
DAX_INT_MIN     = -32768
DAX_INT_MAX     = 32767
DAX_DWORD_MIN   = 0
DAX_DWORD_MAX   = 4294967295
DAX_DINT_MIN    = -2147483648
DAX_DINT_MAX    = 2147483647
DAX_UDINT_MIN   = DAX_DWORD_MIN
DAX_UDINT_MAX   = DAX_DWORD_MAX
DAX_TIME_MIN    = DAX_DWORD_MIN
DAX_TIME_MAX    = DAX_DWORD_MAX
DAX_LWORD_MIN   = 0
DAX_LWORD_MAX   = 18446744073709551615ULL
DAX_LINT_MIN    = -9223372036854775808LL
DAX_LINT_MAX    = 9223372036854775807LL
DAX_ULINT_MIN   = DAX_LWORD_MIN
DAX_ULINT_MAX   = DAX_LWORD_MAX
DAX_REAL_MIN   = -FLT_MAX
DAX_REAL_MAX    = FLT_MAX
DAX_LREAL_MIN  = -DBL_MAX
DAX_LREAL_MAX   = DBL_MAX

# DAX_TAGNAME_SIZE = 32

# This is here to deal with some bug about an init function not existing
# cdef class dummy(object):
#     pass
