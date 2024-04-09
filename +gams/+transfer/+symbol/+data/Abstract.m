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
classdef (Abstract, Hidden) Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        records_ = []
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

        function obj = set.records(obj, records)
            obj.records_ = records;
        end

    end

    methods

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

        function flag = isLabel_(obj, label)
            flag = ismember(label, obj.getLabels());
        end

        function obj = renameLabels_(obj, oldlabels, newlabels)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function def = projectDefinition_(obj, def)
            missing_domains = false(1, numel(def.domains));
            missing_values = false(1, numel(def.values));
            for i = 1:numel(def.domains)
                missing_domains(i) = ~obj.isLabel_(def.domains{i}.label);
            end
            for i = 1:numel(def.values)
                missing_values(i) = ~obj.isLabel_(def.values{i}.label);
            end
            if any(missing_domains) || any(missing_values)
                def.domains_ = def.domains(~missing_domains);
                def.values_ = def.values(~missing_values);
            end
        end

        function status = isValid_(obj, def, axes)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function flag = hasUniqueLabels_(obj, domain)
            flag = false;
        end

        function indices = usedUniqueLabels_(obj, def, dimension)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function nrecs = getNumberRecords_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function nvals = getNumberValues_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function sparsity = getSparsity_(obj, def, axes)
            n_dense = prod(axes.size()) * numel(def.values);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues_(def) / n_dense;
            end
        end

        function value = getMeanValue_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function [value, where] = getMinValue_(obj, def, axes)
            if nargout >= 2
                [value, where] = obj.getFunValue_(@min, def, axes);
            else
                value = obj.getFunValue_(@min, def, axes);
            end
        end

        function [value, where] = getMaxValue_(obj, def, axes)
            if nargout >= 2
                [value, where] = obj.getFunValue_(@max, def, axes);
            else
                value = obj.getFunValue_(@max, def, axes);
            end
        end

        function [value, where] = getMaxAbsValue_(obj, def, axes)
            fun = @(x) (max(abs(x)));
            if nargout >= 2
                [value, where] = obj.getFunValue_(fun, def, axes);
            else
                value = obj.getFunValue_(fun, def, axes);
            end
        end

        function n = countNA_(obj, def)
            n = obj.countFun_(@gams.transfer.SpecialValues.isNA, def);
        end

        function n = countUndef_(obj, def)
            n = obj.countFun_(@gams.transfer.SpecialValues.isUndef, def);
        end

        function n = countEps_(obj, def)
            n = obj.countFun_(@gams.transfer.SpecialValues.isEps, def);
        end

        function n = countPosInf_(obj, def)
            n = obj.countFun_(@gams.transfer.SpecialValues.isPosInf, def);
        end

        function n = countNegInf_(obj, def)
            n = obj.countFun_(@gams.transfer.SpecialValues.isNegInf, def);
        end

        function obj = dropDefaults_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function obj = dropNA_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function obj = dropUndef_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function obj = dropMissing_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function obj = dropEps_(obj, def)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function n = countDuplicates_(obj, def)
            n = numel(obj.findDuplicates_(def, 'first'));
        end

        function indices = findDuplicates_(obj, def, keep)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function flag = hasDuplicates_(obj, def)
            flag = obj.countDuplicates_(def) > 0;
        end

        function obj = dropDuplicates_(obj, def, keep)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function subindex = ind2sub_(obj, axes, value, linindex)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function data = transformTo_(obj, def, axes, data)
            if isa(data, 'gams.transfer.symbol.data.Tabular')
                data = obj.transformToTabular_(def, axes, data);
            elseif isa(data, 'gams.transfer.symbol.data.Matrix')
                data = obj.transformToMatrix_(def, axes, data);
            else
                error('Invalid data: %s', class(data));
            end
        end

        function data = transformToTabular_(obj, def, axes, data)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function data = transformToMatrix_(obj, def, axes, data)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function obj = permuteAxis_(obj, def, axes, dimension, permutation)
            % st = dbstack;
            % error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

    end

    methods (Sealed = true)

        function flag = isLabel(obj, label)
            label = gams.transfer.utils.Validator('label', 1, label).string2char().type('char').nonempty().value;
            flag = obj.isLabel_(label);
        end

        function obj = renameLabels(obj, oldlabels, newlabels)
            oldlabels = gams.transfer.utils.Validator('oldlabels', 1, oldlabels).string2char().cellstr().value;
            newlabels = gams.transfer.utils.Validator('newlabels', 2, newlabels).string2char().cellstr().value;
            obj = obj.renameLabels_(oldlabels, newlabels);
        end

        function status = isValid(obj, def, axes)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            status = obj.isValid_(def, axes);
        end

        function flag = hasUniqueLabels(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            flag = obj.hasUniqueLabels_(domain);
        end

        function indices = usedUniqueLabels(obj, def, dimension)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('dimension', 2, dimension).integer().scalar().inInterval(1, axes.dimension);
            indices = obj.usedUniqueLabels_(def, dimension);
        end

        function nrecs = getNumberRecords(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            nrecs = obj.getNumberRecords_(def);
        end

        function nvals = getNumberValues(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            nvals = obj.getNumberValues_(def_);
        end

        function sparsity = getSparsity(obj, def, axes)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            sparsity = obj.getSparsity_(def, axes);
        end

        function value = getMeanValue(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            value = obj.getMeanValue_(def);
        end

        function [value, where] = getMinValue(obj, def, axes)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            if nargout >= 2
                [value, where] = obj.getFunValue_(@min, def, axes);
            else
                value = obj.getFunValue_(@min, def, axes);
            end
        end

        function [value, where] = getMaxValue(obj, def, axes)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            if nargout >= 2
                [value, where] = obj.getFunValue_(@max, def, axes);
            else
                value = obj.getFunValue_(@max, def, axes);
            end
        end

        function [value, where] = getMaxAbsValue(obj, def, axes)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            fun = @(x) (max(abs(x)));
            if nargout >= 2
                [value, where] = obj.getFunValue_(fun, def, axes);
            else
                value = obj.getFunValue_(fun, def, axes);
            end
        end

        function n = countNA(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countFun_(@gams.transfer.SpecialValues.isNA, def);
        end

        function n = countUndef(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countFun_(@gams.transfer.SpecialValues.isUndef, def);
        end

        function n = countEps(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countFun_(@gams.transfer.SpecialValues.isEps, def);
        end

        function n = countPosInf(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countFun_(@gams.transfer.SpecialValues.isPosInf, def);
        end

        function n = countNegInf(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countFun_(@gams.transfer.SpecialValues.isNegInf, def);
        end

        function obj = dropDefaults(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            obj = obj.dropDefaults_(def);
        end

        function obj = dropNA(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            obj = obj.dropNA_(def);
        end

        function obj = dropUndef(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            obj = obj.dropUndef_(def);
        end

        function obj = dropMissing(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            obj = obj.dropMissing_(def);
        end

        function obj = dropEps(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            obj = obj.dropEps_(def);
        end

        function n = countDuplicates(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            n = obj.countDuplicates_(def);
        end

        function indices = findDuplicates(obj, def, keep)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('keep', 2, keep).string2char().type('char').in({'first', 'last'});
            indices = obj.findDuplicates_(def, keep);
        end

        function flag = hasDuplicates(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            flag = obj.hasDuplicates_(def);
        end

        function obj = dropDuplicates(obj, def, keep)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('keep', 2, keep).string2char().type('char').in({'first', 'last'});
            obj = obj.dropDuplicates_(def, keep);
        end

        function data = transformTo(obj, def, axes, data)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            data = obj.transformTo_(def, axes, data);
        end

        function data = transformToTabular(obj, def, axes, data)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            data = obj.transformToTabular_(def, axes, data);
        end

        function data = transformToMatrix(obj, def, axes, data)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Abstract');
            data = obj.transformToMatrix_(def, axes, data);
        end

        function obj = permuteAxis(obj, def, axes, dimension, permutation)
            gams.transfer.utils.Validator('def', 1, def).type('gams.transfer.symbol.definition.Abstract');
            gams.transfer.utils.Validator('axes', 2, axes).type('gams.transfer.symbol.unique_labels.Axes');
            gams.transfer.utils.Validator('dimension', 3, dimension).integer().scalar().inInterval(1, axes.dimension);
            gams.transfer.utils.Validator('permutation', 4, permutation).integer().vector();
            obj = obj.permuteAxis_(def, axes, dimension, permutation);
        end

    end

    methods (Hidden, Access = private)

        function [value, where] = getFunValue_(obj, fun, def, axes)
            value = zeros(1, numel(def.values));
            where = cell(1, numel(def.values));
            found = false;
            for i = 1:numel(def.values)
                [value_, where_] = fun(obj.records_.(def.values{i}.label)(:));
                if ~isempty(value_)
                    value(i) = value_;
                    where{i} = where_;
                    found = true;
                end
            end
            if found
                [value, idx] = fun(value);
                if nargout >= 2
                    idx = obj.ind2sub_(axes, def.values{idx}, where{idx});
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

        function n = countFun_(obj, fun, def)
            n = 0;
            for i = 1:numel(def.values)
                n = n + sum(fun(obj.records_.(def.values{i}.label)(:)));
            end
        end

    end

end
