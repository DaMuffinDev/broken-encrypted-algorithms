cdef list convert_text_to_grids(str plaintext, list fill_values)
cdef list setup(str plaintext, list cipher_grid, list fill_grid)
cdef list proc_round(list grids, list cipher_grid, list secret_grid)
cdef list end(list grids, list cipher_grid, list fill_grid)
cdef list proc_aram(list grids)
cdef list proc_shift_rows(list grids)
cdef list proc_shift_cols(list grids)