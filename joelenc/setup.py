from Cython.Build import cythonize
import pkg_resources
from setuptools import setup, Extension
import os
import sys

here = os.path.dirname(os.path.abspath(__file__))
extensions = []
files = {
    0: "_enc_proc",
    1: "_utils",
    2: "_table",
    3: "_encrypt",
}
for i in range(4):
    filename = files[i]
    extensions.append(Extension(f"joelenc.{filename}", [os.path.join(here, f"{filename}.pyx")], include_dirs=['.']))

setup(
    name=filename,
    ext_modules=cythonize(extensions, language_level=3)
)