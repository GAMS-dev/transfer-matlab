% Abstract Symbol Definition (internal)
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
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
% Abstract Symbol Definition (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = {?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract, ?gams.transfer.Container})
        domains_ = {}
        values_ = []
        last_update_ = now()
    end

    properties (Dependent)
        domains
    end

    properties (Dependent, SetAccess = private)
        values
        last_update
    end

    methods (Hidden, Static)

        function domains = createDomains(name, index, input)
            if ~iscell(input)
                if isa(input, 'gams.transfer.symbol.domain.Abstract') || ...
                    isa(input, 'gams.transfer.symbol.Set') || ...
                    isa(input, 'gams.transfer.alias.Abstract') || ...
                    ischar(input) || isstring(input)
                    input = {input};
                else
                    error(['Cannot create domains from ''%s'' (at position %d): Must be ''cell'', ', ...
                        '''gams.transfer.symbol.domain.Abstract'', ''gams.transfer.symbol.Set'' or ', ...
                        '''gams.transfer.alias.Abstract''.'], name, index);
                end
            end
            domains = cell(size(input));
            for i = 1:numel(input)
                if isa(input{i}, 'gams.transfer.symbol.domain.Abstract')
                    domains{i} = input{i};
                elseif isa(input{i}, 'gams.transfer.symbol.Set') || isa(input{i}, 'gams.transfer.alias.Abstract')
                    domains{i} = gams.transfer.symbol.domain.Regular(input{i});
                elseif ischar(input{i}) || isstring(input{i})
                    domains{i} = gams.transfer.symbol.domain.Relaxed(input{i});
                else
                    error(['Cannot create domains from ''%s'' (at position %d): Element %d must be ', ...
                        '''gams.transfer.symbol.domain.Abstract'', ''gams.transfer.symbol.Set'', ', ...
                        '''char'' or ''string''.'], name, index, i);
                end
            end
        end

    end

    methods

        function domains = get.domains(obj)
            domains = obj.domains_;
        end

        function set.domains(obj, domains)
            obj.domains_ = obj.createDomains('domains', 1, domains);
            if numel(obj.domains_) ~= numel(unique(obj.getDomainLabels()))
                for i = 1:numel(obj.domains_)
                    obj.domains_{i}.appendLabelIndex(i);
                end
            end
            obj.last_update_ = now();
        end

        function values = get.values(obj)
            if isnumeric(obj.values_) && isempty(obj.values_)
                obj.initValues()
            end
            values = obj.values_;
        end

        function last_update = get.last_update(obj)
            last_update = obj.last_update_;
            for i = 1:numel(obj.domains_)
                last_update = max(last_update, obj.domains_{i}.last_update);
            end
            for i = 1:numel(obj.values_)
                last_update = max(last_update, obj.values_{i}.last_update);
            end
        end

    end

    methods

        function def = copy(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function copyFrom(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type(class(obj));
            obj.domains_ = cell(size(def.domains));
            for i = 1:numel(obj.domains_)
                obj.domains_{i} = def.domains{i}.copy();
            end
            obj.values_ = def.values;
            obj.last_update_ = now();
        end

        function eq = equals(obj, def)
            eq = false;
            if ~isequal(class(obj), class(def)) || ~isequal(obj.values, def.values)
                return
            end
            if numel(obj.domains_) ~= numel(def.domains_)
                return
            end
            for i = 1:numel(obj.domains_)
                if ~obj.domains_{i}.equals(def.domains_{i})
                    return
                end
            end
            eq = true;
        end

        function status = isValid(obj)
            for i = 1:numel(obj.domains_)
                status = obj.domains_{i}.isValid();
                if status.flag ~= gams.transfer.utils.Status.OK
                    return
                end
            end
            status = gams.transfer.utils.Status.ok();
        end

        function dim = dimension(obj)
            dim = numel(obj.domains_);
        end

        function labels = getDomainLabels(obj)
            dim = obj.dimension();
            labels = cell(1, dim);
            for i = 1:dim
                labels{i} = obj.domains_{i}.label;
            end
        end

        function setDomainLabels(obj, domain_labels)
            gams.transfer.utils.Validator('domain_labels', 1, domain_labels).cellstr().vector().numel(obj.dimension);
            add_prefix = numel(unique(domain_labels)) ~= numel(domain_labels);
            for i = 1:numel(domain_labels)
                if isequal(domain_labels{i}, gams.transfer.Constants.UNIVERSE_NAME)
                    domain_labels{i} = gams.transfer.Constants.UNIVERSE_LABEL;
                end
                obj.domains_{i}.label = char(domain_labels{i});
                if add_prefix
                    obj.domains_{i}.appendLabelIndex(i);
                end
            end
            obj.last_update_ = now();
        end

        function domain = findDomain(obj, label)
            domain = [];
            domains = obj.domains_;
            for i = 1:numel(domains)
                if strcmp(domains{i}.label, label)
                    domain = domains{i};
                    return
                end
            end
        end

        function value = findValue(obj, label)
            value = [];
            values = obj.values;
            for i = 1:numel(values)
                if strcmp(values{i}.label, label)
                    value = values{i};
                    return
                end
            end
        end

        function switchContainer(obj, container)
            if ~isempty(container)
                gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container');
            end
            for i = 1:numel(obj.domains_)
                if ~isa(obj.domains_{i}, 'gams.transfer.symbol.domain.Regular')
                    continue
                end
                if isempty(container) || ~container.hasSymbols(obj.domains_{i}.name)
                    obj.domains_{i} = obj.domains_{i}.getRelaxed();
                    continue
                end
                symbol = container.getSymbols(obj.domains_{i}.name);
                if ~symbol.equals(obj.domains_{i}.symbol)
                    obj.domains_{i} = obj.domains_{i}.getRelaxed();
                    continue
                end
                obj.domains_{i}.symbol = symbol;
            end
            obj.last_update_ = now();
        end

    end

    methods (Hidden, Access = protected)

        function initValues(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function resetValues(obj)
            obj.initValues();
            obj.last_update_ = now();
        end

    end

end
