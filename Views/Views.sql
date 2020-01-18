CREATE VIEW PaymentsForReservation
	AS
	SELECT reservation_id, sum(Payments.value) as already_paid
	FROM Payments
	GROUP BY reservation_id
GO

-- wyświetla balans każdego klienta
CREATE VIEW ClientsBalanceView
AS SELECT id as client_id, dbo.clientsBalance(id) as balance FROM Clients


-- widok wszystkich klientów którzy nie opłacili rezerwacji
CREATE VIEW ClientsWithUnpaidReservations
AS SELECT clients_id, reservation_id, due_price as to_pay_until,
          dbo.confReservationPrice(reservation_id) -dbo.confReservationPaidAmount(reservation_id) as left_to_pay
FROM Conference_day_reservations

-- widok klientów którzy nie opłacili rezerwacji w wyznaczonym terminie
CREATE VIEW ClientsToCall
AS SELECT clients_id, reservation_id, due_price as to_pay_until,
          dbo.confReservationPrice(reservation_id) -dbo.confReservationPaidAmount(reservation_id) as left_to_pay
FROM Conference_day_reservations
WHERE due_price < GETDATE()

-- warsztaty na które są jeszcze wolne miejsca
-- CREATE VIEW AvailableWorkshops

-- widok prezentujący klientów którzy najczęściej korzystają z usług i którzy najwięcej płacą.
-- CREATE VIEW MostActiveClients

--widok prezentujący uczestników na różne dni konferencji
CREATE VIEW ParticipantsForConferenceDay
AS SELECT name, surname, conference_day_id FROM Participants
INNER JOIN Conference_day_registration Cdrg on Participants.participant_id = Cdrg.Participant_id
INNER JOIN Conference_day_reservations Cdr on Cdrg.reservation_id = Cdr.reservation_id

--widok prezentujący uczestników na różne warsztaty
CREATE VIEW ParticipantsForWorkshop
AS SELECT name, surname, workshop_id FROM Participants
INNER JOIN Workshop_registration Wrg on Participants.participant_id = Wrg.Participant_id
INNER JOIN Workshop_reservations Wrs on Wrg.reservation_id = Wrs.reservation_id
