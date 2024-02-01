function labels = filter_unique_labels(alllabels, indices)
    idx = indices >= 1 & indices <= numel(alllabels);
    labels = cell(numel(indices), 1);
    labels(idx) = alllabels(indices(idx));
    labels(~idx) = {gams.transfer.Constants.UNDEFINED_UNIQUE_LABEL};
end
