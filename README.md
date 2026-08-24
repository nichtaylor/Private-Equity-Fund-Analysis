# Private Equity Fund Analysis

SQL analysis of 462 active CalPERS private equity funds using Google BigQuery, examining portfolio concentration, fund performance, vintage trends and manager relationships.

## Key Findings

**1. CalPERS' largest manager relationships are not its strongest-performing relationships**

Manager commitment size shows little relationship with observed performance, with correlations of just 0.11 with median Net IRR and 0.19 with median Investment Multiple. Several of the strongest-performing manager relationships also sit outside CalPERS' largest exposures.

**2. Performance varies substantially even across repeat manager relationships**

Among managers with at least three measurable active funds, median Investment Multiples range from 0.9x to 2.1x, while median Net IRRs range from -1.3% to 27.1%.

**3. Strong multiple outcomes are concentrated in a relatively small share of active funds**

Among 264 active funds with reported Investment Multiples, 92.8% are at or above cost, but only 17.8% have reached 2.0x+ and 4.2% have reached 3.0x+.

## About the Project

This project analyzes publicly available fund-level data from the [CalPERS Private Equity Program Fund Performance Review](https://www.calpers.ca.gov/investments/about-investment-office/investment-organization/pep-fund-performance).

The analysis uses the portfolio snapshot as of **September 30, 2025** and examines:

- Portfolio composition and commitment concentration
- Fund performance and return dispersion
- Performance and realization across vintages
- Manager performance, consistency and exposure

A separate manager mapping dataset was created to link individual funds to their respective fund managers and standardize manager names.

## Approach

The project follows an end-to-end SQL workflow:

**Raw data → quality checks → cleaning → manager enrichment → metric validation → portfolio, performance, vintage and manager analysis**

Manager performance comparisons require at least three active funds with reported performance, reducing the influence of individual fund outcomes.

## Important Limitation

The CalPERS Fund Performance Review contains **active investments only and excludes exited investments**. The analysis therefore represents a snapshot of the active portfolio and should not be interpreted as complete historical vintage or manager performance.

Older vintages are particularly affected, as fully realized and exited partnerships may no longer appear in the dataset. Performance reported by CalPERS as `N/M (Not Meaningful)` is excluded from performance-based analysis.

## Repository Structure

```text
Private-Equity-Fund-Analysis/
│
├── README.md
│
└── sql/
    ├── 01_data_quality.sql
    ├── 02_data_cleaning.sql
    ├── 03_data_integration.sql
    ├── 04_metric_validation.sql
    ├── 05_portfolio_analysis.sql
    ├── 06_performance_analysis.sql
    ├── 07_vintage_analysis.sql
    └── 08_manager_analysis.sql
```

## Data Source & Disclaimer

This independent, non-commercial portfolio project uses publicly available information from the California Public Employees' Retirement System (CalPERS) for educational purposes. The underlying CalPERS dataset is not redistributed in this repository and should be obtained directly from CalPERS.

Manager mappings, SQL transformations, calculations and analysis were prepared independently for this project and do not represent analysis or conclusions produced by CalPERS.

CalPERS is a trademark of the California Public Employees' Retirement System. This project is not affiliated with, sponsored by or endorsed by CalPERS.
