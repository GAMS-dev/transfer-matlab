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

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description') || ...
                strcmpi(x, 'read_entry') || strcmpi(x, 'read_number_records');

            % check optional arguments
            i = 1;
            etype = GAMSTransfer.EquationType.NONBINDING;
            domain = {};
            while true
                term = true;
                if i == 1 && nargin > 2
                    if is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        isnumeric(varargin{i})
                        etype = varargin{i};
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''type'' must be ''numeric'' or ''char''.');
                    end
                elseif i == 2 && nargin > 3
                    if is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        iscell(varargin{i}) || isa(varargin{i}, 'GAMSTransfer.Set')
                        domain = varargin{i};
                        if ~iscell(domain)
                            domain = {domain};
                        end
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''domain'' must be ''cell'', ''Set'', or ''char''.');
                    end
                end
                if term || i > 2
                    break;
                end
            end

            % check parameter arguments
            records = [];
            description = '';
            read_entry = nan;
            read_number_records = nan;
            while i < nargin - 2
                if strcmpi(varargin{i}, 'records')
                    records = varargin{i+1};
                elseif strcmpi(varargin{i}, 'description')
                    description = varargin{i+1};
                elseif strcmpi(varargin{i}, 'read_entry')
                    read_entry = varargin{i+1};
                elseif strcmpi(varargin{i}, 'read_number_records')
                    read_number_records = varargin{i+1};
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 2
                error('Invalid number of arguments');
            end

            if container.indexed
                error('Equation not allowed in indexed mode.');
            end

            % create object
            obj = obj@GAMSTransfer.Symbol(container, name, description, domain, ...
                records, read_entry, read_number_records);
            obj.type = etype;
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
