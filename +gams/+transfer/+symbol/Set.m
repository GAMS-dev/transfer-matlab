% GAMS Set
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
% GAMS Set
%
% Represents a GAMS Set.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of set
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {"*"} (for 1-dim with universe domain).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is `[]`.
% - description (string):
%   Description of symbol. Default is "".
% - is_singleton (logical):
%   Indicates if set is a is_singleton set (true) or not (false). Default is false.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain forwarding
%   can be enabled/disabled independently for each domain. Default: false.
%
% Example:
% c = Container();
% s1 = symbol.Set(c, 's1');
% s2 = symbol.Set(c, 's2', {s1, '*', '*'});
% s3 = symbol.Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%
% See also: gams.transfer.Set, gams.transfer.Container.addSet

%> @brief GAMS Set
%>
%> Represents a GAMS Set.
%>
%> **Example:**
%> ```
%> c = Container();
%> s1 = symbol.Set(c, 's1');
%> s2 = symbol.Set(c, 's2', {s1, '*', '*'});
%> s3 = symbol.Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%> ```
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container::addSet
%> "Container.addSet"
classdef Set < gams.transfer.symbol.Symbol

    properties (Dependent)
        %> indicator if Set is is_singleton

        % is_singleton indicator if Set is is_singleton
        is_singleton
    end

    methods

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.def_.is_singleton_;
        end

        function obj = set.is_singleton(obj, is_singleton)
            obj.def_.is_singleton = singleton;
        end

    end

    methods

        %> @brief Constructs a GAMS Set
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should be stored in
        %> 2. name (`string`):
        %>    Name of set
        %>
        %> **Optional Arguments:**
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{"*"}` (for 1-dim with
        %>    universe domain).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Set records, e.g. a list of strings. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - is_singleton (`logical`):
        %>   Indicates if set is a is_singleton set (`true`) or not (`false`). Default is `false`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s1 = symbol.Set(c, 's1');
        %> s2 = symbol.Set(c, 's2', {s1, '*', '*'});
        %> s3 = symbol.Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container::addSet
        %> "Container.addSet"
        function obj = Set(varargin)
            % Constructs a GAMS Set, see class help

            obj.def_ = gams.transfer.symbol.definition.Set();

            % parse input arguments
            has_records = false;
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
                    elseif strcmpi(varargin{index}, 'is_singleton')
                        obj.def_.is_singleton = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'is_singleton', []);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'records')
                        obj.data_ = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'records', @obj.validateData);
                        has_records = true;
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 3
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
            if ~has_records
                obj.data_ = gams.transfer.symbol.data.Struct();
            end
        end

        %> Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to `relaxed` if the destination container does not have
        %> equivalent domain sets, see also \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination \ref gams::transfer::Container "Container"
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`. Default: `false`.
        function symbol = copy(obj, varargin)
            % Copies symbol to destination container
            %
            % Symbol domains are downgraded to relaxed if the destination container does not have
            % equivalent domain sets.
            %
            % Required Arguments:
            % 1. destination (Container):
            %    Destination container
            %
            % Optional Arguments:
            % 2. overwrite (bool):
            %    Overwrites symbol with same name in destination if true. Default: false.

            % parse input arguments
            try
                validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'gams.transfer.Container'}, -1));
                destination = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'destination', validate);
                index = 2;
                is_pararg = false;
                while index < nargin
                    if ~is_pararg && index == 2
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        overwrite = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'overwrite', validate);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % create new (empty) symbol
            if destination.hasSymbols(obj.name_)
                if ~overwrite
                    error('Symbol already exists in destination.');
                end
                symbol = destination.getSymbols(obj.name_);
                if ~isa(symbol, class(obj))
                    destination.removeSymbols(obj.name_);
                    symbol = destination.addSet(obj.name_);
                end
            else
                symbol = destination.addSet(obj.name_);
            end

            symbol.copyFrom(obj);
        end

    end

    methods (Static)

        %> Returns an overview over all sets given
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Required Arguments:**
        %> 1. symbols (list):
        %>    List of sets to include.
        %>
        %> The overview is in form of a table listing for each symbol its main characteristics and
        %> some statistics.
        function descr = describe(symbols)
            % Returns an overview over all sets given
            %
            % Optional Arguments:
            % 1. symbols (list):
            %    List of sets to include.
            %
            % The overview is in form of a table listing for each symbol its main characteristics
            % and some statistics.

            symbols = gams.transfer.utils.validate_cell('symbols', 1, symbols, ...
                {'gams.transfer.symbol.Set'}, 1);

            descr = struct();
            descr.name = cell(numel(symbols), 1);
            descr.is_singleton = true(numel(symbols), 1);
            descr.format = cell(numel(symbols), 1);
            descr.dimension = zeros(numel(symbols), 1);
            descr.domain_type = cell(numel(symbols), 1);
            descr.domain = cell(numel(symbols), 1);
            descr.size = cell(numel(symbols), 1);
            descr.number_records = zeros(numel(symbols), 1);
            descr.number_values = zeros(numel(symbols), 1);
            descr.sparsity = zeros(numel(symbols), 1);

            for i = 1:numel(symbols)
                descr.name{i} = symbols{i}.name;
                descr.is_singleton(i) = symbols{i}.is_singleton;
                descr.format{i} = symbols{i}.format;
                descr.dimension(i) = symbols{i}.dimension;
                descr.domain_type{i} = symbols{i}.domain_type;
                descr.domain{i} = gams.transfer.utils.list2str(symbols{i}.domain_names);
                descr.size{i} = gams.transfer.utils.list2str(symbols{i}.size);
                descr.number_records(i) = symbols{i}.getNumberRecords();
                descr.number_values(i) = symbols{i}.getNumberValues();
                descr.sparsity(i) = symbols{i}.getSparsity();
            end

            % convert to categorical if possible
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                descr.domain_type = categorical(descr.domain_type);
                descr.domain = categorical(descr.domain);
                descr.size = categorical(descr.size);
            end

            % convert to table if possible
            if gams.transfer.Constants.SUPPORTS_TABLE
                descr = struct2table(descr);
            end
        end

    end

end
