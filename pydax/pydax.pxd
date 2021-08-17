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

from libc.stdint cimport uint8_t as u_int8_t
from libc.stdint cimport uint16_t as u_int16_t
from libc.stdint cimport uint32_t as u_int32_t
from libc.stdint cimport uint64_t as u_int64_t
from libc.stdint cimport int8_t, int16_t, int32_t, int64_t

DEF DAX_TAGNAME_SIZE = 32

cdef extern from "<opendax.h>":
    ctypedef u_int8_t   dax_byte
    ctypedef int8_t     dax_sint
    ctypedef char       dax_char
    ctypedef u_int16_t  dax_word
    ctypedef int16_t    dax_int
    ctypedef u_int16_t  dax_uint
    ctypedef u_int32_t  dax_dword
    ctypedef int32_t    dax_dint
    ctypedef u_int32_t  dax_udint
    ctypedef u_int32_t  dax_time
    ctypedef float      dax_real
    ctypedef u_int64_t  dax_lword
    ctypedef int64_t    dax_lint
    ctypedef u_int64_t  dax_ulint
    ctypedef double     dax_lreal

    ctypedef dax_dint   tag_index
    ctypedef dax_udint  tag_type

    struct dax_state:
        pass
    ctypedef struct dax_cdt:
        pass
    struct cdt_iter:
        const char *name
        tag_type type
        int count
        int byte
        int bit
    struct tag_handle:
        tag_index index
        u_int32_t byte
        unsigned char bit
        u_int32_t count
        u_int32_t size
        tag_type type
    struct dax_tag:
        tag_index idx
        tag_type type
        unsigned int count
        char name[DAX_TAGNAME_SIZE + 1]

    ctypedef struct dax_event_id:
        tag_index index
        int id

    dax_state *dax_init(char *name)
    int dax_init_config(dax_state *ds, char *name)
    int dax_set_luafunction(dax_state *ds, int (*f)(void *L), char *name)
    int dax_add_attribute(dax_state *ds, char *name, char *longopt, char shortopt, int flags, char *defvalue)
    int dax_configure(dax_state *ds, int argc, char **argv, int flags)
    char *dax_get_attr(dax_state *ds, char *name)
    int dax_set_attr(dax_state *ds, char *name, char *value)
    int dax_attr_callback(dax_state *ds, char *name, int (*attr_callback)(char *name, char *value))
    int dax_free_config(dax_state *ds)
    int dax_free(dax_state *ds)

    void dax_set_debug_topic(dax_state *ds, u_int32_t)

    void dax_set_debug(dax_state *ds, void (*debug)(const char *msg))
    void dax_set_error(dax_state *ds, void (*error)(const char *msg))
    void dax_set_log(dax_state *ds, void (*log)(const char *msg))

    void dax_debug(dax_state *ds, int topic, const char *format, ...)
    void dax_error(dax_state *ds, const char *format, ...)
    void dax_log(dax_state *ds, const char *format, ...)
    void dax_fatal(dax_state *ds, const char *format, ...)

    int dax_connect(dax_state *ds)
    int dax_disconnect(dax_state *ds)

    # int dax_mod_get(dax_state *ds, char *modname)
    int dax_mod_set(dax_state *ds, u_int8_t cmd, void *param)

    int dax_tag_add(dax_state *ds, tag_handle *h, char *name, tag_type type, int count, int attr)

    int dax_tag_byname(dax_state *ds, dax_tag *tag, char *name)
    int dax_tag_byindex(dax_state *ds, dax_tag *tag, tag_index index)

    int dax_tag_handle(dax_state *ds, tag_handle *h, char *str, int count)

    int dax_get_typesize(dax_state *ds, tag_type type)

    int dax_read(dax_state *ds, tag_index idx, int offset, void *data, size_t size)
    int dax_write(dax_state *ds, tag_index idx, int offset, void *data, size_t size)
    int dax_mask(dax_state *ds, tag_index idx, int offset, void *data,
                 void *mask, size_t size)

    int dax_read_tag(dax_state *ds, tag_handle handle, void *data)
    int dax_write_tag(dax_state *ds, tag_handle handle, void *data)
    int dax_mask_tag(dax_state *ds, tag_handle handle, void *data, void *mask)

    int dax_event_add(dax_state *ds, tag_handle *handle, int event_type, void *data,
                      dax_event_id *id, void (*callback)(void *udata), void *udata,
                      void (*free_callback)(void *udata))
    int dax_event_del(dax_state *ds, dax_event_id id)
    int dax_event_get(dax_state *ds, dax_event_id id)
    int dax_event_modify(dax_state *ds, int id)
    int dax_event_wait(dax_state *ds, int timeout, dax_event_id *id)
    int dax_event_poll(dax_state *ds, dax_event_id *id)
    int dax_event_get_fd(dax_state *ds)
    int dax_event_dispatch(dax_state *ds, dax_event_id *id)
    int dax_event_string_to_type(char *string)
    char *dax_event_type_to_string(int type)

    tag_type dax_string_to_type(dax_state *ds, char *type)
    const char *dax_type_to_string(dax_state *ds, tag_type type)

    dax_cdt *dax_cdt_new(char *name, int *error)
    int dax_cdt_member(dax_state *ds, dax_cdt *cdt, char *name,
                       tag_type mem_type, unsigned int count)
    int dax_cdt_create(dax_state *ds, dax_cdt *cdt, tag_type *type)
    void dax_cdt_free(dax_cdt *cdt)

    int dax_cdt_iter(dax_state *ds, tag_type type, void *udata, void (*callback)(cdt_iter member, void *udata))
