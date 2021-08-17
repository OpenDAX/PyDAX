import pydax
import time

c = pydax.Client("Dummy")
c.dax_configure()
c.dax_connect()

#t = c.add_cdt("dopey", [("mem1", pydax.DAX_INT, 1),("mem2", pydax.DAX_BOOL, 10)])
#t = c.add_cdt("dingy", [("ddd", t, 1), ("mem3", pydax.DAX_BOOL, 16)])
#t = c.dax_tag_add("dummy3", t, 10)
#t = c.dax_tag_add("dummy1", "dopey", 1)
t = c.dax_tag_add("dummy", "uint", 1, 0)
c.write_tag("dummy", 65536, clip=True)
print(c.dummy.value)
# c.dummy.value = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# print(c.dummy.value)
# c.dummy[3].value = 445
# print(c.dummy[3].value)

#x = c.read_tag("dummy[0].mem1")
#print(type(x))
#print(x)
#c.dummy3[0].ddd.mem1.value = 23
#print(c.dummy3[9].ddd.mem1.value)
#for each in c.dummy3:
#    print(each.ddd.mem1.path)
# c.dummy3.value  = 34
# c.dummy[3].value  = 48
