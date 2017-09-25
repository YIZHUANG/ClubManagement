--Index script
--
--Created by YI ZHUANG & Jose Zapata 15.05.2017


CREATE UNIQUE NONCLUSTERED INDEX ix_ArtistPhone ON Artist(ArtistPhoneNumber);

CREATE UNIQUE INDEX ix_PaymentNumber ON Account(paymentNumber);

CREATE NONCLUSTERED INDEX ix_eventId ON Booking(eventId);