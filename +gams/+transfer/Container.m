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

    properties (Hidden, SetAccess = protected)
        gams_dir_ = ''
        indexed_ = false
        modified_ = true
        data_
    end

    methods (Hidden, Static)

        function arg = validateGamsDir(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if ~isfile(fullfile(arg, gams.transfer.Constants.GDX_LIB_NAME))
                error('Argument ''%s'' (at position %d) does not contain a path to the GDX library.', name, index);
            end
        end

        function arg = validateGdxFile(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            arg = gams.transfer.utils.absolute_path(arg);
            [~, ~, ext] = fileparts(arg);
            if ~strcmpi(ext, '.gdx')
                error('Argument ''%s'' (at position %d) must be file name with ''.gdx'' extension.', name, index);
            end
            if ~isfile(arg)
                error('Argument ''%s'' (at position %d) must name a file that exists.', name, index);
            end
        end

        function arg = validateIndexed(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

        function arg = validateModified(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

        function arg = validateReadSource(name, index, arg)
            if isa(arg, 'gams.transfer.Container')
                return
            end
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'', ''char'' or ''gams.transfer.Container''.', name, index);
            end
        end

    end

    properties (Dependent, SetAccess = protected)
        %> GAMS system directory

        % gams_dir GAMS system directory
        gams_dir


        %> Flag for indexed mode

        % indexed Flag for indexed mode
        indexed


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

        function indexed = get.indexed(obj)
            indexed = obj.indexed_;
        end

        function data = get.data(obj)
            data = obj.data_.entries_;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
            if modified
                return
            end
            symbols = obj.data_.getAllEntries();
            for i = 1:numel(symbols)
                if modified
                    return
                end
                modified = modified || symbols{i}.modified;
            end
        end

        function obj = set.modified(obj, modified)
            modified = obj.validateModified('modified', 1, modified);
            symbols = obj.data_.getAllEntries();
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

            obj.data_ = gams.transfer.ordered_dict.CaseInsensitiveStruct();

            % parse input arguments
            has_gams_dir = false;
            source = '';
            try
                index = 1;
                is_pararg = false;
                while index <= nargin
                    if strcmpi(varargin{index}, 'gams_dir')
                        obj.gams_dir_ = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'gams_dir', @obj.validateGamsDir);
                        has_gams_dir = true;
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'indexed')
                        obj.indexed_ = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'indexed', @obj.validateIndexed);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        source = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'source', @obj.validateReadSource);
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
            if ~strcmp(source, '')
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
            % if ~isa(container, 'gams.transfer.Container')
            %     return
            % end
            % eq = isequaln(obj.gams_dir_, container.gams_dir);
            % eq = eq && obj.indexed_ == container.indexed;
            % eq = eq && numel(fieldnames(obj.data_)) == numel(fieldnames(container.data));
            % if ~eq
            %     return
            % end

            % symbols1 = fieldnames(obj.data_);
            % symbols2 = fieldnames(container.data);
            % if numel(symbols1) ~= numel(symbols2)
            %     eq = false;
            %     return
            % end
            % for i = 1:numel(symbols1)
            %     eq = eq && isequaln(symbols1{i}, symbols2{i});
            %     eq = eq && obj.data_.(symbols1{i}).equals(container.data.(symbols2{i}));
            % end
        end

    end

    methods (Hidden)

        function copyFrom(obj, varargin)

            % parse input arguments
            has_symbols = false;
            try
                validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'gams.transfer.Container'}, 0));
                container = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'container', validate);
                index = 2;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'symbols')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'string', 'char'}, 1));
                        symbols = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'symbols', validate);
                        symbols = container.getSymbols(symbols);
                        has_symbols = true;
                        index = index + 2;
                        is_pararg = true;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end
            if ~has_symbols
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
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> c.read('path/to/file.gdx');
        %> c.read('path/to/file.gdx', 'format', 'dense_matrix');
        %> c.read('path/to/file.gdx', 'symbols', {'x', 'z'}, 'format', 'struct', 'values', {'level'});
        %> ```
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

            % parse input arguments
            symbols = {};
            has_symbols = false;
            format = 'table';
            records = true;
            values = {'level', 'marginal', 'lower', 'upper', 'scale'};
            % try
                validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, ...
                    {'string', 'char', 'gams.transfer.Container'}, -1));
                source = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'source', validate);
                index = 2;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'symbols')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'string', 'char'}, 1));
                        symbols = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'symbols', validate);
                        has_symbols = true;
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'format')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'string', 'char'}, -1));
                        format = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'format', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'records')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        records = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'records', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'values')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'string', 'char'}, 1));
                        symbols = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'values', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 4
                        obj.def_.domains_ = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'domains', @gams.transfer.symbol.Definition.validateDomains);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            % catch e
            %     error(e.message);
            % end

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
            source = obj.validateGdxFile('source', 1, source);
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
            if obj.indexed_
                symbols = gams.transfer.cmex.gt_idx_read(obj.gams_dir_, source, symbols, format, records);
            else
                symbols = gams.transfer.cmex.gt_gdx_read(obj.gams_dir_, source, symbols, format, records, ...
                    values, gams.transfer.Constants.SUPPORTS_CATEGORICAL, false);
            end
            symbol_names = fieldnames(symbols);

            % transform data into Symbol object
            for i = 1:numel(symbol_names)
                symbol = symbols.(symbol_names{i});

                % handle alias differently
                switch symbol.symbol_type
                case {gams.transfer.cmex.SymbolType.ALIAS, 'alias'}
                    if strcmp(symbol.alias_with, gams.transfer.Constants.UNIVERSE_NAME)
                        gams.transfer.UniverseAlias(obj, symbol.name);
                    elseif obj.hasSymbols(symbol.alias_with)
                        gams.transfer.Alias(obj, symbol.name, obj.getSymbols(symbol.alias_with));
                    else
                        error('Alias reference for symbol ''%s'' not found: %s.', symbol.name, symbol.alias_with);
                    end
                    continue
                case {gams.transfer.cmex.SymbolType.SET, 'set'}
                    new_symbol = obj.addSet(symbol.name, 'is_singleton', symbol.is_singleton);
                case {gams.transfer.cmex.SymbolType.PARAMETER, 'parameter'}
                    new_symbol = obj.addParameter(symbol.name);
                case {gams.transfer.cmex.SymbolType.VARIABLE, 'variable'}
                    new_symbol = obj.addVariable(symbol.name, symbol.type);
                case {gams.transfer.cmex.SymbolType.EQUATION, 'equation'}
                    new_symbol = obj.addEquation(symbol.name, symbol.type);
                otherwise
                    error('Invalid symbol type');
                end

                new_symbol.description = symbol.description;

                % set domain and description
                if obj.indexed_
                    new_symbol.size = symbol.size;
                else
                    domain = symbol.domain;
                    for j = 1:numel(domain)
                        if strcmp(domain{j}, gams.transfer.Constants.UNIVERSE_NAME) || symbol.domain_type == 2
                            continue
                        elseif obj.hasSymbols(domain{j}) && isfield(symbols, domain{j})
                            domain{j} = obj.getSymbols(domain{j});
                        end
                    end
                    new_symbol.domain = domain;
                end

                % set records
                symbol_.records = symbol.records;
                % switch symbol.format
                % case {3, 'dense_matrix',
                %     4, 'sparse_matrix'}
                %     copy_format = ~any(isnan(symbol_.size));
                % otherwise
                %     copy_format = true;
                % end
                % TODO
                % if copy_format
                %     if isnumeric(symbol.format)
                %         symbol_.format_ = symbol.format;
                %     else
                %         symbol_.format_ = gams.transfer.RecordsFormat.str2int(symbol.format);
                %     end
                % end

                % set uels
                if isfield(symbol, 'uels') && ~gams.transfer.Constants.SUPPORTS_CATEGORICAL
                    switch symbol.format
                    case {3, 'dense_matrix', 4, 'sparse_matrix'}
                    case {1, 'table', 2, 'struct'}
                        for j = 1:numel(symbol.domain)
                            new_symbol.setUELs(symbol.uels{j}, j, 'rename', true);
                        end
                    end
                end
            end

            % check for format of read symbols in case of partial read (done by
            % forced call to isValid). Domains may not be read and may cause
            % invalid symbols.
            % TODO
            % if is_partial_read
            %     for j = 1:numel(symbols)
            %         if obj.hasSymbols(symbols{i})
            %             obj.getSymbols(symbols{i}).isValid(false, true);
            %         end
            %     end
            % end
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
                symbols = obj.data_.getAllKeys();
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
                allsymbols = obj.data_.getAllKeys();
                allsymbols = containers.Map(allsymbols, 1:numel(allsymbols));
                for i = 1:numel(symbols)
                    enable(allsymbols(symbols{i})) = true;
                end
            end

            if p.Results.compress && obj.indexed_
                error('Compression not supported for indexed GDX.');
            end

            % get full path
            filename = obj.validateGdxFile('filename', 1, p.Results.filename);

            % write data
            if obj.indexed_
                gams.transfer.cmex.gt_idx_write(obj.gams_dir_, filename, obj.data_.entries, ...
                    enable, p.Results.sorted, gams.transfer.Constants.SUPPORTS_TABLE);
            else
                gams.transfer.cmex.gt_gdx_write(obj.gams_dir_, filename, obj.data_.entries, ...
                    enable, p.Results.uel_priority, p.Results.compress, p.Results.sorted, ...
                    gams.transfer.Constants.SUPPORTS_TABLE, gams.transfer.Constants.SUPPORTS_CATEGORICAL, ...
                    false);
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
                symbols = obj.data_.getAllEntries();
                return
            end
            try
                if iscell(names)
                    symbols = obj.data_.getEntries(names);
                else
                    symbols = obj.data_.getEntry(names);
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

            if iscell(names)
                bool = obj.data_.hasKeys(names);
            else
                bool = obj.data_.hasKey(names);
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

            if iscell(names)
                symbols = obj.data_.getKeys(names);
            else
                symbols = obj.data_.getKey(names);
            end
        end

    end

    methods (Hidden, Static, Access = private)

        function [is_valid, types] = parseArgumentsListSymbols(args, has_types)
            is_valid = nan;
            types = {};
            index = 1;
            is_pararg = false;
            while index < numel(args)
                if strcmpi(args{index}, 'is_valid')
                    is_valid = gams.transfer.utils.parse_argument(args, ...
                        index + 1, 'is_valid', []);
                    index = index + 2;
                    is_pararg = true;
                elseif has_types && strcmpi(args{index}, 'types')
                    types = gams.transfer.utils.parse_argument(args, ...
                        index + 1, 'types', []);
                    index = index + 2;
                    is_pararg = true;
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
                list = obj.data_.getAllKeys();
                return
            end

            % count matched symbols
            symbols = obj.data_.getAllEntries();
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
                    if islogical(is_valid) && isa(symbols{i}, 'gams.transfer.Symbol') && ...
                        xor(is_valid, symbols{i}.isValid())
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
                types = gams.transfer.symbol.VariableType.values(types);
            catch e
                error('Argument ''types'' cannot create ''gams.transfer.symbol.VariableType'': %s', e.message);
            end

            list = obj.listSymbols('types', {'gams.transfer.symbol.Variable'}, 'is_valid', is_valid);

            % filter by type
            if numel(types) > 0
                filter = false(size(list));
                for i = 1:numel(list)
                    symbol = obj.data_.getEntry(list{i});
                    filter(i) = sum(types == gams.transfer.symbol.VariableType(symbol.type).value) > 0;
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
                types = gams.transfer.symbol.EquationType.values(types);
            catch e
                error('Argument ''types'' cannot create ''gams.transfer.symbol.EquationType'': %s', e.message);
            end

            list = obj.listSymbols('types', {'gams.transfer.symbol.Equation'}, 'is_valid', is_valid);

            % filter by type
            if numel(types) > 0
                filter = false(size(list));
                for i = 1:numel(list)
                    symbol = obj.data_.getEntry(list{i});
                    filter(i) = sum(types == gams.transfer.symbol.EquationType(symbol.type).value) > 0;
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
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.alias.Set')
                    symbols{i} = symbols{i}.alias_with;
                end
            end

            descr = gams.transfer.symbol.Set.describe(symbols);
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

            if obj.indexed_
                error('Set not supported in indexed mode.');
            end

            new_symbol = gams.transfer.symbol.Set(obj, name, varargin{:});

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

            new_symbol = gams.transfer.symbol.Parameter(obj, name, varargin{:});

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
        %> 2. type (`string`, `int` or \ref gams::transfer::symbol::VariableType "symbol.VariableType"):
        %>    Specifies the variable type, either as `string`, as `integer` given by any of the
        %>    constants in \ref gams::transfer::symbol::VariableType "symbol.VariableType" or \ref
        %>    gams::transfer::symbol::VariableType "symbol.VariableType". Default is `"free"`.
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
        %> gams::transfer::Variable "Variable", \ref gams::transfer::symbol::VariableType
        %> "VariableType"
        function symbol = addVariable(obj, name, varargin)
            % Adds a variable to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of variable
            %
            % Optional Arguments:
            % 2. type (string, int or gams.transfer.symbol.VariableType):
            %    Specifies the variable type, either as string, as integer given by any of the
            %    constants in gams.transfer.symbol.VariableType or
            %    gams.transfer.symbol.VariableType. Default is "free".
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
            % gams.transfer.symbol.VariableType

            if obj.indexed_
                error('Variable not supported in indexed mode.');
            end

            new_symbol = gams.transfer.symbol.Variable(obj, name, varargin{:});

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
        %> 2. type (`string`, `int` or \ref gams::transfer::symbol::EquationType "symbol.EquationType"):
        %>    Specifies the variable type, either as `string`, as `integer` given by any of the
        %>    constants in \ref gams::transfer::symbol::EquationType "symbol.EquationType" or \ref
        %>    gams::transfer::symbol::EquationType "symbol.EquationType".
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
        %> gams::transfer::Equation "Equation", \ref gams::transfer::symbol::EquationType
        %> "symbol.EquationType"
        function symbol = addEquation(obj, name, varargin)
            % Adds an equation to the container
            %
            % Required Arguments:
            % 1. name (string):
            %    Name of equation
            % 2. type (string, int or gams.transfer.symbol.EquationType):
            %    Specifies the variable type, either as string, as integer given by any of the
            %    constants in gams.transfer.symbol.EquationType or
            %    gams.transfer.symbol.EquationType.
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
            % gams.transfer.symbol.EquationType

            if obj.indexed_
                error('Equation not supported in indexed mode.');
            end

            new_symbol = gams.transfer.symbol.Equation(obj, name, varargin{:});

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

            if obj.indexed_
                error('Alias not supported in indexed mode.');
            end

            new_symbol = gams.transfer.alias.Set(obj, name, alias_with);

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

            if obj.indexed_
                error('UniverseAlias not supported in indexed mode.');
            end

            new_symbol = gams.transfer.alias.Universe(obj, name);

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

            if strcmp(oldname, newname)
                return
            end
            if obj.hasSymbols(newname) && ~strcmpi(newname, oldname)
                error('Symbol ''%s'' already exists.', newname);
            end
            symbol = obj.data_.rename(oldname, newname);
            symbol.name = newname;
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
                obj.data_.remove(removed_symbols{j}.name);

                % force recheck of deleted symbol (it may still live within an
                % alias, domain or in the user's program)
                removed_symbols{j}.isValid(false, true);
            end
            removed_symbols = removed_symbols(1:j);

            % remove aliases to removed sets
            symbols = obj.data_.getAllEntries();
            remove_aliases = {};
            for i = 1:numel(symbols)
                if ~isa(symbols{i}, 'gams.transfer.alias.Set')
                    continue
                end
                for j = 1:numel(removed_symbols)
                    if symbols{i}.alias_with.name == removed_symbols{j}.name
                        remove_aliases{end+1} = symbols{i}.name;
                        break;
                    end
                end
            end
            if numel(remove_aliases) > 0
                obj.removeSymbols(remove_aliases);
            end
        end

        %> Reestablishes a valid GDX symbol order
        function reorderSymbols(obj)
            % Reestablishes a valid GDX symbol order

            error('todo')

            names = fieldnames(obj.data_);

            % get number of set/alias
            n_sets = 0;
            for i = 1:numel(names)
                symbol = obj.data_.(names{i});
                if isa(symbol, 'gams.transfer.symbol.Set') || isa(symbol, 'gams.transfer.Alias')
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
                symbol = obj.data_.(names{i});
                if isa(symbol, 'gams.transfer.symbol.Set') || isa(symbol, 'gams.transfer.Alias')
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
                    current_set = obj.data_.(sets{idx(n_handled+1)});
                    for i = 1:current_set.dimension
                        if (isa(current_set.domain{i}, 'gams.transfer.symbol.Set') || ...
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
            obj.data_ = orderfields(obj.data_, [idx_sets, idx_other]);

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

            dom_violations = {};

            % input arguments
            p = inputParser();
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
            end

            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.Alias')
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

            % input arguments
            p = inputParser();
            addOptional(p, 'verbose', false, @islogical);
            addOptional(p, 'force', false, @islogical);
            addParameter(p, 'symbols', {}, @iscellstr);
            parse(p, varargin{:});
            if isempty(p.Results.symbols)
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
            end
            verbose = p.Results.verbose;
            force = p.Results.force;

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
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
            end

            uels = {};
            for i = 1:numel(symbols)
                if isa(symbols{i}, 'gams.transfer.UniverseAlias')
                    continue
                end
                uels = gams.transfer.utils.unique([uels; symbols{i}.getUELs('ignore_unused', p.Results.ignore_unused)]);
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
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(symbols);
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
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
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
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
            end

            for i = 1:numel(symbols)
                symbols{i}.renameUELs(uels, 'allow_merge', p.Results.allow_merge);
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
        %> gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
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
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
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
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "Symbol.isValid"
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
                symbols = obj.data_.getAllEntries();
            else
                symbols = obj.getSymbols(p.Results.symbols);
            end

            for i = 1:numel(symbols)
                symbols{i}.upperUELs();
            end
        end

    end

end
