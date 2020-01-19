class WorkshopRegistration:
    def __init__(self, res_id, participant_id):
        self.res_id = res_id
        self.participant_id = participant_id

    def to_sql(self):
        return "INSERT INTO Workshop_registration (reservation_id, Participant_id) VALUES (" + str(
            self.res_id) + "," + str(self.participant_id) + ")"
