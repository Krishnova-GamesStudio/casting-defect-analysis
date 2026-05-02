-- ============================================================
-- PROJECT: Manufacturing Defect Analysis
-- STEP 1: Exploratory Data Analysis (EDA)
-- Dataset: casting_defects_raw.csv
-- Tool: MySQL (adapt DATE functions if using SQLite/PostgreSQL)
-- ============================================================


-- ------------------------------------------------------------
-- SECTION 0: TABLE SETUP
-- Run this first to load your CSV into a SQL table
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS casting_defects (
    batch_id        VARCHAR(10),
    production_date DATE,
    shift           VARCHAR(10),
    line_id         VARCHAR(5),
    machine_id      VARCHAR(5),
    operator_id     VARCHAR(10),
    parts_produced  INT,
    defects_found   INT,
    defect_type     VARCHAR(30),
    mold_temp_c     NUMERIC(6,1),
    pour_temp_c     NUMERIC(7,1),
    moisture_pct    NUMERIC(4,2),
    sand_ratio      NUMERIC(4,2)
);

-- If importing via CSV in PostgreSQL:
-- COPY casting_defects FROM '/path/to/casting_defects_raw.csv'
-- CSV HEADER;

-- NOTE: Your date format is DD-MM-YYYY. If PostgreSQL throws a date error,
-- run this first:
-- SET datestyle = 'DMY';


-- ------------------------------------------------------------
-- SECTION 1: DATASET OVERVIEW
-- Understand the size, shape, and completeness of the data
-- ------------------------------------------------------------

-- 1.1 Total rows and date range
SELECT
    COUNT(*)                            AS total_batches,
    SUM(parts_produced)                 AS total_parts,
    SUM(defects_found)                  AS total_defects,
    MIN(production_date)                AS earliest_date,
    MAX(production_date)                AS latest_date
FROM casting_defects;


-- 1.2 Unique values in categorical columns
SELECT
    COUNT(DISTINCT batch_id)    AS unique_batches,
    COUNT(DISTINCT machine_id)  AS unique_machines,
    COUNT(DISTINCT operator_id) AS unique_operators,
    COUNT(DISTINCT line_id)     AS unique_lines,
    COUNT(DISTINCT shift)       AS unique_shifts,
    COUNT(DISTINCT defect_type) AS unique_defect_types
FROM casting_defects;


-- 1.3 Check for nulls in every column
SELECT
    COUNT(*) - COUNT(batch_id)        AS null_batch_id,
    COUNT(*) - COUNT(production_date) AS null_production_date,
    COUNT(*) - COUNT(shift)           AS null_shift,
    COUNT(*) - COUNT(line_id)         AS null_line_id,
    COUNT(*) - COUNT(machine_id)      AS null_machine_id,
    COUNT(*) - COUNT(operator_id)     AS null_operator_id,
    COUNT(*) - COUNT(parts_produced)  AS null_parts_produced,
    COUNT(*) - COUNT(defects_found)   AS null_defects_found,
    COUNT(*) - COUNT(defect_type)     AS null_defect_type,
    COUNT(*) - COUNT(mold_temp_c)     AS null_mold_temp,
    COUNT(*) - COUNT(pour_temp_c)     AS null_pour_temp,
    COUNT(*) - COUNT(moisture_pct)    AS null_moisture,
    COUNT(*) - COUNT(sand_ratio)      AS null_sand_ratio
FROM casting_defects;


-- 1.4 Check for impossible values (data quality flags)
SELECT
    SUM(CASE WHEN defects_found > parts_produced THEN 1 ELSE 0 END) AS defects_exceed_parts,
    SUM(CASE WHEN parts_produced <= 0            THEN 1 ELSE 0 END) AS zero_or_neg_parts,
    SUM(CASE WHEN defects_found < 0              THEN 1 ELSE 0 END) AS negative_defects,
    SUM(CASE WHEN moisture_pct < 0               THEN 1 ELSE 0 END) AS negative_moisture,
    SUM(CASE WHEN pour_temp_c < 1000             THEN 1 ELSE 0 END) AS suspicious_pour_temp
FROM casting_defects;


-- ------------------------------------------------------------
-- SECTION 2: OVERALL DEFECT RATE
-- Your headline metric — the number that goes in your README
-- ------------------------------------------------------------

-- 2.1 Overall defect rate
SELECT
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS overall_defect_rate_pct
FROM casting_defects;


-- 2.2 Monthly defect rate trend (time-series for Power BI line chart)
SELECT
    DATE_FORMAT(production_date, '%Y-%M')                         AS month,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY DATE_FORMAT(production_date, '%Y-%M')
ORDER BY month;


-- ------------------------------------------------------------
-- SECTION 3: DEFECT BREAKDOWN BY CATEGORY
-- Understand what types of defects are occurring and where
-- ------------------------------------------------------------

-- 3.1 Defect rate by shift
SELECT
    shift,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY shift
ORDER BY defect_rate_pct DESC;


-- 3.2 Defect rate by machine
SELECT
    machine_id,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY machine_id
ORDER BY defect_rate_pct DESC;


-- 3.3 Defect rate by production line
SELECT
    line_id,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY line_id
ORDER BY defect_rate_pct DESC;


-- 3.4 Defect type breakdown — volume and share (Pareto source data)
SELECT
    defect_type,
    SUM(defects_found)                                                    AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(SUM(defects_found)) OVER(), 2) AS pct_of_total
FROM casting_defects
GROUP BY defect_type
ORDER BY total_defects DESC;


-- 3.5 Defect rate by operator — top 5 worst performers
SELECT
    operator_id,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY operator_id
ORDER BY defect_rate_pct DESC
LIMIT 5;


-- 3.6 Cross-tab: machine x shift (spot the worst combination)
SELECT
    machine_id,
    shift,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY machine_id, shift
ORDER BY machine_id, shift;


-- ------------------------------------------------------------
-- SECTION 4: PROCESS PARAMETER ANALYSIS
-- How do mold temp, pour temp, moisture, and sand ratio
-- relate to defect rate? This feeds your correlation story.
-- ------------------------------------------------------------

-- 4.1 Moisture % bands vs defect rate
SELECT
    CASE
        WHEN moisture_pct < 3.0                THEN '1 - Low (<3%)'
        WHEN moisture_pct BETWEEN 3.0 AND 4.5  THEN '2 - Optimal (3-4.5%)'
        ELSE                                        '3 - High (>4.5%)'
    END                                                         AS moisture_band,
    COUNT(*)                                                    AS batches,
    ROUND(AVG(moisture_pct), 2)                                 AS avg_moisture,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY 1
ORDER BY 1;


-- 4.2 Pour temperature bands vs defect rate
SELECT
    CASE
        WHEN pour_temp_c < 1380                  THEN '1 - Low (<1380C)'
        WHEN pour_temp_c BETWEEN 1380 AND 1420   THEN '2 - Optimal (1380-1420C)'
        ELSE                                          '3 - High (>1420C)'
    END                                                         AS pour_temp_band,
    COUNT(*)                                                    AS batches,
    ROUND(AVG(pour_temp_c), 1)                                  AS avg_pour_temp,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY 1
ORDER BY 1;


-- 4.3 Mold temperature bands vs defect rate
SELECT
    CASE
        WHEN mold_temp_c < 195               THEN '1 - Low (<195C)'
        WHEN mold_temp_c BETWEEN 195 AND 215 THEN '2 - Optimal (195-215C)'
        ELSE                                      '3 - High (>215C)'
    END                                                         AS mold_temp_band,
    COUNT(*)                                                    AS batches,
    ROUND(AVG(mold_temp_c), 1)                                  AS avg_mold_temp,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY 1
ORDER BY 1;


-- 4.4 Sand ratio bands vs defect rate
SELECT
    CASE
        WHEN sand_ratio < 0.82                  THEN '1 - Low (<0.82)'
        WHEN sand_ratio BETWEEN 0.82 AND 0.88   THEN '2 - Optimal (0.82-0.88)'
        ELSE                                         '3 - High (>0.88)'
    END                                                         AS sand_ratio_band,
    COUNT(*)                                                    AS batches,
    ROUND(AVG(sand_ratio), 3)                                   AS avg_sand_ratio,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- SECTION 5: SUMMARY STATS FOR NUMERIC COLUMNS
-- Min, max, avg, stddev — helps spot outliers before analysis
-- ------------------------------------------------------------

SELECT
    'mold_temp_c' AS metric,
    ROUND(MIN(mold_temp_c),2) AS min_val,
    ROUND(MAX(mold_temp_c),2) AS max_val,
    ROUND(AVG(mold_temp_c),2) AS avg_val,
    ROUND(STDDEV(mold_temp_c),2) AS std_dev
FROM casting_defects

UNION ALL

SELECT
    'pour_temp_c',
    ROUND(MIN(pour_temp_c),2),
    ROUND(MAX(pour_temp_c),2),
    ROUND(AVG(pour_temp_c),2),
    ROUND(STDDEV(pour_temp_c),2)
FROM casting_defects

UNION ALL

SELECT
    'moisture_pct',
    ROUND(MIN(moisture_pct),2),
    ROUND(MAX(moisture_pct),2),
    ROUND(AVG(moisture_pct),2),
    ROUND(STDDEV(moisture_pct),2)
FROM casting_defects

UNION ALL

SELECT
    'sand_ratio',
    ROUND(MIN(sand_ratio),3),
    ROUND(MAX(sand_ratio),3),
    ROUND(AVG(sand_ratio),3),
    ROUND(STDDEV(sand_ratio),3)
FROM casting_defects;


-- ------------------------------------------------------------
-- SECTION 6: EXPORT QUERIES
-- Save these outputs as CSVs — they feed Excel and Power BI
-- ------------------------------------------------------------

-- Export 1: Monthly trend → monthly_defect_trend.csv
SELECT
    DATE_FORMAT(production_date, '%Y-%M')                         AS month,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY DATE_FORMAT(production_date, '%Y-%M')
ORDER BY month;


-- Export 2: Machine + shift breakdown → machine_shift_breakdown.csv
SELECT
    machine_id,
    shift,
    line_id,
    SUM(parts_produced)                                         AS total_parts,
    SUM(defects_found)                                          AS total_defects,
    ROUND(100.0 * SUM(defects_found) / SUM(parts_produced), 2) AS defect_rate_pct
FROM casting_defects
GROUP BY machine_id, shift, line_id
ORDER BY defect_rate_pct DESC;


-- Export 3: Batch-level with defect rate → batch_parameters.csv
-- Use this for scatter plots in Power BI (moisture vs defect rate, etc.)
SELECT 
    batch_id,
    production_date,
    machine_id,
    shift,
    line_id,
    operator_id,
    moisture_pct,
    pour_temp_c,
    mold_temp_c,
    sand_ratio,
    parts_produced,
    defects_found,
    ROUND(100.0 * defects_found / NULLIF(parts_produced, 0),
            2) AS defect_rate_pct
FROM
    casting_defects
ORDER BY production_date;
-- Export 4: machine stability over time 
-- use this produces a machine trend chart in Power BI.
SELECT
DATE_FORMAT(production_date,'%Y-%m') AS month,
machine_id,
ROUND(100 * SUM(defects_found) / SUM(parts_produced),2) defect_rate
FROM casting_defects
GROUP BY month, machine_id
ORDER BY month, machine_id;

