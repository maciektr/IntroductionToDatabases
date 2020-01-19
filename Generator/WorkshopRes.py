from AbstractClass import *


class WorkshopRes(AbstractClass):
    def __init__(self, res_id, workshop, conf_res_id, faker, rand):
        self.faker = faker
        self.rand = rand

        self.res_id = res_id
        self.work_id = workshop.workshop_id
        self.date = self.random_time(
            self.faker.date_between(start_date=datetime.today(), end_date=workshop.start.date()))
        self.due_price = self.date + timedelta(weeks=self.rand.randint(1, 4))
        self.nr_seats = self.rand.randint(1, workshop.free_seats)
        self.conf_res_id = conf_res_id
        self.active = self.rand.randint(0, 1)

    def to_sql(self):
        return "INSERT INTO Workshop_reservations (reservation_id, workshop_id, reservation_date, due_price, nr_of_seats, Conference_day_res_id, active) VALUES (" + str(
            self.res_id) + "," + str(self.work_id) + ",\'" + str(self.date) + "\',\'" + str(self.due_price) + "\'," + str(
            self.nr_seats) + ',' + str(self.conf_res_id) + ',' + str(self.active) + ")"