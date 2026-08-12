CREATE DATABASE telecom_projectt;
USE telecom_projectt;

select * from customers

select * from billing

select * from Network_issues

select * from Network_usage

ALTER TABLE customers
ADD CONSTRAINT PK_customers PRIMARY KEY (customer_id);

ALTER TABLE network_usage
ADD CONSTRAINT FK_usage_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE network_issues
ADD CONSTRAINT FK_issues_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE billing
ADD CONSTRAINT FK_billing_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

SELECT 
    c.customer_id,
    c.customer_type,
    c.city,
    u.usage_date,
    u.data_used_gb,
    u.call_minutes,
    u.network_type
FROM customers c
JOIN Network_usage  u
    ON c.customer_id = u.customer_id;

    SELECT 
    c.customer_id,
    c.city,
    u.data_used_gb,
    u.call_minutes,
    i.issue_type,
    i.resolution_time_hrs,
    i.resolved
FROM customers c
JOIN Network_usage u
    ON c.customer_id = u.customer_id
JOIN Network_issues i
    ON c.customer_id = i.customer_id;

SELECT 
    c.customer_id,
    c.customer_type,
    c.city,

    u.usage_date,
    u.data_used_gb,
    u.call_minutes,
    u.network_type,

    i.issue_type,
    i.resolution_time_hrs,
    i.resolved,

    b.bill_month,
    b.bill_amount,
    b.payment_status

FROM customers c
JOIN Network_usage u
    ON c.customer_id = u.customer_id
JOIN Network_issues i
    ON c.customer_id = i.customer_id
JOIN billing b
    ON c.customer_id = b.customer_id;

--Total complaints per customer
SELECT 
    customer_id,
    COUNT(issue_id) AS total_complaints
FROM Network_issues
GROUP BY customer_id;

--Complaint rate per customer
SELECT 
    customer_id,
    COUNT(issue_id) AS total_complaints,
    COUNT(issue_id) * 1.0 / COUNT(DISTINCT issue_date) AS complaint_rate
FROM Network_issues
GROUP BY customer_id;

--Monthly complaint trend
SELECT 
    customer_id,
    FORMAT(issue_date, 'yyyy-MM') AS month,
    COUNT(issue_id) AS monthly_complaints
FROM Network_issues
GROUP BY customer_id, FORMAT(issue_date, 'yyyy-MM')
ORDER BY customer_id, month;

--Monthly billing trend
SELECT 
    customer_id,
    FORMAT(bill_month, 'yyyy-MM') AS month,
    SUM(bill_amount) AS monthly_revenue
FROM billing
GROUP BY customer_id, FORMAT(bill_month, 'yyyy-MM')
ORDER BY customer_id, month;

--Late payment analysis
SELECT 
    customer_id,
    COUNT(*) AS total_bills,
    SUM(CASE WHEN payment_status = 'Late' THEN 1 ELSE 0 END) AS late_payments
FROM billing
GROUP BY customer_id;

--City-wise network performance
SELECT 
    c.city,
    COUNT(i.issue_id) AS total_complaints,
    AVG(u.data_used_gb) AS avg_data_usage,
    AVG(i.resolution_time_hrs) AS avg_resolution_time
FROM customers c
JOIN Network_usage u ON c.customer_id = u.customer_id
JOIN Network_issues i ON c.customer_id = i.customer_id
GROUP BY c.city;

--Network type vs issues (5G analysis)
SELECT 
    u.network_type,
    COUNT(i.issue_id) AS total_issues
FROM Network_usage u
JOIN Network_issues i 
    ON u.customer_id = i.customer_id
GROUP BY u.network_type;

--Which customers have high usage but also high complaints
SELECT 
    u.customer_id,
    SUM(u.data_used_gb) AS total_usage,
    COUNT(i.issue_id) AS total_complaints
FROM Network_usage u
LEFT JOIN Network_issues i
    ON u.customer_id = i.customer_id
GROUP BY u.customer_id
HAVING SUM(u.data_used_gb) > 500
   AND COUNT(i.issue_id) > 3;

--Average resolution time by issue type
SELECT 
    issue_type,
    AVG(resolution_time_hrs) AS avg_resolution_time
FROM Network_issues
GROUP BY issue_type
ORDER BY avg_resolution_time DESC;

