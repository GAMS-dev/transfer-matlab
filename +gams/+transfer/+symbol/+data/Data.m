% Abstract Records (internal)
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
% Abstract Records (internal)
%
classdef (Abstract) Data < handle

    properties (Hidden, SetAccess = protected)
        records_ = []
        last_update_ = now()
    end

    methods (Hidden, Static)

        function arg = validateDefinition(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.definition.Definition')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.definition.Definition''.', name, index);
            end
        end

        function [domains, values] = parseDefinitionWithValueFilter(varargin)

            % parse input arguments
            try
                def = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'def', @gams.transfer.symbol.data.Data.validateDefinition);
                domains = def.domains;
                values = def.values;
                index = 2;
                is_pararg = false;
                while index <= nargin
                    if strcmpi(varargin{index}, 'values')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'gams.transfer.symbol.value.Value'}, 1, -1));
                        values = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'values', validate);
                        index = index + 2;
                        is_pararg = true;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

        end

        function arg = validateDomains(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.domain.Domain')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.domain.Domain''.', name, index, i);
                end
            end
        end

        function arg = validateValues(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.value.Value')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.value.Value''.', name, index, i);
                end
            end
        end

    end

    properties (Abstract, SetAccess = private)
        % TODO: make method
        labels
    end

    properties (Dependent)
        records
    end

    properties (Dependent, SetAccess = private)
        last_update
    end

    methods (Abstract)
        name = name(obj)
        renameLabels(obj, old_labels, new_labels)
        data = copy(obj)
        status = isValid(obj, def)
        data = transform(obj, format)

        nrecs = getNumberRecords(obj, def)
        nvals = getNumberValues(obj, def, varargin)
        value = getMeanValue(obj, def, varargin)
    end

    methods (Abstract, Hidden, Access = protected)
        arg = validateDomains_(obj, name, index, arg)
        arg = validateValues_(obj, name, index, arg)
        subindex = ind2sub_(obj, domains, value, linindex)
    end

    methods

        function records = get.records(obj)
            records = obj.records_;
        end

        function obj = set.records(obj, records)
            obj.records_ = records;
            obj.last_update_ = now();
        end

        function last_update = get.last_update(obj)
            last_update = obj.last_update_;
        end

    end

    methods

        function flag = hasUniqueLabels(obj, domain)
            % TODO check domain
            flag = false;
        end

        function indices = usedUniqueLabels(obj, domain)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function count = countUniqueLabels(obj, domain)
            % TODO: check domain
            count = numel(obj.getUniqueLabels());
        end

        function labels = getUniqueLabels(obj, domain)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function labels = getUniqueLabelsAt(obj, domain, indices)
            % TODO check indices
            labels = gams.transfer.utils.filter_unique_labels(obj.getUniqueLabels(domain), indices);
        end

        function indices = findUniqueLabels(obj, domain, labels)
            % TODO: check labels
            [~, indices] = ismember(labels, obj.getUniqueLabels(domain));
        end

        function clearUniqueLabels(obj, domain)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function addUniqueLabels(obj, domain, labels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function setUniqueLabels(obj, domain, labels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function updateUniqueLabels(obj, domain, labels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function removeUniqueLabels(obj, domain, labels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function removeUnusedUniqueLabels(obj, domain)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function renameUniqueLabels(obj, domain, oldlabels, newlabels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function mergeUniqueLabels(obj, domain, oldlabels, newlabels)
            if obj.hasUniqueLabels(domain)
                error('Abstract method. Call method of subclass ''%s''.', class(obj));
            else
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
        end

        function copyFrom(obj, symbol)

            % parse input arguments
            try
                symbol = gams.transfer.utils.validate('symbol', 1, symbol, {class(obj)}, -1);
            catch e
                error(e.message);
            end

            obj.records_ = symbol.records;
            obj.last_update_ = symbol.last_update;
        end

        function eq = equals(obj, data)
            eq = isequal(class(obj), class(data)) && isequaln(obj.records_, data.records);
        end

        function flag = isLabel(obj, label)
            flag = ismember(label, obj.labels);
        end

        function domains = availableDomains(obj, domains)
            idx = true(size(domains));
            for i = 1:numel(domains)
                if ~isa(domains{i}, 'gams.transfer.symbol.domain.Domain') || ~obj.isLabel(domains{i}.label)
                    idx(i) = false;
                end
            end
            domains = domains(idx);
        end

        function values = availableValues(obj, values)
            idx = true(size(values));
            for i = 1:numel(values)
                if ~isa(values{i}, 'gams.transfer.symbol.value.Value') || ~obj.isLabel(values{i}.label)
                    idx(i) = false;
                end
            end
            values = values(idx);
        end

        function values = availableNumericValues(obj, values)
            idx = true(size(values));
            for i = 1:numel(values)
                if ~isa(values{i}, 'gams.transfer.symbol.value.Numeric') || ~obj.isLabel(values{i}.label)
                    idx(i) = false;
                end
            end
            values = values(idx);
        end

    end

    methods

        function n = countNA(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n = 0;
            for i = 1:numel(values)
                n = n + sum(gams.transfer.SpecialValues.isNA(obj.records_.(values{i}.label)(:)));
            end
        end

        function n = countUndef(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n = 0;
            for i = 1:numel(values)
                n = n + sum(gams.transfer.SpecialValues.isUndef(obj.records_.(values{i}.label)(:)));
            end
        end

        function n = countEps(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n = 0;
            for i = 1:numel(values)
                n = n + sum(gams.transfer.SpecialValues.isEps(obj.records_.(values{i}.label)(:)));
            end
        end

        function n = countPosInf(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n = 0;
            for i = 1:numel(values)
                n = n + sum(gams.transfer.SpecialValues.isPosInf(obj.records_.(values{i}.label)(:)));
            end
        end

        function n = countNegInf(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n = 0;
            for i = 1:numel(values)
                n = n + sum(gams.transfer.SpecialValues.isNegInf(obj.records_.(values{i}.label)(:)));
            end
        end

        function sparsity = getSparsity(obj, def, varargin)
            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n_dense = prod(obj.axes(domains).size()) * numel(values);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues(def) / n_dense;
            end
        end

        function [value, where] = getMinValue(obj, def, varargin)

            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            value = nan;
            where = {};

            idx = [];
            for i = 1:numel(values)
                [value_, idx_] = min(obj.records_.(values{i}.label)(:));
                if ~isempty(value_) && (isempty(idx) || value > value_)
                    value = value_;
                    idx = obj.ind2sub_(domains, values{i}, idx_);
                end
            end

            if ~isempty(idx)
                where = cell(1, numel(domains));
                for i = 1:numel(domains)
                    where{i} = obj.axis(domains{i}).labelAt(idx(i));
                end
            end
        end

        function [value, where] = getMaxValue(obj, def, varargin)

            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            value = nan;
            where = {};

            idx = [];
            for i = 1:numel(values)
                [value_, idx_] = max(obj.records_.(values{i}.label)(:));
                if ~isempty(value_) && (isempty(idx) || value < value_)
                    value = value_;
                    idx = obj.ind2sub_(domains, values{i}, idx_);
                end
            end

            if ~isempty(idx)
                where = cell(1, numel(domains));
                for i = 1:numel(domains)
                    where{i} = obj.axis(domains{i}).labelAt(idx(i));
                end
            end
        end

        function [value, where] = getMaxAbsValue(obj, def, varargin)

            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            value = nan;
            where = {};

            idx = [];
            for i = 1:numel(values)
                [value_, idx_] = max(abs(obj.records_.(values{i}.label)(:)));
                if ~isempty(value_) && (isempty(idx) || value > value_)
                    value = value_;
                    idx = obj.ind2sub_(domains, values{i}, idx_);
                end
            end

            if ~isempty(idx)
                where = cell(1, numel(domains));
                for i = 1:numel(domains)
                    where{i} = obj.axis(domains{i}).labelAt(idx(i));
                end
            end
        end

        function axis = axis(obj, domain)
            axis = gams.transfer.symbol.unique_labels.Axis(obj, domain);
        end

        function axes = axes(obj, domains)
            axes = gams.transfer.symbol.unique_labels.Axes(obj, domains);
        end

    end

    methods (Static)

        function index = createUniqueLabelsIndex(input, unique_labels)
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                index = gams.transfer.symbol.data.Data.createUniqueLabelsCategoricalIndex(input, unique_labels);
            else
                index = gams.transfer.symbol.data.Data.createUniqueLabelsIntegerIndex(input, unique_labels);
            end
        end

        function index = createUniqueLabelsCategoricalIndex(input, unique_labels)
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

        function index = createUniqueLabelsIntegerIndex(input, unique_labels)
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
