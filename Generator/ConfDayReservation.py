from AbstractClass import *


class ConfDayReservation(AbstractClass):
    def __init__(self, res_id, clients_id, day, part_count, faker, rand):
        self.faker = faker
        self.rand = rand

        self.res_id = res_id
        self.day_id = day.day_id
        self.clients_id = clients_id

        self.date = self.random_time(self.faker.date_between(start_date=datetime.today(), end_date=day.date))
        self.active = self.rand.randint(0, 1)
        self.due_price = self.date + timedelta(weeks=self.rand.randint(1, 4))
        self.adult_seats = self.rand.randint(1, min(day.free_seats, part_count))
        self.student_seats = self.rand.randint(0, max(0, min(day.free_seats, part_count) - self.adult_seats))

        self.workshops_price = 0
        self.day_price = day.price * self.adult_seats
        self.day_price += day.price * (1 - day.stud_disc) * self.student_seats
        esds = list(filter(lambda x: x.date > self.date.date(), day.esds))
        esds = sorted(esds, key=lambda x: x.date)
        esd = 0 if len(esds) == 0 else esds[0].discount
        self.day_price *= (1 - esd)

    def to_sql(self, start=True):
        values = "(" + str(
            self.res_id) + "," + str(self.day_id) + "," + str(self.clients_id) + ",\'" + str(self.date) + "\',\'" + str(
            self.active) + "\',\'" + str(self.due_price) + "\'," + str(self.adult_seats) + "," + str(
            self.student_seats) + ")"
        return "INSERT INTO Conference_day_reservations (reservation_id, conference_day_id, clients_id, reservation_date, active, due_price, adult_seats, student_seats) VALUES " + values if start else values
