-- procedura pozwalająca zmniejszyć ilość zarezerwowanych miejsc na warsztaty, pod warunkiem że na daną rezerwację
-- nie zarejestrowało się już więcej osób
CREATE PROCEDURE DecreaseNumberOfBookedPlacesForWorkshop @reservation_id int, @new_nr_of_seats int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @already_registered_participants int = (SELECT COUNT(*)
                                                    FROM Workshop_registration
                                                    WHERE reservation_id = @reservation_id)
    IF @new_nr_of_seats < (SELECT nr_of_seats FROM Workshop_reservations WHERE reservation_id = @reservation_id)
        BEGIN
            IF (@already_registered_participants <= @new_nr_of_seats)
                BEGIN
                    UPDATE Workshop_reservations
                    SET nr_of_seats = @new_nr_of_seats
                    WHERE reservation_id = @reservation_id
                    PRINT 'success'
                END
            ELSE
                BEGIN
                    PRINT 'cannot decrease number of booked places, as ' +
                          CAST(@already_registered_participants AS varchar(4)) +
                          ' participants already registered for the workshop on this reservation'
                END
        END
END
GO

-- procedura dezaktywująca rezerwację warsztatu
CREATE PROCEDURE DeactivateWorkshopReservation @reservation_id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @currentlyActive bit = (SELECT active FROM Workshop_reservations WHERE reservation_id = @reservation_id)
    IF @currentlyActive = 1
        BEGIN
            UPDATE Workshop_reservations
            SET active = 0
            WHERE reservation_id = @reservation_id
        END
END
GO

-- procedura dezaktywująca rezerwację konferencji
CREATE PROCEDURE DeactivateConferenceReservation @reservation_id int
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @currentlyActive bit = (SELECT active FROM Conference_day_reservations WHERE reservation_id = @reservation_id)
    IF @currentlyActive = 1
        BEGIN
            UPDATE Conference_day_reservations
            SET active = 0
            WHERE reservation_id = @reservation_id
        END
END
GO

