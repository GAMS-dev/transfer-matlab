% Table Data (internal)
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
% Table Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Table < gams.transfer.symbol.data.Tabular

    %#ok<*INUSD,*STOUT>

    properties (Constant)
        name = 'table'
    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.Container, ?gams.transfer.symbol.Abstract})

        function obj = Table(records)
            obj.records_ = table();
            if nargin >= 1
                obj.records = records;
            end
        end

    end

    methods (Static)

        function obj = construct(records)
            if nargin == 0
                obj = gams.transfer.symbol.data.Table();
            else
                obj = gams.transfer.symbol.data.Table(records);
            end
        end

    end

    methods

        function data = copy(obj)
            data = gams.transfer.symbol.data.Table();
            data.copyFrom(obj);
        end

        function labels = getLabels(obj)
            if istable(obj.records_)
                labels = obj.records_.Properties.VariableNames;
            else
                labels = {};
            end
        end

        function renameLabels(obj, old_labels, new_labels)
            if istable(obj.records_)
                obj.records_ = renamevars(obj.records_, old_labels, new_labels);
            end
        end

        function status = isValid(obj, axes, values)
            if ~istable(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'table'.");
                return
            end

            status = isValid@gams.transfer.symbol.data.Tabular(obj, axes, values);
        end

        function nrecs = getNumberRecords(obj, axes, values)
            if istable(obj.records_)
                nrecs = height(obj.records_);
            else
                nrecs = nan;
            end
        end

        function transformToTabular(obj, axes, values, data)
            if isa(data, 'gams.transfer.symbol.data.Table')
                data.records = obj.records_;
            elseif isa(data, 'gams.transfer.symbol.data.Struct')
                data.records = table2struct(obj.records_, 'ToScalar', true);
            else
                error('Invalid data: %s', class(data));
            end
        end

        function removeRows(obj, indices)
            gams.transfer.utils.Validator('indices', 1, indices).integer().vector().min(1);
            if istable(obj.records_)
                obj.records_(indices, :) = [];
            end
        end

    end

end
