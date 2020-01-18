class Client:
    def __init__(self, cl_id, faker):
        self.cl_id = cl_id
        self.faker = faker

        add = self.faker.address().split('\n')
        self.address = add[0]
        self.zip_code = add[-1].split(' ')[0]
        self.city = ' '.join(add[-1].split(' ')[1:])

    def to_sql(self):
        return "INSERT INTO CLIENTS (id,zip_code, city, address) " \
               "VALUES (" + str(self.cl_id) + ",\'" + self.zip_code + "\',\'" + self.city + "\',\'" + self.address + "\')"
