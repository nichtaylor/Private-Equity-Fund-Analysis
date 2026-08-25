/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 06_performance_analysis.sql
Purpose: Analyze fund-level performance, return dispersion, and realized versus unrealized value across CalPERS' active private equity portfolio.
*/


-- 1. Fund performance overview

SELECT
    COUNT(*) AS funds_with_performance,

    ROUND(100 * AVG(net_irr), 1) AS average_net_irr_pct,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(1)], 1) AS net_irr_q1_pct,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(2)], 1) AS median_net_irr_pct,
    ROUND(100 * APPROX_QUANTILES(net_irr, 4)[OFFSET(3)], 1) AS net_irr_q3_pct,

    ROUND(AVG(investment_multiple), 2) AS average_multiple,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(1)], 2) AS multiple_q1,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(2)], 2) AS median_multiple,
    ROUND(APPROX_QUANTILES(investment_multiple, 4)[OFFSET(3)], 2) AS multiple_q3

FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
    AND investment_multiple IS NOT NULL;


-- 2. Top-performing funds by Net IRR

SELECT
    fund_manager,
    fund_name,
    vintage_year,
    ROUND(100 * net_irr, 1) AS net_irr_pct,
    investment_multiple
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
ORDER BY net_irr DESC
LIMIT 10;


-- 3. Top-performing funds by Investment Multiple

SELECT
    fund_manager,
    fund_name,
    vintage_year,
    investment_multiple,
    ROUND(100 * net_irr, 1) AS net_irr_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL
ORDER BY investment_multiple DESC
LIMIT 10;


-- 4. Correlation between Net IRR and Investment Multiple

SELECT
    ROUND(CORR(net_irr, investment_multiple), 2) AS irr_multiple_correlation
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE net_irr IS NOT NULL
    AND investment_multiple IS NOT NULL;


-- 5. Realized and unrealized value by fund

SELECT
    fund_manager,
    fund_name,
    vintage_year,
    ROUND(cash_out / cash_in, 2) AS dpi,
    ROUND((total_value - cash_out) / cash_in, 2) AS rvpi,
    investment_multiple AS tvpi
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL
ORDER BY dpi DESC;


-- 6. Aggregate realized and unrealized performance

SELECT
    ROUND(SUM(cash_out) / SUM(cash_in), 2) AS dpi,
    ROUND(SUM(total_value - cash_out) / SUM(cash_in), 2) AS rvpi,
    ROUND(SUM(total_value) / SUM(cash_in), 2) AS tvpi
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL;


-- 7. Distribution of funds by Investment Multiple

SELECT
    COUNT(*) AS funds_with_performance,
    ROUND(100 * COUNTIF(investment_multiple < 1.0) / COUNT(*), 1) AS below_cost_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 1.0 AND investment_multiple < 1.5) / COUNT(*), 1) AS between_1x_and_1_5x_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 1.5 AND investment_multiple < 2.0) / COUNT(*), 1) AS between_1_5x_and_2x_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 2.0) / COUNT(*), 1) AS above_2x_pct,
    ROUND(100 * COUNTIF(investment_multiple >= 3.0) / COUNT(*), 1) AS above_3x_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
WHERE investment_multiple IS NOT NULL;


-- 8. Compare top-performing funds by Net IRR and Investment Multiple

WITH ranked_funds AS (
    SELECT
        fund_name,
        net_irr,
        investment_multiple,
        RANK() OVER (ORDER BY net_irr DESC) AS irr_rank,
        RANK() OVER (ORDER BY investment_multiple DESC) AS multiple_rank
    FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
    WHERE net_irr IS NOT NULL
        AND investment_multiple IS NOT NULL
)

SELECT
    COUNTIF(irr_rank <= 10 AND multiple_rank <= 10) AS top_10_overlap
FROM ranked_funds
WHERE irr_rank <= 10
    OR multiple_rank <= 10;


-- 9. Concentration of value above contributed capital

WITH ranked_funds AS (
    SELECT
        total_value - cash_in AS value_above_contributed_capital,
        ROW_NUMBER() OVER (ORDER BY total_value - cash_in DESC) AS fund_rank,
        COUNT(*) OVER () AS total_funds
    FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
    WHERE cash_in > 0
)

SELECT
    total_funds,
    ROUND(100 * SUM(IF(fund_rank <= CEIL(total_funds * 0.20), value_above_contributed_capital, 0))
        / SUM(value_above_contributed_capital), 1) AS top_20_pct_share,
    ROUND(100 * SUM(IF(fund_rank <= CEIL(total_funds * 0.50), value_above_contributed_capital, 0))
        / SUM(value_above_contributed_capital), 1) AS top_50_pct_share,
    ROUND(100 * SUM(IF(fund_rank > CEIL(total_funds * 0.50), value_above_contributed_capital, 0))
        / SUM(value_above_contributed_capital), 1) AS bottom_50_pct_share,
    ROUND(100 * COUNTIF(fund_rank > CEIL(total_funds * 0.50) AND value_above_contributed_capital > 0)
        / COUNTIF(fund_rank > CEIL(total_funds * 0.50)), 1) AS bottom_50_above_cost_pct
FROM ranked_funds
GROUP BY total_funds;
