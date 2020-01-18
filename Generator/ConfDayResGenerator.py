from random import Random
from faker import Faker
from ConfDayReservation import *


class ConfDayResGenerator:
    def __init__(self, clients_gen, rand=Random(), faker=Faker(['pl_PL']), next_res_id=1):
        self.faker = faker
        self.rand = rand

        self.clients_gen = clients_gen
        self.next_res_id = next_res_id
        self.reservations = []

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Conference_day_reservations ON'
        for v in self.reservations:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Conference_day_reservations OFF'
        self.reservations = []
        return res

    def make(self, days):
        for day in days:
            n_res = self.rand.randint(2, self.clients_gen.clients_count()/5)
            while day.free_seats > 0 and n_res > 0:
                n_res -= 1
                self.reservations.append(
                    ConfDayReservation(self.next_res_id, self.clients_gen.choice().cl_id, day, self.faker, self.rand))
                day.free_seats -= self.reservations[-1].adult_seats
                day.free_seats -= self.reservations[-1].student_seats
