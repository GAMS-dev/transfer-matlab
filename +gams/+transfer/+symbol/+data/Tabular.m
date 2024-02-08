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

    methods

        function status = isValid(obj, axes, values)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues('Numeric', values);

            % empty is valid
            if numel(obj.getLabels()) == 0
                status = gams.transfer.utils.Status.createOK();
                return
            end

            prev_size = [];

            for i = 1:axes.dimension
                axis = axes.axis(i);
                label = axis.label;

                if ~obj.isLabel(label)
                    status = gams.transfer.utils.Status(sprintf("Records have no domain column '%s'.", label));
                    return
                end

                if isempty(obj.records_.(label))

                elseif iscategorical(obj.records_.(label))
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

            status = gams.transfer.utils.Status.createOK();
        end

        function flag = hasUniqueLabels(obj, domain)
            % TODO: check domain
            flag = gams.transfer.Constants.SUPPORTS_CATEGORICAL && ...
                obj.isLabel(domain.label) && iscategorical(obj.records_.(domain.label));
        end

        function indices = usedUniqueLabels(obj, domain)
            % TODO: check domain
            indices = gams.transfer.utils.unique(uint64(obj.records_.(domain.label)));
            indices = indices(~isnan(indices));
        end

        function labels = getUniqueLabels(obj, domain)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            labels = categories(obj.records_.(domain.label));
        end

        function addUniqueLabels(obj, domain, labels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end

            % TODO: check labels

            if ~isordinal(obj.records_.(domain.label))
                obj.records_.(domain.label) = addcats(obj.records_.(domain.label), labels);
                return
            end

            current_labels = categories(obj.records_.(domain.label));
            if numel(current_labels) == 0
                obj.records_.(domain.label) = categorical(labels, 'Ordinal', true);
            else
                obj.records_.(domain.label) = addcats(obj.records_.(domain.label), labels, 'After', current_labels{end});
            end
        end

        function setUniqueLabels(obj, domain, labels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            % TODO: check labels
            obj.records_.(domain.label) = categorical(double(obj.records_.(domain.label)), ...
                1:numel(labels), labels, 'Ordinal', true);
        end

        function updateUniqueLabels(obj, domain, labels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            % TODO: check labels
            obj.records_.(domain.label) = setcats(obj.records_.(domain.label), labels);
        end

        function removeUniqueLabels(obj, domain, labels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            % TODO: check labels
            obj.records_.(domain.label) = removecats(obj.records_.(domain.label), labels);
        end

        function removeUnusedUniqueLabels(obj, domain)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            obj.records_.(domain.label) = removecats(obj.records_.(domain.label));
        end

        function renameUniqueLabels(obj, domain, oldlabels, newlabels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            % TODO: check labels
            not_avail = ~ismember(oldlabels, categories(obj.records_.(domain.label)));
            oldlabels(not_avail) = [];
            newlabels(not_avail) = [];
            obj.records_.(domain.label) = renamecats(obj.records_.(domain.label), oldlabels, newlabels);
        end

        function mergeUniqueLabels(obj, domain, oldlabels, newlabels)
            if ~obj.hasUniqueLabels(domain)
                error('Data does not maintain unique labels for domain ''%s''.', domain.label);
            end
            % TODO: check labels
            obj.records_.(domain.label) = categorical(obj.records_.(domain.label), 'Ordinal', false);
            not_avail = ~ismember(oldlabels, categories(obj.records_.(domain.label)));
            oldlabels(not_avail) = [];
            newlabels(not_avail) = [];
            for j = 1:numel(newlabels)
                obj.records_.(domain.label) = mergecats(obj.records_.(domain.label), ...
                    oldlabels{j}, newlabels{j});
            end
            obj.records_.(domain.label) = categorical(obj.records_.(domain.label), 'Ordinal', true);
        end

        function nvals = getNumberValues(obj, axes, values)
            nvals = obj.getNumberRecords(axes, values) * numel(obj.availableValues('Numeric', values));
        end

        function value = getMeanValue(obj, axes, values)
            values = obj.availableValues('Numeric', values);
            value = 0;
            for i = 1:numel(values)
                value = value + sum(obj.records_.(values{i}.label)(:));
            end
            value = value / obj.getNumberRecords(axes, values) / numel(values);
        end

        function transformToMatrix(obj, axes, values, data)
            gams.transfer.utils.Validator('axes', 1, axes).type('gams.transfer.symbol.unique_labels.Axes');
            values = obj.availableValues('Numeric', values);
            if numel(values) == 0
                error('At least one numeric value column is required to transform to a matrix format.');
            end
            gams.transfer.utils.Validator('data', 3, data).type('gams.transfer.symbol.data.Matrix');
            if isa(data, 'gams.transfer.symbol.data.SparseMatrix') && axes.dimension > 2
                error('Sparse matrix does not support dimension larger than 2.');
            end

            % get matrix size
            size_ = axes.matrixSize();

            % convert indices to matrix (linear) indices
            if axes.dimension == 0
                idx = 1;
            else
                idx = cell(1, axes.dimension);
                for i = 1:axes.dimension
                    idx{i} = uint64(obj.records_.(axes.axis(i).label));
                end
                idx = sub2ind(size_, idx{:});
            end

            % init matrix records
            if isa(data, 'gams.transfer.symbol.data.DenseMatrix') && axes.dimension > 2
                for i = 1:numel(values)
                    data.records.(values{i}.label) = values{i}.default * ones(size_);
                end
            elseif isa(data, 'gams.transfer.symbol.data.SparseMatrix') && axes.dimension > 2
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
        end

    end

    methods (Hidden, Access = protected)

        function subindex = ind2sub(obj, axes, value, linindex)
            subindex = zeros(1, axes.dimension);
            for i = 1:axes.dimension
                subindex(i) = double(obj.records_.(axes.axis(i).label)(linindex));
            end
        end

    end

end
