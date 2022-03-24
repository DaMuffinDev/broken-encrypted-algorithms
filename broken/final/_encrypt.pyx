from random import randint, choice
from tqdm import tqdm
import pathlib
import shutil
import os

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
    return list(bits.values()).index(char)+1

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
        cdef int addition_table = {"r": 1, "l": -1}[direction]
        for i in range(shifts):
            if addition_table + char_id > 52:
                char_id = 1
                continue
            elif addition_table + char_id < 1:
                char_id = 52
                continue
            char_id += addition_table
        self.__char_id = char_id
        self.__output = bits[self.__char_id]
        return (self.__char_id, get_id_char(self.__char_id))

cdef dict extensions = {
    "encrypted_file": ".jenc",
    "decrypt_key": ".jdkc"
}

cdef list cell_types = [16, 32, 64, 256, 512, 1024, 2048]
cdef dict generate_cells(size):
    if not size in cell_types:
        raise TypeError(f"Expected size (16, 32, 64, 256, 512, 1024 or 2048) got {size}")
    cdef dict cells = {}
    for i in range(size): cells[i] = 0
    return cells

cdef class Cell:
    cdef str __cell
    cdef dict __cells
    cdef int __cell_index, __size
    def __cinit__(self, size):
        self.__size = size
        self.__cells = generate_cells(size)
        self.__cell_index = 52
    
    cpdef int get_size(self):
        return self.__size

    cpdef dict get_cells(self):
        return self.__cells

    cpdef int get_cell(self):
        return self.__cells[self.__cell_index]

    cpdef void move(self, index):
        self.__cell_index = index

    cpdef void move_right(self):
        if self.__cell_index + 1 > self.__size-1:
            self.__cell_index = 1
        self.__cell_index += 1
    
    cpdef void move_left(self):
        if self.__cell_index - 1 < 1:
            self.__cell_index = self.__size - 1
        self.__cell_index -= 1
    
    cpdef void allocate(self, int value):
        self.__cells[self.__cell_index] = value

    cpdef void reset(self, int cell_index):
        self.__cells[cell_index] = 0

cdef class Instructions:
    cdef __cell
    cdef str __character, __instructions
    def __cinit__(self, cell, character):
        self.__cell = cell
        self.__character = character
        self.__instructions = ""
    
    cpdef get_cell(self):
        return self.__cell
    
    cpdef check(self):
        if not self.__character in list(bits.values()):
            a = ord(self.__character) if len(self.__character) <= 3 else self.__character
            self.add_instruction(f"%o.{a}".encode("uft8"))
            return a
        return False

    cpdef str get_instructions(self):
        return self.__instructions
    
    cpdef str get_encrypted_text(self):
        c = self.check()
        if not c is False:
            return c
        cdef str text = ""
        for v in self.__cell.get_cells().values():
            text += get_id_char(v)
        return text
    
    cpdef void add_instruction(self, bytes instruction):
        self.__instructions += instruction.decode("utf8")
    
    cpdef void shift(self):
        cdef int cell_index = randint(0, self.__cell.get_size())
        cdef int shifts = randint(1, 15)
        cdef str direction = choice(["l", "r"])
        cdef a = balphabet(self.__character)
        self.__cell.move(cell_index)
        self.__cell.allocate(a.shift(direction, shifts)[0])
        self.add_instruction(f"%s.{cell_index}{direction}{shifts}".encode("utf8"))

    cpdef void scramble_cells(self):
        cdef int shifts
        cdef tuple new_char_id
        cdef str direction
        cdef int cell_size = self.__cell.get_size()
        self.add_instruction(f"%sc.{cell_size}".encode("utf8"))
        for k in self.__cell.get_cells().keys():
            shifts = randint(1, 20)
            direction = choice(["r", "l"])
            new_char_id = balphabet(self.__character).shift(direction, shifts)
            self.__cell.move(k)
            self.__cell.allocate(new_char_id[0])
            self.add_instruction(f"-{direction}{shifts}".encode("utf8"))

cdef str gen_name(int length):
    cdef str name = ""
    for i in range(length):
        name += choice(list(bits.keys()))
    return name

cdef class __encryptor:
    cdef __getitem
    def __cinit__(self, getitem):
        self.__getitem = getitem
    
    def __call__(self, txt, size=256, ipc=8, console=True):
        return self.__getitem(txt, size, ipc, console)
    
    cpdef void __create_decryption_file(self, name, dst, key):
        with open(os.path.join(dst, name), "x") as new_file:
            new_file.write(key.replace("&", "\n"))

    cpdef str file(self, file, size=256, ipc=8, console=True, name=None):
        if os.path.splitext(file)[1] == "." + extensions["encrypted_file"]: continue
        if name is None: name = gen_name(12)
        cdef str new_file, file_parent, key, value, contents
        file_parent = os.path.dirname(file)
        new_file = os.path.join(file_parent, name + extensions["encrypted_file"])

        with open(file, "r", errors="ignore") as file_to_encrypt:
            key, value = self.__getitem(file_to_encrypt.read(), size, ipc, console)
            self.__create_decryption_file(name=name, dst=file_parent, key=key)
            contents = value

        if not os.path.exists(new_file):
            with open(new_file, "x", errors="ignore") as f:
                f.write(contents)
        else:
            with open(new_file, "w", errors="ignore") as f:
                f.write(contents)
        os.remove(file)
        return new_file

    cpdef str folder(self, src, size=256, ipc=8, console=True):
        cdef str path, item
        for item in os.listdir(src):
            path = os.path.join(src, item)
            name = item + extensions["encrypted_file"]
            if os.path.isdir(path):
                self.folder(path, size, ipc, console)
            
            if os.path.isfile(path):
                self.file(path, size, ipc, console, name=name)
        return src

@__encryptor
def encrypt(str txt, int size=256, int ipc=8, console=True):
    cdef str key = ""
    cdef str etext = ""
    cdef cell = Cell(size)
    for c in tqdm(txt, desc="Encrypting", disable=not console):
        instruction = Instructions(cell, c)
        for i in range(ipc):
            if not instruction.check() is False:
                break
            if randint(0, 10) > 7:
                instruction.scramble_cells()
                continue
            instruction.shift()
        instruction.scramble_cells()
        cell = instruction.get_cell()
        key += instruction.get_instructions() + "&"
    etext = instruction.get_encrypted_text()
    return key, etext