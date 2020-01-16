create function getPaidAmount(@reservationId int)
returns int
as begin
    return (select sum(p.value) from Payments p where p.reservation_id=@reservationId group by p.reservation_id);
end
go

CREATE FUNCTION getWorkshopsFreeSeatsCount(@workshopId int)
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
go