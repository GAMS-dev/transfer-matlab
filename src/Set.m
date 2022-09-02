% GAMS Set
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
% GAMS Set
%
% This class represents a GAMS Set.
%
% Required Arguments:
% 1. container (Container):
%    GAMSTransfer container object this symbol should be stored in
% 2. name (string):
%    Name of set
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a Set
%    object. Default is {'*'} (for 1-dim with universe domain).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is ''.
% - is_singleton (logical):
%   Indicates if set is a is_singleton set (true) or not (false). Default is false.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the
%   domains in case they are not present in the domains already. Default:
%   false.
%
% Example:
% c = Container();
% s1 = Set(c, 's1');
% s2 = Set(c, 's2', {s1, '*', '*'});
% s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%
% See also: GAMSTransfer.Container
%

%> @ingroup symbol
%> @brief GAMS Set
%>
%> **Example:**
%> ```
%> c = Container();
%> s1 = Set(c, 's1');
%> s2 = Set(c, 's2', {s1, '*', '*'});
%> s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%> ```
%>
%> @see \ref GAMSTransfer::Container "Container"
classdef Set < GAMSTransfer.Symbol

    properties (Dependent)
        %> Set name

        % name Set name
        name


        %> Set description

        % description Set description
        description
    end

    properties
        %> indicator if Set is is_singleton

        % is_singleton indicator if Set is is_singleton
        is_singleton
    end

    properties (Hidden, Constant)
        VALUE_FIELDS = {}
        TEXT_FIELDS = {'text'}
        SUPPORTS_FORMAT_DENSE_MATRIX = false
        SUPPORTS_FORMAT_SPARSE_MATRIX = false
        SUPPORTS_FORMAT_STRUCT = true
        SUPPORTS_FORMAT_TABLE = true
    end

    methods

        %> Constructs a GAMS Set
        %>
        %> See \ref GAMSTRANSFER_MATLAB_SYMBOL_CREATE for more information.
        %>
        %> **Required Arguments:**
        %> 1. container (`Container`):
        %>    \ref GAMSTransfer::Container "Container" object this symbol should
        %>    be stored in
        %> 2. name (`string`):
        %>    Name of set
        %>
        %> **Optional Arguments:**
        %> 3. domain (`cellstr` or `Set`):
        %>    List of domains given either as `string` or as reference to a \ref
        %>    GAMSTransfer::Set "Set" object. Default is `{"*"}` (for 1-dim with
        %>    universe domain).
        %>
        %> **Parameter Arguments:**
        %> - records:
        %>   Set records, e.g. a list of strings. Default is `[]`.
        %> - description (`string`):
        %>   Description of symbol. Default is `""`.
        %> - is_singleton (`logical`):
        %>   Indicates if set is a is_singleton set (`true`) or not (`false`). Default
        %>   is `false`.
        %> - domain_forwarding (`logical`):
        %>   If `true`, domain entries in records will recursively be added to the
        %>   domains in case they are not present in the domains already. Default:
        %>   `false`.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> s1 = Set(c, 's1');
        %> s2 = Set(c, 's2', {s1, '*', '*'});
        %> s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
        %> ```
        %>
        %> @see \ref GAMSTransfer::Container "Container"
        function obj = Set(container, name, varargin)
            % Constructs a GAMS Set, see class help

            if container.indexed
                error('Set not allowed in indexed mode.');
            end

            % create object
            args = GAMSTransfer.Set.parseConstructArguments(name, varargin{:});
            obj = obj@GAMSTransfer.Symbol(container, args.name, args.description, ...
                args.domain, args.records, args.domain_forwarding);
            obj.is_singleton = args.is_singleton;
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

        function set.is_singleton(obj, is_singleton)
            if ~islogical(is_singleton)
                error('is_singleton must be of type ''logical''.');
            end
            obj.is_singleton = is_singleton;
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
            if ~isa(symbol, 'GAMSTransfer.Set')
                return
            end
            eq = obj.is_singleton == symbol.is_singleton && ...
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
                newsym = GAMSTransfer.Set(destination, obj.name_);
            end

            % copy data
            copy@GAMSTransfer.Symbol(obj, destination, true);
            newsym.is_singleton = obj.is_singleton;
        end

    end

    methods (Hidden)

        function bool = isValidAsDomain(obj)
            % Checks if set could be used as a domain of a different symbol
            %
            % b = isValidAsDomain() returns true if this set can be used as
            % domain and false otherwise.
            %

            bool = false;
            if ~obj.isValid()
                return
            end
            if obj.dimension ~= 1
                return
            end
            bool = true;
        end

    end

    methods (Hidden, Static, Access = private)

        function args = parseConstructArguments(name, varargin)
            args = struct;
            args.name = name;

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description') || ...
                strcmpi(x, 'is_singleton');

            % check optional arguments
            i = 1;
            args.domain = {'*'};
            while true
                term = true;
                if i == 1 && nargin > 1
                    if is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        iscell(varargin{i}) || isa(varargin{i}, 'GAMSTransfer.Set')
                        args.domain = varargin{i};
                        if ~iscell(args.domain)
                            args.domain = {args.domain};
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
            args.records = [];
            args.description = '';
            args.is_singleton = false;
            args.domain_forwarding = false;
            while i < nargin - 1
                if strcmpi(varargin{i}, 'records')
                    args.records = varargin{i+1};
                elseif strcmpi(varargin{i}, 'description')
                    args.description = varargin{i+1};
                elseif strcmpi(varargin{i}, 'is_singleton')
                    args.is_singleton = varargin{i+1};
                elseif strcmpi(varargin{i}, 'domain_forwarding')
                    args.domain_forwarding = varargin{i+1};
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 1
                error('Invalid number of arguments');
            end

        end

    end

end
