classdef Equation < GAMSTransfer.Symbol
    % GAMS Equation
    %
    % This class represents a GAMS Equation.
    %
    % Required Arguments:
    % 1. container: Container
    %    GAMSTransfer container object this symbol should be stored in
    % 2. name: string
    %    Name of equation
    %
    % Optional Arguments:
    % 3. type: string or int
    %    Specifies the equation type, either as string or as integer given by
    %    any of the constants in EquationType. Default is 'nonbinding'.
    % 4. domain: cell of string or Set
    %    List of domains given either as string or as reference to a Set
    %    object. Default is {} (for scalar).
    %
    % Parameter Arguments:
    % - records:
    %   Set records, e.g. a list of strings. Default is [].
    % - description: string
    %   Description of symbol. Default is ''.
    %
    % Example:
    % c = Container();
    % e1 = Equation(c, 'e1');
    % e2 = Equation(c, 'e2', 'l', {'*', '*'});
    % e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
    %
    % See also: GAMSTransfer.Container, GAMSTransfer.EquationType, GAMSTransfer.Set
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

    properties (Dependent)
        % name Equation name
        name

        % description Equation description
        description

        % type Equation type, e.g. 'leq'
        type
    end

    properties (Hidden, SetAccess = private)
        type_
    end

    properties (Hidden, Constant)
        VALUE_FIELDS = {'level', 'marginal', 'lower', 'upper', 'scale'}
        TEXT_FIELDS = {}
        SUPPORTS_FORMAT_DENSE_MATRIX = true
        SUPPORTS_FORMAT_SPARSE_MATRIX = true
        SUPPORTS_FORMAT_STRUCT = true
        SUPPORTS_FORMAT_TABLE = true
    end

    methods

        function obj = Equation(container, name, varargin)
            % Constructs a GAMS Equation, see class help.
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_container = @(x) isa(x, 'GAMSTransfer.Container');
            is_type = @(x) is_string_char(x) && ~strcmpi(x, 'description') && ...
                ~strcmpi(x, 'records') || isnumeric(x);
            is_domain = @(x) iscell(x) || isa(x, 'GAMSTransfer.Set') || ...
                is_string_char(x) && ~strcmpi(x, 'description') && ~strcmpi(x, 'records');
            addRequired(p, 'container', is_container);
            addRequired(p, 'name', is_string_char);
            if container.features.parser_optional
                addOptional(p, 'type', GAMSTransfer.EquationType.NONBINDING, is_type);
                addOptional(p, 'domain', {}, is_domain);
            else
                addParameter(p, 'type', GAMSTransfer.EquationType.NONBINDING, is_type);
                addParameter(p, 'domain', {}, is_domain);
            end
            addParameter(p, 'records', []);
            addParameter(p, 'description', '', is_string_char);
            addParameter(p, 'read_entry', nan, @isnumeric);
            addParameter(p, 'read_number_records', nan, @isnumeric);

            % parse input arguments
            if ~container.features.parser_optional
                varargin = GAMSTransfer.Utils.parserOptional2Parameter(...
                    0, {'type', 'domain'}, {'records', 'description', 'read_entry', ...
                    'read_number_records'}, varargin);
            end
            parse(p, container, name, varargin{:});

            if container.indexed
                error('Equation not allowed in indexed mode.');
            end

            domain = p.Results.domain;
            if ~iscell(domain)
                domain = {domain};
            end

            % create object
            obj = obj@GAMSTransfer.Symbol(container, name, p.Results.description, ...
                domain, p.Results.records, p.Results.read_entry, p.Results.read_number_records);
            obj.type = p.Results.type;
        end

    end

    methods

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            if ~isstring(name) && ~ischar(name)
                error('Name must be of type ''char''.');
            end
            if strcmp(obj.name_, name)
                return
            end
            obj.container.renameSymbol(obj.name_, name);
        end

        function descr = get.description(obj)
            descr = obj.description_;
        end

        function set.description(obj, descr)
            if ~isstring(descr) && ~ischar(descr)
                error('Description must be of type ''char''.');
            end
            obj.description_ = char(descr);
        end

        function typ = get.type(obj)
            typ = GAMSTransfer.EquationType.int2str(obj.type_);
        end

        function set.type(obj, typ)
            if ischar(typ) || isstring(typ)
                obj.type_ = GAMSTransfer.EquationType.str2int(typ);
            elseif isnumeric(typ)
                if ~GAMSTransfer.EquationType.isValid(typ)
                    error("Invalid variable type: %d", typ);
                end
                obj.type_ = typ;
            else
                error('Variable type must be of type ''char'' or ''numeric''.');
            end
        end

    end

    methods

        function def = getDefaultValues(obj)
            % Returns default values for given symbol type (incl. sub type)
            %
            % Different GAMS symbols have different default values for level,
            % marginal, lower, upper and scale. This function returns a vector
            % of length 5 with these default values.
            %
            % Example:
            % c = Container();
            % v = Variable(c, 'v', 'binary');
            % v.getDefaultValues() equals [0, 0, 0, 1, 1]
            %

            def = GAMSTransfer.gt_get_defaults(obj);
        end

    end

end
