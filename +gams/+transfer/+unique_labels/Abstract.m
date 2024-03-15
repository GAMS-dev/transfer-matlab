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
classdef (Abstract, Hidden) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT>

    methods

        function unique_labels = copy(obj)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function count = count(obj)
            count = numel(obj.get());
        end

        function labels = get(obj)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function clear(obj)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.symbol.data.Abstract, ...
        ?gams.transfer.symbol.domain.Abstract})

        function labels = getAt_(obj, indices)
            if numel(indices) == 0
                labels = {};
                return
            end
            labels = gams.transfer.utils.filter_unique_labels(obj.get(), indices);
        end

        function [flag, indices] = find_(obj, labels)
            [flag, indices] = ismember(labels, obj.get());
        end

        function add_(obj, labels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function set_(obj, labels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function [flag, indices] = update_(obj, labels)
            if nargout > 0
                oldlabels = obj.get();
            end
            obj.set_(labels);
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels, [], []);
            end
        end

        function [flag, indices] = remove_(obj, labels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function rename_(obj, oldlabels, newlabels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function [flag, indices] = merge_(obj, oldlabels, newlabels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function index = createCategoricalIndexFromCellstr_(obj, input)
            index = gams.transfer.unique_labels.Abstract ...
                .createCategoricalIndexFromCellstrAndLabels_(input, obj.get());
        end

        function index = createCategoricalIndexFromInteger_(obj, input)
            index = gams.transfer.unique_labels.Abstract ...
                .createCategoricalIndexFromIntegerAndLabels_(input, obj.get());
        end

        function index = createIntegerIndexFromCellstr_(obj, input)
            index = gams.transfer.unique_labels.Abstract ...
                .createIntegerIndexFromCellstrAndLabels_(input, obj.get());
        end

        function index = createIntegerIndexFromInteger_(obj, input)
            index = gams.transfer.unique_labels.Abstract ...
                .createIntegerIndexFromIntegerAndLabels_(input, obj.count());
        end

    end

    methods (Sealed = true)

        function labels = getAt(obj, indices)
            gams.transfer.utils.Validator('indices', 1, indices).integer();
            labels = obj.getAt_(indices);
        end

        function [flag, indices] = find(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            [flag, indices] = obj.find_(labels);
        end

        function add(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            obj.add_(labels);
        end

        function set(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            obj.set_(labels);
        end

        function [flag, indices] = update(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            [flag, indices] = obj.update_(labels);
        end

        function [flag, indices] = remove(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            [flag, indices] = obj.remove_(labels);
        end

        function rename(obj, oldlabels, newlabels)
            oldlabels = gams.transfer.utils.Validator('oldlabels', 1, oldlabels).string2char() ...
                .cellstr().value;
            newlabels = gams.transfer.utils.Validator('newlabels', 2, newlabels).string2char() ...
                .cellstr().numel(numel(oldlabels)).value;
            obj.rename_(oldlabels, newlabels);
        end

        function [flag, indices] = merge(obj, oldlabels, newlabels)
            oldlabels = gams.transfer.utils.Validator('oldlabels', 1, oldlabels).string2char() ...
                .cellstr().value;
            newlabels = gams.transfer.utils.Validator('newlabels', 2, newlabels).string2char() ...
                .cellstr().numel(numel(oldlabels)).value;
            obj.merge_(oldlabels, newlabels);
        end

    end

    methods (Hidden, Static, Access = {?gams.transfer.unique_labels.Abstract, ?gams.transfer.symbol.Abstract})

        function index = createCategoricalIndexFromCellstrAndLabels_(input, unique_labels)
            index = categorical(input, unique_labels, 'Ordinal', true);
        end

        function index = createCategoricalIndexFromIntegerAndLabels_(input, unique_labels)
            index = categorical(input, 1:numel(unique_labels), unique_labels, 'Ordinal', true);
        end

        function index = createIntegerIndexFromCellstrAndLabels_(input, unique_labels)
            map = containers.Map(unique_labels, 1:numel(unique_labels));
            index = zeros(size(input));
            for i = 1:numel(input)
                if isKey(map, input{i})
                    index(i) = map(input{i});
                end
            end
        end

        function index = createIntegerIndexFromIntegerAndLabels_(input, unique_labels_count)
            index = uint64(input);
            index(index < 1 | index > unique_labels_count) = 0;
        end

    end

    methods (Hidden, Access = protected)

        function [flag, indices] = updatedIndices_(obj, labels_before_operation, rename_oldlabels, rename_newlabels)
            labels_after_operation = obj.get();
            [flag, indices] = ismember(labels_before_operation, labels_after_operation);
            if numel(rename_oldlabels) == 0
                return
            end
            [flag_, indices_] = ismember(rename_oldlabels, labels_before_operation);
            [flag(indices_(flag_)), indices(indices_(flag_))] = ismember(rename_newlabels(flag_), labels_after_operation);
        end

    end

end
