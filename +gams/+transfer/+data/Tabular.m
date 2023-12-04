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
classdef (Abstract) Tabular < gams.transfer.data.Abstract

    methods

        function [flag, msg] = isValid(obj)
            % check domain columns
            labels = obj.domain_labels;
            for i = 1:numel(labels)
                if ~obj.isLabel(labels{i})
                    flag = false;
                    msg = sprintf("Records have no domain column '%s'.", labels{i});
                    return
                end

                if ~iscategorical(obj.records.(labels{i}))
                    flag = false;
                    msg = sprintf("Records domain column '%s' must be categorical.", labels{i});
                    return
                end
            end

            % check value columns
            labels = obj.value_labels;
            prev_size = [];
            for i = 1:numel(labels)
                if ~obj.isLabel(labels{i})
                    continue
                end

                if ~isnumeric(obj.records.(labels{i}))
                    flag = false;
                    msg = sprintf("Records value column '%s' must be numeric.", labels{i});
                    return
                end

                if issparse(obj.records.(labels{i}))
                    flag = false;
                    msg = sprintf("Records value column '%s' must not be sparse.", labels{i});
                    return
                end

                curr_size = size(obj.records.(labels{i}));
                if numel(curr_size) ~= 2 || curr_size(1) ~= 1
                    flag = false;
                    msg = sprintf("Records value column '%s' must be column vector.", labels{i});
                    return
                end

                if i > 1 && any(curr_size ~= prev_size)
                    flag = false;
                    msg = sprintf("Records value column '%s' must have same size as other value columns.", labels{i});
                    return
                end
                prev_size = curr_size;
            end

            flag = true;
            msg = '';
        end

        %> Returns the UELs used in this symbol
        %>
        %> - `u = getUELs()` returns the UELs across all dimensions.
        %> - `u = getUELs(d)` returns the UELs used in dimension(s) `d`.
        %> - `u = getUELs(d, i)` returns the UELs `u` for the given UEL codes `i`.
        %> - `u = getUELs(d, _, "ignore_unused", true)` returns only those UELs
        %>   that are actually used in the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid.
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in this symbol
            %
            % u = getUELs() returns the UELs across all dimensions.
            % u = getUELs(d) returns the UELs used in dimension(s) d.
            % u = getUELs(d, i) returns the UELs u for the given UEL codes i.
            % u = getUELs(_, 'ignore_unused', true) returns only those UELs that
            % are actually used in the records.
            %
            % Note: This can only be used if the symbol is valid.

            if ~obj.isValid()
                error('Records must be valid in order to manage UELs.');
            end

            % parse input arguments
            p = inputParser();
            addOptional(p, 'dim', 1:obj.dimension, ...
                @(x) validateattributes(x, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', obj.dimension}, ...
                'getUELs', 'dim', 1));
            addOptional(p, 'codes', [], ...
                @(x) validateattributes(x, {'numeric'}, {'vector'}, 'getUELs', 'codes', 2));
            addParameter(p, 'ignore_unused', false, ...
                @(x) validateattributes(x, {'logical'}, {'scalar'}, 'getUELs', 'ignore_unused'));
            parse(p, varargin{:});

            % no UELs for scalar records
            if obj.dimension == 0
                uels = {};
                return;
            end

            uels = {};
            labels = obj.domain_labels;
            for i = p.Results.dim
                if p.Results.ignore_unused
                    uels_i = categories(removecats(obj.records.(labels{i})));
                else
                    uels_i = categories(obj.records.(labels{i}));
                end

                % filter for given codes
                codes = p.Results.codes;
                if ~isempty(codes)
                    uels_i_orig = uels_i;
                    idx = codes >= 1 & codes <= numel(uels_i_orig);
                    uels_i = cell(numel(codes), 1);
                    uels_i(idx) = uels_i_orig(codes(idx));
                    uels_i(~idx) = {'<undefined>'};
                end

                uels = [uels; reshape(uels_i, numel(uels_i), 1)];
            end

            if numel(p.Results.dim) > 1
                uels = gams.transfer.utils.unique(uels);
            end
        end

        %> Sets UELs
        %>
        %> - `setUELs(u, d)` sets the UELs `u` for dimension(s) `d`. This may
        %>   modify UEL codes used in the property records such that records still
        %>   point to the correct UEL label when UEL codes have changed.
        %> - `setUELs(u, d, 'rename', true)` sets the UELs `u` for dimension(s)
        %>   `d`. This does not modify UEL codes used in the property records.
        %>   This can change the meaning of the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the records are valid.
        function setUELs(obj, varargin)
            % Sets UELs
            %
            % setUELs(u, d) sets the UELs u for dimension(s) d. This may modify
            % UEL codes used in the property records such that records still point
            % to the correct UEL label when UEL codes have changed.
            % setUELs(u, d, 'rename', true) sets the UELs u for dimension(s) d.
            % This does not modify UEL codes used in the property records. This
            % can change the meaning of the records.
            %
            % Note: This can only be used if the records are valid.

            if ~obj.isValid()
                error('Records must be valid in order to manage UELs.');
            end

            % parse input arguments
            p = inputParser();
            addRequired(p, 'uels', ...
                @(x) validateattributes(x, {'string', 'char', 'cell'}, {}, 'setUELs', 'uels', 1))
            addOptional(p, 'dim', 1:obj.dimension, ...
                @(x) validateattributes(x, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', obj.dimension}, ...
                'setUELs', 'dim', 2));
            addParameter(p, 'rename', false, ...
                @(x) validateattributes(x, {'logical'}, {'scalar'}, 'setUELs', 'rename'));
            parse(p, varargin{:});

            labels = obj.domain_labels;
            for i = p.Results.dim
                if p.Results.rename
                    obj.records.(labels{i}) = categorical(double(obj.records.(labels{i})), ...
                        1:numel(p.Results.uels), p.Results.uels, 'Ordinal', true);
                else
                    obj.records.(labels{i}) = setcats(obj.records.(labels{i}), p.Results.uels);
                end
            end
        end

        %> Reorders UELs
        %>
        %> Same functionality as `setUELs(uels, dim)`, but checks that no new categories are added.
        %> The meaning of records does not change.
        %>
        %> - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
        %>   appended.
        %>
        %> @see \ref gams::transfer::data::Tabular::setUELs "records.Tabular.setUELs"
        function reorderUELs(obj, varargin)
            % Reorders UELs
            %
            % Same functionality as setUELs(uels, dim), but checks that no new categories are added.
            % The meaning of records does not change.
            %
            % - reorderUELs() reorders UELs by record order for each dimension. Unused UELs are
            %   appended.
            %
            % See also: gams.transfer.data.Tabular.setUELs

            if ~obj.isValid()
                error('Records must be valid in order to manage UELs.');
            end

            % if no uels or dimension are given, reorder by record order
            if nargin == 1
                labels = obj.domain_labels;
                for i = 1:obj.dimension
                    uels = obj.getUELs(i);
                    rec_uels_ids = gams.transfer.utils.unique(uint64(obj.records.(labels{i})));
                    rec_uels_ids = rec_uels_ids(rec_uels_ids ~= nan);
                    obj.setUELs(uels(rec_uels_ids), i);
                    obj.addUELs(uels, i);
                end
                return
            end

            % parse input arguments
            p = inputParser();
            addRequired(p, 'uels', ...
                @(x) validateattributes(x, {'string', 'char', 'cell'}, {}, 'reorderUELs', 'uels', 1))
            addOptional(p, 'dim', 1:obj.dimension, ...
                @(x) validateattributes(x, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', obj.dimension}, ...
                'reorderUELs', 'dim', 2));
            parse(p, varargin{:});

            % check for valid given uels
            for i = p.Results.dim
                uels = obj.getUELs(i);
                if numel(p.Results.uels) ~= numel(uels)
                    error('Number of UELs %d not equal to number of current UELs %d', numel(uels), numel(uels));
                end
                if ~all(ismember(uels, p.Results.uels))
                    error('Adding new UELs not supported for reordering');
                end
            end

            obj.setUELs(p.Results.uels, p.Results.dim);
        end

        %> Adds UELs to the symbol
        %>
        %> - `addUELs(u)` adds the UELs `u` for all dimensions.
        %> - `addUELs(u, d)` adds the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid.
        function addUELs(obj, varargin)
            % Adds UELs to the symbol
            %
            % addUELs(u) adds the UELs u for all dimensions.
            % addUELs(u, d) adds the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid.

            if ~obj.isValid()
                error('Records must be valid in order to manage UELs.');
            end

            % parse input arguments
            p = inputParser();
            addRequired(p, 'uels', ...
                @(x) validateattributes(x, {'string', 'char', 'cell'}, {}, 'addUELs', 'uels', 1))
            addOptional(p, 'dim', 1:obj.dimension, ...
                @(x) validateattributes(x, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', obj.dimension}, ...
                'addUELs', 'dim', 2));
            parse(p, varargin{:});

            labels = obj.domain_labels;
            for i = p.Results.dim
                if ~isordinal(obj.records.(labels{i}))
                    obj.records.(labels{i}) = addcats(obj.records.(label{i}), p.Results.uels);
                    continue
                end

                cats = categories(obj.records.(labels{i}));
                if numel(cats) == 0
                    obj.records.(labels{i}) = categorical(p.Results.uels, 'Ordinal', true);
                else
                    obj.records.(labels{i}) = addcats(obj.records.(labels{i}), p.Results.uels, 'After', cats{end});
                end
            end
        end

        %> Removes UELs from the symbol
        %>
        %> - `removeUELs()` removes all unused UELs for all dimensions.
        %> - `removeUELs({}, d)` removes all unused UELs for dimension(s) `d`.
        %> - `removeUELs(u)` removes the UELs `u` for all dimensions.
        %> - `removeUELs(u, d)` removes the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid.
        function removeUELs(obj, varargin)
            % Removes UELs from the symbol
            %
            % removeUELs() removes all unused UELs for all dimensions.
            % removeUELs({}, d) removes all unused UELs for dimension(s) d.
            % removeUELs(u) removes the UELs u for all dimensions.
            % removeUELs(u, d) removes the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid.

            if ~obj.isValid()
                error('Records must be valid in order to manage UELs.');
            end

            % parse input arguments
            p = inputParser();
            addOptional(p, 'uels', {}, ...
                @(x) validateattributes(x, {'string', 'char', 'cell'}, {}, 'removeUELs', 'uels', 1))
            addOptional(p, 'dim', 1:obj.dimension, ...
                @(x) validateattributes(x, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', obj.dimension}, ...
                'removeUELs', 'dim', 2));
            parse(p, varargin{:});

            if obj.dimension == 0
                return
            end

            labels = obj.domain_labels;
            for i = p.Results.dim
                if isempty(p.Results.uels)
                    obj.records.(labels{i}) = removecats(obj.records.(labels{i}));
                else
                    obj.records.(labels{i}) = removecats(obj.records.(labels{i}), p.Results.uels);
                end
            end
        end

    end

end
