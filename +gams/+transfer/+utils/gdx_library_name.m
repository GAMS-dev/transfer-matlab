function gdxlibname = gdx_library_name()
    switch gams.transfer.utils.operating_system()
    case 'windows'
        gdxlibname = 'gdxcclib64.dll';
    case 'linux'
        gdxlibname = 'libgdxcclib64.so';
    case {'macos', 'macos_arm'}
        gdxlibname = 'libgdxcclib64.dylib';
    otherwise
        error('Unknown operating system.');
    end
end
