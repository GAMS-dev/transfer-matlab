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

    %#ok<*INUSD,*STOUT,*PROPLC>

    properties (Hidden, SetAccess = {?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract, ?gams.transfer.Container})
        domains_ = {}
        values_ = []
        time_ = gams.transfer.utils.Time()
    end

    properties (Dependent)
        domains
        values
    end

    methods (Hidden, Static)

        function domains = createDomains(name, index, input)
            if ~iscell(input)
                if isa(input, 'gams.transfer.symbol.domain.Abstract') || ...
                    isa(input, 'gams.transfer.symbol.Set') || ...
                    isa(input, 'gams.transfer.alias.Abstract') || ...
                    ischar(input) || isstring(input) && numel(input) == 1
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
                elseif ischar(input{i}) || isstring(input{i}) && numel(input{i}) == 1
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
            if numel(obj.domains_) > 1 && numel(obj.domains_) ~= numel(unique(obj.getDomainLabels()))
                for i = 1:numel(obj.domains_)
                    obj.domains_{i}.appendLabelIndex_(i);
                end
            end
            obj.time_ = obj.time_.reset();
        end

        function values = get.values(obj)
            if isnumeric(obj.values_) && isempty(obj.values_)
                obj.initValues_()
            end
            values = obj.values_;
        end

        function set.values(obj, values)
            obj.values_ = gams.transfer.utils.Validator('values', 1, values) ...
                .cellof('gams.transfer.symbol.value.Abstract').value;
        end

    end

    methods

        function def = copy(obj)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function eq = equals(obj, def)
            eq = false;
            if ~isequal(class(obj), class(def))
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
            if numel(obj.values) ~= numel(def.values)
                return
            end
            for i = 1:numel(obj.values_)
                if ~obj.values_{i}.equals(def.values_{i})
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

    end

    methods (Hidden, Access = {?gams.transfer.symbol.definition.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.Container})

        function [flag, time] = updatedAfter_(obj, time)
            flag = true;
            if time <= obj.time_
                time = obj.time_;
                return
            end
            for i = 1:numel(obj.domains_)
                [flag_, time_] = obj.domains_{i}.updatedAfter_(time);
                if flag_
                    obj.time_ = time_;
                    time = time_;
                    return
                end
            end
            for i = 1:numel(obj.values_)
                [flag_, time_] = obj.values_{i}.updatedAfter_(time);
                if flag_
                    obj.time_ = time_;
                    time = time_;
                    return
                end
            end
            flag = false;
        end

        function copyFrom_(obj, def)
            obj.domains_ = cell(size(def.domains));
            for i = 1:numel(obj.domains_)
                obj.domains_{i} = def.domains{i}.copy();
            end
            obj.values_ = def.values;
            obj.time_ = obj.time_.reset();
        end

        function setDomainLabels_(obj, domain_labels)
            add_prefix = numel(unique(domain_labels)) ~= numel(domain_labels);
            for i = 1:numel(domain_labels)
                if isequal(domain_labels{i}, gams.transfer.Constants.UNIVERSE_NAME)
                    domain_labels{i} = gams.transfer.Constants.UNIVERSE_LABEL;
                end
                obj.domains_{i}.label = char(domain_labels{i});
                if add_prefix
                    obj.domains_{i}.appendLabelIndex_(i);
                end
            end
            obj.time_ = obj.time_.reset();
        end

        function domain = findDomain_(obj, label)
            domain = [];
            domains = obj.domains_;
            for i = 1:numel(domains)
                if strcmp(domains{i}.label, label)
                    domain = domains{i};
                    return
                end
            end
        end

        function value = findValue_(obj, label)
            value = [];
            values = obj.values;
            for i = 1:numel(values)
                if strcmp(values{i}.label, label)
                    value = values{i};
                    return
                end
            end
        end

        function switchContainer_(obj, container)
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
            obj.time_ = obj.time_.reset();
        end

        function initValues_(obj)
            st = dbstack;
            error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function resetValues_(obj)
            obj.initValues_();
            obj.time_ = obj.time_.reset();
        end

    end

    methods

        function copyFrom(obj, def)
            gams.transfer.utils.Validator('def', 1, def).type(class(obj));
            obj.copyFrom_(def);
        end

        function domain = findDomain(obj, label)
            label = gams.transfer.utils.Validator('label', 1, label).string2char().type('char').value;
            domain = obj.findDomain_(label);
        end

        function value = findValue(obj, label)
            label = gams.transfer.utils.Validator('label', 1, label).string2char().type('char').value;
            value = obj.findValue_(label);
        end

        function setDomainLabels(obj, domain_labels)
            gams.transfer.utils.Validator('domain_labels', 1, domain_labels).cellstr().vector().numel(obj.dimension);
            obj.setDomainLabels_(domain_labels);
        end

    end

end
