"""
Generates a synthetic 'Apple Retail Sales' dataset for a SQL portfolio project.
Produces 5 CSVs: category, products, stores, sales (~1M rows), warranty
"""
import numpy as np
import pandas as pd
from datetime import date, timedelta

rng = np.random.default_rng(42)

# ---------- 1. CATEGORY ----------
categories = [
    (1, "iPhone"), (2, "iPad"), (3, "Mac"), (4, "Apple Watch"),
    (5, "AirPods"), (6, "Apple TV"), (7, "HomePod"), (8, "Accessories"),
]
category_df = pd.DataFrame(categories, columns=["category_id", "category_name"])

# ---------- 2. PRODUCTS ----------
product_catalog = {
    1: [("iPhone 12", 699), ("iPhone 13", 799), ("iPhone 14", 899),
        ("iPhone 15", 999), ("iPhone 15 Pro", 1199), ("iPhone SE", 429)],
    2: [("iPad 9th Gen", 329), ("iPad Air", 599), ("iPad Mini", 499),
        ("iPad Pro 11-inch", 799), ("iPad Pro 12.9-inch", 1099)],
    3: [("MacBook Air M1", 999), ("MacBook Air M2", 1199), ("MacBook Pro 14-inch", 1999),
        ("MacBook Pro 16-inch", 2499), ("iMac 24-inch", 1299), ("Mac Mini", 699)],
    4: [("Apple Watch SE", 249), ("Apple Watch Series 8", 399),
        ("Apple Watch Series 9", 429), ("Apple Watch Ultra", 799)],
    5: [("AirPods 2nd Gen", 129), ("AirPods 3rd Gen", 169),
        ("AirPods Pro", 249), ("AirPods Max", 549)],
    6: [("Apple TV HD", 149), ("Apple TV 4K", 179)],
    7: [("HomePod Mini", 99), ("HomePod 2nd Gen", 299)],
    8: [("MagSafe Charger", 39), ("USB-C Power Adapter", 19),
        ("AppleCare+", 129), ("Leather Case", 59), ("Smart Keyboard", 179),
        ("Apple Pencil", 129)],
}

products = []
pid = 1
launch_start = date(2015, 1, 1)
launch_end = date(2023, 12, 31)
span_days = (launch_end - launch_start).days
for cat_id, plist in product_catalog.items():
    for name, price in plist:
        launch_date = launch_start + timedelta(days=int(rng.integers(0, span_days)))
        products.append((pid, name, cat_id, launch_date.isoformat(), price))
        pid += 1
products_df = pd.DataFrame(products, columns=["product_id", "product_name", "category_id", "launch_date", "price"])

# ---------- 3. STORES ----------
store_locations = [
    ("Cupertino Flagship", "Cupertino", "USA"), ("Fifth Avenue", "New York", "USA"),
    ("Union Square", "San Francisco", "USA"), ("Michigan Avenue", "Chicago", "USA"),
    ("Regent Street", "London", "UK"), ("Covent Garden", "London", "UK"),
    ("Opera", "Paris", "France"), ("Champs-Elysees", "Paris", "France"),
    ("Ginza", "Tokyo", "Japan"), ("Shibuya", "Tokyo", "Japan"),
    ("Dubai Mall", "Dubai", "UAE"), ("Mall of Emirates", "Dubai", "UAE"),
    ("Orchard Road", "Singapore", "Singapore"), ("IFC Mall", "Hong Kong", "China"),
    ("Sanlitun", "Beijing", "China"), ("Nanjing Road", "Shanghai", "China"),
    ("Infinite Loop", "Sydney", "Australia"), ("George Street", "Sydney", "Australia"),
    ("Bandra", "Mumbai", "India"), ("Saket", "New Delhi", "India"),
    ("Koramangala", "Bengaluru", "India"), ("Alexanderplatz", "Berlin", "Germany"),
    ("Kurfurstendamm", "Berlin", "Germany"), ("Via del Corso", "Rome", "Italy"),
    ("Toronto Eaton Centre", "Toronto", "Canada"), ("Yorkdale", "Toronto", "Canada"),
    ("Coex Mall", "Seoul", "South Korea"), ("Myeongdong", "Seoul", "South Korea"),
    ("Reforma", "Mexico City", "Mexico"), ("Paulista Avenue", "Sao Paulo", "Brazil"),
]
stores = [(i + 1, name, city, country) for i, (name, city, country) in enumerate(store_locations)]
stores_df = pd.DataFrame(stores, columns=["store_id", "store_name", "city", "country"])

# ---------- 4. SALES (~1,000,000 rows) ----------
N_SALES = 1_000_000
sale_start = date(2018, 1, 1)
sale_end = date(2024, 12, 31)
sale_span = (sale_end - sale_start).days

sale_ids = np.arange(1, N_SALES + 1)
sale_dates = np.array([sale_start + timedelta(days=int(d)) for d in rng.integers(0, sale_span, N_SALES)])
store_ids = rng.integers(1, len(stores) + 1, N_SALES)
product_ids = rng.integers(1, len(products) + 1, N_SALES)
quantities = rng.integers(1, 5, N_SALES)

sales_df = pd.DataFrame({
    "sale_id": sale_ids,
    "sale_date": [d.isoformat() for d in sale_dates],
    "store_id": store_ids,
    "product_id": product_ids,
    "quantity": quantities,
})

# ---------- 5. WARRANTY (subset of sales) ----------
N_CLAIMS = 45_000
claim_sale_ids = rng.choice(sale_ids, size=N_CLAIMS, replace=False)
claim_sale_dates = sales_df.set_index("sale_id").loc[claim_sale_ids, "sale_date"]
repair_statuses = ["Paid Repaired", "Warranty Void", "Replacement", "Repaired", "In Progress"]
status_weights = [0.30, 0.15, 0.20, 0.30, 0.05]

claims = []
for i, (sid, sdate) in enumerate(zip(claim_sale_ids, claim_sale_dates), start=1):
    sale_d = date.fromisoformat(sdate)
    days_after = int(rng.integers(1, 365))
    claim_date = sale_d + timedelta(days=days_after)
    if claim_date > sale_end:
        claim_date = sale_end
    status = rng.choice(repair_statuses, p=status_weights)
    claims.append((i, claim_date.isoformat(), sid, status))

warranty_df = pd.DataFrame(claims, columns=["claim_id", "claim_date", "sale_id", "repair_status"])

# ---------- WRITE CSVs ----------
out = "/home/claude/apple-retail-sql-project/data"
category_df.to_csv(f"{out}/category.csv", index=False)
products_df.to_csv(f"{out}/products.csv", index=False)
stores_df.to_csv(f"{out}/stores.csv", index=False)
sales_df.to_csv(f"{out}/sales.csv", index=False)
warranty_df.to_csv(f"{out}/warranty.csv", index=False)

print("category:", category_df.shape)
print("products:", products_df.shape)
print("stores:", stores_df.shape)
print("sales:", sales_df.shape)
print("warranty:", warranty_df.shape)
