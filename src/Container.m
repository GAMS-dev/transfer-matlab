classdef Container < GAMSTransfer.BaseContainer
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

    methods

        function obj = Container(varargin)
            % Constructs a GAMSTransfer Container, see class help.
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'gams_dir') && ~strcmpi(x, 'indexed') && ...
                ~strcmpi(x, 'features');
            is_source = @(x) is_string_char(x) || isa(x, 'GAMSTransfer.ConstContainer');
            addOptional(p, 'source', '', is_source);
            addParameter(p, 'gams_dir', '', is_string_char);
            addParameter(p, 'indexed', false, @islogical);
            addParameter(p, 'features', struct(), @isstruct);
            parse(p, varargin{:});

            obj = obj@GAMSTransfer.BaseContainer(p.Results.gams_dir, ...
                p.Results.indexed, p.Results.features);

            % read GDX file
            if ~strcmp(p.Results.source, '')
                obj.read(p.Results.source);
            end
        end

    end

    methods

        function read(obj, varargin)
            % Reads symbol records from GDX file
            %
            % Required Arguments:
            % 1. filename: string
            %    Path to GDX file to be read
            %
            % Parameter Arguments:
            % - symbols: cell
            %   List of symbols to be read. All if empty. Default is {}.
            % - format: string
            %   Records format symbols should be stored in. Default is table.
            % - records: bool
            %   Enables reading of records. Default is true.
            % - values: cell
            %   Subset of {'level', 'marginal', 'lower', 'upper', 'scale'} that
            %   defines what value fields should be read. Default is all.
            %
            % Example:
            % c = Container();
            % c.read('path/to/file.gdx');
            % c.read('path/to/file.gdx', 'format', 'dense_matrix');
            % c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
            %
            % See also: GAMSTransfer.RecordsFormat
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_source = @(x) is_string_char(x) || isa(x, 'GAMSTransfer.ConstContainer');
            is_values = @(x) iscellstr(x) && numel(x) <= 5;
            addRequired(p, 'source', is_source);
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'format', 'table', is_string_char);
            addParameter(p, 'records', true, @islogical);
            addParameter(p, 'values', {'level', 'marginal', 'lower', 'upper', 'scale'}, ...
                is_values);
            parse(p, varargin{:});

            % read raw data
            if isa(p.Results.source, 'GAMSTransfer.ConstContainer')
                if p.Results.source.indexed ~= obj.indexed
                    error('Indexed flags of source and this container must match.');
                end
                data = struct();
                source_data = p.Results.source.data;
                symbols = p.Results.symbols;
                if isempty(symbols)
                    data = source_data;
                else
                    for i = 1:numel(symbols)
                        data.(symbols{i}) = source_data.(symbols{i});
                    end
                end
            else
                data = obj.readRaw(p.Results.source, p.Results.symbols, ...
                    p.Results.format, p.Results.records, p.Results.values);
            end
            symbols = fieldnames(data);
            is_partial_read = numel(p.Results.symbols) > 0;

            % transform data into Symbol object
            for i = 1:numel(symbols)
                symbol = data.(symbols{i});

                % handle alias differently
                switch symbol.symbol_type
                case {GAMSTransfer.SymbolType.ALIAS, 'alias'}
                    if ~isfield(obj.data, symbol.alias_with)
                        error('Alias reference for symbol ''%s'' not found: %s.', ...
                            symbol.name, symbol.description);
                    end
                    GAMSTransfer.Alias(obj, symbol.name, obj.data.(symbol.alias_with));
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
                        elseif isfield(obj.data, domain{j}) && isfield(data, domain{j})
                            domain{j} = obj.data.(domain{j});
                        end
                    end
                end

                % convert symbol to GDXSymbol
                switch symbol.symbol_type
                case {GAMSTransfer.SymbolType.SET, 'set'}
                    GAMSTransfer.Set(obj, symbol.name, domain, 'description', ...
                        symbol.description, 'is_singleton', symbol.is_singleton);
                case {GAMSTransfer.SymbolType.PARAMETER, 'parameter'}
                    GAMSTransfer.Parameter(obj, symbol.name, domain, 'description', ...
                        symbol.description);
                case {GAMSTransfer.SymbolType.VARIABLE, 'variable'}
                    GAMSTransfer.Variable(obj, symbol.name, symbol.type, domain, ...
                        'description', symbol.description);
                case {GAMSTransfer.SymbolType.EQUATION, 'equation'}
                    GAMSTransfer.Equation(obj, symbol.name, symbol.type, domain, ...
                        'description', symbol.description);
                otherwise
                    error('Invalid symbol type');
                end

                % set records and store format (no need to call isValid to
                % detect the format because at this point, we know it)
                obj.data.(symbol.name).records = symbol.records;
                if isnumeric(symbol.format)
                    obj.data.(symbol.name).format_ = symbol.format;
                else
                    obj.data.(symbol.name).format_ = GAMSTransfer.RecordsFormat.str2int(symbol.format);
                end

                % set uels
                if isfield(symbol, 'uels') && ~obj.features.categorical && ...
                    symbol.format ~= GAMSTransfer.RecordsFormat.DENSE_MATRIX && ...
                    symbol.format ~= GAMSTransfer.RecordsFormat.SPARSE_MATRIX && ...
                    ~strcmp(symbol.format, 'dense_matrix') && ~strcmp(symbol.format, 'sparse_matrix')
                    for j = 1:numel(symbol.domain)
                        if isempty(symbol.uels{j})
                            continue
                        end
                        obj.data.(symbol.name).initUELs(j, symbol.uels{j});
                    end
                end
            end

            % check for format of read symbols in case of partial read (done by
            % forced call to isValid). Domains may not be read and may cause
            % invalid symbols.
            if is_partial_read
                for j = 1:numel(symbols)
                    if ~isfield(obj.data, symbols{j})
                        continue
                    end
                    obj.data.(symbols{j}).isValid(false, true);
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
            % Required Arguments:
            % 1. filename: string
            %    Path to GDX file to write to.
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
            % c.write('path/to/file.gdx');
            % c.write('path/to/file.gdx', 'compress', true, 'sorted', true);
            %
            % See also: GAMSTransfer.Container.getDomainViolations
            %

            if ~obj.isValid()
                obj.reorderSymbols();
                if ~obj.isValid()
                    invalid_symbols = GAMSTransfer.Utils.list2str(...
                        obj.listSymbols('is_valid', false));
                    error('Can''t write invalid container. Invalid symbols: %s.', invalid_symbols);
                end
            end

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'compress') && ~strcmpi(x, 'sorted');
            addRequired(p, 'filename', is_string_char);
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

            % write data
            if obj.indexed
                GAMSTransfer.gt_cmex_idx_write(obj.gams_dir, filename, obj.data, ...
                    p.Results.sorted, obj.features.table);
            else
                GAMSTransfer.gt_cmex_gdx_write(obj.gams_dir, filename, obj.data, ...
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

        function symbol = addAlias(obj, name, alias_with)
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

            symbol = GAMSTransfer.Alias(obj, name, alias_with);
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

            % get number of set/alias
            n_sets = 0;
            for i = 1:numel(names)
                symbol = obj.data.(names{i});
                if isa(symbol, 'GAMSTransfer.Set') || isa(symbol, 'GAMSTransfer.Alias')
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
                if isa(symbol, 'GAMSTransfer.Set') || isa(symbol, 'GAMSTransfer.Alias')
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
                        if (isa(current_set.domain{i}, 'GAMSTransfer.Set') || ...
                            isa(current_set.domain{i}, 'GAMSTransfer.Alias')) && ...
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
                        l = GAMSTransfer.Utils.list2str(sets(idx(n_handled+1:end)));
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
                error('Symbol ''%s'' already exists.', symbol.name);
            end
            obj.data.(symbol.name_) = symbol;
        end

    end

end
