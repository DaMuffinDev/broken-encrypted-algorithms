# cython: language_level=3
import random

cdef list letters = ["a", "b", "c", "d", "e", "f"]
cdef list numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
cdef list letters_and_numbers = [*letters, *numbers]


cdef int xor(int int1, int int2):
    return int1 ^ int2

cdef list xor_grid(list grid1, list grid2):
    return [[xor(grid1[row][val], grid2[row][val]) for val in range(5)] for row in range(5)]


cdef list grid(list values):
    return [values[i:i + 5] for i in range(0, len(values), 5)]

cdef list add_grids(list grid1, list grid2):
    return grid([(grid1[row][val] + grid2[row][val]) for val in row] for row in range(5))


cdef list create_fill_values():
    return [random.choice(letters_and_numbers) for i in range(25)]

cdef list create_cipher_grid():
    return grid(create_fill_values())


cdef list fill_list(list _list, list _fill):
    for i in range(len(_list) - 1, 25):
        _list.append(_fill[i])
    return _list

cdef list hex_list(list _list):
    return [ord(l) for l in _list]

cdef list grid_to_list(list grid):
    new_list = []
    for row in grid:
        for v in row:
            new_list.append(v)
    return new_list


cdef list shift_right(list l):
    return [*_list[-positions::], *_list[:-positions]]

cdef list shift_left(list l):
    return [*_list[positions::], *_list[:positions]]

cdef list shift_list(list l, int positions, str direction):
    new_list = l
    f = {'r': shift_right, 'l': shift_left}
    for i in range(positions):
        new_list = f[direction](new_list)
    return new_list

cdef list shift_col(list grid, int col_index, str direction):
    cdef list rows = [row[col_index] for row in grid]
    cdef list col = {"r": shift_right(rows), "l": shift_left(rows)}[direction]
    for i, row in enumerate(grid):
        row[i] = col[i]
    return grid


cdef str convert_grid_to_text(grid):
    return "".join(["".join(row) for row in grid])