import random
import string
from _table import character_table, \
    subbyte_table, reversed_subbyte_table, \
        lookup_subbyte, reverse_subbyte_lookup, \
            character_lookup, reverse_character_lookup
from samuel import encrypt, parse_decryption_key
import re

"""
Getting 
"""

def main():
    secret_key, encrypted_text = encrypt("This is a key: length 25.", rounds=1, console=False)
    print(secret_key)
    print(encrypted_text)
    print(parse_decryption_key(secret_key))

if __name__ == "__main__":
    main()