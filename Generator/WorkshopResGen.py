from random import Random
from faker import Faker
from WorkshopRes import *


class WorkshopResGen:
    def __init__(self, conf_day_res_gen, rand=Random(), faker=Faker(['pl_PL']), next_res_id=1):
        self.faker = faker
        self.rand = rand

        self.conf_day_res_gen = conf_day_res_gen
        self.next_res_id = next_res_id
        self.reservations = []

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Workshop_reservations ON'
        for v in self.reservations:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Workshop_reservations OFF'
        self.reservations = []
        return res

    def make(self, workshops):
        for work in workshops:
            n_res = self.rand.randint(1, self.conf_day_res_gen.res_count()//4)
            while work.free_seats > 0 and n_res > 0:
                n_res -= 1
                self.reservations.append(
                    WorkshopRes(self.next_res_id, work, self.conf_day_res_gen.choice().res_id, self.faker, self.rand))
                self.next_res_id += 1
                work.free_seats -= self.reservations[-1].nr_seats
