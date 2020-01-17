CREATE PROCEDURE DeleteWorkshopRegistration @ParticipantID int, @ReservationID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN DELETE
                   FROM Workshop_registration
                   WHERE reservation_id = @ReservationId
                     AND Participant_id = @ParticipantID
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        PRINT error_message() ROLLBACK TRANSACTION
    END CATCH
END
GO

CREATE PROCEDURE DeleteWorkshopReservation @ReservationID int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN DELETE
                   FROM Workshop_reservations
                   WHERE reservation_id = @ReservationId
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        PRINT error_message() ROLLBACK TRANSACTION
    END CATCH
END
GO
