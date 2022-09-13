% GAMS Alias
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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
% GAMS Alias
%
% This class represents a GAMS Alias, which is a link to another GAMS Set.
%
% Required Arguments:
% 1. container (Container):
%    GAMSTransfer container object this symbol should be stored in
% 2. name (string):
%    name of alias
% 3. alias_with (Set or Alias):
%    GAMS Set to be linked to
%
% Example:
% c = Container();
% s = Set(c, 's');
% a = Alias(c, 'a', s);
%
% See also: GAMSTransfer.Set, GAMSTransfer.Container

%> @ingroup symbol
%> @brief GAMS Alias
%>
%> This class represents a GAMS Alias, which is a link to another GAMS \ref
%> GAMSTransfer::Set "Set".
%>
%> **Example:**
%> ```
%> c = Container();
%> s = Set(c, 's');
%> a = Alias(c, 'a', s);
%> ```
%>
%> @see \ref GAMSTransfer::Set "Set", \ref GAMSTransfer::Container "Container"
%>
classdef Alias < handle

    properties (Dependent)
        %> Alias name

        % name Alias name
        name
    end

    properties
        %> Aliased GAMS Set

        % Aliased GAMS Set
        alias_with


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

    properties (Dependent)
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
        %> GAMSTransfer::RecordsFormat::UNKNOWN "RecordsFormat.UNKNOWN". Calling
        %> \ref GAMSTransfer::Alias::isValid "Alias.isValid" will detect the
        %> format again.

        % Records format
        %
        % If records are changed, this gets reset to 'unknown'. Calling
        % isValid() will detect the format again.
        format
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
        %> See \ref GAMSTRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref GAMSTransfer::Container "Container" object this symbol should
        %>    be stored in
        %> 2. name (`string`):
        %>    name of alias
        %> 3. alias_with (`Set` or `Alias`):
        %>    GAMS \ref GAMSTransfer::Set "Set" to be linked to
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s = Set(c, 's');
        %> a = Alias(c, 'a', s);
        %> ```
        %>
        %> @see \ref GAMSTransfer::Set "Set", \ref GAMSTransfer::Container
        %> "Container"
        function obj = Alias(container, name, alias_with)
            % Constructs a GAMS Alias, see class help

            obj.id = int32(randi(100000));

            % input arguments
            if ~isa(container, 'GAMSTransfer.Container')
                error('Argument ''container'' must be of type ''GAMSTransfer.Container''.');
            end
            if ~(isstring(name) && numel(name) == 1) && ~ischar(name)
                error('Argument ''name'' must be of type ''char''.');
            end
            if ~isa(alias_with, 'GAMSTransfer.Set') && ~isa(alias_with, 'GAMSTransfer.Alias')
                error('Argument ''alias_with'' must be of type ''GAMSTransfer.Set'' or ''GAMSTransfer.Alias''.');
            end
            obj.container = container;
            obj.name_ = char(name);
            while isa(alias_with, 'GAMSTransfer.Alias')
                alias_with = alias_with.alias_with;
            end
            obj.alias_with = alias_with;

            if container.indexed
                error('Alias not allowed in indexed mode.');
            end

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

        function set.alias_with(obj, alias)
            if ~isa(alias, 'GAMSTransfer.Set')
                error('Can only alias to sets.');
            end
            if obj.container.id ~= alias.container.id
                error('Alias and aliased set must be located in same container');
            end
            obj.alias_with = alias;
            obj.modified = true;
        end

        function set.modified(obj, modified)
            if ~islogical(modified)
                error('Modified must be logical.');
            end
            obj.modified = modified;
        end

        function description = get.description(obj)
            description = obj.alias_with.description;
        end

        function set.description(obj, description)
            obj.alias_with.description = description;
        end

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.alias_with.is_singleton;
        end

        function set.is_singleton(obj, is_singleton)
            obj.alias_with.is_singleton = is_singleton;
        end

        function dimension = get.dimension(obj)
            dimension = obj.alias_with.dimension;
        end

        function set.dimension(obj, dimension)
            obj.alias_with.dimension = dimension;
        end

        function size_ = get.size(obj)
            size_ = obj.alias_with.size;
        end

        function set.size(obj, size_)
            obj.alias_with.size = size_;
        end

        function domain = get.domain(obj)
            domain = obj.alias_with.domain;
        end

        function set.domain(obj, domain)
            obj.alias_with.domain = domain;
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.alias_with.domain_names;
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.alias_with.domain_labels;
        end

        function domain_type = get.domain_type(obj)
            domain_type = obj.alias_with.domain_type;
        end

        function records = get.records(obj)
            records = obj.alias_with.records;
        end

        function set.records(obj, records)
            obj.alias_with.records = records;
        end

        function format_ = get.format(obj)
            format_ = obj.alias_with.format;
        end

    end

    methods

        %> Sets symbol records in supported format
        %>
        %> @see \ref GAMSTransfer::Symbol::setRecords "Symbol.setRecords"
        function setRecords(obj, varargin)
            % Sets symbol records in supported format
            %
            % See also: GAMSTransfer.Symbol.setRecords

            obj.alias_with.setRecords(varargin{:});
        end

        %> Transforms symbol records into given format
        %>
        %> @see \ref GAMSTransfer::Symbol::transformRecords
        %> "Symbol.transformRecords"
        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: GAMSTransfer.Symbol.transformRecords

            obj.alias_with.transformRecords(target_format);
        end

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
            if ~isa(symbol, 'GAMSTransfer.Alias')
                return
            end
            eq = isequaln(obj.name_, symbol.name_) && ...
                obj.alias_with.equals(symbol.alias_with);
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
            is_dest = @(x) isa(x, 'GAMSTransfer.Container');
            addRequired(p, 'destination', is_dest);
            addOptional(p, 'overwrite', '', @islogical);
            parse(p, varargin{:});
            destination = p.Results.destination;
            overwrite = p.Results.overwrite;

            % get aliased symbol in destination
            if ~isfield(destination.data, obj.alias_with.name_) || ...
                ~obj.alias_with.equals(destination.data.(obj.alias_with.name_))
                error('Aliased symbol not available or differs in destination.');
            end
            alias_with = destination.data.(obj.alias_with.name_);

            % create new (empty) symbol
            if isfield(destination.data, obj.name_)
                if ~overwrite
                    error('Symbol already exists in destination.');
                end
                newsym = destination.data.(obj.name_);
                newsym.alias_with = alias_with;
            else
                newsym = GAMSTransfer.Alias(destination, obj.name_, alias_with);
            end
            newsym.modified = true;
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

            verbose = false;
            force = false;
            if nargin > 1 && varargin{1}
                verbose = true;
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            valid = false;

            % check if symbol is actually contained in container
            if ~isfield(obj.container.data, obj.name)
                if verbose
                    warning('Symbol is not part of its linked container.');
                end
                return
            end

            if ~obj.alias_with.isValid()
                if verbose
                    warning('Linked symbol is invalid.');
                end
                return
            end

            valid = true;
        end

        %> Get domain violations
        %>
        %> @see \ref GAMSTransfer::Symbol::getDomainViolations
        %> "Symbol.getDomainViolations"
        function dom_violations = getDomainViolations(obj)
            % Get domain violations
            %
            % See also: GAMSTransfer.Symbol.getDomainViolations

            dom_violations = obj.alias_with.getDomainViolations();
        end

        %> Extends domain sets in order to resolve domain violations
        %>
        %> @see \ref GAMSTransfer::Symbol::resolveDomainViolations
        %> "Symbol.resolveDomainViolations"
        function resolveDomainViolations(obj)
            % Extends domain sets in order to resolve domain violations
            %
            % See also: GAMSTransfer.Symbol.resolveDomainViolations

            obj.alias_with.resolveDomainViolations();
        end

        %> Returns the sparsity of symbol records
        %>
        %> @see \ref GAMSTransfer::Symbol::getSparsity "Symbol.getSparsity"
        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % See also: GAMSTransfer.Symbol.getSparsity

            sparsity = obj.alias_with.getSparsity();
        end

        %> Returns the cardenality of symbol records
        %>
        %> @see \ref GAMSTransfer::Symbol::getCardenality
        %> "Symbol.getCardenality"
        function card = getCardenality(obj)
            % Returns the cardenality of symbol records
            %
            % See also: GAMSTransfer.Symbol.getCardenality

            card = obj.alias_with.getCardenality();
        end

        %> Returns the largest value in records
        %>
        %> @see \ref GAMSTransfer::Symbol::getMaxValue "Symbol.getMaxValue"
        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % See also: GAMSTransfer.Symbol.getMaxValue

            [value, where] = obj.alias_with.getMaxValue(varargin{:});
        end

        %> Returns the smallest value in records
        %>
        %> @see \ref GAMSTransfer::Symbol::getMinValue "Symbol.getMinValue"
        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % See also: GAMSTransfer.Symbol.getMinValue

            [value, where] = obj.alias_with.getMinValue(varargin{:});
        end

        %> Returns the mean value over all values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::getMeanValue "Symbol.getMeanValue"
        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % See also: GAMSTransfer.Symbol.getMeanValue

            value = obj.alias_with.getMeanValue(varargin{:});
        end

        %> Returns the largest absolute value in records
        %>
        %> @see \ref GAMSTransfer::Symbol::getMaxAbsValue
        %> "Symbol.getMaxAbsValue"
        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % See also: GAMSTransfer.Symbol.getMaxAbsValue

            [value, where] = obj.alias_with.getMaxAbsValue(varargin{:});
        end

        %> Returns the number of GAMS NA values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::countNA "Symbol.countNA"
        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % See also: GAMSTransfer.Symbol.countNA

            n = obj.alias_with.countNA(varargin{:});
        end

        %> Returns the number of GAMS UNDEF values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::countUndef "Symbol.countUndef"
        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % See also: GAMSTransfer.Symbol.countUndef

            n = obj.alias_with.countUndef(varargin{:});
        end

        %> Returns the number of GAMS EPS values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::countEps "Symbol.countEps"
        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % See also: GAMSTransfer.Symbol.countEps

            n = obj.alias_with.countEps(varargin{:});
        end

        %> Returns the number of GAMS PINF (positive infinity) values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::countPosInf "Symbol.countPosInf"
        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % See also: GAMSTransfer.Symbol.countPosInf

            n = obj.alias_with.countPosInf(varargin{:});
        end

        %> Returns the number of GAMS MINF (negative infinity) values in records
        %>
        %> @see \ref GAMSTransfer::Symbol::countNegInf "Symbol.countNegInf"
        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % See also: GAMSTransfer.Symbol.countNegInf

            n = obj.alias_with.countNegInf(varargin{:});
        end

        %> Returns the number of GDX records (not available for matrix formats)
        %>
        %> @see \ref GAMSTransfer::Symbol::getNumberRecords
        %> "Symbol.getNumberRecords"
        function nrecs = getNumberRecords(obj)
            % Returns the number of GDX records (not available for matrix
            % formats)
            %
            % See also: GAMSTransfer.Symbol.getNumberRecords

            nrecs = obj.alias_with.getNumberRecords();
        end

        %> Returns the number of values stored for this symbol.
        %>
        %> @see \ref GAMSTransfer::Symbol::getNumberValues
        %> "Symbol.getNumberValues"
        function nvals = getNumberValues(obj, varargin)
            % Returns the number of values stored for this symbol.
            %
            % See also: GAMSTransfer.Symbol.getNumberValues

            nvals = obj.alias_with.getNumberValues(varargin{:});
        end

        %> Returns the UELs used in this symbol
        %>
        %> @see \ref GAMSTransfer::Symbol::getUELs "Symbol.getUELs"
        function uels = getUELs(obj, dim, varargin)
            % Returns the UELs used in this symbol
            %
            % See also: GAMSTransfer.Symbol.getUELs

            uels = obj.alias_with.getUELs(dim, varargin{:});
        end

        %> Returns the UELs labels for the given UEL IDs
        %>
        %> @see \ref GAMSTransfer::Symbol::getUELLabels "Symbol.getUELLabels"
        function uels = getUELLabels(obj, dim, ids)
            % Returns the UELs labels for the given UEL IDs
            %
            % See also: GAMSTransfer.Symbol.getUELLabels

            uels = obj.alias_with.getUELLabels(dim, ids);
        end

        %> Sets the UELs without modifying UEL IDs in records
        %>
        %> @see \ref GAMSTransfer::Symbol::initUELs "Symbol.initUELs"
        function initUELs(obj, dim, uels)
            % Sets the UELs without modifying UEL IDs in records
            %
            % See also: GAMSTransfer.Symbol.initUELs

            obj.alias_with.initUELs(dim, uels);
        end

        %> Sets the UELs with updating UEL IDs in records
        %>
        %> @see \ref GAMSTransfer::Symbol::setUELs "Symbol.setUELs"
        function setUELs(obj, dim, uels)
            % Sets the UELs with updating UEL IDs in records
            %
            % See also: GAMSTransfer.Symbol.setUELs

            obj.alias_with.setUELs(dim, uels);
        end

        %> Adds UELs to the symbol
        %>
        %> @see \ref GAMSTransfer::Symbol::addUELs "Symbol.addUELs"
        function addUELs(obj, dim, uels)
            % Adds UELs to the symbol
            %
            % See also: GAMSTransfer.Symbol.addUELs

            obj.alias_with.addUELs(dim, uels);
        end

        %> Removes UELs from the symbol
        %>
        %> @see \ref GAMSTransfer::Symbol::removeUELs "Symbol.removeUELs"
        function removeUELs(obj, dim, uels)
            % Removes UELs from the symbol
            %
            % See also: GAMSTransfer.Symbol.removeUELs

            obj.alias_with.removeUELs(dim, uels);
        end

        %> Renames UELs in the symbol
        %>
        %> @see \ref GAMSTransfer::Symbol::renameUELs "Symbol.renameUELs"
        function renameUELs(obj, dim, olduels, newuels)
            % Renames UELs in the symbol
            %
            % See also: GAMSTransfer.Symbol.renameUELs

            obj.alias_with.renameUELs(dim, olduels, newuels);
        end

    end

    methods (Hidden)

        function unsetContainer(obj)
            obj.container = GAMSTransfer.Container('indexed', obj.container.indexed, ...
                'gams_dir', obj.container.gams_dir, 'features', obj.container.features);
            obj.modified = true;
        end

        function bool = isValidAsDomain(obj)
            % Checks if alias could be used as a domain of a different symbol
            %
            % b = isValidAsDomain() returns true if this alias can be used as
            % domain and false otherwise.
            %

            bool = obj.alias_with.isValidAsDomain();
        end

    end

end
