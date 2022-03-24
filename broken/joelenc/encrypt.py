from _encryption import _encrypt, encrypt_file, encrypt_folder

__all__ = ["encrypt"]

class __encryptor:
    def __init__(self, _getitem):
        self._getitem = _getitem
    
    file = encrypt_file
    folder = encrypt_folder

@__encryptor
def encrypt(self, text, size=256, console=True):
    return _encrypt(text, {128: 10, 192: 11, 256: 12}[size])

with open("doc/encrypt.txt", "r") as efd_file:
    encrypt.__doc__ = efd_file.read()