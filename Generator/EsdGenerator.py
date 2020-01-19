from random import Random
from faker import Faker
from Esd import *
from AbstractGenerator import *


class EsdGenerator:
    def __init__(self, rand=Random(), faker=Faker(['pl_PL'])):
        self.faker = faker
        self.rand = rand

        self.esds = []

    def to_sql(self):
        # res = self.esds[0].to_sql()
        # for v in range(1,len(self.esds)):
        #     res += ','
        #     res += self.esds[v].to_sql(False)
        res = table_to_sql(self.esds, False)
        self.esds = []
        return res

    def make(self, days):
        for day in days:
            for _ in range(self.rand.randint(1, 5)):
                e = Esd(self.faker, self.rand, day)
                self.esds.append(e)
                day.esds.append(e)
