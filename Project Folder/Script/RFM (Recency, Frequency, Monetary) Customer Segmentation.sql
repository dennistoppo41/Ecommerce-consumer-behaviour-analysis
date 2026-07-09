WITH Customer_Metrics AS (
    SELECT 
        Customer_ID,
        Gender,
        Age_Group,
        -- Monetary: Total spent by this customer in the dataset
        SUM(Net_Revenue_) AS Total_Customer_Spend, 
        -- Frequency: Historical purchases + current transaction counts
        (MAX(Previous_Purchases) + COUNT(Transaction_ID)) AS Lifetime_Purchase_Count,
        MAX(Frequency_of_Purchases) AS Purchase_Frequency_Type
    FROM fourth-groove-499909-u2.Ecommerce.cust_behaviour
    GROUP BY Customer_ID, Gender, Age_Group
),
RFM_Scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Lifetime_Purchase_Count ASC) AS Frequency_Score,
        NTILE(5) OVER (ORDER BY Total_Customer_Spend ASC) AS Monetary_Score
    FROM Customer_Metrics
)
SELECT 
    Customer_ID,
    Gender,
    Age_Group,
    Total_Customer_Spend,
    Lifetime_Purchase_Count,
    Purchase_Frequency_Type,
    (Frequency_Score + Monetary_Score) AS Total_Loyalty_Score,
    CASE 
        WHEN (Frequency_Score + Monetary_Score) >= 8 THEN 'VIP Champions'
        WHEN (Frequency_Score + Monetary_Score) >= 5 THEN 'Regular Loyalists'
        ELSE 'At-Risk / Casual Shoppers'
    END AS Customer_Segment
FROM RFM_Scores
ORDER BY Total_Customer_Spend DESC;