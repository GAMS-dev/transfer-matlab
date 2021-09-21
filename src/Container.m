classdef Container < handle
    % GAMSTransfer Container stores (multiple) symbols
    %
    % A GAMS GDX file is a collection of GAMS symbols (e.g. variables or
    % parameters), each holding multiple symbol records. In GAMSTransfer the
    % Container is the main object that holds different symbols and allows to
    % read and write those to GDX. There is a fix correspondance to a GDX file,
    % i.e. the file to be read must be given when creating the container and
    % can't be changed thereafter. Hence, it is (currently) not possible to read
    % multiple GDX files into the same container. Simply create multiple
    % containers for each GDX file to be read.
    %
    % When a GDX file is given, the container will read the list of symbols from
    % the GDX files, but no records. This allows to look what is inside the file
    % without reading all data records.
    %
    % Indexed Mode:
    % There are two different modes GAMSTransfer can be used in: indexed or
    % default.
    % - In default mode the main characteristic of a symbol is its domain that
    %   defines the symbol dimension and its dependencies. A size of symbol is
    %   here given by the number of records of the domain sets of each
    %   dimension. In default mode all GAMS symbol types can be used.
    % - In indexed mode, there are no domain sets, but sizes (the shape of a
    %   symbol) can be set explicitly. Furthermore, there are no UELs and only
    %   GAMS Parameters are allowed to be used in indexed mode.
    % The mode is defined when creating a container and can't be changed
    % thereafter.
    %
    % Optional Arguments:
    % 1. filename: string
    %    Path to GDX file to be read
    %
    % Parameter Arguments:
    % - gams_dir: string
    %   Path to GAMS system directory. Default is determined from PATH
    %   environment variable
    % - indexed: logical
    %   Specifies if container is used in indexed of default mode, see above.
    %
    % Example:
    % c = Container();
    % c = Container('path/to/file.gdx');
    % c = Container('indexed', true, 'gams_dir', 'C:\GAMS');
    %
    % See also: GAMSTransfer.Set, GAMSTransfer.Alias, GAMSTransfer.Parameter,
    % GAMSTransfer.Variable, GAMSTransfer.Equation
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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

    properties (SetAccess = private)
        % gams_dir GAMS system directory
        gams_dir = ''

        % filename GDX file name to be read
        filename = ''

        % indexed Flag for indexed mode
        indexed = false

        % data GAMS (GDX) symbols
        data
    end

    properties (Hidden, SetAccess = private)
        id
        reorder_after_add = false
        features
    end

    methods

        function obj = Container(varargin)
            % Constructs a GAMSTransfer Container, see class help.
            %

            obj.id = int32(randi(100000));

            % check support of features
            obj.features = GAMSTransfer.Utils.checkFeatureSupport();

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'gams_dir') && ~strcmpi(x, 'indexed') && ...
                ~strcmpi(x, 'features');
            addOptional(p, 'filename', '', is_string_char);
            addParameter(p, 'gams_dir', '', is_string_char);
            addParameter(p, 'indexed', false, @islogical);
            addParameter(p, 'features', struct(), @isstruct);
            parse(p, varargin{:});
            obj.gams_dir = GAMSTransfer.Utils.checkGamsDirectory(p.Results.gams_dir);
            obj.filename = GAMSTransfer.Utils.checkFilename(p.Results.filename, '.gdx', true);
            obj.indexed = p.Results.indexed;
            feature_names = fieldnames(obj.features);
            for i = 1:numel(feature_names)
                if isfield(p.Results.features, feature_names{i})
                    obj.features.(feature_names{i}) = p.Results.features.(feature_names{i});
                end
            end
            if strcmp(obj.filename, '')
                return
            end

            % read basic GDX information
            obj.readBasic();
        end

    end

    methods

        function read(obj, varargin)
            % Reads symbol records from GDX file
            %
            % Parameter Arguments:
            % - symbols: cell
            %   List of symbols to be read. Default is all.
            % - format: string
            %   Records format symbols should be stored in. Default is table.
            % - values: cell
            %   Subset of {'level', 'marginal', 'lower', 'upper', 'scale'} that
            %   defines what value fields should be read. Default is all.
            %
            % Example:
            % c = Container('path/to/file.gdx');
            % c.read();
            % c.read('format', 'dense_matrix');
            % c.read('symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
            %
            % See also: GAMSTransfer.RecordsFormat
            %

            if strcmp(obj.filename, '')
                warning('GDX file to read has not been specified. No action taken.');
                return
            end

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_values = @(x) iscellstr(x) && numel(x) <= 5;
            if obj.features.table
                def_format = 'table';
            else
                def_format = 'struct';
            end
            addParameter(p, 'symbols', false, @iscellstr);
            addParameter(p, 'format', def_format, is_string_char);
            addParameter(p, 'values', {'level', 'marginal', 'lower', 'upper', 'scale'}, ...
                is_values);
            parse(p, varargin{:});

            % parsing input arguments
            switch p.Results.format
            case {'struct', 'dense_matrix', 'sparse_matrix'}
                format_int = GAMSTransfer.RecordsFormat.str2int(p.Results.format);
            case 'table'
                format_int = GAMSTransfer.RecordsFormat.TABLE;
                if ~obj.features.table
                    warning('Table format is not supported in this Matlab version. Read as struct instead.');
                    format_int = GAMSTransfer.RecordsFormat.STRUCT;
                end
            otherwise
                error('Invalid format option: %s. Choose from: struct, table, dense_matrix, sparse_matrix.', p.Results.format);
            end
            values_bool = false(5,1);
            for e = p.Results.values
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
            if ~iscellstr(p.Results.symbols)
                symbols = fieldnames(obj.data);
            else
                symbols = p.Results.symbols;
            end

            % read records
            if obj.indexed
                GAMSTransfer.gt_idx_read_records(obj.gams_dir, ...
                    obj.filename, obj.data, symbols, int32(format_int));
            else
                GAMSTransfer.gt_gdx_read_records(obj.gams_dir, ...
                    obj.filename, obj.data, symbols, int32(format_int), ...
                    values_bool, obj.features.categorical, obj.features.c_prop_setget);
            end

            % read cache data for C
            if ~obj.indexed && ~obj.features.c_prop_setget
                for i = 1:numel(symbols)
                    if ~isfield(obj.data, symbols{i})
                        continue
                    end
                    symbol = obj.data.(symbols{i});
                    if isa(symbol, 'GAMSTransfer.Alias')
                        continue;
                    end
                    symbol.getCacheUels();
                end
            end

            % check for format of read symbols in case of partial read (done by
            % forced call to isValid). Domains may not be read and may cause
            % invalid symbols.
            if iscellstr(p.Results.symbols)
                for i = 1:numel(symbols)
                    if ~isfield(obj.data, symbols{i})
                        continue
                    end
                    obj.data.(symbols{i}).isValid(false, true);
                end
            end
        end

        function write(obj, varargin)
            % Writes symbols with symbol records to GDX file
            %
            % There are different issues that can occur when writing to GDX:
            % e.g. domain violations and unsorted data. For domain violations,
            % see GAMSTransfer.Container.getDomainViolations. Domain labels are
            % stored as UELs in GDX that are an (ID,label) pair. The ID is a
            % number with an ascending order based on the write occurence. Data
            % records must be sorted by these IDs in ascending order (dimension
            % 1 first, then dimension 2, ...). If one knows that the data is
            % sorted, one can set the flag 'sorted' to true to improve
            % performance. Otherwise GAMSTransfer will sort the values
            % internally. Note, that the case of 'sorted' being true and the
            % data not being sorted will lead to an error.
            %
            % Optional Arguments:
            % 1. filename: string
            %    Path to GDX file to write to. Default is read file.
            %
            % Parameter Arguments:
            % - compress: logical
            %   Flag to compress GDX file (true) or not (false). Default is
            %   false.
            % - sorted: logical
            %   Flag to define records as sorted (true) or not (false). Default
            %   is false.
            % - uel_priority: cellstr
            %   UELs to be registered first before any symbol UELs. Default: {}.
            %
            % Example:
            % c.write();
            % c.write('path/to/file.gdx');
            % c.write('compress', true, 'sorted', true);
            %
            % See also: GAMSTransfer.Container.getDomainViolations
            %

            if ~obj.isValid()
                obj.reorderSymbols();
                if ~obj.isValid()
                    invalid_symbols = GAMSTransfer.Utils.list2str(setdiff(...
                        obj.listSymbols('only_loaded', true), obj.listSymbols(...
                        'only_valid', true, 'only_loaded', true)), '', '');
                    error('Can''t write invalid container. Invalid loaded symbols: %s.', invalid_symbols);
                end
            end

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'compress') && ~strcmpi(x, 'sorted');
            addOptional(p, 'filename', obj.filename, is_string_char);
            addParameter(p, 'compress', false, @islogical);
            addParameter(p, 'sorted', false, @islogical);
            addParameter(p, 'uel_priority', {}, @iscellstr);
            parse(p, varargin{:});

            if p.Results.compress && obj.indexed
                error('Compression not supported for indexed GDX.');
            end

            % get full path
            filename = GAMSTransfer.Utils.checkFilename(...
                char(p.Results.filename), '.gdx', false);

            % cache data for C
            if ~obj.indexed && ~obj.features.c_prop_setget
                symbols = fieldnames(obj.data);
                for i = 1:numel(symbols)
                    symbol = obj.data.(symbols{i});
                    if isa(symbol, 'GAMSTransfer.Alias')
                        continue;
                    end
                    symbol.setCacheUels();
                end
            end

            % write data
            if obj.indexed
                GAMSTransfer.gt_idx_write(obj.gams_dir, filename, obj.data, ...
                    p.Results.sorted, obj.features.table);
            else
                GAMSTransfer.gt_gdx_write(obj.gams_dir, filename, obj.data, ...
                    p.Results.uel_priority, p.Results.compress, p.Results.sorted, ...
                    obj.features.table, obj.features.categorical, obj.features.c_prop_setget);
            end
        end

        function symbols = getSymbols(obj, names)
            % Get symbol objects by names
            %
            % s = c.getSymbols(a) returns the handle to GAMS symbol named a.
            % s = c.getSymbols(b) returns a list of handles to the GAMS symbols
            % with names equal to any element in cell b.
            %
            % Example:
            % v1 = c.getSymbols('v1');
            % vars = c.getSymbols(c.listVariables());
            %

            if ischar(names) || isstring(names)
                symbols = obj.data.(names);
                return
            elseif ~iscellstr(names)
                error('Name must be of type ''char'' or ''cellstr''.');
            end
            n = numel(names);
            symbols = cell(size(names));
            for i = 1:n
                symbols{i} = obj.data.(names{i});
            end
        end

        function symbol = addSet(obj, name, varargin)
            % Adds a set to the container
            %
            % Arguments are identical to the GAMSTransfer.Set constructor.
            % Alternatively, use the constructor directly.
            %
            % Example:
            % c = Container();
            % s1 = c.addSet('s1');
            % s2 = c.addSet('s2', {s1, '*', '*'});
            % s3 = c.addSet('s3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
            %
            % See also: GAMSTransfer.Set
            %

            symbol = GAMSTransfer.Set(obj, name, varargin{:});
        end

        function symbol = addParameter(obj, name, varargin)
            % Adds a parameter to the container
            %
            % Arguments are identical to the GAMSTransfer.Parameter constructor.
            % Alternatively, use the constructor directly.
            %
            % Example:
            % c = Container();
            % p1 = c.addParameter('p1');
            % p2 = c.addParameter('p2', {'*', '*'});
            % p3 = c.addParameter('p3', '*', 'description', 'par p3');
            %
            % See also: GAMSTransfer.Parameter
            %

            symbol = GAMSTransfer.Parameter(obj, name, varargin{:});
        end

        function symbol = addVariable(obj, name, varargin)
            % Adds a variable to the container
            %
            % Arguments are identical to the GAMSTransfer.Variable constructor.
            % Alternatively, use the constructor directly.
            %
            % Example:
            % c = Container();
            % v1 = c.addVariable('v1');
            % v2 = c.addVariable('v2', 'binary', {'*', '*'});
            % v3 = c.addVariable('v3', VariableType.BINARY, '*', 'description', 'var v3');
            %
            % See also: GAMSTransfer.Variable, GAMSTransfer.VariableType
            %

            symbol = GAMSTransfer.Variable(obj, name, varargin{:});
        end

        function symbol = addEquation(obj, name, etype, varargin)
            % Adds an equation to the container
            %
            % Arguments are identical to the GAMSTransfer.Equation constructor.
            % Alternatively, use the constructor directly.
            %
            % Example:
            % c = Container();
            % e2 = c.addEquation('e2', 'l', {'*', '*'});
            % e3 = c.addEquation('e3', EquationType.EQ, '*', 'description', 'equ e3');
            %
            % See also: GAMSTransfer.Equation, GAMSTransfer.EquationType
            %

            symbol = GAMSTransfer.Equation(obj, name, etype, varargin{:});
        end

        function symbol = addAlias(obj, name, alias_with, varargin)
            % Adds an alias to the container
            %
            % Arguments are identical to the GAMSTransfer.Alias constructor.
            % Alternatively, use the constructor directly.
            %
            % Example:
            % c = Container();
            % s = c.addSet('s');
            % a = c.addAlias('a', s);
            %
            % See also: GAMSTransfer.Alias, GAMSTransfer.Set
            %

            symbol = GAMSTransfer.Alias(obj, name, alias_with, varargin{:});
        end

        function renameSymbol(obj, oldname, newname)
            % Rename a symbol
            %
            % renameSymbol(oldname, newname) renames the symbol with name
            % oldname to newname. The symbol order in data will not change.
            %
            % Example:
            % c.renameSymbol('x', 'xx');
            %

            if strcmp(oldname, newname)
                return
            end

            % get index of symbol
            names = fieldnames(obj.data);
            idx = find(strcmp(names, oldname));
            if isempty(idx)
                return
            end

            % change name in symbol
            obj.data.(oldname).name_ = char(newname);

            % add new symbol / remove old symbol
            obj.data.(newname) = obj.data.(oldname);
            obj.data = rmfield(obj.data, oldname);

            % get old ordering
            perm = [1:idx-1, numel(names), idx:numel(names)-1];
            obj.data = orderfields(obj.data, perm);
        end

        function removeSymbols(obj, names)
            % Removes a symbol from container
            %

            if isstring(names) || ischar(names)
                names = {names};
            end

            for i = 1:numel(names)
                if ~isfield(obj.data, names{i})
                    continue;
                end

                symbol = obj.data.(names{i});

                % remove symbol
                obj.data = rmfield(obj.data, names{i});

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                symbol.isValid(false, true);
            end

            % force recheck of all remaining symbols in container
            obj.isValid(false, true);
        end

        function reorderSymbols(obj)
            % Reestablishes a valid GDX symbol order
            %

            names = fieldnames(obj.data);

            % get number of
            n = zeros(1, 5);
            for i = 1:numel(names)
                symbol = obj.data.(names{i});
                if isa(symbol, 'GAMSTransfer.Set')
                    n(1) = n(1) + 1;
                elseif isa(symbol, 'GAMSTransfer.Parameter')
                    n(2) = n(2) + 1;
                elseif isa(symbol, 'GAMSTransfer.Variable')
                    n(3) = n(3) + 1;
                elseif isa(symbol, 'GAMSTransfer.Equation')
                    n(4) = n(4) + 1;
                elseif isa(symbol, 'GAMSTransfer.Alias')
                    n(5) = n(5) + 1;
                else
                    error('Invalid symbol type');
                end
            end

            sets = cell(1, n(1));
            idx_sets = zeros(1, n(1));
            idx_pars = zeros(1, n(2));
            idx_vars = zeros(1, n(3));
            idx_equs = zeros(1, n(4));
            idx_alis = zeros(1, n(5));
            n = zeros(1, 5);

            % get index by type
            for i = 1:numel(names)
                symbol = obj.data.(names{i});
                if isa(symbol, 'GAMSTransfer.Set')
                    n(1) = n(1) + 1;
                    idx_sets(n(1)) = i;
                    sets{n(1)} = symbol;
                elseif isa(symbol, 'GAMSTransfer.Parameter')
                    n(2) = n(2) + 1;
                    idx_pars(n(2)) = i;
                elseif isa(symbol, 'GAMSTransfer.Variable')
                    n(3) = n(3) + 1;
                    idx_vars(n(3)) = i;
                elseif isa(symbol, 'GAMSTransfer.Equation')
                    n(4) = n(4) + 1;
                    idx_equs(n(4)) = i;
                elseif isa(symbol, 'GAMSTransfer.Alias')
                    n(5) = n(5) + 1;
                    idx_alis(n(5)) = i;
                else
                    error('Invalid symbol type');
                end
            end

            % handle set dependencies
            if n(1) > 1
                n_handled = 0;
                set_handled = containers.Map(obj.listSets(), false(1, n(1)));
                set_avail = true(1, n(1));

                while n_handled < n(1)
                    % check if we can add the next set
                    curr_is_next = true;
                    current_set = sets{n_handled+1};
                    for i = 1:current_set.dimension
                        if isa(current_set.domain{i}, 'GAMSTransfer.Set') && ...
                            ~set_handled(current_set.domain{i}.name)
                            curr_is_next = false;
                            break;
                        end
                    end
                    set_avail(n_handled+1) = false;
                    if curr_is_next
                        n_handled = n_handled + 1;
                        set_handled(current_set.name) = true;
                        set_avail(n_handled+1:end) = true;
                        continue;
                    end

                    % find next available
                    next_avail = find(set_avail(n_handled+1:end), 1);
                    if isempty(next_avail)
                        l = GAMSTransfer.Utils.list2str(sets(n_handled+1:end));
                        error('Circular domain set dependency in: %s.', l);
                    end
                    next_avail = next_avail + n_handled;
                    tmp = sets{next_avail};
                    sets(n_handled+2:next_avail) = sets(n_handled+1:next_avail-1);
                    sets{n_handled+1} = tmp;
                    tmp = idx_sets(next_avail);
                    idx_sets(n_handled+2:next_avail) = idx_sets(n_handled+1:next_avail-1);
                    idx_sets(n_handled+1) = tmp;
                    tmp = set_avail(next_avail);
                    set_avail(n_handled+2:next_avail) = set_avail(n_handled+1:next_avail-1);
                    set_avail(n_handled+1) = tmp;
                end
            end

            % apply permutation
            perm = [idx_sets, idx_alis, idx_pars, idx_vars, idx_equs];
            obj.data = orderfields(obj.data, perm);

            % force recheck of all remaining symbols in container
            obj.isValid(false, true);
        end

        function list = listSymbols(obj, varargin)
            % Lists all symbols in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSets,
            % GAMSTransfer.Container.listParameters,
            % GAMSTransfer.Container.listVariables,
            % GAMSTransfer.Container.listEquations,
            % GAMSTransfer.Container.listAliases
            %

            p = inputParser();
            addParameter(p, 'only_types', [], @isnumeric);
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});
            only_types = p.Results.only_types;
            only_loaded = p.Results.only_loaded;
            only_valid = p.Results.only_valid;

            names = fieldnames(obj.data);
            if isempty(only_types) && ~only_loaded && ~only_valid
                list = names;
                return
            end

            % count matched symbols
            for k = 1:2
                n = 0;
                for i = 1:numel(names)
                    symbol = obj.data.(names{i});

                    % check type
                    matched_type = isempty(only_types);
                    for j = 1:numel(only_types)
                        switch only_types(j)
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
                        if matched_type
                            break;
                        end
                    end
                    if ~matched_type
                        continue
                    end

                    % check loaded
                    if only_loaded && ~isa(symbol, 'GAMSTransfer.Alias') && ...
                        ~isnan(symbol.read_entry) && ...
                        symbol.format_ == GAMSTransfer.RecordsFormat.NOT_READ
                        continue
                    end

                    % check invalid
                    if only_valid && ~symbol.isValid()
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

        function list = listSets(obj, varargin)
            % Lists all sets in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSymbols,
            % GAMSTransfer.Container.listParameters,
            % GAMSTransfer.Container.listVariables,
            % GAMSTransfer.Container.listEquations,
            % GAMSTransfer.Container.listAliases
            %

            p = inputParser();
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});

            list = obj.listSymbols('only_types', [GAMSTransfer.SymbolType.SET, ...
                GAMSTransfer.SymbolType.ALIAS], 'only_loaded', p.Results.only_loaded, ...
                'only_valid', p.Results.only_valid);
        end

        function list = listParameters(obj, varargin)
            % Lists all parameters in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSymbols,
            % GAMSTransfer.Container.listSets,
            % GAMSTransfer.Container.listVariables,
            % GAMSTransfer.Container.listEquations,
            % GAMSTransfer.Container.listAliases
            %

            p = inputParser();
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});

            list = obj.listSymbols('only_types', GAMSTransfer.SymbolType.PARAMETER, ...
                'only_loaded', p.Results.only_loaded, 'only_valid', ...
                p.Results.only_valid);
        end

        function list = listVariables(obj, varargin)
            % Lists all variables in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSymbols,
            % GAMSTransfer.Container.listSets,
            % GAMSTransfer.Container.listParameters,
            % GAMSTransfer.Container.listEquations,
            % GAMSTransfer.Container.listAliases
            %

            p = inputParser();
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});

            list = obj.listSymbols('only_types', GAMSTransfer.SymbolType.VARIABLE, ...
                'only_loaded', p.Results.only_loaded, 'only_valid', ...
                p.Results.only_valid);
        end

        function list = listEquations(obj, varargin)
            % Lists all equations in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSymbols,
            % GAMSTransfer.Container.listSets,
            % GAMSTransfer.Container.listParameters,
            % GAMSTransfer.Container.listVariables,
            % GAMSTransfer.Container.listAliases
            %

            p = inputParser();
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});

            list = obj.listSymbols('only_types', GAMSTransfer.SymbolType.EQUATION, ...
                'only_loaded', p.Results.only_loaded, 'only_valid', ...
                p.Results.only_valid);
        end

        function list = listAliases(obj, varargin)
            % Lists all aliases in container
            %
            % Parameter Arguments:
            % - only_loaded: logical
            %   Only include symbols with records loaded from GDX or added
            %   through interface. Default: false.
            % - only_valid: logical
            %   Only include symbols that are valid. Default: false.
            %
            % See also: GAMSTransfer.Container.listSymbols,
            % GAMSTransfer.Container.listSets,
            % GAMSTransfer.Container.listParameters,
            % GAMSTransfer.Container.listVariables,
            % GAMSTransfer.Container.listEquations,
            %

            p = inputParser();
            addParameter(p, 'only_loaded', false, @islogical);
            addParameter(p, 'only_valid', false, @islogical);
            parse(p, varargin{:});

            list = obj.listSymbols('only_types', GAMSTransfer.SymbolType.ALIAS, ...
                'only_loaded', p.Results.only_loaded, 'only_valid', ...
                p.Results.only_valid);
        end

        function descr = describeSets(obj)
            % Returns an overview over all sets in container
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.
            %

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.SET);
        end

        function descr = describeParameters(obj)
            % Returns an overview over all parameters in container
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.
            %

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.PARAMETER);
        end

        function descr = describeVariables(obj)
            % Returns an overview over all variables in container
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.
            %

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.VARIABLE);
        end

        function descr = describeEquations(obj)
            % Returns an overview over all equations in container
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.
            %

            descr = obj.describeSymbols(GAMSTransfer.SymbolType.EQUATION);
        end

        function descr = describeAliases(obj)
            % Returns an overview over all aliases in container
            %
            % The overview is in form of a table listing for each symbol its
            % main characteristics and some statistics.
            %

            symbols = obj.listAliases();
            n_symbols = numel(symbols);

            % init describe table
            descr = struct();
            descr.name = cell(n_symbols, 1);
            descr.alias_with = cell(n_symbols, 1);

            % collect values
            for i = 1:n_symbols
                symbol = obj.data.(symbols{i});
                descr.name{i} = symbol.name;
                descr.alias_with{i} = symbol.alias_with.name;
            end

            % convert to categorical if possible
            if obj.features.categorical
                descr.name = categorical(descr.name);
                descr.alias_with = categorical(descr.alias_with);
            end

            % convert to table if possible
            if obj.features.table
                descr = struct2table(descr);
            end
        end

        function dom_violations = getDomainViolations(obj)
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
            % See also: GAMSTransfer.Container.resovleDomainViolations,
            % GAMSTransfer.Symbol.getDomainViolations, GAMSTransfer.DomainViolation
            %

            dom_violations = {};

            symbols = fieldnames(obj.data);
            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                if isa(symbol, 'GAMSTransfer.Alias')
                    continue
                end

                dom_violations_sym = symbol.getDomainViolations();
                dom_violations(end+1:end+numel(dom_violations_sym)) = dom_violations_sym;
            end
        end

        function resolveDomainViolations(obj)
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
            % See also: GAMSTransfer.Container.getDomainViolations,
            % GAMSTransfer.Symbol.resovleDomainViolations, GAMSTransfer.DomainViolation
            %

            dom_violations = obj.getDomainViolations();
            for i = 1:numel(dom_violations)
                dom_violations{i}.resolve();
            end
        end

        function list = getUniverseSet(obj)
            % Generate universe set (UEL order in GDX)
            %

            map = javaObject('java.util.LinkedHashMap');

            % collect uels
            symbols = fieldnames(obj.data);
            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                for j = 1:symbol.dimension
                    uels = symbol.getUELs(j);
                    for k = 1:numel(uels)
                        map.put(uels{k}, true);
                    end
                end
            end

            % get list of keys
            list = cell(1, map.keySet().size());
            it = map.keySet().iterator();
            i = 1;
            while it.hasNext()
                list{i} = char(it.next());
                i = i + 1;
            end
        end

        function valid = isValid(obj, varargin)
            % Checks correctness of all symbols
            %
            % Note: Not yet read symbols will be ignored.
            %
            % Optional Arguments:
            % 1. verbose: logical
            %    If true, the reason for an invalid symbol is printed
            % 2. force: logical
            %    If true, forces reevaluation of validity (resets cache)
            %
            %
            % See also: GAMSTransfer.Symbol/isValid
            %

            verbose = false;
            force = false;
            if nargin > 1 && varargin{1}
                verbose = true;
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            valid = true;
            symbols = fieldnames(obj.data);
            for i = 1:numel(symbols)
                symbol = obj.data.(symbols{i});
                if symbol.isValid(verbose, force)
                    continue
                end
                if ~isa(symbol, 'GAMSTransfer.Alias') && ...
                    symbol.format_ == GAMSTransfer.RecordsFormat.NOT_READ
                    continue
                end
                valid = false;
                if ~force
                    return
                end
            end
        end

    end

    methods (Hidden, Access = {?GAMSTransfer.Symbol, ?GAMSTransfer.Alias})

        function add(obj, symbol)
            if obj.indexed && ~isa(symbol, 'GAMSTransfer.Parameter')
                error('Symbol must be of type ''GAMSTransfer.Parameter'' in indexed mode.');
            end
            if isfield(obj.data, symbol.name_)
                error('Symbol ''%s'' exists already.', symbol.name);
            end
            obj.data.(symbol.name_) = symbol;

            % reorder symbols
            if obj.reorder_after_add && ~obj.isValid()
                obj.reorderSymbols();
            end
        end

    end

    methods (Hidden, Access = private)

        function descr = describeSymbols(obj, symtype)
            switch symtype
            case GAMSTransfer.SymbolType.SET
                symbol_names = obj.listSets();
                symbols = obj.getSymbols(symbol_names);
            case GAMSTransfer.SymbolType.PARAMETER
                symbol_names = obj.listParameters();
                symbols = obj.getSymbols(symbol_names);
            case GAMSTransfer.SymbolType.VARIABLE
                symbol_names = obj.listVariables();
                symbols = obj.getSymbols(symbol_names);
            case GAMSTransfer.SymbolType.EQUATION
                symbol_names = obj.listEquations();
                symbols = obj.getSymbols(symbol_names);
            otherwise
                error('Invalid symbol type');
            end
            n_symbols = numel(symbols);

            % init describe table
            descr = struct();
            descr.name = cell(n_symbols, 1);
            switch symtype
            case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                descr.type = cell(n_symbols, 1);
            case GAMSTransfer.SymbolType.SET
                descr.is_alias = true(n_symbols, 1);
                descr.is_singleton = true(n_symbols, 1);
            end
            descr.format = cell(n_symbols, 1);
            descr.dim = zeros(n_symbols, 1);
            descr.domain_info = cell(n_symbols, 1);
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

                descr.name{i} = symbol_names{i};
                switch symtype
                case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                    descr.type{i} = symbol.type;
                case GAMSTransfer.SymbolType.SET
                    descr.is_alias(i) = isa(symbol, 'GAMSTransfer.Alias');
                    descr.is_singleton(i) = symbol.is_singleton;
                end
                descr.format{i} = symbol.format;
                descr.dim(i) = symbol.dimension;
                descr.domain_info{i} = symbol.domain_info;
                descr.domain{i} = GAMSTransfer.Utils.list2str(symbol.domain);
                descr.size{i} = GAMSTransfer.Utils.list2str(symbol.size);
                descr.num_recs(i) = symbol.getNumberRecords();
                descr.num_vals(i) = symbol.getNumberValues();
                descr.sparsity(i) = symbol.getSparsity();
                switch symtype
                case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                    descr.min_level(i) = symbol.getMinValue('level');
                    descr.mean_level(i) = symbol.getMeanValue('level');
                    descr.max_level(i) = symbol.getMaxValue('level');
                    [absmax, descr.where_max_abs_level{i}] = symbol.getMaxAbsValue('level');
                    if isnan(absmax)
                        descr.where_max_abs_level{i} = '';
                    else
                        descr.where_max_abs_level{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_level{i});
                    end
                    descr.count_na_level(i) = symbol.countNa({'level'});
                    descr.count_undef_level(i) = symbol.countUndef({'level'});
                    descr.count_eps_level(i) = symbol.countEps({'level'});
                    descr.min_marginal(i) = symbol.getMinValue('marginal');
                    descr.mean_marginal(i) = symbol.getMeanValue('marginal');
                    descr.max_marginal(i) = symbol.getMaxValue('marginal');
                    [absmax, descr.where_max_abs_marginal{i}] = symbol.getMaxAbsValue('marginal');
                    if isnan(absmax)
                        descr.where_max_abs_marginal{i} = '';
                    else
                        descr.where_max_abs_marginal{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_marginal{i});
                    end
                    descr.count_na_marginal(i) = symbol.countNa({'marginal'});
                    descr.count_undef_marginal(i) = symbol.countUndef({'marginal'});
                    descr.count_eps_marginal(i) = symbol.countEps({'marginal'});
                case GAMSTransfer.SymbolType.PARAMETER
                    descr.min_value(i) = symbol.getMinValue();
                    descr.mean_value(i) = symbol.getMeanValue();
                    descr.max_value(i) = symbol.getMaxValue();
                    [absmax, descr.where_max_abs_value{i}] = symbol.getMaxAbsValue();
                    if isnan(absmax)
                        descr.where_max_abs_value{i} = '';
                    else
                        descr.where_max_abs_value{i} = GAMSTransfer.Utils.list2str(descr.where_max_abs_value{i});
                    end
                    descr.count_na(i) = symbol.countNa();
                    descr.count_undef(i) = symbol.countUndef();
                    descr.count_eps(i) = symbol.countEps();
                end
            end

            % convert to categorical if possible
            if obj.features.categorical
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                descr.domain_info = categorical(descr.domain_info);
                descr.domain = categorical(descr.domain);
                descr.size = categorical(descr.size);
                switch symtype
                case {GAMSTransfer.SymbolType.VARIABLE, GAMSTransfer.SymbolType.EQUATION}
                    descr.type = categorical(descr.type);
                    descr.where_max_abs_level = categorical(descr.where_max_abs_level);
                    descr.where_max_abs_marginal = categorical(descr.where_max_abs_marginal);
                case GAMSTransfer.SymbolType.PARAMETER
                    descr.where_max_abs_value = categorical(descr.where_max_abs_value);
                end
            end

            % convert to table if possible
            if obj.features.table
                descr = struct2table(descr);
            end
        end

        function readBasic(obj)
            % read data from GDX
            if obj.indexed
                rawdata = GAMSTransfer.gt_idx_read_basics(obj.gams_dir, obj.filename);
            else
                rawdata = GAMSTransfer.gt_gdx_read_basics(obj.gams_dir, obj.filename);
            end
            symbols = fieldnames(rawdata);

            % turn off to reorder symbols after an addition
            initial_reorder_after_add = obj.reorder_after_add;
            obj.reorder_after_add = false;

            % transform data into Symbol object
            for i = 1:numel(symbols)
                symbol = rawdata.(symbols{i});

                % create cross-referenced domain if possible
                if obj.indexed
                    domain = symbol.size;
                else
                    domain = symbol.domain;
                    for j = 1:numel(domain)
                        if strcmp(domain{j}, '*')
                            continue
                        elseif symbol.domain_info == 2
                            continue
                        elseif isfield(obj.data, domain{j})
                            domain{j} = obj.data.(domain{j});
                        else
                            error('Domain %s is not available.', domain{j});
                        end
                    end
                end

                % convert symbol to GDXSymbol
                switch symbol.type
                case GAMSTransfer.SymbolType.SET
                    obj.data.(symbols{i}) = GAMSTransfer.Set(obj, symbol.name, ...
                        domain, 'description', symbol.description, 'read_entry', i, ...
                        'read_number_records', double(symbol.number_records), ...
                        'is_singleton', symbol.subtype == 1);
                case GAMSTransfer.SymbolType.PARAMETER
                    obj.data.(symbols{i}) = GAMSTransfer.Parameter(obj, symbol.name, ...
                        domain, 'description', symbol.description, 'read_entry', i, ...
                        'read_number_records', double(symbol.number_records));
                case GAMSTransfer.SymbolType.VARIABLE
                    obj.data.(symbols{i}) = GAMSTransfer.Variable(obj, symbol.name, ...
                        symbol.subtype, domain, 'description', symbol.description, ...
                        'read_entry', i, 'read_number_records', double(symbol.number_records));
                case GAMSTransfer.SymbolType.EQUATION
                    obj.data.(symbols{i}) = GAMSTransfer.Equation(obj, symbol.name, ...
                        symbol.subtype, domain, 'description', symbol.description, ...
                        'read_entry', i, 'read_number_records', double(symbol.number_records));
                case GAMSTransfer.SymbolType.ALIAS
                    alias_with = regexp(symbol.description, '(?<=Aliased with )[a-zA-Z]*', 'match');
                    if numel(alias_with) ~= 1 || ~isfield(obj.data, alias_with{1})
                        error('Alias reference for symbol ''%s'' not found: %s.', ...
                            symbol.name, symbol.description);
                    end
                    obj.data.(symbols{i}) = GAMSTransfer.Alias(obj, symbol.name, ...
                        obj.data.(alias_with{1}), 'read_entry', i);
                otherwise
                    error('Invalid symbol type');
                end
            end

            % reset reorder after addition
            obj.reorder_after_add = initial_reorder_after_add;
        end

    end

end
