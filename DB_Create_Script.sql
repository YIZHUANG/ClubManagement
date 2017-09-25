--Case assigment tables

-- Yi Zhuang & Jose Zapata
--11.05.2017

/*DROP TABLE Club;
DROP TABLE Artist;
DROP TABLE Event;
DROP TABLE Payment;
DROP TABLE Account;
*/


CREATE TABLE Club
(
	VenueId INTEGER NOT NULL IDENTITY,
	VenueName VARCHAR(50) NOT NULL,
	Capacity INTEGER NOT NULL,

	CONSTRAINT PK_Venue PRIMARY KEY (VenueId),
	CONSTRAINT UC_Venue UNIQUE (VenueName),
);

CREATE TABLE Artist
(
	ArtistId INTEGER NOT NULL IDENTITY,
	ArtistName VARCHAR(50) NOT NULL,
	SpecialRequest VARCHAR(50) NOT NULL,
	Nationality VARCHAR(50) NOT NULL,
	ArtistPhoneNumber INTEGER NOT NULL,

	CONSTRAINT PK_Artist PRIMARY KEY (ArtistId),
	CONSTRAINT UC_Artist UNIQUE (ArtistName),
);

CREATE TABLE Event
(
	EventId INTEGER NOT NULL IDENTITY,
	EventName VARCHAR(50) NOT NULL,
	SeatNumber INTEGER NOT NULL,
	TicketPrice INTEGER NOT NULL,
	ArtistId INTEGER NOT NULL,
	VenueId INTEGER NOT NULL,
	EventStatus VARCHAR(50) NOT NULL,
	EventDate DATE NOT NULL,
	EventType VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Event PRIMARY KEY (EventId),
	CONSTRAINT UC_Event UNIQUE (EventName),
	CONSTRAINT FK_Event_ArtistId FOREIGN KEY (ArtistId)  REFERENCES Artist(ArtistId),
	CONSTRAINT FK_Event_VenueId FOREIGN KEY (VenueId)  REFERENCES Club(VenueId),
	CONSTRAINT CHK_Event_EventStatus CHECK(EventStatus = 'cancelled' OR EventStatus = 'passed' OR EventStatus = 'active'),
);


CREATE TABLE Booking
(
	bookingNumber INTEGER NOT NULL IDENTITY,
	memo VARCHAR(10) NOT NULL,
	ticketNumber INTEGER NOT NULL,
	eventId INTEGER NOT NULL,
	bookingStatus VARCHAR(50) DEFAULT 'active',
    AmountTobePaid INTEGER ,
	BookingDate DATE default GETDATE(),
	CONSTRAINT PK_Booking PRIMARY KEY (bookingNumber),
	CONSTRAINT UC_Booking UNIQUE (memo),
	CONSTRAINT FK_Booking_EventNumber FOREIGN KEY (eventId)  REFERENCES Event(EventId),
	CONSTRAINT CHK_Booking_BookingStatus CHECK(BookingStatus = 'cancelled'
	OR BookingStatus = 'active' OR BookingStatus = 'sold'),
);

CREATE TABLE Payment
(
	PaymentNumber INTEGER NOT NULL IDENTITY,
	PaymentStatus CHAR(1) NOT NULL,
	BookingNumber INTEGER NOT NULL,

	

	CONSTRAINT PK_Payment PRIMARY KEY (PaymentNumber),
	CONSTRAINT CHK_Payment_PaymentStatus CHECK(PaymentStatus = 'Y' OR PaymentStatus = 'N'),
	CONSTRAINT FK_Payment_BookingNumber FOREIGN KEY (BookingNumber)  REFERENCES Booking(bookingNumber),
);




CREATE TABLE Account
(
	AccountNumber INTEGER NOT NULL,
	Balance	INTEGER DEFAULT 0,
	paymentNumber INTEGER DEFAULT NULL,

	CONSTRAINT PK_Account PRIMARY KEY (AccountNumber),
	CONSTRAINT FK_Account_PaymentNumber FOREIGN KEY (PaymentNumber)  REFERENCES Payment(PaymentNumber),
);
