% GAMS Parameter
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
% GAMS Parameter
%
% Represents a GAMS Parameter.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of parameter
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Parameter records. Default is [].
% - description (string):
%   Description of symbol. Default is "".
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain
%   forwarding can be enabled/disabled independently for each domain. Default: false.
%
% Example:
% c = Container();
% p1 = symbol.Parameter(c, 'p1');
% p2 = symbol.Parameter(c, 'p2', {'*', '*'});
% p3 = symbol.Parameter(c, 'p3', '*', 'description', 'par p3');
%
% See also: gams.transfer.Parameter, gams.transfer.Container.addParameter

%> @brief GAMS Parameter
%>
%> Represents a GAMS Parameter.
%>
%> **Example:**
%> ```
%> c = Container();
%> p1 = symbol.Parameter(c, 'p1');
%> p2 = symbol.Parameter(c, 'p2', {'*', '*'});
%> p3 = symbol.Parameter(c, 'p3', '*', 'description', 'par p3');
%> ```
%>
%> @see \ref gams::transfer::Parameter "Parameter", \ref
%> gams::transfer::Container::addParameter "Container.addParameter"
classdef Parameter < gams.transfer.symbol.Abstract

    methods

        %> @brief Constructs a GAMS Parameter
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should be stored in
        %> 2. name (`string`):
        %>    Name of parameter
        %>
        %> **Optional Arguments:**
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Parameter records. Default is `[]`.
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
        %> p1 = symbol.Parameter(c, 'p1');
        %> p2 = symbol.Parameter(c, 'p2', {'*', '*'});
        %> p3 = symbol.Parameter(c, 'p3', '*', 'description', 'par p3');
        %> ```
        %>
        %> @see \ref gams::transfer::Parameter "Parameter", \ref
        %> gams::transfer::Container::addParameter "Container.addParameter"
        function obj = Parameter(varargin)
            % Constructs a GAMS Parameter, see class help

            obj.def_ = gams.transfer.def.Definition();
            obj.data_ = gams.transfer.data.Unknown();

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
                            index + 1, 'domain_forwarding', @gams.transfer.def.Domain.validateForwarding);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 3
                        obj.def_.domains_ = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'domains', @gams.transfer.def.Definition.validateDomains);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % create default value definition
            gdx_default_values = gams.transfer.cmex.gt_get_defaults(obj);
            obj.def_.values_ = struct(...
                'value', gams.transfer.def.NumericValue('value', gdx_default_values(1)));
        end

    end

    methods (Static)

        %> Returns an overview over all parameters given
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Required Arguments:**
        %> 1. symbols (list):
        %>    List of parameters to include.
        %>
        %> The overview is in form of a table listing for each symbol its main characteristics and
        %> some statistics.
        function descr = describe(symbols)
            % Returns an overview over all parameters given
            %
            % Optional Arguments:
            % 1. symbols (list):
            %    List of parameters to include.
            %
            % The overview is in form of a table listing for each symbol its main characteristics
            % and some statistics.

            symbols = gams.transfer.utils.validate_cell('symbols', 1, symbols, ...
                {'gams.transfer.symbol.Parameter'}, 1);

            descr = struct();
            descr.name = cell(numel(symbols), 1);
            descr.format = cell(numel(symbols), 1);
            descr.dimension = zeros(numel(symbols), 1);
            descr.domain_type = cell(numel(symbols), 1);
            descr.domain = cell(numel(symbols), 1);
            descr.size = cell(numel(symbols), 1);
            descr.number_records = zeros(numel(symbols), 1);
            descr.number_values = zeros(numel(symbols), 1);
            descr.sparsity = zeros(numel(symbols), 1);
            descr.min = zeros(numel(symbols), 1);
            descr.mean = zeros(numel(symbols), 1);
            descr.max = zeros(numel(symbols), 1);
            descr.where_min = cell(numel(symbols), 1);
            descr.where_max = cell(numel(symbols), 1);

            for i = 1:numel(symbols)
                descr.name{i} = symbols{i}.name;
                descr.format{i} = symbols{i}.format;
                descr.dimension(i) = symbols{i}.dimension;
                % descr.domain_type{i} = symbols{i}.domain_type;
                % descr.domain{i} = gams.transfer.Utils.list2str(symbols{i}.domain);
                % descr.size{i} = gams.transfer.Utils.list2str(symbols{i}.size);
                descr.number_records(i) = symbols{i}.getNumberRecords();
                % descr.number_values(i) = symbols{i}.getNumberValues();
                % descr.sparsity(i) = symbols{i}.getSparsity();
                % [descr.min(i), descr.where_min{i}] = gams.transfer.getMinValue(symbols{i}, symbols{i}.container.indexed);
                % if isnan(descr.min(i))
                %     descr.where_min{i} = '';
                % else
                %     descr.where_min{i} = gams.transfer.Utils.list2str(descr.where_min{i});
                % end
                % descr.mean(i) = gams.transfer.getMeanValue(symbols{i});
                % [descr.max(i), descr.where_max{i}] = gams.transfer.getMaxValue(symbols{i}, symbols{i}.container.indexed);
                % if isnan(descr.max(i))
                %     descr.where_max{i} = '';
                % else
                %     descr.where_max{i} = gams.transfer.Utils.list2str(descr.where_max{i});
                % end
            end

            % convert to categorical if possible
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                % descr.domain_type = categorical(descr.domain_type);
                % descr.domain = categorical(descr.domain);
                % descr.size = categorical(descr.size);
                % descr.where_min = categorical(descr.where_min);
                % descr.where_max = categorical(descr.where_max);
            end

            % convert to table if possible
            if gams.transfer.Constants.SUPPORTS_TABLE
                descr = struct2table(descr);
            end
        end

    end

end
