# 📊 Superstore End-to-End Data Analytics Project

A comprehensive data analytics project covering the full lifecycle — from raw data ingestion and cleaning in **Python**, through relational database design and analytical queries in **PostgreSQL**, to exploratory data visualization — demonstrating how to turn raw transactional data into actionable business insights.

![Python](https://img.shields.io/badge/Python-Pandas%20|%20Matplotlib%20|%20Seaborn-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Star%20Schema%20|%20Window%20Functions-4169E1?logo=postgresql&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)

---

## 🔍 Project Overview

The Superstore dataset contains **9,993 transaction line items** across **5,009 orders** for a US-based office supplies retailer (2014–2017). This project analyses sales performance, product profitability, customer behaviour, shipping efficiency, and geographic trends to surface data-driven recommendations.

| Metric | Value |
|--------|-------|
| Total Sales | $2.30M |
| Total Profit | $286K |
| Profit Margin | 12.5% |
| Total Orders | 5,009 |
| Unique Customers | 793 |

---

## 🏗️ Project Architecture

```
Raw CSV → Python (Cleaning & Validation) → Cleaned CSV → PostgreSQL (Star Schema + ETL) → SQL Analytics → Python (Visualisation)
```

| Stage | Tool | Description |
|-------|------|-------------|
| Ingestion | Python / Pandas | Read raw CSV (9,994 rows, 21 columns) |
| Cleaning | Python / Pandas | Type casting, deduplication, derived columns |
| Export | Python / Pandas | Cleaned CSV (9,993 rows, 23 columns) |
| Schema Design | PostgreSQL | 5-table star schema (3 dimensions + 2 facts) |
| ETL / Load | PostgreSQL | Staging table → dimension & fact loads with validation |
| Analytics | PostgreSQL | 18 queries across 6 business domains |
| Visualisation | Matplotlib / Seaborn | 14 charts with business insights |

---

## 📁 Repository Structure

```
├── Superstore_code.ipynb              # Jupyter notebook — data cleaning + 14 EDA visualisations
├── SUPERSTORE_SCHEMA.sql              # PostgreSQL schema (5 tables, indexes, constraints)
├── SUPERSTORE_DATA_LOAD_SCRIPT.sql    # ETL script — staging table → production loads
├── SUPERSTORE_ANALYTICS_QUERIES.sql   # 18 analytical SQL queries across 6 domains
├── Sample_Superstore_Cleaned.csv      # Cleaned, analysis-ready dataset
├── Sample_Superstore.csv              # Raw dataset from Kaggle
├── Superstore_Project_Report.pdf      # Full project report with findings & recommendations
└── README.md
```

---

## 🧹 Data Cleaning (Python)

Key cleaning steps performed in the Jupyter notebook:

- Whitespace trimming on all string columns
- Date parsing (`Order Date`, `Ship Date`) from string to datetime
- Zero-padded postal codes to preserve leading zeros (e.g., `5401` → `05401`)
- Text standardisation (`.str.title()`) on categorical columns
- Derived columns: `Days_to_Ship`, `Is_Loss` (profit < 0), `High_Discount` (discount > 0.8)
- Deduplication (1 duplicate removed) and validation assertions

---

## 🗄️ Database Design (PostgreSQL)

The database uses a **star schema** with three dimension tables and two fact tables:

- **`geography`** (631 rows) — postal code, city, state, region
- **`customers`** (793 rows) — customer ID, name, segment
- **`products`** (1,862 rows) — product ID, name, category, sub-category
- **`orders`** (5,009 rows) — order ID, dates, ship mode (fact header)
- **`order_items`** (9,993 rows) — sales, quantity, discount, profit (fact detail)

Includes 11 strategic indexes on frequently filtered and joined columns.

---

## 📈 SQL Analytics

18 queries organised into 6 business domains:

| Domain | Highlights | SQL Techniques |
|--------|-----------|----------------|
| Sales Performance | Yearly KPIs, monthly trends, by region/segment | `GROUP BY`, `EXTRACT`, `TO_CHAR` |
| Product Analytics | Category margins, discount impact, top/bottom products | `CASE`, `FILTER`, multi-level aggregation |
| Customer Analytics | Top customers, repeat rate, RFM segmentation | CTEs, `NTILE` window function, subqueries |
| Shipping | Avg days by mode, performance by region | `AVG`, `MIN`, `MAX` with JOINs |
| Geographic | Top/bottom states by sales and profit | Multi-table JOINs, `FILTER` clause |
| Advanced | YTD running totals, MoM growth, product rankings | `LAG`, `RANK`, running `SUM`, `PARTITION BY` |

---

## 📊 Key Findings

1. **Revenue grew 51% over 4 years** ($484K → $733K), but profit margin peaked in 2016 (13.4%) and dipped in 2017 (12.7%).
2. **Discounts above 20% destroyed $135K in profit** — discounted items collectively lost $35K while non-discounted items generated $321K.
3. **Three sub-categories are loss-makers**: Tables (−$17.7K), Bookcases (−$3.5K), Supplies (−$1.2K).
4. **Central region underperforms** at 7.9% margin vs. 14.9% for the West — Texas, Ohio, and Pennsylvania are the top loss-making states.
5. **98% of customers are repeat buyers** — strong retention, with opportunity to grow share of wallet.
6. **Q4 drives disproportionate revenue** — consistent November–December spikes across all four years.

---

## 💡 Recommendations

- **Discount cap policy**: Max 15% for Furniture, 20% for Office Supplies, 25% for Technology.
- **Product portfolio review**: Audit Tables, Bookcases, and Supplies for pricing and vendor cost issues.
- **Central region deep-dive**: Investigate discount patterns, product mix, and shipping costs in loss-making states.
- **Seasonal alignment**: Front-load inventory and marketing budgets for Q4; target Q1 promotions to smooth revenue.
- **Customer growth**: Cross-sell high-margin products (Copiers, Paper, Labels) using RFM segmentation.

---

## 🛠️ Tools & Technologies

- **Python**: Pandas, Matplotlib, Seaborn
- **PostgreSQL**: Star schema, ETL, window functions, CTEs
- **Jupyter Notebook**: Documentation and reproducibility
- **Dataset**: [Sample Superstore (Kaggle)](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

---

## 🚀 Future Work

- Add **sales forecasting** using time-series models (ARIMA, Prophet)
- Implement **customer churn prediction** using RFM scores as features
- Automate the pipeline with **scheduled ETL** (Airflow or dbt)
- Expand geographic analysis with a **choropleth map** visualisation
