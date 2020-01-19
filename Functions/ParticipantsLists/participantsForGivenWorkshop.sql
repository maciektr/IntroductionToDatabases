CREATE FUNCTION participantsForGivenWorkshop(
    @workshopID int
)
    RETURNS table
        AS
        RETURN SELECT name, surname
               FROM ParticipantsForWorkshop
               WHERE workshop_id = @workshopID

