-- tables
-- Table: Clients
CREATE TABLE Clients (
    id int  NOT NULL IDENTITY,
    zip_code varchar(6)  NOT NULL,
    city varchar(30)  NOT NULL,
    address varchar(100)  NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY  (id)
);

-- Table: Companies
CREATE TABLE Companies (
    companyName varchar(100)  NOT NULL,
    nip nvarchar(15)  NOT NULL CHECK ((nip not like '%[^0-9]%') and (LEN(nip) = 10) and (nip not like '0%' or nip like '1%')),
    phone varchar(20)  NOT NULL,
    clients_id int  NOT NULL,
    email varchar(100)  NOT NULL CHECK (email like '%_@__%.__%'),
    CONSTRAINT unique_nip UNIQUE (nip),
    CONSTRAINT checkNip CHECK (dbo.IsValidNip(nip) = 1),
    CONSTRAINT Companies_pk PRIMARY KEY  (clients_id)
);

CREATE INDEX companies_client_id on Companies (clients_id ASC)
;

CREATE INDEX companies_nip on Companies (nip ASC)
;

-- Table: Conference_day_registration
CREATE TABLE Conference_day_registration (
    reservation_id int  NOT NULL,
    Participant_id int  NOT NULL,
    is_student bit  NOT NULL DEFAULT 0,
    CONSTRAINT Conference_day_registration_pk PRIMARY KEY  (reservation_id,Participant_id)
);

CREATE INDEX day_reg_part_id on Conference_day_registration (Participant_id ASC)
;

CREATE INDEX day_reg_res_id on Conference_day_registration (reservation_id ASC)
;

-- Table: Conference_day_reservations
CREATE TABLE Conference_day_reservations (
    reservation_id int  NOT NULL IDENTITY,
    conference_day_id int  NOT NULL,
    clients_id int  NOT NULL,
    reservation_date datetime  NOT NULL DEFAULT GETDATE(),
    active bit  NOT NULL DEFAULT 1,
    due_price datetime  NOT NULL DEFAULT DATEADD(week, 2, GETDATE()) CHECK (due_price >= GETDATE()),
    adult_seats int  NOT NULL DEFAULT 0 CHECK (adult_seats >= 0),
    student_seats int  NOT NULL DEFAULT 0 CHECK (student_seats >= 0),
    CONSTRAINT Conference_day_reservations_pk PRIMARY KEY  (reservation_id)
);

CREATE INDEX day_res_day_id on Conference_day_reservations (conference_day_id ASC)
;

CREATE INDEX day_res_client_id on Conference_day_reservations (clients_id ASC)
;

CREATE INDEX day_res_pay_deadline on Conference_day_reservations (due_price ASC)
;

-- Table: Conference_days
CREATE TABLE Conference_days (
    conference_day_id int  NOT NULL IDENTITY,
    conference_id int  NOT NULL,
    date date  NOT NULL DEFAULT GETDATE(),
    standard_price money  NOT NULL DEFAULT 0 CHECK (standard_price >= 0),
    student_discount decimal(4,4)  NOT NULL DEFAULT 0 CHECK (student_discount >= 0),
    number_of_seats int  NOT NULL DEFAULT 0 CHECK (number_of_seats >= 0),
    CONSTRAINT Conference_days_pk PRIMARY KEY  (conference_day_id)
);

CREATE INDEX day_conf_id on Conference_days (conference_id ASC)
;

-- Table: Conferences
CREATE TABLE Conferences (
    Conference_id int  NOT NULL IDENTITY,
    name varchar(100)  NOT NULL,
    description text  NULL,
    CONSTRAINT Conferences_pk PRIMARY KEY  (Conference_id)
);

-- Table: Early_signup_discounts
CREATE TABLE Early_signup_discounts (
    discount_id int  NOT NULL IDENTITY,
    conference_day_id int  NOT NULL,
    end_date datetime  NOT NULL,
    discount decimal(4,4)  NOT NULL DEFAULT 0,
    CONSTRAINT Early_signup_discounts_pk PRIMARY KEY  (discount_id)
);

CREATE INDEX esd_end_date on Early_signup_discounts (end_date ASC)
;

-- Table: Participants
CREATE TABLE Participants (
    participant_id int  NOT NULL IDENTITY,
    clients_id int  NULL DEFAULT Null,
    name varchar(100)  NOT NULL,
    surname varchar(100)  NOT NULL,
    email varchar(100)  NOT NULL CHECK (email like '%_@__%.__%'),
    phone varchar(20)  NOT NULL,
    CONSTRAINT Participants_pk PRIMARY KEY  (participant_id)
);

CREATE INDEX participants_client_id on Participants (clients_id ASC)
;

CREATE INDEX participants_name on Participants (surname ASC,name ASC)
;

-- Table: Payments
CREATE TABLE Payments (
    payment_id int  NOT NULL IDENTITY,
    reservation_id int  NOT NULL,
    in_date datetime  NOT NULL,
    value money  NOT NULL,
    CONSTRAINT Payments_pk PRIMARY KEY  (payment_id)
);

CREATE INDEX payment_reservation on Payments (reservation_id ASC)
;

-- Table: Workshop_registration
CREATE TABLE Workshop_registration (
    Participant_id int  NOT NULL,
    reservation_id int  NOT NULL,
    CONSTRAINT Workshop_registration_pk PRIMARY KEY  (Participant_id,reservation_id)
);

CREATE INDEX workshop_reg_part_id on Workshop_registration (Participant_id ASC)
;

CREATE INDEX workshop_reg_res_id on Workshop_registration (reservation_id ASC)
;

-- Table: Workshop_reservations
CREATE TABLE Workshop_reservations (
    reservation_id int  NOT NULL IDENTITY,
    workshop_id int  NOT NULL,
    reservation_date datetime  NOT NULL DEFAULT GETDATE(),
    due_price datetime  NOT NULL DEFAULT DATEADD(week, 2, GETDATE()) CHECK (due_price >= GETDATE()),
    nr_of_seats int  NOT NULL DEFAULT 0 CHECK (nr_of_seats >= 0),
    Conference_day_res_id int  NOT NULL,
    active bit  NOT NULL DEFAULT 1,
    CONSTRAINT Workshop_reservations_pk PRIMARY KEY  (reservation_id)
);

CREATE INDEX workshop_res_conf_res_id on Workshop_reservations (Conference_day_res_id ASC)
;

CREATE INDEX workshop_res_pay_deadline on Workshop_reservations (due_price ASC)
;

CREATE INDEX workshop_res_workshop_id on Workshop_reservations (workshop_id ASC)
;

-- Table: Workshops
CREATE TABLE Workshops (
    workshop_id int  NOT NULL IDENTITY,
    conference_day_id int  NOT NULL,
    start_time datetime  NOT NULL,
    end_time datetime  NOT NULL CHECK (end_time >= GETDATE()),
    topic varchar(100)  NOT NULL,
    price money  NOT NULL CHECK (price >= 0),
    number_of_seats int  NOT NULL DEFAULT 0 CHECK (number_of_seats >= 0),
    CONSTRAINT Workshops_pk PRIMARY KEY  (workshop_id)
);

CREATE INDEX workshop_day_id on Workshops (conference_day_id ASC)
;

CREATE INDEX workshop_time on Workshops (start_time ASC,end_time ASC)
;

-- foreign keys
-- Reference: Companies_Clients (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id);

-- Reference: Conference_day_registration_Conference_day_reservations (table: Conference_day_registration)
ALTER TABLE Conference_day_registration ADD CONSTRAINT Conference_day_registration_Conference_day_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Conference_day_reservations (reservation_id)
    ON DELETE  CASCADE;

-- Reference: Conference_day_registration_Participants (table: Conference_day_registration)
ALTER TABLE Conference_day_registration ADD CONSTRAINT Conference_day_registration_Participants
    FOREIGN KEY (Participant_id)
    REFERENCES Participants (participant_id)
    ON DELETE  CASCADE;

-- Reference: Conference_day_reservations_Clients (table: Conference_day_reservations)
ALTER TABLE Conference_day_reservations ADD CONSTRAINT Conference_day_reservations_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id);

-- Reference: Conference_day_reservations_Conference_days (table: Conference_day_reservations)
ALTER TABLE Conference_day_reservations ADD CONSTRAINT Conference_day_reservations_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id)
    ON DELETE  CASCADE;

-- Reference: Conference_days_Conferences (table: Conference_days)
ALTER TABLE Conference_days ADD CONSTRAINT Conference_days_Conferences
    FOREIGN KEY (conference_id)
    REFERENCES Conferences (Conference_id)
    ON DELETE  CASCADE;

-- Reference: Discounts_Conference_days (table: Early_signup_discounts)
ALTER TABLE Early_signup_discounts ADD CONSTRAINT Discounts_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id)
    ON DELETE  CASCADE;

-- Reference: Participants_Clients (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id)
    ON DELETE  SET NULL;

-- Reference: Payments_Conference_day_reservations (table: Payments)
ALTER TABLE Payments ADD CONSTRAINT Payments_Conference_day_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Conference_day_reservations (reservation_id);

-- Reference: Workshop_registration_Participants (table: Workshop_registration)
ALTER TABLE Workshop_registration ADD CONSTRAINT Workshop_registration_Participants
    FOREIGN KEY (Participant_id)
    REFERENCES Participants (participant_id)
    ON DELETE  CASCADE;

-- Reference: Workshop_registration_Workshop_reservations (table: Workshop_registration)
ALTER TABLE Workshop_registration ADD CONSTRAINT Workshop_registration_Workshop_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Workshop_reservations (reservation_id)
    ON DELETE  CASCADE;

-- Reference: Workshop_reservations_Conference_day_reservations (table: Workshop_reservations)
ALTER TABLE Workshop_reservations ADD CONSTRAINT Workshop_reservations_Conference_day_reservations
    FOREIGN KEY (Conference_day_res_id)
    REFERENCES Conference_day_reservations (reservation_id)
    ON DELETE  CASCADE;

-- Reference: Workshop_reservations_Workshops (table: Workshop_reservations)
ALTER TABLE Workshop_reservations ADD CONSTRAINT Workshop_reservations_Workshops
    FOREIGN KEY (workshop_id)
    REFERENCES Workshops (workshop_id)
    ON DELETE  CASCADE;

-- Reference: Workshops_Conference_days (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshops_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id);

-- End of file.

