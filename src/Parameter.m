classdef Parameter < GAMSTransfer.Symbol
    % GAMS Parameter
    %
    % This class represents a GAMS Parameter.
    %
    % Required Arguments:
    % 1. container: Container
    %    GAMSTransfer container object this symbol should be stored in
    % 2. name: string
    %    Name of parameter
    %
    % Optional Arguments:
    % 3. domain: cell of string or Set
    %    List of domains given either as string or as reference to a Set
    %    object. Default is {} (for scalar).
    %
    % Parameter Arguments:
    % - records:
    %   Set records, e.g. a list of strings. Default is [].
    % - description: string
    %   Description of symbol. Default is ''.
    % - grow_domain: logical
    %   If true, domain entries in records will recursively be added to the
    %   domains in case they are not present in the domains already. Default:
    %   false.
    %
    % Example:
    % c = Container();
    % p1 = Parameter(c, 'p1');
    % p2 = Parameter(c, 'p2', {'*', '*'});
    % p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
    %
    % See also: GAMSTransfer.Container, GAMSTransfer.Set
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
        % name Parameter name
        name

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

        function obj = Parameter(container, name, varargin)
            % Constructs a GAMS Parameter, see class help.
            %

            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_parname = @(x) strcmpi(x, 'records') || strcmpi(x, 'description') || ...
                strcmpi(x, 'read_entry') || strcmpi(x, 'read_number_records');
            idxed = container.indexed;

            % check optional arguments
            i = 1;
            if idxed
                domain = [];
            else
                domain = {};
            end
            while true
                term = true;
                if i == 1 && nargin > 2
                    if (idxed && isnumeric(varargin{i})) || (~idxed && ...
                        (is_string_char(varargin{i}) && ~is_parname(varargin{i}) || ...
                        iscell(varargin{i}) || isa(varargin{i}, 'GAMSTransfer.Set')))
                        domain = varargin{i};
                        if ~idxed && ~iscell(domain)
                            domain = {domain};
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
            records = [];
            description = '';
            read_entry = nan;
            read_number_records = nan;
            grow_domain = false;
            while i < nargin - 2
                if strcmpi(varargin{i}, 'records')
                    records = varargin{i+1};
                elseif strcmpi(varargin{i}, 'description')
                    description = varargin{i+1};
                elseif strcmpi(varargin{i}, 'read_entry')
                    read_entry = varargin{i+1};
                elseif strcmpi(varargin{i}, 'read_number_records')
                    read_number_records = varargin{i+1};
                elseif strcmpi(varargin{i}, 'grow_domain')
                    grow_domain = varargin{i+1};
                else
                    error('Unknown argument name: %s.', varargin{i});
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 2
                error('Invalid number of arguments');
            end

            % create object
            obj = obj@GAMSTransfer.Symbol(container, name, description, domain, ...
                records, grow_domain, read_entry, read_number_records);
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

    end

end
