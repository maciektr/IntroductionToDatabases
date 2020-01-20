-- Shows sum of payments per reservation
CREATE VIEW PaymentsForReservation
AS
SELECT reservation_id, ISNULL(sum(Payments.value), 0) as already_paid
FROM Payments
GROUP BY reservation_id
GO

-- Show sum of payments per client
CREATE VIEW PaymentsForClients
AS
SELECT clients_id, SUM(value) AS paid
FROM Payments
         INNER JOIN Conference_day_reservations Cdr ON Payments.reservation_id = Cdr.reservation_id
GROUP BY clients_id
GO


-- Shows balance of payments per reservation
CREATE VIEW BalanceForReservation
AS
SELECT reservation_id, already_paid - dbo.confReservationPrice(reservation_id) as balance
FROM PaymentsForReservation
GO

-- Shows payment balance per client
CREATE VIEW ClientsBalanceView
AS
SELECT id                     as client_id,
       dbo.clientsBalance(id) as balance
FROM Clients
GO

-- Shows clients with unpaid reservations
CREATE VIEW ClientsWithUnpaidReservations
AS
SELECT clients_id,
       reservation_id,
       due_price                                                                                as to_pay_until,
       DATEDIFF(DAY, GETDATE(), due_price) as days_left,
       dbo.confReservationPrice(reservation_id) - dbo.confReservationPaidAmount(reservation_id) as left_to_pay,
       dbo.showClientsName(clients_id)                                                          as clients_name
FROM Conference_day_reservations
WHERE dbo.confReservationPrice(reservation_id) - dbo.confReservationPaidAmount(reservation_id) > 0.01
  and Conference_day_reservations.active = 1
GO

-- Same but only for companies
CREATE VIEW CompaniesWithUnpaidReservations
AS
    SELECT *
    FROM ClientsWithUnpaidReservations
    WHERE dbo.isClientCompany(clients_id) = 1
GO

-- Same but only for individual clients
CREATE VIEW IndividualClientsWithUnpaidReservations
AS
    SELECT *
    FROM ClientsWithUnpaidReservations
    WHERE dbo.isClientCompany(clients_id) = 0
GO

-- Same, but with the earliest payment deadline
CREATE VIEW UnpaidReservationsWithEarliestDeadline
AS
    SELECT TOP 10 *
    FROM ClientsWithUnpaidReservations
    ORDER BY to_pay_until ASC
GO

-- Clients with unpaid reservations who exceeded payment deadline
CREATE VIEW ClientsWithExceededPaymentDeadline
AS
    SELECT *
    FROM ClientsWithUnpaidReservations
    WHERE to_pay_until < GETDATE()
GO

-- Workshops with free seats available
CREATE VIEW WorkshopsWithFreeSeats
AS
SELECT workshop_id,
       dbo.workshopFreeSeats(workshop_id) as free_seats
FROM Workshops
WHERE dbo.workshopFreeSeats(workshop_id) > 0
GO

-- Conference days with free seats available
CREATE VIEW ConferenceDaysWithFreeSeats
AS
SELECT conference_day_id,
       dbo.conferenceFreeSeats(conference_day_id) as free_seats
FROM Conference_days
WHERE dbo.conferenceFreeSeats(conference_day_id) > 0
GO

-- Clients who paid the most
CREATE VIEW ClientsWhoPaidMost
AS
SELECT TOP 20 *
from PaymentsForClients
ORDER BY paid DESC
GO

-- Clients with the highest count of conference reservations
CREATE VIEW MostActiveClients
AS
SELECT TOP 20 clients_id, COUNT(reservation_id) AS reservation_count
FROM Clients
         INNER JOIN Conference_day_reservations Cdr on Clients.id = Cdr.clients_id
GROUP BY clients_id
ORDER BY COUNT(reservation_id) DESC
GO

-- Show participants for conference days
CREATE VIEW ParticipantsForConferenceDay
AS
SELECT name, surname, conference_day_id
FROM Participants
         INNER JOIN Conference_day_registration Cdrg on Participants.participant_id = Cdrg.Participant_id
         INNER JOIN Conference_day_reservations Cdr on Cdrg.reservation_id = Cdr.reservation_id

-- Show participants for workshops
CREATE VIEW ParticipantsForWorkshop
AS
SELECT name, surname, workshop_id
FROM Participants
         INNER JOIN Workshop_registration Wrg on Participants.participant_id = Wrg.Participant_id
         INNER JOIN Workshop_reservations Wrs on Wrg.reservation_id = Wrs.reservation_id

-- Show cancelled conference reservations
CREATE VIEW CancelledConferenceReservations
AS
SELECT reservation_id,
       conference_day_id,
       reservation_date,
       clients_id,
       adult_seats,
       student_seats,
       dbo.showClientsName(clients_id) as clients_name
FROM Conference_day_reservations
WHERE active = 0

-- Show cancelled workshops reservations
CREATE VIEW CancelledWorkshopsReservations
AS
    SELECT Workshop_reservations.reservation_id,
       workshop_id,
       Workshop_reservations.reservation_date,
       nr_of_seats,
       dbo.showClientsName(clients_id) as clients_name
    FROM Workshop_reservations
         INNER JOIN Conference_day_reservations Cdr on Workshop_reservations.Conference_day_res_id = Cdr.reservation_id
    WHERE Workshop_reservations.active = 0
GO

-- Show how popular conferences are
CREATE VIEW ConferencePopularity
AS
    SELECT conf.Conference_id, conf.name, SUM(cdr.student_seats + cdr.adult_seats) AS participants_count
    FROM Conferences conf INNER JOIN Conference_days cd on conf.Conference_id = cd.conference_id
    INNER JOIN Conference_day_reservations cdr on cd.conference_day_id = cdr.conference_day_id
    WHERE cdr.active = 1
    GROUP BY conf.Conference_id, conf.name
GO

-- Show the most popular conferences
CREATE VIEW MostPopularConference
AS
    SELECT TOP 20 *
    FROM ConferencePopularity
    ORDER BY participants_count DESC
GO

-- Show how popular Workshops are
CREATE VIEW WorkshopPopularity
AS
    SELECT w.workshop_id, w.topic, SUM(wr.nr_of_seats) AS participants_count
    FROM Workshops w INNER JOIN Workshop_reservations wr on w.workshop_id = wr.workshop_id
    WHERE wr.active=1
    GROUP BY w.workshop_id, w.topic
GO

-- Show the most popular workshops
CREATE VIEW MostPopularWorkshops
AS
    SELECT TOP 20 *
    FROM WorkshopPopularity
    ORDER BY participants_count DESC
GO

-- Show all cities from which our clients are coming
CREATE VIEW ClientsCities
AS
    SELECT DISTINCT city
    FROM Clients
GO

-- Show all clients phone numbers
CREATE VIEW ClientsPhones
AS
    SELECT DISTINCT phone
    FROM Clients INNER JOIN Companies C on Clients.id = C.clients_id
    UNION
    SELECT DISTINCT phone
    FROM Clients INNER JOIN Participants P on Clients.id = P.clients_id
GO

-- Show all clients phone numbers
CREATE VIEW ClientsEmails
AS
    SELECT DISTINCT email
    FROM Clients INNER JOIN Companies C on Clients.id = C.clients_id
    UNION
    SELECT DISTINCT email
    FROM Clients INNER JOIN Participants P on Clients.id = P.clients_id
GO