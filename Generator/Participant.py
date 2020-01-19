class Participant:
    def __init__(self, part_id, faker, client_id=None):
        self.part_id = part_id
        self.client_id = client_id
        self.faker = faker

        n = self.faker.name().split(' ')
        if n[0] == 'pani' or n[0] == 'pan' or n[0] == 'Pan' or n[0] == 'Pani':
            n = n[1:]
        self.name = n[0]
        self.surname = ' '.join(n[1:])
        self.phone = self.faker.phone_number()
        self.email = self.faker.email()

    def to_sql(self, start=True):
        values = "(" + str(self.part_id) + "," + (str(
            self.client_id) if self.client_id is not None else 'null') + ",\'" + self.name + "\',\'" + self.surname + "\',\'" + self.email + "\',\'" + self.phone + "\')"
        return "INSERT INTO Participants (participant_id,clients_id, name, surname, email, phone) VALUES " + values if start else values
