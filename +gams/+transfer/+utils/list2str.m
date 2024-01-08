function str = list2str(list, varargin)
    % Convert a list to string
    %
    % s = Utils.list2str(l) converts the list l into a string with list
    % brackets '[' and ']'. List can be numerical or cell.
    % s = Utils.list2str(l, bl, bu) is as above, but with list brackets
    % bl and bu.
    %

    bracket_open = '[';
    bracket_close = ']';
    if nargin > 1
        bracket_open = varargin{1};
    end
    if nargin > 2
        bracket_close = varargin{2};
    end

    str = bracket_open;
    for i = 1:numel(list)
        if iscell(list)
            elem = list{i};
        else
            elem = list(i);
        end
        if ischar(elem) || isstring(elem)
            str = sprintf('%s%s', str, elem);
        else
            str = sprintf('%s%g', str, elem);
        end
        if i < numel(list)
            str = strcat(str, ',');
        end
    end
    str = strcat(str, bracket_close);
end
