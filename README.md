# 📊 Superstore End-to-End Data Analytics Project

A full-lifecycle data analytics project — from raw data ingestion and cleaning in **Python**, through relational database design and analytical queries in **PostgreSQL**, to interactive business dashboards in **Power BI** — demonstrating how to turn raw transactional data into actionable business decisions.

![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20Matplotlib%20%7C%20Seaborn-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Star%20Schema%20%7C%20Window%20Functions-4169E1?logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Interactive%20Dashboard-F2C811?logo=powerbi&logoColor=black)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)

---

## 🔍 Project Overview

The Superstore dataset contains **9,993 transaction line items** across **5,009 orders** for a US-based office supplies retailer (2014–2017). This project analyses sales performance, product profitability, customer behaviour, shipping efficiency, and geographic trends to surface data-driven recommendations.

| Metric | Value |
|---|---|
| Total Sales | $2.30M |
| Total Profit | $286K |
| Profit Margin | 12.5% |
| Total Orders | 5,009 |
| Unique Customers | 793 |

---

## 🏗️ Project Architecture

```
Raw CSV → Python (Cleaning & Validation) → Cleaned CSV → PostgreSQL (Star Schema + ETL) → SQL Analytics → Power BI Dashboard
```

| Stage | Tool | Description |
|---|---|---|
| Ingestion | Python / Pandas | Read raw CSV (9,994 rows, 21 columns) |
| Cleaning | Python / Pandas | Type casting, deduplication, derived columns |
| Export | Python / Pandas | Cleaned CSV (9,993 rows, 23 columns) |
| Schema Design | PostgreSQL | 5-table star schema (3 dimensions + 2 facts) |
| ETL / Load | PostgreSQL | Staging table → dimension & fact loads with validation |
| Analytics | PostgreSQL | 18 queries across 6 business domains |
| Visualisation | Matplotlib / Seaborn | 14 exploratory charts |
| Dashboard | Power BI | Interactive 3-page business dashboard |

---

## 📁 Repository Structure

```
├── Superstore_Final.ipynb                 # Jupyter notebook — data cleaning + 14 EDA visualisations
├── SUPERSTORE SCHEMA.sql                  # PostgreSQL schema (5 tables, indexes, constraints)
├── SUPERSTORE DATA LOAD SCRIPT.sql        # ETL script — staging table → production loads
├── SUPERSTORE ANALYTICS QUERIES.sql       # 18 analytical SQL queries across 6 domains
├── Sample_Superstore_Cleaned.csv          # Cleaned, analysis-ready dataset
├── Sample_Superstore.csv                  # Raw dataset from Kaggle
├── Superstore Dashboard.pdf               # Power BI dashboard export (PDF)
├── Superstore_Project_Report.pdf          # Full project report with findings & recommendations
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
|---|---|---|
| Sales Performance | Yearly KPIs, monthly trends, by region/segment | `GROUP BY`, `EXTRACT`, `TO_CHAR` |
| Product Analytics | Category margins, discount impact, top/bottom products | `CASE`, `FILTER`, multi-level aggregation |
| Customer Analytics | Top customers, repeat rate, RFM segmentation | CTEs, `NTILE` window function, subqueries |
| Shipping | Avg days by mode, performance by region | `AVG`, `MIN`, `MAX` with JOINs |
| Geographic | Top/bottom states by sales and profit | Multi-table JOINs, `FILTER` clause |
| Advanced | YTD running totals, MoM growth, product rankings | `LAG`, `RANK`, running `SUM`, `PARTITION BY` |

---

## 📊 Power BI Dashboard

The Power BI dashboard translates the SQL findings into three interactive report pages, connected directly to the PostgreSQL star schema.

| Page | Focus |
|---|---|
| **Executive Summary** | KPIs, revenue trend, profit by region and segment |
| **Product & Discount Analysis** | Sub-category margins, discount impact on profit |
| **Geographic Performance** | State-level sales and profit mapping, loss-state breakdown |

> 📄 Dashboard exported as PDF — see [`Superstore Dashboard.pdf`](./Superstore%20Dashboard.pdf)

### Dashboard Preview

<!-- Replace the paths below with your actual uploaded image filenames -->

**Page 1 — Executive Summary**
![Executive Summary](./dashboard_page1.png)

**Page 2 — Product & Discount Analysis**
![Product & Discount Analysis](./dashboard_page2.png)

**Page 3 — Geographic Performance**
![Geographic Performance](./dashboard_page3.png)

---

## 📊 Key Findings

1. **Revenue grew 51% over 4 years** ($484K → $733K), but profit margin peaked in 2016 (13.4%) and dipped in 2017 (12.7%) — growth is not translating to improved profitability.
2. **Discounts above 20% destroyed $135K in profit** — discounted items collectively lost $35K while non-discounted items generated $321K profit.
3. **Three sub-categories are structural loss-makers**: Tables (−$17.7K), Bookcases (−$3.5K), Supplies (−$1.2K) — not seasonal dips, consistent across all four years.
4. **Central region is the margin problem**: 7.9% vs. 14.9% for the West — Texas, Ohio, and Pennsylvania alone account for the majority of Central's losses.
5. **98% of customers are repeat buyers** — retention is strong, but average revenue per customer has not grown proportionally.
6. **Q4 drives disproportionate revenue** — consistent November–December spikes across all four years, with Q1 consistently the weakest quarter.

---

## 💡 Recommendations

- **Discount cap policy**: Max 15% for Furniture, 20% for Office Supplies, 25% for Technology — enforced at order entry.
- **Product portfolio review**: Audit Tables, Bookcases, and Supplies for vendor cost renegotiation or discontinuation.
- **Central region investigation**: Isolate whether margin gap is driven by discount rates, product mix, or shipping costs in loss-making states.
- **Seasonal strategy**: Front-load inventory and marketing for Q4; introduce Q1 promotions targeting high-margin categories (Copiers, Paper, Labels) to smooth revenue.
- **Wallet share growth**: Apply RFM segmentation to cross-sell high-margin products to the existing repeat-buyer base rather than acquiring new customers.

---

## 🛠️ Tools & Technologies

- **Python**: Pandas, Matplotlib, Seaborn
- **PostgreSQL**: Star schema design, ETL scripting, window functions, CTEs
- **Power BI**: Interactive dashboard connected to PostgreSQL star schema
- **Jupyter Notebook**: Reproducible cleaning and EDA workflow
- **Dataset**: [Sample Superstore — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

---

## 🚀 Future Work

- **Discount elasticity model**: Quantify the revenue-to-profit trade-off at each discount band to find the actual break-even threshold per category — rather than applying a blanket cap.
- **Central region churn analysis**: Determine whether low-margin Central customers are high-volume repeat buyers or one-time purchasers; the answer changes the fix.
- **Sales forecasting**: Time-series model (Prophet or ARIMA) scoped to the Q4 spike — specifically to answer how much inventory to pre-position by October.
- **Pipeline automation**: Schedule ETL with dbt or Airflow to keep the dashboard live on a rolling 30-day window.
