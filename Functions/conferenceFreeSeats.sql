CREATE FUNCTION conferenceFreeSeats(@conferenceId int)
    RETURNS INT
AS
BEGIN
    DECLARE @used INT
    SET @used = (SELECT SUM(adult_seats+student_seats)
                 FROM Conference_day_reservations
                 WHERE conference_day_id = @conferenceId)
    DECLARE @all INT
    SET @all = (SELECT number_of_seats
                FROM Conference_days
                WHERE conference_day_id= @conferenceId)
    RETURN @all - @used
END
go