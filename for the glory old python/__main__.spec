# -*- mode: python ; coding: utf-8 -*-

from PyInstaller.utils.hooks import collect_data_files

src_data = [
    ( 'mods/ftg/*', 'mods/ftg' ),
    ( 'mods/ftg.yml', 'mods/ftg.yml' ),
]

a = Analysis(
    ['src/__main__.py'],
    pathex=['.'],  # Add the src directory to the pathex
    binaries=[],
    datas= src_data,
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure, a.zipped_data)
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='my_python_app',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='my_python_app',
    outdir='custom_output_directory'  # Specify your custom output directory here
)