import os
import toml

def load_toml_files(folder_path):
    toml_data = {}
    for filename in os.listdir(folder_path):
        if filename.endswith('.toml'):
            file_path = os.path.join(folder_path, filename)
            with open(file_path, 'r') as file:
                print("Loading TOML file:", file_path)
                data = toml.load(file)
                toml_data[filename] = data

                # Check for INCLUDE tag
                if 'INCLUDE' in data:
                    for include_file in data['INCLUDE']:
                        include_path = os.path.join(folder_path, include_file)
                        with open(include_path, 'r') as include:
                            print("  Loading included TOML file:", include_path)
                            toml_data[include_file] = toml.load(include)
    return toml_data



def display_toml_data(toml_data):
    for filename, data in toml_data.items():

        if filename.endswith('policy.toml'):
            print(f"Data from {filename}")
            print(toml.dumps(data))
            print()

if __name__ == "__main__":
    folder_path = '../toml'  # Adjust the folder path as needed
    toml_data = load_toml_files(folder_path)
    display_toml_data(toml_data)