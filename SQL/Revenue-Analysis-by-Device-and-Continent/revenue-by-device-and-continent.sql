WITH
--finding all revenue needed info
device_revenues AS (
SELECT
 sp.continent,
 SUM(p.price) AS revenue,
 SUM(CASE WHEN sp.device = 'mobile' THEN p.price ELSE 0 END) AS revenue_from_mobile,
 SUM(CASE WHEN sp.device = 'desktop' THEN p.price ELSE 0 END) AS revenue_from_desktop
FROM `DA.product` AS p
JOIN `DA.order` AS o
 ON p.item_id = o.item_id
JOIN `DA.session_params` AS sp
 ON o.ga_session_id = sp.ga_session_id
GROUP BY sp.continent
),
-- finding account info
account_data AS (
SELECT
COUNT(ac.id) AS account_count,
COUNT(CASE WHEN ac.is_verified = 1 THEN id ELSE NULL END) AS verified_account,
sp.continent
FROM `DA.account` AS ac
JOIN `DA.account_session` AS acs
 ON ac.id = acs.account_id
JOIN `DA.session_params` AS sp
 ON acs.ga_session_id = sp.ga_session_id
GROUP BY sp.continent
),
-- finding total session count
total_session_count AS
(
 SELECT
   COUNT(ga_session_id) AS session_count,
   sp.continent
 FROM `DA.session_params` AS sp
 GROUP BY sp.continent
)
--final SELECT of CTE
SELECT
 dr.continent,
 dr.revenue,
 dr.revenue_from_mobile,
 dr.revenue_from_desktop,
 SAFE_DIVIDE(dr.revenue, SUM(dr.revenue) OVER()) * 100 AS percent_revenue_from_total,
 ad.account_count,
 ad.verified_account,
 total_s.session_count
FROM `device_revenues` AS dr
JOIN `account_data` AS ad
 ON dr.continent = ad.continent
JOIN `total_session_count` AS total_s
 ON ad.continent = total_s.continent ;
