-- 1st CTE finds the account details
-- date - country - send_interval - is_verified - is_unsubscribed - account_cnt
WITH account_metrics AS (
SELECT
s.date,
sp.country,
ac.send_interval,
ac.is_verified,
ac.is_unsubscribed,
COUNT(DISTINCT ac.id) AS account_cnt,
0 AS sent_msg,
0 AS open_msg,
0 AS visit_msg
FROM `DA.session` AS s
JOIN `DA.session_params` AS sp
  ON s.ga_session_id = sp.ga_session_id
JOIN `DA.account_session` AS acs
  ON s.ga_session_id = acs.ga_session_id
JOIN `DA.account` AS ac
  ON acs.account_id = ac.id
GROUP BY 1,2,3,4,5
),
--2nd CTE finds the email details
--sent_msg, open_msg, visit_msg
email_metrics AS (
SELECT
DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS sent_date,
sp.country,
ac.send_interval,
ac.is_verified,
ac.is_unsubscribed,
0 AS account_cnt,
COUNT(DISTINCT es.id_message) AS sent_msg,
COUNT(DISTINCT eo.id_message) AS open_msg,
COUNT(DISTINCT ev.id_message) AS visit_msg
FROM `DA.session` AS s
JOIN `DA.session_params` AS sp
  ON s.ga_session_id = sp.ga_session_id
JOIN `DA.account_session` AS acs
  ON s.ga_session_id = acs.ga_session_id
JOIN `DA.account` AS ac
  ON acs.account_id = ac.id
JOIN `DA.email_sent` AS es
  ON ac.id = es.id_account
LEFT JOIN `DA.email_open` AS eo
  ON es.id_message = eo.id_message
LEFT JOIN `DA.email_visit` AS ev
  ON eo.id_message = ev.id_message
GROUP BY 1, 2, 3, 4, 5
),
--3rd CTE unions the 1st and 2nd CTE's so lately we are able to ADD total aggregations
union_data AS (
SELECT * FROM account_metrics
UNION ALL
SELECT * FROM email_metrics
),
-- 4th CTE finds the aggregations in TOTAL AC cnt and sent cnt
aggregation_data AS (
SELECT
 date,
 country,
 send_interval,
 is_verified,
 is_unsubscribed,
 SUM(account_cnt) AS account_cnt,
 SUM(sent_msg) AS sent_msg,
 SUM(open_msg) AS open_msg,
 SUM(visit_msg) AS visit_msg,
 SUM(SUM(account_cnt)) OVER(PARTITION BY country) AS total_country_account_cnt,
 SUM(SUM(sent_msg)) OVER(PARTITION BY country) AS total_country_sent_cnt
FROM union_data
GROUP BY 1,2,3,4,5
),
--5th CTE finds rank_total_counrty_account_cnt - rank_total_country_sent_cnt
ranked_data AS (
SELECT
*,
DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_cnt,
DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
FROM aggregation_data
)
--FINAL query is here
SELECT
*
FROM ranked_data
WHERE rank_total_country_cnt <= 10 OR rank_total_country_sent_cnt <= 10
ORDER BY total_country_account_cnt DESC;
