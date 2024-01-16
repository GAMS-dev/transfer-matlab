% Tabular Records (internal)
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
% Tabular Records (internal)
%
classdef (Abstract) Tabular < gams.transfer.symbol.data.Data

    methods

        function status = isValid(obj, def)
            def = obj.validateDefinition('def', 1, def);

            status = obj.isValidDomains_(def.domains);
            if status.flag == status.OK
                return
            end

            status = obj.isValidValues_(def.values);
        end

        function nvals = getNumberValues(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            nvals = obj.getNumberRecords(def) * numel(obj.availableNumericValues(values));
        end

        function value = getMeanValue(obj, def, varargin)

            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            value = 0;
            for i = 1:numel(values)
                value = value + sum(obj.records_.(values{i}.label)(:));
            end

            value = value / obj.getNumberValues(def, 'values', values);
        end

    end

    methods (Hidden, Access = protected)

        function status = isValidDomains_(obj, domains)
            for i = 1:numel(domains)
                label = domains{i}.label;

                if ~obj.isLabel(label)
                    status = gams.transfer.utils.Status(sprintf("Records have no domain column '%s'.", label));
                    return
                end

                if ~iscategorical(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records domain column '%s' must be categorical.", label));
                    return
                end
            end

            status = gams.transfer.utils.Status.createOK();
        end

        function status = isValidValues_(obj, values)

            prev_size = [];
            for i = 1:numel(values)
                label = values{i}.label;

                if ~obj.isLabel(label)
                    continue
                end

                switch class(values{i})
                case 'gams.transfer.symbol.value.Numeric'
                    if ~isnumeric(obj.records_.(label))
                        status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be numeric.", label));
                        return
                    end
                case 'gams.transfer.symbol.value.String'

                    if (~gams.transfer.Constants.SUPPORTS_CATEGORICAL || ~iscategorical(obj.records_.(label))) && ~iscellstr(obj.records_.(label))
                        status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be categorical or cellstr.", label));
                        return
                    end
                otherwise
                    error('Unknown symbol value type: %s', class(values{i}));
                end

                if issparse(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must not be sparse.", label));
                    return
                end

                if ~iscolumn(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be column vector.", label));
                    return
                end

                curr_size = size(obj.records_.(label));
                if i > 1 && any(curr_size ~= prev_size)
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must have same size as other value columns.", label));
                    return
                end
                prev_size = curr_size;
            end

            status = gams.transfer.utils.Status.createOK();
        end

        function arg = validateDomains_(obj, name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.domain.Domain')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.domain.Domain''.', name, index, i);
                end
                if ~obj.isLabel(arg{i}.label)
                    error('Argument ''%s'' (at position %d, element %d) contains domain with unknown label ''%s''.', name, index, i, arg{i}.label);
                end
            end
        end

        function arg = validateValues_(obj, name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.value.Value')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.value.Value''.', name, index, i);
                end
                if ~obj.isLabel(arg{i}.label)
                    error('Argument ''%s'' (at position %d, element %d) contains domain with unknown label ''%s''.', name, index, i, arg{i}.label);
                end
            end
        end

        function subindex = ind2sub_(obj, domains, value, linindex)
            subindex = zeros(1, numel(domains));
            for i = 1:numel(domains)
                subindex(i) = double(obj.records_.(domains{i}.label)(linindex));
            end
        end

        function uels = getUniqueLabelsAt_(obj, domain, ignore_unused)

            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if ignore_unused
                    uels = categories(removecats(obj.records_.(domain.label)));
                else
                    uels = categories(obj.records_.(domain.label));
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end

        end

        function setUniqueLabelsAt_(obj, uels, domain, rename)

            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL

                if rename
                    obj.records_.(domain.label) = categorical(double(obj.records_.(domain.label)), ...
                        1:numel(uels), uels, 'Ordinal', true);
                else
                    obj.records_.(domain.label) = setcats(obj.records_.(domain.label), uels);
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end

        end

        function addUniqueLabelsAt_(obj, uels, domain)

            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if ~isordinal(obj.records_.(domain.label))
                    obj.records_.(domain.label) = addcats(obj.records_.(domain.label), uels);
                    return
                end
                cats = categories(obj.records_.(domain.label));
                if numel(cats) == 0
                    obj.records_.(domain.label) = categorical(uels, 'Ordinal', true);
                else
                    obj.records_.(domain.label) = addcats(obj.records_.(domain.label), uels, 'After', cats{end});
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end

        end

        function removeUniqueLabelsAt_(obj, uels, domain)

            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if isempty(uels)
                    obj.records_.(domain.label) = removecats(obj.records_.(domain.label));
                else
                    obj.records_.(domain.label) = removecats(obj.records_.(domain.label), uels);
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end

        end

    end

end
