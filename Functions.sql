CREATE FUNCTION calcExpectedPriceForConferenceDay(@reservationId int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @earlySignupDiscount decimal(4,4) = (Select TOP 1 esd.discount from Conference_day_reservations as res
                                                inner join Conference_days as day on res.conference_day_id = day.conference_day_id
                                                inner join Early_signup_discounts esd on day.conference_day_id = esd.conference_day_id
                                                    where reservation_id = 3
                                                      and esd.end_date > res.reservation_date
                                                    order by esd.end_date ASC)
    DECLARE @nrOfStudents int = (SELECT student_seats
                                 FROM Conference_day_reservations
                                 WHERE reservation_id = @reservationId)
    DECLARE @nrOfAdults int = (SELECT adult_seats
                               FROM Conference_day_reservations
                               WHERE reservation_id = @reservationId)
    DECLARE @conferenceDayID int = (SELECT conference_day_id
                                    FROM Conference_day_reservations
                                    WHERE reservation_id = @reservationId)
    DECLARE @standardPrice money = (SELECT standard_price
                                    FROM Conference_days
                                    WHERE conference_day_id = @conferenceDayID)
    DECLARE @studentDiscount decimal(4, 4) = (SELECT student_discount
                                              FROM Conference_days
                                              WHERE conference_day_id = @conferenceDayID)
    DECLARE @priceBeforeDiscount money = (@nrOfAdults * @standardPrice + @nrOfStudents * (@standardPrice * (1.0 - @studentDiscount)))

    IF @earlySignupDiscount is not null BEGIN
        RETURN CONVERT(money, @priceBeforeDiscount * (1.0 - @earlySignupDiscount))
    END
    RETURN @priceBeforeDiscount
END
GO

CREATE FUNCTION conferenceReservationPrice(@reservation_id int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @dayPrice money = dbo.calcExpectedPriceForConferenceDay(@reservation_id)
    DECLARE @workshopsPrice money = (select sum(wr.nr_of_seats * W.price) from Conference_day_reservations res
                                        inner join Conference_days Cd on res.conference_day_id = Cd.conference_day_id
                                        inner join Workshops W on Cd.conference_day_id = W.conference_day_id
                                        inner join Workshop_reservations wr on W.workshop_id = wr.workshop_id
                                        where res.reservation_id = @reservation_id)
    RETURN @dayPrice + @workshopsPrice
END

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