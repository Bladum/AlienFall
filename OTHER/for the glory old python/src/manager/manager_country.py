from src.db import TDB
db = TDB()


def process_before_all():
    print("  Country manager before processing")

    # Process countries
    for id, country in db.countries.items():
        country.process_before_all()

