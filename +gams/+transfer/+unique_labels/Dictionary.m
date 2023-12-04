% Dictionary
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
% Dictionary
%

%> @brief Abstract UELs
classdef Dictionary < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = protected)
        dict_ = containers.Map('KeyType', 'char', 'ValueType', 'int64')
    end

    methods

        function size = size(obj)
            size = obj.dict_.Count;
        end

        function labels = get(obj)
            labels = keys(obj.dict_);
        end

        function labels = getAt(obj, indices)
            alllabels = obj.get();
            idx = indices >= 1 & indices <= obj.size();
            labels = cell(1, numel(indices));
            labels(idx) = alllabels(indices(idx));
            labels(~idx) = {'<undefined>'};
        end

        function indices = find(obj, labels)
            indices = zeros(1, numel(labels));
            for i = 1:numel(labels)
                if isKey(obj.dict_, labels{i})
                    indices(i) = obj.dict_(labels{i});
                end
            end
        end

        function clear(obj)
            obj.dict_ = containers.Map('KeyType', 'char', 'ValueType', 'int64')
        end

        function add(obj, labels)
            for i = 1:numel(labels)
                obj.dict_(labels{i}) = obj.size() + 1;
            end
        end

        function set(obj, labels)
            obj.clear();
            obj.add(labels);
        end

        function remove(obj, labels)
            error('not yet implemented');
        end

        function rename(obj, oldlabels, newlabels)
            error('not yet implemented');
        end

    end

end
