-- Shows sum of payments per reservation
CREATE VIEW PaymentsForReservation
AS
    SELECT reservation_id, ISNULL(sum(Payments.value),0) as already_paid
    FROM Payments
    GROUP BY reservation_id
GO

-- Show sum of payments per client
CREATE VIEW PaymentsForClients
AS
    SELECT clients_id, SUM(value) AS paid
    FROM Payments INNER JOIN Conference_day_reservations Cdr ON Payments.reservation_id = Cdr.reservation_id
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
SELECT id as client_id,
       dbo.clientsBalance(id) as balance
FROM Clients
GO

-- Shows clients with unpaid reservations
CREATE VIEW ClientsWithUnpaidReservations
AS
SELECT clients_id,
       reservation_id,
       due_price                                                                                as to_pay_until,
       dbo.confReservationPrice(reservation_id) - dbo.confReservationPaidAmount(reservation_id) as left_to_pay
FROM Conference_day_reservations
WHERE dbo.confReservationPrice(reservation_id) - dbo.confReservationPaidAmount(reservation_id) > 0.01
GO

-- Clients with unpaid reservations who exceeded payment deadline
CREATE VIEW ClientsWithExceededPaymentDeadline
AS
    SELECT * FROM ClientsWithUnpaidReservations
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
    SELECT TOP 20 * from PaymentsForClients
    ORDER BY paid DESC
GO

-- Clients with the highest count of conference reservations
CREATE VIEW MostActiveClients
AS
    SELECT TOP 20 clients_id, COUNT(reservation_id) AS reservation_count
    FROM Clients INNER JOIN Conference_day_reservations Cdr on Clients.id = Cdr.clients_id
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
