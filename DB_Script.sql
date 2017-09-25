Create function TotalTickets(@EventId as int)
	Returns Int
	As
	Begin
	Return (select sum(ticketNumber)from Booking where eventId=@EventId)
	End;

Create Function ReturnSeatNo(
@EventId as Integer)
Returns Int
As
Begin
Return (Select SeatNumber from Event where EventId=@EventId) 
End;

alter table Booking  
Add Constraint Checkoverbooking check(BIT_SWD03_42.TotalTickets(eventId) <=BIT_SWD03_42.ReturnSeatNo(eventId))

--these 3 queries are for creating the constraint to prevent overbooking. And replace the BIT_SWD03_42 with the name of your database.

Create function getTicketNumberPerbooking(@bookingnumber as int)
returns int
as 
Begin
Return (Select ticketNumber from Booking where bookingNumber=@bookingnumber)
End 

Create function getTicketPrice(@eventId as int)
returns int
as 
Begin
Return (Select TicketPrice from Event where EventId=@eventId)
End 


Create function totalAmoutTobePaid(@bookingnumber as int,@eventId as int)
returns int
as
Begin
return BIT_SWD03_42.getTicketNumberPerbooking(@bookingnumber) *BIT_SWD03_42.getTicketPrice(@eventId)
End;


--These 2 queries calculates the total amount of ticket price the buyer needs to pay for in a booking. 

Create PROCEDURE BookingTicket(@memo as VARCHAR(10),@ticketnumber as int,@eventID as int)
AS
BEGIN

    INSERT INTO Booking(memo,ticketNumber,eventId) VALUES
	(@memo,@ticketnumber,@eventID);
END

--This is to book a ticket as well as showing the total amount of ticket price the buyer needs to pay for in a booking automatically combined with the trigger which is shown later in this script.


Create PROCEDURE CancelBooking(@bookingnumber as int)
AS
BEGIN

update Booking
Set BookingStatus = 'cancelled' where bookingNumber=@bookingnumber and not bookingStatus='sold'

END
--this is to cancel a booking.


Create PROCEDURE ChangeNumberOfTicket(@bookingnumber as int,@NumberOfTickets as int)
AS
BEGIN
update Booking
Set ticketNumber =@NumberOfTickets  where bookingNumber=@bookingnumber and not bookingStatus='sold'
END

--This is to change the number of tickets in a booking.


Create PROCEDURE CancelEvent(@EventId as int)
AS
BEGIN
	
Update Event
Set EventStatus='cancelled' where EventId=@EventId
END
--This is to cancel an event.

--TRIGGERS

--1) This trigger changes the status to booking when the tickets are purchased
CREATE TRIGGER Payed_Trigger
ON Payment
AFter Update
AS
	Begin
	
	Update Booking 
	Set bookingStatus='sold'
	from Booking
	JOIN Payment ON (Payment.BookingNumber = Booking.bookingNumber)
	 where Payment.PaymentStatus='Y'


End;

--TEST TRIGGER
--UPDATE Payment SET PaymentStatus = 'Y' WHERE BookingNumber = 1

--2) Remove the unpurchased bookings from DB of the past events

CREATE TRIGGER Event_trigger
ON Event
AFTER UPDATE
AS
BEGIN
	Delete Booking from Booking 
	 JOIN Event ON (Event.EventId = Booking.eventId)
	Where Event.EventStatus='passed' 
END;

--SELECT * FROM Booking
--Test trigger
--UPDATE Event SET EventStatus = '' WHERE EventId =1


--3)  Remove unpurchased tickers after 3 days of booking

CREATE TRIGGER RemoveBooking_Trigger
ON Booking
AFTER INSERT
AS
BEGIN
	
	DELETE Booking FROM Booking WHERE DATEPART(DD,GETDATE())- DATEPART(DD,BookingDate) >= 3
	

END;




	--total tickets booked for each venue 	
	--SELECT SUM(ticketNumber) AS 'totalTickets',VenueId FROM Booking JOIN Event ON (Event.eventID = Booking.eventId)  GROUP BY VenueId





-- trigger to show the total price amount for each booking automatically 
CREATE TRIGGER ShowTotal_Trigger
ON Booking
AFTER INSERT
AS
BEGIN
	UPDATE Booking SET AmountTobePaid = Booking.ticketNumber * Event.TicketPrice FROM Booking JOIN Event ON (Event.EventId = Booking.EventId)

END;

CREATE TRIGGER ShowTotal_Trigger_Update
ON Booking
AFTER UPDATE
AS
BEGIN
	UPDATE Booking SET AmountTobePaid = Booking.ticketNumber * Event.TicketPrice FROM Booking JOIN Event ON (Event.EventId = Booking.EventId)

END;

--TEST
--SELECT * FROM Booking

--INSERT INTO Booking (memo,ticketNumber,eventId,bookingStatus) VALUES
--('1112229992',10,2,'active')


	--TRIGGER used to refund in case of the event getting cancelled
CREATE TRIGGER Update_acc_Trigger
ON Event
AFTER UPDATE
AS
BEGIN
	UPDATE Account SET Balance = Balance - Booking.ticketNumber * Event.TicketPrice FROM Booking JOIN Event ON (Event.EventId = Booking.EventId)
	 
	WHERE Event.EventStatus = 'cancelled'
END;

--Trigger used to cancel a booking after refund is made to the clients booking ,after the event is cancelled
CREATE TRIGGER Update_Booking_Trigger
ON Event
AFTER UPDATE
AS
BEGIN
	UPDATE Booking SET bookingStatus = 'cancelled' FROM Event JOIN Booking ON (Booking.eventId = Event.EventId) 
	WHERE Event.EventStatus = 'cancelled' 
END;

--Test trigger
--UPDATE Event SET EventStatus = 'cancelled' WHERE Event.EventId = 1


--Trigger which adds the amount of payment made from the booking to the club balance 
CREATE TRIGGER AddBalance_Trigger
ON Payment
AFTER UPDATE
AS
BEGIN
	UPDATE Account SET Balance = Balance + Booking.AmountTobePaid FROM Booking JOIN   Payment ON (Payment.BookingNumber = Booking.bookingNumber)
	WHERE Payment.PaymentStatus = 'Y'
END;

--TEST trigger 
--UPDATE Booking SET AmountTobePaid = 200 WHERE bookingNumber = 1
--UPDATE Payment SET PaymentStatus = 'Y' WHERE bookingNumber = 1
--SELECT * FROM Account



-- TEST SCRIPTS

--1)
SELECT * FROM Event WHERE Month(EventDate) = 6;

--2)
SELECT * FROM Event WHERE Month(EventDate) = 5 AND EventType LIKE 'theater';

--3)
SELECT ArtistPhoneNumber FROM Artist WHERE ArtistName = 'Saara Aalto';

--4)
SELECT EventDate,EventType,Artist.SpecialRequest FROM Artist JOIN Event ON (Event.ArtistId = Artist.ArtistId) WHERE ArtistName LIKE 'ZZ Top';

--5)
SELECT SUM(ticketNumber) AS 'Sold Tickets',EventName, ArtistName FROM Event
JOIN Artist ON (Artist.ArtistId = Event.ArtistId) 
JOIN Booking ON (Booking.EventId = Event.EventId) 
WHERE EventDate = '12/06/2017' AND ArtistName = 'Jorma Uotinen' AND BookingStatus = 'active'
GROUP BY ArtistName,EventName;

 

--6)
SELECT SeatNumber- ticketNumber  AS 'Tickets left',EventName FROM Event 
JOIN Artist ON (Artist.ArtistId = Event.ArtistId) 
JOIN Booking ON (Booking.EventId = Event.EventId) 
WHERE EventDate = '12/11/2017'

--7) --How much money has kuru got from sold tickets this year.
--Note, run the update queries first before excuting the Select query

SELECT sum(AmountTobePaid) as 'Balance' ,BookingDate from Booking JOIN Payment ON (Payment.bookingNumber=Booking.bookingNumber) 
WHERE Booking.bookingStatus='sold' and Payment.PaymentStatus='Y' and datepart(yy,Booking.BookingDate)=2017
Group by BookingDate

Update Booking
Set bookingStatus='sold' where bookingNumber=1
SELECT * FROM Account
Update Payment
Set PaymentStatus='Y' where BookingNumber=1
SELECT * FROM Payment
update Account
Set paymentNumber=1 where AccountNumber=1

UPDATE Payment SET PaymentStatus = 'Y' WHERE bookingNumber = 1




