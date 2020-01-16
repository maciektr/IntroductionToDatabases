CREATE FUNCTION getWorkshopsFreeSeatsCount
(
    @workshopId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @used INT
    SET @used = (SELECT SUM(nr_of_seats)
                 FROM Workshop_reservations
                 WHERE workshop_id = @workshopId)
    DECLARE @all INT
    SET @all = (SELECT number_of_seats
                FROM Workshops
                WHERE workshop_id = @workshopId)
    RETURN @all - @used
END
