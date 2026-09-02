# Apple Retail Sales — SQL Analytics Project

A portfolio SQL project analyzing 1,000,000+ synthetic Apple retail transactions
across 30 stores in 19 countries, covering products, sales, and warranty claims.
Built to demonstrate joins, aggregations, subqueries, CTEs, and window functions
on a realistically sized dataset in **MySQL**.

## Dataset

| Table       | Rows        | Description                                          |
|-------------|------------:|-------------------------------------------------------|
| `category`  | 8           | Product categories (iPhone, Mac, AirPods, etc.)       |
| `stores`    | 30          | Apple retail store locations worldwide                |
| `products`  | 35          | Individual products, launch dates, prices             |
| `sales`     | 1,000,000   | Transactions, 2018–2024                                |
| `warranty`  | 45,000      | Warranty claims linked to sales                        |

**Note:** the data is synthetically generated (`generate_data.py`) for
portfolio/practice purposes — it is not real Apple sales data.

### Entity-Relationship Diagram

```
category (1) ──< (many) products (1) ──< (many) sales >── (many) (1) stores
                                              │
                                              │ (1)
                                              ∨
                                          warranty (many)
```

- `products.category_id` → `category.category_id`
- `sales.product_id` → `products.product_id`
- `sales.store_id` → `stores.store_id`
- `warranty.sale_id` → `sales.sale_id`

## Project structure

```
apple-retail-sql-project/
├── README.md
├── generate_data.py           # regenerates the CSVs (optional, seeded/reproducible)
├── data/
│   ├── category.csv
│   ├── stores.csv
│   ├── products.csv
│   ├── sales.csv
│   └── warranty.csv
└── sql/
    ├── 01_schema.sql           # CREATE DATABASE + tables + indexes
    ├── 02_load_data.sql        # LOAD DATA INFILE import scripts
    └── 03_business_problems.sql  # 20 business questions + solutions
```

## Setup

1. Install MySQL 8+ and make sure `local_infile` is enabled:
   ```sql
   SET GLOBAL local_infile = 1;
   ```
2. Create the schema:
   ```bash
   mysql -u root -p < sql/01_schema.sql
   ```
3. Load the data (run from the project root so the relative CSV paths resolve,
   and connect with `--local-infile=1`):
   ```bash
   mysql -u root -p --local-infile=1 apple_retail < sql/02_load_data.sql
   ```
4. Run the analysis:
   ```bash
   mysql -u root -p apple_retail < sql/03_business_problems.sql
   ```

## Business problems solved (20 total)

**Easy:** stores per country, units sold per store, sales in a given month,
average price per category, filtering by country.

**Medium:** warranty claims per year, top-revenue store in a year, unique
products sold in a trailing period, warranty-void rate, stores with zero
claims, claim rate by price tier.

**Advanced (CTEs / window functions):** revenue rank of stores within each
country (`RANK()`), year-over-year revenue growth (`LAG()`), cumulative
monthly revenue (`SUM() OVER`), best-selling product per category
(`ROW_NUMBER()`), average time-to-claim by category, month-over-month
growth/decline classification per store, claim rate by country, and revenue
from recently launched products.

See `sql/03_business_problems.sql` for the full question + query for each.

## Sample insights (from this dataset)

- Total simulated revenue across all sales: **~$1.52B**
- Store distribution skews toward the USA, India, and China (4, 3, and 3
  stores respectively in the largest markets)
- Warranty-void claims make up **~15%** of all warranty claims
- Premium-tier products ($800+) show a measurably different claim rate than
  budget accessories — see Q11 for the exact breakdown

## Why this project

Built to demonstrate practical SQL skills — schema design, data loading at
scale, and analytical querying with joins, subqueries, CTEs, and window
functions — on a dataset large enough (1M+ rows) to make indexing and query
performance genuinely matter.
