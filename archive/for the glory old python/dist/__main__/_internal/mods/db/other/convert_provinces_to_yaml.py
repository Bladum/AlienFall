import csv
import yaml
import re

def read_prov_mapping(file_path):
    prov_colors = {}
    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            prov_id = int(row['ID'])
            color = row['hex']
            prov_colors[prov_id] = color
    return prov_colors

def convert_csv_to_yaml(input_file, output_file, mapping_file):
    prov_colors = read_prov_mapping(mapping_file)
    data = {}
    with open(input_file, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            province_id = int(row.pop('id'))
            row['col_diff'] = row.pop('colonization difficulty')
            row['color'] = prov_colors.get(province_id, None)
            data[province_id] = row

    sorted_data = dict(sorted(data.items()))

    with open(output_file, 'w') as ymlfile:
        yaml.dump({'provinces': sorted_data}, ymlfile, default_flow_style=False)

input_file = '../provinces.csv'
output_file = '../provinces.yml'
mapping_file = '../../map/prov_mapping.txt'
convert_csv_to_yaml(input_file, output_file, mapping_file)
print(f"Data has been converted from {input_file} to {output_file}")