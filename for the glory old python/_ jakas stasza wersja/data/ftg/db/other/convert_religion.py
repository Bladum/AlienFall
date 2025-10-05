import yaml

def convert_religions_txt_to_yml(txt_path, yml_path):
    religions = {}
    current_religion = None

    with open(txt_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            if '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip().strip('{}')
                if current_religion is not None:
                    if key in ['group', 'subgroup', 'color', 'papacy', 'predominance', 'force_conversion', 'defender', 'annexable', 'annex_same_penalty', 'annex_other_penalty', 'reveal_map', 'whiteman', 'defectprovinceto_penalty', 'province_nationalism', 'province_religion', 'coastalprovince_bonus', 'stability_cost', 'missionary_placement_penalty', 'missionary_sprite', 'slaves_effect']:
                        religions[current_religion][key] = value
                    elif key in ['allowed_conversion', 'income_bonus', 'war', 'aggressiveness', 'conflict', 'heretic']:
                        religions[current_religion][key] = [v.strip() for v in value.split()]
                    else:
                        try:
                            religions[current_religion][key] = float(value)
                        except ValueError:
                            religions[current_religion][key] = value
            else:
                current_religion = line.split()[0]
                if current_religion not in religions:
                    religions[current_religion] = {}

    with open(yml_path, 'w') as file:
        yaml.dump({'religions': religions}, file, default_flow_style=False)

convert_religions_txt_to_yml('yml/religions.txt', '../religions_converted.yml')