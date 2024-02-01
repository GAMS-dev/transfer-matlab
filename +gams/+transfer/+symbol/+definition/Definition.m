% Symbol Definition (internal)
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
% Symbol Definition (internal)
%
classdef (Abstract) Definition < handle

    properties (Hidden, SetAccess = {?gams.transfer.symbol.definition.Definition, ?gams.transfer.symbol.Symbol})
        domains_ = {}
        values_ = {}
    end

    methods (Hidden, Static)

        function arg = validateDomains(name, index, arg)
            if ~iscell(arg)
                if isa(arg, 'gams.transfer.symbol.domain.Domain') || ...
                    isa(arg, 'gams.transfer.symbol.Set') || ...
                    isa(arg, 'gams.transfer.alias.Abstract') || ...
                    ischar(arg) || isstring(arg)
                    arg = {arg};
                else
                    error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
                end
            end
            for i = 1:numel(arg)
                if isa(arg{i}, 'gams.transfer.symbol.domain.Domain')
                    continue
                elseif isa(arg{i}, 'gams.transfer.symbol.Set') || isa(arg{i}, 'gams.transfer.alias.Abstract')
                    arg{i} = gams.transfer.symbol.domain.Regular(arg{i});
                elseif ischar(arg{i}) || isstring(arg{i})
                    arg{i} = gams.transfer.symbol.domain.Relaxed(arg{i});
                else
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.domain.Domain'', ''gams.transfer.symbol.Set'', ''char'' or ''string''.', name, index, i);
                end
            end
        end

        function arg = validateValues(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.value.Value')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.value.Value''.', name, index, i);
                end
            end
        end

    end

    properties (Dependent)
        domains
    end

    properties (Dependent, SetAccess = private)
        values
    end

    methods

        function domains = get.domains(obj)
            domains = obj.domains_;
        end

        function obj = set.domains(obj, domains)
            obj.domains_ = obj.validateDomains('domains', 1, domains);
            if numel(obj.domains) == numel(unique(obj.domainLabels()))
                return
            end
            for i = 1:numel(obj.domains_)
                obj.domains_{i}.appendLabelIndex(i);
            end
        end

        function values = get.values(obj)
            values = obj.values_;
        end

    end

    methods (Abstract)

        def = copy(obj)

    end

    methods

        function copyFrom(obj, symbol)

            % parse input arguments
            try
                symbol = gams.transfer.utils.validate('symbol', 1, symbol, {class(obj)}, -1);
            catch e
                error(e.message);
            end

            obj.domains_ = symbol.domains;
            obj.values_ = symbol.values;
        end

        function eq = equals(obj, def)
            eq = isequal(class(obj), class(def)) && ...
                isequal(obj.values_, def.values_);
            if ~eq
                return;
            end

            eq = numel(obj.domains_) == numel(def.domains_);
            for i = 1:numel(obj.domains_)
                eq = eq && obj.domains_{i}.equals(def.domains_{i});
                if ~eq
                    return
                end
            end
        end

        function status = isValid(obj)

            for i = 1:numel(obj.domains_)
                status = obj.domains_{i}.isValid();
                if status.flag ~= gams.transfer.utils.Status.OK
                    return
                end
            end

            status = gams.transfer.utils.Status.createOK();
        end

        function dim = dimension(obj)
            dim = numel(obj.domains_);
        end

        function axis = axis(obj, data, dimension)
            % TODO check dimension
            axis = gams.transfer.symbol.unique_labels.Axis(data, obj.domains_{dimension});
        end

        function axes = axes(obj, data)
            axes = gams.transfer.symbol.unique_labels.Axes(data, obj.domains_);
        end

        function n = numberDomains(obj)
            n = numel(obj.domains_);
        end

        function bases = domainBases(obj)
            dim = obj.dimension();
            bases = cell(1, dim);
            for i = 1:dim
                bases{i} = obj.domains_{i}.base;
            end
        end

        function labels = domainLabels(obj)
            dim = obj.dimension();
            labels = cell(1, dim);
            for i = 1:dim
                labels{i} = obj.domains_{i}.label;
            end
        end

        function setDomainLabels(obj, domain_labels)
            domain_labels = gams.transfer.utils.validate_cell('domain_labels', 1, domain_labels, ...
                {'string', 'char'}, 1, obj.dimension);

            add_prefix = numel(unique(domain_labels)) ~= numel(domain_labels);

            for i = 1:numel(domain_labels)
                if isequal(domain_labels{i}, gams.transfer.Constants.UNIVERSE_NAME)
                    domain_labels{i} = gams.transfer.Constants.UNIVERSE_LABEL;
                end
                obj.domains_{i}.label = domain_labels{i};
                if add_prefix
                    obj.domains_{i}.appendLabelIndex(i);
                end
            end

        end

        function names = domainNames(obj)
            dim = obj.dimension();
            names = cell(1, dim);
            for i = 1:dim
                names{i} = obj.domains_{i}.name;
            end
        end

        function n = numberValues(obj)
            n = numel(obj.values_);
        end

        function domain = getDomain(obj, label)
            domain = [];
            for i = 1:numel(obj.domains_)
                if strcmp(obj.domains_{i}.label, label)
                    domain = obj.domains_{i};
                    return
                end
            end
        end

        function value = getValue(obj, label)
            value = [];
            for i = 1:numel(obj.values_)
                if strcmp(obj.values_{i}.label, label)
                    value = obj.values_{i};
                    return
                end
            end
        end

        % function keys = valueKeys(obj)
        %     keys = fieldnames(obj.values_);
        % end

        % function labels = valueLabels(obj)
        %     labels = cell(1, obj.numberValues());
        %     keys = obj.valueKeys();
        %     for i = 1:numel(keys)
        %         labels{i} = obj.domainValue(i, keys{i});
        %     end
        % end

        function switchContainer(obj, container)
            if ~isempty(container)
                container = gams.transfer.utils.validate('container', 1, container, {'gams.transfer.Container'}, -1);
            end
            for i = 1:numel(obj.domains_)
                if ~isa(obj.domains_{i}, 'gams.transfer.symbol.domain.Regular')
                    continue
                end
                if isempty(container)
                    obj.domains_{i} = obj.domains_{i}.getRelaxed();
                    continue
                end
                if ~container.hasSymbols(obj.domains_{i}.name)
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
        end

    end

end
