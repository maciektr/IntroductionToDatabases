class Esd:
    def __init__(self, faker, rand, day):
        self.faker = faker
        self.rand = rand

        self.day_id = day.day_id
        self.discount = round(self.rand.uniform(0.0, 0.5), 2)
        self.date = self.faker.date_between(start_date='-2y', end_date=day.date)

    def to_sql(self):
        return "INSERT INTO Early_signup_discounts (conference_day_id, end_date, discount) VALUES (" + str(
            self.day_id) + ",\'" + str(self.date) + "\'," + str(self.discount) + ")"
