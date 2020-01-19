from random import Random
from faker import Faker
from Esd import *


class EsdGenerator:
    def __init__(self, rand=Random(), faker=Faker(['pl_PL'])):
        self.faker = faker
        self.rand = rand

        self.esds = []

    def to_sql(self):
        res = ''
        for v in self.esds:
            res += v.to_sql()
            res += '\n'
        res = res[:-1]
        self.esds = []
        return res

    def make(self, days):
        for day in days:
            for _ in range(self.rand.randint(1, 5)):
                e = Esd(self.faker, self.rand, day)
                self.esds.append(e)
                day.esds.append(e)
