/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 07_vintage_analysis.sql
Purpose: Analyze fund performance and realization patterns across vintage years, while accounting for differences in fund maturity and the "active fund only" scope of the dataset.
*/


-- 1. Performance by vintage year

SELECT
    vintage_year,
    COUNT(*) AS funds_with_performance,
    ROUND(100 * AVG(net_irr), 1) AS average_net_irr_pct,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(2)], 1) AS median_net_irr_pct,
    ROUND(AVG(investment_multiple), 2) AS average_multiple,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(2)], 2) AS median_multiple
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
GROUP BY vintage_year
ORDER BY vintage_year;


-- 2. Realized and unrealized value by vintage year

SELECT
    vintage_year,
    COUNT(*) AS fund_count,
    ROUND(SUM(cash_out) / SUM(cash_in), 2) AS dpi,
    ROUND(SUM(total_value - cash_out) / SUM(cash_in), 2) AS rvpi,
    ROUND(SUM(total_value) / SUM(cash_in), 2) AS tvpi
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE cash_in > 0
GROUP BY vintage_year
ORDER BY vintage_year;


-- 3. Realized share of total value by vintage year

SELECT
    vintage_year,
    COUNT(*) AS fund_count,
    ROUND(100 * SUM(cash_out) / SUM(total_value), 1) AS realized_value_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE total_value > 0
GROUP BY vintage_year
ORDER BY vintage_year;
