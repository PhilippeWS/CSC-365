DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS receipts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS goods;

CREATE TABLE customers(
  CId INTEGER PRIMARY KEY,
  Lastname VARCHAR(32),
  Firstname VARCHAR(32)
);

CREATE TABLE goods(
  GId VARCHAR(32) PRIMARY KEY,
  Flavor VARCHAR(32),
  Food VARCHAR(32),
  Price DOUBLE,
  
  CONSTRAINT UniqueFlavorFood UNIQUE (Flavor, Food)
);

CREATE TABLE receipts(
  RNumber INTEGER PRIMARY KEY,
  SaleDate DATE,
  Customer INTEGER,
  
  FOREIGN KEY ReceiptsCustomer_CustomerCId (Customer) REFERENCES customers(CId)
);


CREATE TABLE items(
  Receipt INTEGER,
  Ordinal INTEGER,
  Item VARCHAR(32) NOT NULL,
  
  PRIMARY KEY (Receipt, Ordinal),
  FOREIGN KEY CustomersReceipt_ReceiptRNumber (Receipt) REFERENCES receipts(RNumber),
  FOREIGN KEY CustomersItem_GoodsGId (Item) REFERENCES goods(GId)
);