-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-01-04 11:08:00.981

-- tables
-- Table: Clients
CREATE TABLE Clients (
    id int  NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY  (id)
);

-- Table: Companies
CREATE TABLE Companies (
    companyName varchar(100)  NOT NULL,
    nip varchar(10)  NOT NULL,
    phone int  NOT NULL,
    clients_id int  NOT NULL,
    email varchar(100)  NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY  (clients_id)
);

-- Table: Conference_day_registration
CREATE TABLE Conference_day_registration (
    reservation_id int  NOT NULL,
    Participant_id int  NOT NULL,
    is_student bit  NOT NULL,
    CONSTRAINT Conference_day_registration_pk PRIMARY KEY  (reservation_id,Participant_id)
);

-- Table: Conference_day_reservations
CREATE TABLE Conference_day_reservations (
    reservation_id int  NOT NULL,
    conference_day_id int  NOT NULL,
    clients_id int  NOT NULL,
    reservation_date datetime  NOT NULL,
    active bit  NOT NULL,
    due_price datetime  NOT NULL,
    adult_seats int  NOT NULL,
    student_seats int  NOT NULL,
    CONSTRAINT Conference_day_reservations_pk PRIMARY KEY  (reservation_id)
);

-- Table: Conference_days
CREATE TABLE Conference_days (
    conference_day_id int  NOT NULL,
    conference_id int  NOT NULL,
    date date  NOT NULL,
    standard_price money  NOT NULL,
    student_discount decimal(4,4)  NOT NULL,
    CONSTRAINT Conference_days_pk PRIMARY KEY  (conference_day_id)
);

-- Table: Conferences
CREATE TABLE Conferences (
    Conference_id int  NOT NULL,
    name varchar(100)  NOT NULL,
    CONSTRAINT Conferences_pk PRIMARY KEY  (Conference_id)
);

-- Table: Early_signup_discounts
CREATE TABLE Early_signup_discounts (
    discount_id int  NOT NULL,
    conference_day_id int  NOT NULL,
    end_date datetime  NOT NULL,
    discount decimal(4,4)  NOT NULL,
    CONSTRAINT Early_signup_discounts_pk PRIMARY KEY  (discount_id)
);

-- Table: Participants
CREATE TABLE Participants (
    participant_id int  NOT NULL,
    clients_id int  NOT NULL,
    name varchar(100)  NOT NULL,
    surname varchar(100)  NOT NULL,
    email varchar(100)  NOT NULL,
    CONSTRAINT Participants_pk PRIMARY KEY  (participant_id)
);

-- Table: Payments
CREATE TABLE Payments (
    payment_id int  NOT NULL,
    reservation_id int  NOT NULL,
    in_date datetime  NOT NULL,
    value money  NOT NULL,
    CONSTRAINT Payments_pk PRIMARY KEY  (payment_id)
);

-- Table: Workshop_registration
CREATE TABLE Workshop_registration (
    Participant_id int  NOT NULL,
    reservation_id int  NOT NULL,
    CONSTRAINT Workshop_registration_pk PRIMARY KEY  (Participant_id,reservation_id)
);

-- Table: Workshop_reservations
CREATE TABLE Workshop_reservations (
    reservation_id int  NOT NULL,
    workshop_id int  NOT NULL,
    reservation_date datetime  NOT NULL,
    due_price datetime  NOT NULL,
    nr_of_seats int  NOT NULL,
    Conference_day_reservations_reservation_id int  NOT NULL,
    CONSTRAINT Workshop_reservations_pk PRIMARY KEY  (reservation_id)
);

-- Table: Workshops
CREATE TABLE Workshops (
    workshop_id int  NOT NULL,
    conference_day_id int  NOT NULL,
    start_time datetime  NOT NULL,
    end_time datetime  NOT NULL,
    topic text  NOT NULL,
    price money  NOT NULL,
    number_of_seats int  NOT NULL,
    CONSTRAINT Workshops_pk PRIMARY KEY  (workshop_id)
);

-- foreign keys
-- Reference: Companies_Clients (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id);

-- Reference: Conference_day_registration_Conference_day_reservations (table: Conference_day_registration)
ALTER TABLE Conference_day_registration ADD CONSTRAINT Conference_day_registration_Conference_day_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Conference_day_reservations (reservation_id);

-- Reference: Conference_day_registration_Participants (table: Conference_day_registration)
ALTER TABLE Conference_day_registration ADD CONSTRAINT Conference_day_registration_Participants
    FOREIGN KEY (Participant_id)
    REFERENCES Participants (participant_id);

-- Reference: Conference_day_reservations_Clients (table: Conference_day_reservations)
ALTER TABLE Conference_day_reservations ADD CONSTRAINT Conference_day_reservations_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id);

-- Reference: Conference_day_reservations_Conference_days (table: Conference_day_reservations)
ALTER TABLE Conference_day_reservations ADD CONSTRAINT Conference_day_reservations_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id);

-- Reference: Conference_days_Conferences (table: Conference_days)
ALTER TABLE Conference_days ADD CONSTRAINT Conference_days_Conferences
    FOREIGN KEY (conference_id)
    REFERENCES Conferences (Conference_id);

-- Reference: Discounts_Conference_days (table: Early_signup_discounts)
ALTER TABLE Early_signup_discounts ADD CONSTRAINT Discounts_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id);

-- Reference: Participants_Clients (table: Participants)
ALTER TABLE Participants ADD CONSTRAINT Participants_Clients
    FOREIGN KEY (clients_id)
    REFERENCES Clients (id);

-- Reference: Payments_Conference_day_reservations (table: Payments)
ALTER TABLE Payments ADD CONSTRAINT Payments_Conference_day_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Conference_day_reservations (reservation_id);

-- Reference: Workshop_registration_Participants (table: Workshop_registration)
ALTER TABLE Workshop_registration ADD CONSTRAINT Workshop_registration_Participants
    FOREIGN KEY (Participant_id)
    REFERENCES Participants (participant_id);

-- Reference: Workshop_registration_Workshop_reservations (table: Workshop_registration)
ALTER TABLE Workshop_registration ADD CONSTRAINT Workshop_registration_Workshop_reservations
    FOREIGN KEY (reservation_id)
    REFERENCES Workshop_reservations (reservation_id);

-- Reference: Workshop_reservations_Conference_day_reservations (table: Workshop_reservations)
ALTER TABLE Workshop_reservations ADD CONSTRAINT Workshop_reservations_Conference_day_reservations
    FOREIGN KEY (Conference_day_reservations_reservation_id)
    REFERENCES Conference_day_reservations (reservation_id);

-- Reference: Workshop_reservations_Workshops (table: Workshop_reservations)
ALTER TABLE Workshop_reservations ADD CONSTRAINT Workshop_reservations_Workshops
    FOREIGN KEY (workshop_id)
    REFERENCES Workshops (workshop_id);

-- Reference: Workshops_Conference_days (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshops_Conference_days
    FOREIGN KEY (conference_day_id)
    REFERENCES Conference_days (conference_day_id);

-- End of file.

