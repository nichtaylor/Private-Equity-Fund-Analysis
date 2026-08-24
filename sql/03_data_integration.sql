/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 03_data_integration.sql
Purpose: Integrate the cleaned fund performance and manager mapping tables into a single analysis-ready dataset.
*/


-- 1. Join fund performance and manager data

SELECT
    m.fund_manager,
    p.fund_name,
    p.vintage_year,
    p.capital_committed,
    p.cash_in,
    p.cash_out,
    p.total_value,
    p.net_irr,
    p.investment_multiple
FROM `pe-fund-insights-project.calpers_pe.clean_fund_performance` AS p
LEFT JOIN `pe-fund-insights-project.calpers_pe.clean_fund_managers` AS m
    ON p.fund_name = m.fund_name;


-- 2. Validate joined dataset

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT p.fund_name) AS unique_funds,
    COUNTIF(m.fund_manager IS NULL) AS missing_managers
FROM `pe-fund-insights-project.calpers_pe.clean_fund_performance` AS p
LEFT JOIN `pe-fund-insights-project.calpers_pe.clean_fund_managers` AS m
    ON p.fund_name = m.fund_name;


-- 3. Create integrated analysis table

CREATE OR REPLACE TABLE `pe-fund-insights-project.calpers_pe.fund_analysis` AS

SELECT
    m.fund_manager,
    p.fund_name,
    p.vintage_year,
    p.capital_committed,
    p.cash_in,
    p.cash_out,
    p.total_value,
    p.net_irr,
    p.investment_multiple
FROM `pe-fund-insights-project.calpers_pe.clean_fund_performance` AS p
LEFT JOIN `pe-fund-insights-project.calpers_pe.clean_fund_managers` AS m
    ON p.fund_name = m.fund_name;
