% GAMS Transfer Container stores (multiple) symbols
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
% GAMS Transfer Container stores (multiple) symbols
%
% A GAMS GDX file is a collection of GAMS symbols (e.g. variables or
% parameters), each holding multiple symbol records. In GAMS Transfer the
% Container is the main object that holds different symbols and allows to read
% and write those to GDX.
%
% Optional Arguments:
% 1. source (string or Container):
%    Path to GDX file or a Container object to be read
%
% Parameter Arguments:
% - gams_dir (string):
%   Path to GAMS system directory. Default is determined from PATH environment
%   variable
%
% Example:
% c = Container();
% c = Container('path/to/file.gdx');
% c = Container('gams_dir', 'C:\GAMS');
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
%> **Example:**
%> ```
%> c = Container();
%> c = Container('path/to/file.gdx');
%> c = Container('gams_dir', 'C:\GAMS');
%> ```
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Alias "Alias", \ref
%> gams::transfer::Parameter "Parameter", \ref gams::transfer::Variable "Variable",
%> \ref gams::transfer::Equation "Equation"
classdef Container < handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        gams_dir_ = ''
        modified_ = true
        data_
    end

    properties (Dependent, SetAccess = protected)
        %> GAMS system directory

        % gams_dir GAMS system directory
        gams_dir


        %> GAMS (GDX) symbols

        % data GAMS (GDX) symbols
        data
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

    methods

        function gams_dir = get.gams_dir(obj)
            gams_dir = obj.gams_dir_;
        end

        function data = get.data(obj)
            data = obj.data_.entries_;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
            if modified
                return
            end
            symbols = obj.data_.entries();
            for i = 1:numel(symbols)
                if modified
                    return
                end
                modified = modified || symbols{i}.modified;
            end
        end

        function set.modified(obj, modified)
            gams.transfer.utils.Validator('modified', 1, modified).type('logical').scalar();
            symbols = obj.data_.entries();
            for i = 1:numel(symbols)
                symbols{i}.modified = modified;
            end
            obj.modified_ = modified;
        end

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
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> c = Container('path/to/file.gdx');
        %> c = Container('gams_dir', 'C:\GAMS');
        %> ```
        %>
        %> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Alias "Alias", \ref
        %> gams::transfer::Parameter "Parameter", \ref gams::transfer::Variable "Variable",
        %> \ref gams::transfer::Equation "Equation", \ref gams::transfer::Container
        %> "Container"
        function obj = Container(varargin)
            % Constructs a GAMS Transfer Container, see class help

            obj.data_ = gams.transfer.incase_ordered_dict.Struct();

            % parse input arguments
            has_gams_dir = false;
            has_source = false;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'gams_dir')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        gams_dir = gams.transfer.utils.Validator('gams_dir', index, varargin{index})...
                            .string2char().type('char').value;
                        if ~isfile(fullfile(gams_dir, gams.transfer.Constants.GDX_LIBRARY_NAME))
                            error('Argument ''gams_dir'' (at position %d) does not contain a path to the GDX library.', index);
                        end
                        has_gams_dir = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'indexed')
                        warning('Setting argument ''indexed'' for the Container has no effect anymore. Use it in the ''read'' and/or ''write'' method.');
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        source = gams.transfer.utils.Validator('source', index, varargin{index}) ...
                            .types({'gams.transfer.Container', 'string', 'char'}).value;
                        has_source = true;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % find GDX directory from PATH if not given
            if ~has_gams_dir
                obj.gams_dir_ = gams.transfer.utils.find_gdx();
            end

            % read GDX file
            if has_source
                obj.read(source);
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
            if ~isequal(class(obj), class(container)) || ...
                ~isequal(obj.gams_dir_, container.gams_dir)
                return
            end
            symbols1 = obj.getSymbols();
            symbols2 = container.getSymbols();
            if numel(symbols1) ~= numel(symbols2)
                return
            end
            for i = 1:numel(symbols1)
                if ~symbols1{i}.equals(symbols2{i})
                    return
                end
            end
            eq = true;
        end

    end

    methods (Hidden)

        function copyFrom(obj, container, varargin)

            % parse input arguments
            has_symbols = false;
            try
                gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container');
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                all_symbols = container.listSymbols();
                idx = ismember(all_symbols, container.getSymbolNames(symbols));
                symbols = container.getSymbols(all_symbols(idx));
            else
                symbols = container.getSymbols();
            end

            for i = 1:numel(symbols)
                symbols{i}.copy(obj);
            end

        end

    end

    methods

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
        %> - indexed (`logical`):
        %>   Specifies if indexed GDX should be read. Default is `false`.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> c.read('path/to/file.gdx');
        %> c.read('path/to/file.gdx', 'format', 'dense_matrix');
        %> c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
        %> ```
        function read(obj, source, varargin)
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
            % - indexed (logical):
            %   Specifies if indexed GDX should be read. Default is false.
            %
            % Example:
            % c = Container();
            % c.read('path/to/file.gdx');
            % c.read('path/to/file.gdx', 'format', 'dense_matrix');
            % c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});

            % parse input arguments
            symbols = {};
            has_symbols = false;
            format = 'table';
            records = true;
            values = {'level', 'marginal', 'lower', 'upper', 'scale'};
            indexed = false;
            try
                valid = gams.transfer.utils.Validator('source', 1, source) ...
                    .types({'gams.transfer.Container', 'string', 'char'});
                if ~isa(source, 'gams.transfer.Container')
                    valid.string2char().fileExtension('.gdx').fileExists();
                end
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().vector().value;
                        has_symbols = true;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'format')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        format = gams.transfer.utils.Validator('format', index, varargin{index}) ...
                            .string2char().type('char').vector().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'records')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        records = gams.transfer.utils.Validator('records', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'values')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        values = gams.transfer.utils.Validator('values', index, varargin{index}) ...
                            .string2char().cellstr().vector().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'indexed')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        indexed = gams.transfer.utils.Validator('indexed', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % read from other container?
            if isa(source, 'gams.transfer.Container')
                if has_symbols
                    obj.copyFrom(source, 'symbols', symbols);
                else
                    obj.copyFrom(source);
                end
                return
            end

            % validate input arguments
            switch format
            case 'struct'
                format = int32(2);
            case 'dense_matrix'
                format = int32(3);
            case 'sparse_matrix'
                format = int32(4);
            case 'table'
                format = int32(5);
                if ~gams.transfer.Constants.SUPPORTS_TABLE
                    format = int32(2);
                end
            otherwise
                error('Argument ''format'' must be ''struct'', ''table'', ''dense_matrix'' or ''sparse_matrix''.');
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
                    error('Argument ''values'' contains invalid selection ''%s''. Must be subset of ''level'', ''value'', ''element_text'', ''marginal'', ''lower'', ''upper'', ''scale''.', e{1});
                end
            end
            values = values_bool;

            % read records
            if indexed
                symbols = gams.transfer.gdx.gt_idx_read(obj.gams_dir_, source, symbols, format, records);
            else
                symbols = gams.transfer.gdx.gt_gdx_read(obj.gams_dir_, source, symbols, format, records, ...
                    values, gams.transfer.Constants.SUPPORTS_CATEGORICAL, false);
            end
            symbol_names = fieldnames(symbols);

            % transform data into Symbol object
            for i = 1:numel(symbol_names)
                symbol = symbols.(symbol_names{i});

                % create symbol object
                switch symbol.symbol_type
                case {gams.transfer.gdx.SymbolType.ALIAS, 'alias'}
                    if strcmp(symbol.alias_with, gams.transfer.Constants.UNIVERSE_NAME)
                        new_symbol = gams.transfer.alias.Universe(obj, symbol.name);
                    elseif obj.hasSymbols(symbol.alias_with)
                        new_symbol = gams.transfer.alias.Set(obj, symbol.name, obj.getSymbols(symbol.alias_with));
                    else
                        error('Alias reference for symbol ''%s'' not found: %s.', symbol.name, symbol.alias_with);
                    end
                case {gams.transfer.gdx.SymbolType.SET, 'set'}
                    new_symbol = gams.transfer.symbol.Set(obj, symbol.name, symbol.is_singleton, false, false);
                case {gams.transfer.gdx.SymbolType.PARAMETER, 'parameter'}
                    new_symbol = gams.transfer.symbol.Parameter(obj, symbol.name, false, false);
                case {gams.transfer.gdx.SymbolType.VARIABLE, 'variable'}
                    new_symbol = gams.transfer.symbol.Variable(obj, symbol.name, symbol.type, false, false);
                case {gams.transfer.gdx.SymbolType.EQUATION, 'equation'}
                    new_symbol = gams.transfer.symbol.Equation(obj, symbol.name, symbol.type, false, false);
                otherwise
                    error('Invalid symbol type');
                end
                obj.data_.add(symbol.name, new_symbol);
                if isa(new_symbol, 'gams.transfer.alias.Abstract')
                    continue
                end

                % set domain
                if indexed
                    new_symbol.size = symbol.size;
                else
                    for j = 1:numel(symbol.domain)
                        if ~strcmp(symbol.domain{j}, gams.transfer.Constants.UNIVERSE_NAME) && ...
                            symbol.domain_type ~= 2 && obj.hasSymbols(symbol.domain{j}) && ...
                            isfield(symbols, symbol.domain{j})
                            symbol.domain{j} = obj.getSymbols(symbol.domain{j});
                        end
                    end
                    new_symbol.domain = symbol.domain;
                end

                % set data
                if isfield(symbol, 'format')
                    switch symbol.format
                    case {1, 2}
                        new_symbol.data_ = gams.transfer.symbol.data.Struct(symbol.records);
                    case 3
                        new_symbol.data_ = gams.transfer.symbol.data.DenseMatrix(symbol.records);
                    case 4
                        new_symbol.data_ = gams.transfer.symbol.data.SparseMatrix(symbol.records);
                    case 5
                        new_symbol.data_ = gams.transfer.symbol.data.Table(symbol.records);
                    end
                end

                % set uels
                if isfield(symbol, 'uels') && ~gams.transfer.Constants.SUPPORTS_CATEGORICAL
                    for j = 1:new_symbol.dimension
                        new_symbol.unique_labels{j} = gams.transfer.unique_labels.OrderedLabelSet(symbol.uels{j});
                    end
                end

                % set other properties
                new_symbol.description_ = symbol.description;
                if isfield(symbol, 'domain_labels') && numel(symbol.domain_labels) == symbol.dimension
                    new_symbol.domain_labels = symbol.domain_labels;
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
        %> - indexed (`logical`):
        %>   Specifies if indexed GDX should be written. Default is `false`.
        %>
        %> **Example:**
        %> ```
        %> c.write('path/to/file.gdx');
        %> c.write('path/to/file.gdx', 'compress', true, 'sorted', true);
        %> ```
        %>
        %> @see \ref gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations"
        function write(obj, filename, varargin)
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
            % - indexed (logical):
            %   Specifies if indexed GDX should be written. Default is false.
            %
            % Example:
            % c.write('path/to/file.gdx');
            % c.write('path/to/file.gdx', 'compress', true, 'sorted', true);
            %
            % See also: gams.transfer.Container.getDomainViolations

            % parse input arguments
            has_symbols = false;
            compress = false;
            sorted = false;
            uel_priority = {};
            indexed = false;
            try
                filename = gams.transfer.utils.absolute_path(gams.transfer.utils.Validator(...
                    'filename', 1, filename).string2char().type('char').fileExtension('.gdx').value);
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'uel_priority')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        uel_priority = gams.transfer.utils.Validator('uel_priority', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'compress')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        compress = gams.transfer.utils.Validator('compress', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'sorted')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        sorted = gams.transfer.utils.Validator('sorted', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'indexed')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        indexed = gams.transfer.utils.Validator('indexed', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols && ~isempty(symbols)
                symbols = obj.getSymbolNames(symbols);
            else
                symbols = obj.data_.keys();
            end

            if ~obj.isValid('symbols', symbols)
                invalid_symbols = gams.transfer.utils.list2str(obj.listSymbols('is_valid', false));
                error('Can''t write invalid container. Invalid symbols: %s.', invalid_symbols);
            end

            % create enable flags
            if has_symbols
                enable = ismember(obj.data_.keys(), symbols);
            else
                enable = true(1, obj.data_.count());
            end

            % check indexed symbols
            if indexed
                disabled_symbols = {};
                for i = 1:numel(symbols)
                    if enable(i) && ~obj.getSymbols(symbols{i}).supportsIndexed()
                        enable(i) = false;
                        disabled_symbols{end+1} = symbols{i};
                    end
                end
                if numel(disabled_symbols) > 0
                    warning('The following symbols have been disbaled because they are not indexed: %s', ...
                        gams.transfer.utils.list2str(disabled_symbols));
                end
            end

            if compress && indexed
                error('Compression not supported for indexed GDX.');
            end

            % write data
            if indexed
                gams.transfer.gdx.gt_idx_write(obj.gams_dir_, filename, obj.data_.entries_, ...
                    enable, sorted, gams.transfer.Constants.SUPPORTS_TABLE);
            else
                gams.transfer.gdx.gt_gdx_write(obj.gams_dir_, filename, obj.data_.entries_, ...
                    enable, uel_priority, compress, sorted, gams.transfer.Constants.SUPPORTS_TABLE, ...
                    gams.transfer.Constants.SUPPORTS_CATEGORICAL);
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

            try
                if nargin == 1
                    symbols = obj.data_.entries();
                else
                    symbols = obj.data_.entries(names);
                end
            catch e
                error('Cannot get symbols: %s', e.message);
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

            symbols = obj.getSymbols(obj.listEquations(varargin{:}));
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

            bool = obj.data_.exists(names);
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

            symbols = obj.data_.keys(names);
        end

    end

    methods (Hidden, Static, Access = private)

        function [is_valid, types] = parseArgumentsListSymbols(args, has_types)
            is_valid = nan;
            types = {};
            index = 1;
            while index <= numel(args)
                if strcmpi(args{index}, 'is_valid')
                    index = index + 1;
                    gams.transfer.utils.Validator.minargin(numel(args), index);
                    is_valid = args{index};
                    index = index + 1;
                elseif has_types && strcmpi(args{index}, 'types')
                    index = index + 1;
                    gams.transfer.utils.Validator.minargin(numel(args), index);
                    types = args{index};
                    index = index + 1;
                else
                    error('Invalid argument at position %d', index);
                end
            end
        end

    end

    methods

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

            try
                [is_valid, types] = obj.parseArgumentsListSymbols(varargin, true);
            catch e
                error(e.message);
            end

            if isempty(types) && ~islogical(is_valid)
                list = obj.data_.keys();
                return
            end

            % count matched symbols
            symbols = obj.data_.entries();
            for k = 1:2
                n = 0;
                for i = 1:numel(symbols)

                    % check type
                    matched_type = isempty(types);
                    for j = 1:numel(types)
                        if isa(symbols{i}, types{j})
                            matched_type = true;
                            break;
                        end
                    end
                    if ~matched_type
                        continue
                    end

                    % check invalid
                    if islogical(is_valid) && xor(is_valid, symbols{i}.isValid())
                        continue
                    end

                    % add name to list
                    n = n + 1;
                    if k == 2
                        list{n} = symbols{i}.name;
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

            try
                is_valid = obj.parseArgumentsListSymbols(varargin, false);
            catch e
                error(e.message);
            end
            list = obj.listSymbols('types', {'gams.transfer.symbol.Set'}, 'is_valid', is_valid);
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

            try
                is_valid = obj.parseArgumentsListSymbols(varargin, false);
            catch e
                error(e.message);
            end
            list = obj.listSymbols('types', {'gams.transfer.symbol.Parameter'}, 'is_valid', is_valid);
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

            % parse input arguments
            try
                [is_valid, types] = obj.parseArgumentsListSymbols(varargin, true);
            catch e
                error(e.message);
            end
            try
                types = gams.transfer.VariableType.values(types);
            catch e
                error('Argument ''types'' cannot create ''gams.transfer.VariableType'': %s', e.message);
            end

            list = obj.listSymbols('types', {'gams.transfer.symbol.Variable'}, 'is_valid', is_valid);

            % filter by type
            if numel(types) > 0
                filter = false(size(list));
                for i = 1:numel(list)
                    symbol = obj.data_.entries(list{i});
                    filter(i) = sum(types == gams.transfer.VariableType(symbol.type).value) > 0;
                end
                list = list(filter);
            end
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

            % parse input arguments
            try
                [is_valid, types] = obj.parseArgumentsListSymbols(varargin, true);
            catch e
                error(e.message);
            end
            try
                types = gams.transfer.EquationType.values(types);
            catch e
                error('Argument ''types'' cannot create ''gams.transfer.EquationType'': %s', e.message);
            end

            list = obj.listSymbols('types', {'gams.transfer.symbol.Equation'}, 'is_valid', is_valid);

            % filter by type
            if numel(types) > 0
                filter = false(size(list));
                for i = 1:numel(list)
                    symbol = obj.data_.entries(list{i});
                    filter(i) = sum(types == gams.transfer.EquationType(symbol.type).value) > 0;
                end
                list = list(filter);
            end
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

            try
                is_valid = obj.parseArgumentsListSymbols(varargin, false);
            catch e
                error(e.message);
            end
            list = obj.listSymbols('types', {'gams.transfer.alias.Set'}, 'is_valid', is_valid);
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
                symbols = obj.getSymbols(varargin{1});
            else
                symbols = obj.getSets();
            end

            % get sets for aliases
            names = cell(1, numel(symbols));
            for i = 1:numel(symbols)
                names{i} = symbols{i}.name;
                if isa(symbols{i}, 'gams.transfer.alias.Set')
                    symbols{i} = symbols{i}.alias_with;
                end
            end

            descr = gams.transfer.symbol.Set.describe(symbols);

            for i = 1:numel(names)
                if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                    descr.name(i) = names{i};
                else
                    descr.name{i} = names{i};
                end
            end
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
                symbols = obj.getSymbols(varargin{1});
            else
                symbols = obj.getParameters();
            end
            descr = gams.transfer.symbol.Parameter.describe(symbols);
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
                symbols = obj.getSymbols(varargin{1});
            else
                symbols = obj.getVariables();
            end
            descr = gams.transfer.symbol.Variable.describe(symbols);
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
                symbols = obj.getSymbols(varargin{1});
            else
                symbols = obj.getEquations();
            end
            descr = gams.transfer.symbol.Equation.describe(symbols);
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
                symbols = obj.getSymbols(varargin{1});
            else
                symbols = obj.getAliases();
            end
            descr = gams.transfer.alias.Abstract.describe(symbols);
        end

        %> Adds a set to the container
        %>
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    Name of set
        %>
        %> **Optional Arguments:**
        %> 2. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{"*"}` (for 1-dim with
        %>    universe domain).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Set records, e.g. a list of strings. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - is_singleton (`logical`):
        %>   Indicates if set is a is_singleton set (`true`) or not (`false`). Default is `false`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> Note, this method may overwrite a set if its definition (\ref
        %> gams::transfer::symbol::Set::is_singleton "is_singleton", \ref
        %> gams::transfer::symbol::Set::domain "domain", \ref
        %> gams::transfer::symbol::Set::domain_forwarding "domain_forwarding") doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s1 = c.addSet('s1');
        %> s2 = c.addSet('s2', {s1, '*', '*'});
        %> s3 = c.addSet('s3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
        %> ```
        %>
        %> @see \ref gams::transfer::symbol::Set "symbol.Set", \ref gams::transfer::Set "Set"
        function symbol = addSet(obj, name, varargin)
            % Adds a set to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of set
            %
            % Optional Arguments:
            % 2. domain (cellstr or Set):
            %    List of domains given either as string or as reference to a
            %    gams.transfer.symbol.Set object. Default is {"*"} (for 1-dim with universe domain).
            %
            % Parameter Arguments:
            % - records:
            %   Set records, e.g. a list of strings. Default is `[]`.
            % - description (string):
            %   Description of symbol. Default is "".
            % - is_singleton (logical):
            %   Indicates if set is a is_singleton set (true) or not (false). Default is false.
            % - domain_forwarding (logical):
            %   If true, domain entries in records will recursively be added to the domains in case
            %   they are not present in the domains already. With a logical vector domain forwarding
            %   can be enabled/disabled independently for each domain. Default: false.
            %
            % Note, this method may overwrite a set if its definition (is_singleton, domain,
            % domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % s1 = c.addSet('s1');
            % s2 = c.addSet('s2', {s1, '*', '*'});
            % s3 = c.addSet('s3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
            %
            % See also: gams.transfer.symbol.Set, gams.transfer.Set

            new_symbol = gams.transfer.symbol.Set.construct(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
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
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    Name of parameter
        %>
        %> **Optional Arguments:**
        %> 2. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Parameter records. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> Note, this method may overwrite a parameter if its definition (\ref
        %> gams::transfer::symbol::Parameter::domain "domain", \ref
        %> gams::transfer::symbol::Parameter::domain_forwarding "domain_forwarding") doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> p1 = c.addParameter('p1');
        %> p2 = c.addParameter('p2', {'*', '*'});
        %> p3 = c.addParameter('p3', '*', 'description', 'par p3');
        %> ```
        %>
        %> @see \ref gams::transfer::symbol::Parameter "symbol.Parameter", \ref
        %> gams::transfer::Parameter "Parameter"
        function symbol = addParameter(obj, name, varargin)
            % Adds a parameter to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of parameter
            %
            % Optional Arguments:
            % 2. domain (cellstr or Set):
            %    List of domains given either as string or as reference to a
            %    gams.transfer.symbol.Set object. Default is {} (for scalar).
            %
            % Parameter Arguments:
            % - records:
            %   Parameter records. Default is [].
            % - description (string):
            %   Description of symbol. Default is "".
            % - domain_forwarding (logical):
            %   If true, domain entries in records will recursively be added to the domains in case
            %   they are not present in the domains already. With a logical vector domain
            %   forwarding can be enabled/disabled independently for each domain. Default: false.
            %
            % Note, this method may overwrite a parameter if its definition (domain,
            % domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % p1 = c.addParameter('p1');
            % p2 = c.addParameter('p2', {'*', '*'});
            % p3 = c.addParameter('p3', '*', 'description', 'par p3');
            %
            % See also: gams.transfer.symbol.Parameter, gams.transfer.Parameter

            new_symbol = gams.transfer.symbol.Parameter.construct(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
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
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    Name of variable
        %>
        %> **Optional Arguments:**
        %> 2. type (`string`, `int` or \ref gams::transfer::VariableType "VariableType"):
        %>    Specifies the variable type, either as `string`, as `integer` given by any of the
        %>    constants in \ref gams::transfer::VariableType "VariableType" or \ref
        %>    gams::transfer::VariableType "VariableType". Default is `"free"`.
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as string or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Set records, e.g. a list of strings. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> Note, this method may overwrite a variable if its definition (\ref
        %> gams::transfer::symbol::Variable::type "type", \ref
        %> gams::transfer::symbol::Variable::domain "domain", \ref
        %> gams::transfer::symbol::Variable::domain_forwarding "domain_forwarding") doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> v1 = c.addVariable('v1');
        %> v2 = c.addVariable('v2', 'binary', {'*', '*'});
        %> v3 = c.addVariable('v3', VariableType.BINARY, '*', 'description', 'var v3');
        %> ```
        %>
        %> @see \ref gams::transfer::symbol::Variable "symbol.Variable", \ref
        %> gams::transfer::Variable "Variable", \ref gams::transfer::VariableType
        %> "VariableType"
        function symbol = addVariable(obj, name, varargin)
            % Adds a variable to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of variable
            %
            % Optional Arguments:
            % 2. type (string, int or gams.transfer.VariableType):
            %    Specifies the variable type, either as string, as integer given by any of the
            %    constants in gams.transfer.VariableType or
            %    gams.transfer.VariableType. Default is "free".
            % 3. domain (cellstr or Set):
            %    List of domains given either as string or as reference to a
            %    gams.transfer.symbol.Set object. Default is {} (for scalar).
            %
            % Parameter Arguments:
            % - records:
            %   Set records, e.g. a list of strings. Default is [].
            % - description (string):
            %   Description of symbol. Default is "".
            % - domain_forwarding (logical):
            %   If true, domain entries in records will recursively be added to the domains in case
            %   they are not present in the domains already. With a logical vector domain forwarding
            %   can be enabled/disabled independently for each domain. Default: false.
            %
            % Note, this method may overwrite a variable if its definition (type, domain,
            % domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % v1 = c.addVariable('v1');
            % v2 = c.addVariable('v2', 'binary', {'*', '*'});
            % v3 = c.addVariable('v3', VariableType.BINARY, '*', 'description', 'var v3');
            %
            % See also: gams.transfer.symbol.Variable, gams.transfer.Variable,
            % gams.transfer.VariableType

            new_symbol = gams.transfer.symbol.Variable.construct(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
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
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    Name of equation
        %> 2. type (`string`, `int` or \ref gams::transfer::EquationType "EquationType"):
        %>    Specifies the variable type, either as `string`, as `integer` given by any of the
        %>    constants in \ref gams::transfer::EquationType "EquationType" or \ref
        %>    gams::transfer::EquationType "EquationType".
        %>
        %> **Optional Arguments:**
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Equation records. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the domains in case
        %>   they are not present in the domains already. With a logical vector domain forwarding
        %>   can be enabled/disabled independently for each domain. Default: `false`.
        %>
        %> Note, this method may overwrite an equation if its definition (\ref
        %> gams::transfer::symbol::Equation::type "type", \ref
        %> gams::transfer::symbol::Equation::domain "domain", \ref
        %> gams::transfer::symbol::Equation::domain_forwarding "domain_forwarding") doesn't differ.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> e2 = c.addEquation('e2', 'l', {'*', '*'});
        %> e3 = c.addEquation('e3', EquationType.EQ, '*', 'description', 'equ e3');
        %> ```
        %>
        %> @see \ref gams::transfer::symbol::Equation "symbol.Equation", \ref
        %> gams::transfer::Equation "Equation", \ref gams::transfer::EquationType
        %> "EquationType"
        function symbol = addEquation(obj, name, varargin)
            % Adds an equation to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of equation
            % 2. type (string, int or gams.transfer.EquationType):
            %    Specifies the variable type, either as string, as integer given by any of the
            %    constants in gams.transfer.EquationType or
            %    gams.transfer.EquationType.
            %
            % Optional Arguments:
            % 3. domain (cellstr or Set):
            %    List of domains given either as string or as reference to a
            %    gams.transfer.symbol.Set object. Default is {} (for scalar).
            %
            % Parameter Arguments:
            % - records:
            %   Equation records. Default is [].
            % - description (string):
            %   Description of symbol. Default is "".
            % - domain_forwarding (logical):
            %   If true, domain entries in records will recursively be added to the domains in case
            %   they are not present in the domains already. With a logical vector domain forwarding
            %   can be enabled/disabled independently for each domain. Default: false.
            %
            % Note, this method may overwrite an equation if its definition (type, domain,
            % domain_forwarding) doesn't differ.
            %
            % Example:
            % c = Container();
            % e2 = c.addEquation('e2', 'l', {'*', '*'});
            % e3 = c.addEquation('e3', EquationType.EQ, '*', 'description', 'equ e3');
            %
            % See also: gams.transfer.symbol.Equation, gams.transfer.Equation,
            % gams.transfer.EquationType

            new_symbol = gams.transfer.symbol.Equation.construct(obj, name, varargin{:});

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
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
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    name of alias
        %> 2. alias_with (`Set` or `Alias`):
        %>    \ref gams::transfer::symbol::Set "symbol.Set" to be linked to.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s = c.addSet('s');
        %> a = c.addAlias('a', s);
        %> ```
        %>
        %> @see \ref gams::transfer::alias::Set "alias.Set", \ref gams::transfer::Alias "Alias",
        %> \ref gams::transfer::symbol::Set "symbol.Set"
        function symbol = addAlias(obj, name, alias_with)
            % Adds an alias to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    name of alias
            % 2. alias_with (Set or Alias):
            %    gams.transfer.symbol.Set to be linked to.
            %
            % Example:
            % c = Container();
            % s = c.addSet('s');
            % a = c.addAlias('a', s);
            %
            % See also: gams.transfer.alias.Set, gams.transfer.Alias, gams.transfer.symbol.Set

            new_symbol = gams.transfer.alias.Set.construct(obj, name, alias_with);

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.alias.Set')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
        end

        %> Adds a universe alias to the container
        %>
        %> **Required Arguments:**
        %> 1. name (`string`):
        %>    name of alias
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> u = c.addUniverseAlias('u');
        %> ```
        %>
        %> @see \ref gams::transfer::alias::Universe "alias.Universe", \ref
        %> gams::transfer::UniverseAlias "UniverseAlias", \ref gams::transfer::symbol::Set
        %> "symbol.Set"
        function symbol = addUniverseAlias(obj, name)
            % Adds a universe alias to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    name of alias
            %
            % Example:
            % c = Container();
            % u = c.addUniverseAlias('u');
            %
            % See also: gams.transfer.alias.Universe, gams.transfer.UniverseAlias,
            % gams.transfer.symbol.Set

            new_symbol = gams.transfer.alias.Universe.construct(obj, name);

            if ~obj.hasSymbols(name)
                obj.data_.add(name, new_symbol);
                symbol = new_symbol;
                return
            end

            symbol = obj.getSymbols(name);
            if ~isa(symbol, 'gams.transfer.alias.Universe')
                error('Symbol ''%s'' (with different symbol type) already exists.', name);
            end
            symbol.copyFrom(new_symbol);
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

            if isequal(oldname, newname)
                return
            end
            try
                oldname = gams.transfer.utils.Validator('oldname', 1, oldname).symbolName().value;
                newname = gams.transfer.utils.Validator('newname', 2, newname).symbolName().value;
            catch e
                error(e.message);
            end

            if obj.hasSymbols(newname) && ~strcmpi(newname, oldname)
                error('Symbol ''%s'' already exists.', newname);
            end
            symbol = obj.data_.rename(oldname, newname);
            symbol.name_ = newname;
            symbol.modified = true;
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
                obj.data_.clear();

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                for i = 1:numel(removed_symbols)
                    removed_symbols{i}.isValid(false, true);
                    removed_symbols{i}.container = [];
                end

                obj.modified_ = true;
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
                obj.data_.remove(removed_symbols{j}.name);

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                removed_symbols{j}.isValid(false, true);
                removed_symbols{j}.container = [];
            end

            % remove aliases to removed sets
            symbols = obj.data_.entries();
            remove_aliases = {};
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.alias.Set')
                    if isempty(symbols{i}.alias_with.container)
                        remove_aliases{end+1} = symbols{i}.name;
                    end
                elseif isa(symbols{i}, 'gams.transfer.symbol.Abstract')
                    for j = 1:numel(symbols{i}.def.domains)
                        domain = symbols{i}.def.domains{j};
                        if ~isa(domain, 'gams.transfer.symbol.domain.Regular')
                            continue
                        end
                        if isempty(domain.symbol.container)
                            symbols{i}.def.domains{j} = domain.getRelaxed();
                        end
                    end
                end
            end
            if numel(remove_aliases) > 0
                obj.removeSymbols(remove_aliases);
            end

            obj.modified_ = true;
        end

        %> Reestablishes a valid GDX symbol order
        function reorderSymbols(obj)
            % Reestablishes a valid GDX symbol order

            symbols = obj.getSymbols();

            % get number of set/alias
            n_sets = 0;
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.symbol.Set') || isa(symbols{i}, 'gams.transfer.alias.Abstract')
                    n_sets = n_sets + 1;
                end
            end
            n_other = numel(symbols) - n_sets;

            sets = cell(1, n_sets);
            idx_sets = zeros(1, n_sets);
            idx_other = zeros(1, n_other);
            n_sets = 0;
            n_other = 0;

            % get index by type
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.symbol.Set') || isa(symbols{i}, 'gams.transfer.alias.Abstract')
                    n_sets = n_sets + 1;
                    idx_sets(n_sets) = i;
                    sets{n_sets} = symbols{i}.name;
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
                    current_set = obj.getSymbols(sets{idx(n_handled+1)});
                    for i = 1:current_set.dimension
                        if (isa(current_set.domain{i}, 'gams.transfer.symbol.Set') || ...
                            isa(current_set.domain{i}, 'gams.transfer.alias.Abstract')) && ...
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
                        l = gams.transfer.utils.list2str(sets(idx(n_handled+1:end)));
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
            obj.data_.reorder([idx_sets, idx_other]);
            obj.modified_ = true;

            % force recheck of all remaining symbols in container
            obj.isValid(false, true);
        end

        %> Get domain violations for all symbols
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::symbol::Set "Sets" as \ref gams::transfer::symbol::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::symbol::Symbol::records "records" that is not present in
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
        %> gams::transfer::symbol::Symbol::getDomainViolations
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

            % parse input arguments
            has_symbols = false;
            try
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            dom_violations = {};
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.alias.Abstract')
                    continue
                end
                dom_violations_sym = symbols{i}.getDomainViolations();
                dom_violations(end+1:end+numel(dom_violations_sym)) = dom_violations_sym;
            end
        end

        %> Extends domain sets in order to remove domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::symbol::Set "Sets" as \ref gams::transfer::symbol::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::symbol::Symbol::records "records" that is not present in
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
        %> gams::transfer::symbol::Symbol::resolveDomainViolations
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

            dom_violations = obj.getDomainViolations(varargin{:});
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
        %> @see \ref gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
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

            % parse input arguments
            has_symbols = false;
            verbose = false;
            force = false;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        verbose = gams.transfer.utils.Validator('verbose', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        force = gams.transfer.utils.Validator('force', index, varargin{index}) ...
                            .type('logical').scalar().value;
                        index = index + 1;

                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            % check for correct order of symbols
            correct_order = true;
            for i = 1:numel(symbols)
                if ~isa(symbols{i}, 'gams.transfer.symbol.Abstract')
                    continue
                end
                for j = 1:numel(symbols{i}.def.domains)
                    domain = symbols{i}.def.domains{j};
                    if ~isa(domain, 'gams.transfer.symbol.domain.Regular')
                        continue
                    end
                    correct_order = gams.transfer.gdx.gt_check_symbol_order(obj.data_.entries_, ...
                        domain.name, symbols{i}.name);
                    if ~correct_order
                        break;
                    end
                end
                if ~correct_order
                    break;
                end
            end
            if ~correct_order
                obj.reorderSymbols();
            end

            % check symbols
            valid = true;
            for i = 1:numel(symbols)
                if symbols{i}.isValid(verbose, force)
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
        %> @note This can only be used if the container is valid.
        %>
        %> @see \ref gams::transfer::Container::isValid "Container.isValid"
        function uels = getUELs(obj, varargin)
            % Get UELs from all symbols
            %
            % u = getUELs() returns the UELs across all symbols.
            % u = getUELs(_, 'symbols', s) returns the UELs across symbols s.
            % u = getUELs(_, "ignore_unused", true) returns only those UELs
            % that are actually used in the records.
            %
            % Note: This can only be used if the container is valid.
            %
            % See also: gams.transfer.Container.isValid

            % parse input arguments
            has_symbols = false;
            ignore_unused = false;
            try
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'ignore_unused')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        ignore_unused = gams.transfer.utils.Validator('ignore_unused', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            uels = {};
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.alias.Abstract')
                    continue
                end
                uels = gams.transfer.utils.unique([uels; symbols{i}.getUELs('ignore_unused', ignore_unused)]);
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
        %> @note This can only be used if the container is valid.
        %>
        %> @see \ref gams::transfer::Container::isValid "Container.isValid"
        function removeUELs(obj, varargin)
            % Removes UELs from all symbol
            %
            % removeUELs() removes all unused UELs for all symbols.
            % removeUELs(u) removes the UELs u for all symbols.
            % removeUELs(_, 'symbols', s) removes UELs for symbols s.
            %
            % Note: This can only be used if the container is valid.
            %
            % See also: gams.transfer.Container.isValid

            % parse input arguments
            has_symbols = false;
            uels = {};
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        if iscell(varargin{index})
                            uels = gams.transfer.utils.Validator('uels', index, varargin{index}).cellstr().value;
                        else
                            uels = gams.transfer.utils.Validator('uels', index, varargin{index}).types({'string', 'char'}).value;
                        end
                        index = index + 1;

                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            for i = 1:numel(symbols)
                symbols{i}.removeUELs(uels);
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
        %> @note This can only be used if the symbol is valid.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
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
            % Note: This can only be used if the symbol is valid.
            %
            % See also: gams.transfer.Symbol.isValid

            % parse input arguments
            has_symbols = false;
            allow_merge = false;
            try
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    elseif strcmpi(varargin{index}, 'allow_merge')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        allow_merge = gams.transfer.utils.Validator('allow_merge', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            for i = 1:numel(symbols)
                symbols{i}.renameUELs(uels, 'allow_merge', allow_merge);
            end
        end

        %> Converts UELs to lower case
        %>
        %> - `lowerUELs()` converts all UELs to lower case.
        %> - `lowerUELs('symbols', s)` converts all UELs to lower case for symbols `s`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % lowerUELs() converts all UELs to lower case.
            % lowerUELs('symbols', s) converts all UELs to lower case for symbols s.
            %
            % Note: This can only be used if the symbol is valid.
            %
            % See also: gams.transfer.Symbol.isValid

            % parse input arguments
            has_symbols = false;
            try
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            for i = 1:numel(symbols)
                symbols{i}.lowerUELs();
            end
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts all UELs to upper case.
        %> - `upperUELs('symbols', s)` converts all UELs to upper case for symbols `s`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % upperUELs() converts all UELs to upper case.
            % upperUELs('symbols', s) converts all UELs to upper case for symbols s.
            %
            % Note: This can only be used if the symbol is valid.
            %
            % See also: gams.transfer.Symbol.isValid

            % parse input arguments
            has_symbols = false;
            try
                index = 1;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'symbols')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        symbols = gams.transfer.utils.Validator('symbols', index, varargin{index}) ...
                            .string2char().cellstr().value;
                        has_symbols = true;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if has_symbols
                symbols = obj.getSymbols(symbols);
            else
                symbols = obj.data_.entries();
            end

            for i = 1:numel(symbols)
                symbols{i}.upperUELs();
            end
        end

    end

end
