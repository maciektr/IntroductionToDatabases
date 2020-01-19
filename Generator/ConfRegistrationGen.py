from ConfRegistration import *
from AbstractGenerator import *


class ConfRegistrationGen:
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
            if res.active == 0:
                continue
            parts = set([p.part_id for p in self.part_gen.participants])

            for _ in range(res.adult_seats):
                p = self.rand.sample(parts, 1)
                self.registrations.append(ConfRegistration(res.res_id, p[0], 1, self.rand))
                parts.remove(p[0])

            for _ in range(res.student_seats):
                p = self.rand.sample(parts, 1)
                self.registrations.append(ConfRegistration(res.res_id, p[0], 0, self.rand))
                parts.remove(p[0])
