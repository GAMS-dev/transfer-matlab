% Abstract Unique Labels (internal)
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
% Abstract Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Abstract < handle

    methods

        function unique_labels = copy(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function count = count(obj)
            count = numel(obj.get());
        end

        function labels = get(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function labels = getAt(obj, indices)
            gams.transfer.utils.Validator('indices', 1, indices).integer();
            if numel(indices) == 0
                labels = {};
            end
            labels = gams.transfer.utils.filter_unique_labels(obj.get(), indices);
            if numel(indices) == 1
                labels = labels{1};
            end
        end

        function indices = find(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            [~, indices] = ismember(labels, obj.get());
        end

        function clear(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function add(obj, labels)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function set(obj, labels)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function remove(obj, labels)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function rename(obj, oldlabels, newlabels)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function index = createIndex(obj, input)
            index = obj.createIndexFrom(input, obj.get());
        end

        function index = createCategoricalIndex(obj, input)
            index = obj.createCategoricalIndexFrom(input, obj.get());
        end

        function index = createIntegerIndex(obj, input)
            index = obj.createIntegerIndexFrom(input, obj.get());
        end

    end

    methods (Hidden)

        function flag = supportsIndexed(obj)
            flag = false;
        end

    end

    methods (Static)

        function index = createIndexFrom(input, unique_labels)
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                index = gams.transfer.unique_labels.Abstract.createCategoricalIndexFrom(input, unique_labels);
            else
                index = gams.transfer.unique_labels.Abstract.createIntegerIndexFrom(input, unique_labels);
            end
        end

        function index = createCategoricalIndexFrom(input, unique_labels)
            unique_labels = gams.transfer.utils.Validator('unique_labels', 2, unique_labels) ...
                .string2char().cellstr().value;
            if iscell(input)
                input = gams.transfer.utils.Validator('input', 1, input).string2char().cellstr().value;
                index = categorical(input, unique_labels, 'Ordinal', true);
            else
                gams.transfer.utils.Validator('input', 1, input).integer();
                index = categorical(input, 1:numel(unique_labels), unique_labels, 'Ordinal', true);
            end
        end

        function index = createIntegerIndexFrom(input, unique_labels)
            unique_labels = gams.transfer.utils.Validator('unique_labels', 2, unique_labels) ...
                .string2char().cellstr().value;
            if iscell(input)
                input = gams.transfer.utils.Validator('input', 1, input).string2char().cellstr().value;
                map = containers.Map(unique_labels, 1:numel(unique_labels));
                index = zeros(size(input));
                for i = 1:numel(input)
                    if isKey(map, input{i})
                        index(i) = map(input{i});
                    end
                end
            else
                gams.transfer.utils.Validator('input', 1, input).integer();
                index = input;
                index(index < 1 | numel(unique_labels)) = 0;
            end
        end

    end

end
