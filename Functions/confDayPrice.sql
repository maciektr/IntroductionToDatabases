CREATE FUNCTION confDayPrice(@reservationId int)
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
