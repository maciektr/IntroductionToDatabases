CREATE FUNCTION confReservationPrice(@reservation_id int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @dayPrice money = dbo.confDayPrice(@reservation_id);
    DECLARE @workshopsPrice money = (select sum(wr.nr_of_seats * W.price)
                                     from Workshop_reservations wr
                                              inner join Workshops W on wr.workshop_id = W.workshop_id
                                     where wr.Conference_day_res_id = @reservation_id);

    RETURN ROUND(@dayPrice + ISNULL(@workshopsPrice, 0), 2)
END