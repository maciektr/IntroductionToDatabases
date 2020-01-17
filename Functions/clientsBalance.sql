CREATE FUNCTION clientsBalance(@ClientId int)
    RETURNS MONEY
AS
BEGIN
    DECLARE @paid MONEY = (SELECT SUM(P.VALUE)
                           FROM Payments P
                                    inner join Conference_day_reservations Cdr on P.reservation_id = Cdr.reservation_id
                           WHERE Cdr.clients_id = @ClientId)
    DECLARE @owed MONEY = (SELECT SUM(dbo.conferenceReservationPrice(cdr.reservation_id))
                           FROM Conference_day_reservations cdr
                           WHERE cdr.clients_id = @ClientId)
    RETURN @paid - @owed
END
