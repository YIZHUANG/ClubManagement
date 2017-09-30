# ClubManagement
Creating a sql database for a club with the functions of booking/cancelling/refunding tickets etc, by using stored procedure/User defined functions/triggers.




Background:
1.The Kuru club has two venues to hold its events. One is holds up to 400 people while the smaller one holds up to 80 people. 
2. When a client makes a booking he/she should get a unique booking number. 
3.The booked tickets should still be purchased at Kuru Library within three days from booking.
5. Tickets for the same event are the same price.
6. The Club has an extensive registry of artists with their information such as special requests.


Functions of the database:

1.Booking a ticket
2. Cancelling a ticket booking
3. Changing the number of tickets in a booking
4. Changing the status of booking to sold when tickets are purchased (the booking is payed for)
5. Removing the unpurchased bookings from the database after three days from booking
6. Removing the unpurchased bookings of the past events from the database
7. Cancelling an event (in extreme exceptional cases)
8. Refunding a client in case of a cancelled event.
9.Do not allow overbooking.(Tickets<= the number of people that the venue can hold up to ).
10.If the event is cancelled, the client can receive a refund of the amount paid for the ticket. The refund is given in person at Kuru Library.
11.Once the tickets are purchased, they can neither be changed nor refunded (except for event cancellation).
12.The number of tickets in a booking can be changed, unless the tickets are already purchased.
13.A booking can be cancelled, unless it has already been already purchased (payed for).
14.A booking can only contain tickets to one event.


