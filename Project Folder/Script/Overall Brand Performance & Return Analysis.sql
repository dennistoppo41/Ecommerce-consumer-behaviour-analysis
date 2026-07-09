select
Brand,
Category,
count(Transaction_ID) as Total_Orders,
sum(Quantity) as Total_Items_Sold,
sum(Net_Revenue_) as Total_Net_Revenue,
round(avg(Review_Rating), 2) as Average_Rating,
round(
  count(case when Return_Status = 'Returned' then 1 end) * 100.0 / count(Transaction_ID), 2
) as Return_Rate_Percentage
from fourth-groove-499909-u2.Ecommerce.cust_behaviour
group by Brand, Category
Order by Total_Net_Revenue DESC;