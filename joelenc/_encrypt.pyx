# cython: language_level=3
cimport _enc_proc
cimport _utils
from _enc_proc cimport setup, proc_round, end
from _utils cimport create_cipher_grid, create_fill_values, grid, convert_grid_to_text
from tqdm import tqdm

def encrypt(str plaintext, int rounds=12, console=True):
    cdef list cipher_grid = create_cipher_grid()
    cdef list secret_grid = create_cipher_grid()
    cdef list fill_values = create_fill_values()
    cdef list grids = setup(plaintext, cipher_grid, grid(fill_values))
    for i in tqdm(range(rounds), desc="Encrypting", disable=not console):
        grids = proc_round(grids, cipher_grid, secret_grid)
    grids = end(grids, cipher_grid, grid(fill_values))
    return (
        convert_grid_to_text(cipher_grid) + convert_grid_to_text(secret_grid) + "".join(fill_values),
        "".join([convert_grid_to_text(grid) for grid in grids])
    )
