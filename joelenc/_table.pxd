
cdef list sb_table, rsb_table, chr_table
cdef dict rchr_table

cdef int subbyte_lookup(byte)
cdef str char_lookup(byte)
cdef int reverse_subbyte_lookup(byte)
cdef int reverse_char_lookup(str char)