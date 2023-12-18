function arg = validate(name, index, arg, classes)
    is_class = false;
    assert(numel(classes) > 0);
    for i = 1:numel(classes)
        if isa(arg, classes{i})
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
        error('Argument ''%s'' (at position %d) must be %s.', name, index, class_list);
    end
end
