import os
import platform
import re
import setuptools
import subprocess
import sys
import sysconfig

from distutils.version import LooseVersion
from setuptools.command.build_ext import build_ext

with open("README.md", "r") as fh:
    long_description = fh.read()


class CMakeExtension(setuptools.Extension):
    def __init__(self, name, sourcedir=""):
        setuptools.Extension.__init__(self, name, sources=[])
        self.sourcedir = os.path.abspath(sourcedir)


class CMakeBuild(build_ext):
    def run(self):
        try:
            out = subprocess.check_output(["cmake", "--version"])
        except OSError:
            raise RuntimeError(
                               "CMake must be installed to build the followingextensions: " +
                               ", ".join(e.name for e in self.extensions))

        if platform.system() == "Windows":
            cmake_version = LooseVersion(re.search(r"version\s*([\d.]+)",
                                         out.decode()).group(1))

        for ext in self.extensions:
            self.build_extension(ext)

    def build_extension(self, ext):
        extdir = os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.name)))
        cmake_args = []
        cmake_args += ["-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=" + extdir,
                      "-DPYTHON_EXECUTABLE=" + sys.executable]

        cfg = "Debug" if self.debug else "Release"
        build_args = ["--config", cfg]

        if platform.system() == "Windows":
            cmake_args += ["-DCMAKE_LIBRARY_OUTPUT_DIRECTORY_{}={}".format(cfg.upper(), extdir)]
            build_args += ["--", "/m"]

        else:
            cmake_args += ["-DCMAKE_BUILD_TYPE=" + cfg]
            build_args += ["--", "-j2"]

        env = os.environ.copy()
        env["CXXFLAGS"] = '{} -DVERSION_INFO=\"{}\"'.format(
            env.get("CXXFLAGS", ""), self.distribution.get_version())

        if not os.path.exists(self.build_temp):
            os.makedirs(self.build_temp)

        print(" ".join(e for e in ["cmake", ext.sourcedir] + cmake_args))
        subprocess.check_call(["cmake", ext.sourcedir] + cmake_args,
                              cwd=self.build_temp, env=env)

        subprocess.check_call(["cmake", "--build", "."] + 
                              build_args, cwd=self.build_temp)

        print()
    
                                            
setuptools.setup(name="myCppPackage",
    version="0.1",
    description="A Python-C++ package",
    url="http://github.com/mygit/myCppPackage",
    author="author",
    author_email="author@myCppPackage.com",
    license="MIT",
    zip_safe=False,
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages("src"),
    package_dir={"":"src"},
    ext_modules=[CMakeExtension("myCppPackage/myCppPackage")],
    cmdclass=dict(build_ext=CMakeBuild),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    keywords="sample package development",
    project_urls={},
    py_modules=[],
    install_requires=[
        "markdown",
    ],
    python_requires=">=3",
    data_files=[],
    include_package_data=True,
    scripts=[],
    test_suite="tests",
)

