# Monthly Email Activity Analysis Using Window Functions

## Project Overview

This project focuses on analyzing monthly email activity at the account level.

The goal was to determine what percentage of all monthly sent emails belonged to each account and identify the first and last email sending dates for every account within each month.

Using SQL in Google BigQuery, I applied window functions to calculate account-level and monthly email metrics without using GROUP BY.

## Key Analysis Areas

- **Monthly Email Distribution:** Calculating each account's share of total emails sent during a month.
- **Account-Level Activity:** Measuring the number of emails sent by each account within each month.
- **Email Sending Timeline:** Identifying the first and last email sending dates for each account per month.

## Tools & Technologies

- Google BigQuery
- SQL

## SQL Skills Demonstrated

- Window Functions
- PARTITION BY
- COUNT() OVER()
- MIN() OVER() and MAX() OVER()
- DATE_TRUNC()
- DATE_ADD()
- SAFE_DIVIDE()
- DISTINCT
- Nested Subqueries
- Date Calculations

## Key Outcome

The project resulted in a monthly account-level dataset showing email sending distribution and activity periods, allowing comparisons of email engagement across accounts and months.
