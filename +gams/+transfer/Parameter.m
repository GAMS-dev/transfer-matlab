% GAMS Parameter
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
% GAMS Parameter
%
% This class represents a GAMS Parameter.
%
% Required Arguments:
% 1. container (Container):
%    GAMS Transfer container object this symbol should be stored in
% 2. name (string):
%    Name of parameter
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a Set
%    object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is ''.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains
%   in case they are not present in the domains already. With a logical vector
%   domain forwarding can be enabled/disabled independently for each domain.
%   Default: false.
%
% Example:
% c = Container();
% p1 = Parameter(c, 'p1');
% p2 = Parameter(c, 'p2', {'*', '*'});
% p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
%
% See also: gams.transfer.Container, gams.transfer.Set
%

%> @brief GAMS Parameter
%>
%> **Example:**
%> ```
%> c = Container();
%> p1 = Parameter(c, 'p1');
%> p2 = Parameter(c, 'p2', {'*', '*'});
%> p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
%> ```
%>
%> @see \ref gams::transfer::Container "Container", \ref gams::transfer::Set "Set"
classdef Parameter < gams.transfer.Symbol


    properties (Dependent)
        %> Parameter name

        % name Parameter name
        name


        %> Parameter description

        % description Parameter description
        description
    end

    properties (Hidden, Constant)
        VALUE_FIELDS = {'value'}
        TEXT_FIELDS = {}
        SUPPORTS_FORMAT_DENSE_MATRIX = true
        SUPPORTS_FORMAT_SPARSE_MATRIX = true
        SUPPORTS_FORMAT_STRUCT = true
        SUPPORTS_FORMAT_TABLE = true
    end

    methods

        %> Constructs a GAMS Parameter
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref gams::transfer::Container "Container" object this symbol should
        %>    be stored in
        %> 2. name (`string`):
        %>    Name of parameter
        %>
        %> **Optional Arguments:**
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    gams::transfer::Set "Set" object. Default is `{}` (for scalar).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Parameter records. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to
        %>   the domains in case they are not present in the domains already.
        %>   With a logical vector domain forwarding can be enabled/disabled
        %>   independently for each domain. Default: `false`.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> p1 = Parameter(c, 'p1');
        %> p2 = Parameter(c, 'p2', {'*', '*'});
        %> p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
        %> ```
        %>
        %> @see \ref gams::transfer::Container "Container", \ref gams::transfer::Set "Set"
        function obj = Parameter(container, name, varargin)
            % Constructs a GAMS Parameter, see class help

            args = gams.transfer.Parameter.parseConstructArguments(container.indexed, ...
                name, varargin{:});
            obj = obj@gams.transfer.Symbol(container, args.name, args.description, ...
                args.domain, args.records, args.domain_forwarding);
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
            obj.modified = true;
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
            obj.modified = true;
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
            if ~isa(symbol, 'gams.transfer.Parameter')
                return
            end
            eq = equals@gams.transfer.Symbol(obj, symbol);
        end

        %> Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to `relaxed` if the destination
        %> container does not have equivalent domain sets, see also \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination \ref gams::transfer::Container "Container"
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
            is_dest = @(x) isa(x, 'gams.transfer.Container');
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
                newsym = gams.transfer.Parameter(destination, obj.name_);
            end

            % copy data
            copy@gams.transfer.Symbol(obj, destination, true);
        end

    end

    methods (Hidden, Static)

        function args = parseConstructArguments(indexed, name, varargin)
            args = struct;
            args.name = name;
            args.isset_name = true;

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description') || ...
                strcmpi(x, 'domain_forwarding');;

            % check optional arguments
            i = 1;
            if indexed
                args.domain = [];
            else
                args.domain = {};
            end
            args.isset_domain = false;
            while true
                term = true;
                if i == 1 && nargin > 2
                    if (indexed && isnumeric(varargin{i})) || (~indexed && ...
                        (is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        iscell(varargin{i}) || isa(varargin{i}, 'gams.transfer.Set')))
                        args.domain = varargin{i};
                        args.isset_domain = true;
                        if ~indexed && ~iscell(args.domain)
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
            args.domain_forwarding = false(1, numel(args.domain));
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
                    error('Unknown argument name: %s.', varargin{i});
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