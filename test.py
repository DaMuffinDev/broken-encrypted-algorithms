#from joelenc._samuelv2 import encrypt
import json
import string

def main():
    #print(encrypt("a"))
    d = ""
    l = string.ascii_letters
    for i, v in enumerate(l):
        print(f'{i+1}: "{v}",')
    print(json.dumps(d, indent=3))

if __name__ == "__main__":
    main()