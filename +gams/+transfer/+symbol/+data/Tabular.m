% Tabular Data (internal)
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
% Tabular Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Tabular < gams.transfer.symbol.data.Abstract

    %#ok<*INUSD,*STOUT>

    methods (Hidden, Access = {?gams.transfer.symbol.data.Abstract, ?gams.transfer.symbol.Abstract, ...
        ?gams.transfer.unique_labels.DomainSet})

        function status = isValid_(obj, axes, values)
            % empty is valid
            if numel(obj.getLabels()) == 0
                status = gams.transfer.utils.Status.ok();
                return
            end

            prev_size = [];

            for i = 1:axes.dimension
                axis = axes.axis(i);
                label = axis.domain.label;

                if ~obj.isLabel_(label)
                    status = gams.transfer.utils.Status(sprintf("Records have no domain column '%s'.", label));
                    return
                end

                if isempty(obj.records_.(label))

                elseif gams.transfer.Constants.SUPPORTS_CATEGORICAL && iscategorical(obj.records_.(label))
                    if any(isundefined(obj.records_.(label)))
                        status = gams.transfer.utils.Status(sprintf("Records domain column '%s' has undefined domain entries.", label));
                        return
                    end
                elseif isnumeric(obj.records_.(label))
                    if any(isnan(obj.records_.(label))) || any(isinf(obj.records_.(label)))
                        status = gams.transfer.utils.Status(sprintf("Records domain column '%s' has nan or inf domain entries.", label));
                        return
                    end
                    if min(obj.records_.(label)) < 1 || max(obj.records_.(label)) > axis.unique_labels.count()
                        status = gams.transfer.utils.Status(sprintf("Records domain column '%s' must have values in [%d,%d].", label, 1, axis.unique_labels.count()));
                        return
                    end
                else
                    status = gams.transfer.utils.Status(sprintf("Records domain column '%s' must be categorical, numeric or empty.", label));
                    return
                end

                curr_size = size(obj.records_.(label));
                if ~isempty(prev_size) && any(curr_size ~= prev_size)
                    status = gams.transfer.utils.Status(sprintf("Records domain column '%s' must have same size as other columns.", label));
                    return
                end
                prev_size = curr_size;
            end

            for i = 1:numel(values)
                label = values{i}.label;

                switch class(values{i})
                case 'gams.transfer.symbol.value.Numeric'
                    if isempty(obj.records_.(label))
                    elseif isnumeric(obj.records_.(label))
                    else
                        status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be numeric or empty.", label));
                        return
                    end
                case 'gams.transfer.symbol.value.String'

                    if isempty(obj.records_.(label))
                    elseif (gams.transfer.Constants.SUPPORTS_CATEGORICAL && iscategorical(obj.records_.(label))) || iscellstr(obj.records_.(label))
                    else
                        status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be categorical, cellstr or empty.", label));
                        return
                    end
                otherwise
                    error('Unknown symbol value type: %s', class(values{i}));
                end

                if issparse(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must not be sparse.", label));
                    return
                end

                if ~isempty(obj.records_.(label)) && ~iscolumn(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be column vector.", label));
                    return
                end

                curr_size = size(obj.records_.(label));
                if ~isempty(prev_size) && any(curr_size ~= prev_size)
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must have same size as other columns.", label));
                    return
                end
                prev_size = curr_size;
            end

            status = gams.transfer.utils.Status.ok();
        end

        function flag = hasUniqueLabels_(obj, domain)
            flag = gams.transfer.Constants.SUPPORTS_CATEGORICAL && ...
                obj.isLabel_(domain.label) && iscategorical(obj.records_.(domain.label));
        end

        function unique_labels = getUniqueLabels_(obj, domain)
            if obj.hasUniqueLabels_(domain)
                unique_labels = gams.transfer.unique_labels.CategoricalColumn(obj, domain);
            else
                unique_labels = [];
            end
        end

        function indices = usedUniqueLabels_(obj, axes, values, dimension)
            domain = axes.axis(dimension).domain;
            if ~obj.isLabel_(domain.label)
                indices = [];
                return
            end
            indices = gams.transfer.utils.unique(uint64(obj.records_.(domain.label)));
            indices = indices(~isnan(indices) & indices ~= 0);
        end

        function nvals = getNumberValues_(obj, axes, values)
            nvals = obj.getNumberRecords_(axes, values) * numel(values);
        end

        function value = getMeanValue_(obj, axes, values)
            value = 0;
            for i = 1:numel(values)
                value = value + sum(obj.records_.(values{i}.label)(:));
            end
            n_values = obj.getNumberRecords_(axes, values) * numel(values);
            if n_values == 0
                value = nan;
            else
                value = value / n_values;
            end
        end

        function subindex = ind2sub_(obj, axes, value, linindex)
            dim = axes.dimension;
            subindex = zeros(1, dim);
            for i = 1:dim
                subindex(i) = double(obj.records_.(axes.axis(i).domain.label)(linindex));
            end
        end

        function transformToMatrix_(obj, axes, values, data)
            if numel(values) == 0
                error('At least one numeric value column is required to transform to a matrix format.');
            end
            dim = axes.dimension;
            if isa(data, 'gams.transfer.symbol.data.SparseMatrix') && dim > 2
                error('Sparse matrix does not support dimension larger than 2.');
            end

            % get matrix size
            size_ = axes.matrixSize();

            % convert indices to matrix (linear) indices
            if dim == 0
                idx = 1;
            else
                idx = cell(1, dim);
                for i = 1:dim
                    idx{i} = uint64(obj.records_.(axes.axis(i).domain.label));
                end
                idx = sub2ind(size_, idx{:});
            end

            % init matrix records
            if isa(data, 'gams.transfer.symbol.data.DenseMatrix')
                for i = 1:numel(values)
                    data.records.(values{i}.label) = values{i}.default * ones(size_);
                end
            elseif isa(data, 'gams.transfer.symbol.data.SparseMatrix')
                for i = 1:numel(values)
                    if values{i}.default == 0
                        data.records.(values{i}.label) = sparse(size_(1), size_(2));
                    else
                        data.records.(values{i}.label) = sparse(values{i}.default * ones(size_));
                    end
                end
            end

            % copy records to matrices
            for i = 1:numel(values)
                data.records.(values{i}.label)(idx) = obj.records_.(values{i}.label);
            end

            data.last_update_ = now();
        end

        function permuteAxis_(obj, axes, values, dimension, permutation)
            domain = axes.axis(dimension).domain;
            if ~obj.isLabel(domain.label)
                return
            end
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL && iscategorical(obj.records_.(domain.label));
                unique_labels = obj.getUniqueLabels_(domain);
                unique_labels.set(unique_labels.getAt(permutation));
            else
                obj.records_.(domain.label) = reshape(uint64(permutation(obj.records_.(domain.label))), [], 1);
            end
        end

        function removeRows_(obj, indices)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

    end

    methods

        function removeRows(obj, indices)
            gams.transfer.utils.Validator('indices', 1, indices).integer().vector().min(1);
            obj.removeRows_(indices);
        end

    end

end
