from faker import Faker
import random
from ParticipantsGenerator import *
from Client import *
from Company import *


def table_to_sql(table):
    res = '\n'
    res += table[0].to_sql()
    lid = 0
    for v in range(1, len(table)):
        if v - lid < 999:
            res += ','
            res += table[v].to_sql(False)
        else:
            lid = v
            res += '\n'
            res += table[v].to_sql()
    return res


class ClientsGenerator:
    def __init__(self, participants_gen, next_client_id=1):
        self.faker = Faker(['pl_PL'])
        self.rand = random.Random()

        self.next_client_id = next_client_id
        self.participants_gen = participants_gen
        self.clients = []
        self.companies = []

    def choice(self):
        return self.rand.choice(self.clients)

    def clients_count(self):
        return len(self.clients)

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
        res += table_to_sql(self.clients)

        res += '\nSET IDENTITY_INSERT Clients OFF'
        res += table_to_sql(self.companies)
        res += '\n'
        res += self.participants_gen.to_sql()

        self.clients = []
        self.companies = []
        return res
