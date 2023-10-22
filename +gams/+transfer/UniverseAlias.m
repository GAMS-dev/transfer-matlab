% GAMS UniverseAlias
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
% u = UniverseAlias(c, 'u');
%
% See also: gams.transfer.Set, gams.transfer.Container, gams.transfer.Alias

%> @ingroup symbol
%> @brief GAMS Alias to Universe
%>
%> This class represents a GAMS Alias to Universe.
%>
%> **Example:**
%> ```
%> c = Container();
%> u = UniverseAlias(c, 'u');
%> ```
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container "Container", \ref
%> gams::transfer::Alias "Alias"
%>
classdef UniverseAlias < handle

    properties (Dependent)
        %> Alias name

        % name Alias name
        name
    end

    properties (Dependent, SetAccess = private)
        %> Aliased GAMS Set

        % Aliased GAMS Set
        alias_with


        %> Aliased GAMS Set description

        % Aliased GAMS Set description
        description


        %> Indicator if aliased GAMS Set is singleton

        % Indicator if aliased GAMS Set is singleton
        is_singleton


        %> Aliased GAMS Set dimension (in [0,20])

        % Aliased GAMS Set dimension (in [0,20])
        dimension


        %> Aliased GAMS Set Shape (length == dimension)

        % Aliased GAMS Set Shape (length == dimension)
        size


        %> Aliased GAMS Set domain (length == dimension)

        % Aliased GAMS Set domain (length == dimension)
        domain


        %> Aliased GAMS Set domain names

        % Aliased GAMS Set domain names
        domain_names


        %> Expected domain labels in records

        % Expected domain labels in records
        domain_labels


        %> Specifies if domains are stored 'relaxed' or 'regular'

        % Specifies if domains are stored 'relaxed' or 'regular'
        domain_type


        %> Storage of aliased Set records

        % Storage of aliased Set records
        records


        %> Records format
        %>
        %> If records are changed, this gets reset to \ref
        %> gams::transfer::RecordsFormat::UNKNOWN "RecordsFormat.UNKNOWN". Calling
        %> \ref gams::transfer::Alias::isValid "Alias.isValid" will detect the
        %> format again.

        % Records format
        %
        % If records are changed, this gets reset to 'unknown'. Calling
        % isValid() will detect the format again.
        format
    end

    properties
        %> Flag to indicate modification
        %>
        %> If the symbol has been modified since last reset of flag (`false`),
        %> this flag will be `true`.

        % Flag to indicate modification
        %
        % If the symbol has been modified since last reset of flag (`false`),
        % this flag will be `true`.
        modified = true
    end

    properties (Hidden, SetAccess = private)
        id
        container
    end

    properties (Hidden)
        name_
    end

    methods

        %> Constructs a GAMS Alias
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should
        %>    be stored in
        %> 2. name (`string`):
        %>    name of alias
        %> 3. alias_with (`Set` or `Alias`):
        %>    GAMS \ref gams::transfer::Set "Set" to be linked to
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s = Set(c, 's');
        %> a = Alias(c, 'a', s);
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container
        %> "Container"
        function obj = UniverseAlias(container, name)
            % Constructs a GAMS Alias, see class help

            obj.id = int32(randi(100000));

            % input arguments
            if ~isa(container, 'gams.transfer.Container')
                error('Argument ''container'' must be of type ''gams.transfer.Container''.');
            end
            obj.container = container;

            if container.indexed
                error('Alias not allowed in indexed mode.');
            end

            args = gams.transfer.UniverseAlias.parseConstructArguments(name);
            obj.name_ = args.name;

            % add symbol to container
            obj.container.add(obj);
        end

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            if ~isstring(name) && ~ischar(name)
                error('Name must be of type ''char''.');
            end
            name = char(name);
            if numel(name) >= 64
                error('Symbol name too long. Name length must be smaller than 64.');
            end
            if strcmp(obj.name_, name)
                return
            end
            obj.container.renameSymbol(obj.name_, name);
            obj.modified = true;
        end

        function alias_with = get.alias_with(obj)
            alias_with = '*';
        end

        function set.modified(obj, modified)
            if ~islogical(modified)
                error('Modified must be logical.');
            end
            obj.modified = modified;
        end

        function description = get.description(obj)
            description = 'Alias to universe';
        end

        function is_singleton = get.is_singleton(obj)
            is_singleton = false;
        end

        function dimension = get.dimension(obj)
            dimension = 1;
        end

        function size_ = get.size(obj)
            size_ = nan;
        end

        function domain = get.domain(obj)
            domain = {'*'};
        end

        function domain_names = get.domain_names(obj)
            domain_names = {'*'};
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = {'uni'};
        end

        function domain_type = get.domain_type(obj)
            domain_type = 'none';
        end

        function records = get.records(obj)
            uels = obj.container.getUELs();
            records = struct();
            records.uni = (1:numel(uels))';
            if obj.container.features.categorical
                records.uni = categorical(records.uni, records.uni, uels, 'Ordinal', true);
            end
            if obj.container.features.table
                records = struct2table(records);
            end
        end

        function format_ = get.format(obj)
            if obj.container.features.table
                format_ = 'table';
            else
                format_ = 'struct';
            end
        end

    end

    methods

        %> Checks equivalence with other symbol
        %>
        %> @note A symbol is always linked to a container. This method does not
        %> check equivalence of the linked containers.
        %>
        %> **Required Arguments:**
        %> 1. symbol (`any`):
        %>    Other symbol
        function eq = equals(obj, symbol)
            % Checks equivalence with other symbol
            %
            % Note: A symbol is always linked to a container. This method does
            % not check equivalence of the linked containers.
            %
            % Required Arguments:
            % 1. symbol (any):
            %    Other symbol

            eq = false;
            if ~isa(symbol, 'gams.transfer.UniverseAlias')
                return
            end
            eq = isequaln(obj.name_, symbol.name_);
        end

        %> Copies symbol to destination container
        %>
        %> If destination container does not have a symbol equal to the
        %> aliased symbol, an error is raised.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination container
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`.
        %>    Default: `false`.
        function copy(obj, varargin)
            % Copies symbol to destination container
            %
            % If destination container does not have a symbol equal to the
            % aliased symbol, an error is raised.
            %
            % Required Arguments:
            % 1. destination (Container):
            %    Destination container
            %
            % Optional Arguments:
            % 2. overwrite (bool):
            %    Overwrites symbol with same name in destination if true.
            %    Default: false.

            % input arguments
            p = inputParser();
            is_dest = @(x) isa(x, 'gams.transfer.Container');
            addRequired(p, 'destination', is_dest);
            addOptional(p, 'overwrite', false, @islogical);
            parse(p, varargin{:});
            destination = p.Results.destination;
            overwrite = p.Results.overwrite;

            if ~overwrite && destination.hasSymbols(obj.name_)
                error('Symbol already exists in destination.');
            end
            destination.addUniverseAlias(obj.name_);
        end

        %> Checks correctness of alias
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        function valid = isValid(obj, varargin)
            % Checks correctness of alias
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)

            valid = true;
        end

        %> Returns the UELs used in all symbols
        %>
        %> @see \ref gams::transfer::Container::getUELs "Container.getUELs"
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in all symbols
            %
            % See also: gams.transfer.Container.getUELs

            uels = obj.container.getUELs(varargin{:});
        end

        %> Removes UELs from all symbols
        %>
        %> @see \ref gams::transfer::Container::removeUELs "Container.removeUELs"
        function removeUELs(obj, varargin)
            % Removes UELs from all symbols
            %
            % See also: gams.transfer.Container.removeUELs

            obj.container.removeUELs(varargin{:});
        end

        %> Renames UELs in all symbols
        %>
        %> @see \ref gams::transfer::Container::renameUELs "Container.renameUELs"
        function renameUELs(obj, uels)
            % Renames UELs in all symbols
            %
            % See also: gams.transfer.Container.renameUELs

            obj.container.renameUELs(uels);
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Container::lowerUELs "Container.lowerUELs"
        function lowerUELs(obj)
            % Converts UELs to lower case
            %
            % See also: gams.transfer.Container.lowerUELs

            obj.container.lowerUELs();
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Container::upperUELs "Container.upperUELs"
        function upperUELs(obj, dim)
            % Converts UELs to upper case
            %
            % See also: gams.transfer.Container.upperUELs

            obj.container.upperUELs();
        end

    end

    methods (Hidden)

        function unsetContainer(obj)
            obj.container = gams.transfer.Container('indexed', obj.container.indexed, ...
                'gams_dir', obj.container.gams_dir, 'features', obj.container.features);
            obj.modified = true;
        end

        function bool = isValidAsDomain(obj)
            % Checks if alias could be used as a domain of a different symbol
            %
            % b = isValidAsDomain() returns true if this alias can be used as
            % domain and false otherwise.
            %

            bool = true;
        end

    end

    methods (Hidden, Static)

        function args = parseConstructArguments(name)
            args = struct;

            if ~(isstring(name) && numel(name) == 1) && ~ischar(name)
                error('Argument ''name'' must be of type ''char''.');
            end
            args.name = char(name);
            args.isset_name = true;

        end

    end

end
