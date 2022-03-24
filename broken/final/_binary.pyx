cdef dict bits = {
    1: "a",
    2: "b",
    3: "c",
    4: "d",
    5: "e",
    6: "f",
    7: "g",
    8: "h",
    9: "i",
    10: "j",
    11: "k",
    12: "l",
    13: "m",
    14: "n",
    15: "o",
    16: "p",
    17: "q",
    18: "r",
    19: "s",
    20: "t",
    21: "u",
    22: "v",
    23: "w",
    24: "x",
    25: "y",
    26: "z",
    27: "A",
    28: "B",
    29: "C",
    30: "D",
    31: "E",
    32: "F",
    33: "G",
    34: "H",
    35: "I",
    36: "J",
    37: "K",
    38: "L",
    39: "M",
    40: "N",
    41: "O",
    42: "P",
    43: "Q",
    44: "R",
    45: "S",
    46: "T",
    47: "U",
    48: "V",
    49: "W",
    50: "X",
    51: "Y",
    52: "Z"
}

cdef int get_char_id(str char):
    return list(bits.values()).index(char)

cdef str get_id_char(int id):
    return bits[id]

cdef class balphabet:
    cdef str __letter, __output
    cdef int __char_id
    def __cinit__(self, letter):
        self.__char_id = get_char_id(letter)
        self.__letter = letter
        self.__output = bits[self.__char_id]

    cpdef int get_id(self):
        return self.__char_id
    
    cpdef str get_letter(self):
        return self.__output

    cpdef tuple shift(self, str direction, int shifts):
        cdef int char_id = self.__char_id
        cdef dict addition_table = {"r": 1, "l": -1}[direction]
        for i in range(shifts):
            char_id += ((52 - char_id, addition_table)[addition_table + char_id < 0], -char_id)[addition_table + char_id > 52]
        self.__output = bits[self.__char_id]
        return (self.__char_id, get_id_char(self.__char_id))