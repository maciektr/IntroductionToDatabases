from datetime import datetime, timedelta, time


class AbstractClass:
    def random_time(self, date):
        return datetime.combine(date, time(self.rand.randint(0, 23), self.rand.randint(0, 59)))
