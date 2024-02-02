function flag = supports_table()
    flag = true;
    try
        table();
    catch
        flag = false;
    end

    env = getenv('GAMS_TRANSFER_MATLAB_SUPPORTS_TABLE');
    if ~isempty(env)
        if strcmpi(env, 'true')
            flag = true;
        elseif strcmpi(env, 'false')
            flag = false;
        end
    end
end
