% GAMS Set Alias
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
% GAMS Set Alias
%
% This class represents a GAMS Alias, which is a link to another GAMS Set.
%
% Required Arguments:
% 1. container (Container):
%    GAMS Transfer container object this symbol should be stored in
% 2. name (string):
%    name of alias
% 3. alias_with (Set or Alias):
%    GAMS Set to be linked to
%
% Example:
% c = Container();
% s = symbol.Set.construct(c, 's');
% a = alias.Set.construct(c, 'a', s);
%
% See also: gams.transfer.Alias, gams.transfer.symbol.Set, gams.transfer.Container

%> @brief GAMS Alias
%>
%> This class represents a GAMS Alias, which is a link to another GAMS \ref
%> gams::transfer::symbol::Set "Set".
%>
%> **Example:**
%> ```
%> c = Container();
%> s = symbol.Set.construct(c, 's');
%> a = alias.Set.construct(c, 'a', s);
%> ```
%>
%> @see \ref gams::transfer::Alias "Alias", \ref gams::transfer::symbol::Set "Set", \ref
%> gams::transfer::Container "Container"
%>
classdef Set < gams.transfer.alias.Abstract

    %#ok<*INUSD,*STOUT,*PROPLC>

    properties (Hidden, SetAccess = protected)
        alias_with_
    end

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

        function alias_with = get.alias_with(obj)
            alias_with = obj.alias_with_;
        end

        function set.alias_with(obj, alias_with)
            gams.transfer.utils.Validator('alias_with', 1, alias_with)...
                .types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Set'});
            while isa(alias_with, 'gams.transfer.alias.Set')
                alias_with = alias_with.alias_with;
            end
            obj.alias_with_ = alias_with;
            obj.last_update_ = now();
        end

        function description = get.description(obj)
            description = obj.alias_with_.description;
        end

        function set.description(obj, description)
            obj.alias_with_.description = description;
        end

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.alias_with_.is_singleton;
        end

        function set.is_singleton(obj, is_singleton)
            obj.alias_with_.is_singleton = is_singleton;
        end

        function dimension = get.dimension(obj)
            dimension = obj.alias_with_.dimension;
        end

        function set.dimension(obj, dimension)
            obj.alias_with_.dimension = dimension;
        end

        function size = get.size(obj)
            size = obj.alias_with_.size;
        end

        function set.size(obj, size_)
            obj.alias_with_.size = size_;
        end

        function domain = get.domain(obj)
            domain = obj.alias_with_.domain;
        end

        function set.domain(obj, domain)
            obj.alias_with_.domain = domain;
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.alias_with_.domain_names;
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.alias_with_.domain_labels;
        end

        function domain_type = get.domain_type(obj)
            domain_type = obj.alias_with_.domain_type;
        end

        function records = get.records(obj)
            records = obj.alias_with_.records;
        end

        function set.records(obj, records)
            obj.alias_with_.records = records;
        end

        function last_update = get.last_update(obj)
            last_update = max(obj.last_update_, obj.alias_with.last_update);
        end

        function format_ = get.format(obj)
            format_ = obj.alias_with_.format;
        end

    end

    methods (Hidden, Access = {?gams.transfer.alias.Abstract, ?gams.transfer.Container})

        function obj = Set(container, name, alias_with)
            obj.container_ = container;
            obj.name_ = name;
            obj.alias_with_ = alias_with;
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
        %> s = symbol.Set.construct(c, 's');
        %> a = alias.Set.construct(c, 'a', s);
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Container "Container"
        function obj = construct(container, name, alias_with)
            % Constructs a GAMS Alias, see class help

            gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container', true);
            name = gams.transfer.utils.Validator('name', 1, name).symbolName().value;
            gams.transfer.utils.Validator('alias_with', 1, alias_with)...
                .types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Set'});
            while isa(alias_with, 'gams.transfer.alias.Set')
                alias_with = alias_with.alias_with;
            end
            obj = gams.transfer.alias.Set(container, name, alias_with);
        end

    end

    methods

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

            eq = equals@gams.transfer.alias.Abstract(obj, symbol) && ...
                obj.alias_with_.equals(symbol.alias_with);
        end

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

            % get aliased symbol in destination
            if ~destination.hasSymbols(obj.alias_with.name)
                error('Aliased symbol not available in destination');
            end
            alias_with = destination.getSymbols(obj.alias_with.name);
            if ~obj.alias_with.equals(alias_with)
                error('Aliased symbol differs in destination');
            end

            % create new (empty) symbol
            if destination.hasSymbols(obj.name_)
                if ~overwrite
                    error('Symbol already exists in destination.');
                end
                symbol = destination.getSymbols(obj.name_);
                if ~isa(symbol, class(obj))
                    destination.removeSymbols(obj.name_);
                    symbol = destination.addAlias(obj.name_, alias_with);
                else
                    symbol.alias_with = alias_with;
                end
            else
                symbol = destination.addAlias(obj.name_, alias_with);
            end
        end

    end

    methods (Hidden)

        function copyFrom(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).type(class(obj));
            obj.alias_with_ = symbol.alias_with;
            obj.last_update_ = now();
        end

    end

    methods

        %> Sets symbol records in supported format
        %>
        %> @see \ref gams::transfer::Symbol::setRecords "Symbol.setRecords"
        function setRecords(obj, varargin)
            % Sets symbol records in supported format
            %
            % See also: gams.transfer.Symbol.setRecords

            obj.alias_with_.setRecords(varargin{:});
        end

        %> Transforms symbol records into given format
        %>
        %> @see \ref gams::transfer::Symbol::transformRecords "Symbol.transformRecords"
        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: gams.transfer.Symbol.transformRecords

            obj.alias_with_.transformRecords(target_format);
        end

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

            if ~isa(obj.container_, 'gams.transfer.Container') || ...
                ~obj.container_.hasSymbols(obj.name_) || obj.container_.getSymbols(obj.name_) ~= obj
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

            if ~obj.alias_with_.isValid()
                msg = 'Linked symbol is invalid.';
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

        %> Get domain violations
        %>
        %> @see \ref gams::transfer::Symbol::getDomainViolations "Symbol.getDomainViolations"
        function dom_violations = getDomainViolations(obj, varargin)
            % Get domain violations
            %
            % See also: gams.transfer.Symbol.getDomainViolations

            dom_violations = obj.alias_with_.getDomainViolations(varargin{:});
        end

        %> Extends domain sets in order to resolve domain violations
        %>
        %> @see \ref gams::transfer::Symbol::resolveDomainViolations
        %> "Symbol.resolveDomainViolations"
        function resolveDomainViolations(obj, varargin)
            % Extends domain sets in order to resolve domain violations
            %
            % See also: gams.transfer.Symbol.resolveDomainViolations

            obj.alias_with_.resolveDomainViolations(varargin{:});
        end

        %> Returns the sparsity of symbol records
        %>
        %> @see \ref gams::transfer::Symbol::getSparsity "Symbol.getSparsity"
        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % See also: gams.transfer.Symbol.getSparsity

            sparsity = obj.alias_with_.getSparsity();
        end

        %> Returns the largest value in records
        %>
        %> @see \ref gams::transfer::Symbol::getMaxValue "Symbol.getMaxValue"
        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % See also: gams.transfer.Symbol.getMaxValue

            [value, where] = obj.alias_with_.getMaxValue(varargin{:});
        end

        %> Returns the smallest value in records
        %>
        %> @see \ref gams::transfer::Symbol::getMinValue "Symbol.getMinValue"
        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % See also: gams.transfer.Symbol.getMinValue

            [value, where] = obj.alias_with_.getMinValue(varargin{:});
        end

        %> Returns the mean value over all values in records
        %>
        %> @see \ref gams::transfer::Symbol::getMeanValue "Symbol.getMeanValue"
        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % See also: gams.transfer.Symbol.getMeanValue

            value = obj.alias_with_.getMeanValue(varargin{:});
        end

        %> Returns the largest absolute value in records
        %>
        %> @see \ref gams::transfer::Symbol::getMaxAbsValue "Symbol.getMaxAbsValue"
        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % See also: gams.transfer.Symbol.getMaxAbsValue

            [value, where] = obj.alias_with_.getMaxAbsValue(varargin{:});
        end

        %> Returns the number of GAMS NA values in records
        %>
        %> @see \ref gams::transfer::Symbol::countNA "Symbol.countNA"
        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % See also: gams.transfer.Symbol.countNA

            n = obj.alias_with_.countNA(varargin{:});
        end

        %> Returns the number of GAMS UNDEF values in records
        %>
        %> @see \ref gams::transfer::Symbol::countUndef "Symbol.countUndef"
        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % See also: gams.transfer.Symbol.countUndef

            n = obj.alias_with_.countUndef(varargin{:});
        end

        %> Returns the number of GAMS EPS values in records
        %>
        %> @see \ref gams::transfer::Symbol::countEps "Symbol.countEps"
        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % See also: gams.transfer.Symbol.countEps

            n = obj.alias_with_.countEps(varargin{:});
        end

        %> Returns the number of GAMS PINF (positive infinity) values in records
        %>
        %> @see \ref gams::transfer::Symbol::countPosInf "Symbol.countPosInf"
        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in records
            %
            % See also: gams.transfer.Symbol.countPosInf

            n = obj.alias_with_.countPosInf(varargin{:});
        end

        %> Returns the number of GAMS MINF (negative infinity) values in records
        %>
        %> @see \ref gams::transfer::Symbol::countNegInf "Symbol.countNegInf"
        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in records
            %
            % See also: gams.transfer.Symbol.countNegInf

            n = obj.alias_with_.countNegInf(varargin{:});
        end

        %> Returns the number of GDX records (not available for matrix formats)
        %>
        %> @see \ref gams::transfer::Symbol::getNumberRecords "Symbol.getNumberRecords"
        function nrecs = getNumberRecords(obj)
            % Returns the number of GDX records (not available for matrix formats)
            %
            % See also: gams.transfer.Symbol.getNumberRecords

            nrecs = obj.alias_with_.getNumberRecords();
        end

        %> Returns the number of values stored for this symbol.
        %>
        %> @see \ref gams::transfer::Symbol::getNumberValues "Symbol.getNumberValues"
        function nvals = getNumberValues(obj, varargin)
            % Returns the number of values stored for this symbol.
            %
            % See also: gams.transfer.Symbol.getNumberValues

            nvals = obj.alias_with_.getNumberValues(varargin{:});
        end

        %> Returns the UELs used in this symbol
        %>
        %> @see \ref gams::transfer::Symbol::getUELs "Symbol.getUELs"
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in this symbol
            %
            % See also: gams.transfer.Symbol.getUELs

            uels = obj.alias_with_.getUELs(varargin{:});
        end

        %> Sets the UELs with updating UEL codes in records
        %>
        %> @see \ref gams::transfer::Symbol::setUELs "Symbol.setUELs"
        function setUELs(obj, varargin)
            % Sets the UELs with updating UEL codes in records
            %
            % See also: gams.transfer.Symbol.setUELs

            obj.alias_with_.setUELs(varargin{:});
        end

        %> Adds UELs to the symbol
        %>
        %> @see \ref gams::transfer::Symbol::addUELs "Symbol.addUELs"
        function addUELs(obj, varargin)
            % Adds UELs to the symbol
            %
            % See also: gams.transfer.Symbol.addUELs

            obj.alias_with_.addUELs(varargin{:});
        end

        %> Removes UELs from the symbol
        %>
        %> @see \ref gams::transfer::Symbol::removeUELs "Symbol.removeUELs"
        function removeUELs(obj, varargin)
            % Removes UELs from the symbol
            %
            % See also: gams.transfer.Symbol.removeUELs

            obj.alias_with_.removeUELs(varargin{:});
        end

        %> Renames UELs in the symbol
        %>
        %> @see \ref gams::transfer::Symbol::renameUELs "Symbol.renameUELs"
        function renameUELs(obj, varargin)
            % Renames UELs in the symbol
            %
            % See also: gams.transfer.Symbol.renameUELs

            obj.alias_with_.renameUELs(varargin{:});
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Symbol::lowerUELs "Symbol.lowerUELs"
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % See also: gams.transfer.Symbol.lowerUELs

            obj.alias_with_.lowerUELs(varargin{:});
        end

        %> Converts UELs to lower case
        %>
        %> @see \ref gams::transfer::Symbol::upperUELs "Symbol.upperUELs"
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % See also: gams.transfer.Symbol.upperUELs

            obj.alias_with_.upperUELs(varargin{:});
        end

    end

end
