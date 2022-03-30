% GAMS Variable
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
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
% ------------------------------------------------------------------------------
%
% GAMS Variable
%
% This class represents a GAMS Variable.
%
% Required Arguments:
% 1. container (Container):
%    GAMSTransfer container object this symbol should be stored in
% 2. name (string):
%    Name of variable
%
% Optional Arguments:
% 3. type (string or int):
%    Specifies the variable type, either as string or as integer given by
%    any of the constants in VariableType. Default is 'free'.
% 4. domain (cellstr or Set):
%    List of domains given either as string or as reference to a Set
%    object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is ''.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the
%   domains in case they are not present in the domains already. Default:
%   false.
%
% Example:
% c = Container();
% v1 = Variable(c, 'v1');
% v2 = Variable(c, 'v2', 'binary', {'*', '*'});
% v3 = Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%
% See also: GAMSTransfer.Container, GAMSTransfer.VariableType, GAMSTransfer.Set
%

%> GAMS Variable
%>
%> This class represents a GAMS Variable.
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    GAMSTransfer container object this symbol should be stored in
%> 2. name (`string`):
%>    Name of variable
%>
%> **Optional Arguments:**
%> 3. type (`string` or `int`):
%>    Specifies the variable type, either as string or as integer given by
%>    any of the constants in VariableType. Default is `"free"`.
%> 4. domain (`cellstr` or `Set`):
%>    List of domains given either as string or as reference to a Set
%>    object. Default is `{}` (for scalar).
%>
%> **Parameter Arguments:**
%> - records:
%>   Set records, e.g. a list of strings. Default is `[]`.
%> - description (`string`):
%>   Description of symbol. Default is `""`.
%> - domain_forwarding (`logical`):
%>   If `true`, domain entries in records will recursively be added to the
%>   domains in case they are not present in the domains already. Default:
%>   `false`.
%>
%> **Example:**
%> ```
%> c = Container();
%> v1 = Variable(c, 'v1');
%> v2 = Variable(c, 'v2', 'binary', {'*', '*'});
%> v3 = Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%> ```
%>
%> @see \ref GAMSTransfer::Container "Container", \ref
%> GAMSTransfer::VariableType "VariableType", \ref GAMSTransfer::Set "Set"

classdef Variable < GAMSTransfer.Symbol


    properties (Dependent)
        %> Variable name

        % name Variable name
        name


        %> Variable description

        % description Variable description
        description


        %> Variable type, e.g. 'free'

        % type Variable type, e.g. 'free'
        type


        %> Variable default values

        % default_values Variable default values
        default_values
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

        %> Constructs a GAMS Variable, see class help
        function obj = Variable(container, name, varargin)
            % Constructs a GAMS Variable, see class help

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description');

            % check optional arguments
            i = 1;
            vtype = GAMSTransfer.VariableType.FREE;
            domain = {};
            while true
                term = true;
                if i == 1 && nargin > 2
                    if is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        isnumeric(varargin{i})
                        vtype = varargin{i};
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''type'' must be ''integer'' or ''char''.');
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
            domain_forwarding = false;
            while i < nargin - 2
                if strcmpi(varargin{i}, 'records')
                    records = varargin{i+1};
                elseif strcmpi(varargin{i}, 'description')
                    description = varargin{i+1};
                elseif strcmpi(varargin{i}, 'domain_forwarding')
                    domain_forwarding = varargin{i+1};
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
                error('Variable not allowed in indexed mode.');
            end

            % create object
            obj = obj@GAMSTransfer.Symbol(container, name, description, domain, ...
                records, domain_forwarding);
            obj.type = vtype;
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
            name = char(name);
            if numel(name) >= 64
                error('Symbol name too long. Name length must be smaller than 64.');
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
            descr = char(descr);
            if numel(descr) >= 256
                error('Symbol description too long. Name length must be smaller than 256.');
            end
            obj.description_ = descr;
        end

        function typ = get.type(obj)
            typ = GAMSTransfer.VariableType.int2str(obj.type_);
        end

        function set.type(obj, typ)
            if ischar(typ) || isstring(typ)
                obj.type_ = GAMSTransfer.VariableType.str2int(typ);
            elseif isnumeric(typ)
                if ~GAMSTransfer.VariableType.isValid(typ)
                    error("Invalid variable type: %d", typ);
                end
                obj.type_ = typ;
            else
                error('Variable type must be of type ''char'' or ''numeric''.');
            end
        end

        function def = get.default_values(obj)
            def_vals = GAMSTransfer.gt_cmex_get_defaults(obj);
            def = struct();
            def.level = def_vals(1);
            def.marginal = def_vals(2);
            def.lower = def_vals(3);
            def.upper = def_vals(4);
            def.scale = def_vals(5);
        end

    end

    methods

        %> Checks equivalence with other symbol
        %>
        %> @note A symbol is always linked to a container. This method does not
        %> check equivalence of the linked containers.
        %>
        %> **Required Arguments:**
        %> 1. symbol (`any`):
        %>    Other symbol
        function eq = equals(obj, symbol)
            % Checks equivalence with other symbol
            %
            % Note: A symbol is always linked to a container. This method does
            % not check equivalence of the linked containers.
            %
            % Required Arguments:
            % 1. symbol (any):
            %    Other symbol

            eq = false;
            if ~isa(symbol, 'GAMSTransfer.Variable')
                return
            end
            eq = isequaln(obj.type_, symbol.type_) && ...
                equals@GAMSTransfer.Symbol(obj, symbol);
        end

        %> Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to relaxed if the destination container
        %> does not have equivalent domain sets.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`)
        %>    Destination container
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`.
        %>    Default: `false`.
        function copy(obj, varargin)
            % Copies symbol to destination container
            %
            % Symbol domains are downgraded to relaxed if the destination
            % container does not have equivalent domain sets.
            %
            % Required Arguments:
            % 1. destination (Container):
            %    Destination container
            %
            % Optional Arguments:
            % 2. overwrite (bool):
            %    Overwrites symbol with same name in destination if true.
            %    Default: false.

            % input arguments
            p = inputParser();
            is_dest = @(x) isa(x, 'GAMSTransfer.Container');
            addRequired(p, 'destination', is_dest);
            addOptional(p, 'overwrite', '', @islogical);
            parse(p, varargin{:});
            destination = p.Results.destination;
            overwrite = p.Results.overwrite;

            % create new (empty) symbol
            if isfield(destination.data, obj.name_)
                if ~overwrite
                    error('Symbol already exists in destination.');
                end
                newsym = destination.data.(obj.name_);
            else
                newsym = GAMSTransfer.Variable(destination, obj.name_);
            end

            % copy data
            copy@GAMSTransfer.Symbol(obj, destination, true);
            newsym.type_ = obj.type_;
        end

    end

end
