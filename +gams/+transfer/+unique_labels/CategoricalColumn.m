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

    properties (Hidden, SetAccess = protected)
        data_
        label_
    end

    properties (Dependent)
        data
        label
    end

    methods

        function data = get.data(obj)
            data = obj.data_;
        end

        function set.data(obj, data)
            gams.transfer.utils.Validator('data', 1, data).type('gams.transfer.symbol.data.Tabular');
            obj.data_ = data;
        end

        function label = get.label(obj)
            label = obj.label_;
        end

        function set.label(obj, label)
            obj.label_ = gams.transfer.utils.Validator('label', 1, label).string2char() ...
                .type('char').nonempty().varname().value;
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ?gams.transfer.symbol.data.Tabular})

        function obj = CategoricalColumn(data, label)
            obj.data_ = data;
            obj.label_ = label;
        end

    end

    methods (Static)

        function obj = construct(data, label)
            gams.transfer.utils.Validator('data', 1, data).type('gams.transfer.symbol.data.Tabular');
            label = gams.transfer.utils.Validator('label', 1, label).string2char() ...
                .type('char').nonempty().varname().value;
            obj = gams.transfer.unique_labels.CategoricalColumn(data, label);
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.CategoricalColumn(obj.data_, obj.label_);
        end

        function labels = get(obj)
            assert(iscategorical(obj.data_.records.(obj.label_)));
            labels = categories(obj.data_.records.(obj.label_));
        end

        function add(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            assert(iscategorical(obj.data_.records.(obj.label_)));

            if ~isordinal(obj.data_.records.(obj.label_))
                obj.data_.records.(obj.label_) = addcats(obj.data_.records.(obj.label_), labels);
                return
            end

            current_labels = categories(obj.data_.records.(obj.label_));
            if numel(current_labels) == 0
                obj.data_.records.(obj.label_) = categorical(labels, 'Ordinal', true);
            else
                obj.data_.records.(obj.label_) = addcats(obj.data_.records.(obj.label_), labels, 'After', current_labels{end});
            end
        end

        function clear(obj)
            assert(iscategorical(obj.data_.records.(obj.label_)));
            obj.data_.records.(obj.label_) = categorical([], [], {}, 'Ordinal', true);
        end

        function set(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            assert(iscategorical(obj.data_.records.(obj.label_)));
            obj.data_.records.(obj.label_) = categorical(double(obj.data_.records.(obj.label_)), ...
                1:numel(labels), labels, 'Ordinal', true);
        end

        function remove(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            assert(iscategorical(obj.data_.records.(obj.label_)));
            obj.data_.records.(obj.label_) = removecats(obj.data_.records.(obj.label_), labels);
        end

        function rename(obj, oldlabels, newlabels)
            oldlabels = gams.transfer.utils.Validator('oldlabels', 1, oldlabels).string2char().cellstr().value;
            newlabels = gams.transfer.utils.Validator('newlabels', 2, newlabels).string2char() ...
                .cellstr().numel(numel(oldlabels)).value;
            assert(iscategorical(obj.data_.records.(obj.label_)));
            not_avail = ~ismember(oldlabels, categories(obj.data_.records.(obj.label_)));
            oldlabels(not_avail) = [];
            newlabels(not_avail) = [];
            obj.data_.records.(obj.label_) = renamecats(obj.data_.records.(obj.label_), oldlabels, newlabels);
        end

    end

end
