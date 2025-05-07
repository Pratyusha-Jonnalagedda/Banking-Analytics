create schema bankanalytics;

Use bankanalytics;

Create table loananalytics
(AccountID varchar (175), Age varchar (10), BHName Varchar(100), BankName varchar(15), BranchName varchar(30), Caste Varchar(15),
CenterID int, City varchar(100), ClientID int, ClientName varchar(350), CloseClient varchar(50), ClosedDate date, CreditOfficerName varchar (350),
DateofBirth date, Disb_by varchar(350), DisbursementDate_Years varchar (50), GenderID varchar(25), HomeOwnership varchar(25),
LoanStatus varchar(25), LoanTransferDate varchar(25), NextMeetingDate date, Grade varchar(2), PurposeCategory varchar(50),
RegionName varchar (100), Religion varchar(50), VerificationStatus varchar(50), StateName varchar (50), TransferLogic varchar(50),
IsDelinquentLoan varchar(50), IsDefaultLoan varchar(50), Age_T int, Delinq2yrs varchar(50), LoanAmount decimal (10,2),
FundedAmount decimal (10,2), FundedAmountInv decimal (10,2), Term varchar (20), IntRate decimal(2,2), TotalPymnt decimal (10,2),
TotalPymntInv decimal (10,2), TotalRecPrncp decimal (10,2), TotalFees decimal(2,2), TotalRrecInt decimal(10,2), TotalRecLateFee decimal (4,2),
Recoveries decimal(10,2), CollectionRecoveryFee decimal(4,2), DisbursementDate date, TermofLoan int, LoanMaturityDate date);

select * from loananalytics;

SET GLOBAL local_infile = 1;

SET GLOBAL local_infile=ON;
SELECT @@secure_file_priv;
SELECT @@sql_mode;

LOAD DATA LOCAL INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Loan_Data_Final.csv"
into table loananalytics
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(AccountID, Age, BHName, BankName, BranchName, @Caste, CenterID, City, ClientID, ClientName, CloseClient, @ClosedDate, 
CreditOfficerName, @DateofBirth, @Disb_by, DisbursementDate_Years, GenderID, @HomeOwnership, LoanStatus, LoanTransferDate,
NextMeetingDate, Grade, PurposeCategory, RegionName, Religion, @VerificationStatus, StateName, TransferLogic, 
IsDelinquentLoan, IsDefaultLoan, @Age_T, @Delinq2yrs, LoanAmount, FundedAmount, FundedAmountInv, Term, IntRate, TotalPymnt,
TotalPymntInv, TotalRecPrncp, TotalFees, TotalRrecInt, TotalRecLateFee, Recoveries, CollectionRecoveryFee, 
DisbursementDate, TermofLoan, LoanMaturityDate)
SET  Caste = nullif(@Caste, ' '),
DateofBirth = Nullif (@DateofBirth,' '),
Disb_by = nullif(@Disb_by,' '),
HomeOwnership = nullif(@HomeOwnership,' '),
VerificationStatus = nullif(@VerificationStatus,' '),
Age_T = nullif(@Age_T, ' '),
Delinq2yrs = nullif(@Delinq2yrs, ' ');

select count(*) from loananalytics;
Select * from loananalytics;

-- KPIS --
-- 1. Total Loan Amount Funded --
Select concat(round(sum(FundedAmount)/1000000,2)," ","M") as Total_Loan_Amount from loananalytics;

-- 2. Total Loans--
Select count(AccountID) as Total_Loans from loananalytics;

-- 3. Total Collection --
Select concat(round(sum(TotalPymnt) / 1000000, 2), 'M') as Total_Collection from loananalytics;

-- 4. Total Interest --
Select concat(Round(Sum(TotalRrecInt) / 1000000, 2), 'M') as Total_Interest from loananalytics;

-- 5. Branch-Wise (Interest, Fees, Total Revenue) --
Select BranchName, concat(ROUND(SUM(TotalRrecInt)/1000000, 2), 'M') AS Interest, ROUND(SUM(TotalFees + TotalRecLateFee + CollectionRecoveryFee)) 
as Fees, concat(ROUND(SUM(TotalPymnt)/1000000, 2), 'M') AS Total_Revenue
from loananalytics GROUP BY BranchName;

-- 6. State-Wise Loan --
Select StateName, Count(AccountID) as State_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded from loananalytics
group by StateName
order by State_Wise_Distribution;
-- or TOP 10 branches --
Select StateName, Count(AccountID) as State_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded from loananalytics
group by StateName
order by State_Wise_Distribution desc limit 10;

-- 7. Religion-Wise Loan --
Select Religion, Count(AccountID) as Religion_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded from loananalytics
group by Religion;

-- 8. Product Group-Wise Loan --
Select PurposeCategory, count(PurposeCategory) as ProductGroup_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded from loananalytics
group by PurposeCategory order by Amount_Funded desc;

-- 9. Disbursement Trend --
Select DisbursementDate_Years as Year, COUNT(AccountID) as Count_of_Loans from loananalytics 
group by Year;

-- 10. Grade-Wise Loan --
Select Grade, count(Grade) as Grade_Wise_Distribution, concat(round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded from loananalytics
group by Grade;

-- 11. Count of Default Loan --
Select count(AccountID) as Count_of_Default_Loans from loananalytics
where IsDefaultLoan = 'Y';

-- 12. Count of Delinquent Clients --
Select count(AccountID) as Count_of_Delinquent_Loans from loananalytics
where IsDelinquentLoan = 'Y';

-- 13. Delinquent Loans Rate --
Select round((sum(case when IsDelinquentLoan = 'Y' then 1 else 0 end) / count(*) * 100), 2) as Delinquent_Loan_Rate
from loananalytics;

-- 14. Default Loan Rate --
Select round((sum(case when IsDefaultLoan = 'Y' then 1 else 0 end) / count(*) * 100), 2) as Default_Loan_Rate
from loananalytics;

-- 15. Loan Status-Wise Loan --
Select LoanStatus, count(AccountID) as LoanStatus_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') 
as Amount_Funded from loananalytics
group by LoanStatus;

-- 16. Age Group-Wise Loan --
Select Age, count(Age) as Age_Wise_Distribution, concat(Round(sum(FundedAmount)/1000000, 2), 'M') as Amount_Funded
from loananalytics
group by Age;

-- 17. No Verified Loan --
Select count(VerificationStatus) as Non_Verified_Loan from loananalytics
where VerificationStatus = 'Not Verified';

-- 18. Loan Maturity
Select AccountID, ClientName, DisbursementDate, TermofLoan as Term_in_Months,
DATE_ADD(DisbursementDate, interval TermofLoan month) as Date_of_Loan_Maturity from loananalytics
where DisbursementDate is not null and TermofLoan is not null;
