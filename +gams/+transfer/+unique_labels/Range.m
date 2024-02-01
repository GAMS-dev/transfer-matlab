% Abstract UELs
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
% Abstract UELs
%

%> @brief Abstract UELs
classdef Range < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = protected)

        prefix_ = ''
        first_ = 1
        step_ = 1
        length_ = 0

    end

    methods (Static, Hidden)

        function arg = validatePrefix(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
        end

        function arg = validateFirst(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 0
                error('Argument ''%s'' (at position %d) must be non-negative.', name, index);
            end
            if isnan(arg)
                error('Argument ''%s'' (at position %d) must not be nan.', name, index);
            end
            if isinf(arg)
                error('Argument ''%s'' (at position %d) must not be inf.', name, index);
            end
        end

        function arg = validateStep(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 1
                error('Argument ''%s'' (at position %d) must be positive.', name, index);
            end
            if isnan(arg)
                error('Argument ''%s'' (at position %d) must not be nan.', name, index);
            end
            if isinf(arg)
                error('Argument ''%s'' (at position %d) must not be inf.', name, index);
            end
        end

        function arg = validateLength(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 0
                error('Argument ''%s'' (at position %d) must be non-negative.', name, index);
            end
            if isnan(arg)
                error('Argument ''%s'' (at position %d) must not be nan.', name, index);
            end
            if isinf(arg)
                error('Argument ''%s'' (at position %d) must not be inf.', name, index);
            end
        end

    end

    properties (Dependent)
        prefix
        first
        step
        length
    end

    methods

        function prefix = get.prefix(obj)
            prefix = obj.prefix_;
        end

        function set.prefix(obj, prefix)
            obj.prefix_ = obj.validatePrefix('prefix', 1, prefix);
        end

        function first = get.first(obj)
            first = obj.first_;
        end

        function set.first(obj, first)
            obj.first_ = obj.validateFirst('first', 1, first);
        end

        function step = get.step(obj)
            step = obj.step_;
        end

        function set.step(obj, step)
            obj.step_ = obj.validateStep('step', 1, step);
        end

        function length = get.length(obj)
            length = obj.length_;
        end

        function set.length(obj, length)
            obj.length_ = obj.validateLength('length', 1, length);
        end

    end

    methods

        function obj = Range(prefix, first, step, length)
            obj.prefix = prefix;
            obj.first = first;
            obj.step = step;
            obj.length = length;
        end

        function count = count(obj)
            count = obj.length_;
        end

        function labels = get(obj)
            labels = cell(1, obj.length_);
            for i = 1:obj.length_
                labels{i} = [obj.prefix_, int2str(obj.first_ + obj.step_ * (i - 1))];
            end
        end

        function labels = getAt(obj, indices)
            % TODO check indices
            labels = cell(1, numel(indices));
            for i = 1:numel(indices)
                labels{i} = [obj.prefix_, int2str(obj.first_ + obj.step_ * (indices(i) - 1))];
            end
        end

        function indices = find(obj, labels)
            % TODO check labels
            error('todo');
        end

        function clear(obj)
            obj.prefix_ = ''
            obj.first_ = 1
            obj.step_ = 1
            obj.length_ = 0
        end

        function add(obj, labels)
            error('Adding labels to a unique labels range is not supported.');
        end

        function set(obj, labels)
            error('Setting labels to a unique labels range is not supported.');
        end

        function remove(obj, labels)
            error('Removing labels from a unique labels range is not supported.');
        end

        function rename(obj, oldlabels, newlabels)
            error('Renaming labels in a unique labels range is not supported.');
        end

    end

end
