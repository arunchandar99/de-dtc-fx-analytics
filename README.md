# DTC FX Analytics

A complete data warehouse solution for a Direct-to-Consumer currency exchange business, built with **Snowflake** and **dbt Cloud**.

---

## Business Context

A currency exchange company is launching a new business segment: **Direct-to-Consumer (DTC) Branches**. These are physical retail locations where customers walk in and exchange currency.

This project builds the complete data infrastructure from scratch — from raw source data to analytics-ready dimensional models.

---

## Stakeholders & Business Questions

### CEO
- How is the DTC branch business performing overall?
- Which branches should we expand or close?
- What's our customer growth looking like?

### DTC Operations
- What's the customer throughput per branch?
- Are we staffed appropriately?
- Do we have enough cash inventory?
- What are our void/error rates?

### CFO & Finance
- Revenue by branch, by currency pair, by month
- What are our margins on each currency?
- Which branches are profitable?
- Does cash balance at end of day?

---

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Source Systems │     │    Snowflake    │     │    dbt Cloud    │
│                 │     │                 │     │                 │
│  - POS System   │────▶│  RAW Schema     │────▶│  Staging        │
│  - ADP (HR)     │     │  (VARIANT/JSON) │     │  Intermediate   │
│  - Reuters      │     │                 │     │  Marts          │
│  - Branch Mgmt  │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Data Model

### Star Schema Design

```
                    ┌──────────────┐
                    │ dim_branches │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────┴─────────┐    ┌────────────────┐
│dim_currencies│────│fct_transactions│────│ dim_customers  │
└──────────────┘    └──────┬─────────┘    └────────────────┘
                           │
                    ┌──────┴───────┐
                    │dim_employees │
                    └──────────────┘
```

### Dimensions
| Table | Description | Grain |
|-------|-------------|-------|
| dim_branches | Retail branch locations | One row per branch |
| dim_currencies | Supported currencies | One row per currency |
| dim_customers | Customer master data | One row per customer |
| dim_employees | Branch staff | One row per employee |

### Facts
| Table | Description | Grain |
|-------|-------------|-------|
| fct_transactions | Currency exchange transactions | One row per transaction line |
| fct_exchange_rates | Daily exchange rates | One row per currency pair per day |
| fct_daily_cash_inventory | Cash inventory counts | One row per branch per currency per day |
| fct_shifts | Employee shift data | One row per shift |
| fct_branch_performance | Branch performance summary | One row per branch per day type |

### Intermediate
| Table | Description |
|-------|-------------|
| int_daily_branch_summary | Daily aggregates with window functions |

### Snapshots
| Table | Description |
|-------|-------------|
| snp_employees | SCD Type 2 history tracking for employees |

---

## Project Structure

```
dtc-fx-analytics/
├── dbt_project.yml
├── packages.yml
├── models/
│   ├── staging/
│   │   ├── _schema.yml
│   │   ├── stg_branches.sql
│   │   ├── stg_currencies.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_employees.sql
│   │   ├── stg_exchange_rates.sql
│   │   ├── stg_transactions.sql
│   │   ├── stg_shifts.sql
│   │   └── stg_daily_cash_inventory.sql
│   ├── intermediate/
│   │   └── int_daily_branch_summary.sql
│   └── marts/
│       ├── dimensions/
│       │   ├── dim_branches.sql
│       │   ├── dim_currencies.sql
│       │   ├── dim_customers.sql
│       │   └── dim_employees.sql
│       └── facts/
│           ├── _facts__models.yml
│           ├── fct_transactions.sql
│           ├── fct_exchange_rates.sql
│           ├── fct_daily_cash_inventory.sql
│           ├── fct_shifts.sql
│           └── fct_branch_performance.sql
├── snapshots/
│   └── snp_employees.sql
├── macros/
│   ├── calculate_percentage.sql
│   ├── calculate_spread.sql
│   ├── cents_to_dollars.sql
│   ├── dollars_to_cents.sql
│   └── transaction_fee_tier.sql
├── seeds/
└── tests/
```

---

## Key Features Implemented

### 1. Data Ingestion
- JSON data loaded into Snowflake VARIANT columns
- Internal stage for file uploads
- COPY INTO with STRIP_OUTER_ARRAY for array handling

### 2. Staging Layer
- Parse JSON using Snowflake's `data:field::type` syntax
- Light transformations (rename, cast, clean)
- Materialized as views for always-fresh data

### 3. Dimensional Modeling
- Surrogate keys using `dbt_utils.generate_surrogate_key()`
- Star schema with fact tables joining to dimensions
- Conformed dimensions (dim_currencies used by multiple facts)

### 4. Incremental Processing
- `fct_transactions` uses incremental materialization
- Merge strategy with `unique_key`
- `is_incremental()` macro for conditional filtering

```sql
{{
    config(
        materialized='incremental',
        unique_key='transaction_line_id'
    )
}}

...

{% if is_incremental() %}
    where loaded_at > (select max(loaded_at) from {{ this }})
{% endif %}
```

### 5. SCD Type 2 (Snapshots)
- `snp_employees` tracks historical changes
- Monitors: branch_id, employee_role, status
- Automatic valid_from/valid_to management

```sql
{% snapshot snp_employees %}
{{
    config(
        target_schema='snapshots',
        unique_key='employee_id',
        strategy='check',
        check_cols=['branch_id', 'employee_role', 'status']
    )
}}
select * from {{ ref('stg_employees') }}
{% endsnapshot %}
```

### 6. Window Functions
- Running totals: `SUM() OVER (PARTITION BY ... ORDER BY ...)`
- Previous day comparison: `LAG()`
- Daily ranking: `DENSE_RANK()`

### 7. Custom Macros
| Macro | Purpose |
|-------|---------|
| `calculate_percentage` | Safe percentage calculation with NULL handling |
| `calculate_spread` | Calculate FX spread between buy/sell rates |
| `cents_to_dollars` | Currency conversion helper |
| `dollars_to_cents` | Currency conversion helper |
| `transaction_fee_tier` | Categorize transactions by amount |

### 8. Testing
- **Schema tests:** unique, not_null, relationships
- **accepted_values:** Validate day_type categories
- **Referential integrity:** Foreign key validation across tables

### 9. Documentation
- Model and column descriptions
- Generated dbt docs site
- Lineage visualization (DAG)

### 10. Deployment
- Production environment configured
- Scheduled daily job (6:00 AM)
- `dbt build` runs models, tests, and snapshots

---

## Snowflake Setup

### Database Structure
```sql
CREATE DATABASE dtc_fx;

CREATE SCHEMA dtc_fx.raw;
CREATE SCHEMA dtc_fx.staging;
CREATE SCHEMA dtc_fx.intermediate;
CREATE SCHEMA dtc_fx.marts;
CREATE SCHEMA dtc_fx.snapshots;
```

### Warehouse
```sql
CREATE WAREHOUSE dbt_wh
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
```

### Raw Tables
All raw tables use the same structure:
```sql
CREATE TABLE raw_transactions (
    id INT AUTOINCREMENT,
    data VARIANT,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

---

## Data Volume

| Table | Row Count |
|-------|-----------|
| raw_branches | 5 |
| raw_currencies | 10 |
| raw_employees | 20 |
| raw_customers | 141,131 |
| raw_exchange_rates | 6,579 |
| raw_transactions | 201,833 |
| raw_shifts | 10,216 |
| raw_daily_cash_inventory | 32,895 |

**Date Range:** January 1, 2023 to December 31, 2024 (2 years)

---

## How to Run

### Prerequisites
- Snowflake account
- dbt Cloud account
- GitHub repository

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/[username]/dtc-fx-analytics.git
```

2. **Configure dbt Cloud**
- Connect to Snowflake
- Set default schema
- Link GitHub repository

3. **Install packages**
```bash
dbt deps
```

4. **Load raw data**
- Upload JSON files to Snowflake stage
- Run COPY INTO commands

5. **Run the pipeline**
```bash
dbt build
```

6. **Generate documentation**
```bash
dbt docs generate
```

---

## dbt Commands Reference

| Command | Purpose |
|---------|---------|
| `dbt run` | Run all models |
| `dbt run -s staging` | Run only staging models |
| `dbt run -s +fct_transactions` | Run model and all upstream dependencies |
| `dbt test` | Run all tests |
| `dbt snapshot` | Run snapshots (SCD Type 2) |
| `dbt build` | Run models + tests + snapshots |
| `dbt build --full-refresh` | Rebuild incremental models from scratch |
| `dbt docs generate` | Generate documentation |

---

## Materializations Used

| Layer | Materialization | Reason |
|-------|-----------------|--------|
| Staging | View | Always-fresh, no storage cost |
| Intermediate | View | Reusable logic, no duplication |
| Marts (Dimensions) | Table | Query performance, surrogate keys |
| Marts (Facts) | Table / Incremental | Performance, large data volumes |
| Snapshots | Snapshot | SCD Type 2 history tracking |

---

## Testing Strategy

### Primary Keys
- `unique` + `not_null` on all primary keys

### Foreign Keys
- `not_null` + `relationships` on all foreign keys
- Validates referential integrity

### Business Rules
- `accepted_values` for categorical columns
- Ensures data quality at the source

---

## Technologies Used

- **Snowflake** — Cloud data warehouse
- **dbt Cloud** — Data transformation
- **GitHub** — Version control
- **Python** — Data generation scripts

---

## Author

Built as a portfolio project demonstrating end-to-end analytics engineering skills.
