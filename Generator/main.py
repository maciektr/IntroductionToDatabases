from ParticipantsGenerator import *
from ClientsGenerator import *

part_gen = ParticipantsGenerator()
part_gen.make(None, 5)
print(part_gen.to_sql())

clients_gen = ClientsGenerator(part_gen)
clients_gen.make(10)

print(clients_gen.to_sql())