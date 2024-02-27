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
        time_
    end

    properties (Abstract, Constant)
        name
    end

    properties (Dependent)
        records
    end

    methods

        function records = get.records(obj)
            records = obj.records_;
        end

        function set.records(obj, records)
            obj.records_ = records;
            obj.time_.reset();
        end

    end



    methods (Hidden, Access = protected)

        function obj = Abstract()
            obj.time_ = gams.transfer.utils.Time();
        end

    end

    methods

        function data = copy(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function eq = equals(obj, data)
            eq = isequal(class(obj), class(data)) && isequaln(obj.records_, data.records_);
        end

        function labels = getLabels(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.symbol.Abstract, ...
        ?gams.transfer.unique_labels.Abstract})

        function [flag, time] = updatedAfter_(obj, time)
            flag = time <= obj.time_;
            if flag
                time = obj.time_;
            end
        end

        function copyFrom_(obj, symbol)
            obj.records_ = symbol.records_;
            obj.time_.reset();
        end

        function isLabel_(obj, label)
            flag = ismember(label, obj.getLabels());
        end

        function renameLabels_(obj, oldlabels, newlabels)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function values = availableValues_(obj, class, values)
            idx = true(size(values));
            for i = 1:numel(values)
                if ~isa(values{i}, ['gams.transfer.symbol.value.', class]) || ...
                    ~obj.isLabel_(values{i}.label)
                    idx(i) = false;
                end
            end
            values = values(idx);
        end

        function status = isValid_(obj, axes, values)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function flag = hasUniqueLabels_(obj, domain)
            flag = false;
        end

        function unique_labels = getUniqueLabels_(obj, domain)
            unique_labels = [];
        end

        function indices = usedUniqueLabels_(obj, axes, values, dimension)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function nrecs = getNumberRecords_(obj, axes, values)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function nvals = getNumberValues_(obj, axes, values)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function sparsity = getSparsity_(obj, axes, values)
            n_dense = prod(axes.size()) * numel(values);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues_(axes, values) / n_dense;
            end
        end

        function value = getMeanValue_(obj, axes, values)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function [value, where] = getMinValue_(obj, axes, values)
            if nargout >= 2
                [value, where] = obj.getFunValue_(@min, axes, values);
            else
                value = obj.getFunValue_(@min, axes, values);
            end
        end

        function [value, where] = getMaxValue_(obj, axes, values)
            if nargout >= 2
                [value, where] = obj.getFunValue_(@max, axes, values);
            else
                value = obj.getFunValue_(@max, axes, values);
            end
        end

        function [value, where] = getMaxAbsValue_(obj, axes, values)
            fun = @(x) (max(abs(x)));
            if nargout >= 2
                [value, where] = obj.getFunValue_(fun, axes, values);
            else
                value = obj.getFunValue_(fun, axes, values);
            end
        end

        function n = countNA_(obj, values)
            n = obj.countFun_(@gams.transfer.SpecialValues.isNA, values);
        end

        function n = countUndef_(obj, values)
            n = obj.countFun_(@gams.transfer.SpecialValues.isUndef, values);
        end

        function n = countEps_(obj, values)
            n = obj.countFun_(@gams.transfer.SpecialValues.isEps, values);
        end

        function n = countPosInf_(obj, values)
            n = obj.countFun_(@gams.transfer.SpecialValues.isPosInf, values);
        end

        function n = countNegInf_(obj, values)
            n = obj.countFun_(@gams.transfer.SpecialValues.isNegInf, values);
        end

        function subindex = ind2sub_(obj, axes, value, linindex)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function transformTo_(obj, axes, values, data)
            if isa(data, 'gams.transfer.symbol.data.Tabular')
                obj.transformToTabular_(axes, values, data);
            elseif isa(data, 'gams.transfer.symbol.data.Matrix')
                obj.transformToMatrix_(axes, values, data);
            else
                error('Invalid data: %s', class(data));
            end
        end

        function transformToTabular_(obj, axes, values, data)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function transformToMatrix_(obj, axes, values, data)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function permuteAxis_(obj, axes, values, dimension, permutation)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

    end

    methods (Sealed = true)

        function copyFrom(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).type(class(obj));
            obj.copyFrom_(symbol);
        end

        function flag = isLabel(obj, label)
            label = gams.transfer.utils.Validator('label', 1, label).string2char().type('char').nonempty().value;
            flag = obj.isLabel_(label);
        end

        function renameLabels(obj, oldlabels, newlabels)
            oldlabels = gams.transfer.utils.Validator('oldlabels', 1, oldlabels).string2char().cellstr().value;
            newlabels = gams.transfer.utils.Validator('newlabels', 2, newlabels).string2char().cellstr().value;
            obj.renameLabels_(oldlabels, newlabels);
        end

        function status = isValid(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            status = obj.isValid_(axes, values);
        end

        function flag = hasUniqueLabels(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            flag = obj.hasUniqueLabels_(domain);
        end

        function unique_labels = getUniqueLabels(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            unique_labels = obj.getUniqueLabels_(domain);
        end

        function indices = usedUniqueLabels(obj, axes, values, dimension)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            gams.transfer.utils.Validator('dimension', 3, dimension).integer().scalar().inInterval(1, axes.dimension);
            indices = obj.usedUniqueLabels_(axes, values, dimension);
        end

        function nrecs = getNumberRecords(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            nrecs = obj.getNumberRecords_(axes, values);
        end

        function nvals = getNumberValues(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            nvals = obj.getNumberValues_(axes, values);
        end

        function sparsity = getSparsity(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            sparsity = obj.getSparsity_(axes, values);
        end

        function value = getMeanValue(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            value = obj.getMeanValue_(axes, values);
        end

        function [value, where] = getMinValue(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            if nargout >= 2
                [value, where] = obj.getFunValue_(@min, axes, values);
            else
                value = obj.getFunValue_(@min, axes, values);
            end
        end

        function [value, where] = getMaxValue(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            if nargout >= 2
                [value, where] = obj.getFunValue_(@max, axes, values);
            else
                value = obj.getFunValue_(@max, axes, values);
            end
        end

        function [value, where] = getMaxAbsValue(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            fun = @(x) (max(abs(x)));
            if nargout >= 2
                [value, where] = obj.getFunValue_(fun, axes, values);
            else
                value = obj.getFunValue_(fun, axes, values);
            end
        end

        function n = countNA(obj, values)
            values = obj.availableValues_('Numeric', values);
            n = obj.countFun_(@gams.transfer.SpecialValues.isNA, values);
        end

        function n = countUndef(obj, values)
            values = obj.availableValues_('Numeric', values);
            n = obj.countFun_(@gams.transfer.SpecialValues.isUndef, values);
        end

        function n = countEps(obj, values)
            values = obj.availableValues_('Numeric', values);
            n = obj.countFun_(@gams.transfer.SpecialValues.isEps, values);
        end

        function n = countPosInf(obj, values)
            values = obj.availableValues_('Numeric', values);
            n = obj.countFun_(@gams.transfer.SpecialValues.isPosInf, values);
        end

        function n = countNegInf(obj, values)
            values = obj.availableValues_('Numeric', values);
            n = obj.countFun_(@gams.transfer.SpecialValues.isNegInf, values);
        end

        function transformTo(obj, axes, values, data)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            obj.transformTo_(axes, values, data);
        end

        function transformToTabular(obj, axes, values, data)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            obj.transformToTabular_(axes, values, data);
        end

        function transformToMatrix(obj, axes, values, data)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            obj.transformToMatrix_(axes, values, data);
        end

        function permuteAxis(obj, axes, values, dimension, permutation)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues_('Numeric', values);
            gams.transfer.utils.Validator('dimension', 3, dimension).integer().scalar().inInterval(1, axes.dimension);
            gams.transfer.utils.Validator('permutation', 4, permutation).integer().vector();
            obj.permuteAxis_(axes, values, dimension, permutation);
        end

    end

    methods (Hidden, Access = private)

        function [value, where] = getFunValue_(obj, fun, axes, values)
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
            if found
                [value, idx] = fun(value);
                if nargout >= 2
                    idx = obj.ind2sub_(axes, values{i}, where{idx});
                    where = cell(1, axes.dimension);
                    for i = 1:axes.dimension
                        where{i} = axes.axis(i).unique_labels.getAt_(idx(i));
                        where{i} = where{i}{1};
                    end
                end
            else
                value = nan;
                where = {};
            end
        end

        function n = countFun_(obj, fun, values)
            n = 0;
            for i = 1:numel(values)
                n = n + sum(fun(obj.records_.(values{i}.label)(:)));
            end
        end

    end

end
