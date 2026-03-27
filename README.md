# ⚡ AtliQ Motors — India EV Market Analysis

> **Role:** Data Analyst (Peter Pandey) | **Client:** AtliQ Motors (Bruce Haryali, Chief — India)  
> **Tools:** MySQL  Excel  
> **Domain:** Automotive · Electric Vehicles · India Market Entry

---

## 📌 Project Overview

AtliQ Motors holds a **25% market share** in EV/Hybrid vehicles across North America. As part of their **India expansion strategy**, this project delivers a comprehensive data-driven market study of India's EV landscape (FY 2022–2024) to guide entry decisions.

---

## 🗂️ Repository Structure

```
atliq-ev-india-analysis/
│
├── sql/
│   └── ev_market_analysis.sql   # All 10 primary analysis queries
│
└── README.md
```

---

## 🗃️ Dataset Schema

| Table | Description |
|---|---|
| `dim_date` | Date dimension with fiscal year and quarter mapping |
| `electric_vehicle_sales_by_makers` | Month-wise EV sales by brand and vehicle category |
| `electric_vehicle_sales_by_state` | Month-wise EV and total vehicle sales by state |

---

## 📊 Primary Research Questions & SQL Coverage

| # | Question | Status |
|---|---|---|
| 1 | Top 3 & Bottom 3 2-Wheeler makers — FY 2023 & 2024 | ✅ |
| 2 | Top 5 states by EV penetration rate — FY 2024 | ✅ |
| 3 | States with negative EV penetration 2022 → 2024 | ✅ |
| 4 | Quarterly trends for top 5 EV makers (4-wheelers) 2022–2024 | ✅ |
| 5 | Delhi vs Karnataka — EV sales & penetration rate 2024 | ✅ |
| 6 | CAGR in 4-wheeler units — top 5 makers 2022 → 2024 | ✅ |
| 7 | Top 10 states by CAGR in total vehicles sold 2022 → 2024 | ✅ |
| 8 | Peak & low season months for EV sales 2022–2024 | ✅ |
| 9 | Projected EV sales 2030 — top 10 states by penetration rate | ✅ |
| 10 | Revenue growth rate — 2-wheelers & 4-wheelers (2022 vs 2024, 2023 vs 2024) | ✅ |

---

## 🔍 Key Insights (Summary)

- **Ola Electric & TVS** dominate the 2-wheeler EV segment in FY 2024
- **Goa, Kerala & Karnataka** lead in EV penetration rates
- **Tata Motors** commands the 4-wheeler EV space with the highest CAGR
- **March** is consistently the peak sales month (fiscal year-end effect)
- **Maharashtra & Karnataka** are projected to lead EV adoption by 2030

---

## 💡 Secondary Research Highlights

1. **Customer drivers** — Fuel cost savings, FAME-II subsidies, and rising petrol prices
2. **Top subsidy states** — Gujarat, Maharashtra, Delhi, Rajasthan
3. **Charging infra** — Karnataka & Maharashtra show strong correlation between stations and EV adoption
4. **Recommended brand ambassador** — A sustainability-focused, tech-forward Indian celebrity
5. **Ideal manufacturing state** — **Gujarat** (PLI scheme, port access, EV policy, ease of doing business)

---

## 🚀 Top 3 Recommendations for AtliQ Motors

1. **Enter via Karnataka & Maharashtra** — highest EV readiness, infrastructure, and consumer awareness
2. **Set up manufacturing in Gujarat** — best subsidies, logistics, and government support
3. **Launch 2-wheelers first** — larger market, lower price point, faster adoption curve in India

---

## ⚙️ How to Run the SQL

```sql
-- 1. Import the three tables into your MySQL database
-- 2. Open sql/ev_market_analysis.sql
-- 3. Run queries section by section (each block is clearly labeled)
```

> Tested on **MySQL 8.0+**. CTEs and window functions are used extensively.

---

## 📁 Data Source

Dataset provided as part of the **Codebasics Resume Project Challenge**.

---

## 👤 Author

**[Harivardhan Reddy]**  
Data Analyst | [LinkedIn]https://www.linkedin.com/in/harivardhan-reddy-bhumireddy/
