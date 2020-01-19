from ParticipantsGenerator import *
from ClientsGenerator import *
from ConfDayResGenerator import *
from ConfDaysGenerator import *
from EsdGenerator import *
from ConferenceGenerator import *
from WorkshopGenerator import *
from WorkshopResGen import *
from ConfRegistrationGen import *
from WorkshopRegistrationGen import *
from PaymentGen import *

from random import Random
from faker import Faker

faker = Faker(['pl_PL'])
rand = Random()

generators = []

part_gen = ParticipantsGenerator(rand)
part_gen.make(None, 4000)
# part_gen.make(None, 5)

clients_gen = ClientsGenerator(part_gen)
generators.append(clients_gen)
clients_gen.make(400)
# clients_gen.make(10)

conf_gen = ConferenceGenerator(rand, faker)
generators.append(conf_gen)
conf_gen.make(72)
# conf_gen.make(3)

day_gen = ConfDaysGenerator(rand, faker)
generators.append(day_gen)
day_gen.make(conf_gen.conferences)

esd_gen = EsdGenerator(rand, faker)
generators.append(esd_gen)
esd_gen.make(day_gen.days)

day_res_gen = ConfDayResGenerator(clients_gen, rand, faker)
generators.append(day_res_gen)
day_res_gen.make(day_gen.days)

wor_gen = WorkshopGenerator(part_gen, rand, faker)
generators.append(wor_gen)
wor_gen.make(day_gen.days)

wor_res_gen = WorkshopResGen(day_res_gen)
generators.append(wor_res_gen)
wor_res_gen.make(wor_gen.workshops)

conf_reg_gen = ConfRegistrationGen(rand, part_gen)
generators.append(conf_reg_gen)
conf_reg_gen.make(day_res_gen.reservations)

wor_reg_gen = WorkshopRegistrationGen(rand, part_gen)
generators.append(wor_reg_gen)
wor_reg_gen.make(wor_res_gen.reservations)

pay_gen = PaymentGen(rand, faker)
generators.append(pay_gen)
pay_gen.make(day_res_gen.reservations)

for g in generators:
    print(g.to_sql())
