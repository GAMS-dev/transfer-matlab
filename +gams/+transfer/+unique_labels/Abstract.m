% Abstract UELs
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2023 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2023 GAMS Development Corp. <support@gams.com>
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
% Abstract UELs
%

%> @brief Abstract UELs
classdef (Abstract) Abstract < handle

    methods (Abstract)

        unique_labels = copy(obj)
        labels = get(obj)
        add(obj, labels)
        set(obj, labels)
        remove(obj, labels)
        rename(obj, oldlabels, newlabels)

    end

    methods

        function count = count(obj)
            count = numel(obj.get());
        end

        function labels = getAt(obj, indices)
            % TODO check indices
            if numel(indices) == 0
                labels = {};
            end
            labels = gams.transfer.utils.filter_unique_labels(obj.get(), indices);
            if numel(indices) == 1
                labels = labels{1};
            end
        end

        function indices = find(obj, labels)
            % TODO check labels
            [~, indices] = ismember(labels, obj.get());
        end

        function clear(obj)
            obj.set({});
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

    methods (Static)

        function index = createIndexFrom(input, unique_labels)
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                index = gams.transfer.unique_labels.Abstract.createCategoricalIndexFrom(input, unique_labels);
            else
                index = gams.transfer.unique_labels.Abstract.createIntegerIndexFrom(input, unique_labels);
            end
        end

        function index = createCategoricalIndexFrom(input, unique_labels)
            if ~iscellstr(unique_labels)
                error('Argument ''unique_labels'' (at position 2) must be ''cellstr''.');
            end
            if iscellstr(input)
                index = categorical(input, unique_labels, 'Ordinal', true);
            elseif isnumeric(input) && all(round(input) == input)
                index = categorical(input, 1:numel(unique_labels), unique_labels, 'Ordinal', true);
            else
                error('Argument ''input'' (at position 1) must be ''cellstr'' or integer ''numeric''.');
            end
        end

        function index = createIntegerIndexFrom(input, unique_labels)
            if ~iscellstr(unique_labels)
                error('Argument ''unique_labels'' (at position 2) must be ''cellstr''.');
            end
            if iscellstr(input)
                map = containers.Map(unique_labels, 1:numel(unique_labels));
                index = zeros(size(input));
                for i = 1:numel(input)
                    if isKey(map, input{i})
                        index(i) = map(input{i});
                    end
                end
            elseif isnumeric(input) && all(round(input) == input)
                index = input;
                index(index < 1 | numel(unique_labels)) = 0;
            else
                error('Argument ''input'' (at position 1) must be ''cellstr'' or integer ''numeric''.');
            end
        end

    end

end
