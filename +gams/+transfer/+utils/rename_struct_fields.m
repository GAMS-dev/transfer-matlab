function s_out = rename_struct_fields(s, old_labels, new_labels)
    % TODO check old_labels
    % TODO check new_labels
    s_out = struct();
    labels = fieldnames(s);
    for i = 1:numel(labels)
        idx = find(strcmp(labels{i}, old_labels), 1, 'first');
        if isempty(idx)
            s_out.(labels{i}) = s.(labels{i});
        else
            s_out.(new_labels{idx}) = s.(labels{i});
        end
    end
end
