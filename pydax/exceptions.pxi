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
# This file contains exceptions for use in the Module


# DAX Library Errors
class GenericError(Exception):
    pass

class NoSocketError(Exception):
    pass

class TooBigError(Exception):
    pass

class ArgError(Exception):
    pass

class NotNoundError(Exception):
    pass

class MsgSendError(Exception):
    pass

class MsgRecvError(Exception):
    pass

class TagBadError(Exception):
    pass

class TagDuplError(Exception):
    pass

class AllocError(Exception):
    pass

class MsgBadError(Exception):
    pass

class DuplError(Exception):
    pass

class NoInitError(Exception):
    pass

class TimeoutError(Exception):
    pass

class IllegalError(Exception):
    pass

class InUseError(Exception):
    pass

class ParseError(Exception):
    pass

class ArbitraryError(Exception):
    pass

class NotNumberError(Exception):
    pass

class EmptyError(Exception):
    pass

class BadTypeError(Exception):
    pass

class AuthError(Exception):
    pass

# TODO: Probably should make some DAX only Exceptions for all of these
# This function returns an exception object that depends on the value of the
# error 'e'
def getError(e):
    print(e)
    exceptions = {
                    ERR_GENERIC:GenericError,
                    ERR_NO_SOCKET:NoSocketError,
                    ERR_2BIG:TooBigError,
                    ERR_ARG:ArgError,
                    ERR_NOTFOUND:NotNoundError,
                    ERR_MSG_SEND:MsgSendError,
                    ERR_MSG_RECV:MsgRecvError,
                    ERR_TAG_BAD:TagBadError,
                    ERR_TAG_DUPL:TagDuplError,
                    ERR_ALLOC:AllocError,
                    ERR_MSG_BAD:MsgBadError,
                    ERR_DUPL:DuplError,
                    ERR_NO_INIT:NoInitError,
                    ERR_TIMEOUT:TimeoutError,
                    ERR_ILLEGAL:IllegalError,
                    ERR_INUSE:InUseError,
                    ERR_PARSE:ParseError,
                    ERR_ARBITRARY:ArbitraryError,
                    ERR_NOTNUMBER:NotNumberError,
                    ERR_EMPTY:EmptyError,
                    ERR_BADTYPE:BadTypeError,
                    ERR_AUTH:AuthError
                }

    if e in exceptions.keys():
        ex = exceptions[e]
        return ex
    else:
        return RuntimeError("Unknown Error {}".format(e))
