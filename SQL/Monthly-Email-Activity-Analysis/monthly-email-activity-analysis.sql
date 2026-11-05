SELECT
 DISTINCT sent_month,
 id_account,
 SAFE_DIVIDE(sent_msg, msg_month) * 100 AS sent_msg_percent_from_this_month,
 MIN(sent_date_full) OVER(PARTITION BY id_account, sent_month) AS first_sent_date,
 MAX(sent_date_full) OVER(PARTITION BY id_account, sent_month) AS last_sent_date
FROM (
--Finding sent msg per account and per month AND finding msg sent in month total
 SELECT
   sent_month,
   id_account,
   COUNT(id_message) OVER(PARTITION BY id_account, sent_month) AS sent_msg,
   COUNT(id_message) OVER(PARTITION BY sent_month) AS msg_month,
   sent_date_full
 FROM(
--finding the sent_month
   SELECT
     DATE_TRUNC(sent_date_full, MONTH) AS sent_month,
     id_account,
     id_message,
     sent_date_full
   FROM(
--JOINING session.date and email_sent.sent_date to find the full date.
     SELECT
       DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS sent_date_full,
       es.id_account,
       es.id_message
     FROM `DA.session` AS s
     JOIN `DA.account_session` AS acs
       ON s.ga_session_id = acs.ga_session_id
     JOIN `DA.account` AS ac
       ON acs.account_id = ac.id
     JOIN `DA.email_sent` AS es
       ON ac.id = es.id_account
     )));
