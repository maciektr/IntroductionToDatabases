
/*CREATE FUNCTION getPaidAmount(@reservationId int)
    RETURNS INT
AS
BEGIN
    RETURN (SELECT sum(p.value) FROM Payments p WHERE p.reservation_id = @reservationId GROUP BY p.reservation_id);
END
GO

CREATE FUNCTION calcPriceForWorkshopReservation(@reservationId int)
    RETURNS INT
AS
BEGIN
    DECLARE @workshopID int = (SELECT workshop_id FROM Workshop_reservations WHERE reservation_id = @reservationId)
    DECLARE @price money = (SELECT price FROM Workshops WHERE workshop_id = @workshopID)
    RETURN @price * (SELECT nr_of_seats FROM Workshop_reservations WHERE reservation_id = @reservationId)
END
GO
 */