import toml

def format_key(key):
    return f"{int(key):04d}"

def format_value(value):
    if isinstance(value, str):
        formatted_value = ''
        for i, char in enumerate(value):
            if char.isupper() and i != 0 and value[i - 1] != ' ':
                formatted_value += f"_{char.lower()}"
            else:
                formatted_value += char

        formatted_value = formatted_value.lower().replace(' ', '_')

        return formatted_value
    return value

def convert_provinces(input_file, output_file):
    with open(input_file, 'r') as file:
        data = toml.load(file)

    new_data = {}
    for key, value in data.items():
        new_key = format_key(key)
        new_value = {k: (format_value(v) if k in ['continent', 'area', 'region'] else v) for k, v in value.items()}
        new_data[new_key] = new_value

    with open(output_file, 'w') as file:
        toml.dump(new_data, file)

if __name__ == "__main__":
    convert_provinces('../province.toml', 'provinces_converted.toml')
#
# load provines.toml
# change key of each elemnt to format 0000, so add leading zeros
# make continent key lower case
# make area key lower case, replace ' ' with _ and for every capital letter in the name which is not first letter change it to lower case and add _ before so CSeaCoast will become c_sea_coast
# do the same task for region key as for area key