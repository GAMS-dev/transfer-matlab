% Matrix Data (internal)
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
% Matrix Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Matrix < gams.transfer.symbol.data.Abstract

    %#ok<*INUSD,*STOUT>

    methods

        function labels = getLabels(obj)
            if isstruct(obj.records_)
                labels = fieldnames(obj.records_);
            else
                labels = {};
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.symbol.Abstract, ...
        ?gams.transfer.unique_labels.Abstract})

        function flag = isLabel_(obj, label)
            flag = isfield(obj.records_, label);
        end

        function obj = renameLabels_(obj, oldlabels, newlabels)
            if isstruct(obj.records_)
                obj.records = gams.transfer.utils.rename_struct_fields(obj.records_, oldlabels, newlabels);
            end
        end

        function status = isValid_(obj, def, axes)
            size_ = axes.matrixSize();
            for i = 1:numel(def.values)
                label = def.values{i}.label;

                switch class(def.values{i})
                case 'gams.transfer.symbol.value.Numeric'
                    if isempty(obj.records_.(label))
                    elseif isnumeric(obj.records_.(label))
                    else
                        status = gams.transfer.utils.Status(sprintf("Records value '%s' must be numeric or empty.", label));
                        return
                    end
                case 'gams.transfer.symbol.value.String'
                    if ~isempty(obj.records_.(label))
                        status = gams.transfer.utils.Status(sprintf("Records value '%s' must be empty.", label));
                        return
                    end
                otherwise
                    error('Unknown symbol value type: %s', class(def.values{i}));
                end

                if isempty(obj.records_.(label))
                    continue
                end

                if any(size_ ~= size(obj.records_.(label)))
                    status = gams.transfer.utils.Status(sprintf("Records value '%s' have incorrect size.", label));
                    return
                end
            end

            status = gams.transfer.utils.Status.ok();
        end

        function indices = usedUniqueLabels_(obj, def, dimension)
            if numel(def.values) == 0
                indices = [];
            else
                count = 0;
                for i = 1:numel(def.values)
                    size_ = size(obj.records_.(def.values{i}.label));
                    count = max(count, size_(dimension));
                end
                indices = 1:count;
            end
        end

        function nrecs = getNumberRecords_(obj, def)
            nrecs = nan;
        end

        function value = getMeanValue_(obj, def)
            value = 0;
            for i = 1:numel(def.values)
                value = value + mean(obj.records_.(def.values{i}.label)(:));
            end
            if numel(def.values) == 0
                value = nan;
            else
                value = value / numel(def.values);
            end
        end

        function subindex = ind2sub_(obj, axes, value, linindex)
            [i, j] = ind2sub(size(obj.records_.(value.label)), linindex);
            subindex = [i, j];
        end

        function data = transformToTabular_(obj, def, axes, data)
            % get size
            dim = axes.dimension;
            size_ = axes.matrixSize();

            % get all possible indices (sorted by column)
            indices_ = cell(1, dim);
            [indices_{:}] = ind2sub(size_, 1:prod(size_));
            indices = zeros(prod(size_), dim);
            for i = 1:dim
                indices(:, i) = indices_{i};
            end
            [indices, indices_perm] = sortrows(indices, 1:dim);

            % get sparse indices
            keep_indices = false(1, prod(size_));
            for i = 1:numel(def.values)
                [row, col, val] = find(obj.records_.(def.values{i}.label));
                idx = sub2ind(size(obj.records_.(def.values{i}.label)), row, col);
                keep_indices(idx(val ~= def.values{i}.default)) = true;
            end
            keep_indices = keep_indices(indices_perm);
            indices(~keep_indices, :) = [];
            indices_perm(~keep_indices) = [];

            % domain columns
            for i = 1:dim
                axis = axes.axis(i);
                switch axis.domain.index_type.value
                case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                    data.records.(axis.domain.label) = ...
                        axis.unique_labels.createCategoricalIndexFromInteger_(indices(:, i));
                case gams.transfer.symbol.domain.IndexType.INTEGER
                    data.records.(axis.domain.label) = ...
                        axis.unique_labels.createIntegerIndexFromInteger_(indices(:, i));
                otherwise
                    error('Unsupported domain index type: %s', axis.domain.index_type.select);
                end
            end

            % values columns
            for i = 1:numel(def.values)
                data.records.(def.values{i}.label) = full(obj.records_.(def.values{i}.label)(indices_perm));
            end
        end

    end

end
