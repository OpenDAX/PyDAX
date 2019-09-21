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

class TestTypes(unittest.TestCase):

    def setUp(self):
        self.server = subprocess.Popen(["tagserver"])
        time.sleep(0.1)
        x = self.server.poll()
        self.assertIsNone(x)

    def tearDown(self):
        self.server.terminate()
        self.server.wait()

    def test_CDT_Add_Basic(self):
        """Test Adding Basic CDT"""
        c = pydax.Client("cdtadd")
        c.dax_configure()
        c.dax_connect()

        # Using integers as the types
        tlist = [("mem1", pydax.DAX_INT, 1),("mem2", pydax.DAX_BOOL, 10)]
        t = c.add_cdt("type1", tlist)
        # read as the integer type
        result = c.get_cdt(t)
        self.assertEqual(tlist, result)
        # read as the string type
        result = c.get_cdt("type1")
        self.assertEqual(tlist, result)

        # Using strings as teh types
        tlist = [("mem1", "DINT", 10),("mem2", "BOOL", 16)]
        rlist = [("mem1", pydax.DAX_DINT, 10),("mem2", pydax.DAX_BOOL, 16)]
        t = c.add_cdt("type2", tlist)
        result = c.get_cdt(t)
        self.assertEqual(rlist, result)
        result = c.get_cdt("type2")
        self.assertEqual(rlist, result)



    def test_TypeConstants(self):
        """Verify that we have access to the constants"""
        self.assertEqual(pydax.DAX_BOOL, 0x0010)





if __name__ == '__main__':
    unittest.main()
