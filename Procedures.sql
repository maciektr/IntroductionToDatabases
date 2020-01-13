CREATE PROCEDURE AddConference -- TODO add conference location? start-end date?
    @Name varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conferences(Name)
    VALUES (@Name)
END
GO

CREATE PROCEDURE AddConferenceDay @ConferenceId int,
                                  @Date date,
                                  @StandardPrice money,
                                  @StudentDiscount int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_days
        (conference_id, date, standard_price, student_discount)
    VALUES (@ConferenceId, @Date, @StandardPrice, @StudentDiscount)
END
GO

-- Add client (legal person) to database
CREATE PROCEDURE AddClient @ZipCode varchar(6), @City varchar(30), @Address varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Clients(zip_code, city, address) -- TODO autoincr?
    VALUES (@ZipCode, @City, @Address)
END

-- Add participant (natural person)
CREATE PROCEDURE AddParticipant @Name varchar(100), @Surname varchar(100),
                                @Email varchar(100), @Phone varchar(20),
                                @ClientId int = null -- TODO who pays for participant without client?
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Participants(clients_id, name, surname, email, phone)
    VALUES (@ClientId, @Name, @Surname, @Email, @Phone)
END

CREATE PROCEDURE AddPayment @ReservationID int, @Value money
AS BEGIN
    SET NOCOUNT ON;
    INSERT INTO Payments(reservation_id, value)
    VALUES (@ReservationID, @Value)  -- date = getDate() by default
END
