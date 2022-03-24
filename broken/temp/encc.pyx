# cython: language_level=3
from _binary import balphabet, bchr, bits
from random import choice, randint
from string import ascii_letters
from tqdm import tqdm

cdef str letters = ascii_letters
cdef class Instructions:
    cdef public str __character, __encrypted_text, __instructions
    def __init__(self, character):
        self.__character = character
        self.__encrypted_text = character if character in letters else ""
        self.__instructions = ""
    
    cpdef check(self):
        if not self.__character in letters:
            self.__encrypted_text += choice(list(bits.values()))
            self.add_instruction(f"%o.{ord(self.__character) if len(self.__character) <= 3 else self.__character}")
            return True
        return False

    cpdef void add_instruction(self, instruction):
        self.__instructions += instruction
    
    cpdef str get_instructions(self):
        return self.__instructions
    
    cpdef str get_encrypted_text(self):
        return self.__encrypted_text
    
    cpdef void shift(self):
        cdef list a = [balphabet(c) for c in self.__encrypted_text]
        cdef str direction = choice(["l", "r"])
        cdef int shifts = randint(5, len(bits)-1)
        for c in a:
            c.shift(direction, shifts)
            self.__encrypted_text = c.get_character()
        self.add_instruction(f"%s.{direction}{shifts}")
    
    cpdef void add(self):
        cdef str random_character = choice(list(letters))
        self.__encrypted_text += random_character
        self.add_instruction(f"%a.{random_character}")

def encrypt(str txt, int ipc=8, console=True):
    cdef str key = ""
    cdef str new_txt = ""
    cdef dict cmd_table = {}
    for t in tqdm(txt, desc="Encrypting", disable=not console):
        instruction = Instructions(t)
        cmd_table = {
            0: instruction.add,
            1: instruction.shift
        }
        for i in range(ipc):
            if instruction.check(): break
            cmd_table[randint(0, 1)]()
        key += instruction.get_instructions()
        new_txt += instruction.get_encrypted_text()
    return (key, new_txt)