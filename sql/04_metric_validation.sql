/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 04_metric_validation.sql
Purpose: Independently calculate and validate reported fund performance metrics using the underlying CalPERS financial data.
*/


-- 1. Validate reported Investment Multiple against calculated values

SELECT
    COUNT(*) AS funds_tested,
    COUNTIF(
        investment_multiple = ROUND(total_value / cash_in, 1)
    ) AS matching_values,
    COUNTIF(
        investment_multiple != ROUND(total_value / cash_in, 1)
    ) AS mismatched_values
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL;
