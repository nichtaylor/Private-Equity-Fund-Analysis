/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 05_portfolio_analysis.sql
Purpose: Analyze the size, capital contributions, value, and concentration of CalPERS' active private equity portfolio.
*/


-- 1. Portfolio overview

SELECT
    COUNT(*) AS total_funds,
    COUNT(DISTINCT fund_manager) AS total_managers,
    MIN(vintage_year) AS earliest_vintage,
    MAX(vintage_year) AS latest_vintage,
    SUM(capital_committed) AS total_committed,
    SUM(cash_in) AS total_cash_in,
    SUM(cash_out) AS total_cash_out,
    SUM(total_value) AS total_value,
    SUM(total_value) - SUM(cash_out) AS remaining_value,
    ROUND(100 * SUM(cash_in) / SUM(capital_committed), 1) AS cash_in_pct_of_commitment,
    ROUND(SUM(cash_out) / SUM(cash_in), 2) AS dpi,
    ROUND(SUM(total_value) / SUM(cash_in), 2) AS tvpi
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`;


-- 2. Commitment concentration by fund manager

SELECT
    fund_manager,
    COUNT(*) AS fund_count,
    SUM(capital_committed) AS total_committed,
    ROUND(
        100 * SUM(capital_committed)
        / SUM(SUM(capital_committed)) OVER (),
        1
    ) AS share_of_commitments_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
GROUP BY fund_manager
ORDER BY total_committed DESC;


-- 3. Commitment concentration among largest fund managers

WITH manager_commitments AS (
    SELECT
        fund_manager,
        SUM(capital_committed) AS total_committed
    FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
    GROUP BY fund_manager
),

ranked_managers AS (
    SELECT
        fund_manager,
        total_committed,
        ROW_NUMBER() OVER (ORDER BY total_committed DESC) AS manager_rank
    FROM manager_commitments
)

SELECT
    ROUND(
        100 * SUM(CASE WHEN manager_rank <= 10 THEN total_committed ELSE 0 END)
        / SUM(total_committed),
        1
    ) AS top_10_commitment_share_pct,

    ROUND(
        100 * SUM(CASE WHEN manager_rank <= 25 THEN total_committed ELSE 0 END)
        / SUM(total_committed),
        1
    ) AS top_25_commitment_share_pct,

    ROUND(
        100 * SUM(CASE WHEN manager_rank <= 50 THEN total_committed ELSE 0 END)
        / SUM(total_committed),
        1
    ) AS top_50_commitment_share_pct

FROM ranked_managers;


-- 4. Portfolio composition by vintage year

SELECT
    vintage_year,
    COUNT(*) AS fund_count,
    SUM(capital_committed) AS total_committed,
    ROUND(
        100 * SUM(capital_committed)
        / SUM(SUM(capital_committed)) OVER (),
        1
    ) AS share_of_commitments_pct
FROM `pe-fund-insights-project.calpers_pe.fund_analysis`
GROUP BY vintage_year
ORDER BY vintage_year;
