classdef Variable < GAMSTransfer.Symbol
    % GAMS Variable
    %
    % This class represents a GAMS Variable.
    %
    % Required Arguments:
    % 1. container: Container
    %    GAMSTransfer container object this symbol should be stored in
    % 2. name: string
    %    Name of variable
    %
    % Optional Arguments:
    % 3. type: string or int
    %    Specifies the variable type, either as string or as integer given by
    %    any of the constants in VariableType. Default is 'free'.
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
    % v1 = Variable(c, 'v1');
    % v2 = Variable(c, 'v2', 'binary', {'*', '*'});
    % v3 = Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
    %
    % See also: GAMSTransfer.Container, GAMSTransfer.VariableType, GAMSTransfer.Set
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
        % name Variable name
        name

        % description Variable description
        description

        % type Variable type, e.g. 'free'
        type
    end

    properties (Hidden, SetAccess = private)
        type_
    end

    methods

        function obj = Variable(container, name, varargin)
            % Constructs a GAMS Variable, see class help.
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
                addOptional(p, 'type', GAMSTransfer.VariableType.FREE, is_type);
                addOptional(p, 'domain', {}, is_domain);
            else
                addParameter(p, 'type', GAMSTransfer.VariableType.FREE, is_type);
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
                error('Variable not allowed in indexed mode.');
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
            obj.container.rename(obj.name_, name);
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
            typ = GAMSTransfer.VariableType.int2str(obj.type_);
        end

        function set.type(obj, typ)
            if ischar(typ) || isstring(typ)
                obj.type_ = GAMSTransfer.VariableType.str2int(typ);
            elseif isnumeric(typ)
                if ~GAMSTransfer.VariableType.isvalid(typ)
                    error("Invalid variable type: %d", typ);
                end
                obj.type_ = typ;
            else
                error('Variable type must be of type ''char'' or ''numeric''.');
            end
        end

    end

end
