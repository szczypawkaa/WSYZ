import random


def create_data(output_file):
    weeks = range(1, 53)
    stores = range(1, 11)
    products = ["ZIEMNIAKI", "BURAKI", "KAPUSTA", "MARCHEW"]

    lines = [
        f"{week} {store} {product} {random.randint(20, 100)}"
        for week in weeks
        for store in stores
        for product in products
    ]

    with open(output_file, 'w') as f:
        f.write("param weekly_sales :=\n")
        f.write("\n".join(lines))
        f.write("\n;\n")


if __name__ == "__main__":
    output_file = "weekly_sales2.dat"
    data = create_data(output_file)
    # write_sales_file(data, output_file)
