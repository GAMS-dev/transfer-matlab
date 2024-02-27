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
            data.copyFrom_(obj);
        end

        function labels = getLabels(obj)
            if istable(obj.records_)
                labels = obj.records_.Properties.VariableNames;
            else
                labels = {};
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.symbol.Abstract, ...
        ?gams.transfer.unique_labels.Abstract})

        function flag = isLabel_(obj, label)
            flag = istable(obj.records_) && ismember(label, obj.records_.Properties.VariableNames);
        end

        function renameLabels_(obj, oldlabels, newlabels)
            if istable(obj.records_)
                obj.records_ = renamevars(obj.records_, oldlabels, newlabels);
            end
        end

        function status = isValid_(obj, axes, values)
            if ~istable(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'table'.");
                return
            end
            status = isValid_@gams.transfer.symbol.data.Tabular(obj, axes, values);
        end

        function nrecs = getNumberRecords_(obj, axes, values)
            if istable(obj.records_)
                nrecs = height(obj.records_);
            else
                nrecs = nan;
            end
        end

        function transformToTabular_(obj, axes, values, data)
            if isa(data, 'gams.transfer.symbol.data.Table')
                data.records_ = obj.records_;
            elseif isa(data, 'gams.transfer.symbol.data.Struct')
                data.records_ = table2struct(obj.records_, 'ToScalar', true);
            else
                error('Invalid data: %s', class(data));
            end
            data.time_.reset();
        end

        function removeRows_(obj, indices)
            if istable(obj.records_)
                obj.records_(indices, :) = [];
            end
            obj.time_.reset();
        end

    end

end
