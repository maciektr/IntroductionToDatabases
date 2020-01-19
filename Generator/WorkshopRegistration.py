class WorkshopRegistration:
    def __init__(self, res_id, participant_id):
        self.res_id = res_id
        self.participant_id = participant_id

    def to_sql(self, start=True):
        values = "(" + str(self.res_id) + "," + str(self.participant_id) + ")"
        return "INSERT INTO Workshop_registration (reservation_id, Participant_id) VALUES " + values if start else values
