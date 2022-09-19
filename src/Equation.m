% GAMS Equation
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
% GAMS Equation
%
% This class represents a GAMS Equation.
%
% Required Arguments:
% 1. container (Container):
%    GAMSTransfer container object this symbol should be stored in
% 2. name (string):
%    Name of equation
% 3. type (string or int):
%    Specifies the equation type, either as string or as integer given by
%    any of the constants in EquationType.
%
% Optional Arguments:
% 4. domain (cellstr or Set):
%    List of domains given either as string or as reference to a Set
%    object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Equation records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is ''.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the
%   domains in case they are not present in the domains already. Default:
%   false.
%
% Example:
% c = Container();
% e2 = Equation(c, 'e2', 'l', {'*', '*'});
% e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
%
% See also: GAMSTransfer.Container, GAMSTransfer.EquationType, GAMSTransfer.Set
%

%> @ingroup symbol
%> @brief GAMS Equation
%>
%> **Example:**
%> ```
%> c = Container();
%> e2 = Equation(c, 'e2', 'l', {'*', '*'});
%> e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
%> ```
%>
%> @see \ref GAMSTransfer::Container "Container", \ref
%> GAMSTransfer::EquationType "EquationType", \ref GAMSTransfer::Set "Set"
classdef Equation < GAMSTransfer.Symbol


    properties (Dependent)
        %> Equation name

        % name Equation name
        name


        %> Equation description

        % description Equation description
        description


        %> Equation type, e.g. `leq`

        % type Equation type, e.g. 'leq'
        type


        %> Equation default values

        % default_values Equation default values
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

        %> Constructs a GAMS Equation
        %>
        %> See \ref GAMSTRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref GAMSTransfer::Container "Container" object this symbol should
        %>    be stored in
        %> 2. name (`string`):
        %>    Name of equation
        %> 3. type (`string` or `int`):
        %>    Specifies the equation type, either as `string` or as `integer`
        %>    given by any of the constants in \ref GAMSTransfer::EquationType
        %>    "EquationType".
        %>
        %> **Optional Arguments:**
        %> 4. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    GAMSTransfer::Set "Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Equation records. Default is `[]`.
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
        %> e2 = Equation(c, 'e2', 'l', {'*', '*'});
        %> e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
        %> ```
        %>
        %> @see \ref GAMSTransfer::Container "Container", \ref
        %> GAMSTransfer::EquationType "EquationType", \ref GAMSTransfer::Set "Set"
        function obj = Equation(container, name, etype, varargin)
            % Constructs a GAMS Equation, see class help

            if container.indexed
                error('Equation not allowed in indexed mode.');
            end

            args = GAMSTransfer.Equation.parseConstructArguments(name, etype, varargin{:});
            obj = obj@GAMSTransfer.Symbol(container, args.name, args.description, ...
                args.domain, args.records, args.domain_forwarding);
            obj.type = args.type;
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
            typ = GAMSTransfer.EquationType.int2str(obj.type_);
        end

        function set.type(obj, typ)
            if ischar(typ) || isstring(typ)
                if ~GAMSTransfer.EquationType.isValid(typ)
                    error("Invalid equation type: %s", typ);
                end
                obj.type_ = GAMSTransfer.EquationType.str2int(typ);
            elseif isnumeric(typ)
                if ~GAMSTransfer.EquationType.isValid(typ)
                    error("Invalid equation type: %d", typ);
                end
                obj.type_ = typ;
            else
                error('Equation type must be of type ''char'' or ''numeric''.');
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
            if ~isa(symbol, 'GAMSTransfer.Equation')
                return
            end
            eq = isequaln(obj.type_, symbol.type_) && ...
                equals@GAMSTransfer.Symbol(obj, symbol);
        end

        %> Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to `relaxed` if the destination
        %> container does not have equivalent domain sets, see also \ref
        %> GAMSTRANSFER_MATLAB_SYMBOL_DOMAIN.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination \ref GAMSTransfer::Container "Container"
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
                newsym = GAMSTransfer.Equation(destination, obj.name_, obj.type_);
            end

            % copy data
            copy@GAMSTransfer.Symbol(obj, destination, true);
            newsym.type_ = obj.type_;
        end

    end

    methods (Hidden, Static)

        function args = parseConstructArguments(name, etype, varargin)
            args = struct;
            args.name = name;
            args.isset_name = true;

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description') || ...
                strcmpi(x, 'domain_forwarding');

            % check required arguments
            if ischar(etype) || isstring(etype)
                if ~GAMSTransfer.EquationType.isValid(etype)
                    error("Invalid equation type: %s", etype);
                end
                etype = GAMSTransfer.EquationType.str2int(etype);
            elseif isnumeric(etype)
                if ~GAMSTransfer.EquationType.isValid(etype)
                    error("Invalid equation type: %d", etype);
                end
            else
                error('Equation type must be of type ''char'' or ''numeric''.');
            end
            args.type = etype;
            args.isset_type = true;

            % check optional arguments
            i = 1;
            args.domain = {};
            args.isset_domain = false;
            while true
                term = true;
                if i == 1 && nargin > 2
                    if is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        iscell(varargin{i}) || isa(varargin{i}, 'GAMSTransfer.Set')
                        args.domain = varargin{i};
                        args.isset_domain = true;
                        if ~iscell(args.domain)
                            args.domain = {args.domain};
                        end
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''domain'' must be ''cell'', ''Set'', or ''char''.');
                    end
                end
                if term || i > 1
                    break;
                end
            end

            % check parameter arguments
            args.records = [];
            args.isset_records = false;
            args.description = '';
            args.isset_description = false;
            args.domain_forwarding = false;
            args.isset_domain_forwarding = false;
            while i < nargin - 2
                if strcmpi(varargin{i}, 'records')
                    args.records = varargin{i+1};
                    args.isset_records = true;
                elseif strcmpi(varargin{i}, 'description')
                    args.description = varargin{i+1};
                    args.isset_description = true;
                elseif strcmpi(varargin{i}, 'domain_forwarding')
                    args.domain_forwarding = varargin{i+1};
                    args.isset_domain_forwarding = true;
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 2
                error('Invalid number of arguments');
            end
        end

    end

end
