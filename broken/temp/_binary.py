bits = {
    0: "a",
    1: "b",
    2: "c",
    3: "d",
    4: "e",
    5: "f",
    6: "g",
    7: "h",
    8: "i",
    9: "j",
    10: "k",
    11: "l",
    12: "m",
    13: "n",
    14: "o",
    15: "p",
    16: "q",
    17: "r",
    18: "s",
    19: "t",
    20: "u",
    21: "v",
    22: "w",
    23: "x",
    24: "y",
    25: "z",
    26: "A",
    27: "B",
    28: "C",
    29: "D",
    30: "E",
    31: "F",
    32: "G",
    33: "H",
    34: "I",
    35: "J",
    36: "K",
    37: "L",
    38: "M",
    39: "N",
    40: "O",
    41: "P",
    42: "Q",
    43: "R",
    44: "S",
    45: "T",
    46: "U",
    47: "V",
    48: "W",
    49: "X",
    50: "Y",
    51: "Z"
}

def bord(c):
    if len(c) > 1:
        raise TypeError(f"bord expected a str of length 1 got ({len(c)})")
    return list(bits.values()).index(c)

def bchr(i):
    if not isinstance(i, int):
        raise TypeError(f"bchr expected an int got \"{type(i)}\"")
    return bits[i]

class balphabet:
    def __init__(self, c):
        self.__character = c
        self.bit_id = bord(c)
        self.SHIFTRIGHT = "r"
        self.SHIFTLEFT = "l"

    def parse(self):
        return self.__character

    def get_character(self):
        return bchr(self.bit_id)

    def shift(self, direction, shifts):
        bit_id = self.bit_id
        bit_keys_length = len(bits.keys())
        for i in range(shifts):
            bit_id += {self.SHIFTRIGHT: 1, self.SHIFTLEFT: -1}[direction]
            if bit_id > bit_keys_length - 1:
                bit_id = -1
            
            if bit_id < 0:
                bit_id = bit_keys_length - 1
        self.bit_id = bit_id
        self.__character = bchr(self.bit_id)
