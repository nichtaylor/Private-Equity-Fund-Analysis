/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 01_data_quality.sql
Purpose: Assess the completeness, uniqueness, validity, and internal consistency of the raw CalPERS fund performance and manager mapping data before transformation.
*/


-- 1. Fund performance: Table overview

-- Confirm row count and fund-name uniqueness
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Fund) AS unique_funds
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- 2. Fund performance: Completeness checks

-- Check for NULL values across all source fields
SELECT
    COUNTIF(Fund IS NULL) AS missing_fund_name,
    COUNTIF(`Vintage Year` IS NULL) AS missing_vintage_year,
    COUNTIF(`Capital Committed` IS NULL) AS missing_capital_committed,
    COUNTIF(`Cash In` IS NULL) AS missing_cash_in,
    COUNTIF(`Cash Out` IS NULL) AS missing_cash_out,
    COUNTIF(`Cash Out & Remaining Value` IS NULL) AS missing_total_value,
    COUNTIF(`Net IRR` IS NULL) AS missing_net_irr,
    COUNTIF(`Investment Multiple` IS NULL) AS missing_investment_multiple
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- 3. Fund performance: Special values and format checks

-- Count records where reported performance is marked as Not Meaningful
SELECT
    COUNTIF(STARTS_WITH(`Net IRR`, 'N/M')) AS nm_net_irr,
    COUNTIF(STARTS_WITH(`Investment Multiple`, 'N/M')) AS nm_investment_multiple
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- Review distribution of N/M designations by vintage
SELECT
    `Vintage Year`,
    COUNT(*) AS total_funds,
    COUNTIF(STARTS_WITH(`Net IRR`, 'N/M')) AS nm_net_irr,
    COUNTIF(STARTS_WITH(`Investment Multiple`, 'N/M')) AS nm_investment_multiple
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`
GROUP BY `Vintage Year`
ORDER BY `Vintage Year`;


-- Check consistency of N/M designation across performance fields
SELECT
    Fund,
    `Vintage Year`,
    `Net IRR`,
    `Investment Multiple`
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`
WHERE
    (STARTS_WITH(`Net IRR`, 'N/M')
        AND NOT STARTS_WITH(`Investment Multiple`, 'N/M'))
    OR
    (NOT STARTS_WITH(`Net IRR`, 'N/M')
        AND STARTS_WITH(`Investment Multiple`, 'N/M'));


-- 4. Fund performance: Financial sanity checks

-- Check for negative monetary values
SELECT
    COUNTIF(`Capital Committed` < 0) AS negative_commitments,
    COUNTIF(`Cash In` < 0) AS negative_cash_in,
    COUNTIF(`Cash Out` < 0) AS negative_cash_out,
    COUNTIF(`Cash Out & Remaining Value` < 0) AS negative_total_value
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- Check for cases where total value is lower than distributions received
SELECT
    Fund,
    `Cash Out`,
    `Cash Out & Remaining Value`
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`
WHERE `Cash Out & Remaining Value` < `Cash Out`;


-- 5. Manager mapping: Quality checks

-- Confirm row count, fund-name uniqueness, and number of managers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT fund_name) AS unique_funds,
    COUNT(DISTINCT fund_manager) AS unique_managers
FROM `pe-fund-insights-project.calpers_pe.raw_fund_managers`;


-- Check for missing values in manager mapping
SELECT
    COUNTIF(fund_name IS NULL) AS missing_fund_name,
    COUNTIF(fund_manager IS NULL) AS missing_fund_manager
FROM `pe-fund-insights-project.calpers_pe.raw_fund_managers`;


-- Check for unmatched funds between performance and manager tables
SELECT
    p.Fund AS performance_fund,
    m.fund_name AS manager_fund
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance` AS p
FULL OUTER JOIN `pe-fund-insights-project.calpers_pe.raw_fund_managers` AS m
    ON p.Fund = m.fund_name
WHERE p.Fund IS NULL
   OR m.fund_name IS NULL;
