from Payment import *
from AbstractGenerator import *


class PaymentGen:
    def __init__(self, rand, faker):
        self.rand = rand
        self.faker = faker
        self.payments = []

    def make(self, reservations):
        for res in reservations:
            price = res.workshops_price + res.day_price
            payed = int(price)
            if self.rand.randint(1, 1000) % 30 == 0:  # nie oplacone
                payed = 0 if self.rand.randint(0, 1000) % 2 == 0 else self.rand.randint(0, int(price))
            if payed == 0:
                continue
            n_payments = self.rand.randint(1, 4)
            values = [payed // n_payments for _ in range(n_payments)]
            i = 0
            while sum(values) < payed:
                values[i % n_payments] += 1
                i += 1
            i = 0
            while i < n_payments:
                p = self.rand.randint(0, values[i])
                values[i] -= p
                values[(i + 1) % n_payments] += p
                i += 1
            values[-1] += round(price - int(price), 2)
            for value in values:
                self.payments.append(Payment(value, res, self.faker, self.rand))

    def to_sql(self):
        res = table_to_sql(self.payments, False)
        self.payments = []
        return res
