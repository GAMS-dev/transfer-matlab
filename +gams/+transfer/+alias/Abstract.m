% Abstract Alias
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
% Abstract Alias
%
% Use subclasses to create a GAMS Alias, see subclass help.
%
% See also: gams.transfer.alias.Set, gams.transfer.alias.Universe
%

%> @brief Abstract Alias
%>
%> Use subclasses to create a GAMS Alias, see subclass help.
%>
%> @see \ref gams::transfer::alias::Set "alias.Set", \ref gams::transfer::alias::Universe
%> "alias.Universe"
classdef (Abstract) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        container_
        name_ = ''
        last_update_ = now()
        last_update_reset_ = []
    end

    properties (Dependent)

        %> Container the symbol is stored in

        % container Container the symbol is stored in
        container


        %> Alias name

        % name Alias name
        name

    end

    properties (Abstract, Dependent)

        %> (Abstract) Aliased symbol

        % alias_with (Abstract) Aliased symbol
        alias_with


        %> (Abstract) Aliased GAMS Set description

        % description (Abstract) Aliased GAMS Set description
        description


        %> (Abstract) Indicator if aliased GAMS Set is singleton

        % is_singleton (Abstract) Indicator if aliased GAMS Set is singleton
        is_singleton


        %> (Abstract) Aliased GAMS Set dimension (in [0,20])

        % dimension (Abstract) Aliased GAMS Set dimension (in [0,20])
        dimension


        %> (Abstract) Aliased GAMS Set Shape (length == dimension)

        % size (Abstract) Aliased GAMS Set Shape (length == dimension)
        size


        %> (Abstract) Aliased GAMS Set domain (length == dimension)

        % domain (Abstract) Aliased GAMS Set domain (length == dimension)
        domain


        %> (Abstract) Expected domain labels in records

        % domain_labels (Abstract) Expected domain labels in records
        domain_labels

    end

    properties (Abstract, Dependent, SetAccess = private)

        %> (Abstract) Aliased GAMS Set domain names

        % domain_names (Abstract) Aliased GAMS Set domain names
        domain_names


        %> (Abstract) Specifies if domains are stored 'relaxed' or 'regular'

        % domain_type (Abstract) Specifies if domains are stored 'relaxed' or 'regular'
        domain_type

    end

    properties (Abstract, Dependent)

        %> (Abstract) Enables domain forwarding in aliased symbol

        % domain_forwarding (Abstract) Enables domain forwarding in aliased symbol
        domain_forwarding


        %> (Abstract) Storage of aliased Set records

        % records (Abstract) Storage of aliased Set records
        records

    end

    properties (Abstract, Dependent, SetAccess = private)

        %> (Abstract) Records format of aliased Set records

        % format (Abstract) Records format of aliased Set records
        format

    end

    properties (Abstract, Hidden, SetAccess = private)
        last_update
    end

    properties (Dependent)

        %> Flag to indicate modification
        %>
        %> If the symbol has been modified since last reset of flag (`false`),
        %> this flag will be `true`.

        % Flag to indicate modification
        %
        % If the symbol has been modified since last reset of flag (`false`),
        % this flag will be `true`.
        modified

    end

    methods

        function container = get.container(obj)
            container = obj.container_;
        end

        function set.container(obj, container)
            gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container', true);
            obj.container_ = container;
            if isa(obj.alias_with, 'gams.transfer.symbol.Abstract')
                obj.alias_with.container = container;
            end
            obj.last_update_ = now();
        end

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            name = gams.transfer.utils.Validator('name', 1, name).symbolName().value;
            obj.container.renameSymbol(obj.name, name);
            obj.last_update_ = now();
        end

        function modified = get.modified(obj)
            modified = isempty(obj.last_update_reset_) || obj.last_update_reset_ <= obj.last_update;
        end

        function set.modified(obj, modified)
            gams.transfer.utils.Validator('modified', 1, modified).type('logical').scalar();
            if modified
                obj.last_update_reset_ = [];
            else
                last_update = obj.last_update;
                obj.last_update_reset_ = now();
                while (obj.last_update_reset_ == last_update)
                    obj.last_update_reset_ = now();
                end
            end
        end

    end

    methods (Hidden)

        function copyFrom(obj, symbol)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

    end

    methods

        %> (Abstract) Copies symbol to destination container
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
            % (Abstract) Copies symbol to destination container
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

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> Checks equivalence with other symbol
        %>
        %> @note A symbol is always linked to a container. This method does not check equivalence of
        %> the linked containers.
        %>
        %> **Required Arguments:**
        %> 1. symbol (`any`):
        %>    Other symbol
        function eq = equals(obj, symbol)
            % Checks equivalence with other symbol
            %
            % Note: A symbol is always linked to a container. This method does not check equivalence
            % of the linked containers.
            %
            % Required Arguments:
            % 1. symbol (any):
            %    Other symbol

            eq = isequal(class(obj), class(symbol)) && ...
                isequal(obj.name, symbol.name);
        end

        %> (Abstract) Checks correctness of alias
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        function flag = isValid(obj, varargin)
            % (Abstract) Checks correctness of alias
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> (Abstract) Returns the UELs used in this symbol
        function uels = getUELs(obj, varargin)
            % (Abstract) Returns the UELs used in this symbol

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> (Abstract) Removes UELs from the symbol
        function removeUELs(obj, varargin)
            % (Abstract) Removes UELs from the symbol

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> (Abstract) Renames UELs in the symbol
        function renameUELs(obj, uels)
            % (Abstract) Renames UELs in the symbol

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> (Abstract) Converts UELs to lower case
        function lowerUELs(obj)
            % (Abstract) Converts UELs to lower case

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        %> (Abstract) Converts UELs to lower case
        function upperUELs(obj)
            % (Abstract) Converts UELs to upper case

            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

    end

    methods (Static)

        %> Returns an overview over all aliases given
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Required Arguments:**
        %> 1. symbols (list):
        %>    List of aliases to include.
        %>
        %> The overview is in form of a table listing for each symbol its main characteristics and
        %> some statistics.
        function descr = describe(symbols)
            % Returns an overview over all aliases given
            %
            % Optional Arguments:
            % 1. symbols (list):
            %    List of aliases to include.
            %
            % The overview is in form of a table listing for each symbol its main characteristics
            % and some statistics.

            gams.transfer.utils.Validator('symbols', 1, symbols).cellof('gams.transfer.alias.Abstract');

            descr = struct();
            descr.name = cell(numel(symbols), 1);
            descr.is_singleton = true(numel(symbols), 1);
            descr.alias_with = cell(numel(symbols), 1);
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
                descr.alias_with{i} = symbols{i}.alias_with.name;
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
