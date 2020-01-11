import random
import ParticipantsGenerator
from faker import Faker


class ClientsGenerator:
    def __init__(self, id=0):
        self.start_id = id
        self.faker = Faker(['pl_PL'])
        self.rand = random.Random()
        self.part_gen = ParticipantsGenerator.ParticipantsGenerator()
        self.first_id = self.start_id + 1

    def get_clients_ids(self):
        return [i for i in range(self.first_id, self.start_id + 1)]

    def random_nip(self):
        res = ''
        sum = 0
        weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]
        for i in range(8):
            k = self.rand.randint(1 if i < 3 else 0, 9)
            sum += weights[i] * k
            res += str(k)
        k = self.rand.randint(0, 9)
        if (sum + (k * weights[8])) % 11 == 10:
            k += (1 if k + 1 < 10 else -1)
        res += str(k)
        sum += k * weights[8]
        res += str(sum % 11)
        return res

    def get_random_company_as_sql(self, clients_id=0):

        name = self.faker.company()
        phone = self.faker.phone_number()
        email = self.faker.email()
        nip = self.random_nip()
        return "INSERT INTO COMPANIES (companyName, nip, phone, clients_id, email) VALUES (\'" + name + "\',\'" + nip + "\',\'" + phone + "\'," + str(
            clients_id) + ",\'" + email + "\')"

    def get_random_client_as_sql(self):
        add = self.faker.address().split('\n')
        address = add[0]
        zip_code = add[-1].split(' ')[0]
        city = ' '.join(add[-1].split(' ')[1:])
        self.start_id += 1

        client_sql = "INSERT INTO CLIENTS (id,zip_code, city, address) " \
                     "VALUES (" + str(self.start_id) + ",\'" + zip_code + "\',\'" + city + "\',\'" + address + "\')"

        # res = 'SET IDENTITY_INSERT Clients ON\n'
        res = client_sql + "\n" + (self.get_random_company_as_sql(self.start_id) if self.rand.randint(0,1) == 0 else self.part_gen.get_random_participant_as_sql(self.start_id))
        # res += '\nSET IDENTITY_INSERT Clients OFF'
        return res
