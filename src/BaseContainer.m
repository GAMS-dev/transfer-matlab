% GAMSTransfer BaseContainer stores (multiple) symbols (expert-only)
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
% Container base (only use subclasses)
%

%> @ingroup container
%> @brief Container base (only use subclasses)
%>
classdef BaseContainer < handle

    properties (SetAccess = protected)
        %> GAMS system directory

        % gams_dir GAMS system directory
        gams_dir = ''


        %> Flag for indexed mode

        % indexed Flag for indexed mode
        indexed = false


        %> GAMS (GDX) symbols

        % data GAMS (GDX) symbols
        data = struct()
    end

    properties (Hidden, SetAccess = protected)
        id
        features
        modified_ = true
        name_lookup = struct();
    end

    methods (Hidden)

        %> Constructs a GAMSTransfer BaseContainer
        function obj = BaseContainer(gams_dir, indexed, features)
            % Constructs a GAMSTransfer BaseContainer

            obj.id = int32(randi(100000));

            % check support of features
            obj.features = GAMSTransfer.Utils.checkFeatureSupport();

            % input arguments
            obj.gams_dir = GAMSTransfer.Utils.checkGamsDirectory(gams_dir);
            obj.indexed = indexed;
            feature_names = fieldnames(obj.features);
            for i = 1:numel(feature_names)
                if isfield(features, feature_names{i})
                    obj.features.(feature_names{i}) = features.(feature_names{i});
                end
            end
        end

    end

    methods

        function set.data(obj, data)
            obj.data = data;
            obj.modified_ = true;
        end

    end

    methods

        %> Checks if symbol exists in container (case insensitive)
        %>
        %> - `s = c.hasSymbols(a)` returns `true` if GAMS symbol named `a` (case
        %>   does not matter) exists. `false` otherwise.
        %> - `s = c.hasSymbols(b)` returns a list of bools where an entry `s{i}`
        %>   is `true` if GAMS symbol named `b{i}` (case does not matter)
        %>   exists. `false` otherwise.
        function bool = hasSymbols(obj, names)
            % Checks if symbol exists in container (case insensitive)
            %
            % s = c.hasSymbols(a) returns true if GAMS symbol named a (case does
            % not matter) exists. false otherwise.
            % s = c.hasSymbols(b) returns a list of bools where an entry s{i} is
            % true if GAMS symbol named b{i} (case does not matter) exists.
            % false otherwise.

            if ischar(names) || isstring(names)
                bool = isfield(obj.name_lookup, lower(names));
            elseif iscellstr(names)
                n = numel(names);
                bool = true(1, n);
                for i = 1:n
                    bool(i) = isfield(obj.name_lookup, lower(names{i}));
                end
            else
                error('Name must be of type ''char'' or ''cellstr''.');
            end
        end

        %> Get symbol names by names (case insensitive)
        %>
        %> - `s = c.getSymbolNames(a)` returns GAMS symbol names named `a` where
        %>   `a` may have different casing.
        %> - `s = c.getSymbolNames(b)` returns a list GAMS symbol names
        %>   where names equal `b` case insensitively.
        %>
        %> **Example:**
        %> ```
        %> v1 = c.getSymbolNames('v1'); % equals c.getSymbolNames('V1');
        %> ```
        function symbols = getSymbolNames(obj, names)
            % Get symbol names by names (case insensitive)
            %
            % s = c.getSymbolNames(a) returns GAMS symbol names named a where a
            % may have different casing.
            % s = c.getSymbolNames(b) returns a list GAMS symbol names where
            % names equal b case insensitively.
            %
            % Example:
            % v1 = c.getSymbolNames('v1'); % equals c.getSymbolNames('V1');

            if ischar(names) || isstring(names)
                name_lower = lower(names);
                if ~isfield(obj.name_lookup, name_lower)
                    error('Symbol ''%s'' does not exist.', names);
                end
                symbols = obj.name_lookup.(name_lower);
            elseif iscellstr(names)
                n = numel(names);
                symbols = cell(size(names));
                for i = 1:n
                    name_lower = lower(names{i});
                    if ~isfield(obj.name_lookup, name_lower)
                        error('Symbol ''%s'' does not exist.', names{i});
                    end
                    symbols{i} = obj.name_lookup.(name_lower);
                end
            else
                error('Name must be of type ''char'' or ''cellstr''.');
            end
        end

        %> Lists all symbols in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSets
        %> "BaseContainer.listSets", \ref
        %> GAMSTransfer::BaseContainer::listParameters
        %> "BaseContainer.listParameters", \ref
        %> GAMSTransfer::BaseContainer::listVariables
        %> "BaseContainer.listVariables", \ref
        %> GAMSTransfer::BaseContainer::listEquations
        %> "BaseContainer.listEquations", \ref
        %> GAMSTransfer::BaseContainer::listAliases "BaseContainer.listAliases"
        function list = listSymbols(obj, varargin)
            % Lists all symbols in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: GAMSTransfer.BaseContainer.listSets,
            % GAMSTransfer.BaseContainer.listParameters,
            % GAMSTransfer.BaseContainer.listVariables,
            % GAMSTransfer.BaseContainer.listEquations,
            % GAMSTransfer.BaseContainer.listAliases

            p = inputParser();
            addParameter(p, 'types', [], @isnumeric);
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});
            types = p.Results.types;
            is_valid = p.Results.is_valid;

            names = fieldnames(obj.data);
            if isempty(types) && ~islogical(is_valid)
                list = names;
                return
            end

            % count matched symbols
            for k = 1:2
                n = 0;
                for i = 1:numel(names)
                    symbol = obj.data.(names{i});

                    % check type
                    matched_type = isempty(types);
                    for j = 1:numel(types)
                        if isfield(symbol, 'symbol_type')
                            matched_type = strcmp(symbol.symbol_type, ...
                                GAMSTransfer.SymbolType.int2str(types(j)));
                        else
                            switch types(j)
                            case GAMSTransfer.SymbolType.SET
                                matched_type = isa(symbol, 'GAMSTransfer.Set');
                            case GAMSTransfer.SymbolType.PARAMETER
                                matched_type = isa(symbol, 'GAMSTransfer.Parameter');
                            case GAMSTransfer.SymbolType.VARIABLE
                                matched_type = isa(symbol, 'GAMSTransfer.Variable');
                            case GAMSTransfer.SymbolType.EQUATION
                                matched_type = isa(symbol, 'GAMSTransfer.Equation');
                            case GAMSTransfer.SymbolType.ALIAS
                                matched_type = isa(symbol, 'GAMSTransfer.Alias');
                            otherwise
                                error('Invalid symbol type.');
                            end
                        end
                        if matched_type
                            break;
                        end
                    end
                    if ~matched_type
                        continue
                    end

                    % check invalid
                    if islogical(is_valid) && isa(symbol, 'GAMSTransfer.Symbol') && ...
                        xor(is_valid, symbol.isValid())
                        continue
                    end

                    % add name to list
                    n = n + 1;
                    if k == 2
                        list{n} = names{i};
                    end
                end
                if k == 1
                    list = cell(n, 1);
                end
            end
        end

        %> Lists all sets in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSymbols
        %> "BaseContainer.listSymbols", \ref
        %> GAMSTransfer::BaseContainer::listParameters
        %> "BaseContainer.listParameters", \ref
        %> GAMSTransfer::BaseContainer::listVariables
        %> "BaseContainer.listVariables", \ref
        %> GAMSTransfer::BaseContainer::listEquations
        %> "BaseContainer.listEquations", \ref
        %> GAMSTransfer::BaseContainer::listAliases "BaseContainer.listAliases"
        function list = listSets(obj, varargin)
            % Lists all sets in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: GAMSTransfer.BaseContainer.listSymbols,
            % GAMSTransfer.BaseContainer.listParameters,
            % GAMSTransfer.BaseContainer.listVariables,
            % GAMSTransfer.BaseContainer.listEquations,
            % GAMSTransfer.BaseContainer.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', GAMSTransfer.SymbolType.SET, ...
                'is_valid', p.Results.is_valid);
        end

        %> Lists all parameters in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSymbols
        %> "BaseContainer.listSymbols", \ref
        %> GAMSTransfer::BaseContainer::listSets "BaseContainer.listSets", \ref
        %> GAMSTransfer::BaseContainer::listVariables
        %> "BaseContainer.listVariables", \ref
        %> GAMSTransfer::BaseContainer::listEquations
        %> "BaseContainer.listEquations", \ref
        %> GAMSTransfer::BaseContainer::listAliases "BaseContainer.listAliases"
        function list = listParameters(obj, varargin)
            % Lists all parameters in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: GAMSTransfer.BaseContainer.listSymbols,
            % GAMSTransfer.BaseContainer.listSets,
            % GAMSTransfer.BaseContainer.listVariables,
            % GAMSTransfer.BaseContainer.listEquations,
            % GAMSTransfer.BaseContainer.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', GAMSTransfer.SymbolType.PARAMETER, ...
                'is_valid', p.Results.is_valid);
        end

        %> Lists all variables in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %> - types (`any`):
        %>   Enable filter for variable type, e.g. `type = {"binary",
        %>   "integer"}`. Default: not applied.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSymbols
        %> "BaseContainer.listSymbols", \ref
        %> GAMSTransfer::BaseContainer::listSets "BaseContainer.listSets", \ref
        %> GAMSTransfer::BaseContainer::listParameters
        %> "BaseContainer.listParameters", \ref
        %> GAMSTransfer::BaseContainer::listEquations
        %> "BaseContainer.listEquations", \ref
        %> GAMSTransfer::BaseContainer::listAliases "BaseContainer.listAliases"
        function list = listVariables(obj, varargin)
            % Lists all variables in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            % - types (any):
            %   Enable filter for variable type, e.g. type = {'binary',
            %   'integer'}. Default: not applied.
            %
            % See also: GAMSTransfer.BaseContainer.listSymbols,
            % GAMSTransfer.BaseContainer.listSets,
            % GAMSTransfer.BaseContainer.listParameters,
            % GAMSTransfer.BaseContainer.listEquations,
            % GAMSTransfer.BaseContainer.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            addParameter(p, 'types', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', GAMSTransfer.SymbolType.VARIABLE, ...
                'is_valid', p.Results.is_valid);

            % check for further filtering
            if isstring(p.Results.types) && numel(p.Results.types) == 1 || ischar(p.Results.types)
                type_request = [GAMSTransfer.VariableType.str2int(p.Results.types)];
            elseif iscellstr(p.Results.types)
                type_request = zeros(size(p.Results.types));
                for i = 1:numel(type_request)
                    type_request(i) = GAMSTransfer.VariableType.str2int(p.Results.types{i});
                end
            elseif isnan(p.Results.types)
                return;
            else
                error('Type must be cellstr or string.');
            end

            % filter
            filter = false(size(list));
            for i = 1:numel(list)
                symbol = obj.data.(list{i});
                type_sym = GAMSTransfer.VariableType.str2int(symbol.type);
                filter(i) = sum(type_request == type_sym) > 0;
            end
            list = list(filter);
        end

        %> Lists all equations in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %> - types (`any`):
        %>   Enable filter for equation type, e.g. `type = {"g", "l"}`. Default:
        %>   not applied.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSymbols
        %> "BaseContainer.listSymbols", \ref
        %> GAMSTransfer::BaseContainer::listSets "BaseContainer.listSets", \ref
        %> GAMSTransfer::BaseContainer::listParameters
        %> "BaseContainer.listParameters", \ref
        %> GAMSTransfer::BaseContainer::listVariables
        %> "BaseContainer.listVariables", \ref
        %> GAMSTransfer::BaseContainer::listAliases "BaseContainer.listAliases"
        function list = listEquations(obj, varargin)
            % Lists all equations in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not applied.
            % - types (any):
            %   Enable filter for equation type, e.g. type = {'g', 'l'}.
            %   Default: not applied.
            %
            % See also: GAMSTransfer.BaseContainer.listSymbols,
            % GAMSTransfer.BaseContainer.listSets,
            % GAMSTransfer.BaseContainer.listParameters,
            % GAMSTransfer.BaseContainer.listVariables,
            % GAMSTransfer.BaseContainer.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            addParameter(p, 'types', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', GAMSTransfer.SymbolType.EQUATION, ...
                'is_valid', p.Results.is_valid);

            % check for further filtering
            if isstring(p.Results.types) && numel(p.Results.types) == 1 || ischar(p.Results.types)
                type_request = [GAMSTransfer.EquationType.str2int(p.Results.types)];
            elseif iscellstr(p.Results.types)
                type_request = zeros(size(p.Results.types));
                for i = 1:numel(type_request)
                    type_request(i) = GAMSTransfer.EquationType.str2int(p.Results.types{i});
                end
            elseif isnan(p.Results.types)
                return;
            else
                error('Type must be cellstr or string.');
            end

            % filter
            filter = false(size(list));
            for i = 1:numel(list)
                symbol = obj.data.(list{i});
                type_sym = GAMSTransfer.EquationType.str2int(symbol.type);
                filter(i) = sum(type_request == type_sym) > 0;
            end
            list = list(filter);
        end

        %> Lists all aliases in container
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref GAMSTransfer::BaseContainer::listSymbols
        %> "BaseContainer.listSymbols", \ref
        %> GAMSTransfer::BaseContainer::listSets "BaseContainer.listSets", \ref
        %> GAMSTransfer::BaseContainer::listParameters
        %> "BaseContainer.listParameters", \ref
        %> GAMSTransfer::BaseContainer::listVariables
        %> "BaseContainer.listVariables", \ref
        %> GAMSTransfer::BaseContainer::listEquations
        %> "BaseContainer.listEquations"
        function list = listAliases(obj, varargin)
            % Lists all aliases in container
            %
            % Parameter Arguments:
            % - is_valid: logical or any
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: GAMSTransfer.BaseContainer.listSymbols,
            % GAMSTransfer.BaseContainer.listSets,
            % GAMSTransfer.BaseContainer.listParameters,
            % GAMSTransfer.BaseContainer.listVariables,
            % GAMSTransfer.BaseContainer.listEquations

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', GAMSTransfer.SymbolType.ALIAS, ...
                'is_valid', p.Results.is_valid);
        end

        %> Returns an overview over all sets in container
        %>
        %> See \ref GAMSTRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> @note This method includes set aliases.
        %>
        %> **Optional Arguments:**
        %> 1. symbols (`cellstr`):
        %>    List of symbols to include. Default: `listSets()`.
        %>
        %> The overview is in form of a table listing for each symbol its
        %> main characteristics and some statistics.
        function descr = describeSets(obj, varargin)
            % Returns an overview over all sets in container
            %
            % Note: This method includes set aliases.
            %
            % Optional Arguments:
            % 1. symbols (cellstr):
            %    List of symbols to include. Default: listSets().
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.

            if nargin == 2
                symbols = obj.getSymbolNames(varargin{1});
            else
                symbols = obj.listSets();
            end

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.SET, symbols);
        end

        %> Returns an overview over all parameters in container
        %>
        %> See \ref GAMSTRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Optional Arguments:**
        %> 1. symbols (`cellstr`):
        %>    List of symbols to include. Default: `listParameters()`.
        %>
        %> The overview is in form of a table listing for each symbol its
        %> main characteristics and some statistics.
        function descr = describeParameters(obj, varargin)
            % Returns an overview over all parameters in container
            %
            % Optional Arguments:
            % 1. symbols (cellstr):
            %    List of symbols to include. Default: listParameters().
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.

            if nargin == 2
                symbols = obj.getSymbolNames(varargin{1});
            else
                symbols = obj.listParameters();
            end

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.PARAMETER, symbols);
        end

        %> Returns an overview over all variables in container
        %>
        %> See \ref GAMSTRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Optional Arguments:**
        %> 1. symbols (`cellstr`):
        %>    List of symbols to include. Default: `listVariables()`.
        %>
        %> The overview is in form of a table listing for each symbol its
        %> main characteristics and some statistics.
        function descr = describeVariables(obj, varargin)
            % Returns an overview over all variables in container
            %
            % Optional Arguments:
            % 1. symbols: cellstr
            %    List of symbols to include. Default: listVariables().
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.

            if nargin == 2
                symbols = obj.getSymbolNames(varargin{1});
            else
                symbols = obj.listVariables();
            end

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.VARIABLE, symbols);
        end

        %> Returns an overview over all equations in container
        %>
        %> See \ref GAMSTRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Optional Arguments:**
        %> 1. symbols (`cellstr`):
        %>    List of symbols to include. Default: `listEquations()`.
        %>
        %> The overview is in form of a table listing for each symbol its
        %> main characteristics and some statistics.
        function descr = describeEquations(obj, varargin)
            % Returns an overview over all equations in container
            %
            % Optional Arguments:
            % 1. symbols (cellstr):
            %    List of symbols to include. Default: listEquations().
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.

            if nargin == 2
                symbols = obj.getSymbolNames(varargin{1});
            else
                symbols = obj.listEquations();
            end

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.EQUATION, symbols);
        end

        %> Returns an overview over all aliases in container
        %>
        %> See \ref GAMSTRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
        %>
        %> **Optional Arguments:**
        %> 1. symbols (`cellstr`):
        %>    List of symbols to include. Default: `listAliases()`.
        %>
        %> The overview is in form of a table listing for each symbol its
        %> main characteristics and some statistics.
        function descr = describeAliases(obj, varargin)
            % Returns an overview over all aliases in container
            %
            % Optional Arguments:
            % 1. symbols (cellstr):
            %    List of symbols to include. Default: listAliases().
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.

            if nargin == 2
                symbols = obj.getSymbolNames(varargin{1});
            else
                symbols = obj.listAliases();
            end

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.ALIAS, symbols);
        end

        %> Checks correctness of all symbols
        %>
        %> See \ref GAMSTRANSFER_MATLAB_RECORDS_VALIDATE for more information.
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        %>
        %> @see \ref GAMSTransfer::Symbol::isValid "Symbol.isValid"
        function valid = isValid(obj, varargin)
            % Checks correctness of all symbols
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)
            %
            % See also: GAMSTransfer.Symbol/isValid

            valid = true;
        end

    end

    methods (Hidden, Access = protected)

        function data = readRaw(obj, filename, symbols, format, records, values)
            % Reads symbol records from GDX file
            %

            % get full path
            filename = GAMSTransfer.Utils.checkFilename(char(filename), '.gdx', false);

            % parsing input arguments
            switch format
            case {'struct', 'dense_matrix', 'sparse_matrix'}
                format_int = GAMSTransfer.RecordsFormat.str2int(format);
            case 'table'
                format_int = GAMSTransfer.RecordsFormat.TABLE;
                if ~obj.features.table
                    format_int = GAMSTransfer.RecordsFormat.STRUCT;
                end
            otherwise
                error('Invalid format option: %s. Choose from: struct, table, dense_matrix, sparse_matrix.', format);
            end
            values_bool = false(5,1);
            for e = values
                switch e{1}
                case {'level', 'value', 'text'}
                    values_bool(1) = true;
                case 'marginal'
                    values_bool(2) = true;
                case 'lower'
                    values_bool(3) = true;
                case 'upper'
                    values_bool(4) = true;
                case 'scale'
                    values_bool(5) = true;
                otherwise
                    error('Invalid value option: %s. Choose from level, value, text, marginal, lower, upper, scale.', e{1});
                end
            end

            % read records
            if obj.indexed
                data = GAMSTransfer.gt_cmex_idx_read(obj.gams_dir, filename, ...
                    symbols, int32(format_int), records);
            else
                data = GAMSTransfer.gt_cmex_gdx_read(obj.gams_dir, filename, ...
                    symbols, int32(format_int), records, values_bool, ...
                    obj.features.categorical, obj.features.c_prop_setget);
            end
        end

        function descr = describeSymbols(obj, symtype, wanted_symbols)
            % get list of elements (ignore invalid labels)

            symbols = cell(1, numel(wanted_symbols));
            n_symbols = 0;
            for i = 1:numel(wanted_symbols)
                if ~isfield(obj.data, wanted_symbols{i})
                    continue;
                end
                symbol = obj.data.(wanted_symbols{i});

                if isfield(symbol, 'symbol_type')
                    symbol_type = symbol.symbol_type;
                elseif isa(symbol, 'GAMSTransfer.Set')
                    symbol_type = 'set';
                elseif isa(symbol, 'GAMSTransfer.Parameter')
                    symbol_type = 'parameter';
                elseif isa(symbol, 'GAMSTransfer.Variable')
                    symbol_type = 'variable';
                elseif isa(symbol, 'GAMSTransfer.Equation')
                    symbol_type = 'equation';
                elseif isa(symbol, 'GAMSTransfer.Alias')
                    symbol_type = 'alias';
                else
                    error('Invalid symbol type');
                end

                if symtype == GAMSTransfer.SymbolType.SET && ...
                    ~strcmp(symbol_type, 'set') && ~strcmp(symbol_type, 'alias')
                    continue
                end
                if symtype == GAMSTransfer.SymbolType.PARAMETER && ...
                    ~strcmp(symbol_type, 'parameter')
                    continue
                end
                if symtype == GAMSTransfer.SymbolType.VARIABLE && ...
                    ~strcmp(symbol_type, 'variable')
                    continue
                end
                if symtype == GAMSTransfer.SymbolType.EQUATION && ...
                    ~strcmp(symbol_type, 'equation')
                    continue
                end
                if symtype == GAMSTransfer.SymbolType.ALIAS && ...
                    ~strcmp(symbol_type, 'alias')
                    continue
                end

                n_symbols = n_symbols + 1;
                symbols{n_symbols} = symbol;
            end
            symbols = symbols(1:n_symbols);

            % init describe table
            descr = struct();
            descr.name = cell(n_symbols, 1);
            switch symtype
            case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                descr.type = cell(n_symbols, 1);
            case GAMSTransfer.SymbolType.SET
                descr.is_alias = true(n_symbols, 1);
                descr.is_singleton = true(n_symbols, 1);
            case GAMSTransfer.SymbolType.ALIAS
                descr.is_alias = true(n_symbols, 1);
                descr.is_singleton = true(n_symbols, 1);
                descr.alias_with = cell(n_symbols, 1);
            end
            descr.format = cell(n_symbols, 1);
            descr.dim = zeros(n_symbols, 1);
            descr.domain_type = cell(n_symbols, 1);
            descr.domain = cell(n_symbols, 1);
            descr.size = cell(n_symbols, 1);
            descr.num_recs = zeros(n_symbols, 1);
            descr.num_vals = zeros(n_symbols, 1);
            descr.sparsity = zeros(n_symbols, 1);
            switch symtype
            case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                descr.min_level = zeros(n_symbols, 1);
                descr.mean_level = zeros(n_symbols, 1);
                descr.max_level = zeros(n_symbols, 1);
                descr.where_max_abs_level = cell(n_symbols, 1);
                descr.count_na_level = zeros(n_symbols, 1);
                descr.count_undef_level = zeros(n_symbols, 1);
                descr.count_eps_level = zeros(n_symbols, 1);
                descr.min_marginal = zeros(n_symbols, 1);
                descr.mean_marginal = zeros(n_symbols, 1);
                descr.max_marginal = zeros(n_symbols, 1);
                descr.where_max_abs_marginal = cell(n_symbols, 1);
                descr.count_na_marginal = zeros(n_symbols, 1);
                descr.count_undef_marginal = zeros(n_symbols, 1);
                descr.count_eps_marginal = zeros(n_symbols, 1);
            case GAMSTransfer.SymbolType.PARAMETER
                descr.min_value = zeros(n_symbols, 1);
                descr.mean_value = zeros(n_symbols, 1);
                descr.max_value = zeros(n_symbols, 1);
                descr.where_max_abs_value = cell(n_symbols, 1);
                descr.count_na = zeros(n_symbols, 1);
                descr.count_undef = zeros(n_symbols, 1);
                descr.count_eps = zeros(n_symbols, 1);
            end

            % collect values
            for i = 1:n_symbols
                symbol = symbols{i};

                descr.name{i} = symbol.name;
                if symtype == GAMSTransfer.SymbolType.VARIABLE || ...
                    symtype == GAMSTransfer.SymbolType.EQUATION
                    descr.type{i} = symbol.type;
                elseif symtype == GAMSTransfer.SymbolType.SET || ...
                    symtype == GAMSTransfer.SymbolType.ALIAS
                    descr.is_alias(i) = isa(symbol, 'GAMSTransfer.Alias') || ...
                        isfield(symbol, 'symbol_type') && strcmp(symbol.symbol_type, 'alias');
                    if descr.is_alias(i) && isa(symbol.alias_with, 'GAMSTransfer.Symbol')
                        symbol = symbol.alias_with;
                    elseif descr.is_alias(i)
                        symbol = obj.data.(symbol.alias_with);
                    end
                end
                if symtype == GAMSTransfer.SymbolType.ALIAS
                    descr.alias_with{i} = symbol.name;
                elseif symtype == GAMSTransfer.SymbolType.SET
                    descr.is_singleton(i) = symbol.is_singleton;
                end
                descr.format{i} = symbol.format;
                descr.dim(i) = symbol.dimension;
                descr.domain_type{i} = symbol.domain_type;
                descr.domain{i} = GAMSTransfer.Utils.list2str(symbol.domain);
                descr.size{i} = GAMSTransfer.Utils.list2str(symbol.size);
                if isfield(symbol, 'number_records')
                    descr.num_recs(i) = symbol.number_records;
                else
                    descr.num_recs(i) = symbol.getNumberRecords();
                end
                if isfield(symbol, 'number_values')
                    descr.num_vals(i) = symbol.number_values;
                else
                    descr.num_vals(i) = symbol.getNumberValues();
                end
                if isfield(symbol, 'sparsity')
                    descr.sparsity(i) = symbol.sparsity;
                else
                    descr.sparsity(i) = symbol.getSparsity();
                end
                switch symtype
                case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                    descr.min_level(i) = GAMSTransfer.getMinValue(symbol, obj.indexed, 'level');
                    descr.mean_level(i) = GAMSTransfer.getMeanValue(symbol, 'level');
                    descr.max_level(i) = GAMSTransfer.getMaxValue(symbol, obj.indexed, 'level');
                    [absmax, descr.where_max_abs_level{i}] = GAMSTransfer.getMaxAbsValue(symbol, obj.indexed, 'level');
                    if isnan(absmax)
                        descr.where_max_abs_level{i} = '';
                    else
                        descr.where_max_abs_level{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_level{i});
                    end
                    descr.count_na_level(i) = GAMSTransfer.countNA(symbol, {'level'});
                    descr.count_undef_level(i) = GAMSTransfer.countUndef(symbol, {'level'});
                    descr.count_eps_level(i) = GAMSTransfer.countEps(symbol, {'level'});
                    descr.min_marginal(i) = GAMSTransfer.getMinValue(symbol, obj.indexed, 'marginal');
                    descr.mean_marginal(i) = GAMSTransfer.getMeanValue(symbol, 'marginal');
                    descr.max_marginal(i) = GAMSTransfer.getMaxValue(symbol, obj.indexed, 'marginal');
                    [absmax, descr.where_max_abs_marginal{i}] = GAMSTransfer.getMaxAbsValue(symbol, obj.indexed, 'marginal');
                    if isnan(absmax)
                        descr.where_max_abs_marginal{i} = '';
                    else
                        descr.where_max_abs_marginal{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_marginal{i});
                    end
                    descr.count_na_marginal(i) = GAMSTransfer.countNA(symbol, {'marginal'});
                    descr.count_undef_marginal(i) = GAMSTransfer.countUndef(symbol, {'marginal'});
                    descr.count_eps_marginal(i) = GAMSTransfer.countEps(symbol, {'marginal'});
                case GAMSTransfer.SymbolType.PARAMETER
                    descr.min_value(i) = GAMSTransfer.getMinValue(symbol, obj.indexed);
                    descr.mean_value(i) = GAMSTransfer.getMeanValue(symbol);
                    descr.max_value(i) = GAMSTransfer.getMaxValue(symbol, obj.indexed);
                    [absmax, descr.where_max_abs_value{i}] = GAMSTransfer.getMaxAbsValue(symbol, obj.indexed);
                    if isnan(absmax)
                        descr.where_max_abs_value{i} = '';
                    else
                        descr.where_max_abs_value{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_value{i});
                    end
                    descr.count_na(i) = GAMSTransfer.countNA(symbol);
                    descr.count_undef(i) = GAMSTransfer.countUndef(symbol);
                    descr.count_eps(i) = GAMSTransfer.countEps(symbol);
                end
            end

            % convert to categorical if possible
            if obj.features.categorical
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                descr.domain_type = categorical(descr.domain_type);
                descr.domain = categorical(descr.domain);
                descr.size = categorical(descr.size);
                switch symtype
                case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                    descr.type = categorical(descr.type);
                    descr.where_max_abs_level = categorical(descr.where_max_abs_level);
                    descr.where_max_abs_marginal = categorical(descr.where_max_abs_marginal);
                case GAMSTransfer.SymbolType.PARAMETER
                    descr.where_max_abs_value = categorical(descr.where_max_abs_value);
                case GAMSTransfer.SymbolType.ALIAS
                    descr.alias_with = categorical(descr.alias_with);
                end
            end

            % convert to table if possible
            if obj.features.table
                descr = struct2table(descr);
            end
        end

    end

    methods (Hidden, Access = protected)

        function clearData(obj)
            obj.data = struct();
            obj.name_lookup = struct();
        end

        function addToData(obj, name, symbol)
            if obj.hasSymbols(name)
                error('Symbol ''%s'' already exists.', name);
            end
            obj.data.(name) = symbol;
            obj.name_lookup.(lower(name)) = name;
        end

        function renameData(obj, oldname, newname)
            if ~obj.hasSymbols(oldname)
                return
            end

            % get index of symbol
            names = fieldnames(obj.data);
            idx = find(strcmp(names, oldname), 1);
            if isempty(idx)
                return
            end

            % add new symbol / remove old symbol
            obj.data.(newname) = obj.data.(oldname);
            obj.name_lookup.(lower(newname)) = newname;
            obj.data = rmfield(obj.data, oldname);
            obj.name_lookup = rmfield(obj.name_lookup, lower(oldname));

            % get old ordering
            perm = [1:idx-1, numel(names), idx:numel(names)-1];
            obj.data = orderfields(obj.data, perm);
            obj.name_lookup = orderfields(obj.name_lookup, perm);
        end

        function removeFromData(obj, name)
            if ~obj.hasSymbols(name)
                return
            end
            obj.data = rmfield(obj.data, name);
            obj.name_lookup = rmfield(obj.name_lookup, lower(name));
        end

    end

end
