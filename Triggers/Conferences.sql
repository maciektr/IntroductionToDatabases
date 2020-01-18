-- ===================================
-- Triggery dla tabeli Conference_days
-- ===================================
-- sprawdzenie czy na daną konferencje nie zostały dodane dwa te same dni konferencji
CREATE TRIGGER CheckForTwoTheSameConferenceDays
    ON Conference_days
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @Date date = (SELECT date FROM inserted)
    DECLARE @ConferenceId int = (SELECT conference_id FROM inserted)
    IF ((SELECT COUNT(conference_day_id)
         FROM Conference_days
         WHERE (date = @Date)
           AND (conference_id = @ConferenceId)) > 1)
        BEGIN
            DECLARE @message varchar(100) = 'Day ' + CAST(@Date as varchar(11)) +
                                            ' has already been added for this conference';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END
-- ===================================
-- Triggery dla tabeli Conference_day_reservations
-- ===================================
-- przy rzerwacji miejsc na konferencje sprawdza czy jest odpowiednia ilość wolnych miejsc
CREATE TRIGGER CheckIfEnoughSeatsAvailableForConference
    ON Conference_day_reservations
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ConferenceDayID int = (SELECT conference_day_id FROM inserted)
    DECLARE @RequestedSeats int = (SELECT (adult_seats + student_seats) FROM inserted)
    DECLARE @FreeSeats int = (SELECT [dbo].[conferenceFreeSeats](@ConferenceDayID))
    IF (@FreeSeats < @RequestedSeats)
        BEGIN
            DECLARE @Message varchar(100) = 'There are only ' + CAST(@FreeSeats as varchar(10)) +
                                            ' places left for this conference day.';
            THROW 52000,@Message,1 ROLLBACK TRANSACTION
        END
END

-- ===================================
-- Triggery dla tabeli Conference_day_registration
-- ===================================
-- trigger zapewniający aby na daną rezerwację dnia konferencji nie zapisało się więcej osób
-- niż jest zarezerwowanych miejsc
CREATE TRIGGER CheckIfConfReservationNotFull
    ON Conference_day_registration
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @reservationId int = (SELECT reservation_id FROM inserted)
    DECLARE @isStudent bit = (SELECT is_student FROM inserted)
    DECLARE @seatsTaken int = (SELECT COUNT(participant_id) FROM Conference_day_registration
            WHERE reservation_id = @reservationId AND is_student = @isStudent)
    DECLARE @seatsFree int = (SELECT IIF(@isStudent=1, student_seats, adult_seats) FROM Conference_day_reservations
            WHERE reservation_id = @reservationId)
    IF (@seatsTaken > @seatsFree)
        BEGIN
            DECLARE @message varchar(100) = 'nr of participants for this reservation is exceeded, ' +
                                            CAST(@seatsTaken as varchar(3)) +
                                            ' participants are already registered';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END