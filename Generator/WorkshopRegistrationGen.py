from WorkshopRegistration import *
from AbstractGenerator import *


class WorkshopRegistrationGen:
    def __init__(self, rand, part_gen):
        self.rand = rand

        self.part_gen = part_gen
        self.registrations = []

    def to_sql(self):
        res = table_to_sql(self.registrations, False)
        self.registrations = []
        return res

    def make(self, reservations):
        for res in reservations:
            parts = set([p.part_id for p in self.part_gen.participants])
            for _ in range(res.nr_seats):
                p = self.rand.sample(parts, 1)
                self.registrations.append(WorkshopRegistration(res.res_id, p[0]))
                parts.remove(p[0])
