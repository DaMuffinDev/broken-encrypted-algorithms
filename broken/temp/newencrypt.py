import string
import cython
from _binary import balphabet, bchr, bits
from random import choice as rn_choice, randint as rn_int

class Instructions:
    def __init__(self, character):
        self.__character = character
        self.__encrypted_text = character if character in string.ascii_letters else ""
        self.__instructions = ""
    
    def check(self):
        if not self.__character in string.ascii_letters:
            self.__encrypted_text += rn_choice(list(bits.values()))
            self.add_instruction(f"%o.{ord(self.__character) if len(self.__character) <= 3 else self.__character}")
            return True
        return False

    def add_instruction(self, instruction):
        self.__instructions += instruction
    
    def get_instructions(self):
        return self.__instructions
    
    def get_encrypted_text(self):
        return self.__encrypted_text
    
    def shift(self):
        a = [balphabet(c) for c in self.__encrypted_text]
        direction = rn_choice(["l", "r"])
        shifts = rn_int(5, len(bits)-1)
        for c in a:
            c.shift(direction, shifts)
            self.__encrypted_text = c.get_character()
        self.add_instruction(f"%s.{direction}{shifts}")
    
    def add(self):
        random_character = rn_choice(list(string.ascii_letters))
        self.__encrypted_text += random_character
        self.add_instruction(f"%a.{random_character}")

def encrypt(txt, ipc=8):
    key, new_txt = "", ""
    for t in txt:
        instruction = Instructions(t)
        cmd_table = {
            0: instruction.add,
            1: instruction.shift
        }
        for i in range(ipc):
            if instruction.check(): break
            cmd_table[rn_int(0, 1)]()
        key += instruction.get_instructions()
        new_txt += instruction.get_encrypted_text()
    return (key, new_txt)