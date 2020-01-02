from unittest import TestCase

import os
import subprocess
import myCppPackage

class SampleTest(TestCase):
    def test_py_is_none(self):
        self.assertIsNone(myCppPackage.hello_world_python.greeting_py())

    def test_cpp_is_none(self):
        self.assertIsNone(myCppPackage.hello_world_cpp.greeting_cpp())

    def test_cpp_test(self):
        print("\n\nRunning C++ tests...")
        subprocess.check_call(os.path.join(os.path.dirname(
            os.path.relpath(__file__)), "myCppPackage_test"))


if __name__ == "__main__":
    unittest.main()


