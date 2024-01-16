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
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'gams.transfer.symbol.value.Value'}, 1));
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
        status = isValid(obj, def)
        nrecs = getNumberRecords(obj, def)
        nvals = getNumberValues(obj, def, varargin)
        value = getMeanValue(obj, def, varargin)
    end

    methods (Abstract, Hidden, Access = protected)
        arg = validateDomains_(obj, name, index, arg)
        arg = validateValues_(obj, name, index, arg)
        subindex = ind2sub_(obj, domains, value, linindex)
        uels = getUniqueLabelsAt_(obj, domain, ignore_unused)
        setUniqueLabelsAt_(obj, uels, domain, rename)
        addUniqueLabelsAt_(obj, uels, domain)
        removeUniqueLabelsAt_(obj, uels, domain)
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

        function flag = isLabel(obj, label)
            flag = ismember(label, obj.labels);
        end

        function values = availableNumericValues(obj, values)
            for i = 1:numel(values)
                if ~isa(values{i}, 'gams.transfer.symbol.value.Numeric') ||~obj.isLabel(values{i}.label)
                    values(i) = [];
                end
            end
        end

        function uels = getUELs(obj, varargin)
            % parse input arguments
            codes = [];
            ignore_unused = false;
            try
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'domains', @obj.validateDomains_);
                index = 2;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'ignore_unused')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        ignore_unused = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'ignore_unused', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 2
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'numeric'}, 1));
                        codes = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'codes', validate);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            uels = {};

            for i = 1:numel(domains)
                uels_i0 = obj.getUniqueLabelsAt_(domains{i}, ignore_unused);

                % filter for given codes
                if ~isempty(codes)
                    idx = codes >= 1 & codes <= numel(uels_i0);
                    uels_i = cell(numel(codes), 1);
                    uels_i(idx) = uels_i0(codes(idx));
                    uels_i(~idx) = {'<undefined>'};
                end

                uels = [uels; reshape(uels_i, numel(uels_i), 1)];
            end

            if numel(domains) > 1
                uels = gams.transfer.utils.unique(uels);
            end
        end

        function setUELs(obj, varargin)
            % parse input arguments
            rename = false;
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', @obj.validateUels);
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'domains', @obj.validateDomains_);
                index = 2;
                is_pararg = false;
                while index <= nargin
                    if strcmpi(varargin{index}, 'rename')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        rename = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'rename', validate);
                        index = index + 2;
                        is_pararg = true;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                obj.setUniqueLabelsAt_(uels, domains{i}, rename);
            end
        end

        function reorderUELsByData(obj, varargin)
            % parse input arguments
            try
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                uels = obj.getUniqueLabelsAt_(domains{i});
                rec_uels_ids = gams.transfer.utils.unique(uint64(obj.records_.(domains{i}.label)));
                rec_uels_ids = rec_uels_ids(rec_uels_ids ~= nan);
                obj.setUniqueLabelsAt_(uels(rec_uels_ids), domains{i});
                obj.addUniqueLabelsAt_(uels, domains{i});
            end
        end

        function reorderUELs(obj, varargin)
            % parse input arguments
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', @obj.validateUels);
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                current_uels = obj.getUniqueLabelsAt_(domains{i});
                if numel(uels) ~= numel(current_uels)
                    error('Number of UELs %d not equal to number of current UELs %d', numel(uels), numel(current_uels));
                end
                if ~all(ismember(current_uels, uels))
                    error('Adding new UELs not supported for reordering');
                end
                obj.setUniqueLabelsAt_(uels, domains{i});
            end
        end

        function addUELs(obj, varargin)
            % parse input arguments
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', @obj.validateUels);
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                obj.addUniqueLabelsAt_(uels, domains{i});
            end
        end

        function removeUELs(obj, varargin)
            % parse input arguments
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', @obj.validateUels);
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                obj.removeUniqueLabelsAt_(uels, domains{i});
            end
        end

        function renameUELs(obj, varargin)
            error('todo');
        end

        function lowerUELs(obj, varargin)
            % parse input arguments
            try
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                obj.renameUniqueLabelsAt(lower(obj.getUniqueLabelsAt_(domains{i})), domains{i}, true);
            end
        end

        function upperUELs(obj, varargin)
            % parse input arguments
            try
                domains = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'domains', @obj.validateDomains_);
            catch e
                error(e.message);
            end

            for i = 1:numel(domains)
                obj.renameUniqueLabelsAt(upper(obj.getUniqueLabelsAt_(domains{i})), domains{i}, true);
            end
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
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            n_dense = prod(def.size) * numel(values);
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
                    uels = obj.getUniqueLabelsAt_(domains{i}, false);
                    where{i} = uels{idx(i)};
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
                    uels = obj.getUniqueLabelsAt_(domains{i}, false);
                    where{i} = uels{idx(i)};
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
                    uels = obj.getUniqueLabelsAt_(domains{i}, false);
                    where{i} = uels{idx(i)};
                end
            end
        end

    end

end
