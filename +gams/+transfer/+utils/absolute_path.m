function path = absolute_path(path)

    if isstring(path)
        path = char(path);
    elseif ~ischar(path)
        error('Argument ''path'' (at position 1) must be ''string'' or ''char''.');
    end

    % replace ~ with home directory in path
    if ispc
        homedir = fullfile(getenv('HOMEDRIVE'), getenv('HOMEPATH'));
    else
        homedir = getenv('HOME');
    end
    path = regexprep(path, '^~', strrep(homedir, '\', '\\'));

    % get absolute path
    if isempty(regexp(path, '^([a-zA-Z]:\\|[a-zA-Z]:/|\\\\|/)', 'ONCE'))
        path = fullfile(pwd, path);
    end
    path = char(javaMethod('getCanonicalPath', javaObject('java.io.File', path)));

end
