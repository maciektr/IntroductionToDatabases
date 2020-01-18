CREATE FUNCTION participantsForGivenWorkshop(
    @workshopID int
)
    RETURNS table
        AS
        RETURN SELECT name, surname
               FROM ParticipantsForWorkshop
               WHERE workshop_id = @workshopID

CREATE FUNCTION participantsForGivenConference(
    @conferenceID int
)
    RETURNS table
        AS
        RETURN SELECT name, surname
               FROM ParticipantsForConferenceDay
               WHERE conference_day_id = @conferenceID

