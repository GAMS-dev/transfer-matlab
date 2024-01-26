% Matrix Records (internal)
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
% Matrix Records (internal)
%
classdef (Abstract) Matrix < gams.transfer.symbol.data.Data

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            labels = fieldnames(obj.records_);
        end

    end

    methods

        function renameLabels(obj, old_labels, new_labels)
            % TODO: check old_labels and new_labels
            if ~isstruct(obj.records_)
                error('Cannot rename labels: Records are invalid.');
            end
            records = struct();
            labels = fieldnames(obj.records_);
            for i = 1:numel(labels)
                idx = find(strcmp(labels{i}, old_labels), 1, 'first');
                if isempty(idx)
                    records.(labels{i}) = obj.records_.(labels{i});
                else
                    records.(new_labels{idx}) = obj.records_.(labels{i});
                end
            end
            obj.records = records;
        end

        function status = isValid(obj, def)
            def = gams.transfer.utils.validate('def', 1, def, {'gams.transfer.symbol.definition.Definition'}, -1);

            % TODO

            status = gams.transfer.utils.Status.createOK();
        end

        function nrecs = getNumberRecords(obj, def)
            nrecs = nan;
        end

        function value = getMeanValue(obj, def, varargin)

            [domains, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);

            value = 0;
            for i = 1:numel(values)
                value = value + mean(obj.records_.(values{i}.label)(:));
            end

            value = value / numel(values);
        end

    end

    methods (Hidden, Access = protected)

        function arg = validateDomains_(obj, name, index, arg)
            % if ~iscell(arg)
            %     error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            % end
            % for i = 1:numel(arg)
            %     if ~isa(arg{i}, 'gams.transfer.symbol.domain.Domain')
            %         error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.domain.Domain''.', name, index, i);
            %     end
            %     if ~obj.isLabel(arg{i}.label)
            %         error('Argument ''%s'' (at position %d, element %d) contains domain with unknown label ''%s''.', name, index, i, arg{i}.label);
            %     end
            % end
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
            [i, j] = ind2sub(size(obj.records_.(value.label)), linindex);
            subindex = [i, j];
        end

        function uels = getUniqueLabelsAt_(obj, domain, ignore_unused)

            uels = domain.getUniqueLabels();

        end

        function setUniqueLabelsAt_(obj, uels, domain, rename)
            error('Records format ''%s'' does not support setting UELs. Modify domain instead.', obj.name());
        end

        function addUniqueLabelsAt_(obj, uels, domain)
            error('Records format ''%s'' does not support setting UELs. Modify domain instead.', obj.name());
        end

        function removeUniqueLabelsAt_(obj, uels, domain)
            error('Records format ''%s'' does not support setting UELs. Modify domain instead.', obj.name());
        end

        function data = transformToTabular(obj, def, format)
            def = obj.validateDefinition('def', 1, def);
            format = lower(gams.transfer.utils.validate('format', 1, format, {'string', 'char'}, -1));
            values = obj.availableNumericValues(def.values);

            % create data
            switch format
            case 'table'
                data = gams.transfer.symbol.data.Table(table());
            case 'struct'
                data = gams.transfer.symbol.data.Struct.Empty(def.domains);
            otherwise
                error('Unknown records format: %s', format);
            end

            % get size
            size_ = ones(1, max(2, def.dimension));
            size_(1:def.dimension) = def.size;

            % get all possible indices (sorted by column)
            indices_ = cell(1, def.dimension);
            [indices_{:}] = ind2sub(size_, 1:prod(size_));
            indices = zeros(prod(size_), def.dimension);
            for i = 1:def.dimension
                indices(:, i) = indices_{i};
            end
            [indices, indices_perm] = sortrows(indices, 1:def.dimension);

            % get sparse indices
            keep_indices = false(1, prod(size_));
            for i = 1:numel(values)
                [row, col, val] = find(obj.records_.(values{i}.label));
                idx = sub2ind(size(obj.records_.(values{i}.label)), row, col);
                keep_indices(idx(val ~= values{i}.default)) = true;
            end
            keep_indices = keep_indices(indices_perm);
            indices(~keep_indices, :) = [];
            indices_perm(~keep_indices) = [];

            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                index_type = gams.transfer.symbol.domain.IndexType.Categorical();
            else
                index_type = gams.transfer.symbol.domain.IndexType.Integer();
            end

            % domain columns
            for i = 1:numel(def.domains)
                data.records.(def.domains{i}.label) = def.domains{i}.createIndexFromIntegers(index_type, indices(:, i));
            end
            data.removeUELs({}, def.domains);

            % values columns
            for i = 1:numel(values)
                data.records.(values{i}.label) = full(obj.records_.(values{i}.label)(indices_perm));
            end
        end

    end

end
