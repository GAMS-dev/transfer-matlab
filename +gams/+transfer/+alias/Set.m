% GAMS Set Alias
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
% s = Set(c, 's');
% a = Alias(c, 'a', s);
%
% See also: gams.transfer.symbol.Set, gams.transfer.Container

%> @brief GAMS Alias
%>
%> This class represents a GAMS Alias, which is a link to another GAMS \ref
%> gams::transfer::symbol::Set "Set".
%>
%> **Example:**
%> ```
%> c = Container();
%> s = Set(c, 's');
%> a = Alias(c, 'a', s);
%> ```
%>
%> @see \ref gams::transfer::symbol::Set "Set", \ref gams::transfer::Container "Container"
%>
classdef Set < gams.transfer.alias.Abstract

    properties (Hidden, SetAccess = protected)
        alias_with_
    end

    methods (Hidden, Static)

        function arg = validateAliasWith(name, index, arg)
            while isa(arg, 'gams.transfer.alias.Set')
                arg = arg.alias_with;
            end
            if ~isa(arg, 'gams.transfer.symbol.Set')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.Set'' or ''gams.transfer.alias.Set''.', name, index);
            end
        end

    end

    properties (Dependent)
        %> alias_with
        alias_with
        description
        is_singleton
        dimension
        size
        domain
        domain_labels
    end

    properties (Dependent, SetAccess = private)
        domain_names
        domain_type
    end

    properties (Dependent)
        domain_forwarding
        records
    end

    properties (Dependent, SetAccess = private)
        format
    end

    methods

        function alias_with = get.alias_with(obj)
            alias_with = obj.alias_with_;
        end

        function set.alias_with(obj, alias_with)
            obj.alias_with_ = obj.validateAliasWith('alias_with', 1, alias_with);
            obj.modified_ = true;
        end

        function description = get.description(obj)
            description = obj.alias_with_.description;
        end

        function obj = set.description(obj, description)
            obj.alias_with_.description = description;
        end

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.alias_with_.is_singleton;
        end

        function obj = set.is_singleton(obj, is_singleton)
            obj.alias_with_.is_singleton = is_singleton;
        end

        function dimension = get.dimension(obj)
            dimension = obj.alias_with_.dimension;
        end

        function obj = set.dimension(obj, dimension)
            obj.alias_with_.dimension = dimension;
        end

        function size = get.size(obj)
            size = obj.alias_with_.size;
        end

        function obj = set.size(obj, size_)
            obj.alias_with_.size = size_;
        end

        function domain = get.domain(obj)
            domain = obj.alias_with_.domain;
        end

        function obj = set.domain(obj, domain)
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

        function obj = set.records(obj, records)
            obj.alias_with_.records = records;
        end

        function format_ = get.format(obj)
            format_ = obj.alias_with_.format;
        end

    end

    methods

        function obj = Set(varargin)
            % parse input arguments
            try
                obj.container_ = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'container', @obj.validateContainer);
                obj.name_ = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'name', @obj.validateName);
                obj.alias_with_ = gams.transfer.utils.parse_argument(varargin, ...
                    3, 'alias_with', @obj.validateAliasWith);
            catch e
                error(e.message);
            end
        end

        function eq = equals(obj, symbol)
            eq = equals@gams.transfer.alias.Abstract(obj, symbol) && ...
                obj.alias_with_.equals(symbol.alias_with);
        end

        function symbol = copy(obj, varargin)

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

            % parse input arguments
            try
                symbol = gams.transfer.utils.validate('symbol', 1, symbol, {class(obj)}, -1);
            catch e
                error(e.message);
            end

            obj.alias_with_ = symbol.alias_with;
            obj.modified_ = true;
        end

    end

    methods

        function setRecords(obj, varargin)
            obj.alias_with_.setRecords(varargin{:});
        end

        function transformRecords(obj, target_format)
            obj.alias_with_.transformRecords(target_format);
        end

        function flag = isValid(obj, varargin)

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

        function dom_violations = getDomainViolations(obj)
            dom_violations = obj.alias_with_.getDomainViolations();
        end

        function resolveDomainViolations(obj)
            obj.alias_with_.resolveDomainViolations();
        end

        function sparsity = getSparsity(obj)
            sparsity = obj.alias_with_.getSparsity();
        end

        function [value, where] = getMaxValue(obj, varargin)
            [value, where] = obj.alias_with_.getMaxValue(varargin{:});
        end

        function [value, where] = getMinValue(obj, varargin)
            [value, where] = obj.alias_with_.getMinValue(varargin{:});
        end

        function value = getMeanValue(obj, varargin)
            value = obj.alias_with_.getMeanValue(varargin{:});
        end

        function [value, where] = getMaxAbsValue(obj, varargin)
            [value, where] = obj.alias_with_.getMaxAbsValue(varargin{:});
        end

        function n = countNA(obj, varargin)
            n = obj.alias_with_.countNA(varargin{:});
        end

        function n = countUndef(obj, varargin)
            n = obj.alias_with_.countUndef(varargin{:});
        end

        function n = countEps(obj, varargin)
            n = obj.alias_with_.countEps(varargin{:});
        end

        function n = countPosInf(obj, varargin)
            n = obj.alias_with_.countPosInf(varargin{:});
        end

        function n = countNegInf(obj, varargin)
            n = obj.alias_with_.countNegInf(varargin{:});
        end

        function nrecs = getNumberRecords(obj)
            nrecs = obj.alias_with_.getNumberRecords();
        end

        function nvals = getNumberValues(obj, varargin)
            nvals = obj.alias_with_.getNumberValues(varargin{:});
        end

        function uels = getUELs(obj, dim, varargin)
            uels = obj.alias_with_.getUELs(dim, varargin{:});
        end

        function setUELs(obj, uels, dim, varargin)
            obj.alias_with_.setUELs(uels, dim, varargin{:});
        end

        function addUELs(obj, uels, dim)
            obj.alias_with_.addUELs(uels, dim);
        end

        function removeUELs(obj, varargin)
            obj.alias_with_.removeUELs(varargin{:});
        end

        function renameUELs(obj, uels, dim)
            obj.alias_with_.renameUELs(uels, dim);
        end

        function lowerUELs(obj, dim)
            obj.alias_with_.lowerUELs(dim);
        end

        function upperUELs(obj, dim)
            obj.alias_with_.upperUELs(dim);
        end

    end

end
