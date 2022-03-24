import string
from _binary import balphabet
import encc

encrypt = encc.encrypt

class ReverseInstructions:
    def check(self, num):
        return chr(num)

    def shift(self, text, direction, shifts):
        a = [balphabet(c) for c in text]
        opposite = {"l": "r", "r": "l"}[direction]
        for c in a:
            c.shift(opposite, shifts)
        return "".join([x.get_character() for x in a])

letters = string.ascii_letters
def decrypt(key, text):
    new_text, txt = "", ""
    instructions = ReverseInstructions()
    for i, v in reversed(list(enumerate(key.split("&")))):
        for cmds in reversed(v.split("%")):
            current_func = ""
            for i, c in reversed(list(enumerate(cmds))):
                if c == "a":
                    try:
                        if cmds[i+1] == ".":
                            txt = "".join(list(text).pop())
                    except: continue
                    print("removing")
                elif c == "s" and cmds[i+1] == ".":
                    current_func = "s"
                    print("shifting")
                if current_func == "s" and c in letters:
                    if c == "s":
                        direction = cmds[i+2]
                        shifts = cmds[i+3]
                    txt = instructions.shift(text, direction, int(shifts))
                    print(f"Shift: {txt}")
                    current_func = ""
            if not txt == "":
                new_text += txt
                txt = ""
    return new_text
