/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 08_manager_analysis.sql
Purpose: Analyze performance, consistency, and commitment exposure across fund managers in CalPERS' active private equity portfolio.
*/


-- 1. Performance by fund manager

SELECT
    fund_manager,
    COUNT(*) AS fund_count,
    APPROX_QUANTILES(vintage_year, 2)[OFFSET(1)] AS median_vintage,
    ROUND(100 * AVG(net_irr), 1) AS average_net_irr_pct,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(2)], 1) AS median_net_irr_pct,
    ROUND(AVG(investment_multiple), 2) AS average_multiple,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(2)], 2) AS median_multiple
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
    AND investment_multiple IS NOT NULL
GROUP BY fund_manager
HAVING COUNT(*) >= 3
ORDER BY median_multiple DESC;


-- 2. Performance consistency by fund manager

SELECT
    fund_manager,
    COUNT(*) AS fund_count,
    ROUND(100 * COUNTIF(investment_multiple >= 1.0) / COUNT(*), 1) AS above_cost_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 1.5) / COUNT(*), 1) AS above_1_5x_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 2.0) / COUNT(*), 1) AS above_2x_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL
GROUP BY fund_manager
HAVING COUNT(*) >= 3
ORDER BY above_2x_pct DESC, above_1_5x_pct DESC;


-- 3. Manager commitment exposure and performance

SELECT
    fund_manager,
    COUNT(*) AS fund_count,
    SUM(capital_committed) AS total_committed,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(2)], 1) AS median_net_irr_pct,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(2)], 2) AS median_multiple
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
    AND investment_multiple IS NOT NULL
GROUP BY fund_manager
HAVING COUNT(*) >= 3
ORDER BY total_committed DESC;


-- 4. Relationship between manager commitment size and performance

WITH manager_performance AS (
    SELECT
        fund_manager,
        COUNT(*) AS fund_count,
        SUM(capital_committed) AS total_committed,
        APPROX_QUANTILES(net_irr, 4)[OFFSET(2)] AS median_net_irr,
        APPROX_QUANTILES(investment_multiple, 4)[OFFSET(2)] AS median_multiple
    FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
    WHERE net_irr IS NOT NULL
        AND investment_multiple IS NOT NULL
    GROUP BY fund_manager
    HAVING COUNT(*) >= 3
)

SELECT
    ROUND(CORR(total_committed, median_net_irr), 2) AS commitment_irr_correlation,
    ROUND(CORR(total_committed, median_multiple), 2) AS commitment_multiple_correlation
FROM manager_performance;
