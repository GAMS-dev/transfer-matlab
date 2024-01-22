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

    end

end
