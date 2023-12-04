% Abstract Data
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
% Abstract Data
%

%> @brief Abstract Data
classdef (Abstract) AbstractData < handle

    properties (Hidden, SetAccess = protected)
        status_ = ''
        domains_ = {}
        domain_labels_ = {}
        value_labels_ = {}
    end

    properties (Dependent)
        dimension
        domains
    end

    properties (Abstract, SetAccess = private)
        labels
    end

    properties (Dependent)
        domain_labels
        value_labels
    end

    properties
        records
    end

    methods (Abstract)
        name = name(obj)
        [flag, msg] = isValid(obj)
    end

    methods

        function dimension = get.dimension(obj)
            dimension = obj.domains{1}.dimension;
        end

        function obj = set.dimension(obj, dimension)
            validateattributes(dimension, {'numeric'}, {'integer', '>=', 0, '<=', ...
                gams.transfer.Globals.MAX_DIMENSION}, 'set.dimension', 'dimension', 1);
            curr_dimension = obj.dimension;
            for i = 1:numel(obj.domains_)
                obj.domains_{i}.dimension = dimension;
            end
            if dimension < curr_dimension
                obj.domain_labels_ = obj.domain_labels(1:dimension);
            elseif dimension > curr_dimension
                labels = obj.domains{1}.names;
                if ~isempty(obj.domain_labels_)
                    labels(1:curr_dimension) = obj.domain_labels_(1:curr_dimension);
                end
                obj.domain_labels_ = gams.transfer.utils.unique_labels(labels);
            end
            obj.resetStatus();
        end

        function domains = get.domains(obj)
            domains = obj.domains_;
        end

        function set.domains(obj, domains)
            validateattributes(domains, {'cell'}, {'nonempty'}, 'set.domains', 'domains', 1);
            for i = 1:numel(domains)
                validateattributes(domains{i}, {'gams.transfer.domain.AbstractDomain'}, {}, 'set.domains', 'domains{i}', 1);
            end
            dim = domains{1}.dimension;
            for i = 1:numel(domains)
                if domains{i}.dimension ~= dim
                    error('Dimensions must be equal.');
                end
            end
            obj.domains_ = domains;
            obj.resetStatus();
        end

        function domain_labels = get.domain_labels(obj)
            if isempty(obj.domain_labels_)
                domain_labels = obj.domains{1}.makeLabels();
            else
                domain_labels = obj.domain_labels_;
            end
        end

        function obj = set.domain_labels(obj, domain_labels)
            validateattributes(domain_labels, {'cell'}, {'numel', obj.dimension}, 'set.domain_labels', 'domain_labels', 1);
            for i = 1:numel(domain_labels)
                if isstring(domain_labels{i})
                    domain_labels{i} = char(domain_labels{i});
                end
                validateattributes(domain_labels{i}, {'string', 'char'}, {'nonempty'}, 'set.domain_labels', 'domain_labels{i}', 1);
            end
            domain_labels = gams.transfer.utils.unique_labels(domain_labels);
            obj.domain_labels_ = reshape(domain_labels, 1, numel(domain_labels));
            obj.resetStatus();
        end

        function value_labels = get.value_labels(obj)
            value_labels = obj.value_labels_;
        end

        function obj = set.value_labels(obj, value_labels)
            validateattributes(value_labels, {'cell'}, {}, 'set.value_labels', 'value_labels', 1);
            for i = 1:numel(value_labels)
                if isstring(value_labels{i})
                    value_labels{i} = char(value_labels{i});
                end
                validateattributes(value_labels{i}, {'string', 'char'}, {'nonempty'}, 'set.value_labels', 'value_labels{i}', 1);
            end
            obj.value_labels_ = value_labels;
            obj.resetStatus();
        end

    end

    methods

        function flag = isLabel(obj, label)
            flag = ismember(label, obj.labels);
        end

        function flag = isDomainLabel(obj, label)
            flag = ismember(label, obj.domain_labels);
        end

        function flag = isValueLabel(obj, label)
            flag = ismember(label, obj.value_labels);
        end

        function uels = getUELs(obj, varargin)
            error('Record format ''%s'' does not support getting UELs.', obj.name());
        end

        function setUELs(obj, varargin)
            error('Record format ''%s'' does not support setting UELs.', obj.name());
        end

        function reorderUELs(obj, varargin)
            error('Record format ''%s'' does not support reordering UELs.', obj.name());
        end

        function addUELs(obj, varargin)
            error('Record format ''%s'' does not support adding UELs.', obj.name());
        end

        function removeUELs(obj, varargin)
            error('Record format ''%s'' does not support removing UELs.', obj.name());
        end

        function renameUELs(obj, varargin)
            error('Record format ''%s'' does not support renaming UELs.', obj.name());
        end

        %> Converts UELs to lower case
        %>
        %> - `lowerUELs()` converts the UELs for all dimension(s).
        %> - `lowerUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        function lowerUELs(obj, dim)
            % Converts UELs to lower case
            %
            % lowerUELs() converts the UELs for all dimension(s).
            % lowerUELs(d) converts the UELs for dimension(s) d.

            if nargin == 1
                dim = 1:obj.dimension;
            end

            symbols = obj.getUELs(dim);
            if isempty(symbols)
                return
            end
            rename_map = containers.Map(symbols, lower(symbols));
            obj.renameUELs(rename_map, dim, 'allow_merge', true);
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts the UELs for all dimension(s).
        %> - `upperUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        function upperUELs(obj, dim)
            % Converts UELs to upper case
            %
            % upperUELs() converts the UELs for all dimension(s).
            % upperUELs(d) converts the UELs for dimension(s) d.

            if nargin == 1
                dim = 1:obj.dimension;
            end

            symbols = obj.getUELs(dim);
            if isempty(symbols)
                return
            end
            rename_map = containers.Map(symbols, upper(symbols));
            obj.renameUELs(rename_map, dim, 'allow_merge', true);
        end

    end

    methods (Hidden, Access = protected)

        function [need_eval, flag, msg] = getStatus(obj)
            msg = obj.status_;
            need_eval = isempty(msg);
            flag = ~need_eval && strcmp(msg, 'ok');
        end

        function obj = setStatus(obj, status)
            assert(ischar(status));
            obj.status_ = status;
        end

        function resetStatus(obj)
            obj.status_ = '';
        end

    end

end
