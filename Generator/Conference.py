class Conference:
    def __init__(self, conf_id, faker):
        self.faker = faker

        self.conf_id = conf_id
        self.name = self.faker.bs()
        self.description = self.faker.text()

    def to_sql(self, start=True):
        values = "(" + str(self.conf_id) + ",\'" + self.name + '\',\'' + self.description + "\')"
        return "INSERT INTO Conferences (Conference_id, name, description) VALUES " + values if start else values
