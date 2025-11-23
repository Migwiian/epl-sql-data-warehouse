# analyzing-customer-churn-drivers


---

## Problem Statement
* Telco is losing **27%** of its customers every month.
* Each lost customer = **\$1,200 LTV** (Lifetime Value).

---

## Goal
Identify the top **3–4 churn drivers** and quantify their **\$ impact** so Marketing & Retention can run targeted campaigns.

---

## Dataset
* **Source:** Kaggle: “Telco Customer Churn”
* **Size/Structure:** 7,043 customers, 21 features, churn flag already labelled.
* **Raw size:** 2.4 MB CSV $\rightarrow$ perfect for GitHub.

---

## Project Folder
telco-churn-analytics/
├── data/
│   ├── raw/telco_raw.csv
│   ├── cleaned/telco_clean.parquet
│   └── dictionary.md
├── sql/
│   ├── 01_schema.sql          -- DDL
│   ├── 02_etl.sql             -- cleaning & features
│   ├── 03_kpi_views.sql       -- KPIs
│   └── 04_churn_drivers.sql   -- top drivers
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_churn_profile.ipynb
│   ├── 03_logistic_model.ipynb
│   └── 04_xgb_shap.ipynb
├── dashboard/
│   ├── tableau_churn.twb
│   └── assets/wireframe.png
├── slides/
│   └── executive_summary.pdf
├── README.md
└── requirements.txt
