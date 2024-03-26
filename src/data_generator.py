import random
import re

from datetime import datetime
from data import (countries_cities, phone_country_codes, popular_first_name,
                  popular_last_name, random_address, email_providers)


def sanitize_name(name):
    return re.sub(r'[^a-zA-Z0-9_]', '', name)


def random_date(year_min, year_max):
    start = datetime(year_min, 1, 1)
    end = datetime(year_max, 12, 31)
    return start + (end - start) * random.random()


data_template = "('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}'),"

current_year = datetime.now().year

age_brackets = {
    'under_18': (current_year - 18, current_year - 1),
    '18_35': (current_year - 35, current_year - 19),
    '36_65': (current_year - 65, current_year - 36),
    'above_65': (current_year - 100, current_year - 66),
}

percentages = [16, 31, 28, 25]
num_entries = 100
entries_per_bracket = [int(p * num_entries / 100) for p in percentages]

for i, (bracket, (min_year, max_year)) in enumerate(age_brackets.items()):
    for _ in range(entries_per_bracket[i]):
        country = random.choice(list(countries_cities.keys()))
        city = random.choice(countries_cities[country])
        phone = phone_country_codes[country] + str(random.randint(1000000000, 9999999999))
        first_name = random.choice(popular_first_name[country])
        last_name = random.choice(popular_last_name[country])
        email_provider = random.choice(email_providers)
        address = random.choice(list(random_address.values()))
        birthday = random_date(min_year, max_year).strftime("%Y-%m-%d")
        gender = random.choice(['Male', 'Female', 'Other'])

        sanitized_first_name = sanitize_name(first_name)
        sanitized_last_name = sanitize_name(last_name)
        email = sanitized_first_name.lower() + "." + sanitized_last_name.lower() + "@" + email_provider

        print(data_template.format(sanitized_first_name, sanitized_last_name, email, address, city, country, phone, birthday, gender))
