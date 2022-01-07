classdef ConstContainer < GAMSTransfer.BaseContainer
    % GAMSTransfer ConstContainer stores (multiple) symbols read-only
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
    % c = ConstContainer();
    % c = ConstContainer('path/to/file.gdx');
    % c = ConstContainer('indexed', true, 'gams_dir', 'C:\GAMS');
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

        function obj = ConstContainer(varargin)
            % Constructs a GAMSTransfer Container, see class help.
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
                ~strcmpi(x, 'gams_dir') && ~strcmpi(x, 'indexed') && ...
                ~strcmpi(x, 'features');
            is_values = @(x) iscellstr(x) && numel(x) <= 5;
            addOptional(p, 'filename', '', is_string_char);
            addParameter(p, 'symbols', {}, @iscellstr);
            addParameter(p, 'format', 'table', is_string_char);
            addParameter(p, 'values', {'level', 'marginal', 'lower', 'upper', 'scale'}, ...
                is_values);
            addParameter(p, 'gams_dir', '', is_string_char);
            addParameter(p, 'indexed', false, @islogical);
            addParameter(p, 'features', struct(), @isstruct);
            parse(p, varargin{:});

            obj = obj@GAMSTransfer.BaseContainer(p.Results.gams_dir, p.Results.indexed, ...
                p.Results.features);

            if strcmp(p.Results.filename, '')
                return
            end

            % read raw data
            data = obj.readRaw(p.Results.filename, p.Results.symbols, ...
                p.Results.format, p.Results.values);
            symbols = fieldnames(data);

            % transform data into Symbol object
            for i = 1:numel(symbols)
                n = symbols{i};

                % handle alias
                if data.(n).symbol_type == GAMSTransfer.SymbolType.ALIAS
                    data.(n).symbol_type = GAMSTransfer.SymbolType.int2str(data.(n).symbol_type);
                    if ~isfield(data, data.(n).alias_with)
                        error('Alias reference for symbol ''%s'' not found: %s.', ...
                            data.(n).name, data.(n).description);
                    end
                    continue
                end

                % downgrade regular domain to relaxed if necessary
                for j = 1:numel(data.(n).domain)
                    if data.(n).domain_type == 3 && (~isfield(data, data.(n).domain{j}) || ...
                        strcmp(data.(n).domain{j}, data.(n).name))
                        data.(n).domain_type = 2;
                    end
                end

                % transform some numerical data to strings
                if data.(n).symbol_type == GAMSTransfer.SymbolType.VARIABLE
                    data.(n).type = GAMSTransfer.VariableType.int2str(data.(n).type);
                end
                if data.(n).symbol_type == GAMSTransfer.SymbolType.EQUATION
                    data.(n).type = GAMSTransfer.EquationType.int2str(data.(n).type);
                end
                data.(n).symbol_type = GAMSTransfer.SymbolType.int2str(data.(n).symbol_type);
                data.(n).format = GAMSTransfer.RecordsFormat.int2str(data.(n).format);
                if data.(n).domain_type == 1
                    data.(n).domain_type = 'none';
                elseif data.(n).domain_type == 2
                    data.(n).domain_type = 'relaxed';
                elseif data.(n).domain_type == 3
                    data.(n).domain_type = 'regular';
                end

                % in case of matrix like formats, number of records is not defined
                switch data.(n).format
                case {'dense_matrix', 'sparse_matrix'}
                    data.(n).number_records = nan;
                end

            end

            obj.data = data;
        end

    end

end
