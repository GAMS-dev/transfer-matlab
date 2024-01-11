% Tabular Record
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
% Tabular Record
%

%> @brief Tabular Record
classdef (Abstract) Tabular < gams.transfer.symbol.data.Abstract

    methods

        function status = isValid(obj, def)
            validateattributes(def, {'gams.transfer.symbol.Definition'}, {}, 'isValid', 'def', 1);

            status = obj.isValidDomains(def.domains);
            if status.isOK()
                status = obj.isValidValues(def.valueLabels());
            end
        end

    end

    methods (Hidden, Access = protected)

        function status = isValidDomains(obj, domains)
            for i = 1:numel(domains)
                label = domains{i}.label;

                if ~obj.isLabel(label)
                    status = gams.transfer.utils.Status(sprintf("Records have no domain column '%s'.", label));
                    return
                end

                if ~iscategorical(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records domain column '%s' must be categorical.", label));
                    return
                end
            end

            status = gams.transfer.utils.Status('OK');
        end

        function status = isValidValues(obj, value_labels)

            prev_size = [];
            for i = 1:numel(obj.value_labels)
                label = value_labels{i};

                if ~obj.isLabel(label)
                    continue
                end

                if ~isnumeric(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be numeric.", label));
                    return
                end

                if issparse(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must not be sparse.", label));
                    return
                end

                curr_size = size(obj.records_.(label));
                if numel(curr_size) ~= 2 || curr_size(1) ~= 1
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must be column vector.", label));
                    return
                end

                if i > 1 && any(curr_size ~= prev_size)
                    status = gams.transfer.utils.Status(sprintf("Records value column '%s' must have same size as other value columns.", label));
                    return
                end
                prev_size = curr_size;
            end

            status = gams.transfer.utils.Status('OK');
        end

        function uels = getUniqueLabelsAt(obj, domain, ignore_unused)

            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if ignore_unused
                    uels = categories(removecats(obj.records_.(domain.label)));
                else
                    uels = categories(obj.records_.(domain.label));
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end
        end

        function setUniqueLabelsAt(obj, uels, domain, rename)
            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL

                if rename
                    obj.records_.(domain.label) = categorical(double(obj.records_.(domain.label)), ...
                        1:numel(uels), uels, 'Ordinal', true);
                else
                    obj.records_.(domain.label) = setcats(obj.records_.(domain.label), uels);
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end
        end

        function addUniqueLabelsAt(obj, uels, domain)
            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if ~isordinal(obj.records_.(domain.label))
                    obj.records_.(domain.label) = addcats(obj.records_.(domain.label), uels);
                    return
                end
                cats = categories(obj.records_.(domain.label));
                if numel(cats) == 0
                    obj.records_.(domain.label) = categorical(uels, 'Ordinal', true);
                else
                    obj.records_.(domain.label) = addcats(obj.records_.(domain.label), uels, 'After', cats{end});
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end
        end

        function removeUniqueLabelsAt(obj, uels, domain)
            switch domain.index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                if isempty(uels)
                    obj.records_.(domain.label) = removecats(obj.records_.(domain.label));
                else
                    obj.records_.(domain.label) = removecats(obj.records_.(domain.label), uels);
                end
            otherwise
                error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                    obj.name(), domain.index_type.select);
            end
        end

    end

end
