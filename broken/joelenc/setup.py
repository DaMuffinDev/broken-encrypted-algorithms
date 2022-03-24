from Cython.Build import cythonize
from setuptools import setup
import sys

setup(ext_modules=cythonize(sys.argv[1]))