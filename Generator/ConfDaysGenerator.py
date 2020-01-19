from faker import Faker
from random import Random
from ConferenceDay import *
from datetime import datetime, timedelta, time
from AbstractGenerator import table_to_sql


class ConfDaysGenerator:
    def __init__(self, rand=Random(), faker=Faker(['pl_PL']), next_day_id=1):
        self.faker = faker
        self.rand = rand

        self.next_day_id = next_day_id
        self.days = []

    def make(self, conferences):
        for c in conferences:
            self.days.append(ConferenceDay(self.next_day_id, c.conf_id, self.faker, self.rand))
            self.next_day_id += 1
            date = self.days[-1].date
            n = self.rand.randint(2, 4)
            for _ in range(n):
                date += timedelta(days=1)
                self.days.append(ConferenceDay(self.next_day_id, c.conf_id, self.faker, self.rand, date))
                self.next_day_id += 1

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Conference_days ON'
        res += table_to_sql(self.days)
        res += '\nSET IDENTITY_INSERT Conference_days OFF'
        self.days = []
        return res
