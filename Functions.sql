CREATE FUNCTION getPaidAmount(@reservationId int)
RETURNS INT
AS BEGIN
    RETURN (SELECT sum(p.value) FROM Payments p WHERE p.reservation_id=@reservationId GROUP BY p.reservation_id);
END
GO

CREATE FUNCTION calcExpectedPriceForConferenceDay(@reservationId int)
RETURNS INT
AS BEGIN
    DECLARE @nrOfStudents int = (SELECT student_seats FROM Conference_day_reservations WHERE reservation_id = @reservationId)
    DECLARE @nrOfAdults int = (SELECT adult_seats FROM Conference_day_reservations WHERE reservation_id = @reservationId)
    DECLARE @conferenceDayID int = (SELECT conference_day_id FROM Conference_day_reservations WHERE reservation_id = @reservationId)
    DECLARE @standardPrice money = (SELECT standard_price FROM Conference_days WHERE conference_day_id = @conferenceDayID)
    DECLARE @studentDiscount decimal(4,4) = (SELECT student_discount FROM Conference_days WHERE conference_day_id = @conferenceDayID)
    RETURN @nrOfAdults*@standardPrice + @nrOfStudents*(@standardPrice*(1+@studentDiscount)) -- TODO assuming discount passed as negative value
END
GO


CREATE FUNCTION calcPriceForWorkshopReservation(@reservationId int)
RETURNS INT
AS BEGIN
    DECLARE @workshopID int = (SELECT workshop_id FROM Workshop_reservations WHERE reservation_id = @reservationId)
    DECLARE @price money = (SELECT price FROM Workshops WHERE workshop_id = @workshopID)
    RETURN @price*(SELECT nr_of_seats FROM Workshop_reservations WHERE reservation_id = @reservationId)
END
GO

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