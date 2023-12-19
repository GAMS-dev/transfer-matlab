% GAMS Transfer Container stores (multiple) symbols
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
% GAMS Transfer Container stores (multiple) symbols
%
% A GAMS GDX file is a collection of GAMS symbols (e.g. variables or
% parameters), each holding multiple symbol records. In GAMS Transfer the
% Container is the main object that holds different symbols and allows to read
% and write those to GDX.
%
% Indexed Mode:
%
% There are two different modes GAMS Transfer can be used in: indexed or default.
% - In default mode the main characteristic of a symbol is its domain that
%   defines the symbol dimension and its dependencies. A size of symbol is here
%   given by the number of records of the domain sets of each dimension. In
%   default mode all GAMS symbol types can be used.
% - In indexed mode, there are no domain sets, but sizes (the shape of a symbol)
%   can be set explicitly. Furthermore, there are no UELs and only GAMS
%   Parameters are allowed to be used in indexed mode.
% The mode is defined when creating a container and can't be changed thereafter.
%
% Optional Arguments:
% 1. source (string or Container):
%    Path to GDX file or a Container object to be read
%
% Parameter Arguments:
% - gams_dir (string):
%   Path to GAMS system directory. Default is determined from PATH environment
%   variable
% - indexed (logical):
%   Specifies if container is used in indexed of default mode, see above.
%
% Example:
% c = Container();
% c = Container('path/to/file.gdx');
% c = Container('indexed', true, 'gams_dir', 'C:\GAMS');
%
% See also: gams.transfer.Set, gams.transfer.Alias, gams.transfer.Parameter,
% gams.transfer.Variable, gams.transfer.Equation
%

%> @brief GAMS Transfer Container stores (multiple) symbols
%>
%> A GAMS GDX file is a collection of GAMS symbols (e.g. variables or
%> parameters), each holding multiple symbol records. In GAMS Transfer the
%> Container is the main object that holds different symbols and allows to read
%> and write those to GDX. See \ref GAMS_TRANSFER_MATLAB_CONTAINER for more
%> information.
%>
%> **Indexed Mode:**
%>
%> There are two different modes GAMS Transfer can be used in: indexed or default.
%> - In default mode the main characteristic of a symbol is its domain that
%>   defines the symbol dimension and its dependencies. A size of symbol is here
%>   given by the number of records of the domain sets of each dimension. In
%>   default mode all GAMS symbol types can be used.
%> - In indexed mode, there are no domain sets, but sizes (the shape of a symbol)
%>   can be set explicitly. Furthermore, there are no UELs and only GAMS
%>   Parameters are allowed to be used in indexed mode.
%>
%> The mode is defined when creating a container and can't be changed thereafter.
%> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED for more information.
%>
%> **Example:**
%> ```
%> c = Container();
%> c = Container('path/to/file.gdx');
%> c = Container('indexed', true, 'gams_dir', 'C:\GAMS');
%> ```
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Alias "Alias", \ref
%> gams::transfer::Parameter "Parameter", \ref gams::transfer::Variable "Variable",
%> \ref gams::transfer::Equation "Equation"
classdef Container < handle

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

    properties (Dependent)

        %> Flag to indicate modification
        %>
        %> If the container or any symbol within has been modified since last
        %> reset of flag (`false`), this flag will be `true`. Resetting will
        %> also reset symbol flag.

        % Flag to indicate modification
        %
        % If the container or any symbol within has been modified since last
        % reset of flag (`false`), this flag will be `true`. Resetting will
        % also reset symbol flag.
        modified

    end

    properties (Hidden, SetAccess = protected)
        id
        features
        modified_ = true
        name_lookup = struct();
    end

    methods

        %> Constructs a GAMS Transfer Container
        %>
        %> **Optional Arguments:**
        %> 1. source (`string` or `Container`):
        %>    Path to GDX file or a \ref gams::transfer::Container "Container"
        %>    object to be read
        %>
        %> **Parameter Arguments:**
        %> - gams_dir (`string`):
        %>   Path to GAMS system directory. Default is determined from PATH environment
        %>   variable
        %> - indexed (`logical`):
        %>   Specifies if container is used in indexed of default mode, see above.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> c = Container('path/to/file.gdx');
        %> c = Container('indexed', true, 'gams_dir', 'C:\GAMS');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Alias "Alias", \ref
        %> gams::transfer::Parameter "Parameter", \ref gams::transfer::Variable "Variable",
        %> \ref gams::transfer::Equation "Equation", \ref gams::transfer::Container
        %> "Container"
        function obj = Container(varargin)
            % Constructs a GAMS Transfer Container, see class help

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'gams_dir') && ~strcmpi(x, 'indexed') && ...
                ~strcmpi(x, 'features');
            is_source = @(x) is_string_char(x) || isa(x, 'gams.transfer.Container');
            addOptional(p, 'source', '', is_source);
            addParameter(p, 'gams_dir', '', is_string_char);
            addParameter(p, 'indexed', false, @islogical);
            addParameter(p, 'features', struct(), @isstruct);
            parse(p, varargin{:});

            obj.id = int32(randi(100000));

            % check support of features
            obj.features = gams.transfer.Utils.checkFeatureSupport();

            % input arguments
            obj.gams_dir = gams.transfer.Utils.checkGamsDirectory(p.Results.gams_dir);
            obj.indexed = p.Results.indexed;
            feature_names = fieldnames(obj.features);
            for i = 1:numel(feature_names)
                if isfield(p.Results.features, feature_names{i})
                    obj.features.(feature_names{i}) = p.Results.features.(feature_names{i});
                end
            end

            % read GDX file
            if ~strcmp(p.Results.source, '')
                obj.read(p.Results.source);
            end
        end

    end

    methods

        function set.data(obj, data)
            obj.data = data;
            obj.modified_ = true;
        end

        function set.modified(obj, modified)
            if ~islogical(modified)
                error('Modified must be logical.');
            end
            symbols = fieldnames(obj.data);
            for i = 1:numel(symbols)
                obj.data.(symbols{i}).modified = modified;
            end
            obj.modified_ = modified;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
            symbols = fieldnames(obj.data);
            for i = 1:numel(symbols)
                if modified
                    return
                end
                modified = modified || obj.data.(symbols{i}).modified;
            end
        end

    end

    methods

        %> Checks equivalence with other container
        %>
        %> **Required Arguments:**
        %> 1. container (`any`):
        %>    Other Container
        function eq = equals(obj, container)
            % Checks equivalence with other container
            %
            % Required Arguments:
            % 1. container (any):
            %    Other Container

            eq = false;
            if ~isa(container, 'gams.transfer.Container')
                return
            end
            eq = isequaln(obj.gams_dir, container.gams_dir);
            eq = eq && obj.indexed == container.indexed;
            eq = eq && numel(fieldnames(obj.data)) == numel(fieldnames(container.data));
            if ~eq
                return
            end

            symbols1 = fieldnames(obj.data);
            symbols2 = fieldnames(container.data);
            if numel(symbols1) ~= numel(symbols2)
                eq = false;
                return
            end
            for i = 1:numel(symbols1)
                eq = eq && isequaln(symbols1{i}, symbols2{i});
                eq = eq && obj.data.(symbols1{i}).equals(container.data.(symbols2{i}));
            end
        end

        %> Reads symbols from GDX file
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_READ for more information.
        %>
        %> **Required Arguments:**
        %> 1. source (`string` or `Container`):
        %>    Path to GDX file or a \ref gams::transfer::Container "Container" object to be read
        %>
        %> **Parameter Arguments:**
        %> - symbols (`cell`):
        %>   List of symbols to be read. All if empty. Case doesn't matter.
        %>   Default is `{}`.
        %> - format (`string`):
        %>   Records format symbols should be stored in. Default is `table`.
        %> - records (`logical`):
        %>   Enables reading of records. Default is `true`.
        %> - values (`cell`):
        %>   Subset of `{"level", "marginal", "lower", "upper", "scale"}` that
        %>   defines what value fields should be read. Default is all.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> c.read('path/to/file.gdx');
        %> c.read('path/to/file.gdx', 'format', 'dense_matrix');
        %> c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
        %> ```
        %>
        %> @see \ref gams::transfer::RecordsFormat "RecordsFormat"
        function read(obj, varargin)
            % Reads symbols from GDX file
            %
            % Required Arguments:
            % 1. source (string or (Const)Container):
            %    Path to GDX file, a (Const)Container object to be read
            %
            % Parameter Arguments:
            % - symbols (cell):
            %   List of symbols to be read. All if empty. Case doesn't matter.
            %   Default is {}.
            % - format (string):
            %   Records format symbols should be stored in. Default is table.
            % - records (logical):
            %   Enables reading of records. Default is true.
            % - values (cell):
            %   Subset of {'level', 'marginal', 'lower', 'upper', 'scale'} that
            %   defines what value fields should be read. Default is all.
            %
            % Example:
            % c = Container();
            % c.read('path/to/file.gdx');
            % c.read('path/to/file.gdx', 'format', 'dense_matrix');
            % c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
            %
            % See also: gams.transfer.RecordsFormat

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_source = @(x) is_string_char(x) || isa(x, 'gams.transfer.Container');
            is_values = @(x) iscellstr(x) && numel(x) <= 5;
            addRequired(p, 'source', is_source);
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'format', 'table', is_string_char);
            addParameter(p, 'records', true, @islogical);
            addParameter(p, 'values', {'level', 'marginal', 'lower', 'upper', 'scale'}, ...
                is_values);
            parse(p, varargin{:});

            % copy symbols from container
            if isa(p.Results.source, 'gams.transfer.Container')
                if p.Results.source.indexed ~= obj.indexed
                    error('Indexed flags of source and this container must match.');
                end
                source_data = p.Results.source.data;
                symbols = p.Results.source.listSymbols();
                if ~isempty(p.Results.symbols)
                    sym_enabled = false(size(symbols));
                    for i = 1:numel(p.Results.symbols)
                        sym_enabled(strcmp(symbols, p.Results.symbols{i})) = true;
                    end
                    symbols = symbols(sym_enabled);
                end
                for i = 1:numel(symbols)
                    source_data.(symbols{i}).copy(obj);
                end
                return
            end

            % read raw data
            data = obj.readRaw(p.Results.source, p.Results.symbols, p.Results.format, ...
                p.Results.records, p.Results.values);
            symbols = fieldnames(data);
            is_partial_read = numel(p.Results.symbols) > 0;

            % transform data into Symbol object
            for i = 1:numel(symbols)
                symbol = data.(symbols{i});

                % handle alias differently
                switch symbol.symbol_type
                case {gams.transfer.SymbolType.ALIAS, 'alias'}
                    if strcmp(symbol.alias_with, '*')
                        gams.transfer.UniverseAlias(obj, symbol.name);
                    elseif obj.hasSymbols(symbol.alias_with)
                        gams.transfer.Alias(obj, symbol.name, obj.getSymbols(symbol.alias_with));
                    else
                        error('Alias reference for symbol ''%s'' not found: %s.', ...
                            symbol.name, symbol.alias_with);
                    end
                    continue;
                end

                % create cross-referenced domain if possible
                if obj.indexed
                    domain = symbol.size;
                else
                    domain = symbol.domain;
                    for j = 1:numel(domain)
                        if strcmp(domain{j}, '*')
                            continue
                        elseif symbol.domain_type == 2
                            continue
                        elseif obj.hasSymbols(domain{j}) && isfield(data, domain{j})
                            domain{j} = obj.getSymbols(domain{j});
                        end
                    end
                end

                % convert symbol to GDXSymbol
                switch symbol.symbol_type
                case {gams.transfer.SymbolType.SET, 'set'}
                    gams.transfer.Set(obj, symbol.name, domain, 'description', ...
                        symbol.description, 'is_singleton', symbol.is_singleton);
                case {gams.transfer.SymbolType.PARAMETER, 'parameter'}
                    gams.transfer.Parameter(obj, symbol.name, domain, 'description', ...
                        symbol.description);
                case {gams.transfer.SymbolType.VARIABLE, 'variable'}
                    gams.transfer.Variable(obj, symbol.name, symbol.type, domain, ...
                        'description', symbol.description);
                case {gams.transfer.SymbolType.EQUATION, 'equation'}
                    gams.transfer.Equation(obj, symbol.name, symbol.type, domain, ...
                        'description', symbol.description);
                otherwise
                    error('Invalid symbol type');
                end

                % set records and store format (no need to call isValid to
                % detect the format because at this point, we know it)
                obj.data.(symbol.name).records = symbol.records;
                switch symbol.format
                case {3, 'dense_matrix',
                    4, 'sparse_matrix'}
                    copy_format = ~any(isnan(obj.data.(symbol.name).size));
                otherwise
                    copy_format = true;
                end
                % TODO
                % if copy_format
                %     if isnumeric(symbol.format)
                %         obj.data.(symbol.name).format_ = symbol.format;
                %     else
                %         obj.data.(symbol.name).format_ = gams.transfer.RecordsFormat.str2int(symbol.format);
                %     end
                % end

                % set uels
                if isfield(symbol, 'uels') && ~obj.features.categorical
                    switch symbol.format
                    case {3, 'dense_matrix',
                        4, 'sparse_matrix'}
                    otherwise
                        for j = 1:numel(symbol.domain)
                            if isempty(symbol.uels{j})
                                continue
                            end
                            obj.data.(symbol.name).setUELs(symbol.uels{j}, j, 'rename', true);
                        end
                    end
                end
            end

            % check for format of read symbols in case of partial read (done by
            % forced call to isValid). Domains may not be read and may cause
            % invalid symbols.
            if is_partial_read
                for j = 1:numel(symbols)
                    if obj.hasSymbols(symbols{i})
                        obj.getSymbols(symbols{i}).isValid(false, true);
                    end
                end
            end
        end

        %> Writes symbols with symbol records to GDX file
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_WRITE for more information.
        %>
        %> **Required Arguments:**
        %> 1. filename (`string`):
        %>    Path to GDX file to write to.
        %>
        %> **Parameter Arguments:**
        %> - symbols (`cell`):
        %>   List of symbols to be written. All if empty. Case doesn't matter.
        %>   Default is `{}`.
        %> - compress (`logical`):
        %>   Flag to compress GDX file (`true`) or not (`false`). Default is
        %>   `false`.
        %> - sorted (`logical`):
        %>   Flag to define records as sorted (`true`) or not (`false`). Default
        %>   is `false`.
        %> - uel_priority (`cellstr`):
        %>   UELs to be registered first before any symbol UELs. Default: `{}`.
        %>
        %> **Example:**
        %> ```
        %> c.write('path/to/file.gdx');
        %> c.write('path/to/file.gdx', 'compress', true, 'sorted', true);
        %> ```
        %>
        %> @see \ref gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations"
        function write(obj, varargin)
            % Writes symbols with symbol records to GDX file
            %
            % There are different issues that can occur when writing to GDX:
            % e.g. domain violations and unsorted data. For domain violations,
            % see gams.transfer.Container.getDomainViolations. Domain labels are
            % stored as UELs in GDX that are an (code,label) pair. The code is a
            % number with an ascending order based on the write occurence. Data
            % records must be sorted by these codes in ascending order (dimension
            % 1 first, then dimension 2, ...). If one knows that the data is
            % sorted, one can set the flag 'sorted' to true to improve
            % performance. Otherwise GAMS Transfer will sort the values
            % internally. Note, that the case of 'sorted' being true and the
            % data not being sorted will lead to an error.
            %
            % Required Arguments:
            % 1. filename (string):
            %    Path to GDX file to write to.
            %
            % Parameter Arguments:
            % - symbols (cell):
            %   List of symbols to be written. All if empty. Case doesn't
            %   matter. Default is {}.
            % - compress (logical):
            %   Flag to compress GDX file (true) or not (false). Default is
            %   false.
            % - sorted (logical):
            %   Flag to define records as sorted (true) or not (false). Default
            %   is false.
            % - uel_priority (cellstr):
            %   UELs to be registered first before any symbol UELs. Default: {}.
            %
            % Example:
            % c.write('path/to/file.gdx');
            % c.write('path/to/file.gdx', 'compress', true, 'sorted', true);
            %
            % See also: gams.transfer.Container.getDomainViolations

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'compress') && ~strcmpi(x, 'sorted');
            addRequired(p, 'filename', is_string_char);
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'compress', false, @islogical);
            addParameter(p, 'sorted', false, @islogical);
            addParameter(p, 'uel_priority', {}, @iscellstr);
            parse(p, varargin{:});

            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(p.Results.symbols);
            end

            if ~obj.isValid('symbols', symbols)
                obj.reorderSymbols();
                if ~obj.isValid('symbols', symbols)
                    invalid_symbols = gams.transfer.Utils.list2str(...
                        obj.listSymbols('is_valid', false));
                    error('Can''t write invalid container. Invalid symbols: %s.', invalid_symbols);
                end
            end

            % create enable flags
            if isempty(p.Results.symbols)
                enable = true(1, numel(symbols));
            else
                enable = false(1, numel(symbols));
                allsymbols = fieldnames(obj.data);
                allsymbols = containers.Map(allsymbols, 1:numel(allsymbols));
                for i = 1:numel(symbols)
                    enable(allsymbols(symbols{i})) = true;
                end
            end

            if p.Results.compress && obj.indexed
                error('Compression not supported for indexed GDX.');
            end

            % get full path
            filename = gams.transfer.Utils.checkFilename(...
                char(p.Results.filename), '.gdx', false);

            % write data
            if obj.indexed
                gams.transfer.cmex.gt_idx_write(obj.gams_dir, filename, obj.data, ...
                    enable, p.Results.sorted, obj.features.table);
            else
                gams.transfer.cmex.gt_gdx_write(obj.gams_dir, filename, obj.data, ...
                    enable, p.Results.uel_priority, p.Results.compress, p.Results.sorted, ...
                    obj.features.table, obj.features.categorical, obj.features.c_prop_setget);
            end
        end

        %> Get symbol objects by names
        %>
        %> Note: The letter case of the name does not matter.
        %>
        %> - `s = c.getSymbols()` returns the handles to all GAMS symbols.
        %> - `s = c.getSymbols(a)` returns the handle to GAMS symbol named `a`.
        %> - `s = c.getSymbols(b)` returns a list of handles to the GAMS symbols
        %>   with names equal to any element in cell `b`.
        %>
        %> **Example:**
        %> ```
        %> v1 = c.getSymbols('v1');
        %> vars = c.getSymbols(c.listVariables());
        %> ```
        function symbols = getSymbols(obj, names)
            % Get symbol objects by names
            %
            % Note: The letter case of the name does not matter.
            %
            % s = c.getSymbols() returns the handles to all GAMS symbols.
            % s = c.getSymbols(a) returns the handle to GAMS symbol named a.
            % s = c.getSymbols(b) returns a list of handles to the GAMS symbols
            % with names equal to any element in cell b.
            %
            % Example:
            % v1 = c.getSymbols('v1');
            % vars = c.getSymbols(c.listVariables());

            if nargin == 1
                symbols = struct2cell(obj.data);
                return
            end

            sym_names = obj.getSymbolNames(names);

            if ischar(names) || isstring(names)
                symbols = obj.data.(sym_names);
            elseif iscellstr(names)
                n = numel(names);
                symbols = cell(size(names));
                for i = 1:n
                    symbols{i} = obj.data.(sym_names{i});
                end
            else
                error('Name must be of type ''char'' or ''cellstr''.');
            end
        end

        %> Gets all Set objects
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::getSymbols "Container.getSymbols"
        function symbols = getSets(obj, varargin)
            % Gets all Set objects
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listSets, gams.transfer.Container.getSymbols

            symbols = obj.getSymbols(obj.listSets(varargin{:}));
        end

        %> Gets all Parameter objects
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::getSymbols "Container.getSymbols"
        function symbols = getParameters(obj, varargin)
            % Gets all Parameter objects
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listParameters, gams.transfer.Container.getSymbols

            symbols = obj.getSymbols(obj.listParameters(varargin{:}));
        end

        %> Gets all Variable objects
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
        %> @see \ref gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::getSymbols "Container.getSymbols"
        function symbols = getVariables(obj, varargin)
            % Gets all Variable objects
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
            % See also: gams.transfer.Container.listVariables, gams.transfer.Container.getSymbols

            symbols = obj.getSymbols(obj.listVariables(varargin{:}));
        end

        %> Gets all Equation objects
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
        %> @see \ref gams::transfer::Container::listEquations "Container.listEquations", \ref
        %> gams::transfer::Container::getSymbols "Container.getSymbols"
        function symbols = getEquations(obj, varargin)
            % Gets all Equation objects
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
            % See also: gams.transfer.Container.listEquations, gams.transfer.Container.getSymbols

            symbols = obj.getSymbols(obj.listEquations(varargin));
        end

        %> Gets all Alias objects
        %>
        %> **Parameter Arguments:**
        %> - is_valid (`logical` or `any`):
        %>   Enable `valid` filter if argument is of type logical. If `true`,
        %>   only include symbols that are valid and, if `false`, only invalid
        %>   symbols. Default: not logical.
        %>
        %> @see \ref gams::transfer::Container::listAliases "Container.listAliases", \ref
        %> gams::transfer::Container::getSymbols "Container.getSymbols"
        function symbols = getAliases(obj, varargin)
            % Gets all Aliases objects
            %
            % Parameter Arguments:
            % - is_valid: logical or any
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listAliases, gams.transfer.Container.getSymbols

            symbols = obj.getSymbols(obj.listAliases(varargin{:}));
        end

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
        %> @see \ref gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::listEquations "Container.listEquations", \ref
        %> gams::transfer::Container::listAliases "Container.listAliases"
        function list = listSymbols(obj, varargin)
            % Lists all symbols in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listSets, gams.transfer.Container.listParameters,
            % gams.transfer.Container.listVariables, gams.transfer.Container.listEquations,
            % gams.transfer.Container.listAliases

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
                                gams.transfer.SymbolType.int2str(types(j)));
                        else
                            switch types(j)
                            case gams.transfer.SymbolType.SET
                                matched_type = isa(symbol, 'gams.transfer.Set');
                            case gams.transfer.SymbolType.PARAMETER
                                matched_type = isa(symbol, 'gams.transfer.Parameter');
                            case gams.transfer.SymbolType.VARIABLE
                                matched_type = isa(symbol, 'gams.transfer.Variable');
                            case gams.transfer.SymbolType.EQUATION
                                matched_type = isa(symbol, 'gams.transfer.Equation');
                            case gams.transfer.SymbolType.ALIAS
                                matched_type = isa(symbol, 'gams.transfer.Alias');
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
                    if islogical(is_valid) && isa(symbol, 'gams.transfer.Symbol') && ...
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
        %> @see \ref gams::transfer::Container::listSymbols "Container.listSymbols", \ref
        %> gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::listEquations "Container.listEquations", \ref
        %> gams::transfer::Container::listAliases "Container.listAliases"
        function list = listSets(obj, varargin)
            % Lists all sets in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listSymbols, gams.transfer.Container.listParameters,
            % gams.transfer.Container.listVariables, gams.transfer.Container.listEquations,
            % gams.transfer.Container.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', gams.transfer.SymbolType.SET, ...
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
        %> @see \ref gams::transfer::Container::listSymbols "Container.listSymbols", \ref
        %> gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::listEquations "Container.listEquations", \ref
        %> gams::transfer::Container::listAliases "Container.listAliases"
        function list = listParameters(obj, varargin)
            % Lists all parameters in container
            %
            % Parameter Arguments:
            % - is_valid (logical or any):
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listSymbols, gams.transfer.Container.listSets,
            % gams.transfer.Container.listVariables, gams.transfer.Container.listEquations,
            % gams.transfer.Container.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', gams.transfer.SymbolType.PARAMETER, ...
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
        %> @see \ref gams::transfer::Container::listSymbols "Container.listSymbols", \ref
        %> gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::listEquations "Container.listEquations", \ref
        %> gams::transfer::Container::listAliases "Container.listAliases"
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
            % See also: gams.transfer.Container.listSymbols, gams.transfer.Container.listSets,
            % gams.transfer.Container.listParameters, gams.transfer.Container.listEquations,
            % gams.transfer.Container.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            addParameter(p, 'types', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', gams.transfer.SymbolType.VARIABLE, ...
                'is_valid', p.Results.is_valid);

            % check for further filtering
            if isstring(p.Results.types) && numel(p.Results.types) == 1 || ischar(p.Results.types)
                type_request = [gams.transfer.VariableType.str2int(p.Results.types)];
            elseif iscellstr(p.Results.types)
                type_request = zeros(size(p.Results.types));
                for i = 1:numel(type_request)
                    type_request(i) = gams.transfer.VariableType.str2int(p.Results.types{i});
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
                type_sym = gams.transfer.VariableType.str2int(symbol.type);
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
        %> @see \ref gams::transfer::Container::listSymbols "Container.listSymbols", \ref
        %> gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::listAliases "Container.listAliases"
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
            % See also: gams.transfer.Container.listSymbols, gams.transfer.Container.listSets,
            % gams.transfer.Container.listParameters, gams.transfer.Container.listVariables,
            % gams.transfer.Container.listAliases

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            addParameter(p, 'types', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', gams.transfer.SymbolType.EQUATION, ...
                'is_valid', p.Results.is_valid);

            % check for further filtering
            if isstring(p.Results.types) && numel(p.Results.types) == 1 || ischar(p.Results.types)
                type_request = [gams.transfer.EquationType.str2int(p.Results.types)];
            elseif iscellstr(p.Results.types)
                type_request = zeros(size(p.Results.types));
                for i = 1:numel(type_request)
                    type_request(i) = gams.transfer.EquationType.str2int(p.Results.types{i});
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
                type_sym = gams.transfer.EquationType.str2int(symbol.type);
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
        %> @see \ref gams::transfer::Container::listSymbols "Container.listSymbols", \ref
        %> gams::transfer::Container::listSets "Container.listSets", \ref
        %> gams::transfer::Container::listParameters "Container.listParameters", \ref
        %> gams::transfer::Container::listVariables "Container.listVariables", \ref
        %> gams::transfer::Container::listEquations "Container.listEquations"
        function list = listAliases(obj, varargin)
            % Lists all aliases in container
            %
            % Parameter Arguments:
            % - is_valid: logical or any
            %   Enable valid filter if argument is of type logical. If true,
            %   only include symbols that are valid and, if false, only invalid
            %   symbols. Default: not logical.
            %
            % See also: gams.transfer.Container.listSymbols, gams.transfer.Container.listSets,
            % gams.transfer.Container.listParameters, gams.transfer.Container.listVariables,
            % gams.transfer.Container.listEquations

            p = inputParser();
            addParameter(p, 'is_valid', nan);
            parse(p, varargin{:});

            list = obj.listSymbols('types', gams.transfer.SymbolType.ALIAS, ...
                'is_valid', p.Results.is_valid);
        end

        %> Returns an overview over all sets in container
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
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

            descr = obj.describeSymbols(gams.transfer.SymbolType.SET, symbols);
        end

        %> Returns an overview over all parameters in container
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
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

            descr = obj.describeSymbols(gams.transfer.SymbolType.PARAMETER, symbols);
        end

        %> Returns an overview over all variables in container
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
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

            descr = obj.describeSymbols(gams.transfer.SymbolType.VARIABLE, symbols);
        end

        %> Returns an overview over all equations in container
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
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

            descr = obj.describeSymbols(gams.transfer.SymbolType.EQUATION, symbols);
        end

        %> Returns an overview over all aliases in container
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_CONTAINER_OVERVIEW for more information.
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

            descr = obj.describeSymbols(gams.transfer.SymbolType.ALIAS, symbols);
        end

        %> Adds a set to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::Set "Set"
        %> constructor. Alternatively, use the constructor directly. In contrast
        %> to the constructor, this method may overwrite a set if its definition
        %> (\ref gams::transfer::Set::is_singleton "is_singleton", \ref
        %> gams::transfer::Set::domain "domain", \ref
        %> gams::transfer::Set::domain_forwarding "domain_forwarding") doesn't
        %> differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s1 = c.addSet('s1');
        %> s2 = c.addSet('s2', {s1, '*', '*'});
        %> s3 = c.addSet('s3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set"
        function symbol = addSet(obj, name, varargin)
            % Adds a set to the container
            %
            % Arguments are identical to the gams.transfer.Set constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite a set if its definition
            % (is_singleton, domain, domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % s1 = c.addSet('s1');
            % s2 = c.addSet('s2', {s1, '*', '*'});
            % s3 = c.addSet('s3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
            %
            % See also: gams.transfer.Set

            new_symbol = gams.transfer.symbol.Set(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                symbol = obj.add(new_symbol);
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.symbol.Set')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            if ~symbol.def.equals(new_symbol.def)
                error('Symbol ''%s'' (with different definition) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
        end

        %> Adds a parameter to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::Parameter
        %> "Parameter" constructor. Alternatively, use the constructor directly.
        %> In contrast to the constructor, this method may overwrite a parameter
        %> if its definition (\ref gams::transfer::Parameter::domain "domain",
        %> \ref gams::transfer::Parameter::domain_forwarding "domain_forwarding")
        %> doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> p1 = c.addParameter('p1');
        %> p2 = c.addParameter('p2', {'*', '*'});
        %> p3 = c.addParameter('p3', '*', 'description', 'par p3');
        %> ```
        %>
        %> @see \ref gams::transfer::Parameter "Parameter"
        function symbol = addParameter(obj, name, varargin)
            % Adds a parameter to the container
            %
            % Arguments are identical to the gams.transfer.Parameter constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite a parameter if its
            % definition (domain, domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % p1 = c.addParameter('p1');
            % p2 = c.addParameter('p2', {'*', '*'});
            % p3 = c.addParameter('p3', '*', 'description', 'par p3');
            %
            % See also: gams.transfer.Parameter

            new_symbol = gams.transfer.symbol.Parameter(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                symbol = obj.add(new_symbol);
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.symbol.Parameter')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            if ~symbol.def.equals(new_symbol.def)
                error('Symbol ''%s'' (with different definition) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
        end

        %> Adds a variable to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::Variable "Variable"
        %> constructor. Alternatively, use the constructor directly. In contrast
        %> to the constructor, this method may overwrite a variable if its
        %> definition (\ref gams::transfer::Variable::type "type", \ref
        %> gams::transfer::Variable::domain "domain", \ref
        %> gams::transfer::Variable::domain_forwarding "domain_forwarding")
        %> doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> v1 = c.addVariable('v1');
        %> v2 = c.addVariable('v2', 'binary', {'*', '*'});
        %> v3 = c.addVariable('v3', VariableType.BINARY, '*', 'description', 'var v3');
        %> ```
        %>
        %> @see \ref gams::transfer::Variable "Variable", \ref
        %> gams::transfer::VariableType "VariableType"
        function symbol = addVariable(obj, name, varargin)
            % Adds a variable to the container
            %
            % Arguments are identical to the gams.transfer.Variable constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite a variable if its
            % definition (type, domain, domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % v1 = c.addVariable('v1');
            % v2 = c.addVariable('v2', 'binary', {'*', '*'});
            % v3 = c.addVariable('v3', VariableType.BINARY, '*', 'description', 'var v3');
            %
            % See also: gams.transfer.Variable, gams.transfer.VariableType

            new_symbol = gams.transfer.symbol.Variable(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                symbol = obj.add(new_symbol);
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.symbol.Variable')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            if ~symbol.def.equals(new_symbol.def)
                error('Symbol ''%s'' (with different definition) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
        end

        %> Adds an equation to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::Equation "Equation"
        %> constructor. Alternatively, use the constructor directly. In contrast
        %> to the constructor, this method may overwrite an equation if its
        %> definition (\ref gams::transfer::Equation::type "type", \ref
        %> gams::transfer::Equation::domain "domain", \ref
        %> gams::transfer::Equation::domain_forwarding "domain_forwarding")
        %> doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> e2 = c.addEquation('e2', 'l', {'*', '*'});
        %> e3 = c.addEquation('e3', EquationType.EQ, '*', 'description', 'equ e3');
        %> ```
        %>
        %> @see \ref gams::transfer::Equation "Equation", \ref
        %> gams::transfer::EquationType "EquationType"
        function symbol = addEquation(obj, name, etype, varargin)
            % Adds an equation to the container
            %
            % Arguments are identical to the gams.transfer.Equation constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite an equation if its
            % definition (type, domain, domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % e2 = c.addEquation('e2', 'l', {'*', '*'});
            % e3 = c.addEquation('e3', EquationType.EQ, '*', 'description', 'equ e3');
            %
            % See also: gams.transfer.Equation, gams.transfer.EquationType

            new_symbol = gams.transfer.symbol.Equation(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                symbol = obj.add(new_symbol);
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.symbol.Equation')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            if ~symbol.def.equals(new_symbol.def)
                error('Symbol ''%s'' (with different definition) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
        end

        %> Adds an alias to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::Alias "Alias"
        %> constructor. Alternatively, use the constructor directly. In contrast
        %> to the constructor, this method may overwrite an alias.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s = c.addSet('s');
        %> a = c.addAlias('a', s);
        %> ```
        %>
        %> @see \ref gams::transfer::Alias "Alias", \ref gams::transfer::Set "Set"
        function symbol = addAlias(obj, name, alias_with)
            % Adds an alias to the container
            %
            % Arguments are identical to the gams.transfer.Alias constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite an alias.
            %
            % Example:
            % c = Container();
            % s = c.addSet('s');
            % a = c.addAlias('a', s);
            %
            % See also: gams.transfer.Alias, gams.transfer.Set

            if obj.hasSymbols(name)
                symbol = obj.getSymbols(name);
                args = gams.transfer.Alias.parseConstructArguments(name, alias_with);
                if isa(symbol, 'gams.transfer.Alias')
                    symbol.alias_with = args.alias_with;
                else
                    error('Symbol ''%s'' (with different definition) already exists.', name);
                end
            else
                symbol = gams.transfer.Alias(obj, name, alias_with);
            end
        end

        %> Adds a universe alias to the container
        %>
        %> Arguments are identical to the \ref gams::transfer::UniverseAlias "UniverseAlias"
        %> constructor. Alternatively, use the constructor directly. In contrast
        %> to the constructor, this method may overwrite an alias.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> u = c.addUniverseAlias('u');
        %> ```
        %>
        %> @see \ref gams::transfer::UniverseAlias "UniverseAlias", \ref gams::transfer::Alias "Alias",
        %> \ref gams::transfer::Set "Set"
        function symbol = addUniverseAlias(obj, name)
            % Adds a universe alias to the container
            %
            % Arguments are identical to the gams.transfer.UniverseAlias constructor.
            % Alternatively, use the constructor directly. In contrast to the
            % constructor, this method may overwrite an alias.
            %
            % Example:
            % c = Container();
            % u = c.addUniverseAlias('u');
            %
            % See also: gams.transfer.UniverseAlias, gams.transfer.Alias, gams.transfer.Set

            if obj.hasSymbols(name)
                symbol = obj.getSymbols(name);
                if ~isa(symbol, 'gams.transfer.UniverseAlias')
                    error('Symbol ''%s'' (with different definition) already exists.', name);
                end
            else
                symbol = gams.transfer.UniverseAlias(obj, name);
            end
        end

        %> Rename a symbol
        %>
        %> - `renameSymbol(oldname, newname)` renames the symbol with name
        %>   `oldname` to `newname`. The symbol order in data will not change.
        %>
        %> **Example:**
        %> ```
        %> c.renameSymbol('x', 'xx');
        %> ```
        function renameSymbol(obj, oldname, newname)
            % Rename a symbol
            %
            % renameSymbol(oldname, newname) renames the symbol with name
            % oldname to newname. The symbol order in data will not change.
            %
            % Example:
            % c.renameSymbol('x', 'xx');

            if strcmp(oldname, newname)
                return
            end

            % check if symbol exists
            if obj.hasSymbols(newname) && ~strcmpi(newname, oldname)
                error('Symbol ''%s'' already exists.', newname);
            end

            oldname = obj.getSymbolNames(oldname);
            obj.data.(oldname).name_ = char(newname);
            obj.renameData(oldname, newname);
        end

        %> Removes a symbol from container
        %>
        %> Note: The letter case of the name does not matter.
        %>
        %> - `c.removeSymbols()` removes all symbols.
        %> - `c.removeSymbols(a)` removes GAMS symbol named `a`.
        %> - `c.removeSymbols(b)` removes a list of GAMS symbols with names equal elements in cell
        %>   `b`.
        %>
        %> **Example:**
        %> ```
        %> c.removeSymbols('v1');
        %> c.removeSymbols(c.listVariables());
        %> ```
        function removeSymbols(obj, names)
            % Removes a symbol from container
            %
            % Note: The letter case of the name does not matter.
            %
            % c.removeSymbols() removes all symbols.
            % c.removeSymbols(a) removes GAMS symbol named a.
            % c.removeSymbols(b) removes a list of GAMS symbols with names equal elements in cell b.
            %
            % Example:
            % c.removeSymbols('v1');
            % c.removeSymbols(c.listVariables());

            if nargin == 1
                removed_symbols = obj.getSymbols();

                obj.data = struct();
                obj.name_lookup = struct();

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                for i = 1:numel(removed_symbols)
                    removed_symbols{i}.isValid(false, true);
                    removed_symbols{i}.unsetContainer();
                end
                return
            end

            if isstring(names) || ischar(names)
                names = {names};
            end

            removed_symbols = cell(1, numel(names));
            j = 0;
            % remove symbols from data
            for i = 1:numel(names)
                if ~obj.hasSymbols(names{i})
                    continue;
                end
                j = j + 1;
                removed_symbols{j} = obj.getSymbols(names{i});

                % remove symbol
                obj.removeFromData(removed_symbols{j}.name);

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                removed_symbols{j}.isValid(false, true);

                % unlink container
                removed_symbols{j}.unsetContainer();
            end
            removed_symbols = removed_symbols(1:j);

            % remove symbols from domain references
            symbols = fieldnames(obj.data);
            remove_aliases = {};
            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                if isa(symbol, 'gams.transfer.Alias')
                    for j = 1:numel(removed_symbols)
                        if symbol.alias_with.name == removed_symbols{j}.name
                            remove_aliases{end+1} = symbol.name;
                        end
                    end
                else
                    symbol.unsetDomain(removed_symbols);
                end
            end
            if numel(remove_aliases) > 0
                obj.removeSymbols(remove_aliases);
            end
        end

        %> Reestablishes a valid GDX symbol order
        function reorderSymbols(obj)
            % Reestablishes a valid GDX symbol order

            names = fieldnames(obj.data);

            % get number of set/alias
            n_sets = 0;
            for i = 1:numel(names)
                symbol = obj.data.(names{i});
                if isa(symbol, 'gams.transfer.Set') || isa(symbol, 'gams.transfer.Alias')
                    n_sets = n_sets + 1;
                end
            end
            n_other = numel(names) - n_sets;

            sets = cell(1, n_sets);
            idx_sets = zeros(1, n_sets);
            idx_other = zeros(1, n_other);
            n_sets = 0;
            n_other = 0;

            % get index by type
            for i = 1:numel(names)
                symbol = obj.data.(names{i});
                if isa(symbol, 'gams.transfer.Set') || isa(symbol, 'gams.transfer.Alias')
                    n_sets = n_sets + 1;
                    idx_sets(n_sets) = i;
                    sets{n_sets} = names{i};
                else
                    n_other = n_other + 1;
                    idx_other(n_other) = i;
                end
            end

            % handle set dependencies
            if n_sets > 0
                n_handled = 0;
                set_handled = containers.Map(sets, false(1, n_sets));
                set_avail = true(1, n_sets);
                idx = 1:n_sets;

                while n_handled < n_sets
                    % check if we can add the next set
                    curr_is_next = true;
                    current_set = obj.data.(sets{idx(n_handled+1)});
                    for i = 1:current_set.dimension
                        if (isa(current_set.domain{i}, 'gams.transfer.Set') || ...
                            isa(current_set.domain{i}, 'gams.transfer.Alias')) && ...
                            ~set_handled(current_set.domain{i}.name)
                            curr_is_next = false;
                            break;
                        end
                    end
                    set_avail(idx(n_handled+1)) = false;
                    if curr_is_next
                        n_handled = n_handled + 1;
                        set_handled(current_set.name) = true;
                        set_avail(idx(n_handled+1:end)) = true;
                        continue;
                    end

                    % find next available
                    next_avail = find(set_avail(idx(n_handled+1:end)), 1);
                    if isempty(next_avail)
                        l = gams.transfer.Utils.list2str(sets(idx(n_handled+1:end)));
                        error('Circular domain set dependency in: %s.', l);
                    end
                    next_avail = next_avail + n_handled;
                    tmp = idx(next_avail);
                    idx(n_handled+2:next_avail) = idx(n_handled+1:next_avail-1);
                    idx(n_handled+1) = tmp;
                end

                idx_sets = idx_sets(idx);
            end

            % apply permutation
            obj.data = orderfields(obj.data, [idx_sets, idx_other]);

            % force recheck of all remaining symbols in container
            obj.isValid(false, true);
        end

        %> Get domain violations for all symbols
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::Set "Sets" as \ref gams::transfer::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::Symbol::records "records" that is not present in
        %> the corresponding referenced domain set. Such a domain violation will
        %> lead to a GDX error when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `dom_violations = getDomainViolations` returns a list of domain
        %>   violations.
        %>
        %> **Parameter Arguments:**
        %> - symbols (`cell`):
        %>   List of symbols to be considered. All if empty. Case doesn't
        %>   matter. Default is `{}`.
        %>
        %> @see \ref gams::transfer::Container::resolveDomainViolations
        %> "Container.resolveDomainViolations", \ref
        %> gams::transfer::Symbol::getDomainViolations
        %> "Symbol.getDomainViolations", \ref gams::transfer::DomainViolation
        %> "DomainViolation"
        function dom_violations = getDomainViolations(obj, varargin)
            % Get domain violations for all symbols
            %
            % Domain violations occur when a symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % dom_violations = getDomainViolations returns a list of domain
            % violations.
            %
            % Parameter Arguments:
            % - symbols (cell):
            %   List of symbols to be considered. All if empty. Case doesn't
            %   matter. Default is {}.
            %
            % See also: gams.transfer.Container.resolveDomainViolations,
            % gams.transfer.Symbol.getDomainViolations,
            % gams.transfer.DomainViolation

            dom_violations = {};

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(p.Results.symbols);
            end

            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                if isa(symbol, 'gams.transfer.Alias')
                    continue
                end

                dom_violations_sym = symbol.getDomainViolations();
                dom_violations(end+1:end+numel(dom_violations_sym)) = dom_violations_sym;
            end
        end

        %> Extends domain sets in order to remove domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::Set "Sets" as \ref gams::transfer::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::Symbol::records "records" that is not present in
        %> the corresponding referenced domain set. Such a domain violation will
        %> lead to a GDX error when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `resolveDomainViolations()` extends the domain sets with the
        %>   violated domain entries. Hence, the domain violations disappear.
        %>
        %> **Parameter Arguments:**
        %> - symbols (`cell`):
        %>   List of symbols to be considered. All if empty. Case doesn't
        %>   matter. Default is `{}`.
        %>
        %> @see \ref gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations", \ref
        %> gams::transfer::Symbol::resolveDomainViolations
        %> "Symbol.resolveDomainViolations", \ref gams::transfer::DomainViolation
        %> "DomainViolation"
        function resolveDomainViolations(obj, varargin)
            % Extends domain sets in order to remove domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % resolveDomainViolations() extends the domain sets with the
            % violated domain entries. Hence, the domain violations disappear.
            %
            % Parameter Arguments:
            % - symbols (cell):
            %   List of symbols to be considered. All if empty. Case doesn't
            %   matter. Default is {}.
            %
            % See also: gams.transfer.Container.getDomainViolations,
            % gams.transfer.Symbol.resolveDomainViolations,
            % gams.transfer.DomainViolation

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});

            dom_violations = obj.getDomainViolations('symbols', p.Results.symbols);
            for i = 1:numel(dom_violations)
                dom_violations{i}.resolve();
            end
        end

        %> Checks correctness of all symbols
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_VALIDATE for more information.
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        %>
        %> **Parameter Arguments:**
        %> - symbols (`cell`):
        %>   List of symbols to be considered. All if empty. Case doesn't
        %>   matter. Default is `{}`.
        %>
        %> @see \ref gams::transfer::Symbol::isValid "Symbol.isValid"
        function valid = isValid(obj, varargin)
            % Checks correctness of all symbols
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)
            %
            % Parameter Arguments:
            % - symbols (cell):
            %   List of symbols to be considered. All if empty. Case doesn't
            %   matter. Default is {}.
            %
            % See also: gams.transfer.Symbol/isValid

            % input arguments
            p = inputParser();
            addOptional(p, 'verbose', false, @islogical);
            addOptional(p, 'force', false, @islogical);
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(p.Results.symbols);
            end
            verbose = p.Results.verbose;
            force = p.Results.force;

            valid = true;
            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                if symbol.isValid(verbose, force)
                    continue
                end
                valid = false;
                if ~force
                    return
                end
            end
        end

        %> Get UELs from all symbols
        %>
        %> - `u = getUELs()` returns the UELs across all symbols.
        %> - `u = getUELs(_, 'symbols', s)` returns the UELs across symbols `s`.
        %> - `u = getUELs(_, "ignore_unused", true)` returns only those UELs
        %>   that are actually used in the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the container is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Container::isValid "Container.isValid"
        function uels = getUELs(obj, varargin)
            % Get UELs from all symbols
            %
            % u = getUELs() returns the UELs across all symbols.
            % u = getUELs(_, 'symbols', s) returns the UELs across symbols s.
            % u = getUELs(_, "ignore_unused", true) returns only those UELs
            % that are actually used in the records.
            %
            % Note: This can only be used if the container is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Container.isValid

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'ignore_unused', false, @islogical);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(p.Results.symbols);
            end

            uels = {};
            for i = 1:numel(symbols)
                if isa(obj.data.(symbols{i}), 'gams.transfer.UniverseAlias')
                    continue
                end
                uels = [uels; obj.data.(symbols{i}).getUELs('ignore_unused', p.Results.ignore_unused)];
                [~,uidx,~] = unique(uels, 'first');
                uels = uels(sort(uidx));
            end
        end

        %> Removes UELs from all symbols
        %>
        %> - `removeUELs()` removes all unused UELs for all symbols.
        %> - `removeUELs(u)` removes the UELs `u` for all symbols.
        %> - `removeUELs(_, 'symbols', s)` removes UELs for symbols `s`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the container is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Container::isValid "Container.isValid"
        function removeUELs(obj, varargin)
            % Removes UELs from all symbol
            %
            % removeUELs() removes all unused UELs for all symbols.
            % removeUELs(u) removes the UELs u for all symbols.
            % removeUELs(_, 'symbols', s) removes UELs for symbols s.
            %
            % Note: This can only be used if the container is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Container.isValid

            is_parname = @(x) strcmpi(x, 'symbols');

            % check optional arguments
            i = 1;
            uels = {};
            while true
                term = true;
                if i == 1 && nargin > 1
                    if ((isstring(uels) && numel(uels) == 1) || ischar(uels) || iscellstr(uels)) && ~is_parname(varargin{i})
                        uels = varargin{i};
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''uels'' must be ''char'' or ''cellstr''.');
                    end
                end
                if term || i > 1
                    break;
                end
            end

            % check parameter arguments
            symbols = {};
            while i < nargin - 1
                if strcmpi(varargin{i}, 'symbols')
                    symbols = varargin{i+1};
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 1
                error('Invalid number of arguments');
            end

            if isempty(symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(symbols);
            end

            for i = 1:numel(symbols)
                obj.data.(symbols{i}).removeUELs(uels);
            end
        end

        %> Renames UELs in all symbol
        %>
        %> - `renameUELs(u)` renames the UELs `u` for all symbols. `u` can be a
        %>   `struct` (field names = old UELs, field values = new UELs),
        %>   `containers.Map` (keys = old UELs, values = new UELs) or `cellstr`
        %>   (full list of UELs, must have as many entries as current UELs). The
        %>   codes for renamed UELs do not change.
        %> - `renameUELs(_, 'symbols', s)` renames UELs for symbols `s`.
        %> - `renameUELs(_, 'allow_merge', true)` enables support of merging one
        %>   UEL into another one (renaming a UEL to an already existing one).
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function renameUELs(obj, uels, varargin)
            % Renames UELs in all symbol
            %
            % renameUELs(u) renames the UELs u for all symbols. u can be a
            % struct (field names = old UELs, field values = new UELs),
            % containers.Map (keys = old UELs, values = new UELs) or cellstr
            % (full list of UELs, must have as many entries as current UELs).
            % The codes for renamed UELs do not change.
            % renameUELs(_, 'symbols', s) renames UELs for symbols s.
            % renameUELs(_, 'allow_merge', true) enables support of merging one
            % UEL into another one (renaming a UEL to an already existing one).
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'allow_merge', false, @islogical);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = obj.getSymbolNames(p.Results.symbols);
            end

            for i = 1:numel(symbols)
                obj.data.(symbols{i}).renameUELs(uels, 'allow_merge', p.Results.allow_merge);
            end
        end

        %> Converts UELs to lower case
        %>
        %> - `lowerUELs()` converts all UELs to lower case.
        %> - `lowerUELs('symbols', s)` converts all UELs to lower case for symbols `s`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % lowerUELs() converts all UELs to lower case.
            % lowerUELs('symbols', s) converts all UELs to lower case for symbols s.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            end

            for i = 1:numel(symbols)
                obj.data.(symbols{i}).lowerUELs();
            end
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts all UELs to upper case.
        %> - `upperUELs('symbols', s)` converts all UELs to upper case for symbols `s`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % upperUELs() converts all UELs to upper case.
            % upperUELs('symbols', s) converts all UELs to upper case for symbols s.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = fieldnames(obj.data);
            end

            for i = 1:numel(symbols)
                obj.data.(symbols{i}).upperUELs();
            end
        end

    end

    methods (Hidden, Access = {?gams.transfer.Symbol_, ?gams.transfer.Alias, ?gams.transfer.UniverseAlias})

        function symbol = add(obj, symbol)
            if obj.indexed && ~isa(symbol, 'gams.transfer.Parameter')
                error('Symbol must be of type ''gams.transfer.Parameter'' in indexed mode.');
            end
            obj.addToData(symbol.name_, symbol);
        end

    end

    methods (Hidden, Access = protected)

        function data = readRaw(obj, filename, symbols, format, records, values)
            % Reads symbol records from GDX file
            %

            % get full path
            filename = gams.transfer.Utils.checkFilename(char(filename), '.gdx', false);

            % parsing input arguments
            switch format
            case 'struct'
                format_int = 2;
            case 'dense_matrix'
                format_int = 3;
            case 'sparse_matrix'
                format_int = 4;
            case 'table'
                format_int = 5;
                if ~obj.features.table
                    format_int = 2;
                end
            otherwise
                error('Invalid format option: %s. Choose from: struct, table, dense_matrix, sparse_matrix.', format);
            end
            values_bool = false(5,1);
            for e = values
                switch e{1}
                case {'level', 'value', 'element_text'}
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
                    error('Invalid value option: %s. Choose from level, value, element_text, marginal, lower, upper, scale.', e{1});
                end
            end

            % read records
            if obj.indexed
                data = gams.transfer.cmex.gt_idx_read(obj.gams_dir, filename, ...
                    symbols, int32(format_int), records);
            else
                data = gams.transfer.cmex.gt_gdx_read(obj.gams_dir, filename, ...
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
                elseif isa(symbol, 'gams.transfer.Set')
                    symbol_type = 'set';
                elseif isa(symbol, 'gams.transfer.Parameter')
                    symbol_type = 'parameter';
                elseif isa(symbol, 'gams.transfer.Variable')
                    symbol_type = 'variable';
                elseif isa(symbol, 'gams.transfer.Equation')
                    symbol_type = 'equation';
                elseif isa(symbol, 'gams.transfer.Alias')
                    symbol_type = 'alias';
                else
                    error('Invalid symbol type');
                end

                if symtype == gams.transfer.SymbolType.SET && ...
                    ~strcmp(symbol_type, 'set') && ~strcmp(symbol_type, 'alias')
                    continue
                end
                if symtype == gams.transfer.SymbolType.PARAMETER && ...
                    ~strcmp(symbol_type, 'parameter')
                    continue
                end
                if symtype == gams.transfer.SymbolType.VARIABLE && ...
                    ~strcmp(symbol_type, 'variable')
                    continue
                end
                if symtype == gams.transfer.SymbolType.EQUATION && ...
                    ~strcmp(symbol_type, 'equation')
                    continue
                end
                if symtype == gams.transfer.SymbolType.ALIAS && ...
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
            case {gams.transfer.SymbolType.VARIABLE, gams.transfer.SymbolType.EQUATION}
                descr.type = cell(n_symbols, 1);
            case gams.transfer.SymbolType.SET
                descr.is_singleton = true(n_symbols, 1);
            case gams.transfer.SymbolType.ALIAS
                descr.is_singleton = true(n_symbols, 1);
                descr.alias_with = cell(n_symbols, 1);
            end
            descr.format = cell(n_symbols, 1);
            descr.dimension = zeros(n_symbols, 1);
            descr.domain_type = cell(n_symbols, 1);
            descr.domain = cell(n_symbols, 1);
            descr.size = cell(n_symbols, 1);
            descr.number_records = zeros(n_symbols, 1);
            descr.number_values = zeros(n_symbols, 1);
            descr.sparsity = zeros(n_symbols, 1);
            switch symtype
            case {gams.transfer.SymbolType.VARIABLE, gams.transfer.SymbolType.EQUATION}
                descr.min_level = zeros(n_symbols, 1);
                descr.mean_level = zeros(n_symbols, 1);
                descr.max_level = zeros(n_symbols, 1);
                descr.where_max_abs_level = cell(n_symbols, 1);
            case gams.transfer.SymbolType.PARAMETER
                descr.min = zeros(n_symbols, 1);
                descr.mean = zeros(n_symbols, 1);
                descr.max = zeros(n_symbols, 1);
                descr.where_min = cell(n_symbols, 1);
                descr.where_max = cell(n_symbols, 1);
            end

            % collect values
            for i = 1:n_symbols
                symbol = symbols{i};

                descr.name{i} = symbol.name;
                if symtype == gams.transfer.SymbolType.VARIABLE || ...
                    symtype == gams.transfer.SymbolType.EQUATION
                    descr.type{i} = symbol.type;
                end
                if symtype == gams.transfer.SymbolType.ALIAS
                    descr.alias_with{i} = symbol.name;
                elseif symtype == gams.transfer.SymbolType.SET
                    descr.is_singleton(i) = symbol.is_singleton;
                end
                descr.format{i} = symbol.format;
                descr.dimension(i) = symbol.dimension;
                descr.domain_type{i} = symbol.domain_type;
                descr.domain{i} = gams.transfer.Utils.list2str(symbol.domain);
                descr.size{i} = gams.transfer.Utils.list2str(symbol.size);
                if isfield(symbol, 'number_records')
                    descr.number_records(i) = symbol.number_records;
                else
                    descr.number_records(i) = symbol.getNumberRecords();
                end
                if isfield(symbol, 'number_values')
                    descr.number_values(i) = symbol.number_values;
                else
                    descr.number_values(i) = symbol.getNumberValues();
                end
                if isfield(symbol, 'sparsity')
                    descr.sparsity(i) = symbol.sparsity;
                else
                    descr.sparsity(i) = symbol.getSparsity();
                end
                switch symtype
                case {gams.transfer.SymbolType.VARIABLE, gams.transfer.SymbolType.EQUATION}
                    descr.min_level(i) = gams.transfer.getMinValue(symbol, obj.indexed, 'level');
                    descr.mean_level(i) = gams.transfer.getMeanValue(symbol, 'level');
                    descr.max_level(i) = gams.transfer.getMaxValue(symbol, obj.indexed, 'level');
                    [absmax, descr.where_max_abs_level{i}] = gams.transfer.getMaxAbsValue(symbol, obj.indexed, 'level');
                    if isnan(absmax)
                        descr.where_max_abs_level{i} = '';
                    else
                        descr.where_max_abs_level{i} = gams.transfer.Utils.list2str(descr.where_max_abs_level{i});
                    end
                case gams.transfer.SymbolType.PARAMETER
                    [descr.min(i), descr.where_min{i}] = gams.transfer.getMinValue(symbol, obj.indexed);
                    if isnan(descr.min(i))
                        descr.where_min{i} = '';
                    else
                        descr.where_min{i} = gams.transfer.Utils.list2str(descr.where_min{i});
                    end
                    descr.mean(i) = gams.transfer.getMeanValue(symbol);
                    [descr.max(i), descr.where_max{i}] = gams.transfer.getMaxValue(symbol, obj.indexed);
                    if isnan(descr.max(i))
                        descr.where_max{i} = '';
                    else
                        descr.where_max{i} = gams.transfer.Utils.list2str(descr.where_max{i});
                    end
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
                case {gams.transfer.SymbolType.VARIABLE, gams.transfer.SymbolType.EQUATION}
                    descr.type = categorical(descr.type);
                    descr.where_max_abs_level = categorical(descr.where_max_abs_level);
                case gams.transfer.SymbolType.PARAMETER
                    descr.where_min = categorical(descr.where_min);
                    descr.where_max = categorical(descr.where_max);
                case gams.transfer.SymbolType.ALIAS
                    descr.alias_with = categorical(descr.alias_with);
                end
            end

            % convert to table if possible
            if obj.features.table
                descr = struct2table(descr);
            end
        end

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
            obj.data = rmfield(obj.data, oldname);
            obj.name_lookup = rmfield(obj.name_lookup, lower(oldname));
            obj.name_lookup.(lower(newname)) = newname;

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
