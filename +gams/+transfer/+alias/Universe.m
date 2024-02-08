% GAMS Universe Alias
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
% GAMS Alias to Universe
%
% This class represents a GAMS Alias to Universe.
%
% Required Arguments:
% 1. container (Container):
%    GAMS Transfer container object this symbol should be stored in
% 2. name (string):
%    name of alias
%
% Example:
% c = Container();
% u = alias.Universe.construct(c, 'u');
%
% See also: gams.transfer.symbol.Set, gams.transfer.Container, gams.transfer.Alias

%> @brief GAMS Alias to Universe
%>
%> This class represents a GAMS Alias to Universe.
%>
%> **Example:**
%> ```
%> c = Container();
%> u = alias.Universe.construct(c, 'u');
%> ```
%>
%> @see \ref gams::transfer::symbol::Set "Set", \ref gams::transfer::Container "Container", \ref
%> gams::transfer::alias::Set "Alias"
%>
classdef Universe < gams.transfer.alias.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Dependent)

        %> Aliased symbol

        % alias_with Aliased symbol
        alias_with


        %> Aliased GAMS Set description

        % description Aliased GAMS Set description
        description


        %> Indicator if aliased GAMS Set is singleton

        % is_singleton Indicator if aliased GAMS Set is singleton
        is_singleton


        %> Aliased GAMS Set dimension (in [0,20])

        % dimension Aliased GAMS Set dimension (in [0,20])
        dimension


        %> Aliased GAMS Set Shape (length == dimension)

        % size Aliased GAMS Set Shape (length == dimension)
        size


        %> Aliased GAMS Set domain (length == dimension)

        % domain Aliased GAMS Set domain (length == dimension)
        domain


        %> Expected domain labels in records

        % domain_labels Expected domain labels in records
        domain_labels

    end

    properties (Dependent, SetAccess = private)

        %> Aliased GAMS Set domain names

        % domain_names Aliased GAMS Set domain names
        domain_names


        %> Specifies if domains are stored 'relaxed' or 'regular'

        % domain_type Specifies if domains are stored 'relaxed' or 'regular'
        domain_type

    end

    properties (Dependent)

        %> Enables domain forwarding in aliased symbol

        % domain_forwarding Enables domain forwarding in aliased symbol
        domain_forwarding


        %> Storage of aliased Set records

        % records Storage of aliased Set records
        records

    end

    properties (Dependent, Hidden, SetAccess = private)
        last_update
    end

    properties (Dependent, SetAccess = private)

        %> Records format of aliased Set records

        % format Records format of aliased Set records
        format

    end

    methods

        function alias_with = get.alias_with(obj) %#ok<MANU>
            alias_with = gams.transfer.Constants.UNIVERSE_NAME;
        end

        function description = get.description(obj) %#ok<MANU>
            description = 'Alias to universe';
        end

        function is_singleton = get.is_singleton(obj) %#ok<MANU>
            is_singleton = false;
        end

        function dimension = get.dimension(obj) %#ok<MANU>
            dimension = 1;
        end

        function size_ = get.size(obj) %#ok<MANU>
            size_ = nan;
        end

        function domain = get.domain(obj) %#ok<MANU>
            domain = {gams.transfer.Constants.UNIVERSE_NAME};
        end

        function domain_names = get.domain_names(obj) %#ok<MANU>
            domain_names = {gams.transfer.Constants.UNIVERSE_NAME};
        end

        function domain_labels = get.domain_labels(obj) %#ok<MANU>
            domain_labels = {gams.transfer.Constants.UNIVERSE_LABEL};
        end

        function domain_type = get.domain_type(obj) %#ok<MANU>
            domain_type = 'none';
        end

        function records = get.records(obj)
            uels = obj.container_.getUELs();
            label = gams.transfer.Constants.UNIVERSE_LABEL;
            records = struct();
            records.(label) = (1:numel(uels))';
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                records.(label) = categorical(records.(label), records.(label), uels, 'Ordinal', true);
            end
            if gams.transfer.Constants.SUPPORTS_TABLE
                records = struct2table(records);
            end
        end

        function last_update = get.last_update(obj)
            last_update = obj.last_update_;
        end

        function format_ = get.format(obj) %#ok<MANU>
            if gams.transfer.Constants.SUPPORTS_TABLE
                format_ = 'table';
            else
                format_ = 'struct';
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.alias.Abstract, ?gams.transfer.Container})

        function obj = Universe(container, name)
            obj.container_ = container;
            obj.name_ = name;
        end

    end

    methods (Static)

        %> Constructs a GAMS Alias
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should be stored in
        %> 2. name (`string`):
        %>    name of alias
        %> 3. alias_with (`Set` or `Alias`):
        %>    GAMS \ref gams::transfer::Set "Set" to be linked to
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> u = alias.Universe.construct(c, 'u');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container "Container"
        function obj = construct(container, name)
            % Constructs a GAMS Alias, see class help

            gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container', true);
            name = gams.transfer.utils.Validator('name', 1, name).symbolName().value;
            obj = gams.transfer.alias.Universe(container, name);
        end

    end

    methods

        %> Copies symbol to destination container
        %>
        %> If destination container does not have a symbol equal to the aliased symbol, an error is
        %> raised.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination container
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`. Default: `false`.
        function symbol = copy(obj, varargin)
            % Copies symbol to destination container
            %
            % If destination container does not have a symbol equal to the aliased symbol, an error
            % is raised.
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
                while index < nargin
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
                    symbol = destination.addUniverseAlias(obj.name_);
                end
            else
                symbol = destination.addUniverseAlias(obj.name_);
            end
        end

    end

    methods (Hidden)

        function copyFrom(obj, symbol)
        end

    end

    methods

        %> Checks correctness of alias
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        function flag = isValid(obj, varargin)
            % Checks correctness of alias
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)

            verbose = 0;
            if nargin > 1
                verbose = max(0, min(2, varargin{1}));
            end

            if ~obj.container_.hasSymbols(obj.name_) || obj.container_.getSymbols(obj.name_) ~= obj
                msg = 'Alias is not contained in its linked container.';
                switch verbose
                case 1
                    warning(msg);
                case 2
                    error(msg);
                end
                flag = false;
                return
            end

            flag = true;

        end

        %> Returns the UELs used in all symbols
        %>
        %> @see \ref gams::transfer::Container::getUELs "Container.getUELs"
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in all symbols
            %
            % See also: gams.transfer.Container.getUELs

            uels = obj.container_.getUELs(varargin{:});
        end

        %> Removes UELs from all symbols
        %>
        %> @see \ref gams::transfer::Container::removeUELs "Container.removeUELs"
        function removeUELs(obj, varargin)
            % Removes UELs from all symbols
            %
            % See also: gams.transfer.Container.removeUELs

            obj.container_.removeUELs(varargin{:});
        end

        %> Renames UELs in all symbols
        %>
        %> @see \ref gams::transfer::Container::renameUELs "Container.renameUELs"
        function renameUELs(obj, varargin)
            % Renames UELs in all symbols
            %
            % See also: gams.transfer.Container.renameUELs

            obj.container_.renameUELs(varargin{:});
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Container::lowerUELs "Container.lowerUELs"
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % See also: gams.transfer.Container.lowerUELs

            obj.container_.lowerUELs(varargin{:});
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Container::upperUELs "Container.upperUELs"
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % See also: gams.transfer.Container.upperUELs

            obj.container_.upperUELs(varargin{:});
        end

    end

end
