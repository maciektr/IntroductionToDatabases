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

-- sprawdzenie czy uczestnik zapisujący się na warsztaty nie jest już zapisany na inne warsztaty
-- odbywające się w tym samym czasie
CREATE TRIGGER CheckIfNotRegisteredForOtherWorkshop
    ON Workshop_registration
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ReservationId int = (SELECT reservation_id FROM inserted)
    DECLARE @ParticipantID int = (SELECT participant_id FROM inserted)
    DECLARE @StartTime datetime = (SELECT start_time
                                   FROM Workshops
                                            INNER JOIN Workshop_reservations Wr on Workshops.workshop_id = Wr.workshop_id
                                   WHERE Wr.reservation_id = @ReservationId)
    DECLARE @EndTime datetime = (SELECT end_time
                                 FROM Workshops
                                          INNER JOIN Workshop_reservations Wr on Workshops.workshop_id = Wr.workshop_id
                                 WHERE Wr.reservation_id = @ReservationId)
    DECLARE @CollidingWorkshops int = (SELECT Count(W.workshop_id)
         FROM Workshop_reservations Wrs
                INNER JOIN Workshop_registration Wrg on Wrs.reservation_id = Wrg.reservation_id AND Wrg.Participant_id=@ParticipantID
                  INNER JOIN Workshops W on Wrs.workshop_id = W.workshop_id
         WHERE
               ((W.start_time BETWEEN @StartTime AND @EndTime)
            OR (W.end_time BETWEEN @StartTime AND @EndTime)))
    IF (@CollidingWorkshops
        > 1) -- already registered for the day or0
        BEGIN
            DECLARE @message varchar(100) = 'Participant nr ' + CAST(@ParticipantID as varchar(3)) +
                                            ' already registered for '+CAST(@CollidingWorkshops as varchar(3))+' workshops at this time';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END

-- przy rzerwacji miejsc na warsztaty sprawdza czy jest odpowiednia ilość wolnych miejsc
CREATE TRIGGER CheckIfEnoughSeatsAvailable
    ON Workshop_reservations
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @WorkshopID int = (SELECT workshop_id FROM inserted)
    DECLARE @RequestedSeats int = (SELECT nr_of_seats FROM inserted)
    DECLARE @FreeSeats int = (SELECT [dbo].[getWorkshopsFreeSeatsCount](@WorkshopID))
    IF (@FreeSeats < @RequestedSeats)
        BEGIN
            DECLARE @Message varchar(100) = 'There are only ' + CAST(@FreeSeats as varchar(10)) +
                                            ' places left for this conference day.';
            THROW 52000,@Message,1 ROLLBACK TRANSACTION
        END
END



