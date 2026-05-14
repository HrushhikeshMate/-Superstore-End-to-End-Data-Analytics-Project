# 📊 Superstore End-to-End Data Analytics Project

A complete analytical pipeline built on the Kaggle Sample Superstore dataset — covering raw data
ingestion, Python-based cleaning, PostgreSQL star schema design, 18 analytical SQL queries, an
interactive Power BI dashboard, and 14 Matplotlib/Seaborn visualisations — culminating in
quantified, actionable business recommendations.

[![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20Matplotlib%20%7C%20Seaborn-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Star%20Schema%20%7C%20Window%20Functions-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-DAX%20%7C%20Interactive%20Dashboard-F2C811?logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)](https://jupyter.org/)

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Project Architecture](#️-project-architecture)
- [Repository Structure](#-repository-structure)
- [Setup & Reproduction](#-setup--reproduction)
- [Data Cleaning](#-data-cleaning-python)
- [Database Design](#️-database-design-postgresql)
- [SQL Analytics](#-sql-analytics)
- [Power BI Dashboard](#-power-bi-dashboard)
- [Key Findings](#-key-findings)
- [Recommendations](#-recommendations)
- [Tools & Technologies](#️-tools--technologies)
- [Future Work](#-future-work)

---

## 🔍 Project Overview

The Superstore dataset contains **9,993 transaction line items** across **5,009 orders** for a
US-based office supplies retailer spanning 2014–2017. This project analyses sales performance,
product profitability, customer behaviour, shipping efficiency, and geographic trends to surface
data-driven recommendations.

![KPI Banner](images/kpi_banner.png)

| Metric                              | Value  |
|-------------------------------------|--------|
| Total Sales                         | $2.30M |
| Total Profit                        | $286K  |
| Profit Margin                       | 12.5%  |
| Total Orders                        | 5,009  |
| Unique Customers                    | 793    |
| Loss Transactions                   | 1,871  |
| Profit Destroyed by Discounts >20%  | $135K  |

---

## 🏗️ Project Architecture

![Pipeline Diagram](images/pipeline_diagram.png)

| Stage         | Tool                 | Description                                            |
|---------------|----------------------|--------------------------------------------------------|
| Ingestion     | Python / Pandas      | Read raw CSV (9,994 rows, 21 columns)                  |
| Cleaning      | Python / Pandas      | Type casting, deduplication, derived columns           |
| Export        | Python / Pandas      | Cleaned CSV (9,993 rows, 23 columns)                   |
| Schema Design | PostgreSQL           | 5-table star schema (3 dimensions + 2 facts)           |
| ETL / Load    | PostgreSQL           | Staging table → dimension & fact loads with validation |
| SQL Analytics | PostgreSQL           | 18 queries across 6 business domains                   |
| Dashboard     | Power BI Desktop     | Interactive DAX dashboard with slicers & drill-through |
| Visualisation | Matplotlib / Seaborn | 14 EDA charts with annotated business insights         |
| Reporting     | PDF                  | Full project report with methodology & recommendations |

---

## 📁 Repository Structure

```
├── Superstore_Final.ipynb             # Jupyter notebook — data cleaning + 14 EDA visualisations
├── SUPERSTORE SCHEMA.sql              # PostgreSQL schema (5 tables, indexes, constraints)
├── SUPERSTORE DATA LOAD SCRIPT.sql    # ETL script — staging table → production loads
├── SUPERSTORE ANALYTICS QUERIES.sql   # 18 analytical SQL queries across 6 domains
├── Sample_Superstore.csv              # Raw dataset (source: Kaggle)
├── Sample_Superstore_Cleaned.csv      # Cleaned, analysis-ready dataset
├── Superstore Dashboard.pdf           # Static dashboard export
├── Superstore_Project_Report.pdf      # Full project report with findings & recommendations
├── images/                            # Visuals embedded in this README
└── README.md
```

> **Note:** SQL files use spaces in their filenames. When referencing from the command line,
> wrap in quotes: `psql -f "SUPERSTORE SCHEMA.sql"`.

---

## ⚙️ Setup & Reproduction

### Prerequisites

| Requirement      | Version | Notes                    |
|------------------|---------|--------------------------|
| Python           | 3.9+    | Tested on 3.10           |
| PostgreSQL       | 14+     | Tested on 14.x and 15.x |
| Power BI Desktop | Latest  | Free — Windows only      |
| Jupyter Notebook | Any     | Or JupyterLab            |

### Step 1 — Clone the repository

```bash
git clone https://github.com/HrushhikeshMate/-Superstore-End-to-End-Data-Analytics-Project.git
cd -Superstore-End-to-End-Data-Analytics-Project
```

### Step 2 — Install Python dependencies

```bash
pip install pandas matplotlib seaborn jupyter
```

### Step 3 — Run the Python notebook

```bash
jupyter notebook Superstore_Final.ipynb
```

Run all cells. This loads `Sample_Superstore.csv`, cleans and validates the data,
exports `Sample_Superstore_Cleaned.csv`, and generates all 14 EDA charts.

### Step 4 — Set up PostgreSQL

```sql
CREATE DATABASE superstore;
```

### Step 5 — Run the SQL files in order

```bash
psql -d superstore -f "SUPERSTORE SCHEMA.sql"
psql -d superstore -f "SUPERSTORE DATA LOAD SCRIPT.sql"
psql -d superstore -f "SUPERSTORE ANALYTICS QUERIES.sql"
```

> **Important:** Edit the file path inside `SUPERSTORE DATA LOAD SCRIPT.sql` to point to the
> absolute path of `Sample_Superstore_Cleaned.csv` on your local machine before running.

### Step 6 — Open the Power BI dashboard

Open `Superstore Dashboard.pdf` for the static export, or connect Power BI Desktop directly
to the PostgreSQL database to use the interactive version with live slicers and drill-through.

---

## 🧹 Data Cleaning (Python)

| Transformation        | Implementation                              | Reason                                                      |
|-----------------------|---------------------------------------------|-------------------------------------------------------------|
| Whitespace trimming   | `str.strip()` on all object columns         | Prevents silent `GROUP BY` mismatches on categorical fields |
| Date parsing          | `pd.to_datetime()` on Order/Ship Date       | Enables accurate date arithmetic and temporal aggregation   |
| Postal code padding   | `str.zfill(5)` on Postal Code               | Preserves leading zeros lost during CSV import              |
| Text standardisation  | `.str.title()` on Name, City, State         | Ensures consistent casing for joins and display             |
| Deduplication         | `drop_duplicates()` — 1 row removed         | Eliminates exact duplicate rows                             |
| `Days_to_Ship`        | `(Ship Date - Order Date).dt.days`          | Derived metric for shipping efficiency analysis             |
| `Is_Loss`             | `profit < 0 -> bool`                        | Pre-computed loss flag; avoids repeated CASE logic in SQL   |
| `High_Discount`       | `discount > 0.20 -> bool`                   | 20% threshold — the inversion point identified in analysis  |
| Validation assertions | `assert len(df) == 9993; assert nulls == 0` | Programmatic data integrity check before export             |

---

## 🗄️ Database Design (PostgreSQL)

![Star Schema Diagram](images/schema_diagram.png)

The database uses a **star schema** with three dimension tables and two fact tables.
**11 strategic indexes** cover: `order_date`, `is_loss`, `high_discount`, `category`,
`sub_category`, `region`, `state`, plus a composite index on `(order_date, geo_id)`.

---

## 📈 SQL Analytics

18 queries organised into 6 business domains:

| Domain             | Queries | SQL Techniques                                    |
|--------------------|---------|---------------------------------------------------|
| Sales Performance  | 4       | `GROUP BY`, `EXTRACT`, `TO_CHAR`, `NULLIF`        |
| Product Analytics  | 4       | `CASE` banding, `FILTER`, multi-level aggregation |
| Customer Analytics | 3       | CTEs, `NTILE(4)`, subqueries                      |
| Shipping & Ops     | 2       | `AVG`, `MIN`, `MAX` with multi-table JOINs        |
| Geographic         | 2       | Multi-table JOINs, `FILTER` clause                |
| Advanced Analytics | 3       | `LAG`, `RANK`, running `SUM`, `PARTITION BY`      |

---

## 📊 Power BI Dashboard

An interactive Power BI dashboard complements the Python/SQL analysis layer, providing a
live executive-facing view without requiring SQL or Python access.

| Component                  | Implementation                                        | Business Value                                          |
|----------------------------|-------------------------------------------------------|---------------------------------------------------------|
| KPI Card Strip             | DAX: Total Sales, Profit, Margin %, Orders            | Instant executive summary, refreshable from new data    |
| Sales by Region Map        | Filled map with profit margin colour scale            | Geographic loss identification without SQL              |
| Category Drill-Through     | Page-level: Category → Sub-Category → Product        | Trace margin issues to specific SKUs in three clicks    |
| Discount vs Profit Scatter | Scatter: discount rate (x) vs profit (y)             | Visual confirmation of the 20% inversion threshold      |
| Cross-Filter Slicers       | Year, Region, Segment, Category — affect all visuals | Ad-hoc exploration by any business user                 |
| Monthly Trend Line         | Line chart + seasonal DAX reference bands            | Q4 seasonality monitoring and year-over-year comparison |

---

## 📊 Key Findings

### Annual Revenue vs. Profit Margin

![Annual Sales vs Profit Margin](images/annual_sales_profit.png)

Revenue grew **51%** ($484K → $733K), but profit margin peaked at 13.4% in 2016 then declined
to 12.7% in 2017 — growth is outpacing margin efficiency.

---

### Discount Impact on Profitability

![Discount Impact](images/discount_impact.png)

Discounts above **20%** destroyed **$135K in profit**. Items at 0% discount average +$28.50
profit; items at 50%+ average −$58.20. Profitability inverts sharply at the 20% threshold.

---

### Sub-Category Profit Analysis

![Sub-Category Profit](images/subcategory_profit.png)

**Three sub-categories are structural loss-makers:** Tables (−$17.7K), Bookcases (−$3.5K),
and Supplies (−$1.2K) — unprofitable across all four years without exception.

---

### Regional Performance

![Regional Performance](images/regional_performance.png)

The **Central region** delivers only 7.9% profit margin vs. 14.9% for the West — nearly half.
Texas, Ohio, and Pennsylvania are the top loss-making states.

---

### Monthly Seasonality

![Monthly Trend](images/monthly_trend.png)

**Q4 drives ~33% of annual revenue** consistently across all four years. Q1 is the structural
trough at ~60% of the Q4 monthly run-rate — a predictable pattern that is systematically
under-exploited.

---

### Summary of Findings

1. Revenue grew 51% over 4 years, but 2017 margin underperformed the 2016 peak.
2. Discounts above 20% are reliably loss-generating with no compensating volume uplift.
3. Tables, Bookcases, and Supplies have been unprofitable every single year.
4. Central region has a ~7pp margin deficit vs. the West — structural, not a volume problem.
5. 98% of customers are repeat buyers — growth opportunity is share-of-wallet, not acquisition.
6. Q4 seasonality is predictable and consistent but systematically under-resourced.

---

## 💡 Recommendations

| Priority | Recommendation                                               | Est. Annual Impact |
|----------|--------------------------------------------------------------|--------------------|
| High     | Discount caps: Furniture 15%, Office Supplies 20%, Tech 25% | +$40K–$60K profit  |
| High     | Audit Tables + Bookcases — vendor renegotiation or remove   | +$21K profit       |
| Medium   | Central region margin recovery programme (TX, OH, PA)       | +$15K–$25K profit  |
| Medium   | RFM cross-sell to top 20% of customers                      | +$35K–$60K revenue |
| Medium   | Pre-position inventory + Q1 promotions for seasonality      | +$20K–$40K revenue |

**Conservative combined impact: +$76K–$106K profit improvement (+27–37% vs. 2017 baseline)**

---

## 🛠️ Tools & Technologies

| Tool / Library   | Version | Role                                               |
|------------------|---------|----------------------------------------------------|
| Python           | 3.9+    | Data cleaning, EDA, visualisation                  |
| Pandas           | Any     | Data manipulation and transformation               |
| Matplotlib       | Any     | Chart generation                                   |
| Seaborn          | Any     | Statistical visualisation                          |
| PostgreSQL       | 14+     | Star schema, ETL, analytical query execution       |
| Power BI Desktop | Latest  | Interactive dashboard, DAX measures, drill-through |
| Jupyter Notebook | Any     | Reproducible EDA environment                       |
| **Dataset**      | —       | [Sample Superstore — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) |

---

## 🚀 Future Work

- [ ] **Sales forecasting** — 12-month category-level forecast using ARIMA / Prophet
- [ ] **Customer churn prediction** — using RFM scores as features (scikit-learn)
- [ ] **Pipeline automation** — scheduled ETL with Apache Airflow or dbt
- [ ] **Power BI Service deployment** — publish with Row-Level Security for regional managers
- [ ] **Geospatial profit map** — choropleth of margin by state (Folium / GeoPandas)

---

## 📌 Known Issues & Improvements Pending

- SQL filenames contain spaces — rename to underscores for command-line compatibility
- `requirements.txt` not yet added — install packages manually per the Setup section above
- Commit history is shallow (project developed locally before upload)
- Repo name has a leading dash — rename via Settings > Repository name

---

## 👤 Author

**Hrushikesh Mate**
Data Analytics Portfolio Project · 2026

> Feel free to open an issue, fork the repo, or connect on LinkedIn if you have questions
> about the methodology or want to discuss the findings.

---

*Dataset: [Sample Superstore — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)*
