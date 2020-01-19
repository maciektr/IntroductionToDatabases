class ConfRegistration:
    def __init__(self, res_id, participant_id, student, rand):
        self.rand = rand

        self.res_id = res_id
        self.student = student
        self.participant_id = participant_id

    def to_sql(self, start=True):
        values = "(" + str(self.res_id) + "," + str(self.participant_id) + "," + str(self.student) + ")"
        return "INSERT INTO Conference_day_registration (reservation_id, Participant_id, is_student) VALUES " + values if start else values
