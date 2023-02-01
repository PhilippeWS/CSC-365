--Bakery-1
UPDATE goods SET Price = Price - 2 WHERE (Flavor='Lemon' || Flavor='Napoleon') && Food='Cake';


--Bakery-2
UPDATE goods SET Price = Price*1.15 WHERE (Flavor='Apricot' || Flavor='Chocolate') && Price<5.95;


--Bakery-3
DROP TABLE IF EXISTS payments;
CREATE TABLE payments(
    Receipt INTEGER,
    Amount DECIMAL(5,2),
    PaymentSettled DATETIME,
    PaymentType VARCHAR(32),
    
    PRIMARY KEY (Receipt, Amount, PaymentType),
    FOREIGN KEY fk_ReceiptNo_receiptsRNumber (Receipt) REFERENCES receipts(RNumber)
);


--Bakery-4
CREATE TRIGGER paymentPreventOnDay BEFORE INSERT ON items
    FOR EACH ROW
    BEGIN
        DECLARE desiredSaleDate INTEGER;
        DECLARE desiredGood VARCHAR(32);
        DECLARE desiredFlavor VARCHAR(32);
        
        SELECT DAYOFWEEK(saleDate) INTO desiredSaleDate FROM receipts WHERE RNumber=NEW.Receipt;
        SELECT Food INTO desiredGood FROM goods WHERE GId = NEW.Item;
        SELECT Flavor INTO desiredFlavor FROM goods WHERE GId = NEW.Item;
        
        IF((desiredFlavor = 'Almond' OR desiredGood = 'Meringue') AND (desiredSaleDate = 1 OR desiredSaleDate = 7)) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Products cannot be sold on a Saturday and Sunday';
        END IF;
    END;


--Airlines-1
CREATE TRIGGER noSameAndDestinationFlight BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
    if(NEW.SourceAirport = NEW.DestAirport) then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source and Destination are the same';
    end if;
END;


--Airlines-2
ALTER TABLE airlines ADD Partner VARCHAR(32) UNIQUE;
ALTER TABLE airlines ADD FOREIGN KEY fk_Abb_Partner (Partner) REFERENCES airlines(Abbreviation);

CREATE TRIGGER partnerInsertConstraints BEFORE INSERT ON airlines
    FOR EACH ROW
        BEGIN
            IF(NEW.Partner = NEW.Abbreviation) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid Entry';
            END IF;    
        END;
        
UPDATE airlines SET Partner = 'Southwest' WHERE Airline = 'JetBlue Airways';
UPDATE airlines SET Partner = 'JetBlue' WHERE Airline = 'Southwest Airlines';


--KatzenJammer-1
ALTER TABLE Instruments MODIFY Instrument VARCHAR(255);

UPDATE Instruments SET Instrument = 'awesome bass balalaika' WHERE Instrument = 'bass balalaika';
UPDATE Instruments SET Instrument = 'acoustic guitar' WHERE Instrument = 'guitar';


--KatzenJammer-2
DELETE FROM Vocals WHERE Bandmate != 1 || Type = 'lead';