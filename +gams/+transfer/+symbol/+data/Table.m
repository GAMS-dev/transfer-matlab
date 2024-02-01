% Table Records (internal)
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
% Table Records (internal)
%
classdef Table < gams.transfer.symbol.data.Tabular

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            if istable(obj.records_)
                labels = obj.records_.Properties.VariableNames;
            else
                labels = {};
            end
        end

    end

    methods

        function obj = Table(records)
            if nargin >= 1
                obj.records = records;
            end
        end

        function name = name(obj)
            name = 'table';
        end

        function renameLabels(obj, old_labels, new_labels)
            if ~istable(obj.records_)
                error('Cannot rename labels: Records are invalid.');
            end
            obj.records_ = renamevars(obj.records_, old_labels, new_labels);
        end

        function def = copy(obj)
            def = gams.transfer.symbol.data.Table();
            def.copyFrom(obj);
        end

        function status = isValid(obj, def)
            if ~istable(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'table'.");
                return
            end

            status = isValid@gams.transfer.symbol.data.Tabular(obj, def);
        end

        function data = transform(obj, def, format)
            def = obj.validateDefinition('def', 1, def);
            format = lower(gams.transfer.utils.validate('format', 1, format, {'string', 'char'}, -1));

            switch format
            case 'table'
                data = gams.transfer.symbol.data.Table(obj.records_);
            case 'struct'
                data = gams.transfer.symbol.data.Struct(table2struct(obj.records_, 'ToScalar', true));
            case {'dense_matrix', 'sparse_matrix'}
                data = obj.transformToMatrix(def, format);
            otherwise
                error('Unknown records format: %s', format);
            end
        end

        function nrecs = getNumberRecords(obj, def)
            if istable(obj.records_)
                nrecs = height(obj.records_);
            else
                nrecs = nan;
            end
        end

    end

    methods (Static)

        function obj = Empty(domains)
            domains = gams.transfer.symbol.data.Data.validateDomains('domains', 1, domains);
            obj = gams.transfer.symbol.data.Table(table());
            for i = 1:numel(domains)
                obj.records_.(domains{i}.label) = obj.createUniqueLabelsIntegerIndex([], {});
            end
        end

    end

end
