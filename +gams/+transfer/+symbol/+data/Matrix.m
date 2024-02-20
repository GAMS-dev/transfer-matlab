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

        function renameLabels(obj, old_labels, new_labels)
            if isstruct(obj.records_)
                obj.records = gams.transfer.utils.rename_struct_fields(obj.records_, old_labels, new_labels);
            end
        end

        function status = isValid(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues('Numeric', values);

            size_ = axes.matrixSize();
            for i = 1:numel(values)
                label = values{i}.label;

                switch class(values{i})
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
                    error('Unknown symbol value type: %s', class(values{i}));
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

        function indices = usedUniqueLabels(obj, axes, values, dimension)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            gams.transfer.utils.Validator('dimension', 3, dimension).integer().scalar().inInterval(1, axes.dimension);
            values = obj.availableValues('Numeric', values);
            if numel(values) == 0
                indices = [];
            else
                count = 0;
                for i = 1:numel(values)
                    size_ = size(obj.records_.(values{i}.label));
                    count = max(count, size_(dimension));
                end
                indices = 1:count;
            end
        end

        function nrecs = getNumberRecords(obj, axes, values)
            nrecs = nan;
        end

        function value = getMeanValue(obj, axes, values)
            values = obj.availableValues('Numeric', values);
            value = 0;
            for i = 1:numel(values)
                value = value + mean(obj.records_.(values{i}.label)(:));
            end
            if numel(values) == 0
                value = nan;
            else
                value = value / numel(values);
            end
        end

        function transformToTabular(obj, axes, values, data)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues('Numeric', values);
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Tabular');

            % get size
            size_ = axes.matrixSize();

            % get all possible indices (sorted by column)
            indices_ = cell(1, axes.dimension);
            [indices_{:}] = ind2sub(size_, 1:prod(size_));
            indices = zeros(prod(size_), axes.dimension);
            for i = 1:axes.dimension
                indices(:, i) = indices_{i};
            end
            [indices, indices_perm] = sortrows(indices, 1:axes.dimension);

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

            % domain columns
            for i = 1:axes.dimension
                axis = axes.axis(i);
                switch axis.domain.index_type.value
                case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                    data.records.(axis.domain.label) = axis.unique_labels.createCategoricalIndex(indices(:, i));
                case gams.transfer.symbol.domain.IndexType.INTEGER
                    data.records.(axis.domain.label) = axis.unique_labels.createIntegerIndex(indices(:, i));
                otherwise
                    error('Unsupported domain index type: %s', axis.domain.index_type.select);
                end
            end

            % values columns
            for i = 1:numel(values)
                data.records.(values{i}.label) = full(obj.records_.(values{i}.label)(indices_perm));
            end

            data.last_update_ = now();
        end

    end

    methods (Hidden, Access = protected)

        function subindex = ind2sub(obj, axes, value, linindex)
            [i, j] = ind2sub(size(obj.records_.(value.label)), linindex);
            subindex = [i, j];
        end

    end

end
