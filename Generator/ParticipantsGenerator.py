from faker import Faker
from Participant import *


class ParticipantsGenerator:
    def __init__(self, rand, faker=Faker(['pl_PL']), next_participant_id=1):
        self.faker = faker
        self.rand = rand

        self.next_participant_id = next_participant_id
        self.participants = []

    def choice(self):
        return self.rand.choice(self.participants)

    def part_count(self):
        return len(self.participants)

    def make(self, clients_id=None, n=1):
        for _ in range(n):
            res = Participant(self.next_participant_id, self.faker, clients_id)
            self.next_participant_id += 1
            self.participants.append(res)

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Participants ON'
        for v in self.participants:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Participants OFF'
        self.participants = []
        return res
