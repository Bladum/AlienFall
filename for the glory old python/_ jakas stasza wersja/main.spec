# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=['.'],
    binaries=[],
    datas=[
        ('data', 'data'),
        ('icon.ico', '.')],
    hiddenimports=[],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='main',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,  # Enable UPX compression
    upx_exclude=[],  # List of files to exclude from UPX compression
    runtime_tmpdir=None,
    console=False,
    icon='icon.ico'
)
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,  # Enable UPX compression
    upx_exclude=[],  # List of files to exclude from UPX compression
    name='game',
    outdir='C:/PRJ/GAME/dist/game/'  # Specify your custom output directory here
)

import shutil
import os

source = 'C:/PRJ/GAME/dist/game/_internal/data'
destination = 'C:/PRJ/GAME/dist/game/'
os.makedirs(destination, exist_ok=True)
shutil.move(source, destination)


destination = 'C:/PRJ/GAME/dist/game/'
os.startfile(destination)
