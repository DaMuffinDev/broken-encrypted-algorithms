from _encrypt import encrypt as _encrypt

class __encryptor:
    def __init__(self, getitem):
        self._getitem = getitem
        self.__doc__ = getitem.__doc__
    
    def __call__(self, plaintext, rounds=12, console=True):
        return self._getitem(self, plaintext, rounds, console)

@__encryptor
def encrypt(self, plaintext, rounds, console):
    return _encrypt(plaintext, rounds, console)