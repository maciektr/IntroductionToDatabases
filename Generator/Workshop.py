from datetime import datetime, timedelta, time


class Workshop:
    def __init__(self, workshop_id, day, part_count, faker, rand):
        self.faker = faker
        self.rand = rand

        self.workshop_id = workshop_id
        self.day_id = day.day_id
        self.price = round(self.rand.uniform(10.0, 1000.0), 2)
        self.start = self.random_time(day.date)
        self.end = self.random_time(day.date)
        # while self.start == self.end:
        #     self.end = datetime.combine(day, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))
        if self.start > self.end:
            self.start, self.end = self.end, self.start
        self.topic = self.faker.bs()
        self.numb_seats = self.rand.randint(1, min(day.numb_of_seats, part_count))
        self.free_seats = self.numb_seats

    def random_time(self, date):
        return datetime.combine(date, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))

    def to_sql(self):
        return "INSERT INTO Workshops (workshop_id, conference_day_id, start_time, end_time, topic, price, number_of_seats) VALUES (" + str(
            self.workshop_id) + "," + str(self.day_id) + ",\'" + str(self.start) + "\',\'" + str(
            self.end) + "\',\'" + self.topic + "\'," + str(self.price) + "," + str(self.numb_seats) + ")"
