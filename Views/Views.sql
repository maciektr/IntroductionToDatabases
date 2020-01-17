CREATE VIEW PaymentsForReservation
	AS
	SELECT reservation_id, sum(value)
	FROM Payments
	GROUP BY reservation_id
GO

-- CREATE VIEW UnpaidDayReservations
-- 	AS
-- 	SELECT Conferences.name as Nazwa_Konferencji, Dni_Konferencji.Data,
-- 	Klienci.Nazwa as Nazwa_Klienta, Kwota_Do_Zaplaty, Kwota_Zaplacona,
-- 	Kwota_Do_Zaplaty - Kwota_Zaplacona as Roznica, Dni_Konferencji_Rezerwacje.Liczba_Miejsc,
-- 	Klienci.Nr_Telefonu, Klienci.Email
-- 	FROM Conference_day_reservations
-- 	join Conference_days Cd on Conference_day_reservations.conference_day_id = Cd.conference_day_id
-- 	join Conferences C on Cd.conference_id = C.Conference_id
-- 	join Clients C2 on Conference_day_reservations.clients_id = C2.id
-- 	WHERE due_price < paid_price
-- 	AND Cd.date > GETDATE()
-- GO
