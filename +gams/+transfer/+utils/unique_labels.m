function labels = unique_labels(labels)

    % check for universe
    for i = 1:numel(labels)
        if isequal(labels{i}, '*')
            labels{i} = 'uni';
        end
    end

    % check for uniqueness
    if numel(unique(labels)) ~= numel(labels)
        for i = 1:numel(labels)
            add = ['_', int2str(i)];
            if ~endsWith(labels{i}, add)
                labels{i} = strcat(labels{i}, add);
            end
        end
    end

end
