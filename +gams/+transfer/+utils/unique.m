function list = unique(list)
    [~,idx,~] = unique(list, 'first');
    list = list(sort(idx));
end
