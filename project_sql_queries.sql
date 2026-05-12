-- =========================================
-- CREDIT RISK MONITORING SYSTEM
-- SQL ANALYTICS QUERIES
-- =========================================



-- =========================================
-- STEP 1: BASIC RETRIEVAL QUERIES
-- =========================================


-- Query 1: View first 10 loans
SELECT *
FROM loans
LIMIT 10;


-- Query 2: Loans with interest rate greater than 15%
SELECT *
FROM loans
WHERE int_rate > 15;


-- Query 3: High interest loans sorted from highest to lowest
SELECT customer_id,
       loan_amnt,
       int_rate
FROM loans
WHERE int_rate > 15
ORDER BY int_rate DESC;


-- Query 4: Top 10 highest loan amounts
SELECT loan_amnt
FROM loans
ORDER BY loan_amnt DESC
LIMIT 10;



-- =========================================
-- STEP 2: AGGREGATION QUERIES
-- =========================================


-- Query 5: Loan status distribution
SELECT loan_status,
       COUNT(*) AS no_of_loans
FROM loans
GROUP BY loan_status
ORDER BY no_of_loans DESC;


-- Query 6: Average interest rate by loan grade
SELECT grade,
       ROUND(AVG(int_rate)::numeric, 2) AS avg_int_rate
FROM loans
GROUP BY grade;


-- Query 7: Average loan amount by loan purpose
SELECT purpose,
       ROUND(AVG(loan_amnt)::numeric, 2) AS avg_loan_amnt
FROM loans
GROUP BY purpose
ORDER BY avg_loan_amnt DESC;


-- Query 8: Average DTI by state
SELECT addr_state,
       ROUND(AVG(dti)::numeric, 2) AS avg_dti
FROM customers
GROUP BY addr_state
ORDER BY avg_dti DESC;



-- =========================================
-- STEP 3: KPI ANALYTICS QUERIES
-- =========================================


-- Query 9: Charge-off percentage
SELECT ROUND(
       100.0 * SUM(
           CASE
               WHEN loan_status = 'Charged Off'
               THEN 1
               ELSE 0
           END
       ) / COUNT(*),
       2
) AS charged_off_percentage
FROM loans;


-- Query 10: Average installment amount by grade
SELECT grade,
       ROUND(AVG(installment)::numeric, 2) AS avg_install_amnt
FROM loans
GROUP BY grade;


-- Query 11: States with highest charged-off loans
SELECT a.addr_state,
       COUNT(*) AS cnt
FROM customers AS a
INNER JOIN loans AS b
ON a.customer_id = b.customer_id
WHERE loan_status = 'Charged Off'
GROUP BY a.addr_state
ORDER BY cnt DESC;


-- Query 12: Loan purposes with highest charged-off loans
SELECT purpose,
       COUNT(*) AS cnt
FROM loans
WHERE loan_status = 'Charged Off'
GROUP BY purpose
ORDER BY cnt DESC;



-- =========================================
-- STEP 4: JOIN QUERIES
-- =========================================


-- Query 13: Combined customer-loan analytical view
SELECT a.customer_id,
       a.annual_inc,
       a.dti,
       b.loan_amnt,
       b.int_rate,
       b.loan_status
FROM customers AS a
JOIN loans AS b
ON a.customer_id = b.customer_id;


-- Query 14: High income customers with large loans
SELECT a.customer_id
FROM customers AS a
JOIN loans AS b
ON a.customer_id = b.customer_id
WHERE a.annual_inc > 100000
AND b.loan_amnt > 20000;


-- Query 15: Average loan amount by FICO score group
SELECT a.fico_range_low,
       ROUND(AVG(b.loan_amnt)::numeric, 2) AS avg_loan_amount
FROM customers AS a
JOIN loans AS b
ON a.customer_id = b.customer_id
GROUP BY a.fico_range_low
ORDER BY avg_loan_amount DESC;



-- =========================================
-- STEP 5: CASE WHEN SEGMENTATION QUERIES
-- =========================================


-- Query 16: DTI-based risk segmentation
SELECT customer_id,
       dti,
       CASE
           WHEN dti > 20 THEN 'High Risk'
           ELSE 'Low Risk'
       END AS risk_category
FROM customers;


-- Query 17: Interest-rate-based risk segmentation
SELECT customer_id,
       int_rate,
       CASE
           WHEN int_rate >= 15 THEN 'High Interest Risk'
           WHEN int_rate >= 10 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_category
FROM loans;


-- Query 18: Combined DTI and interest-rate risk segmentation
SELECT c.customer_id,
       c.dti,
       l.int_rate,
       CASE
           WHEN c.dti > 20
           AND l.int_rate > 15
           THEN 'High Risk'
           ELSE 'Normal Risk'
       END AS risk_category
FROM customers AS c
JOIN loans AS l
ON c.customer_id = l.customer_id;



-- =========================================
-- STEP 6: MONITORING VIEWS
-- =========================================


-- Query 19: Create high-risk customers monitoring view
CREATE VIEW high_risk_customers AS
SELECT c.customer_id,
       c.dti,
       l.int_rate,
       l.loan_status
FROM customers AS c
JOIN loans AS l
ON c.customer_id = l.customer_id
WHERE c.dti > 20
AND l.int_rate > 15;


-- Query 20: View all high-risk customers
SELECT *
FROM high_risk_customers;