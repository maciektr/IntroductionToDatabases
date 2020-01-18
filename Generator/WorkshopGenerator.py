from random import Random
from faker import Faker
from Workshop import *


class WorkshopGenerator:
    def __init__(self, rand=Random(), faker=Faker(['pl_PL']), next_workshop_id=1):
        self.faker = faker
        self.rand = rand

        self.workshops = []
        self.next_workshop_id = next_workshop_id
        self.max_nr_workshops = 6

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Workshops ON'
        for v in self.workshops:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Workshops OFF'
        self.workshops = []
        return res

    def make(self, days):
        for day in days:
            for _ in range(self.rand.randint(2, self.max_nr_workshops)):
                self.workshops.append(Workshop(self.next_workshop_id, day, self.faker, self.rand))
