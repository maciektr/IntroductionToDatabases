import random
from faker import Faker


class ParticipantsGenerator:
    def __init__(self, id=0):
        self.start_id = id
        self.faker = Faker(['pl_PL'])
        self.rand = random.Random()

    def get_random_participant_as_sql(self, clients_id=0):
        n = self.faker.name().split(' ')
        name = n[0]
        surname = ' '.join(n[1:])
        phone = self.faker.phone_number()
        email = self.faker.email()
        res = "INSERT INTO Participants (clients_id, name, surname, email, phone) " \
              "VALUES (" + str(
            clients_id) + ",\'" + name + "\',\'" + surname + "\',\'" + email + "\',\'" + phone + "\')"
        return res
