CREATE FUNCTION participantsForGivenConference(
    @conferenceID int
)
    RETURNS table
        AS
        RETURN SELECT name, surname
               FROM ParticipantsForConferenceDay
               WHERE conference_day_id = @conferenceID