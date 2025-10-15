import os
import csv
import toml
import datetime

# Path to the color.toml file
file_path = 'test.toml'

# Read the content of the file
with open(file_path, 'r') as file:
    color_config = toml.load(file)

print(color_config)
print(toml.dumps(color_config))

# Create the output directory if it doesn't exist
output_dir = '../toml'
os.makedirs(output_dir, exist_ok=True)

# List all CSV files in the parent directory
csv_files = [f for f in os.listdir('..') if f.endswith('.csv')]

def try_convert(value):
    if value.lower() in ['yes', 'true']:
        return True
    elif value.lower() in ['no', 'false']:
        return False
    elif value == '':
        return None
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            try:
                return datetime.datetime.strptime(value, '%Y-%m-%d').date()
            except ValueError:
                try:
                    return datetime.datetime.strptime(value, '%Y-%m').date()
                except ValueError:
                    value = value.strip()
                    if ',' in value:
                        value = [v.strip() for v in value.split(',')]
                        value = [{item.split('=')[0].strip(): item.split('=')[1].strip()} if '=' in item else item for item in value]
                    return value

for csv_file in csv_files:
    csv_path = os.path.join('..', csv_file)
    toml_path = os.path.join(output_dir, csv_file.replace('.csv', '.toml'))

    # Read the CSV file and convert to dictionary
    with open(csv_path, 'r') as file:
        reader = csv.DictReader(file)
        data = {row[reader.fieldnames[0]]: {k: try_convert(v) for k, v in row.items() if k != reader.fieldnames[0] and try_convert(v) is not None} for row in
                reader}

    # Write the dictionary to a TOML file
    with open(toml_path, 'w') as file:
        toml.dump(data, file)