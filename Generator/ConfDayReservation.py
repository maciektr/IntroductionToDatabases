from datetime import datetime, timedelta, time


class ConfDayReservation:
    def __init__(self, res_id, clients_id, day, faker, rand):
        self.faker = faker
        self.rand = rand

        self.res_id = res_id
        self.day_id = day.day_id
        self.clients_id = clients_id

        self.date = self.random_time(day.date)
        self.active = True if self.rand.randint(0, 1) == 1 else False
        self.due_price = day.date + timedelta(weeks=self.rand.randint(1, 4))
        self.adult_seats = self.rand.randint(1, day.free_seats)
        self.student_seats = self.rand.randint(0, max(0, day.free_seats - self.adult_seats))

    def random_time(self, date):
        return datetime.combine(date, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))

    def to_sql(self):
        return "INSERT INTO Conference_day_reservations (reservation_id, conference_day_id, clients_id, reservation_date, active, due_price, adult_seats, student_seats) VALUES (" + str(
            self.res_id) + "," + str(self.day_id) + "," + str(self.clients_id) + ",\'" + str(self.date) + "\',\'" + str(
            self.active) + "\',\'" + str(self.due_price) + "\'," + str(self.adult_seats) + "," + str(
            self.student_seats) + ")"
