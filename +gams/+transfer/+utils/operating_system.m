function os = operating_system()
    os = '';
    if ispc
        os = 'windows';
    elseif ismac
        [~,result] = system('uname -v');
        if any(strfind(result, 'ARM64'))
            os = 'macos_arm';
        else
            os = 'macos';
        end
    elseif isunix
        os = 'linux';
    else
        error('Unknown operating system.');
    end
end
