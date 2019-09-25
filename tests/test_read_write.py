#  Copyright (c) 2019 Phil Birkelbach
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

import unittest
import subprocess
import time
import pydax

class TestWrite(unittest.TestCase):
    """Test writing data to OpenDAX"""
    def setUp(self):
        self.server = subprocess.Popen(["tagserver"])
        time.sleep(0.1)
        x = self.server.poll()
        self.assertIsNone(x)

    def tearDown(self):
        self.server.terminate()
        self.server.wait()

    def test_write_single_bools(self):
        """Test writing booleans"""
        c = pydax.Client("tagwrite")
        c.dax_configure()
        c.dax_connect()

        c.dax_tag_add("bool1", "bool")  # Single bool without the 'count' argument

        c.write_tag("bool1", True)
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'1\n')
        c.write_tag("bool1", False)
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'0\n')
        c.write_tag("bool1", 1)
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'1\n')
        c.write_tag("bool1", 0)
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'0\n')
        c.write_tag("bool1", "1") # Strings are considered True
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'1\n')
        c.write_tag("bool1", "0") # Strings are considered True
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool1"]), b'1\n')

    def test_write_array_bools(self):
        """Test writing booleans"""
        c = pydax.Client("tagwrite")
        c.dax_configure()
        c.dax_connect()

        c.dax_tag_add("bool2", "bool", 16) # Array of 16 bools
        c.dax_tag_add("bool3", "bool", 2048) # Big array of bools

        l = [b'0'] *16
        c.write_tag("bool2", [True]) # Just writing the first one
        l[0] = b'1'
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')
        c.write_tag("bool2", [False, True, False, True]) # Just writing the first one
        l[0] = b'0'
        l[1] = b'1'
        l[2] = b'0'
        l[3] = b'1'
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')

        l = [b'0'] *16
        c.write_tag("bool2[0]", True) # Just writing the first one
        l[0] = b'1'
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')

        c.write_tag("bool2[15]", True) # Just writing the last one
        l[15] = b'1'
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')

        l = [b'0'] *16
        x =  [False] * 16
        c.write_tag("bool2[0]", x) # Just writing the first one with a whole list
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')

        l = [b'0'] *16
        c.write_tag("bool2[2]", [True, False, True]) # Writing in the middle
        l[2] = b'1'
        l[3] = b'0'
        l[4] = b'1'
        self.assertEqual(subprocess.check_output(["daxc", "-x", "read bool2"]), b"\n".join(l)+b'\n')

        l = [b'0'] *16
        x =  [False] * 16
        with self.assertRaises(pydax.TooBigError):
            c.write_tag("bool2[2]", x) # This sho  uld fail

    def test_write_single_ints(self):
        """Test writing integers"""
        c = pydax.Client("tagwrite")
        c.dax_configure()
        c.dax_connect()

        c.dax_tag_add("d_byte", "byte")
        c.dax_tag_add("d_sint", "sint")
        c.dax_tag_add("d_word", "word")
        c.dax_tag_add("d_int", "int")
        c.dax_tag_add("d_uint", "uint")
        c.dax_tag_add("d_dword", "dword")
        c.dax_tag_add("d_dint", "dint")
        c.dax_tag_add("d_udint", "udint")
        c.dax_tag_add("d_lword", "lword")
        c.dax_tag_add("d_lint", "lint")
        c.dax_tag_add("d_ulint", "ulint")

        should_work = [
                        ("d_byte", 1, b"1\n"),
                        ("d_byte", 0, b"0\n"),
                        ("d_byte", 127, b"127\n"),
                        ("d_byte", 128, b"128\n"),
                        ("d_byte", 255, b"255\n"),
                        ("d_sint", 1, b"1\n"),
                        ("d_sint", -1, b"-1\n"),
                        ("d_sint", 0, b"0\n"),
                        ("d_sint", 127, b"127\n"),
                        ("d_sint", -128, b"-128\n"),
                        ("d_word", 1, b"1\n"),
                        ("d_word", 0, b"0\n"),
                        ("d_word", 32767, b"32767\n"),
                        ("d_word", 65535, b"65535\n"),
                        ("d_uint", 1, b"1\n"),
                        ("d_uint", 0, b"0\n"),
                        ("d_uint", 32767, b"32767\n"),
                        ("d_uint", 65535, b"65535\n"),
                        ("d_int", 1, b"1\n"),
                        ("d_int", -1, b"-1\n"),
                        ("d_int", 0, b"0\n"),
                        ("d_int", 32767, b"32767\n"),
                        ("d_int", -32768, b"-32768\n"),
                        ("d_dword", 1, b"1\n"),
                        ("d_dword", 0, b"0\n"),
                        ("d_dword", 2147483647, b"2147483647\n"),
                        ("d_dword", 4294967295, b"4294967295\n"),
                        ("d_udint", 1, b"1\n"),
                        ("d_udint", 0, b"0\n"),
                        ("d_udint", 2147483647, b"2147483647\n"),
                        ("d_udint", 4294967295, b"4294967295\n"),
                        ("d_dint", -1, b"-1\n"),
                        ("d_dint", 1, b"1\n"),
                        ("d_dint", 0, b"0\n"),
                        ("d_dint", 2147483647, b"2147483647\n"),
                        ("d_dint", -2147483648, b"-2147483648\n"),
                        ("d_lword", 1, b"1\n"),
                        ("d_lword", 0, b"0\n"),
                        ("d_lword", 9223372036854775807, b"9223372036854775807\n"),
                        ("d_lword", 18446744073709551615, b"18446744073709551615\n"),
                        ("d_ulint", 1, b"1\n"),
                        ("d_ulint", 0, b"0\n"),
                        ("d_ulint", 9223372036854775807, b"9223372036854775807\n"),
                        ("d_ulint", 18446744073709551615, b"18446744073709551615\n"),
                        ("d_lint", 1, b"1\n"),
                        ("d_lint", -1, b"-1\n"),
                        ("d_lint", 0, b"0\n"),
                        ("d_lint", 9223372036854775807, b"9223372036854775807\n"),
                        ("d_lint", -9223372036854775808, b"-9223372036854775808\n"),
        ]
        for each in should_work:
            c.write_tag(each[0], each[1])
            self.assertEqual(subprocess.check_output(["daxc", "-x", "read {}".format(each[0])]), each[2])

        should_overflow = [
                        ("d_byte", -1, b"0\n"),
                        ("d_byte", 256, b"255\n"),
                        ("d_sint", 128, b"127\n"),
                        ("d_sint", -129, b"-128\n"),
                        ("d_word", -1, b"0\n"),
                        ("d_word", 65536, b"65535\n"),
                        ("d_uint", -1, b"0\n"),
                        ("d_uint", 65536, b"65535\n"),
                        ("d_int", 32768, b"32767\n"),
                        ("d_int", -32769, b"-32768\n"),
                        ("d_dword", -1, b"0\n"),
                        ("d_dword", 4294967296, b"4294967295\n"),
                        ("d_udint", -1, b"0\n"),
                        ("d_udint", 4294967296, b"4294967295\n"),
                        ("d_dint", 2147483648, b"2147483647\n"),
                        ("d_dint", -2147483649, b"-2147483648\n"),
                        ("d_lword", -1, b"0\n"),
                        ("d_lword", 18446744073709551616, b"18446744073709551615\n"),
                        ("d_ulint", -1, b"0\n"),
                        ("d_ulint", 18446744073709551616, b"18446744073709551615\n"),
                        ("d_lint", 9223372036854775808, b"9223372036854775807\n"),
                        ("d_lint", -9223372036854775809, b"-9223372036854775808\n"),
        ]

        for each in should_overflow:
            c.write_tag(each[0], each[1], clip=True)
            self.assertEqual(subprocess.check_output(["daxc", "-x", "read {}".format(each[0])]), each[2])
            with self.assertRaises(OverflowError):
                c.write_tag(each[0], each[1])


    def test_write_array_ints(self):
        """Test writing integers"""
        c = pydax.Client("tagwrite")
        c.dax_configure()
        c.dax_connect()

        c.dax_tag_add("d_bytes", "byte", 32)
        c.dax_tag_add("d_sints", "sint", 32)
        c.dax_tag_add("d_words", "word", 32)
        c.dax_tag_add("d_ints", "int", 32)
        c.dax_tag_add("d_uints", "uint", 32)
        c.dax_tag_add("d_dwords", "dword", 32)
        c.dax_tag_add("d_dints", "dint", 32)
        c.dax_tag_add("d_udints", "udint", 32)
        c.dax_tag_add("d_lwords", "lword", 32)
        c.dax_tag_add("d_lints", "lint", 32)
        c.dax_tag_add("d_ulints", "ulint", 32)

if __name__ == '__main__':
    unittest.main()
