% Abstract Data (internal)
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
% Abstract Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        records_ = []
        last_update_ = now()
    end

    properties (Abstract, Constant)
        name
    end

    properties (Dependent)
        records
    end

    properties (Dependent, SetAccess = private)
        last_update
    end

    methods

        function records = get.records(obj)
            records = obj.records_;
        end

        function set.records(obj, records)
            obj.records_ = records;
            obj.last_update_ = now();
        end

        function last_update = get.last_update(obj)
            last_update = obj.last_update_;
        end

    end

    methods

        function data = copy(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function copyFrom(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).type(class(obj));
            obj.records_ = symbol.records_;
            obj.last_update_ = symbol.last_update_;
            obj.last_update_ = now();
        end

        function eq = equals(obj, data)
            eq = isequaln(obj.records_, data.records_);
        end

        function flag = isLabel(obj, label)
            flag = ismember(label, obj.getLabels());
        end

        function labels = getLabels(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function renameLabels(obj, old_labels, new_labels)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function values = availableValues(obj, class, values)
            idx = true(size(values));
            for i = 1:numel(values)
                if ~isa(values{i}, ['gams.transfer.symbol.value.', class]) || ~obj.isLabel(values{i}.label)
                    idx(i) = false;
                end
            end
            values = values(idx);
        end

        function status = isValid(obj, axes, values)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function flag = hasUniqueLabels(obj, domain)
            flag = false;
        end

        function unique_labels = getUniqueLabels(obj, domain)
            unique_labels = [];
        end

        function indices = usedUniqueLabels(obj, domain)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function nrecs = getNumberRecords(obj, axes, values)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function nvals = getNumberValues(obj, axes, values)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function value = getMeanValue(obj, axes, values)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function sparsity = getSparsity(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues('Numeric', values);
            n_dense = prod(axes.size()) * numel(values);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues(axes, values) / n_dense;
            end
        end

        function [value, where] = getMinValue(obj, axes, values)
            [value, where] = obj.getFunValue(@min, axes, values);
        end

        function [value, where] = getMaxValue(obj, axes, values)
            [value, where] = obj.getFunValue(@max, axes, values);
        end

        function [value, where] = getMaxAbsValue(obj, axes, values)
            fun = @(x) (max(abs(x)));
            [value, where] = obj.getFunValue(fun, axes, values);
        end

        function n = countNA(obj, values)
            n = obj.countFun(@gams.transfer.SpecialValues.isNA, values);
        end

        function n = countUndef(obj, values)
            n = obj.countFun(@gams.transfer.SpecialValues.isUndef, values);
        end

        function n = countEps(obj, values)
            n = obj.countFun(@gams.transfer.SpecialValues.isEps, values);
        end

        function n = countPosInf(obj, values)
            n = obj.countFun(@gams.transfer.SpecialValues.isPosInf, values);
        end

        function n = countNegInf(obj, values)
            n = obj.countFun(@gams.transfer.SpecialValues.isNegInf, values);
        end

        function transformTo(obj, axes, values, data)
            if isa(data, 'gams.transfer.symbol.data.Tabular')
                obj.transformToTabular(axes, values, data);
            elseif isa(data, 'gams.transfer.symbol.data.Matrix')
                obj.transformToMatrix(axes, values, data);
            else
                error('Invalid data: %s', class(data));
            end
        end

        function transformToTabular(obj, axes, values, data)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function transformToMatrix(obj, axes, values, data)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

    end

    methods (Hidden, Access = protected)

        function subindex = ind2sub(obj, axes, value, linindex)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function [value, where] = getFunValue(obj, fun, axes, values)
            values = obj.availableValues('Numeric', values);
            value = zeros(1, numel(values));
            where = cell(1, numel(values));
            found = false;
            for i = 1:numel(values)
                [value_, where_] = fun(obj.records_.(values{i}.label)(:));
                if ~isempty(value_)
                    value(i) = value_;
                    where{i} = where_;
                    found = true;
                end
            end
            [value, idx] = fun(value);
            if found
                where = axes.getUniqueLabelsAt({obj.ind2sub(axes, values{i}, where{idx})});
            else
                value = nan;
                where = {};
            end
        end

        function n = countFun(obj, fun, values)
            values = obj.availableValues('Numeric', values);
            n = 0;
            for i = 1:numel(values)
                n = n + sum(fun(obj.records_.(values{i}.label)(:)));
            end
        end

    end

end
