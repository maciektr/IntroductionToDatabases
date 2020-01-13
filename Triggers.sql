-- sprawdzenie czy na daną konferencje nie zostały dodane dwa te same dni konferencji
CREATE TRIGGER CheckForTwoTheSameConferenceDays
    ON Conference_days
    AFTER INSERT, UPDATE AS
BEGIN
    DECLARE @Date date = (SELECT date FROM inserted) --
    DECLARE @ConferenceId int = (SELECT conference_id FROM inserted)
    IF ((SELECT COUNT(conference_day_id)
         FROM Conference_days
         WHERE (date = @Date) AND (conference_id = @ConferenceId)) > 1)
        BEGIN
            DECLARE @message varchar(100) = 'Day ' + CAST(@Date as varchar(3)) +
                                            ' has already been added for this conference';
            THROW 52000,@message,1 ROLLBACK TRANSACTION
        END
END