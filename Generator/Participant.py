class Participant:
    def __init__(self, part_id, faker, client_id=None):
        self.part_id = part_id
        self.client_id = client_id
        self.faker = faker

        n = self.faker.name().split(' ')
        self.name = n[0]
        self.surname = ' '.join(n[1:])
        self.phone = self.faker.phone_number()
        self.email = self.faker.email()

    def to_sql(self):
        if self.client_id is not None:
            res = "INSERT INTO Participants (participant_id,clients_id, name, surname, email, phone) VALUES (" + str(
                self.part_id) + "," + str(self.client_id) + ",\'" + self.name + "\',\'" + self.surname + "\',\'" + self.email + "\',\'" + self.phone + "\')"
        else:
            res = "INSERT INTO Participants (participant_id, name, surname, email, phone) VALUES (" + str(
                self.part_id) + ",\'" + self.name + "\',\'" + self.surname + "\',\'" + self.email + "\',\'" + self.phone + "\')"
        return res

