-- Add client to database
CREATE PROCEDURE AddClientParticipant @ZipCode varchar(6), @City varchar(30), @Address varchar(100), @Name varchar(100),
                                      @Surname varchar(100),
                                      @Email varchar(100), @Phone varchar(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Clients(zip_code, city, address)
    VALUES (@ZipCode, @City, @Address)

    INSERT INTO Participants (clients_id, name, surname, email, phone)
    VALUES (SCOPE_IDENTITY(), @Name, @Surname, @Email, @Phone)
END
GO

CREATE PROCEDURE AddClientCompany @ZipCode varchar(6), @City varchar(30), @Address varchar(100),
                                  @companyName varchar(100), @nip nvarchar(15), @phone varchar(20), @email varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Clients(zip_code, city, address)
    VALUES (@ZipCode, @City, @Address)

    INSERT INTO Companies (companyName, nip, phone, clients_id, email)
    VALUES (@companyName, @nip, @phone, scope_identity(), @email)
END
GO

-- Add participant
CREATE PROCEDURE AddParticipant @Name varchar(100), @Surname varchar(100),
                                @Email varchar(100), @Phone varchar(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Participants(name, surname, email, phone)
    VALUES (@Name, @Surname, @Email, @Phone)
END
GO

CREATE PROCEDURE AddPayment @ReservationID int, @Value money
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Payments(reservation_id, value)
    VALUES (@ReservationID, @Value) -- date = getDate() by default
END
GO

CREATE PROCEDURE AddConference @Name varchar(100),
                               @description text = null
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conferences(name, description)
    VALUES (@Name, @description)
END
GO

CREATE PROCEDURE AddConferenceDay @ConferenceId int,
                                  @Date date,
                                  @StandardPrice money,
                                  @StudentDiscount int,
                                  @NumberOfSeats int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_days
    (conference_id, date, standard_price, student_discount, number_of_seats)
    VALUES (@ConferenceId, @Date, @StandardPrice, @StudentDiscount, @NumberOfSeats)
END
GO

CREATE PROCEDURE AddConferenceWithDays @Name varchar(100),
                                       @numberOfDays int,
                                       @startDate date,
                                       @price money,
                                       @studentDiscount decimal(4, 4),
                                       @numberOfSeats int,
                                       @description text = null
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conferences(name, description)
    VALUES (@Name, @description)

    DECLARE @confId int = SCOPE_IDENTITY()

    WHILE @numberOfDays > 0
        BEGIN
            EXEC AddConferenceDay
                 @confId,
                 @startDate,
                 @price,
                 @studentDiscount,
                 @numberOfSeats;
            SET @startDate = DATEADD(DAY, 1, @startDate)
            SET @numberOfSeats = @numberOfSeats - 1
        END
END
GO

CREATE PROCEDURE AddEarlySignupDiscount @ConferenceDayId int,
                                        @EndDate datetime,
                                        @Discount decimal(4, 4)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Early_signup_discounts(conference_day_id, end_date, discount)
    VALUES (@ConferenceDayId, @EndDate, @Discount)
END
GO

CREATE PROCEDURE AddEarlySignupDiscountToAllInConf @ConferenceId int,
                                                   @EndDate datetime,
                                                   @Discount decimal(4, 4)
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #ids
    (
        rn int,
        id int
    )
    INSERT INTO #ids
    SELECT DISTINCT row_number() over (order by conference_day_id) as rn, conference_day_id as id
    FROM Conference_days
    WHERE conference_id = @ConferenceId;

    DECLARE @id int
    DECLARE @totalrows int = (select count(*) from #ids)
    DECLARE @currentrow int = 1

    WHILE @currentrow <= @totalrows
        BEGIN
            set @id = (select id from #ids where rn = @currentrow)
            exec AddEarlySignupDiscount
                 @id,
                 @EndDate,
                 @Discount
            set @currentrow = @currentrow + 1
        END
END
GO

CREATE PROCEDURE AddWorkshop @conference_day_id int,
                             @start_time datetime,
                             @end_time datetime,
                             @topic varchar(100),
                             @price money,
                             @number_of_seats int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workshops(conference_day_id, start_time, end_time, topic, price, number_of_seats)
    VALUES (@conference_day_id, @start_time, @end_time, @topic, @price, @number_of_seats)
END
GO


CREATE PROCEDURE RegisterParticipantForConferenceDay @reservation_id int, @Participant_id int, @is_student bit
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conference_day_registration(reservation_id, Participant_id, is_student)
    VALUES (@reservation_id, @Participant_id, @is_student)
end
go

CREATE PROCEDURE RegisterParticipantForWorkshop @reservation_id int, @Participant_id int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workshop_registration(reservation_id, Participant_id)
    VALUES (@reservation_id, @Participant_id)
end
go

CREATE PROCEDURE AddConferenceDayReservation @conference_day_id int,
                                             @clients_id int,
                                             @reservation_date datetime,
                                             @due_price datetime,
                                             @adult_seats int,
                                             @student_seats int
AS
BEGIN
    SET NOCOUNT ON;
    IF ((SELECT COUNT(conference_day_id) FROM Conference_days WHERE conference_day_id = @conference_day_id) = 0)
        BEGIN
            THROW 52000,'There is no such conference day in database', 1;
        END
    INSERT INTO Conference_day_reservations(conference_day_id, clients_id, reservation_date, due_price,
                                            adult_seats, student_seats)
    VALUES (@conference_day_id, @clients_id, @reservation_date, @due_price, @adult_seats, @student_seats)
end
go

CREATE PROCEDURE AddConferenceReservation @conference_id int,
                                          @clients_id int,
                                          @reservation_date datetime,
                                          @due_price datetime,
                                          @adult_seats int,
                                          @student_seats int
AS
BEGIN
    SET NOCOUNT ON;
    IF ((SELECT COUNT(conference_id) FROM Conferences WHERE Conference_id = @conference_id) = 0)
        BEGIN
            THROW 52000,'There is no such conference in database', 1;
        END

    CREATE TABLE #ids
    (
        rn int,
        id int
    )
    INSERT INTO #ids
    SELECT DISTINCT row_number() over (order by conference_day_id) as rn, conference_day_id as id
    FROM Conference_days
    WHERE conference_id = @conference_id;


    DECLARE @id int
    DECLARE @totalrows int = (select count(*) from #ids)
    IF @totalrows=0
        BEGIN
            THROW 52000,'This conference has no days defined', 1;
        END
    DECLARE @currentrow int = 1

    WHILE @currentrow <= @totalrows
        BEGIN
            SET @id = (select id from #ids where rn = @currentrow)
            EXEC AddConferenceDayReservation
                 @id,
                 @clients_id,
                 @reservation_date,
                 @due_price,
                 @adult_seats,
                 @student_seats
            SET @currentrow = @currentrow + 1
        END

END
GO

CREATE PROCEDURE AddWorkshopReservation @workshop_id int,
                                        @conf_reservation_id int,
                                        @nr_of_seats int,
                                        @weeks_to_pay int
AS
BEGIN
    SET NOCOUNT ON;
    IF ((SELECT COUNT(workshop_id) FROM Workshops WHERE workshop_id = @workshop_id) = 0)
        BEGIN
            THROW 52000,'There is no such workshop in database', 1;
        END

    INSERT INTO Workshop_reservations(workshop_id, Conference_day_res_id, nr_of_seats, due_price)
    VALUES (@workshop_id, @conf_reservation_id, @nr_of_seats, DATEADD(week, @weeks_to_pay, GETDATE()))
END
GO