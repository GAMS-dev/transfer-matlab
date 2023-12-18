function arg = parse_argument(args, index, name, validate_fun)
    n_args = numel(args);
    if index > n_args
        error('Argument ''%s'' (at position %d) missing.', name, index);
    end
    if ~isempty(validate_fun)
        arg = validate_fun(name, index, args{index});
    else
        arg = args{index};
    end
end
