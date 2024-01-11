% GAMS Variable
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
% GAMS Variable
%
% Represents a GAMS Variable.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of variable
%
% Optional Arguments:
% 3. type (string, int or gams.transfer.VariableType):
%    Specifies the variable type, either as string, as integer given by any of the
%    constants in gams.transfer.VariableType or
%    gams.transfer.VariableType. Default is "free".
% 4. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is "".
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain forwarding
%   can be enabled/disabled independently for each domain. Default: false.
%
% Example:
% c = Container();
% v1 = symbol.Variable(c, 'v1');
% v2 = symbol.Variable(c, 'v2', 'binary', {'*', '*'});
% v3 = symbol.Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%
% See also: gams.transfer.Variable, gams.transfer.Container.addVariable,
% gams.transfer.VariableType

%> @brief GAMS Variable
%>
%> Represents a GAMS Variable.
%>
%> **Example:**
%> ```
%> c = Container();
%> v1 = symbol.Variable(c, 'v1');
%> v2 = symbol.Variable(c, 'v2', 'binary', {'*', '*'});
%> v3 = symbol.Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%> ```
%>
%> @see \ref gams::transfer::Variable "Variable", \ref
%> gams::transfer::Container::addVariable "Container.addVariable", \ref
%> gams::transfer::VariableType "VariableType"
classdef Variable < gams.transfer.symbol.Symbol

    properties (Dependent)
        %> Variable type, e.g. 'free'

        % type Variable type, e.g. 'free'
        type
    end

    properties (Dependent, SetAccess = private)
        %> Variable default values

        % default_values Variable default values
        default_values
    end

    methods

        function type = get.type(obj)
            type = lower(obj.def_.type.select);
        end

        function obj = set.type(obj, type)
            obj.def_.type = type;
        end

        function default_values = get.default_values(obj)
            default_values = struct();
            default_values.level = obj.def_.values.level.default;
            default_values.marginal = obj.def_.values.marginal.default;
            default_values.lower = obj.def_.values.lower.default;
            default_values.upper = obj.def_.values.upper.default;
            default_values.scale = obj.def_.values.scale.default;
        end

    end

    methods

        %> @brief Constructs a GAMS Variable
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should be stored in
        %> 2. name (`string`):
        %>    Name of variable
        %>
        %> **Optional Arguments:**
        %> 3. type (`string`, `int` or \ref gams::transfer::VariableType "VariableType"):
        %>    Specifies the variable type, either as `string`, as `integer` given by any of the
        %>    constants in \ref gams::transfer::VariableType "VariableType" or \ref
        %>    gams::transfer::VariableType "VariableType". Default is `"free"`.
        %> 4. domain (`cellstr` or `Set`):
        %>    List of domains given either as string or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Set records, e.g. a list of strings. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> v1 = symbol.Variable(c, 'v1');
        %> v2 = symbol.Variable(c, 'v2', 'binary', {'*', '*'});
        %> v3 = symbol.Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
        %> ```
        %>
        %> @see \ref gams::transfer::Variable "Variable", \ref
        %> gams::transfer::Container::addVariable "Container.addVariable", \ref
        %> gams::transfer::VariableType "VariableType"
        function obj = Variable(varargin)
            % Constructs a GAMS Variable, see class help

            obj.def_ = gams.transfer.symbol.definition.Variable();
            obj.data_ = gams.transfer.symbol.data.Unknown();

            % parse input arguments
            try
                obj.container_ = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'container', @obj.validateContainer);
                obj.name_ = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'name', @obj.validateName);
                index = 3;
                is_pararg = false;
                while index <= nargin
                    if strcmpi(varargin{index}, 'description')
                        obj.description_ = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'description', @obj.validateDescription);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'domain_forwarding')
                        obj.domain_forwarding = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'domain_forwarding', []);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 3
                        obj.def_.type = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'type', []);
                        index = index + 1;
                    elseif ~is_pararg && index == 4
                        obj.def_.domains = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'domains', []);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end
        end

    end

    methods (Static)

        %> Returns an overview over all variables given
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Required Arguments:**
        %> 1. symbols (list):
        %>    List of variables to include.
        %>
        %> The overview is in form of a table listing for each symbol its main characteristics and
        %> some statistics.
        function descr = describe(symbols)
            % Returns an overview over all variables given
            %
            % Optional Arguments:
            % 1. symbols (list):
            %    List of variables to include.
            %
            % The overview is in form of a table listing for each symbol its main characteristics
            % and some statistics.

            symbols = gams.transfer.utils.validate_cell('symbols', 1, symbols, ...
                {'gams.transfer.symbol.Variable'}, 1);

            descr = struct();
            descr.name = cell(numel(symbols), 1);
            descr.type = cell(numel(symbols), 1);
            descr.format = cell(numel(symbols), 1);
            descr.dimension = zeros(numel(symbols), 1);
            descr.domain_type = cell(numel(symbols), 1);
            descr.domain = cell(numel(symbols), 1);
            descr.size = cell(numel(symbols), 1);
            descr.number_records = zeros(numel(symbols), 1);
            descr.number_values = zeros(numel(symbols), 1);
            descr.sparsity = zeros(numel(symbols), 1);
            descr.min_level = zeros(numel(symbols), 1);
            descr.mean_level = zeros(numel(symbols), 1);
            descr.max_level = zeros(numel(symbols), 1);
            descr.where_max_abs_level = cell(numel(symbols), 1);

            for i = 1:numel(symbols)
                descr.name{i} = symbols{i}.name;
                descr.type{i} = symbols{i}.type;
                descr.format{i} = symbols{i}.format;
                descr.dimension(i) = symbols{i}.dimension;
                % descr.domain_type{i} = symbols{i}.domain_type;
                % descr.domain{i} = gams.transfer.Utils.list2str(symbols{i}.domain);
                % descr.size{i} = gams.transfer.Utils.list2str(symbols{i}.size);
                descr.number_records(i) = symbols{i}.getNumberRecords();
                % descr.number_values(i) = symbols{i}.getNumberValues();
                % descr.sparsity(i) = symbols{i}.getSparsity();
                % descr.min_level(i) = gams.transfer.getMinValue(symbols{i}, symbols{i}.container.indexed, 'level');
                % descr.mean_level(i) = gams.transfer.getMeanValue(symbols{i}, 'level');
                % descr.max_level(i) = gams.transfer.getMaxValue(symbols{i}, symbols{i}.container.indexed, 'level');
                % [absmax, descr.where_max_abs_level{i}] = gams.transfer.getMaxAbsValue(symbols{i}, symbols{i}.container.indexed, 'level');
                % if isnan(absmax)
                %     descr.where_max_abs_level{i} = '';
                % else
                %     descr.where_max_abs_level{i} = gams.transfer.Utils.list2str(descr.where_max_abs_level{i});
                % end
            end

            % convert to categorical if possible
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                % descr.domain_type = categorical(descr.domain_type);
                % descr.domain = categorical(descr.domain);
                % descr.size = categorical(descr.size);
                % descr.type = categorical(descr.type);
                % descr.where_max_abs_level = categorical(descr.where_max_abs_level);
            end

            % convert to table if possible
            if gams.transfer.Constants.SUPPORTS_TABLE
                descr = struct2table(descr);
            end
        end

    end

end
