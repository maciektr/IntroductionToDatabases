class ConferenceDay:
    def __init__(self, day_id, conf_id, faker, rand, day=None):
        self.faker = faker
        self.rand = rand

        self.day_id = day_id
        self.conf_id = conf_id
        self.price = round(self.rand.uniform(10.0, 1000.0), 2)
        self.stud_disc = round(self.rand.uniform(0.0, 0.5), 2)
        self.date = (self.faker.date_between(start_date='today', end_date='+5y')) if day is None else day
        self.numb_of_seats = self.rand.randint(150, 250)
        self.free_seats = self.numb_of_seats
        self.esds = []

    def to_sql(self, start=True):
        values = "(" + str(self.day_id) + "," + str(self.conf_id) + ",\'" + str(self.date) + "\'," + str(
            self.price) + "," + str(self.stud_disc) + ',' + str(self.numb_of_seats) + ")"
        return "INSERT INTO Conference_days (conference_day_id, conference_id, date, standard_price, student_discount, number_of_seats) VALUES " + values if start else values
