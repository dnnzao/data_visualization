import random

# Sample words to construct the address names
words = ["Oak", "Pine", "Maple", "Cedar", "Elm", "Willow", "Birch", "Spruce", "Ash", "Beech", "Cherry", "Hazel", "Holly", "Ivy", "Linden"]

# Street types
street_types = ["Street", "Avenue", "Road", "Drive"]

# Function to generate a random address name
def generate_address_name():
    num_words = random.randint(2, 4)  # Number of words in the name
    name_words = random.sample(words, num_words)
    return " ".join(name_words)

# Function to generate a full address
def generate_address():
    name = generate_address_name()
    number = random.randint(10, 1200)
    street_type = random.choice(street_types)
    return f"{name} {number} {street_type}"

# Generate a dictionary of addresses
address_dict = {f"Address_{i+1}": generate_address() for i in range(100)}  # Generating 100 sample addresses

# Print the dictionary in a format-ready way
print("{")
for key, value in address_dict.items():
    print(f"    '{key}': '{value}',")
print("}")
