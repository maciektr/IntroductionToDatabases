CREATE FUNCTION workshopFreeSeats(@workshopId int)
    RETURNS INT
AS
BEGIN
    DECLARE @used INT
    SET @used = ISNULL((SELECT SUM(nr_of_seats)
                        FROM Workshop_reservations
                        WHERE workshop_id = @workshopId), 0)
    DECLARE @all INT
    SET @all = (SELECT number_of_seats
                FROM Workshops
                WHERE workshop_id = @workshopId)
    RETURN @all - @used
END
GO