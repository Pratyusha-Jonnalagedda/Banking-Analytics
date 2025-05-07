use bankanalytics;
select * from debitcredit;

-- Allow loading files 
set global local_infile = true;

SET GLOBAL local_infile = 1;

drop table debitcredit;
create table debitcredit
(Customer_ID varchar (200),
Customer_Name varchar (200),
Account_Number bigint,
Transaction_Date date,
Transaction_Type varchar (15),
Amount int,
Balance int,
Description_Transaction varchar (150),
Branch_Name varchar (100),
Transaction_Method varchar (100),
Currency varchar (4),
Bank_Name varchar (100),
Transaction_Week smallint,
High_Risk_Value boolean);


SHOW VARIABLES LIKE "secure_file_priv";

