# TODO: Modify tests
# TODO: Check for src/include files inclusions

## Shell script to build a Python-C++ package skeleton

#!/bin/bash

usage()  {
    echo "usage: $programname [-h] name"
    echo ""
    echo "-h     display help"
    echo "name:  name of the package; populates into targeted places throughout"
    exit 0
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi


## -----------------------
echo Creating directories
mkdir -p $1/src/$1
mkdir -p $1/lib
mkdir -p $1/include
mkdir -p $1/build
mkdir -p $1/tests


## -------------------
echo Creating LICENSE

license="Copyright \(c\) 2018

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files \(the \"Software\"\), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"

echo "$license" > $1/LICENSE

## -----------------------
echo Creating manifest
manifest="# Include the README
include *.md

# Include the license file
include LICENSE

# Include the data files
recursive-include data *
"
echo "$manifest" > $1/MANIFEST.in


## -------------------
echo Creating README.md
readme="# Example Package

This is a simple example package. You can use
[Github-flavored Markdown](https://guides.github.com/features/mastering-markdown/)
to write your content.
"
echo "$readme" > $1/README.md


## -----------------------
## Load pybind11 to handle the bindings
echo "Downloading pybind11"
wget https://github.com/pybind/pybind11/archive/v2.4.3.tar.gz
echo "Unpacking pybind11"
tar -xf v2.4.3.tar.gz
mv pybind11-2.4.3 $1/lib/pybind11
rm -rf pybind11-2.3.4
rm v2.4.3.tar.gz


## -------------------
echo Creating setup files
setup="import os
import platform
import re
import setuptools
import subprocess
import sys
import sysconfig

from distutils.version import LooseVersion
from setuptools.command.build_ext import build_ext

with open(\"README.md\", \"r\") as fh:
    long_description = fh.read()


class CMakeExtension(setuptools.Extension):
    def __init__(self, name, sourcedir=\"\"):
        setuptools.Extension.__init__(self, name, sources=[])
        self.sourcedir = os.path.abspath(sourcedir)


class CMakeBuild(build_ext):
    def run(self):
        try:
            out = subprocess.check_output([\"cmake\", \"--version\"])
        except OSError:
            raise RuntimeError(
                               \"CMake must be installed to build the followingextensions: \" +
                               \", \".join(e.name for e in self.extensions))

        if platform.system() == \"Windows\":
            cmake_version = LooseVersion(re.search(r\"version\s*([\d.]+)\",
                                         out.decode()).group(1))

        for ext in self.extensions:
            self.build_extension(ext)

    def build_extension(self, ext):
        extdir = os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.name)))
        cmake_args = []
        cmake_args += [\"-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=\" + extdir,
                      \"-DPYTHON_EXECUTABLE=\" + sys.executable]

        cfg = \"Debug\" if self.debug else \"Release\"
        build_args = [\"--config\", cfg]

        if platform.system() == \"Windows\":
            cmake_args += [\"-DCMAKE_LIBRARY_OUTPUT_DIRECTORY_{}={}\".format(cfg.upper(), extdir)]
            build_args += [\"--\", \"/m\"]

        else:
            cmake_args += [\"-DCMAKE_BUILD_TYPE=\" + cfg]
            build_args += [\"--\", \"-j2\"]

        env = os.environ.copy()
        env[\"CXXFLAGS\"] = '{} -DVERSION_INFO=\\\"{}\\\"'.format(
            env.get(\"CXXFLAGS\", \"\"), self.distribution.get_version())

        if not os.path.exists(self.build_temp):
            os.makedirs(self.build_temp)

        print(\" \".join(e for e in [\"cmake\", ext.sourcedir] + cmake_args))
        subprocess.check_call([\"cmake\", ext.sourcedir] + cmake_args,
                              cwd=self.build_temp, env=env)

        subprocess.check_call([\"cmake\", \"--build\", \".\"] + 
                              build_args, cwd=self.build_temp)

        print()
    
                                            
setuptools.setup(name=\"$1\",
    version=\"0.1\",
    description=\"A Python-C++ package\",
    url=\"http://github.com/mygit/$1\",
    author=\"author\",
    author_email=\"author@$1.com\",
    license=\"MIT\",
    zip_safe=False,
    long_description=long_description,
    long_description_content_type=\"text/markdown\",
    packages=setuptools.find_packages(\"src\"),
    package_dir={\"\":\"src\"},
    ext_modules=[CMakeExtension(\"$1/$1\")],
    cmdclass=dict(build_ext=CMakeBuild),
    classifiers=[
        \"Development Status :: 3 - Alpha\",
        \"Intended Audience :: Developers\",
        \"Topic :: Software Development :: Build Tools\",
        \"Programming Language :: Python :: 3\",
        \"License :: OSI Approved :: MIT License\",
        \"Operating System :: OS Independent\",
    ],
    keywords=\"sample package development\",
    project_urls={},
    py_modules=[],
    install_requires=[
        \"markdown\",
    ],
    python_requires=\">=3\",
    data_files=[],
    include_package_data=True,
    scripts=[],
    test_suite=\"tests\",
)
"

echo "$setup" > $1/setup.py

cfg="[metadata]
license_files = LICENSE
"

echo "$cfg" > $1/setup.cfg


## ----------------------
echo Creating Hello World
init="# We've coded the bindings so that the source files behave like modules
from .hello_world_cpp import *

# Standard python imports
from .hello_world_python import *
"
echo "$init" > "$1/src/$1/__init__.py"

rm -f $1/src/$1/hello_world.py
hello_world_python="def greeting_py():
    \"\"\"A simple Python function\"\"\"  
    print(\"Hello World, from Python!\")
"
echo "$hello_world_python" > $1/src/$1/hello_world_python.py


## -----------------------
echo Creating C++ functions
hello_world_hpp="#include <iostream>

/*! A simple C++ function */
void greeting_cpp();
"

echo "$hello_world_hpp" > $1/src/$1/hello_world_cpp.hpp


hello_world_cpp="#include <pybind11/pybind11.h>
#include \"hello_world_cpp.hpp\"

void greeting_cpp()
{
    std::cout << \"Hello World, from C++!\" << std::endl;
}

namespace py = pybind11;

PYBIND11_MODULE(hello_world_cpp, m)
{
    m.def(\"greeting_cpp\", &greeting_cpp);
}

"

echo "$hello_world_cpp" > $1/src/$1/hello_world_cpp.cpp


## -----------------------
## CMakeLists for build

cmake="cmake_minimum_required(VERSION 2.8.12)
project(test)

# Set source directory
set(SOURCE_DIR \"src/test\")

# Tell CMake that headers are also in SOURCE_DIR
include_directories(\${SOURCE_DIR})
set(SOURCES \"\${SOURCE_DIR}/hello_world_cpp.cpp\")

# Generate Python module
add_subdirectory(lib/pybind11)

pybind11_add_module(hello_world_cpp \${SOURCES})
"

echo "$cmake" > $1/CMakeLists.txt

## -----------------------
echo Creating tests
echo "" > $1/tests/__init__.py

test="from unittest import TestCase

import test

class SampleTest(TestCase):
    def test_py_is_none(self):
        self.assertIsNone(test.hello_world_python.greeting_py())

    def test_cpp_is_none(self):
        self.assertIsNone(test.hello_world_cpp.greeting_cpp())

if __name__ == \"__main__\":
    unittest.main()

"

echo "$test" > $1/tests/hello_world_test.py


