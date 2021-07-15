classdef Alias < handle
    % GAMS Alias
    %
    % This class represents a GAMS Alias, which is a link to another GAMS Set.
    %
    % Required Arguments:
    % 1. container: Container
    %    GAMSTransfer container object this symbol should be stored in
    % 2. name: string
    %    name of alias
    % 3. aliased_with: Set or Alias
    %    GAMS Set to be linked to
    %
    % Example:
    % c = Container();
    % s = Set(c, 's');
    % a = Alias(c, 'a', s);
    %
    % See also: GAMSTransfer.Set, GAMSTransfer.Container
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
        % name name of alias
        name
    end

    properties
        % aliased_with linked GAMS Set
        aliased_with
    end

    properties (Hidden, SetAccess = private)
        container
        read_entry
    end

    properties (Hidden)
        name_
    end

    methods

        function obj = Alias(container, name, aliased_with, varargin)
            % Constructs a GAMS Alias, see class help.
            %

            % input arguments
            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            is_container = @(x) isa(x, 'GAMSTransfer.Container');
            is_alias = @(x) isa(x, 'GAMSTransfer.Set') || isa(x, 'GAMSTransfer.Alias');
            addRequired(p, 'container', is_container);
            addRequired(p, 'name', is_string_char);
            addRequired(p, 'aliased_with', is_alias);
            addParameter(p, 'read_entry', nan, @isnumeric);

            % parse inputs
            parse(p, container, name, aliased_with, varargin{:});
            obj.container = p.Results.container;
            obj.name_ = char(p.Results.name);
            aliased_with = p.Results.aliased_with;
            while isa(aliased_with, 'GAMSTransfer.Alias')
                aliased_with = aliased_with.aliased_with;
            end
            obj.aliased_with = aliased_with;

            if container.indexed
                error('Alias not allowed in indexed mode.');
            end

            % add symbol to container
            obj.container.add(obj);
        end

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

        function set.aliased_with(obj, alias)
            if ~isa(alias, 'GAMSTransfer.Set')
                error('Can only alias to sets.');
            end
            if obj.container.features.handle_comparison && ne(obj.container, alias.container)
                error('Alias and aliased set must be located in same container');
            end
            obj.aliased_with = alias;
        end

    end

    methods

        function valid = isValid(obj, varargin)
            % Checks correctness of alias
            %
            % Optional Arguments:
            % 1. verbose: logical
            %    If true, the reason for an invalid symbol is printed
            % 2. force: logical
            %    If true, forces reevaluation of validity (resets cache)
            %

            verbose = false;
            force = false;
            if nargin > 1 && varargin{1}
                verbose = true;
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            valid = false;

            % check if symbol is actually contained in container
            if ~isfield(obj.container.data, obj.name)
                if verbose
                    warning('Symbol is not part of its linked container.');
                end
                return
            end

            if ~obj.aliased_with.isValid()
                if verbose
                    warning('Linked symbol is invalid.');
                end
                return
            end

            valid = true;
        end

    end

end
