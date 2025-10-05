import csv
import re

import chardet

input_file = '../archive/new_provs.txt'
output_file = '../archive/provinces2.csv'

# Define the columns to extract
columns = ['id', 'continent', 'region', 'area', 'terrain', 'religion',
           'climate', 'culture', 'goods', 'name', 'colonization_difficulty',
           'income', 'manpower', 'size_modifier']

# Initialize a list to store the extracted data
data = []

# Define a regex pattern to match the required fields
pattern = re.compile(r'^\s*(' + '|'.join(columns) + r')\s*=\s*"?([^"]*)"?\s*$')



# Detect the encoding of the input file
with open(input_file, 'rb') as file:
    raw_data = file.read()
    result = chardet.detect(raw_data)
    encoding = result['encoding']

# Open the input file with the detected encoding and read line by line
with open(input_file, 'r', encoding=encoding) as file:
    province_data = {}
    inside_province = False
    for line in file:
        line = line.strip()
        if line == 'province = {':
            province_data = {}
            inside_province = True
        elif line == '}':
            if province_data:
                #if province_data.get('terrain') != 'sea':
                data.append([province_data.get(col, '') for col in columns])
                #else:
                #    data.append(['' for _ in columns])
            inside_province = False
        elif inside_province:
            match = pattern.match(line)
            if match:
                key, value = match.groups()
                if key == 'name':
                    value = value.replace('PROV_', '')
                province_data[key] = value

# Write the extracted data to a CSV file
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(columns)
    writer.writerows(data)

print(f"Data has been written to {output_file}")

#
# input_file = '../provinces.csv'
# output_file = '../provinces.csv'

# # Read the file and remove duplicates based on the ID
# unique_lines = {}
# with open(input_file, 'r') as file:
#     for line in file:
#         if line.strip():  # Skip empty lines
#             id = line.split(':')[0]
#             if id not in unique_lines:
#                 unique_lines[id] = line
#
# # Write the unique lines back to the output file
# with open(output_file, 'w') as file:
#     for line in unique_lines.values():
#         file.write(line)




#
# import csv
#
# input_file = 'provinces.txt'
# columns = ['continent', 'area', 'region', 'culture', 'goods', 'religion', 'climate']
#
# # Initialize dictionaries to store unique values for each column
# unique_values = {col: set() for col in columns}
#
# # Read the input file and collect unique values
# with open(input_file, 'r') as file:
#     reader = csv.DictReader(file)
#     for row in reader:
#         for col in columns:
#             unique_values[col].add(row[col])
#
# # Write unique values to corresponding CSV files
# for col, values in unique_values.items():
#     output_file = f'{col}.csv'
#     with open(output_file, 'w', newline='') as file:
#         writer = csv.writer(file)
#         writer.writerow(['ID', col])
#         for idx, value in enumerate(sorted(values), start=1):
#             writer.writerow([idx, value])
#
# print("Unique values have been written to corresponding CSV files.")





# import csv
# import yaml
#
# # Load IDs from provinces.csv
# csv_ids = set()
# with open('provinces.csv', newline='') as csvfile:
#     reader = csv.reader(csvfile)
#     for row in reader:
#         if row[0].isdigit():
#             csv_ids.add(int(row[0]))
#
# # Load IDs from provinces.yml
# with open('provinces.yml', 'r') as ymlfile:
#     yml_data = yaml.safe_load(ymlfile)
#     yml_ids = {province['ID'] for province in yml_data['provinces'].values()}
#
# # Find IDs that are in one file but not the other
# csv_not_in_yml = csv_ids - yml_ids
# yml_not_in_csv = yml_ids - csv_ids
#
# print("IDs in CSV but not in YAML:", sorted(csv_not_in_yml))
# print("IDs in YAML but not in CSV:", sorted(yml_not_in_csv))
#
#
# import unicodedata
#
# input_file = '../provinces.csv'
# output_file = 'provinces_cleaned.csv'
#
# def remove_diacritics(text):
#     return ''.join(c for c in unicodedata.normalize('NFKD', text) if unicodedata.category(c) != 'Mn')
#
# with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8', newline='') as outfile:
#     for line in infile:
#         cleaned_line = remove_diacritics(line)
#         outfile.write(cleaned_line)
#
# print(f"Data has been written to {output_file} with diacritics removed.")






