import re
from tqdm import tqdm
import string
import random
from _table import lookup_subbyte, reverse_subbyte_lookup, character_lookup

def fill_list(list, characters: int):
    list.append("&")
    for i in range(characters):
        list.append(hex(ord(random.choice(string.ascii_letters))))
    return list

def create_grid(hex_values=[], fill_grid=[]):
    if len(hex_values) == 0:
        raise TypeError("Cannot encrypted a string of length 0.")
    grid_values = []
    for value in [hex_values[i:i + 25] for i in range(0, len(hex_values), 25)]:
        if len(value) == 25: grid_values.append(value); continue
        temp = value
        for i in range(len(value), 25): temp.append(fill_grid[i])
        grid_values.append(temp)
    return [[grid_value[i:i + 5] for i in range(0, len(grid_value), 5)] for grid_value in grid_values]

def shift_row(list, positions, direction):
    return {"r": [*list[-positions::], *list[:-positions]], "l": [*list[positions::], *list[:positions]]}[direction]

def shift_col(grid, col_index, positions, direction):
    col = shift_row([row[col_index] for row in grid], positions, {"u": "l", "d": "r"}[direction])
    for i, row in enumerate(grid): row[col_index] = col[i]
    return grid

def swap_row(grid, row1_index, row2_index):
    grid[row1_index], grid[row2_index] = grid[row2_index], grid[row1_index]
    return grid

def swap_col(grid, column1_index, column2_index):
    for row in grid:
        row[column1_index], row[column2_index] = row[column2_index], row[column1_index]
    return grid

def xor(hex1, hex2):
    return hex1 ^ hex2

def xor_row(row1, row2):
    return [hex(xor(int(row1[i], 16), int(row2[i], 16))) for i in range(5)]

def xor_grid(grid1, grid2):
    return [xor_row(grid1[i], grid2[i]) for i in range(5)]

"""
Procedure 1:
    Shift (Row 1) 1p Right
    Shift (Row 2) 2p Right
    Shift (Row 3) 3p Right
    Shift (Row 4) 1p Left
    Shift (Row 5) 2p Left

Procedure 2:
    Swap (Column 1) & (Column 2)
    Swap (Column 3) & (Column 5)
    Shift (Column 1) 2p Down
    Shift (Column 2) 2p Down
    Shift (Column 4) 2p Up
    Swap (Row 1) & (Row 3)
    Swap (Row 2) & (Row 4)

Procedure 3:
    Shift (Column 1) 2p Up
    Shift (Column 2) 2p Up
    Shift (Column 3) 1p Down
    Shift (Column 4) 2p Down
    Shift (Column 5) 1p Down
"""

def generate_cipher_grid():
    values = generate_fill_grid()
    return [values[i:i + 5] for i in range(0, len(values), 5)]

def generate_fill_grid():
    return [hex(ord(random.choice(string.ascii_letters))) for i in range(25)]

def procedure1(grid):
    shifts = {0: [1, "r"], 1: [2, "r"], 2: [3, "r"], 3: [1, "l"], 4: [2, "l"]}
    return [shift_row(row, *shifts[index]) for index, row in enumerate(grid)]

def procedure2(grid):
    return swap_row(swap_row(shift_col(shift_col(shift_col(swap_col(swap_col(grid, 0, 1), 2, 4), 0, positions=2, direction="d"), 1, positions=2, direction="d"), 3, positions=2, direction="u"), 0, 2), 1, 3)

def procedure3(grid):
    instructions = {0: [2, "u"], 1: [2, "u"], 2: [1, "d"], 3: [2, "d"], 4: [1, "d"]}
    for i in range(5):
        grid = shift_col(grid, i, *instructions[i])
    return grid

def procedure4(state, p3_grid):
    return [[lookup_subbyte(int(row[i], 16)) for i in range(5)] for row in xor_grid(state, p3_grid)]

def __encrypt(grid, cipher_grid):
    return "".join(["".join([chr(v) for v in row]) for row in procedure4(grid, procedure3(procedure2(procedure1(xor_grid(grid, cipher_grid)))))])

def parse_decryption_key(key):
    return tuple([v for v in key.split(".")])

def set_cipher_key_as_grid(cipher_key):
    return [[int(v, 16) for v in cipher_key[i:i + 5]] for i in range(0, len(cipher_key), 5)]

def get_encrypted_grids(encrypted_text):
    values = encrypted_text.split(".")
    return [[v[i:i + 5] for i in range(0, len(v), 5)] for v in values]

def reverse_procedure1(grid):
    shifts = {0: [1, "l"], 1: [2, "l"], 2: [3, "l"], 3: [1, "r"], 4: [2, "r"]}
    return [shift_row(row, *shifts[index]) for index, row in enumerate(grid)]

def reverse_procedure2(grid):
    return swap_row(swap_row(shift_col(shift_col(shift_col(swap_col(swap_col(grid, 0, 1), 2, 4), 0, positions=2, direction="u"), 1, positions=2, direction="u"), 3, positions=2, direction="d"), 0, 2), 1, 3)

def reverse_procedure3(grid):
    instructions = {0: [2, "d"], 1: [2, "d"], 2: [1, "u"], 3: [2, "u"], 4: [1, "u"]}
    for i in range(5):
        grid = shift_col(grid, i, *instructions[i])
    return grid

def reverse_procedure4(output_grid, cipher_grid):
    return [[reverse_subbyte_lookup(row[i]) for i in range(5)] for row in xor_grid(output_grid, cipher_grid)]

def decrypt(encrypted_text, decryption_key, console=True):
    rounds, _cipher_grid, fill_grid = parse_decryption_key(decryption_key)
    cipher_grid = set_cipher_key_as_grid(_cipher_grid)
    grids = get_encrypted_grids(encrypted_text)
    for i in tqdm(range(int(rounds)), desc="Decrypting", disable=not console):
        values = []
        for grid in grids:
            values.append(__decrypt(grid, cipher_grid))

def encrypt(text, rounds=1, console=True):
    cipher_grid = generate_cipher_grid()
    fill_grid = generate_fill_grid()
    state = create_grid([hex(ord(t)) for t in text], fill_grid)
    for i in tqdm(range(rounds), desc="Encrypting", disable=not console):
        values = []
        for grid in state:
            values.append(__encrypt(grid, cipher_grid))
        _ = []
        for row in state:
            for v in row:
                _.append(v)
        state = create_grid(v, fill_grid)
    decryption_key = f"{rounds}.{''.join([''.join([character_lookup(int(v, 16)) for v in row]) for row in cipher_grid])}.{''.join([character_lookup(int(v, 16)) for v in fill_grid])}"
    encrypted_text = "".join([".".join([character_lookup(ord(x)) for x in v]) for v in values])
    return (decryption_key, encrypted_text)