import random
from faker import Faker


class ParticipantsGenerator:
    def __init__(self, id=0):
        self.start_id = id
        self.faker = Faker(['pl_PL'])
        self.rand = random.Random()
        self.first_id = self.start_id + 1

    def get_participants_ids(self):
        return [i for i in range(self.first_id, self.start_id + 1)]

    def get_random_participant_as_sql(self, clients_id=0):
        self.start_id+=1
        n = self.faker.name().split(' ')
        name = n[0]
        surname = ' '.join(n[1:])
        phone = self.faker.phone_number()
        email = self.faker.email()
        res = "INSERT INTO Participants (participant_id,clients_id, name, surname, email, phone) " \
              "VALUES ("+str(self.start_id)+","+ str(
            clients_id) + ",\'" + name + "\',\'" + surname + "\',\'" + email + "\',\'" + phone + "\')"
        return res
