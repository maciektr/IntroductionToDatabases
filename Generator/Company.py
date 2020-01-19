class Company:
    def __init__(self, clients_id,faker, rand):
        self.faker = faker
        self.rand = rand
        self.clients_id = clients_id

        self.name = self.faker.company()
        self.phone = self.faker.phone_number()
        self.email = self.faker.email()
        self.nip = self.random_nip()

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

    def to_sql(self, start=True):
        values = "(\'" + self.name + "\',\'" + self.nip + "\',\'" + self.phone + "\'," + str(
            self.clients_id) + ",\'" + self.email + "\')"
        return "INSERT INTO COMPANIES (companyName, nip, phone, clients_id, email) VALUES "+values if start else values
