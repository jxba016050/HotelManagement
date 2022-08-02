DROP table IF EXISTS CityProvince;
DROP table IF EXISTS Postcode;
DROP table IF EXISTS Hotel;
DROP table IF EXISTS Room;
DROP table IF EXISTS Employee;
DROP table IF EXISTS Reception;
DROP table IF EXISTS Manager;
DROP table IF EXISTS Cleaner;
DROP table IF EXISTS Visitor;
DROP table IF EXISTS CreditCard;
DROP table IF EXISTS Reservation;
DROP table IF EXISTS Payment;
DROP table IF EXISTS VisitorReservation;

create Table CityProvince(
	city VARCHAR(20),
	province VARCHAR(2),
	PRIMARY KEY(city)
);

INSERT into CityProvince values ('Vancouver', 'BC');
INSERT into CityProvince values ('Burnaby', 'BC');
INSERT into CityProvince values ('Toronto', 'ON');
INSERT into CityProvince values ('Montreal', 'QC');
INSERT into CityProvince values ('Ottowa', 'ON');


create Table Postcode(
	postcode VARCHAR(7),
	city VARCHAR(10),
	PRIMARY KEY(postcode), 
	FOREIGN KEY(city) REFERENCES CityProvince(city)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

INSERT into Postcode VALUES ('V6Z 2R9', 'Vancouver');
INSERT into Postcode VALUES ('V6C 2W6', 'Vancouver');
INSERT into Postcode VALUES ('V6C 3L5', 'Vancouver');
INSERT into Postcode VALUES ('V6G 1C1', 'Burnaby');
INSERT into Postcode VALUES ('V5H 2W7', 'Vancouver');


CREATE TABLE Hotel(
	name varchar(255),
	address VARCHAR(100),
	postcode VARCHAR(7),
	star_rating INT,
	PRIMARY KEY (name),
	FOREIGN KEY (postcode) REFERENCES Postcode(postcode)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

INSERT INTO Hotel values ('Sheraton Vancouver Wall Centre','1000 Burrard St', 'V5H 2W7', 4 );
INSERT INTO Hotel values ('Fairmont Hotel','900 W Georgia St.', 'V6G 1C1', 4 );
INSERT INTO Hotel values ('Fairmont Hotel Waterfront','900 Canada Pl.', 'V6G 1C1', 5 );
INSERT INTO Hotel values ('Riviera Hotel','1431 Robson St.', 'V6G 1C1', 5 );
INSERT INTO Hotel values ('Hilton','6083 McKay Ave.', 'V6C 2W6', 5 );

CREATE Table Room(
	room_id INT,
	hotel VARCHAR(255),
	type VARCHAR(100),
	price FLOAT,
	PRIMARY KEY(room_id, hotel),
	FOREIGN KEY (hotel) REFERENCES Hotel(name)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
INSERT INTO Room values (101, 'Sheraton Vancouver Wall Centre',  'queen', 120.00);
INSERT INTO Room values (201, 'Sheraton Vancouver Wall Centre', 'queen', 120.00);
INSERT INTO Room values (301, 'Fairmont Hotel', 'king', 120.00);
INSERT INTO Room values (401, 'Fairmont Hotel', 'regular', 120.00);
INSERT INTO Room values (501, 'Riviera Hotel', 'regular', 120.00);
INSERT INTO Room values (502, 'Riviera Hotel', 'regular', 120.00);


create Table Employee(
	id INT ,
	last_name VARCHAR(100),
	first_name VARCHAR(100),
	gender VARCHAR(10),
	phone VARCHAR(11),
	work_in VARCHAR(255),
	PRIMARY KEY(id),
	FOREIGN KEY(work_in) REFERENCES Hotel(name)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);
insert into Employee values (1, 'Angle', 'Liang','F','1112223333', 'Riviera Hotel');

insert into Employee values (2, 'Ken', 'li','F','1112223333', 'Riviera Hotel');

insert into Employee values (3, 'Angle', 'Liang','F','1112223333', 'Sheraton Vancouver Wall Centre');

insert into Employee values (4, 'Jason', 'Green','F','1112223333', 'Sheraton Vancouver Wall Centre');

insert into Employee values (5, 'Kenny', 'Red','F','1112223333', 'Fairmont Hotel');

create table Reception(
	employee_id INT NOT NULL,
	shift DATE,
	FOREIGN KEY (employee_id) REFERENCES Employee(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE, 
	UNIQUE(employee_id, shift)
);

insert into Reception VALUES (1, '2022-01-01');
insert into Reception VALUES (1, '2022-01-02');
insert into Reception VALUES (2, '2022-01-02');
insert into Reception VALUES (3, '2022-01-02');
insert into Reception VALUES (1, '2022-01-03');

create table Manager(
	employee_id INT NOT NULL,
	mange INT,
	FOREIGN KEY (employee_id) REFERENCES Employee(id) 
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (mange) REFERENCES Employee(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	UNIQUE(employee_id, mange)
);

insert into Manager values (1, 2);
insert into Manager values (1, 3);
insert into Manager values (1, 4);
insert into Manager values (1, 5);
insert into Manager values (2, 5);


create Table Cleaner(
	employee_id INT NOT NULL,
	room_id INT,
	hotel VARCHAR(255),
	shift DATE,
	FOREIGN KEY (employee_id) REFERENCES Employee(id), 
	FOREIGN KEY (room_id, hotel) REFERENCES Room(room_id, hotel) 
		ON DELETE SET NULL
		ON UPDATE CASCADE
);
insert into Cleaner VALUES (2, 101, 'Sheraton Vancouver Wall Centre', '2022-01-04');
insert into Cleaner VALUES (2, 201, 'Sheraton Vancouver Wall Centre', '2022-01-04');
insert into Cleaner VALUES (2, 301, 'Fairmont Hotel', '2022-01-04');
insert into Cleaner VALUES (5, 101, 'Sheraton Vancouver Wall Centre','2022-01-04');
insert into Cleaner VALUES (5, 201, 'Sheraton Vancouver Wall Centre', '2022-01-04');

CREATE Table Visitor(
	id INT,
	last_name VARCHAR(100),
	first_name VARCHAR(100),
	phone VARCHAR(11),
	PRIMARY KEY(id)
);

insert into Visitor VALUES (1, 'Jason','Liang','7781118888');
insert into Visitor VALUES (2, 'Kim','Liang','7782228888');
insert into Visitor VALUES (3, 'Jack','Song','7782228889');
insert into Visitor VALUES (4, 'Ken','Lee','7782228899');
insert into Visitor VALUES (5, 'Mickey','White','7782228879');



CREATE Table CreditCard(
	card_number VARCHAR(20),
	date DATE,
	pin INT,
	PRIMARY KEY(card_number)
);
insert into CreditCard values ('1111 2222 3333 4444', '2022-12-03', 678);
insert into CreditCard values ('1111 2222 3333 4445', '2023-12-03', 678);
insert into CreditCard values ('1111 2222 3333 4447', '2022-12-03', 678);
insert into CreditCard values ('1111 2222 3333 4449', '2020-12-03', 111);
insert into CreditCard values ('1111 2222 3333 5555', '2027-01-03', 222);


CREATE Table Reservation(
	id INT ,
	visitor_id INT NOT NULL,
	room_id INT,
	hotel VARCHAR(255),
	reception_id INT,
	checkin DATE,
	checkout DATE,
	PRIMARY KEY(id),
	FOREIGN KEY(visitor_id) REFERENCES Visitor(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(room_id, hotel) REFERENCES Room(room_id, hotel)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	FOREIGN KEY(hotel) REFERENCES hotel(name)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	FOREIGN KEY(reception_id) REFERENCES Employee(id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

insert into Reservation values (1, 1, 101, 'Sheraton Vancouver Wall Centre', 1,'2022-01-07', '2022-05-06');

insert into Reservation values (2, 2, 201, 'Sheraton Vancouver Wall Centre', 2,'2022-01-08', '2022-05-09');

insert into Reservation values (3, 1, 201, 'Sheraton Vancouver Wall Centre', 5, '2022-01-07', '2022-05-06');

insert into Reservation values (4, 1, 301, 'Fairmont Hotel', 1, '2022-01-07', '2022-05-06');

insert into Reservation values (5, 2, 502, 'Riviera Hotel', 1, '2022-01-07', '2022-05-06');


create table VisitorReservation(
	reservation_id INT,
	visitor_id INT,
	UNIQUE(reservation_id, visitor_id),
	FOREIGN KEY(reservation_id) REFERENCES Reservation(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(visitor_id) REFERENCES Visitor(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

insert into VisitorReservation values (1,1);
insert into VisitorReservation values (1,2);
insert into VisitorReservation values (2,1);
insert into VisitorReservation values (2,2);
insert into VisitorReservation values (3,5);

CREATE TABLE Payment(
	reservation_id INT,
	card_number VARCHAR(20),
	employee_id INT,
	PRIMARY KEY (reservation_id),
	FOREIGN KEY(reservation_id) REFERENCES Reservation(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY(card_number) REFERENCES CreditCard(card_number)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	FOREIGN KEY(employee_id) REFERENCES Employee(id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);
insert into Payment values (1, '1111 2222 3333 4444', 1);
insert into Payment values (2, '1111 2222 3333 4445', 2);
insert into Payment values (3, '1111 2222 3333 4444', 1);
insert into Payment values (4, '1111 2222 3333 5555', 1);
insert into Payment values (5, '1111 2222 3333 5555', 1);


