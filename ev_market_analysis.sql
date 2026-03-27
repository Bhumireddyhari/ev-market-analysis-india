-- ============================================================
--  AtliQ Motors | India EV Market Analysis
--  Analyst : Peter Pandey (Data Analytics Team)
--  Dataset : electric_vehicle_sales_by_makers
--            electric_vehicle_sales_by_state
--            dim_date
-- ============================================================

-- ── Schema Preview ──────────────────────────────────────────
SELECT * FROM dim_date;
SELECT * FROM electric_vehicle_sales_by_makers;
SELECT * FROM electric_vehicle_sales_by_state;


-- ============================================================
-- Q1. Top 3 & Bottom 3 Makers (2-Wheelers) — FY 2023 & 2024
-- ============================================================

-- Top 3
WITH cte AS (
    SELECT
        d.fiscal_year,
        e.maker,
        SUM(e.electric_vehicles_sold)                                          AS ev_sold,
        ROW_NUMBER() OVER (
            PARTITION BY d.fiscal_year
            ORDER BY SUM(e.electric_vehicles_sold) DESC
        )                                                                       AS rnk
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2023, 2024)
      AND e.vehicle_category = '2-Wheelers'
    GROUP BY d.fiscal_year, e.maker
)
SELECT fiscal_year, maker, ev_sold, rnk AS rank_top
FROM cte
WHERE rnk <= 3
ORDER BY fiscal_year, rnk;

-- Bottom 3
WITH cte AS (
    SELECT
        d.fiscal_year,
        e.maker,
        SUM(e.electric_vehicles_sold)                                          AS ev_sold,
        ROW_NUMBER() OVER (
            PARTITION BY d.fiscal_year
            ORDER BY SUM(e.electric_vehicles_sold) ASC
        )                                                                       AS rnk
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2023, 2024)
      AND e.vehicle_category = '2-Wheelers'
    GROUP BY d.fiscal_year, e.maker
)
SELECT fiscal_year, maker, ev_sold, rnk AS rank_bottom
FROM cte
WHERE rnk <= 3
ORDER BY fiscal_year, rnk;


-- ============================================================
-- Q2. Top 5 States — Highest EV Penetration Rate (FY 2024)
--     Separate for 2-Wheelers and 4-Wheelers
-- ============================================================

-- 4-Wheelers
WITH ranked AS (
    SELECT
        d.fiscal_year,
        es.state,
        ROUND(SUM(es.electric_vehicles_sold) / SUM(es.total_vehicles_sold) * 100, 2) AS penetration_rate,
        ROW_NUMBER() OVER (
            PARTITION BY d.fiscal_year
            ORDER BY SUM(es.electric_vehicles_sold) / SUM(es.total_vehicles_sold) DESC
        )                                                                              AS rnk
    FROM electric_vehicle_sales_by_state es
    JOIN dim_date d ON es.date = d.date
    WHERE d.fiscal_year = 2024
      AND es.vehicle_category = '4-Wheelers'
    GROUP BY es.state, d.fiscal_year
)
SELECT fiscal_year, state, penetration_rate
FROM ranked
WHERE rnk <= 5
ORDER BY penetration_rate DESC;


-- ============================================================
-- Q3. States with Negative EV Penetration (Decline) 2022 → 2024
-- ============================================================

WITH yearly AS (
    SELECT
        d.fiscal_year,
        es.state,
        SUM(es.electric_vehicles_sold)  AS ev_sold,
        SUM(es.total_vehicles_sold)     AS total_sold
    FROM electric_vehicle_sales_by_state es
    JOIN dim_date d ON es.date = d.date
    WHERE d.fiscal_year IN (2022, 2024)
    GROUP BY d.fiscal_year, es.state
),
pivoted AS (
    SELECT
        state,
        MAX(CASE WHEN fiscal_year = 2022 THEN ev_sold    / NULLIF(total_sold, 0) END) AS pen_2022,
        MAX(CASE WHEN fiscal_year = 2024 THEN ev_sold    / NULLIF(total_sold, 0) END) AS pen_2024
    FROM yearly
    GROUP BY state
)
SELECT
    state,
    ROUND(pen_2022 * 100, 4) AS penetration_2022_pct,
    ROUND(pen_2024 * 100, 4) AS penetration_2024_pct,
    ROUND((pen_2024 - pen_2022) * 100, 4) AS change_pct
FROM pivoted
WHERE pen_2024 < pen_2022
ORDER BY change_pct ASC;


-- ============================================================
-- Q4. Quarterly Trends — Top 5 EV Makers (4-Wheelers) 2022–2024
-- ============================================================

WITH maker_totals AS (
    SELECT
        e.maker,
        SUM(e.electric_vehicles_sold) AS total_ev_sold
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
      AND e.vehicle_category = '4-Wheelers'
    GROUP BY e.maker
    ORDER BY total_ev_sold DESC
    LIMIT 5
),
quarterly AS (
    SELECT
        d.fiscal_year,
        d.quarter,
        e.maker,
        SUM(e.electric_vehicles_sold) AS ev_sales
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
      AND e.vehicle_category = '4-Wheelers'
      AND e.maker IN (SELECT maker FROM maker_totals)
    GROUP BY d.fiscal_year, d.quarter, e.maker
)
SELECT fiscal_year, quarter, maker, ev_sales
FROM quarterly
ORDER BY maker, fiscal_year, quarter;


-- ============================================================
-- Q5. Delhi vs Karnataka — EV Sales & Penetration Rate (FY 2024)
-- ============================================================

SELECT
    d.fiscal_year,
    e.state,
    SUM(e.electric_vehicles_sold)                                                    AS ev_sold,
    ROUND(SUM(e.electric_vehicles_sold) / SUM(e.total_vehicles_sold) * 100, 2)      AS penetration_rate_pct
FROM dim_date d
JOIN electric_vehicle_sales_by_state e ON d.date = e.date
WHERE d.fiscal_year = 2024
  AND e.state IN ('Delhi', 'Karnataka')
GROUP BY d.fiscal_year, e.state
ORDER BY ev_sold DESC;


-- ============================================================
-- Q6. CAGR in 4-Wheeler Units — Top 5 Makers (2022 → 2024)
-- ============================================================

WITH yearly_sales AS (
    SELECT
        d.fiscal_year,
        e.maker,
        SUM(e.electric_vehicles_sold) AS total_sales
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
      AND e.vehicle_category = '4-Wheelers'
    GROUP BY d.fiscal_year, e.maker
),
top_5_makers AS (
    SELECT maker
    FROM (
        SELECT maker, SUM(total_sales) AS grand_total
        FROM yearly_sales
        GROUP BY maker
        ORDER BY grand_total DESC
        LIMIT 5
    ) t
),
pivot_sales AS (
    SELECT
        maker,
        MAX(CASE WHEN fiscal_year = 2022 THEN total_sales END) AS sales_2022,
        MAX(CASE WHEN fiscal_year = 2024 THEN total_sales END) AS sales_2024
    FROM yearly_sales
    WHERE maker IN (SELECT maker FROM top_5_makers)
    GROUP BY maker
)
SELECT
    maker,
    sales_2022,
    sales_2024,
    ROUND(POWER(sales_2024 / NULLIF(sales_2022, 0), 1.0 / 2) - 1, 4) AS CAGR
FROM pivot_sales
WHERE sales_2022 IS NOT NULL
  AND sales_2024 IS NOT NULL
ORDER BY CAGR DESC;


-- ============================================================
-- Q7. Top 10 States — Highest CAGR in Total Vehicles Sold (2022→2024)
-- ============================================================

WITH yearly_sales AS (
    SELECT
        d.fiscal_year,
        e.state,
        SUM(e.total_vehicles_sold) AS total_sales
    FROM dim_date d
    JOIN electric_vehicle_sales_by_state e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
    GROUP BY d.fiscal_year, e.state
),
pivot_sales AS (
    SELECT
        state,
        MAX(CASE WHEN fiscal_year = 2022 THEN total_sales END) AS sales_2022,
        MAX(CASE WHEN fiscal_year = 2024 THEN total_sales END) AS sales_2024
    FROM yearly_sales
    GROUP BY state
),
cagr_calc AS (
    SELECT
        state,
        sales_2022,
        sales_2024,
        CASE
            WHEN sales_2022 = 0 OR sales_2022 IS NULL THEN NULL
            ELSE POWER(sales_2024 / sales_2022, 1.0 / 2) - 1
        END AS CAGR
    FROM pivot_sales
)
SELECT *
FROM cagr_calc
WHERE CAGR IS NOT NULL
ORDER BY CAGR DESC
LIMIT 10;


-- ============================================================
-- Q8. Peak & Low Season Months for EV Sales (2022–2024)
-- ============================================================

-- Peak months (descending)
SELECT
    MONTHNAME(date)            AS month_name,
    SUM(electric_vehicles_sold) AS ev_sold
FROM electric_vehicle_sales_by_makers
GROUP BY MONTHNAME(date)
ORDER BY ev_sold DESC;

-- Low months (ascending)
SELECT
    MONTHNAME(date)            AS month_name,
    SUM(electric_vehicles_sold) AS ev_sold
FROM electric_vehicle_sales_by_makers
GROUP BY MONTHNAME(date)
ORDER BY ev_sold ASC;


-- ============================================================
-- Q9. Projected EV Sales in 2030 — Top 10 States by Penetration Rate
-- ============================================================

WITH state_yearly AS (
    SELECT
        d.fiscal_year,
        e.state,
        SUM(e.electric_vehicles_sold) AS ev_sales,
        SUM(e.total_vehicles_sold)    AS total_sales
    FROM dim_date d
    JOIN electric_vehicle_sales_by_state e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
    GROUP BY d.fiscal_year, e.state
),
top_states AS (
    SELECT state
    FROM state_yearly
    WHERE fiscal_year = 2024
    GROUP BY state
    ORDER BY SUM(ev_sales) / NULLIF(SUM(total_sales), 0) DESC
    LIMIT 10
),
pivot_sales AS (
    SELECT
        s.state,
        MAX(CASE WHEN s.fiscal_year = 2022 THEN s.ev_sales END) AS sales_2022,
        MAX(CASE WHEN s.fiscal_year = 2024 THEN s.ev_sales END) AS sales_2024
    FROM state_yearly s
    WHERE s.state IN (SELECT state FROM top_states)
    GROUP BY s.state
),
cagr_calc AS (
    SELECT
        state,
        sales_2022,
        sales_2024,
        CASE
            WHEN sales_2022 = 0 OR sales_2022 IS NULL THEN NULL
            ELSE POWER(sales_2024 / sales_2022, 1.0 / 2) - 1
        END AS CAGR
    FROM pivot_sales
)
SELECT
    state,
    sales_2024,
    ROUND(CAGR * 100, 2)                              AS cagr_pct,
    ROUND(sales_2024 * POWER(1 + CAGR, 6), 0)        AS projected_ev_sales_2030
FROM cagr_calc
WHERE CAGR IS NOT NULL
ORDER BY projected_ev_sales_2030 DESC;


-- ============================================================
-- Q10. Revenue Growth Rate — 4-Wheelers & 2-Wheelers (2022 vs 2024)
--      Assumed average unit prices:
--        4-Wheelers : ₹15,00,000
--        2-Wheelers : ₹1,20,000
-- ============================================================

WITH revenue AS (
    SELECT
        d.fiscal_year,
        e.vehicle_category,
        SUM(e.electric_vehicles_sold) AS units_sold,
        SUM(e.electric_vehicles_sold) *
            CASE e.vehicle_category
                WHEN '4-Wheelers' THEN 1500000
                WHEN '2-Wheelers' THEN  120000
            END                        AS revenue_inr
    FROM dim_date d
    JOIN electric_vehicle_sales_by_makers e ON d.date = e.date
    WHERE d.fiscal_year IN (2022, 2023, 2024)
    GROUP BY d.fiscal_year, e.vehicle_category
),
pivot_rev AS (
    SELECT
        vehicle_category,
        MAX(CASE WHEN fiscal_year = 2022 THEN revenue_inr END) AS rev_2022,
        MAX(CASE WHEN fiscal_year = 2023 THEN revenue_inr END) AS rev_2023,
        MAX(CASE WHEN fiscal_year = 2024 THEN revenue_inr END) AS rev_2024
    FROM revenue
    GROUP BY vehicle_category
)
SELECT
    vehicle_category,
    ROUND(rev_2022 / 1e7, 2)                                AS revenue_2022_cr,
    ROUND(rev_2023 / 1e7, 2)                                AS revenue_2023_cr,
    ROUND(rev_2024 / 1e7, 2)                                AS revenue_2024_cr,
    ROUND((rev_2024 - rev_2022) / rev_2022 * 100, 2)        AS growth_2022_vs_2024_pct,
    ROUND((rev_2024 - rev_2023) / rev_2023 * 100, 2)        AS growth_2023_vs_2024_pct
FROM pivot_rev
ORDER BY vehicle_category;


-- ============================================================
-- Secondary: Overall EV Sales — FY 2023 & 2024
-- (Context for customer behaviour / government incentive analysis)
-- ============================================================

SELECT
    d.fiscal_year,
    SUM(e.electric_vehicles_sold) AS total_ev_sold
FROM dim_date d
JOIN electric_vehicle_sales_by_state e ON d.date = e.date
WHERE d.fiscal_year IN (2023, 2024)
GROUP BY d.fiscal_year
ORDER BY total_ev_sold DESC;
