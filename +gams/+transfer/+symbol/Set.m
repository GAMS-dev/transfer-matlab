% GAMS Set
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
% s1 = symbol.Set.construct(c, 's1');
% s2 = symbol.Set.construct(c, 's2', {s1, '*', '*'});
% s3 = symbol.Set.construct(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%
% See also: gams.transfer.Set, gams.transfer.Container.addSet

%> @brief GAMS Set
%>
%> Represents a GAMS Set.
%>
%> **Example:**
%> ```
%> c = Container();
%> s1 = symbol.Set.construct(c, 's1');
%> s2 = symbol.Set.construct(c, 's2', {s1, '*', '*'});
%> s3 = symbol.Set.construct(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%> ```
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container::addSet
%> "Container.addSet"
classdef Set < gams.transfer.symbol.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        is_valid_domain_status_ = gams.transfer.utils.Status();
        is_valid_domain_time_ = 0
    end

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

    methods (Hidden, Access = {?gams.transfer.symbol.Abstract, ?gams.transfer.Container})

        function obj = Set(container, name, is_singleton, init_records)
            obj.container_ = container;
            obj.name_ = name;
            obj.def_ = gams.transfer.symbol.definition.Set(is_singleton);
            if init_records
                obj.data_ = gams.transfer.symbol.data.Struct();
            end
        end

    end

    methods (Static)

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
        %> s1 = symbol.Set.construct(c, 's1');
        %> s2 = symbol.Set.construct(c, 's2', {s1, '*', '*'});
        %> s3 = symbol.Set.construct(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container::addSet
        %> "Container.addSet"
        function obj = construct(varargin)
            % Constructs a GAMS Set, see class help

            % parse input arguments
            has_description = false;
            is_singleton = false;
            has_records = false;
            has_size = false;
            has_domains = false;
            has_domain_forwarding = false;
            try
                gams.transfer.utils.Validator.minargin(nargin, 2);
                container = gams.transfer.utils.Validator('container', 1, varargin{1}) ...
                    .type('gams.transfer.Container', true).value;
                name = gams.transfer.utils.Validator('name', 2, varargin{2}).symbolName().value;
                index = 3;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'description')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(nargin, index);
                        description = gams.transfer.utils.Validator('description', index, varargin{index}) ...
                            .symbolDescription().value;
                        has_description = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'domain_forwarding')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(nargin, index);
                        domain_forwarding = gams.transfer.utils.Validator('domain_forwarding', ...
                            index, varargin{index}).type('logical').scalar().value;
                        has_domain_forwarding = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'is_singleton')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(nargin, index);
                        is_singleton = gams.transfer.utils.Validator('is_singleton', ...
                            index, varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'records')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(nargin, index);
                        records = varargin{index};
                        has_records = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 3
                        if isempty(varargin{index})
                            domains = {};
                            has_domains = true;
                        elseif isnumeric(varargin{index})
                            size = gams.transfer.utils.Validator('domains', index, varargin{index}).vector().integer().value;
                            has_size = true;
                        else
                            domains = varargin{index};
                            has_domains = true;
                        end
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            obj = gams.transfer.symbol.Set(container, name, is_singleton, ~has_records);
            if has_description
                obj.description_ = description;
            end
            if has_domains
                obj.def_.domains = domains;
            end
            if has_size
                obj.size = size;
            end
            if has_domain_forwarding
                for i = 1:numel(obj.def_.domains)
                    obj.def_.domains{i}.forwarding = domain_forwarding;
                end
            end
            if has_records
                obj.setRecords(records);
            end
        end

    end

    methods

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
            overwrite = false;
            try
                gams.transfer.utils.Validator.minargin(numel(varargin), 1);
                destination = gams.transfer.utils.Validator('destination', 1, varargin{1})...
                    .type('gams.transfer.Container').value;
                index = 2;
                is_pararg = false;
                while index <= numel(varargin)
                    if ~is_pararg && index == 2
                        overwrite = gams.transfer.utils.Validator('overwrite', index, varargin{index}) ...
                            .type('logical').scalar().value;
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
            symbol.def.switchContainer(destination);
        end

    end

    methods (Hidden)

        function status = isValidDomain(obj)

            if obj.last_update < obj.is_valid_time_ && obj.is_valid_domain_status_.flag ~= gams.transfer.utils.Status.UNKNOWN
                status = obj.is_valid_domain_status_;
                return
            end

            if obj.dimension ~= 1
                status = gams.transfer.utils.Status(sprintf('Domain set ''%s'' dimension must be 1.', obj.name_));
            elseif ~obj.isValid()
                status = gams.transfer.utils.Status(sprintf('Domain set ''%s'' is invalid.', obj.name_));
            elseif isfield(obj.records, obj.def_.domains{1}.label) && ...
                numel(unique(obj.records.(obj.def_.domains{1}.label))) ~= numel(obj.records.(obj.def_.domains{1}.label))
                status = gams.transfer.utils.Status(sprintf('Domain set ''%s'' must not have duplicate records.', obj.name_));
            else
                status = gams.transfer.utils.Status.ok();
            end
            obj.is_valid_domain_status_ = status;
            obj.is_valid_domain_time_ = now();
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

            gams.transfer.utils.Validator('symbols', 1, symbols).cellof('gams.transfer.symbol.Set');

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
