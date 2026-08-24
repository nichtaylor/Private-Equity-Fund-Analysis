/*
Project: CalPERS Private Equity Portfolio Analysis
Script: 02_data_cleaning.sql
Purpose: Clean and standardize the raw fund performance and manager mapping data for reliable downstream analysis.
*/


-- 1. Fund performance: Standardize column names

SELECT
    Fund AS fund_name,
    `Vintage Year` AS vintage_year,
    `Capital Committed` AS capital_committed,
    `Cash In` AS cash_in,
    `Cash Out` AS cash_out,
    `Cash Out & Remaining Value` AS total_value,
    `Net IRR` AS net_irr_raw,
    `Investment Multiple` AS investment_multiple_raw
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- 2. Fund performance: Clean Net IRR

-- Convert Net IRR from raw text to numeric decimal
SELECT
    Fund AS fund_name,
    `Vintage Year` AS vintage_year,
    `Net IRR` AS net_irr_raw,
    CASE
        WHEN `Net IRR` LIKE 'N/M%' THEN NULL
        ELSE CAST(
            REPLACE(
                REPLACE(
                    REPLACE(`Net IRR`, CHR(160), ' '),
                    ' 1',
                    ''
                ),
                '%',
                ''
            ) AS NUMERIC
        ) / 100
    END AS net_irr_clean
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- Validate Net IRR cleaning
SELECT
    COUNT(*) AS total_funds,
    COUNTIF(`Net IRR` LIKE 'N/M%') AS expected_nulls,
    COUNTIF(
        `Net IRR` NOT LIKE 'N/M%'
        AND (
            CASE
                WHEN `Net IRR` LIKE 'N/M%' THEN NULL
                ELSE CAST(
                    REPLACE(
                        REPLACE(
                            REPLACE(`Net IRR`, CHR(160), ' '),
                            ' 1',
                            ''
                        ),
                        '%',
                        ''
                    ) AS NUMERIC
                ) / 100
            END
        ) IS NULL
    ) AS unexpected_nulls
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- 3. Fund performance: Clean Investment Multiple

-- Convert Investment Multiple from raw text to numeric
SELECT
    Fund AS fund_name,
    `Vintage Year` AS vintage_year,
    `Investment Multiple` AS investment_multiple_raw,
    CASE
        WHEN `Investment Multiple` LIKE 'N/M%' THEN NULL
        ELSE CAST(
            REPLACE(
                REPLACE(
                    REPLACE(`Investment Multiple`, CHR(160), ' '),
                    ' 1',
                    ''
                ),
                'x',
                ''
            ) AS NUMERIC
        )
    END AS investment_multiple_clean
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- Validate Investment Multiple cleaning
SELECT
    COUNT(*) AS total_funds,
    COUNTIF(`Investment Multiple` LIKE 'N/M%') AS expected_nulls,
    COUNTIF(
        `Investment Multiple` NOT LIKE 'N/M%'
        AND (
            CASE
                WHEN `Investment Multiple` LIKE 'N/M%' THEN NULL
                ELSE CAST(
                    REPLACE(
                        REPLACE(
                            REPLACE(`Investment Multiple`, CHR(160), ' '),
                            ' 1',
                            ''
                        ),
                        'x',
                        ''
                    ) AS NUMERIC
                )
            END
        ) IS NULL
    ) AS unexpected_nulls
FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- 4. Fund performance: Create and validate clean table

CREATE OR REPLACE TABLE `pe-fund-insights-project.calpers_pe.clean_fund_performance` AS

SELECT
    Fund AS fund_name,
    `Vintage Year` AS vintage_year,
    `Capital Committed` AS capital_committed,
    `Cash In` AS cash_in,
    `Cash Out` AS cash_out,
    `Cash Out & Remaining Value` AS total_value,

    CASE
        WHEN `Net IRR` LIKE 'N/M%' THEN NULL
        ELSE CAST(
            REPLACE(
                REPLACE(
                    REPLACE(`Net IRR`, CHR(160), ' '),
                    ' 1',
                    ''
                ),
                '%',
                ''
            ) AS NUMERIC
        ) / 100
    END AS net_irr,

    CASE
        WHEN `Investment Multiple` LIKE 'N/M%' THEN NULL
        ELSE CAST(
            REPLACE(
                REPLACE(
                    REPLACE(`Investment Multiple`, CHR(160), ' '),
                    ' 1',
                    ''
                ),
                'x',
                ''
            ) AS NUMERIC
        )
    END AS investment_multiple

FROM `pe-fund-insights-project.calpers_pe.raw_fund_performance`;


-- Validate clean fund performance table
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT fund_name) AS unique_funds,
    COUNTIF(net_irr IS NULL) AS missing_net_irr,
    COUNTIF(investment_multiple IS NULL) AS missing_investment_multiple
FROM `pe-fund-insights-project.calpers_pe.clean_fund_performance`;


-- 5. Manager mapping: Inspect name consistency

SELECT
    fund_manager,
    COUNT(*) AS fund_count
FROM `pe-fund-insights-project.calpers_pe.raw_fund_managers`
GROUP BY fund_manager
ORDER BY fund_manager;


-- 6. Manager mapping: Standardize manager names

SELECT
    fund_name,
    CASE
        WHEN LOWER(fund_manager) IN (
            'hedosophia',
            'hedosophia management limited'
        ) THEN 'Hedosophia'

        WHEN LOWER(fund_manager) IN (
            'hg',
            'hgcapital'
        ) THEN 'Hg'

        WHEN LOWER(fund_manager) IN (
            'welsh, carson, anderson & stowe',
            'welsh, carson, anderson & stowe (wcas)'
        ) THEN 'Welsh, Carson, Anderson & Stowe'

        ELSE fund_manager
    END AS fund_manager_clean
FROM `pe-fund-insights-project.calpers_pe.raw_fund_managers`;


-- 7. Manager mapping: Create and validate clean table

CREATE OR REPLACE TABLE `pe-fund-insights-project.calpers_pe.clean_fund_managers` AS

SELECT
    fund_name,
    CASE
        WHEN LOWER(fund_manager) IN (
            'hedosophia',
            'hedosophia management limited'
        ) THEN 'Hedosophia'

        WHEN LOWER(fund_manager) IN (
            'hg',
            'hgcapital'
        ) THEN 'Hg'

        WHEN LOWER(fund_manager) IN (
            'welsh, carson, anderson & stowe',
            'welsh, carson, anderson & stowe (wcas)'
        ) THEN 'Welsh, Carson, Anderson & Stowe'

        ELSE fund_manager
    END AS fund_manager

FROM `pe-fund-insights-project.calpers_pe.raw_fund_managers`;


-- Validate clean manager mapping table
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT fund_name) AS unique_funds,
    COUNT(DISTINCT fund_manager) AS unique_managers,
    COUNTIF(fund_manager IS NULL) AS missing_managers
FROM `pe-fund-insights-project.calpers_pe.clean_fund_managers`;
