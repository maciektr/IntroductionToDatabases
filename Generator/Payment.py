from AbstractClass import *


class Payment(AbstractClass):
    def __init__(self, value, day_res, faker, rand):
        self.faker = faker
        self.rand = rand

        self.res_id = day_res.res_id
        self.date = self.random_time(self.faker.date_between(start_date=day_res.date, end_date=day_res.due_price))
        self.value = value

    def to_sql(self):
        return "INSERT INTO Payments (reservation_id, in_date, value) VALUES (" + str(self.res_id) + ",\'" + str(
            self.date) + "\'," + str(self.value) + ")"
