SELECT 
    Festival_Sale,
    CASE 
        WHEN Discount_Pct = 0 THEN '0% No Discount'
        WHEN Discount_Pct > 0 AND Discount_Pct <= 15 THEN '1-15% Low Discount'
        WHEN Discount_Pct > 15 AND Discount_Pct <= 40 THEN '16-40% Medium Discount'
        ELSE '41%+ Heavy Discount'
    END AS Discount_Tier,
    COUNT(Transaction_ID) AS Total_Transactions,
    ROUND(AVG(Purchase_Amount_), 2) AS Avg_Item_Price,
    ROUND(AVG(Total_Purchase_Amount_), 2) AS Avg_Order_Value,
    SUM(Total_Purchase_Amount_) AS Group_Revenue
FROM fourth-groove-499909-u2.Ecommerce.cust_behaviour
GROUP BY Festival_Sale, Discount_Tier
ORDER BY Festival_Sale, Discount_Tier;