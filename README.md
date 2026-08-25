# Private Equity Fund Analysis

SQL analysis of 462 active CalPERS private equity funds using Google BigQuery, examining portfolio concentration, fund performance, vintage trends and manager relationships.

## Key Findings

**1. CalPERS' largest manager relationships do not correspond to its strongest performing relationships**

Manager commitment size shows little relationship with observed performance, with correlations of just 0.11 with median Net IRR and 0.19 with median Investment Multiple. Several of the strongest-performing manager relationships also sit outside CalPERS' largest exposures.

**2. The 2017 vintage emerges as the clear performance standout across active funds**

Among vintages with sufficient observations (≥5 funds), 2017 has the highest median Net IRR at 18.7% and Investment Multiple at 2.3x, alongside the highest lower-quartile multiple at 1.9x, with 66.7% of funds reaching 2.0x or above.

**3. Portfolio value creation is heavily concentrated among a subset of active funds**

As of September 2025, the top 20% of active funds account for 68.6% of the portfolio's net value above contributed capital (_total value less cash in_), while the top half account for 96.9%. Although most funds in the bottom half remain above cost, they collectively account for just 3.1%.

## About the Project

This project analyzes publicly available fund-level data from the [CalPERS Private Equity Program Fund Performance Review](https://www.calpers.ca.gov/investments/about-investment-office/investment-organization/pep-fund-performance).

The analysis uses the portfolio snapshot as of **September 30, 2025** and examines:

- Portfolio composition and commitment concentration
- Fund performance and return dispersion
- Performance and realization across vintages
- Manager performance, consistency and exposure

A separate manager mapping dataset was created to link individual funds to their respective fund managers and standardize manager names.

## Approach

The analysis follows a structured SQL workflow:

**Raw data → data quality checks → cleaning and standardization → fund-manager mapping → metric validation → portfolio, performance, vintage and manager analysis**

Manager level comparisons require at least three active funds with reported performance to reduce the influence of individual fund outcomes.

## Limitations

The CalPERS Fund Performance Review contains **active investments only and excludes exited investments**. The analysis therefore represents a snapshot of the active portfolio and should not be interpreted as complete historical vintage or manager performance.

Older vintages are particularly affected, as fully realized and exited partnerships may no longer appear in the dataset. Performance reported by CalPERS as N/M (Not Meaningful) is excluded from performance-based analysis.

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
