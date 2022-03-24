# cython: language_level=3
# proc -> procedures
from _utils cimport add_grids, grid, xor_grid, hex_list, shift_list, shift_col, grid_to_list, fill_list
from _table cimport subbyte_lookup, char_lookup

cdef list convert_text_to_grids(str plaintext, list fill_values):
    cdef list _plaintext = [str(v) for v in plaintext]
    cdef list plaintext_values = [_plaintext[i:i + 25] for i in range(0, len(_plaintext), 25)]
    if not len(plaintext_values[-1]) == 25:
        plaintext_values[-1] = fill_list(plaintext_values[-1], fill_values)
    print(plaintext_values)
    return [grid(hex_list(l)) for l in plaintext_values]

cdef list setup(str plaintext, list cipher_grid, list fill_grid):
    return [xor_grid(add_grids(g, fill_grid), cipher_grid) for g in convert_text_to_grids(plaintext, grid_to_list(fill_grid))]

cdef list proc_round(list grids, list cipher_grid, list secret_grid):
    cdef list subbyte = [[[subbyte_lookup(val) for val in row] for row in grid] for grid in grids]
    cdef list xored = [xor_grid(sg, cipher_grid) for sg in subbyte]
    cdef list added = [add_grids(xg, secret_grid) for xg in xored]
    cdef list col_shifted = proc_shift_cols(added)
    cdef list row_shifted = proc_shift_rows(col_shifted)
    return proc_aram(grids)

cdef list end(list grids, list cipher_grid, list fill_grid):
    cdef list added_grid = add_grids(cipher_grid, fill_grid)
    cdef list final_grids = [xor_grid(grid, added_grid) for grid in grids]
    return [[[char_lookup(v) for v in row] for row in grid] for grid in grids]

cdef list proc_aram(list grids): # Add Rows and Mutliply
    cdef list base_row = [[(row[0] + row[1] + row[2] + row[3] + row[4]) for row in grid] for grid in grids]
    cdef list mul_row = [[row[4], row[2], row[3], row[1], row[0]] for row in base_row]
    return [[[(v * mul_row[ig][i]) for v in row] for i, row in enumerate(grid)] for ig, grid in enumerate(grids)]

cdef list proc_shift_rows(list grids):
    cdef dict shifts = {0: 1, 1: 3, 2: 2, 3: 2, 4: 1}
    cdef dict directions = {0: 'l', 1: 'l', 2: 'l', 3: 'r', 4: 'r'}
    return [[[shift_list(row, shifts[x], directions[x])] for x, row in enumerate(grid)] for i, grid in enumerate(grids)]

cdef list proc_shift_cols(list grids):
    cdef dict shifts = {0: 1, 1: 3, 2: 2, 3: 2, 4: 1}
    cdef dict directions = {0: 'l', 1: 'l', 2: 'l', 3: 'r', 4: 'r'}
    return [[[shift_col(grid, x, directions[x]) for shift in range(shifts[x])] for x in range(5)] for i, grid in enumerate(grids)]