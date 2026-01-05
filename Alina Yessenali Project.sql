#1. Список клиентов с непрерывной историей за год 
SELECT t.ID_client,
AVG(t.Sum_payment) AS avg_check,
SUM(t.Sum_payment) / 12 AS avg_monthly_sum, 
COUNT(t.Id_check) AS total_transactions 
FROM transactions t
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12; 

# 2. Информация в разрезе месяцев
SELECT DATE_FORMAT(date_new, '%Y-%m') AS month,
AVG(Sum_payment) AS avg_monthly_check,
COUNT(Id_check) / COUNT(DISTINCT ID_client) AS avg_trans_per_client,
COUNT(DISTINCT ID_client) AS unique_clients,
COUNT(Id_check) / (SELECT COUNT(*) FROM transactions 
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') * 100 AS pct_total_ops,
SUM(Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') * 100 AS pct_total_sum
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month;

#3 Соотношение M/F/NA и доли затрат по месяцам
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, c.Gender,
COUNT(c.Id_client) / SUM(COUNT(c.Id_client)) 
OVER(PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')) * 100 AS gender_pct,
SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) 
OVER(PARTITION BY DATE_FORMAT(t.date_new, '%Y-%m')) * 100 AS spend_share_pct
FROM transactions t
JOIN customers c
ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month, c.Gender;

# Возрастные группы (шаг 10 лет)
SELECT 
CASE 
	WHEN c.Age IS NULL THEN 'No Info'
	ELSE CONCAT(FLOOR(c.Age/10)*10, '-', FLOOR(c.Age/10)*10 + 9)
    END AS age_group,
SUM(t.Sum_payment) AS total_sum,
COUNT(t.Id_check) AS total_ops,
SUM(t.Sum_payment) / 4 AS avg_quarterly_sum,
SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions) * 100 AS pct_of_total_revenue
FROM customers c
LEFT JOIN transactions t ON c.Id_client = t.ID_client
GROUP BY age_group;
