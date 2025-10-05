import re
import yaml

input_file = '../../org_ftg/Monarchs/monarchs_pol.txt'
output_file = '../monarchs/monarchs_pol.yaml'

def parse_date(date_str):
    match = re.match(r'year\s*=\s*(\d+)', date_str)
    year = match.group(1) if match else '1400'
    match = re.match(r'month\s*=\s*(\w+)', date_str)
    month = match.group(1) if match else '01'
    return f"{year}-{month}"

def parse_monarchs(file_path):
    monarchs = {}
    import chardet

    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
        encoding = result['encoding']
    monarch_id = 0
    with open(file_path, 'r', encoding=encoding) as file:
        content = file.read().split('\n')
        content = '\n'.join([line for line in content if not line.startswith("#")])
        pattern = re.compile(r'historicalmonarch\s*=\s*\{(.*?)\}\nhis', re.DOTALL)
        matches = pattern.findall(content)
        for match in matches:
            monarch = {}
            id_match = re.search(r'id\s*=\s*{\s*type\s*=\s*\d+\s*id\s*=\s*(\d+)\s*}.*?}', match, re.DOTALL)
            if id_match:
                monarch_id = id_match.group(1)
                monarch['ID'] = int(monarch_id)
            name_match = re.search(r'name\s*=\s*"([^"]+)"', match)
            if name_match:
                monarch['name'] = name_match.group(1)
            startdate_match = re.search(r'startdate\s*=\s*{(.*?)}', match, re.DOTALL)
            if startdate_match:
                monarch['start_date'] = parse_date(startdate_match.group(1))
            deathdate_match = re.search(r'deathdate\s*=\s*{(.*?)}', match, re.DOTALL)
            if deathdate_match:
                monarch['end_date'] = parse_date(deathdate_match.group(1))
            dip_match = re.search(r'DIP\s*=\s*(\d+)', match)
            if dip_match:
                monarch['DIP'] = int(dip_match.group(1))
            adm_match = re.search(r'ADM\s*=\s*(\d+)', match)
            if adm_match:
                monarch['ADM'] = int(adm_match.group(1))
            mil_match = re.search(r'MIL\s*=\s*(\d+)', match)
            if mil_match:
                monarch['MIL'] = int(mil_match.group(1))
            dormant_match = re.search(r'dormant\s*=\s*(\w+)', match)
            if dormant_match:
                monarch['dormant'] = dormant_match.group(1) == 'yes'
            monarch['remark'] = ''
            monarchs[ int(monarch_id) ] = monarch
    return monarchs

monarchs = parse_monarchs(input_file)

with open(output_file, 'w', encoding='utf-8') as file:
    yaml.dump(monarchs, file, allow_unicode=True, default_flow_style=False)

print(f"Data has been written to {output_file}")