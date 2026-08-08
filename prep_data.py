import csv, json

SRC = "sp500_companies.csv"
OUT = "sp500.json"

rows = []
with open(SRC) as f:
    r = csv.DictReader(f)
    for row in r:
        try:
            marketcap = float(row["Marketcap"])
        except ValueError:
            marketcap = 0
        try:
            employees = float(row["Fulltimeemployees"])
        except ValueError:
            employees = 0
        rows.append({
            "symbol": row["Symbol"],
            "name": row["Longname"] or row["Shortname"],
            "sector": row["Sector"],
            "marketcap": marketcap,
            "employees": employees,
        })

with open(OUT, "w") as f:
    json.dump(rows, f, indent=1)

print(f"wrote {len(rows)} companies to {OUT}")
