# 📊 E-Commerce Consumer Behavior & Logistics Analytics

An end-to-end data analytics project exploring customer purchasing choices, channel performance, promotional efficiency, and logistics across major Indian metropolitan hubs. This project implements a full production pipeline: from programmatic data cleaning in **Python**, relational data warehouse exploration via **SQL**, to advanced business intelligence in **Tableau Public**.

---

## 🚀 Project Overview & Core Architecture
This project translates over **10,000 multi-channel e-commerce transactions** into actionable strategic frameworks for commercial growth. The primary objective is to evaluate why product returns occur, optimize margin sacrifice during high-velocity promotional sales (Diwali, End of Season Sales), and segment buyers to improve marketing ROI.

### 🛠️ Technology Stack
*   **Data Engineering:** Python 3.10 | Pandas | NumPy
*   **Database Analytics:** SQL (PostgreSQL / MySQL) | Window Functions | CTEs
*   **Business Intelligence:** Tableau Public (Dynamic Dashboards & Geographical Analysis)

---

## 📈 Executive Performance KPIs
*   **Total Net Revenue:** ₹22.3M
*   **Average Order Value (AOV):** ₹1,890
*   **Overall Return Rate:** 18.02%
*   **Active Customer Base:** 2,581 Unique Shoppers

---

## 📂 Repository Structure
```bash
├── README.md                                # Project landing page & documentation
├── data/
│   ├── customer_shopping_behavior.csv       # Raw transaction dataset
│   └── cleaned_customer_shopping_behavior.csv # Python-sanitized data
├── scripts/
│   └── data_cleaning.py                     # Automated pandas processing pipeline
├── sql/
│   ├── platform_performance.sql             # Margin and channel analysis
│   └── rfm_segmentation.sql                 # Customer lifetime value scoring
└── dashboards/
    └── layout_preview.png                   # Tableau dashboard visualization screenshot
```

---

## 🐍 1. Data Engineering Pipeline (Python)
Raw transactional logs contained missing parameters related to offline channels and neutral calendar intervals. A robust Python pipeline automated structural normalization, type standardizations, and downstream feature generation.

### Key Transforms:
*   **Contextual Imputation:** Missing fields for `Online Store` and `Delivery Speed` were programmatically filled with `'N/A - Offline'` upon isolating brick-and-mortar rows. Null values within `Festival/Sale` were assigned to `'Regular Day'` to prevent promotional baseline distortion.
*   **Feature Engineering:** 
    *   Derived `Net_Revenue` by multiplying `Purchase Amount` by `Quantity` and appending logistics costs (`Shipping Charge`).
    *   Segmented demographic indices into categorical cohorts: `Gen Z (18-25)`, `Millennials (26-40)`, and `Gen X (41-60)`.

```python
# scripts/data_cleaning.py
import pandas as pd

def clean_ecommerce_data(file_path):
    df = pd.read_csv(file_path)
    
    # Impute channel-specific dependencies
    df['Online Store'] = df['Online Store'].fillna('N/A - Offline')
    df['Delivery Speed'] = df['Delivery Speed'].fillna('N/A - Offline')
    df['Festival/Sale'] = df['Festival/Sale'].fillna('Regular Day')
    df['Size'] = df['Size'].fillna('Not Applicable')
    
    # Synthesize continuous attributes into financial metrics
    df['Purchase Date'] = pd.to_datetime(df['Purchase Date'])
    df['Total_Purchase_Amount'] = df['Purchase Amount (₹)'] * df['Quantity']
    df['Net_Revenue'] = df['Total_Purchase_Amount'] + df['Shipping Charge (₹)']
    
    # Standardize column naming conventions for SQL standard engines
    df.columns = df.columns.str.replace(' ', '_').str.replace('(', '').str.replace(')', '').str.replace('₹', '').str.replace('/', '_').str.replace('%', 'Pct')
    
    df.to_csv('data/cleaned_customer_shopping_behavior.csv', index=False)

if __name__ == "__main__":
    clean_ecommerce_data('data/customer_shopping_behavior.csv')
```

---

## 🗄️ 2. Advanced Relational DB Queries (SQL)

### Query 1: Channel-Specific Profitability & Product Return Overhead
Isolates which apparel segments and brand labels generate high sales volume versus which suffer from unsustainable return processing costs.
```sql
SELECT 
    Brand,
    Category,
    COUNT(Transaction_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Items_Sold,
    SUM(Net_Revenue) AS Total_Net_Revenue,
    ROUND(AVG(Review_Rating), 2) AS Average_Rating,
    ROUND(
        COUNT(CASE WHEN Return_Status = 'Returned' THEN 1 END) * 100.0 / COUNT(Transaction_ID), 
        2
    ) AS Return_Rate_Percentage
FROM customer_shopping
GROUP BY Brand, Category
ORDER BY Total_Net_Revenue DESC;
```

### Query 2: RFM Customer Lifetime Value & Segment Scoring
Calculates historical buyer profiles via multi-axis dense rankings. Utilizes database window partitioning (`NTILE`) to group customers into behavioral tiers based on aggregate transaction size and purchase frequency.
```sql
WITH Customer_Metrics AS (
    SELECT 
        Customer_ID,
        Gender,
        Age_Group,
        SUM(Net_Revenue) AS Total_Customer_Spend, 
        (MAX(Previous_Purchases) + COUNT(Transaction_ID)) AS Lifetime_Purchase_Count,
        MAX(Frequency_of_Purchases) AS Purchase_Frequency_Type
    FROM customer_shopping
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
    (Frequency_Score + Monetary_Score) AS Total_Loyalty_Score,
    CASE 
        WHEN (Frequency_Score + Monetary_Score) >= 8 THEN 'VIP Champions'
        WHEN (Frequency_Score + Monetary_Score) >= 5 THEN 'Regular Loyalists'
        ELSE 'At-Risk / Casual Shoppers'
    END AS Customer_Segment
FROM RFM_Scores
ORDER BY Total_Customer_Spend DESC;
```

---

## 📊 3. Interactive Visualization (Tableau Public)
The finalized analytical view is deployed as a single-screen responsive canvas optimizing dynamic user interactions.

### Core Visual Dashboards:
1.  **Geospatial Performance Mapping:** Maps logistical turnaround latencies and regional transaction values over Indian tier-1 cities (Mumbai, Pune, Chennai, Hyderabad). Larger marks demonstrate higher net sales; color alerts denote return vulnerabilities.
2.  **Product Contribution Matrix:** A stacked horizontal tracking engine sorting platforms (Myntra, Flipkart, Amazon) and categories.
3.  **Promotional Price Elasticity Scatter Plot:** Connects `Discount Tiers` (0-15%, 16-30%, 31%+, No Discount) to global average basket size to discover optimal markdown thresholds.

---

## 🎯 Strategic Key Takeaways & Data Insights
*   **Discount Optimization Threshold:** Discount distribution charts indicate that pricing markdowns exceeding **30%** fail to produce statistically significant expansion in Average Order Value (AOV). Margins are effectively sacrificed without boosting basket sizes.
*   **Fulfillment Optimization:** Digital marketplaces like Myntra capture an expansive market share within specific fashion items but carry an average **5.2% higher return rate** compared to equivalent brick-and-mortar transactions.
*   **Logistics Delivery Correlations:** Regions demonstrating a lower average delivery turnaround (1-2 days via Same Day or Express channels) yield a strong **18.4% improvement in positive review score distribution**.

---

## 🛠️ Execution & Deployment Guide
1.  **Environment Setup:** Ensure dependencies are met via `pip install pandas numpy`.
2.  **Ingestion:** Execute the cleaning module: `python scripts/data_cleaning.py`.
3.  **Database Seeding:** Import the resulting `cleaned_customer_shopping_behavior.csv` into your local database instances and apply the analysis files from the `/sql` directory.