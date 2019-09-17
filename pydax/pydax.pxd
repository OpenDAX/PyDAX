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

# Data types
DEF DAX_BOOL    = 0x0010
DEF DAX_BYTE    = 0x0003
DEF DAX_SINT    = 0x0013
DEF DAX_WORD    = 0x0004
DEF DAX_INT     = 0x0014
DEF DAX_UINT    = 0x0024
DEF DAX_DWORD   = 0x0005
DEF DAX_DINT    = 0x0015
DEF DAX_UDINT   = 0x0025
DEF DAX_TIME    = 0x0035
DEF DAX_REAL    = 0x0045
DEF DAX_LWORD   = 0x0006
DEF DAX_LINT    = 0x0016
DEF DAX_ULINT   = 0x0026
DEF DAX_LREAL   = 0x0036

DEF DAX_CUSTOM  = 0x80000000

DEF DAX_1BIT    = 0x0000
DEF DAX_8BITS   = 0x0003
DEF DAX_16BITS  = 0x0004
DEF DAX_32BITS  = 0x0005
DEF DAX_64BITS  = 0x0006

# Logger
DEF LOG_ERROR   = 0x00000001
DEF LOG_MAJOR   = 0x00000002
DEF LOG_MINOR   = 0x00000004
DEF LOG_FUNC    = 0x00000008
DEF LOG_COMM    = 0x00000010
DEF LOG_MSG     = 0x00000020
DEF LOG_MSGERR  = 0x00000040
DEF LOG_CONFIG  = 0x00000080
DEF LOG_MODULE  = 0x00000100
DEF LOG_VERBOSE = 0x80000000
DEF LOG_ALL     = 0xFFFFFFFF

# Library Errors
DEF ERR_GENERIC   = -1
DEF ERR_NO_SOCKET = -2
DEF ERR_2BIG      = -3
DEF ERR_ARG       = -4
DEF ERR_NOTFOUND  = -5
DEF ERR_MSG_SEND  = -6
DEF ERR_MSG_RECV  = -7
DEF ERR_TAG_BAD   = -8
DEF ERR_TAG_DUPL  = -9
DEF ERR_ALLOC     = -10
DEF ERR_MSG_BAD   = -11
DEF ERR_DUPL      = -12
DEF ERR_NO_INIT   = -13
DEF ERR_TIMEOUT   = -14
DEF ERR_ILLEGAL   = -15
DEF ERR_INUSE     = -16
DEF ERR_PARSE     = -17
DEF ERR_ARBITRARY = -18
DEF ERR_NOTNUMBER = -19
DEF ERR_EMPTY     = -20
DEF ERR_BADTYPE   = -21
DEF ERR_AUTH      = -22

DEF CFG_ARG_NONE     = 0x00
DEF CFG_ARG_OPTIONAL = 0x01
DEF CFG_ARG_REQUIRED = 0x02
DEF CFG_CMDLINE      = 0x04
DEF CFG_MODCONF      = 0x10
DEF CFG_NO_VALUE     = 0x20

DEF EVENT_READ     = 0x01
DEF EVENT_WRITE    = 0x02
DEF EVENT_CHANGE   = 0x03
DEF EVENT_SET      = 0x04
DEF EVENT_RESET    = 0x05
DEF EVENT_EQUAL    = 0x06
DEF EVENT_GREATER  = 0x07
DEF EVENT_LESS     = 0x08
DEF EVENT_DEADBAND = 0x09

DEF DAX_BYTE_MIN    = 0
DEF DAX_BYTE_MAX    = 255
DEF DAX_SINT_MIN    = -128
DEF DAX_SINT_MAX    = 127
DEF DAX_WORD_MIN    = 0
DEF DAX_WORD_MAX    = 65535
DEF DAX_UINT_MIN    = DAX_WORD_MIN
DEF DAX_UINT_MAX    = DAX_WORD_MAX
DEF DAX_INT_MIN     = -32768
DEF DAX_INT_MAX     = 32767
DEF DAX_DWORD_MIN   = 0
DEF DAX_DWORD_MAX   = 4294967295
DEF DAX_DINT_MIN    = -2147483648
DEF DAX_DINT_MAX    = 2147483647
DEF DAX_UDINT_MIN   = DAX_DWORD_MIN
DEF DAX_UDINT_MAX   = DAX_DWORD_MAX
DEF DAX_TIME_MIN    = DAX_DWORD_MIN
DEF DAX_TIME_MAX    = DAX_DWORD_MAX
DEF DAX_LWORD_MIN   = -9223372036854775808LL
DEF DAX_LWORD_MAX   = 9223372036854775807LL
DEF DAX_LINT_MIN    = DAX_LWORD_MIN
DEF DAX_LINT_MAX    = DAX_LWORD_MAX
DEF DAX_ULINT_MIN   = 0
DEF DAX_ULINT_MAX   = 18446744073709551615ULL
# DEF DAX_REAL_MIN   = -FLT_MAX
# DEF DAX_REAL_MAX    = FLT_MAX
# DEF DAX_LREAL_MIN  = -DBL_MAX
# DEF DAX_LREAL_MAX   = DBL_MAX


cdef extern from "<opendax.h>":
    struct dax_state:
        pass
    dax_state *dax_init(char *name)
    int dax_init_config(dax_state *ds, char *name)
    int dax_configure(dax_state *ds, int argc, char **argv, int flags)

    int dax_connect(dax_state *ds)
    int dax_disconnect(dax_state *ds)
