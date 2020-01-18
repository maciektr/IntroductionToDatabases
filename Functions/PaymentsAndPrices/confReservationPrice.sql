CREATE FUNCTION confReservationPrice(@reservation_id int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @dayPrice money = dbo.confDayPrice(@reservation_id)
    DECLARE @workshopsPrice money = (select sum(wr.nr_of_seats * W.price)
                                     from Conference_day_reservations res
                                              inner join Conference_days Cd on res.conference_day_id = Cd.conference_day_id
                                              inner join Workshops W on Cd.conference_day_id = W.conference_day_id
                                              inner join Workshop_reservations wr on W.workshop_id = wr.workshop_id
                                     where res.reservation_id = @reservation_id)
    RETURN @dayPrice + @workshopsPrice
END