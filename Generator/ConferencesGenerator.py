import random
from faker import Faker
from datetime import datetime, timedelta, time


class ConferencesGenerator:
    def __init__(self, cl, conf_id=0, day_id=0, workshop_id=0, res_id=0):
        self.start_conf_id = conf_id
        self.start_day_id = day_id
        self.start_workshop_id = workshop_id
        self.clients_generator = cl
        self.start_res_id = res_id

        self.rand = random.Random()
        self.faker = Faker(['pl_PL'])
        self.first_id = self.start_conf_id + 1
        self.discounts = []
        self.stud_discount = 0
        self.price = 0

    def get_confs_ids(self):
        return [i for i in range(self.first_id, self.start_conf_id + 1)]

    def get_random_conf_day(self, conf_id=0, day=None):
        date = str(self.faker.date_between(start_date='today', end_date='+5y') if day is None else day)
        price = round(self.rand.uniform(10.0, 1000.0), 2)
        self.price = price
        stud_disc = round(self.rand.uniform(0.0, 0.5), 2)
        self.stud_discount = stud_disc
        self.start_day_id += 1
        res = "INSERT INTO Conference_days (conference_day_id, conference_id, date, standard_price, student_discount) VALUES (" + str(
            self.start_day_id) + "," + str(conf_id) + ",\'" + date + "\'," + str(price) + "," + str(stud_disc) + ")"
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

        res = "INSERT INTO Workshops (workshop_id, conference_day_id, start_time, end_time, topic, price, number_of_seats) VALUES (" + str(
            self.start_workshop_id) + "," + str(day_id) + ",\'" + str(start) + "\',\'" + str(
            end) + "\',\'" + topic + "\',\'" + price + "\',\'" + str(numb_seats) + "\')"


        return res

    def get_random_discounts(self, conf_id, conf_date):
        numb_of_discounts = self.rand.randint(1, 6)
        self.discounts = []
        res = ''
        for _ in range(numb_of_discounts):
            res += '\n'
            end = self.faker.date_between(start_date='-2y', end_date=conf_date)
            discount = round(self.rand.uniform(0.0, 0.5), 2)
            self.discounts.append(tuple([end, discount]))
            res += "INSERT INTO Early_signup_discounts (conference_day_id, end_date, discount) VALUES (" + str(
                conf_id) + ",\'" + str(end) + "\',\'" + str(discount) + "\')"
        return res

    def reservation_price(self, adult_seats, student_seats, res_date):
        self.discounts = sorted(self.discounts, key=lambda x: x[0])
        i = 0
        while i < len(self.discounts) and self.discounts[i][0] < res_date:
            i += 1
        price = self.price
        price += adult_seats * (1 - self.discounts[i - 1][1])
        price += student_seats * (1 - self.discounts[i - 1][1]) * (1 - self.stud_discount)
        return price

    def get_random_payments(self, price, res_id, date_start, date_end):
        numb_payments = self.rand.randint(1, 5)
        if numb_payments == 1:
            in_date = self.faker.date_between(start_date=date_start, end_date=date_end)
            return "\nINSERT INTO Payments (reservation_id, in_date, value) VALUES (" + str(res_id) + ",\'" + str(
                in_date) + "\'," + str(price) + ")"

        values = [price // numb_payments for _ in range(numb_payments)]
        i = 0
        while sum(values) < int(price):
            values[i % len(values)] += 1
            i += 1
        values[0] += (price - int(price))

        for i in range(len(values)):
            k = self.rand.randint(1, price // 5)
            values[i] += k
            values[(i + 1) % len(values)] -= k
        res = ''
        for v in values:
            in_date = self.faker.date_between(start_date=date_start, end_date=date_end)
            res += '\n'
            res += "INSERT INTO Payments (reservation_id, in_date, value) VALUES (" + str(res_id) + ",\'" + str(
                in_date) + "\'," + str(round(v, 2)) + ")"
        return res

    def get_random_registrations(self, res_id, adults, studs):
        res = ''
        participants = set(self.clients_generator.get_participants_generator().get_participants_ids())
        for _ in range(adults):
            part = self.rand.sample(participants,1)[0]
            participants.remove(part)
            res += "\nINSERT INTO Conference_day_registration (reservation_id, Participant_id, is_student) VALUES (" + str(
                res_id) + "," + str(part) + ",0)"
        for _ in range(studs):
            part = self.rand.sample(participants,1)[0]
            participants.remove(part)
            res += "\nINSERT INTO Conference_day_registration (reservation_id, Participant_id, is_student) VALUES (" + str(
                res_id) + "," + str(part) + ",1)"
        return res

    def get_random_conf_reservation(self, day_id, day):
        self.start_res_id += 1
        cl_id = self.rand.choice(self.clients_generator.get_clients_ids())
        res_date = self.faker.date_between(start_date=datetime.today(), end_date=day)
        active = self.rand.randint(0, 1)
        due_price = self.faker.date_between(start_date=res_date, end_date=day)
        adult_seats = self.rand.randint(0,len(self.clients_generator.get_participants_generator().get_participants_ids()))
        student_seats = self.rand.randint(0, len(self.clients_generator.get_participants_generator().get_participants_ids()) - adult_seats)

        res = "INSERT INTO Conference_day_reservations (reservation_id, conference_day_id, clients_id, reservation_date, active, due_price, adult_seats, student_seats) VALUES (" + str(
            self.start_res_id) + "," + str(day_id) + "," + str(cl_id) + ",\'" + str(res_date) + "\',\'" + str(
            active) + "\',\'" + str(due_price) + "\',\'" + str(adult_seats) + "\',\'" + str(student_seats) + "\')"

        price = self.reservation_price(adult_seats, student_seats, res_date)
        res += self.get_random_payments(price, self.start_res_id, res_date, due_price)
        res += self.get_random_registrations(self.start_res_id, adult_seats, student_seats)

        return res

    def get_random_conference_as_sql(self):
        name = self.faker.bs()
        self.start_conf_id += 1
        res = 'SET IDENTITY_INSERT  Conferences ON\n'
        res += "INSERT INTO Conferences (Conference_id, name) VALUES (" + str(
            self.start_conf_id) + ",\'" + name + "\')"
        day = self.faker.date_between(start_date='today', end_date='+5y')

        # Gen conference days
        numb_of_days = self.rand.randint(1, 6)
        res += '\nSET IDENTITY_INSERT  Conferences OFF'
        for _ in range(numb_of_days):
            res += '\nSET IDENTITY_INSERT Conference_days ON\n'
            day += timedelta(days=1)
            res += self.get_random_conf_day(self.start_conf_id, day)
            # Gen discounts
            res += self.get_random_discounts(self.start_day_id, day)
            res += '\nSET IDENTITY_INSERT Conference_days OFF'

            # Gen workshops
            numb_of_workshops = self.rand.randint(1, 6)
            res += '\nSET IDENTITY_INSERT  Workshops ON'
            for _ in range(numb_of_workshops):
                res += '\n'
                res += self.get_random_workshop(self.start_day_id, day)
            res += '\nSET IDENTITY_INSERT  Workshops OFF'

            numb_of_conf_res = self.rand.randint(1, len(self.clients_generator.get_clients_ids()))
            res += '\nSET IDENTITY_INSERT  Conference_day_reservations ON'
            for _ in range(numb_of_conf_res):
                res += '\n'
                res += self.get_random_conf_reservation(self.start_day_id, day)
            res += '\nSET IDENTITY_INSERT  Conference_day_reservations OFF'
        return res
