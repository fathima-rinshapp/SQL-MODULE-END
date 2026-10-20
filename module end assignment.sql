use ecomm;
-- DATA CLEANING --
-- mean --
set @mean_warehousetohome = (select round(avg(warehousetohome )) from customer_churn);
set @mean_hourspendonapp = (select round(avg(hourspendonapp )) from customer_churn);
set @mean_OrderAmountHikeFromlastYear = (select round(avg(OrderAmountHikeFromlastYear )) from customer_churn);
set @mean_DaySinceLastOrder = (select round(avg(DaySinceLastOrder )) from customer_churn);
select @mean_warehousetohome;
set sql_safe_updates=0;
UPDATE customer_churn SET warehousetohome = @mean_warehousetohome 
WHERE warehousetohome is null;
UPDATE customer_churn SET hourspendonapp = @mean_hourspendonapp
 WHERE hourspendonapp is null;
UPDATE customer_churn SET OrderAmountHikeFromlastYear = @mean_OrderAmountHikeFromlastYear
 WHERE OrderAmountHikeFromlastYear is null;
UPDATE customer_churn SET DaySinceLastOrder = @mean_DaySinceLastOrder 
WHERE DaySinceLastOrder is null;
-- mode --
select tenure,count(*) from customer_churn 
group by tenure order by count(*) desc limit 1;
select CouponUsed,count(*) from customer_churn 
group by CouponUsed order by count(*) desc limit 1;
select OrderCount,count(*) from customer_churn 
group by OrderCount order by count(*) desc limit 1;
set sql_safe_updates=0;
UPDATE customer_churn SET tenure=1 WHERE tenure is null;
UPDATE customer_churn SET CouponUsed = 1  WHERE CouponUsed is null;
UPDATE customer_churn SET OrderCount =2 WHERE OrderCount is null;
-- outlier --
delete from customer_churn
 where warehousetohome>100;

UPDATE customer_churn
SET PreferredLoginDevice = REPLACE(PreferredLoginDevice, 'Phone', 'Mobile Phone')
WHERE PreferredLoginDevice LIKE '%Phone%' AND PreferredLoginDevice != 'Mobile Phone';
UPDATE customer_churn
SET Preferedordercat = REPLACE(Preferedordercat, 'Mobile', 'Mobile Phone')
WHERE Preferedordercat LIKE '%Mobile%' AND Preferedordercat != 'Mobile Phone';

UPDATE customer_churn 
SET PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'COD', 'Cash on Delivery') 
WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn 
SET PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'CC', 'Credit Card') 
WHERE PreferredPaymentMode = 'CC';
set sql_safe_updates=1;

-- DATA TRANSFORMATION --
-- COLUMN RENAMING --
ALTER TABLE CUSTOMER_CHURN RENAME COLUMN PreferedOrderCat to PreferredOrderCat;
ALTER TABLE CUSTOMER_CHURN RENAME COLUMN HourSpendOnApp to HoursSpentOnApp;
-- CREATING NEW COLUMN --
ALTER TABLE CUSTOMER_CHURN ADD COLUMN ComplaintReceived VARCHAR(10);
ALTER TABLE CUSTOMER_CHURN ADD COLUMN ChurnStatus VARCHAR(20);
update CUSTOMER_CHURN set  ComplaintReceived= case 
when complain=1 then 'YES' else 'NO' END;
update CUSTOMER_CHURN set  ChurnStatus= case 
when churn=1 then 'CHURNED' else 'ACTIVE' END;
set sql_safe_updates=1;
-- COLUMN DROPPING--
ALTER TABLE CUSTOMER_CHURN DROP COLUMN CHURN;
ALTER TABLE CUSTOMER_CHURN DROP COLUMN COMPLAIN;

-- DATA EXPLORATION AND ANALYSIS --
select count(customerid) from customer_churn where churnstatus="churned";
select count(customerid) from customer_churn where churnstatus="active";
select avg(tenure) from customer_churn where churnstatus="churned";
select sum(cashbackamount) from customer_churn where churnstatus="churned";
select (sum(case when complaintreceived ='yes' then 1 else 0 end) * 100/count(*)) 
from customer_churn where churnstatus="churned";
select  citytier,count(*) as customer_churned from customer_churn where churnstatus="churned" 
and preferredordercat='laptop & accessory' group by citytier
 order by customer_churned desc limit 1;
 select preferredpaymentmode,count(customerid) as customer_count from customer_churn where churnstatus="active"
 group by preferredpaymentmode order by customer_count desc limit 1;
 select sum(orderamounthikefromlastyear) as hike from customer_churn
 where maritalstatus="single" and preferredordercat="mobile phone";
 select round(avg(numberofdeviceregistered)) as registered_count from customer_churn
 where preferredpaymentmode='upi';
 select citytier,count(customerid) as customer_count from customer_churn 
 group by citytier order by customer_count desc limit 1;
 select gender,sum(couponused) as coupon_count from customer_churn 
 group by gender order by coupon_count desc limit 1;
 select preferredordercat,count(customerid) as customer_count,max(hoursspentonapp) as maximum_hours 
 from customer_churn group by preferredordercat ;
 select PreferredPaymentMode,sum(ordercount) as totalordercount,
 max(satisfactionscore) as maximum_satisfactory_score from customer_churn
 where PreferredPaymentMode ="credit card";
 select avg(satisfactionscore) as avg_satisscore_of_complained from customer_churn
 where complaintreceived ='yes';
select distinct preferredordercat,count(couponused) from customer_churn
 where couponused > 5 group by preferredordercat;
select preferredordercat,avg(cashbackamount) as avg_cashback from customer_churn
group by preferredordercat order by avg_cashback desc limit 3;
select preferredpaymentmode,round(avg(tenure)) as avg_tenure,sum(ordercount) as 
total_orders from customer_churn group by preferredpaymentmode having 
avg_tenure=10 and total_orders>500;
select case
 when warehousetohome <=5
 then"very close distance"
 when warehousetohome <=10
 then 'close distance'
 when warehousetohome<=15
 then'moderate distance'
else 'far distance'
end as distancecategory,churnstatus,count(*) as customer_count from customer_churn
group by distancecategory,churnstatus order by distancecategory;
select * from customer_churn where maritalstatus='married' and citytier=1 and 
ordercount>(select avg(ordercount) from customer_churn);

-- Create table
CREATE TABLE customer_returns (
  ReturnID INT PRIMARY KEY,
  CustomerID INT,
  ReturnDate DATE,
  RefundAmount INT
);

-- Insert data
INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
SELECT * FROM customer_returns;
SELECT 
  c.*, 
  r.returnid, r.returndate, r.refundamount,r.customerid
FROM customer_churn c
 right JOIN customer_returns r ON c.Customerid = r.Customerid
WHERE c.ChurnStatus = 'churned' 
  AND c.ComplaintReceived = 'Yes';

