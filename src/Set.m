classdef Set < GAMSTransfer.Symbol
    % GAMS Set
    %
    % This class represents a GAMS Set.
    %
    % Required Arguments:
    % 1. container: Container
    %    GAMSTransfer container object this symbol should be stored in
    % 2. name: string
    %    Name of set
    %
    % Optional Arguments:
    % 3. domain: cell of string or Set
    %    List of domains given either as string or as reference to a Set
    %    object. Default is {'*'} (for 1-dim with universe domain).
    %
    % Parameter Arguments:
    % - records:
    %   Set records, e.g. a list of strings. Default is [].
    % - description: string
    %   Description of symbol. Default is ''.
    % - singleton: logical
    %   Indicates if set is a singleton set (true) or not (false). Default is false.
    %
    % Example:
    % c = Container();
    % s1 = Set(c, 's1');
    % s2 = Set(c, 's2', {s1, '*', '*'});
    % s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
    %
    % See also: GAMSTransfer.Container
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
        % name Set name
        name

        % description Set description
        description
    end

    properties
        % singleton indicator if Set is singleton
        singleton
    end

    methods

        function obj = Set(container, name, varargin)
            % Constructs a GAMS Set, see class help.
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_container = @(x) isa(x, 'GAMSTransfer.Container');
            is_domain = @(x) iscell(x) || isa(x, 'GAMSTransfer.Set') || ...
                is_string_char(x) && ~strcmpi(x, 'description') && ~strcmpi(x, 'singleton') && ...
                ~strcmpi(x, 'records');
            addRequired(p, 'container', is_container);
            addRequired(p, 'name', is_string_char);
            if container.features.parser_optional
                addOptional(p, 'domain', {'*'}, is_domain);
            else
                addParameter(p, 'domain', {'*'}, is_domain);
            end
            addParameter(p, 'records', []);
            addParameter(p, 'description', '', is_string_char);
            addParameter(p, 'singleton', false, @islogical);
            addParameter(p, 'read_entry', nan, @isnumeric);
            addParameter(p, 'read_number_records', nan, @isnumeric);

            % parse input arguments
            if ~container.features.parser_optional
                varargin = GAMSTransfer.Utils.parserOptional2Parameter(...
                    0, {'domain'}, {'records', 'description', 'singleton', ...
                    'read_entry', 'read_number_records'}, varargin);
            end
            parse(p, container, name, varargin{:});

            if container.indexed
                error('Set not allowed in indexed mode.');
            end

            domain = p.Results.domain;
            if ~iscell(domain)
                domain = {domain};
            end

            % create object
            obj = obj@GAMSTransfer.Symbol(container, name, p.Results.description, ...
                domain, p.Results.records, p.Results.read_entry, p.Results.read_number_records);
            obj.singleton = p.Results.singleton;
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

        function set.singleton(obj, singleton)
            if ~islogical(singleton)
                error('Singleton must be of type ''logical''.');
            end
            obj.singleton = singleton;
        end

    end

    methods

        function bool = isValidAsDomain(obj)
            % Checks if set could be used as a domain of a different symbol
            %
            % b = isValidAsDomain() returns true if this set can be used as
            % domain and false otherwise.
            %

            bool = false;
            if ~obj.is_valid
                return
            end
            if obj.dimension ~= 1
                return
            end
            bool = true;
        end

    end

end
