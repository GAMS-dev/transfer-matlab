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
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
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

        function size = size(obj)
            dim = obj.dimension();
            size = nan(1, dim);
            for i = 1:dim
                size(i) = obj.domains_{i}.size;
            end
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

        function setDomainLabels(obj, labels)
            % TODO check labels

            add_prefix = numel(unique(labels)) ~= numel(labels);

            for i = 1:numel(labels)
                if isequal(labels{i}, gams.transfer.Constants.UNIVERSE_NAME)
                    labels{i} = gams.transfer.Constants.UNIVERSE_LABEL;
                end
                obj.domains_{i}.label = labels{i};
                if add_prefix
                    obj.domains_{i} = obj.domains_{i}.appendLabelIndex(i);
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

    end

end
