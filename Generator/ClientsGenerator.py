from faker import Faker
import random
from ParticipantsGenerator import *
from Client import *
from Company import *


class ClientsGenerator:
    def __init__(self, participants_gen, next_client_id=1):
        self.faker = Faker(['pl_PL'])
        self.rand = random.Random()

        self.next_client_id = next_client_id
        self.participants_gen = participants_gen
        self.clients = []
        self.companies = []

    def make(self, n=1):
        for _ in range(n):
            cl = Client(self.next_client_id, self.faker)
            if self.rand.randint(0, 1) == 0:
                cm = Company(self.next_client_id, self.faker, self.rand)
                self.companies.append(cm)
            else:
                self.participants_gen.make(self.next_client_id)
            self.next_client_id += 1
            self.clients.append(cl)

    def to_sql(self):
        res = 'SET IDENTITY_INSERT Clients ON'
        for v in self.clients:
            res += '\n'
            res += v.to_sql()
        res += '\nSET IDENTITY_INSERT Clients OFF'
        for v in self.companies:
            res += '\n'
            res += v.to_sql()
        res += '\n'
        res += self.participants_gen.to_sql()

        self.clients = []
        self.companies = []
        return res
