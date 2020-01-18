-- ===================================
-- Triggery dla tabeli Workshops
-- ===================================
-- sprawdzenie czy godzina rozpoczęcia warsztatów jest wcześniejsza niż godzina jego zakończenia
CREATE TRIGGER StartHourLtEndHour
    ON Workshops
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @StartTime date = (SELECT start_time FROM inserted)
    DECLARE @EndTime int = (SELECT end_time FROM inserted)
    IF (@StartTime > @EndTime)
        BEGIN
            DECLARE @message varchar(100) = 'Workshop cant begin after it ends.';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END

-- sprawdzenie czy tworzone warsztaty nie mają większej ilości miejsc niż to ogranicza odpowiadający dzień konferencji
CREATE TRIGGER WorkshopPlacesLtConfPlaces
    ON Workshops
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @confDayId int = (SELECT conference_day_id FROM inserted)
    DECLARE @nrOfseatsW date = (SELECT number_of_seats FROM inserted)
    DECLARE @nrOfseatsC int = (SELECT number_of_seats FROM Conference_days WHERE conference_day_id = @confDayId)
    IF (@nrOfseatsW > @nrOfseatsC)
        BEGIN
            DECLARE @message varchar(100) = 'Conference day offers less seats than proposed workshop';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END

-- ===================================
-- Triggery dla tabeli Workshop_reservations
-- ===================================
-- przy rzerwacji miejsc na warsztaty sprawdza czy jest odpowiednia ilość wolnych miejsc na warsztatach
CREATE TRIGGER CheckIfEnoughSeatsAvailableForWorkshop
    ON Workshop_reservations
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @WorkshopID int = (SELECT workshop_id FROM inserted)
    DECLARE @RequestedSeats int = (SELECT nr_of_seats FROM inserted)
    DECLARE @FreeSeats int = (SELECT [dbo].[workshopFreeSeats](@WorkshopID))
    IF (@FreeSeats < @RequestedSeats)
        BEGIN
            DECLARE @Message varchar(100) = 'There are only ' + CAST(@FreeSeats as varchar(10)) +
                                            ' places left for this conference day.';
            THROW 52000,@Message,1 ROLLBACK TRANSACTION
        END
END


-- sprawdzenie czy klient nie próbuje zarezerwować warsztatu odbywającego się w inny dzień
-- niż powiązana z tą rezerwacją rezerwacja dnia konferencji
CREATE TRIGGER CheckIfWorkshopAndConfOnSameDay
    ON Workshop_reservations
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @WorkshopID int = (SELECT workshop_id FROM inserted)
    DECLARE @WorkshopDate date = (SELECT CONVERT(date, start_time)
                                  FROM Workshops
                                  WHERE Workshops.workshop_id = @WorkshopID)
    DECLARE @ConfDayResID int = (SELECT Conference_day_res_id FROM inserted)
    DECLARE @ConfDayID int = (SELECT conference_day_id
                              FROM Conference_day_reservations
                              WHERE Conference_day_res_id = @ConfDayResID)
    DECLARE @ConfDayDate date = (SELECT date FROM Conference_days WHERE conference_day_id = @ConfDayID)
    IF (@ConfDayDate <> @WorkshopDate)
        BEGIN
            DECLARE @Message varchar(100) = 'workshop date differs from the associated conference day date';
            THROW 52000,@Message,1 ROLLBACK TRANSACTION
        END
END

-- sprawdzenie czy odpowiadająca rezerwacji warsztatu rezerwacja dnia konferencji jest aktywna
CREATE TRIGGER CheckIfCorrespConfReservationActive
    ON Workshop_reservations
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ConfResID date = (SELECT Conference_day_res_id FROM inserted)
    IF ((SELECT active FROM Conference_day_reservations cdr WHERE cdr.reservation_id = @ConfResID) = 0)
        BEGIN
            DECLARE @Message varchar(100) = 'Corresponding conference day reservation is not active';
            THROW 52000,@Message,1 ROLLBACK TRANSACTION
        END
END

-- procedura usuwająca uczestników warsztatów zapisanych na dezaktywowaną rezerwację
-- TODO isActive neccessary? -> forces manual CASCADE
CREATE TRIGGER OnDeactivateWReservation
    ON Workshop_reservations
    AFTER UPDATE AS
BEGIN
    DECLARE @active bit = (SELECT active FROM inserted)
    DECLARE @ReservationID int = (SELECT reservation_id FROM inserted)
    IF (@active = 0)
        BEGIN TRY
        BEGIN TRAN DELETE
                   FROM Workshop_registration
                   WHERE reservation_id = @ReservationId
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        PRINT error_message() ROLLBACK TRANSACTION
    END CATCH
END
-- ===================================
-- Triggery dla tabeli Workshop_registration
-- ===================================
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
                                                INNER JOIN Workshop_registration Wrg
                                                           on Wrs.reservation_id = Wrg.reservation_id AND
                                                              Wrg.Participant_id = @ParticipantID
                                                INNER JOIN Workshops W on Wrs.workshop_id = W.workshop_id
                                       WHERE ((W.start_time BETWEEN @StartTime AND @EndTime)
                                           OR (W.end_time BETWEEN @StartTime AND @EndTime)))
    IF (@CollidingWorkshops
        > 1) -- already registered for the day
        BEGIN
            DECLARE @message varchar(100) = 'Participant nr ' + CAST(@ParticipantID as varchar(3)) +
                                            ' already registered for ' + CAST(@CollidingWorkshops as varchar(3)) +
                                            ' workshops at this time';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END

-- trigger zapewniający aby na daną rezerwację warsztatów nie zapisało się więcej osób
-- niż jest zarezerwowanych miejsc
CREATE TRIGGER CheckIfWorkshopReservationNotFull
    ON Workshop_registration
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ReservationId int = (SELECT reservation_id FROM inserted)
    DECLARE @PartForReserv int = (SELECT COUNT(Participant_id)
                                  FROM Workshop_registration Wr
                                  WHERE Wr.reservation_id = @ReservationId)
    DECLARE @ReservedSeats int = (SELECT nr_of_seats FROM Workshop_reservations WHERE reservation_id = @ReservationId)
    IF (@PartForReserv > @ReservedSeats)
        BEGIN
            DECLARE @message varchar(100) = 'nr of participants for this reservation is exceeded, ' +
                                            CAST(@PartForReserv as varchar(3)) +
                                            ' participants are already registered';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END

-- sprawdzenie czy uczestnik zapisuje się na aktywną rezerwację
CREATE TRIGGER CheckIfWReservationActive
    ON Workshop_registration
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @ReservationId int = (SELECT reservation_id FROM inserted)
    IF ((SELECT active FROM Workshop_reservations WHERE reservation_id = @ReservationId)
        = 0)
        BEGIN
            DECLARE @message varchar(100) = 'corresponding reservation is not active';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END