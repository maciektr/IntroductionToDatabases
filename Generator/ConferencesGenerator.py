import random
from faker import Faker
from datetime import datetime, timedelta, time


class ConferencesGenerator:
    def __init__(self, conf_id=0, day_id=0, workshop_id=0):
        self.start_conf_id = conf_id
        self.start_day_id = day_id
        self.start_workshop_id = workshop_id

        self.rand = random.Random()
        self.faker = Faker(['pl_PL'])

    def get_random_conf_day(self, conf_id=0, day=None):
        date = str(self.faker.date_between(start_date='today', end_date='+5y') if day is None else day)
        price = str(round(self.rand.uniform(10.0, 1000.0), 2))
        stud_disc = str(round(self.rand.uniform(0.0, 1.0), 2))
        self.start_day_id += 1
        res = "INSERT INTO Conference_days (conference_day_id, conference_id, date, standard_price, student_discount) VALUES (\'" + str(
            self.start_day_id) + "\',\'" + str(conf_id) + "\',\'" + date + "\',\'" + price + "\',\'" + stud_disc + "\')"
        return res

    def random_time(self, date):
        return datetime.combine(date, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))

    def get_random_workshop(self, day_id, day):
        self.start_workshop_id += 1
        topic = self.faker.bs()
        price = str(round(self.rand.uniform(10.0, 1000.0), 2))
        numb_seats = self.rand.randint(10, 100)
        start = self.random_time(day)
        end = self.random_time(day)
        while start == end:
            end = datetime.combine(day, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))
        if start > end:
            start, end = end, start

        res = "INSERT INTO Workshops (workshop_id, conference_day_id, start_time, end_time, topic, price, number_of_seats) VALUES (\'" + str(
            self.start_workshop_id) + "\',\'" + str(day_id) + "\',\'" + str(start) + "\',\'" + str(
            end) + "\',\'" + topic + "\',\'" + price + "\',\'" + str(numb_seats) + "\')"
        return res

    def get_random_discounts(self, conf_id, conf_date):
        end = self.faker.date_between(start_date='-2y', end_date=conf_date)
        discount = round(self.rand.uniform(0.0, 1.0), 2)
        res = "INSERT INTO Early_signup_discounts (conference_day_id, end_date, discount) VALUES (\'" + str(
            conf_id) + "\',\'" + str(end) + "\',\'" + str(discount) + "\')"
        return res

    def get_random_conference_as_sql(self):
        name = self.faker.bs()
        self.start_conf_id += 1
        res = "INSERT INTO Conferences (Conference_id, name) VALUES (\'" + str(
            self.start_conf_id) + "\',\'" + name + "\')"
        day = self.faker.date_between(start_date='today', end_date='+5y')

        numb_of_discounts = self.rand.randint(1,6)
        for _ in range(numb_of_discounts):
            res += '\n'
            res += self.get_random_discounts(self.start_conf_id, day)

        # Gen conference days
        numb_of_days = self.rand.randint(1, 6)
        for _ in range(numb_of_days):
            res += '\n'
            day += timedelta(days=1)
            res += self.get_random_conf_day(self.start_conf_id, day)

            # Gen workshops
            numb_of_workshops = self.rand.randint(1, 6)
            for _ in range(numb_of_workshops):
                res += '\n'
                res += self.get_random_workshop(self.start_day_id, day)

        return res
