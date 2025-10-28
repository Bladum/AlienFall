#!/usr/bin/env python3
"""AlienFall Build Script - Cross-platform"""

import os
import shutil
import zipfile
from pathlib import Path
from datetime import datetime

def log(message, level='INFO'):
    timestamp = datetime.now().strftime('%H:%M:%S')
    prefix = {
        'INFO': '[INFO]',
        'SUCCESS': '[✓]',
        'ERROR': '[✗]',
        'WARN': '[!]'
    }.get(level, '[*]')
    print(f'{timestamp} {prefix} {message}')

def build():
    # Setup paths
    build_dir = Path(__file__).parent.absolute()
    project_root = build_dir.parent
    engine_dir = project_root / 'engine'
    mods_dir = project_root / 'mods'
    output_dir = build_dir / 'output'
    temp_dir = build_dir / 'temp'
    package_dir = temp_dir / 'package'

    log('='*50)
    log('AlienFall Build System', 'INFO')
    log('='*50)
    log('')

    # Read version
    version_file = build_dir / 'version.txt'
    version = version_file.read_text().strip()
    log(f'Version: {version}', 'INFO')
    log(f'Build directory: {build_dir}', 'INFO')
    log('')

    # Create directories
    log('Setting up directories...', 'INFO')
    output_dir.mkdir(exist_ok=True)
    package_dir.mkdir(parents=True, exist_ok=True)

    # Clear old package
    if package_dir.exists():
        shutil.rmtree(package_dir)
    package_dir.mkdir(parents=True, exist_ok=True)
    log('Directories created', 'SUCCESS')
    log('')

    # Validate
    log('Validating engine structure...', 'INFO')
    errors = 0

    if not (engine_dir / 'main.lua').exists():
        log('main.lua not found!', 'ERROR')
        errors += 1

    if not (engine_dir / 'conf.lua').exists():
        log('conf.lua not found!', 'ERROR')
        errors += 1

    if not (mods_dir / 'core' / 'mod.toml').exists():
        log('Core mod not found!', 'ERROR')
        errors += 1

    if errors > 0:
        log(f'{errors} validation errors!', 'ERROR')
        return False

    log('Engine structure OK', 'SUCCESS')
    log('')

    # Copy engine
    log('Copying engine files...', 'INFO')
    try:
        for item in engine_dir.iterdir():
            if item.is_dir():
                shutil.copytree(item, package_dir / item.name, dirs_exist_ok=True)
            else:
                shutil.copy2(item, package_dir / item.name)
        log('Engine copied', 'SUCCESS')
    except Exception as e:
        log(f'Failed to copy engine: {e}', 'ERROR')
        return False

    # Copy mods
    log('Copying mods directory...', 'INFO')
    try:
        mods_dest = package_dir / 'mods'
        mods_dest.mkdir(exist_ok=True)
        for item in mods_dir.iterdir():
            if item.is_dir():
                shutil.copytree(item, mods_dest / item.name, dirs_exist_ok=True)
            else:
                shutil.copy2(item, mods_dest / item.name)
        log('Mods copied', 'SUCCESS')
    except Exception as e:
        log(f'Failed to copy mods: {e}', 'ERROR')
        return False

    # Clean up test files
    log('Removing test files...', 'INFO')
    test_files = ['.luarc.json', 'test_scan.lua', 'simple_test.lua']
    for test_file in test_files:
        test_path = package_dir / test_file
        if test_path.exists():
            test_path.unlink()
    log('Cleanup complete', 'SUCCESS')
    log('')

    # Create .love file
    log('Creating .love file...', 'INFO')
    love_file = output_dir / 'alienfall.love'

    try:
        # Remove old love file if exists
        if love_file.exists():
            love_file.unlink()

        # Create ZIP archive
        with zipfile.ZipFile(love_file, 'w', zipfile.ZIP_DEFLATED) as zf:
            for root, dirs, files in os.walk(package_dir):
                for file in files:
                    file_path = Path(root) / file
                    arcname = file_path.relative_to(package_dir)
                    zf.write(file_path, arcname)

        # Verify
        if not love_file.exists():
            log('.love file not created!', 'ERROR')
            return False

        file_size_mb = love_file.stat().st_size / (1024 * 1024)
        log(f'.love file created: {file_size_mb:.2f} MB', 'SUCCESS')

    except Exception as e:
        log(f'Failed to create .love file: {e}', 'ERROR')
        return False

    log('')
    log('='*50)
    log('Build Complete!', 'SUCCESS')
    log('='*50)
    log('')
    log('Output directory:')
    for file in output_dir.iterdir():
        size_mb = file.stat().st_size / (1024 * 1024)
        log(f'  {file.name} - {size_mb:.2f} MB', 'INFO')
    log('')
    log(f'To test: love {love_file}', 'INFO')
    log('')

    return True

if __name__ == '__main__':
    success = build()
    exit(0 if success else 1)

