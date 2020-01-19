from random import Random
from faker import Faker
from Workshop import *
from AbstractGenerator import table_to_sql


class WorkshopGenerator:
    def __init__(self, part_gen, rand=Random(), faker=Faker(['pl_PL']), next_workshop_id=1):
        self.faker = faker
        self.rand = rand

        self.part_gen = part_gen
        self.workshops = []
        self.next_workshop_id = next_workshop_id

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Workshops ON'
        res += table_to_sql(self.workshops)
        res += '\nSET IDENTITY_INSERT Workshops OFF'
        self.workshops = []
        return res

    def make(self, days):
        for day in days:
            for _ in range(self.rand.randint(2, 6)):
                self.workshops.append(
                    Workshop(self.next_workshop_id, day, self.part_gen.part_count(), self.faker, self.rand))
                self.next_workshop_id += 1
