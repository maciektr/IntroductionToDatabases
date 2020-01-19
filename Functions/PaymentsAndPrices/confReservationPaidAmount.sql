CREATE FUNCTION confReservationPaidAmount(@reservation_id int)
    RETURNS MONEY
AS
BEGIN
    RETURN ISNULL((SELECT sum(value) FROM Payments WHERE reservation_id = @reservation_id), 0)
END