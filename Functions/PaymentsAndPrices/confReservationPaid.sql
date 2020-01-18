CREATE FUNCTION confReservationPaidAmount(@reservation_id int)
    RETURNS MONEY
AS
BEGIN
    RETURN (SELECT sum(value) FROM Payments WHERE reservation_id = @reservation_id)
END