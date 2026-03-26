# 🏭 Manufacturing Casting Defect Analysis

**Tools:** MySQL · Power BI . Excel
**Domain:** Manufacturing Operations · Quality Engineering  
**Skills:** Exploratory Data Analysis · Process Parameter Analysis · Defect Root Cause Investigation · Business Impact Quantification · Dashboard Design

---

## 📌 Project Background

This project simulates a real-world manufacturing quality investigation for a metal casting production facility. The dataset covers **4,800 production batches** across 3 lines, 3 machines, 2 shifts, and 15 operators — spanning January to June 2024.

**The business problem:** defect rates are unacceptably high at **32.23%** against a target of **25%**. The goal was to use SQL-based EDA and Power BI to identify *where*, *when*, and *why* defects are occurring — and translate findings into actionable operational recommendations.

> This project is part of my Data Analyst career transition portfolio. I bring 3+ years of hands-on experience as an Industrial Engineer in casting and manufacturing operations — which means I understand not just the data, but the real-world physics and process context behind it.

---

## 📂 Repository Structure

```
casting-defect-analysis/
│
├── README.md
├── data/
│   └── casting_defects_raw.csv          ← source dataset (synthetic)
├── sql/
│   └── casting_defects_eda.sql          ← full EDA queries (MySQL)
└── dashboard/
    └── Casting_project.pbix             ← Power BI dashboard (3 pages)
```

---

## 📊 Dataset Overview

| Attribute | Detail |
|---|---|
| Rows (Batches) | 4,800 |
| Date Range | Jan 2024 – Jun 2024 |
| Total Parts Produced | 500,115 |
| Total Defects Found | 161,191 |
| **Overall Defect Rate** | **32.23%** |
| **Target Defect Rate** | **25%** |
| **Gap to Target** | **7.23 percentage points** |
| Total Scrap Cost | ~₹8 Million |
| Production Lines | L-1, L-2, L-3 |
| Machines | M-01, M-02, M-03 |
| Shifts | Day, Night |
| Operators | 15 |
| Defect Types | Blowhole, Cold Shut, Misrun, Shrinkage |
| Process Parameters | Mold Temp (°C), Pour Temp (°C), Moisture %, Sand Ratio |

---

## 🔍 Key Findings

### 1. 🚨 Overall Defect Rate — 32.23% (Target: 25%)
Nearly 1 in 3 parts produced had a defect. The 7.23 percentage point gap to target has resulted in **~₹8M in total scrap costs** across the analysis period — making this a critical quality and financial issue.

---

### 2. Night Shift Underperforms Significantly

| Shift | Defect Rate |
|---|---|
| Day | 29.60% |
| **Night** | **34.86%** |

Night shift shows an **~18% higher defect rate** than day shift. This gap likely reflects fatigue-related operator errors, reduced supervision intensity, and inconsistent process control during shift handovers — all common failure modes in real casting environments.

---

### 3. Machine M-03 Is the Primary Equipment Problem

| Machine | Defect Rate |
|---|---|
| M-01 | 28.82% |
| M-02 | 29.13% |
| **M-03** | **38.95%** |

M-03's defect rate is **35% higher** than M-01 and M-02 combined. It is also responsible for the highest share of scrap cost (~₹3.2M). This points strongly to maintenance deterioration, calibration drift, or machine-specific process instability.

---

### 4. Worst Combination: M-03 on Night Shift — 41.37% Defect Rate

The machine × shift cross-tab reveals the most critical failure point:

| Machine | Day | Night | **Total** |
|---|---|---|---|
| M-01 | 26.41% | 31.46% | 28.82% |
| M-02 | 26.64% | 31.59% | 29.13% |
| **M-03** | **36.34%** | **41.37%** | **38.95%** |
| **Total** | **29.60%** | **34.86%** | **32.23%** |

M-03 during Night shift is the single highest-risk operating combination in the facility. Interventions should be prioritised at this intersection.

---

### 5. Defect Types Are Evenly Distributed — No Single Dominant Cause

| Defect Type | Total Defects | Share |
|---|---|---|
| Misrun | 41,162 | ~25.5% |
| Shrinkage | 40,200 | ~24.9% |
| Blowhole | 40,104 | ~24.9% |
| Cold Shut | 39,725 | ~24.6% |

All four defect types occur at nearly equal frequency. This rules out a single root cause and confirms that **multiple process parameters are failing simultaneously** — requiring a systemic, multi-variable response rather than a single fix.

---

### 6. 🔬 Root Cause: Moisture Is the Dominant Process Variable

Process parameter banding reveals moisture % as the strongest predictor of defect rate:

| Moisture Band | Defect Rate |
|---|---|
| Low (<3%) | 27% |
| **Optimal (3–4.5%)** | **27%** |
| **High (>4.5%)** | **42%** |

When moisture exceeds 4.5%, defect rate spikes to **42%** — a 55% increase over the optimal band. By contrast, pour temperature shows **limited variation across bands** (~31–32%), confirming that **moisture control is the primary lever** for defect reduction.

Mold temperature and sand ratio outside optimal ranges also correlate with elevated defects, indicating broad process discipline issues beyond a single variable.

---

## 💡 Business Recommendations

| Priority | Action | Expected Impact |
|---|---|---|
| 🔴 High | **Prioritise M-03 for immediate maintenance inspection** — calibration, tooling wear, mold condition | Targets the machine driving 39% defect rate and ₹3.2M scrap cost |
| 🔴 High | **Implement moisture control SOP (target 3–4.5%)** — this is the dominant root cause variable | Defect rate could drop significantly in out-of-spec batches (currently hitting 42%) |
| 🟡 Medium | **Introduce real-time SPC monitoring** for moisture and temperature at operator workstations | Prevents out-of-range batches before defects occur, not after |
| 🟡 Medium | **Audit Night Shift process checks and handover procedures** — operator training, supervision presence | Closes the ~5 percentage point day/night gap |
| 🟢 Ongoing | **Track M-03 × Night shift combination monthly** as a leading indicator of facility health | Early warning for regression |

**Expected business impact:** Reducing defect rate from 32% → <25% would recover an estimated significant portion of the ₹8M scrap cost and substantially reduce rework and production downtime.

---

## 🛠️ SQL Analysis Structure

The SQL file (`casting_defects_eda.sql`) is organised into 6 sections:

| Section | Purpose |
|---|---|
| 0 — Table Setup | `CREATE TABLE` and CSV import instructions |
| 1 — Dataset Overview | Row counts, date range, null checks, data quality validation |
| 2 — Overall Defect Rate | Headline metric + monthly trend |
| 3 — Defect Breakdown | By shift, machine, line, defect type, operator, machine×shift cross-tab |
| 4 — Process Parameter Analysis | Moisture, pour temp, mold temp, sand ratio banded against defect rate |
| 5 — Summary Statistics | Min, max, avg, stddev for all numeric columns |
| 6 — Export Queries | Ready-to-export CSVs for Power BI (monthly trend, machine×shift, batch-level, machine stability over time) |

---

## 📈 Power BI Dashboard

The dashboard is built across **3 pages** and designed to tell a complete quality story from headline KPIs to root cause evidence.

### Page 1 — Overview
- Monthly Defect Rate Trend line chart (Jan–Jun 2024)
- Defect Rate % by Shift (bar chart)
- Defect Rate % by Machine (bar chart)
- Machine × Shift defect rate cross-tab with conditional formatting
- Interactive slicers: Shift, Machine ID, Production Date range

### Page 2 — Root Cause Analysis
- Defect Rate % by Moisture Band (bar chart)
- Defect Rate % by Pour Temp Band (bar chart)
- Key insight callout: moisture is the dominant process variable

### Page 3 — Business Impact & Recommendations
- KPI cards: Defect Rate %, Target Rate %, Gap to Target, Total Defective Parts, Total Scrap Cost
- Total Defects by Machine (bar chart)
- Total Defects by Shift (bar chart)
- Total Scrap Cost by Machine (bar chart)
- Recommendations and Expected Impact panels
  
---

## 👤 About Me

**Krishna Mohoto** — Industrial Engineer transitioning to Data Analyst  
3+ years in manufacturing operations, quality engineering (Volvo), and casting operations (Bangalore Metallurgicals)  
Led a real DMAIC initiative that reduced blowhole defects from **70% → 20%** in casting production

📧 krishnamohoto90@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/krishna-mohoto-3009b1175)

---

*Dataset is synthetic and created for portfolio purposes. Analysis performed using MySQL on a local server and visualised in Power BI. Queries were designed to replicate a typical manufacturing quality investigation workflow: data validation → defect rate calculation → categorical breakdown → process parameter analysis → business impact quantification.*
