import csv
from pathlib import Path

source = Path("ml-1m")
output = Path("import")
output.mkdir(exist_ok=True)

files = {
    "users": ["userId", "gender", "age", "occupation"],
    "movies": ["movieId", "title", "genres"],
    "ratings": ["userId", "movieId", "rating", "timestamp"],
}

for name, columns in files.items():
    with open(source / f"{name}.dat", encoding="latin-1") as infile:
        with open(output / f"{name}.csv", "w", newline="", encoding="utf-8") as outfile:
            writer = csv.writer(outfile)
            writer.writerow(columns)

            count = 0

            for line in infile:
                values = line.strip().split("::")
                writer.writerow(values[:len(columns)])
                count += 1

    print(f"{name}.csv: {count} rows")

print("Conversion finished!")
