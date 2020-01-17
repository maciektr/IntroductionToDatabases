CREATE PROCEDURE AddConference -- TODO add conference location? start-end date?
    @Name varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Conferences(Name)
    VALUES (@Name)
END
GO

CREATE PROCEDURE AddConferenceDay @ConferenceId int, -- TODO nr of seats for conference?
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
    INSERT INTO Clients(zip_code, city, address)
    VALUES (@ZipCode, @City, @Address)
END
GO

-- Add company (each has its unique clients_id)
CREATE PROCEDURE AddCompany @companyName varchar(100), @nip nvarchar(15), @phone varchar(20),
                            @clients_id int, @email varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Companies(companyName, nip, phone, clients_id, email)
    VALUES (@companyName, @nip, @phone, @clients_id, @email)
END
GO
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
GO

CREATE PROCEDURE AddPayment @ReservationID int, @Value money
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Payments(reservation_id, value)
    VALUES (@ReservationID, @Value) -- date = getDate() by default
END
GO

create procedure AddEarlySignupDiscount @ConferenceDayId int, @EndDate datetime,
                                        @Discount decimal(4, 4)
as
begin
    set nocount on;
    insert into Early_signup_discounts(conference_day_id, end_date, discount)
    values (@ConferenceDayId, @EndDate, @Discount)
end
go

create procedure AddWorkshop @conference_day_id int,
                             @start_time datetime, @end_time datetime,
                             @topic text, @price money, @number_of_seats int
as
begin
    set nocount on;
    insert into Workshops(conference_day_id, start_time, end_time, topic, price, number_of_seats)
    values (@conference_day_id, @start_time, @end_time, @topic, @price, @number_of_seats)
end
go


create procedure RegisterParticipantForConferenceDay @reservation_id int, @Participant_id int, @is_student bit
as
begin
    set nocount on;
    insert into Conference_day_registration(reservation_id, Participant_id, is_student)
    values (@reservation_id, @Participant_id, @is_student)
end
go

create procedure RegisterParticipantForWorkshop @reservation_id int, @Participant_id int
as
begin
    set nocount on;
    insert into Workshop_registration(reservation_id, Participant_id)
    values (@reservation_id, @Participant_id)
end
go

create procedure AddConferenceDayReservation @conference_day_id int, @clients_id int, @reservation_date datetime,
                                             @active bit, @due_price datetime,
                                             @adult_seats int, @student_seats int
as
begin
    set nocount on;
    insert into Conference_day_reservations(conference_day_id, clients_id, reservation_date, active, due_price,
                                            adult_seats, student_seats)
    values (@conference_day_id, @clients_id, @reservation_date, @active, @due_price, @adult_seats, @student_seats)
end
go

create procedure AddWorkshopReservation @workshop_id int, @reservation_date datetime, @due_price datetime,
                                        @nr_of_seats int
as
begin
    set nocount on;
    insert into Workshop_reservations(workshop_id, reservation_date, due_price, nr_of_seats)
    values (@workshop_id, @reservation_date, @due_price, @nr_of_seats)
end
go

