from faker import Faker
from random import Random
from Conference import *


class ConferenceGenerator:
    def __init__(self, rand=Random(), faker=Faker(['pl_PL']), next_conference_id=1):
        self.faker = faker
        self.rand = rand

        self.next_conference_id = next_conference_id
        self.conferences = []

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Conferences ON'
        for v in self.conferences:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Conferences OFF'
        self.conferences = []
        return res

    def make(self, n=1):
        for _ in range(n):
            self.conferences.append(Conference(self.next_conference_id, self.faker))
            self.next_conference_id += 1
