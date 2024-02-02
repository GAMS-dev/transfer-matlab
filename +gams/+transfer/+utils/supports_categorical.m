function flag = supports_categorical()
    flag = true;
    try
        categorical();
    catch
        flag = false;
    end

    env = getenv('GAMS_TRANSFER_MATLAB_SUPPORTS_CATEGORICAL');
    if ~isempty(env)
        if strcmpi(env, 'true')
            flag = true;
        elseif strcmpi(env, 'false')
            flag = false;
        end
    end
end
