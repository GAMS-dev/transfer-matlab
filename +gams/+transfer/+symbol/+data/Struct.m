% Struct Data (internal)
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
% Struct Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Struct < gams.transfer.symbol.data.Tabular

    %#ok<*INUSD,*STOUT>

    properties (Constant)
        name = 'struct'
    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.Container, ?gams.transfer.symbol.Abstract})

        function obj = Struct(records)
            obj.records_ = struct();
            if nargin >= 1
                obj.records = records;
            end
        end

    end

    methods (Static)

        function obj = construct(records)
            if nargin == 0
                obj = gams.transfer.symbol.data.Struct();
            else
                obj = gams.transfer.symbol.data.Struct(records);
            end
        end

    end

    methods

        function data = copy(obj)
            data = gams.transfer.symbol.data.Struct();
            data.copyFrom_(obj);
        end

        function labels = getLabels(obj)
            if isstruct(obj.records_)
                labels = fieldnames(obj.records_);
            else
                labels = {};
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.symbol.Abstract, ...
        ?gams.transfer.unique_labels.DomainSet})

        function flag = isLabel_(obj, label)
            flag = isfield(obj.records_, label);
        end

        function renameLabels_(obj, oldlabels, newlabels)
            if isstruct(obj.records_)
                obj.records = gams.transfer.utils.rename_struct_fields(obj.records_, oldlabels, newlabels);
            end
        end

        function status = isValid_(obj, axes, values)
            if ~isstruct(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'struct'.");
                return
            end
            status = isValid_@gams.transfer.symbol.data.Tabular(obj, axes, values);
        end

        function nrecs = getNumberRecords_(obj, axes, values)
            dim = axes.dimension;
            nrecs_axes = nan(1, dim);
            nrecs_values = nan(1, numel(values));
            for i = 1:dim
                label = axes.axis(i).domain.label;
                if isfield(obj.records_, label)
                    nrecs_axes(i) = numel(obj.records_.(label));
                end
            end
            for i = 1:numel(values)
                nrecs_values(i) = numel(obj.records_.(values{i}.label));
            end
            nrecs = [nrecs_axes, nrecs_values];
            nrecs = nrecs(~isnan(nrecs));

            if numel(nrecs) == 0
                nrecs = 0;
            elseif all(nrecs(1) == nrecs)
                nrecs = nrecs(1);
            else
                nrecs = nan;
            end
        end

        function transformToTabular_(obj, axes, values, data)
            if isa(data, 'gams.transfer.symbol.data.Table')
                data.records_ = struct2table(obj.records_);
            elseif isa(data, 'gams.transfer.symbol.data.Struct')
                data.records_ = obj.records_;
            else
                error('Invalid data: %s', class(data));
            end
            data.last_update_ = now();
        end

        function removeRows_(obj, indices)
            labels = obj.getLabels();
            for i = 1:numel(labels)
                disable = false(1, numel(obj.records_.(labels{i})));
                disable(indices) = true;
                obj.records_.(labels{i}) = obj.records_.(labels{i})(~disable);
            end
            obj.last_update_ = now();
        end

    end

end
