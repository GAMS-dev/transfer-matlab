% Categorical Column of Tabular Data based Unique Labels (internal)
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the 'Software'), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%
% ------------------------------------------------------------------------------
%
% Categorical Column of Tabular Data based Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) CategoricalColumn < gams.transfer.unique_labels.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        data_
        domain_
    end

    properties (Dependent)
        data
        domain
    end

    methods

        function data = get.data(obj)
            data = obj.data_;
        end

        function set.data(obj, data)
            gams.transfer.utils.Validator('data', 1, data).type('gams.transfer.symbol.data.Tabular');
            obj.data_ = data;
        end

        function domain = get.domain(obj)
            domain = obj.domain_;
        end

        function set.domain(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            obj.domain_ = domain;
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ?gams.transfer.symbol.data.Tabular})

        function obj = CategoricalColumn(data, domain)
            obj.data_ = data;
            obj.domain_ = domain;
        end

    end

    methods (Static)

        function obj = construct(data, domain)
            gams.transfer.utils.Validator('data', 1, data).type('gams.transfer.symbol.data.Tabular');
            gams.transfer.utils.Validator('domain', 2, domain).type('gams.transfer.symbol.domain.Abstract');
            obj = gams.transfer.unique_labels.CategoricalColumn(data, domain);
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.CategoricalColumn(obj.data_, obj.domain_);
        end

        function labels = get(obj)
            labels = categories(obj.data_.records.(obj.domain_.label))';
        end

        function clear(obj)
            obj.data_.records.(obj.domain_.label) = categorical([], [], {}, 'Ordinal', true);
        end

        function [flag, indices] = removeUnused(obj)
            if nargout > 0
                oldlabels = obj.get();
            end
            obj.data_.records.(obj.domain_.label) = removecats(obj.data_.records.(obj.domain_.label));
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels, [], []);
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.symbol.data.Abstract, ...
        ?gams.transfer.symbol.domain.Abstract})

        function [flag, time] = updatedAfter_(obj, time)
            flag = true;
            [flag_, time_] = obj.data_.updatedAfter_(time);
            if flag_
                time = time_;
                return
            end
            [flag_, time_] = obj.domain_.updatedAfter_(time);
            if flag_
                time = time_;
                return
            end
            flag = false;
        end

        function add_(obj, labels)
            if ~isordinal(obj.data_.records.(obj.domain_.label))
                obj.data_.records.(obj.domain_.label) = addcats(obj.data_.records.(obj.domain_.label), labels);
                return
            end
            current_labels = categories(obj.data_.records.(obj.domain_.label));
            if numel(current_labels) == 0
                obj.data_.records.(obj.domain_.label) = categorical(labels, 'Ordinal', true);
            else
                obj.data_.records.(obj.domain_.label) = addcats(obj.data_.records.(obj.domain_.label), labels, 'After', current_labels{end});
            end
        end

        function set_(obj, labels)
            obj.data_.records.(obj.domain_.label) = categorical(double(obj.data_.records.(obj.domain_.label)), ...
                1:numel(labels), labels, 'Ordinal', true);
        end

        function [flag, indices] = update_(obj, labels)
            if nargout > 0
                oldlabels = obj.get();
            end
            obj.data_.records.(obj.domain_.label) = setcats(obj.data_.records.(obj.domain_.label), labels);
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels, [], []);
            end
        end

        function [flag, indices] = remove_(obj, labels)
            if nargout > 0
                oldlabels = obj.get();
            end
            obj.data_.records.(obj.domain_.label) = removecats(obj.data_.records.(obj.domain_.label), labels);
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels, [], []);
            end
        end

        function rename_(obj, oldlabels, newlabels)
            not_avail = ~ismember(oldlabels, categories(obj.data_.records.(obj.domain_.label)));
            oldlabels(not_avail) = [];
            newlabels(not_avail) = [];
            obj.data_.records.(obj.domain_.label) = renamecats(obj.data_.records.(obj.domain_.label), oldlabels, newlabels);
        end

        function [flag, indices] = merge_(obj, oldlabels, newlabels)
            if nargout > 0
                oldlabels_ = obj.get();
            end
            obj.data_.records.(obj.domain_.label) = categorical(obj.data_.records.(obj.domain_.label), 'Ordinal', false);
            not_avail = ~ismember(oldlabels, categories(obj.data_.records.(obj.domain_.label)));
            oldlabels(not_avail) = [];
            newlabels(not_avail) = [];
            for j = 1:numel(newlabels)
                obj.data_.records.(obj.domain_.label) = mergecats(obj.data_.records.(obj.domain_.label), ...
                    oldlabels{j}, newlabels{j});
            end
            obj.data_.records.(obj.domain_.label) = categorical(obj.data_.records.(obj.domain_.label), 'Ordinal', true);
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels_, oldlabels, newlabels);
            end
        end

    end

end
