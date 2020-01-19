CREATE FUNCTION clientsBalance(@ClientId int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @paid MONEY = (SELECT SUM(P.VALUE)
                           FROM Payments P
                                    inner join Conference_day_reservations Cdr on P.reservation_id = Cdr.reservation_id
                           WHERE Cdr.clients_id = @ClientId and cdr.active = 1)
    DECLARE @owed MONEY = (SELECT SUM(dbo.confReservationPrice(cdr.reservation_id))
                           FROM Conference_day_reservations cdr
                           WHERE cdr.clients_id = @ClientId and cdr.active = 1)
    DECLARE @res MONEY = ROUND(ISNULL(@paid, 0) - ISNULL(@owed, 0), 2);
    IF @res = 0.01
        BEGIN
            return 0
        END
    RETURN @res
END
