import random
import requests


class ParticipantsGenerator:
    def __init__(self, id=0, api="https://api.namefake.com/polish-poland/random"):
        self.start_id = id
        self.api = api
        self.rand = random.Random()

    def get_api_resp(self):
        resp = requests.get(self.api)
        if resp.status_code != 200:
            raise BaseException('ApiError: GET /api.namefake.com/ {}'.format(resp.status_code))
        return resp

    def get_random_participant_as_sql(self, clients_id=0):
        resp = self.get_api_resp()
        name = resp.json()['name'].split(' ')[0]
        surname = ' '.join(resp.json()['name'].split(' ')[1:])
        email = resp.json()['email_u'] + '@' + resp.json()['email_d']
        phone = resp.json()['phone_w'].replace(' ', '')
        res = "INSERT INTO Participants (clients_id, name, surname, email, phone) " \
              "VALUES (\'" + str(clients_id)+ "\',\'" + name + "\',\'" + surname + "\',\'" + email + "\',\'" + phone + "\')"
        return res
