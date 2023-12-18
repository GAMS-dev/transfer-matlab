% Data Definition
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
% Data Definition
%

%> @brief Data Definition
classdef Definition

    properties (Hidden, SetAccess = {?gams.transfer.def.Definition, ?gams.transfer.symbol.Abstract})
        domains_ = {}
        values_ = struct()
    end

    methods (Hidden, Static)

        function arg = validateDomains(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.def.Domain')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.def.Domain''.', name, index, i);
                end
            end
        end

        function arg = validateValues(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.def.Value')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.def.Value''.', name, index, i);
                end
            end
        end

    end

    properties (Dependent)
        domains
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

        function obj = set.values(obj, values)
            obj.values_ = obj.validateValues('values', 1, values);
        end

    end

    methods (Hidden, Access = {?gams.transfer.def.Definition, ?gams.transfer.symbol.Abstract})

        function obj = Definition(domains, values)
            obj.domains_ = domains;
            obj.values_ = values;
        end

    end

    methods

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

        function labels = domainLabels(obj)
            dim = obj.dimension();
            labels = cell(1, dim);
            for i = 1:dim
                labels{i} = obj.domain_{i}.label;
            end
        end

        function names = domainNames(obj)
            dim = obj.dimension();
            names = cell(1, dim);
            for i = 1:dim
                names{i} = obj.domain_{i}.name;
            end
        end

        function n = numberValues(obj)
            n = numel(fieldnames(obj.values_));
        end

        function keys = valueKeys(obj)
            keys = fieldnames(obj.values_);
        end

        function labels = valueLabels(obj)
            labels = cell(1, obj.numberValues());
            keys = obj.valueKeys();
            for i = 1:numel(keys)
                labels{i} = obj.domainValue(i, keys{i});
            end
        end

    end

end
