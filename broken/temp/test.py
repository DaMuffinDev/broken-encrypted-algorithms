from enc import encrypt, decrypt, ReverseInstructions
from tqdm import tqdm
import time
def main():
    #k, t = encrypt(open("temp/Cookies", "r", errors="ignore").read(), ipc=9, console=False)
    instructions = ReverseInstructions()
    first_shift = instructions.shift("ab", "l", 4)
    print(first_shift)
    reversed_shift = instructions.shift(first_shift, "r", 4)
    print(reversed_shift)
    k, t = encrypt("t", ipc=4)
    print(k)
    print(t)
    print(decrypt(k, t))

if __name__ == "__main__":
    main()