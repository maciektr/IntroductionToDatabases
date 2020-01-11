import random
import requests
import ParticipantsGenerator


class ClientsGenerator:
    def __init__(self, id=0, api="https://api.namefake.com/polish-poland/random"):
        self.start_id = id
        self.api = api
        self.rand = random.Random()
        self.part_gen = ParticipantsGenerator.ParticipantsGenerator()

    def get_api_resp(self):
        resp = requests.get(self.api)
        if resp.status_code != 200:
            raise BaseException('ApiError: GET /api.namefake.com/ {}'.format(resp.status_code))
        return resp

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
        resp = self.get_api_resp()
        name = resp.json()['company']
        phone = resp.json()['phone_w'].replace(' ','')
        email = resp.json()['email_u'] + '@' + resp.json()['email_d']
        nip = self.random_nip()
        return "INSERT INTO COMPANIES (companyName, nip, phone, clients_id, email)" \
               "VALUES (\'" + name + "\',\'" + nip +"\',\'" + phone + "\',\'" + str(clients_id) + "\',\'" + email + "\')"

    def get_random_client_as_sql(self):
        resp = self.get_api_resp()
        address = resp.json()['address'].split('+,')[0]
        zip_code = resp.json()['address'].split(',')[-1].split(' ')[1]
        city = ' '.join(resp.json()['address'].split(',')[-1].split(' ')[2:])
        self.start_id += 1
        client_sql = "INSERT INTO CLIENTS (id,zip_code, city, address) " \
                     "VALUES (\'" + str(self.start_id) + "\',\'" + zip_code + "\',\'" + city + "\',\'" + address + "\')"

        return client_sql + "\n" + (self.get_random_company_as_sql(self.start_id) if self.rand.randint(0,1) == 0 else self.part_gen.get_random_participant_as_sql(self.start_id))

