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

-- sprawdzenie czy uczestnik zapisujący się na warsztaty jest już zapisany na odpowiedni dzień konferencji
CREATE TRIGGER CheckIfRegisteredForTheDay
    ON Workshop_registration
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ReservationId int = (SELECT reservation_id FROM inserted)
    DECLARE @ParticipantID int = (SELECT participant_id FROM inserted)
    DECLARE @ConferenceDayID int = (SELECT conference_day_id
                                    FROM Workshops
                                             INNER JOIN Workshop_reservations
                                                        on Workshops.workshop_id = Workshop_reservations.workshop_id
                                    WHERE Workshop_reservations.reservation_id = @ReservationId)
    IF (@ParticipantID not in (SELECT participant_id
                               FROM Conference_day_registration Cdr
                                        INNER JOIN Conference_day_reservations C on Cdr.reservation_id = C.reservation_id
                               WHERE C.conference_day_id = @ConferenceDayID))
        BEGIN
            DECLARE @message varchar(100) = 'Participant nr ' + CAST(@ParticipantID as varchar(3)) +
                                            ' is not registered for the corresponding conference day';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END


-- przy rzerwacji miejsc na warsztaty sprawdza czy jest odpowiednia ilość wolnych miejsc
-- CREATE TRIGGER ForbidToBookPlacesForFullConferenceDay
--     ON Workshop_reservations
--     AFTER INSERT, UPDATE AS
-- BEGIN
--     DECLARE @WorkshopID int = (SELECT workshop_id FROM inserted)
--     IF (dbo.GetNumberOfFreePlacesForConferenceDay(@ConferenceDayId) < 0)
--         BEGIN
--             DECLARE @FreePlaces int = dbo.GetNumberOfFreePlacesForConferenceDay(@ConferenceDayId) +
--                                       (SELECT places_reserved FROM inserted)
--             DECLARE @message varchar(100) = 'There are only ' + CAST(@FreePlaces as varchar(10)) +
--                                             ' places left for this conference day.';
--             THROW 52000,@message,1 ROLLBACK TRANSACTION
--         END
-- END


