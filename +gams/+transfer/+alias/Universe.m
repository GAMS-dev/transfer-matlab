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
% See also: gams.transfer.symbol.Set, gams.transfer.Container, gams.transfer.Alias

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
%> @see \ref gams::transfer::symbol::Set "Set", \ref gams::transfer::Container "Container", \ref
%> gams::transfer::alias::Set "Alias"
%>
classdef Universe < gams.transfer.alias.Abstract

    methods (Hidden, Static)

        function arg = validateAliasWith(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if ~strcmp(arg, gams.transfer.Constants.UNIVERSE_NAME)
                error('Argument ''%s'' (at position %d) must be ''%s''.', name, index, gams.transfer.Constants.UNIVERSE_NAME);
            end
        end

    end

    properties (Dependent)
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
            alias_with = gams.transfer.Constants.UNIVERSE_NAME;
        end

        function obj = set.alias_with(obj, alias_with)
            obj.validateAliasWith('alias_with', 1, alias_with);
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
            domain = {gams.transfer.Constants.UNIVERSE_NAME};
        end

        function domain_names = get.domain_names(obj)
            domain_names = {gams.transfer.Constants.UNIVERSE_NAME};
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = {gams.transfer.Constants.UNIVERSE_LABEL};
        end

        function domain_type = get.domain_type(obj)
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

        function format_ = get.format(obj)
            if gams.transfer.Constants.SUPPORTS_TABLE
                format_ = 'table';
            else
                format_ = 'struct';
            end
        end

    end

    methods

        function obj = Universe(varargin)
            % parse input arguments
            try
                obj.container_ = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'container', @obj.validateContainer);
                obj.name_ = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'name', @obj.validateName);
            catch e
                error(e.message);
            end
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

        function flag = isValid(obj, varargin)
            flag = true;
        end

        function uels = getUELs(obj, varargin)
            % TODO: check varargin
            uels = obj.container_.getUELs(varargin{:});
        end

        function removeUELs(obj, varargin)
            % TODO: check varargin
            obj.container_.removeUELs(varargin{:});
        end

        function renameUELs(obj, uels)
            obj.container_.renameUELs(uels);
        end

        function lowerUELs(obj)
            obj.container_.lowerUELs();
        end

        function upperUELs(obj)
            obj.container_.upperUELs();
        end

    end

end
