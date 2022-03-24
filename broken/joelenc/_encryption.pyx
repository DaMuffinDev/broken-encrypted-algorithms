# cython: language_level=3
from h._table cimport character_lookup, lookup_subbyte, reverse_character_lookup, reverse_subbyte_lookup
from h._resources cimport shift_col, shift_row, swap_col, swap_row, xor_grid, create_grid
from tqdm import tqdm
import random
import string

cdef list subbyte_table = [
    [99,  124, 119, 123, 242, 107, 111, 197, 48,  1,   103, 43,  254, 215, 171, 118],
    [202, 130, 201, 125, 250, 89,  71,  240, 173, 212, 162, 175, 156, 164, 114, 192],
    [183, 253, 147, 38,  54,  63,  247, 204, 52,  165, 229, 241, 113, 216, 49,   21],
    [4,   199, 35,  195, 24,  150, 5,   154, 7,   18,  128, 226, 235, 39,  178, 117],
    [9,   131, 44,  26,  27,  110, 90,  160, 82,  59,  214, 179, 41,  227, 47,  132],
    [83,  209, 0,   237, 32,  252, 177, 91,  106, 203, 190, 57,  74,  76,  88,  207],
    [208, 239, 170, 251, 67,  77,  51,  133, 69,  249, 2,   127, 80,  60,  159, 168],
    [81,  163, 64,  143, 146, 157, 56,  245, 188, 182, 218, 33,  16,  255, 243, 210],
    [205, 12,  19,  236, 95,  151, 68,  23,  196, 167, 126, 61,  100, 93,  25,  115],
    [96,  129, 79,  220, 34,  42,  144, 136, 70,  238, 184, 20,  222, 94,  11,  219],
    [224, 50,  58,  10,  73,  6,   36,  92,  194, 211, 172, 98,  145, 149, 228, 121],
    [231, 200, 55,  109, 141, 213, 78,  169, 108, 86,  244, 234, 101, 122, 174,   8],
    [186, 120, 37,  46,  28,  166, 180, 198, 232, 221, 116, 31,  75,  189, 139, 138],
    [112, 62,  181, 102, 72,  3,   246, 14,  97,  53,  87,  185, 134, 193, 29,  158],
    [225, 248, 152, 17,  105, 217, 142, 148, 155, 30,  135, 233, 206, 85,  40,  223],
    [140, 161, 137, 13,  191, 230, 66,  104, 65,  153, 45,  15,  176, 84,  187,  22]
]

cdef list reversed_subbyte_table = [
    [82,  9,   106, 213, 48,  54,  165, 56,  191, 64,  163, 158, 129, 243, 215, 251],
    [124, 227, 57,  130, 155, 47,  255, 135, 52,  142, 67,  68,  196, 222, 233, 203],
    [84,  123, 148, 50,  166, 194, 35,  61,  238, 76,  149, 11,  66,  250, 195,  78],
    [8,   46,  161, 102, 40,  217, 36,  178, 118, 91,  162, 73,  109, 139, 209,  37],
    [114, 248, 246, 100, 134, 104, 152, 22,  212, 164, 92,  204, 93,  101, 182, 146],
    [108, 112, 72,  80,  253, 237, 185, 218, 94,  21,  70,  87,  167, 141, 157, 132],
    [144, 216, 171, 0,   140, 188, 211, 10,  247, 228, 88,  5,   184, 179,  69,   6],
    [208, 44,  30,  143, 202, 63,  15,  2,   193, 175, 189, 3,   1,   19,  138, 107],
    [58,  145, 17,  65,  79,  103, 220, 234, 151, 242, 207, 206, 240, 180, 230, 115],
    [150, 172, 116, 34,  231, 173, 53,  133, 226, 249, 55,  232, 28,  117, 223, 110],
    [71,  241, 26,  113, 29,  41,  197, 137, 111, 183, 98,  14,  170, 24,  190,  27],
    [252, 86,  62,  75,  198, 210, 121, 32,  154, 219, 192, 254, 120, 205, 90,  244],
    [31,  221, 168, 51,  136, 7,   199, 49,  177, 18,  16,  89,  39,  128, 236,  95],
    [96,  81,  127, 169, 25,  181, 74,  13,  45,  229, 122, 159, 147, 201, 156, 239],
    [160, 224, 59,  77,  174, 42,  245, 176, 200, 235, 187, 60,  131, 83,  153,  97],
    [23,  43,  4,   126, 186, 119, 214, 38,  225, 105, 20,  99,  85,  33,   12, 125]
]

cdef list character_table = [
    ['pk',  'zZ',  'Z25', 'Y24', 'YB',  'Ii',  'wW',  'NM',  'ev',  'fU',  'uu',  'OO',  'v21', 'jJ',  'Cx',   'az'], 
    ['ii',  'Jq',  'bY',  'qJ',  'RI',  'kk',  'ol',  'nM',  'BY',  'Cc',  'Ol',  'C2',  'rr',  'kK',  'fu',   'h7'],
    ['R17', 'Uf',  'L11', 'm12', 'XC',  'cx',  'hS',  'mn',  'b1',  'Ve',  'Mn',  'e4',  'd3',  'Q16', 'PK',   'Pk'], 
    ['vV',  'dw',  'ir',  'CC',  'HH',  'CX',  'X23', 'cC',  'Ww',  'Zz',  'Wd',  'AZ',  'gT',  'nn',  'U20',  'Mm'], 
    ['a0',  'fF',  'aa',  'AA',  'mM',  'Sh',  'P15', 'j9',  's18', 'y24', 'FF',  'M12', 'nN',  'cX',  'uF',   'Hs'], 
    ['VV',  'VE',  'DD',  'dW',  'dD',  'wD',  'ff',  'Lo',  'Ri',  'Jj',  'n13', 't19', 'f5',  'g6',  'GG',   'lL'], 
    ['Gg',  'oL',  'BB',  'jq',  'Kp',  'z25', 'uf',  'ZZ',  'XX',  'gg',  'JQ',  'OL',  'qj',  'H7',  'Az',   'Tt'], 
    ['SS',  'jj',  'i8',  'wd',  'Ee',  'Nm',  'Uu',  'eE',  'tT',  'Kk',  'Xx',  'hs',  'mm',  'Yb',  'WW',  'N13'], 
    ['mN',  'T19', 'hh',  'p15', 'KK',  'bb',  'RR',  'dd',  'PP',  'Nn',  'MN',  'Tg',  'rI',  'Ev',  'kp',   'jQ'], 
    ['HS',  'x23', 'yy',  've',  'lO',  'yY',  'pP',  'J9',  'vv',  'Gt',  'S18', 'Dw',  'xC',  'sH',  'NN',   'Bb'], 
    ['B1',  'Fu',  'ZA',  'II',  'O14', 'ww',  'gt',  'o14', 'Qj',  'By',  'Ll',  'GT',  'A0',  'MM',  'Aa',   'oo'],
    ['aZ',  'll',  'Dd',  'hH',  'c2',  'V21', 'u20', 'JJ',  'KP',  'SH',  'ee',  'l11', 'W22', 'Ir',  'G6',   'by'], 
    ['za',  'xc',  'Xc',  'pK',  'LO',  'DW',  'xx',  'tg',  'Ff',  'ss',  'kP',  'Za',  'sh',  'Hh',  'Vv',   'pp'], 
    ['D3',  'iI',  'vE',  'iR',  'tG',  'Pp',  'xX',  'Ss',  'I8',  'w22', 'sS',  'YY',  'QJ',  'ri',  'zA',  'k10'], 
    ['FU',  'zz',  'EE',  'WD',  'eV',  'IR',  'rR',  'F5',  'bB',  'r17', 'qq',  'QQ',  'UU',  'aA',  'K10',  'UF'], 
    ['EV',  'gG',  'Rr',  'q16', 'Yy',  'E4',  'TT',  'oO',  'nm',  'yb',  'yB',  'Oo',  'tt',  'TG',  'Qq',   'cc'], 
]

cdef dict reversed_character_table = {
    "pk":  0x63, "zZ":  0x7c, "Z25": 0x77, "Y24": 0x7b, "YB":  0xf2,  "Ii": 0x6b, "wW": 0x6f,  "NM": 0xc5,  "ev": 0x30, "fU":   0x1,
    "uu":  0x67, "OO":  0x2b, "v21": 0xfe, "jJ":  0xd7, "Cx":  0xab,  "az": 0x76, "ii": 0xca,  "Jq": 0x82,  "bY": 0xc9, "qJ":  0x7d,
    "RI":  0xfa, "kk":  0x59, "ol":  0x47, "nM":  0xf0, "BY":  0xad,  "Cc": 0xd4, "Ol": 0xa2,  "C2": 0xaf,  "rr": 0x9c, "kK":  0xa4,
    "fu":  0x72, "h7":  0xc0, "R17": 0xb7, "Uf":  0xfd, "L11": 0x93, "m12": 0x26, "XC": 0x36,  "cx": 0x3f,  "hS": 0xf7, "mn":  0xcc,
    "b1":  0x34, "Ve":  0xa5, "Mn":  0xe5, "e4":  0xf1, "d3":  0x71, "Q16": 0xd8, "PK": 0x31,  "Pk": 0x15,  "vV":  0x4, "dw":  0xc7,
    "ir":  0x23, "CC":  0xc3, "HH":  0x18, "CX":  0x96, "X23":  0x5,  "cC": 0x9a, "Ww":  0x7,  "Zz": 0x12,  "Wd": 0x80, "AZ":  0xe2,
    "gT":  0xeb, "nn":  0x27, "U20": 0xb2, "Mm":  0x75, "a0":   0x9,  "fF": 0x83, "aa": 0x2c,  "AA": 0x1a,  "mM": 0x1b, "Sh":  0x6e,
    "P15": 0x5a, "j9":  0xa0, "s18": 0x52, "y24": 0x3b, "FF":  0xd6, "M12": 0xb3, "nN": 0x29,  "cX": 0xe3,  "uF": 0x2f, "Hs":  0x84,
    "VV":  0x53, "VE":  0xd1, "DD":   0x0, "dW":  0xed, "dD":  0x20,  "wD": 0xfc, "ff": 0xb1,  "Lo": 0x5b,  "Ri": 0x6a, "Jj":  0xcb,
    "n13": 0xbe, "t19": 0x39, "f5":  0x4a, "g6":  0x4c, "GG":  0x58,  "lL": 0xcf, "Gg": 0xd0,  "oL": 0xef,  "BB": 0xaa, "jq":  0xfb,
    "Kp":  0x43, "z25": 0x4d, "uf":  0x33, "ZZ":  0x85, "XX":  0x45,  "gg": 0xf9, "JQ":  0x2,  "OL": 0x7f,  "qj": 0x50, "H7":  0x3c,
    "Az":  0x9f, "Tt":  0xa8, "SS":  0x51, "jj":  0xa3, "i8":  0x40,  "wd": 0x8f, "Ee": 0x92,  "Nm": 0x9d,  "Uu": 0x38, "eE":  0xf5,
    "tT":  0xbc, "Kk":  0xb6, "Xx":  0xda, "hs":  0x21, "mm":  0x10,  "Yb": 0xff, "WW": 0xf3, "N13": 0xd2,  "mN": 0xcd, "T19":  0xc,
    "hh":  0x13, "p15": 0xec, "KK":  0x5f, "bb":  0x97, "RR":  0x44,  "dd": 0x17, "PP": 0xc4,  "Nn": 0xa7,  "MN": 0x7e, "Tg":  0x3d,
    "rI":  0x64, "Ev":  0x5d, "kp":  0x19, "jQ":  0x73, "HS":  0x60, "x23": 0x81, "yy": 0x4f,  "ve": 0xdc,  "lO": 0x22, "yY":  0x2a,
    "pP":  0x90, "J9":  0x88, "vv":  0x46, "Gt":  0xee, "S18": 0xb8,  "Dw": 0x14, "xC": 0xde,  "sH": 0x5e,  "NN":  0xb, "Bb":  0xdb,
    "B1":  0xe0, "Fu":  0x32, "ZA":  0x3a, "II":   0xa, "O14": 0x49,  "ww":  0x6, "gt": 0x24, "o14": 0x5c,  "Qj": 0xc2, "By":  0xd3,
    "Ll":  0xac, "GT":  0x62, "A0":  0x91, "MM":  0x95, "Aa":  0xe4,  "oo": 0x79, "aZ": 0xe7,  "ll": 0xc8,  "Dd": 0x37, "hH":  0x6d,
    "c2":  0x8d, "V21": 0xd5, "u20": 0x4e, "JJ":  0xa9, "KP":  0x6c,  "SH": 0x56, "ee": 0xf4, "l11": 0xea, "W22": 0x65, "Ir":  0x7a,
    "G6":  0xae, "by":   0x8, "za":  0xba, "xc":  0x78, "Xc":  0x25,  "pK": 0x2e, "LO": 0x1c,  "DW": 0xa6,  "xx": 0xb4, "tg":  0xc6,
    "Ff":  0xe8, "ss":  0xdd, "kP":  0x74, "Za":  0x1f, "sh":  0x4b,  "Hh": 0xbd, "Vv": 0x8b,  "pp": 0x8a,  "D3": 0x70, "iI":  0x3e,
    "vE":  0xb5, "iR":  0x66, "tG":  0x48, "Pp":   0x3, "xX":  0xf6,  "Ss":  0xe, "I8": 0x61, "w22": 0x35,  "sS": 0x57, "YY":  0xb9,
    "QJ":  0x86, "ri":  0xc1, "zA":  0x1d, "k10": 0x9e, "FU":  0xe1,  "zz": 0xf8, "EE": 0x98,  "WD": 0x11,  "eV": 0x69, "IR":  0xd9,
    "rR":  0x8e, "F5":  0x94, "bB":  0x9b, "r17": 0x1e, "qq":  0x87,  "QQ": 0xe9, "UU": 0xce,  "aA": 0x55, "K10": 0x28, "UF":  0xdf,
    "EV":  0x8c, "gG":  0xa1, "Rr":  0x89, "q16":  0xd, "Yy":  0xbf,  "E4": 0xe6, "TT": 0x42,  "oO": 0x68,  "nm": 0x41, "yb":  0x99,
    "yB":  0x2d, "Oo":   0xf, "tt":  0xb0, "TG":  0x54, "Qq":  0xbb,  "cc": 0x16
}

cdef str character_lookup(int byte):
    cdef x = byte >> 4
    cdef y = byte & 15
    return character_table[x][y]

cdef str reverse_character_lookup(str char):
    return reversed_character_table[char]

cdef int lookup_subbyte(int byte):
    cdef x = byte >> 4
    cdef y = byte & 15
    return subbyte_table[x][y]

cdef int reverse_subbyte_lookup(int byte):
    cdef x = byte >> 4
    cdef y = byte & 15
    return reversed_subbyte_table[x][y]

cdef list fill_list(list _list, int characters):
    _list.append("&")
    for i in range(characters):
        _list.append(hex(ord(random.choice(string.ascii_letters))))
    return _list

cdef list create_grid(list hex_values = [], list fill_grid = []):
    if len(hex_values) == 0:
        raise TypeError("Cannot encrypted a string of length 0.")
    cdef list grid_values = []
    for value in [hex_values[i:i + 25] for i in range(0, len(hex_values), 25)]:
        if len(value) == 25: grid_values.append(value); continue
        temp = value
        for i in range(len(value), 25): temp.append(fill_grid[i])
        grid_values.append(temp)
    return [[grid_value[i:i + 5] for i in range(0, len(grid_value), 5)] for grid_value in grid_values]

cdef list shift_row(list _list, int positions, str direction):
    return {"r": [*_list[-positions::], *_list[:-positions]], "l": [*_list[positions::], *_list[:positions]]}[direction]

cdef list shift_col(grid, col_index, positions, direction):
    cdef list col = shift_row([row[col_index] for row in grid], positions, {"u": "l", "d": "r"}[direction])
    for i, row in enumerate(grid): row[col_index] = col[i]
    return grid

cdef list swap_row(list grid, int row1_index, int row2_index):
    grid[row1_index], grid[row2_index] = grid[row2_index], grid[row1_index]
    return grid

cdef list swap_col(list grid, int column1_index, int column2_index):
    for row in grid:
        row[column1_index], row[column2_index] = row[column2_index], row[column1_index]
    return grid

cdef int xor(int hex1, int hex2):
    return hex1 ^ hex2

cdef list xor_row(list row1, list row2):
    return [hex(xor(int(row1[i], 16), int(row2[i], 16))) for i in range(5)]

cdef list xor_grid(list grid1, list grid2):
    return [xor_row(grid1[i], grid2[i]) for i in range(5)]



cdef list generate_fill_grid():
    return [hex(ord(random.choice(string.ascii_letters))) for i in range(25)]

cdef list generate_cipher_grid():
    cdef list values = generate_fill_grid()
    return [values[i:i + 5] for i in range(0, len(values), 5)]

cdef list procedure1(list grid):
    cdef dict shifts = {0: [1, "r"], 1: [2, "r"], 2: [3, "r"], 3: [1, "l"], 4: [2, "l"]}
    return [shift_row(row, *shifts[index]) for index, row in enumerate(grid)]

cdef list procedure2(list grid):
    return swap_row(swap_row(
                shift_col(shift_col(shift_col(
                    swap_col(swap_col(grid, 0, 1), 2, 4),
                        0, 2, "d"), 1, 2, "d"), 3, 2, "u"), 
                            0, 2), 1, 3)

cdef list procedure3(list grid):
    cdef dict instructions = {0: [2, "u"], 1: [2, "u"], 2: [1, "d"], 3: [2, "d"], 4: [1, "d"]}
    for i in range(5):
        grid = shift_col(grid, i, *instructions[i])
    return grid

cdef list procedure4(list state, list p3_grid):
    return [[lookup_subbyte(int(row[i], 16)) for i in range(5)] for row in xor_grid(state, p3_grid)]

cdef str __encrypt(list grid, list cipher_grid):
    return "".join(
        ["".join([chr(v) for v in row]) for row in procedure4(
            grid, procedure3(
                    procedure2(
                        procedure1(xor_grid(grid, cipher_grid)))))])

def encrypt(str text, int rounds=1, bool console=True):
    cdef list cipher_grid = generate_cipher_grid()
    cdef list fill_grid = generate_fill_grid()
    cdef list state = create_grid([hex(ord(t)) for t in text], fill_grid)
    for i in tqdm(range(rounds), desc="Encrypting", disable=not console):
        values = []
        for grid in state:
            values.append(__encrypt(grid, cipher_grid))
        _ = []
        for row in state:
            for v in row:
                _.append(v)
        state = create_grid(v, fill_grid)
    return (
        f"{rounds}.{''.join([''.join([character_lookup(int(v, 16)) for v in row]) for row in cipher_grid])}.{''.join([character_lookup(int(v, 16)) for v in fill_grid])}", 
        "".join([".".join([character_lookup(ord(x)) for x in v]) for v in values])
    ) # decrytion key, encrypted text