--Viewing tables
select * from user_data ud;
select * from transaction_line_final tlf ;
select count(*) from transaction_line_final tlf ;

--Summary of active vs closed accounts.
SELECT "ACCOUNT_STATUS" , COUNT(*) AS Account_Count
FROM transaction_line_final 
GROUP BY "ACCOUNT_STATUS";

--Breakdown of account types (e.g., loans, credit cards) and their current balances.
SELECT "ACCOUNT_CATEGORY", COUNT("ACCOUNT_CATEGORY") AS Total_Accounts, 
SUM("ACCOUNT_BALANCE") AS Total_Balance
FROM transaction_line_final
GROUP BY "ACCOUNT_CATEGORY";

--Analysis of loan amounts vs. account balances.
SELECT "ACCOUNT_BALANCE",round(avg("SANCTIONED_AMOUNT")) AS Loan_Amount
FROM transaction_line_final group by "ACCOUNT_BALANCE" order by "ACCOUNT_BALANCE" desc;

--overview of the closure percentages for different loan types by ownership type (Individual vs Joint Account)
SELECT 
    "ACCOUNT_CATEGORY",
    "OWNERSHIP_TYPE",
    COUNT(*) AS Total_Accounts,
    SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) AS Closed_Accounts,
    ROUND((SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS Closure_Percentage
FROM 
    transaction_line_final
GROUP BY 
    "ACCOUNT_CATEGORY", "OWNERSHIP_TYPE";
   
--Let’s start by segmenting customers based on FICO scores and account categories to see the distribution.
SELECT 
    "FICO_SCORE",
    "ACCOUNT_CATEGORY",
    COUNT(*) AS Total_Customers
FROM 
    transaction_line_final
GROUP BY 
    "FICO_SCORE", "ACCOUNT_CATEGORY"
ORDER BY 
    "FICO_SCORE", "ACCOUNT_CATEGORY";
   
SELECT
    FICO_Segment,
    COUNT(*) AS Customer_Count
FROM
    (SELECT
        CASE
            WHEN "FICO_SCORE" BETWEEN 300 AND 549 THEN 'Very Poor'
            WHEN "FICO_SCORE" BETWEEN 550 AND 649 THEN 'Poor'
            WHEN "FICO_SCORE" BETWEEN 650 AND 749 THEN 'Fair'
            WHEN "FICO_SCORE" BETWEEN 750 AND 849 THEN 'Good'
            WHEN "FICO_SCORE" BETWEEN 850 AND 949 THEN 'Excellent'
            ELSE 'Unknown'
        END AS FICO_Segment
    FROM
        transaction_line_final) AS subquery
GROUP BY
    FICO_Segment
ORDER BY
    CASE
        WHEN FICO_Segment = 'Very Poor' THEN 1
        WHEN FICO_Segment = 'Poor' THEN 2
        WHEN FICO_Segment = 'Fair' THEN 3
        WHEN FICO_Segment = 'Good' THEN 4
        WHEN FICO_Segment = 'Excellent' THEN 5
        ELSE 6
    END;

--Product Usage Segmentation: Categorizing customers by the types of accounts they hold (e.g., Auto Loans, Credit Cards, etc.).
SELECT
    "ACCOUNT_CATEGORY",
    COUNT(DISTINCT "CUSTOMER_ID") AS Customer_Count
FROM
    transaction_line_final
GROUP BY
    "ACCOUNT_CATEGORY"
ORDER BY
    Customer_Count DESC;

--Account Activity Segmentation: Segmenting customers by the status of their accounts (whether they have more active or closed accounts).
SELECT
    CASE
        WHEN active_accounts > closed_accounts THEN 'More Active'
        WHEN active_accounts < closed_accounts THEN 'More Closed'
        ELSE 'Equal Activity'
    END AS "Account_Activity_Status",
    COUNT(*) AS "Customer_Count"
FROM
    (
    SELECT
        "CUSTOMER_ID",
        SUM(CASE WHEN "ACCOUNT_STATUS" = 'Active' THEN 1 ELSE 0 END) AS active_accounts,
        SUM(CASE WHEN "ACCOUNT_STATUS" = 'Closed' THEN 1 ELSE 0 END) AS closed_accounts
    FROM
        "transaction_line_final"
    GROUP BY
        "CUSTOMER_ID"
    ) AS subquery
GROUP BY
    "Account_Activity_Status";

----------------------------------------------------------------------
WITH cohort_data AS (
    SELECT
        t."CUSTOMER_ID",
        DATE_TRUNC('month', t."OPENING_DATE"::date) AS cohort_month,
        MIN(t."OPENING_DATE") AS cohort_start_date
    FROM
        TRANSACTION_LINE_FINAL t
    GROUP BY
        t."CUSTOMER_ID", DATE_TRUNC('month', t."OPENING_DATE"::date)
),
cohort_retention AS (
    SELECT
        cd.cohort_month,
        cd.cohort_start_date,
        COUNT(DISTINCT t."CUSTOMER_ID") AS total_customers,
        COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', t."OPENING_DATE"::date) = cd.cohort_month THEN t."CUSTOMER_ID" END) AS retained_customers
    FROM
        TRANSACTION_LINE_FINAL t
    INNER JOIN
        cohort_data cd ON t."CUSTOMER_ID" = cd."CUSTOMER_ID"
    GROUP BY
        cd.cohort_month, cd.cohort_start_date
)
SELECT
    cohort_month,
    cohort_start_date,
    total_customers,
    retained_customers,
    ROUND((retained_customers::NUMERIC / total_customers) * 100, 2) AS retention_rate
FROM
    cohort_retention
ORDER BY
    cohort_start_date, cohort_month;

---------------------------------------------------------
WITH account_counts AS (
    SELECT
        "ACCOUNT_CATEGORY",
        COUNT(DISTINCT "CUSTOMER_ID") AS customer_count
    FROM
        TRANSACTION_LINE_FINAL
    GROUP BY
        "ACCOUNT_CATEGORY"
),
co_occurrence_matrix AS (
    SELECT
        a1."ACCOUNT_CATEGORY" AS account_category_1,
        a2."ACCOUNT_CATEGORY" AS account_category_2,
        COUNT(DISTINCT t1."CUSTOMER_ID") AS co_occurrence_count
    FROM
        TRANSACTION_LINE_FINAL t1
    INNER JOIN
        TRANSACTION_LINE_FINAL t2 ON t1."CUSTOMER_ID" = t2."CUSTOMER_ID"
    INNER JOIN
        account_counts a1 ON t1."ACCOUNT_CATEGORY" = a1."ACCOUNT_CATEGORY"
    INNER JOIN
        account_counts a2 ON t2."ACCOUNT_CATEGORY" = a2."ACCOUNT_CATEGORY"
    WHERE
        t1."ACCOUNT_CATEGORY" != t2."ACCOUNT_CATEGORY"
    GROUP BY
        a1."ACCOUNT_CATEGORY", a2."ACCOUNT_CATEGORY"
),
diagonal_values AS (
    SELECT
        "ACCOUNT_CATEGORY",
        customer_count AS diagonal_value
    FROM
        account_counts
),
off_diagonal_values AS (
    SELECT
        account_category_1,
        account_category_2,
        co_occurrence_count
    FROM
        co_occurrence_matrix
)
SELECT
    d."ACCOUNT_CATEGORY" AS "Account Category",
    d.diagonal_value AS "Diagonal Value",
    ROUND(COALESCE(o1.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Auto Loan (%)",
    ROUND(COALESCE(o2.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Consumer Loan (%)",
    ROUND(COALESCE(o3.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Credit Card (%)",
    ROUND(COALESCE(o4.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Gold Loan (%)",
    ROUND(COALESCE(o5.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Housing Loan (%)",
    ROUND(COALESCE(o6.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Personal Loan (%)",
    ROUND(COALESCE(o7.co_occurrence_count, 0) * 100.0 / d.diagonal_value, 2) AS "Two Wheeler Loan (%)"
FROM
    diagonal_values d
LEFT JOIN
    off_diagonal_values o1 ON d."ACCOUNT_CATEGORY" = o1.account_category_1 AND o1.account_category_2 = 'Auto Loan'
LEFT JOIN
    off_diagonal_values o2 ON d."ACCOUNT_CATEGORY" = o2.account_category_1 AND o2.account_category_2 = 'Consumer Loan'
LEFT JOIN
    off_diagonal_values o3 ON d."ACCOUNT_CATEGORY" = o3.account_category_1 AND o3.account_category_2 = 'Credit Card'
LEFT JOIN
    off_diagonal_values o4 ON d."ACCOUNT_CATEGORY" = o4.account_category_1 AND o4.account_category_2 = 'Gold Loan'
LEFT JOIN
    off_diagonal_values o5 ON d."ACCOUNT_CATEGORY" = o5.account_category_1 AND o5.account_category_2 = 'Housing Loan'
LEFT JOIN
    off_diagonal_values o6 ON d."ACCOUNT_CATEGORY" = o6.account_category_1 AND o6.account_category_2 = 'Personal Loan'
LEFT JOIN
    off_diagonal_values o7 ON d."ACCOUNT_CATEGORY" = o7.account_category_1 AND o7.account_category_2 = 'Two Wheeler Loan'
ORDER BY
    d."ACCOUNT_CATEGORY";
   
   
------------------------------------------------------------------------
select "ACCOUNT_CATEGORY" ,AVG("TENURE_MONTHS") from transaction_line_final group by "ACCOUNT_CATEGORY" ;

-- Count of active accounts in the cohort of 2004-05
SELECT 
    COUNT(CASE WHEN EXTRACT(YEAR FROM "OPENING_DATE"::date) = 2004 AND EXTRACT(MONTH FROM "OPENING_DATE"::date) = 5 AND "ACCOUNT_STATUS" = 'Active' THEN 1 END) AS active_count_2004_05,
    -- Total count of accounts in the cohort of 2004-05
    COUNT(CASE WHEN EXTRACT(YEAR FROM "OPENING_DATE"::date) = 2004 AND EXTRACT(MONTH FROM "OPENING_DATE"::date) = 5 THEN 1 END) AS total_count_2004_05,
    -- Percentage of active accounts in the cohort of 2004-05
    ROUND(COUNT(CASE WHEN EXTRACT(YEAR FROM "OPENING_DATE"::date) = 2004 AND EXTRACT(MONTH FROM "OPENING_DATE"::date) = 5 AND "ACCOUNT_STATUS" = 'Active' THEN 1 END) * 100.0 / COUNT(CASE WHEN EXTRACT(YEAR FROM "OPENING_DATE"::date) = 2004 AND EXTRACT(MONTH FROM "OPENING_DATE"::date) = 5 THEN 1 END), 1) AS active_percentage_2004_05
FROM 
    TRANSACTION_LINE_FINAL;


select avg("TENURE_MONTHS") from transaction_line_final where "ACCOUNT_CATEGORY" ='Housing Loan' and "ACCOUNT_STATUS" ='Closed'
