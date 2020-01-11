-- foreign keys
ALTER TABLE Companies DROP CONSTRAINT Companies_Clients;

ALTER TABLE Conference_day_registration DROP CONSTRAINT Conference_day_registration_Conference_day_reservations;

ALTER TABLE Conference_day_registration DROP CONSTRAINT Conference_day_registration_Participants;

ALTER TABLE Conference_day_reservations DROP CONSTRAINT Conference_day_reservations_Clients;

ALTER TABLE Conference_day_reservations DROP CONSTRAINT Conference_day_reservations_Conference_days;

ALTER TABLE Conference_days DROP CONSTRAINT Conference_days_Conferences;

ALTER TABLE Early_signup_discounts DROP CONSTRAINT Discounts_Conference_days;

ALTER TABLE Participants DROP CONSTRAINT Participants_Clients;

ALTER TABLE Payments DROP CONSTRAINT Payments_Conference_day_reservations;

ALTER TABLE Workshop_registration DROP CONSTRAINT Workshop_registration_Participants;

ALTER TABLE Workshop_registration DROP CONSTRAINT Workshop_registration_Workshop_reservations;

ALTER TABLE Workshop_reservations DROP CONSTRAINT Workshop_reservations_Workshops;

ALTER TABLE Workshops DROP CONSTRAINT Workshops_Conference_days;

-- tables
DROP TABLE Clients;

DROP TABLE Companies;

DROP TABLE Conference_day_registration;

DROP TABLE Conference_day_reservations;

DROP TABLE Conference_days;

DROP TABLE Conferences;

DROP TABLE Early_signup_discounts;

DROP TABLE Participants;

DROP TABLE Payments;

DROP TABLE Workshop_registration;

DROP TABLE Workshop_reservations;

DROP TABLE Workshops;

-- End of file.

