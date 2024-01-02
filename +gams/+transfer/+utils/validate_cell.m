function arg = validate_cell(name, index, arg, classes, dim)
    if ~iscell(arg)
        error('Argument ''%s'' (at position %d) must be cell.', name, index);
    end

    for k = 1:numel(arg)
        is_class = false;
        assert(numel(classes) > 0);
        for i = 1:numel(classes)
            if isa(arg{k}, classes{i})
                is_class = true;
                break;
            end
        end
        if ~is_class
            class_list = '';
            for i = 1:numel(classes)
                if i > 1
                    if i == numel(classes)
                        class_list = strcat(class_list, ' or ');
                    else
                        class_list = strcat(class_list, ', ');
                    end
                end
                class_list = strcat(class_list, '''', classes{i}, '''');
            end
            error('Argument ''%s'' (at position %d, element %d) must be %s.', name, index, k, class_list);
        end

        switch dim
        case 0
            if ~isscalar(arg{k})
                error('Argument ''%s'' (at position %d, element %d) must be scalar.', name, index, k);
            end
        case 1
            if ~isvector(arg{k})
                error('Argument ''%s'' (at position %d, element %d) must be vector.', name, index, k);
            end
        end
    end
end
