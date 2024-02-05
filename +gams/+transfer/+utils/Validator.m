% Validator (internal)
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
% Validator (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef Validator

    properties
        name
        index
        value
    end

    methods

        function obj = Validator(name, index, value)
            obj.name = name;
            obj.index = index;
            obj.value = value;
        end

        function obj = string2char(obj)
            if iscell(obj.value)
                for i = 1:numel(obj.value)
                    if isstring(obj.value{i})
                        obj.value{i} = char(obj.value{i});
                    end
                end
            end
            if isstring(obj.value)
                obj.value = char(obj.value);
            end
        end

        function obj = type(obj, class)
            if ~isa(obj.value, class)
                error('Argument ''%s'' (at position %d) must be ''%s''.', obj.name, obj.index, class);
            end
        end

        function obj = types(obj, classes)
            is_class = false;
            for i = 1:numel(classes)
                if isa(obj.value, classes{i})
                    is_class = true;
                    break;
                end
            end

            if is_class
                return
            end

            class_list = '';
            for i = 1:numel(classes)
                if i > 1
                    if i == numel(classes)
                        class_list = strcat(class_list, ' or ');
                    else
                        class_list = strcat(class_list, ', ');
                    end
                end
                class_list = strcat(class_list, '''', classes{i}, '''');
            end
            error('Argument ''%s'' (at position %d) must be %s.', obj.name, obj.index, class_list);
        end

        function obj = cellstr(obj)
            if ~iscell(obj.value)
                error('Argument ''%s'' (at position %d) must be ''cell''.', obj.name, obj.index);
            end
            for i = 1:numel(obj.value)
                if ~isstring(obj.value{i}) && ~ischar(obj.value{i})
                    error('Argument ''%s{%d}'' (at position %d) must be ''string'' or ''char''.', obj.name, i, obj.index);
                end
            end
        end

        function obj = scalar(obj)
            if ~isscalar(obj.value)
                error('Argument ''%s'' (at position %d) must be scalar.', obj.name, obj.index);
            end
        end

        function obj = vector(obj)
            if ~isvector(obj.value)
                error('Argument ''%s'' (at position %d) must be vector.', obj.name, obj.index);
            end
        end

        function obj = nonempty(obj)
            if isempty(obj.value)
                error('Argument ''%s'' (at position %d) must be non-empty.', obj.name, obj.index);
            end
        end

        function obj = numel(obj, n)
            if numel(obj.value) ~= n
                error('Argument ''%s'' (at position %d) must have %d elements.', obj.name, obj.index, n);
            end
        end

        function obj = varname(obj)
            if ~isvarname(obj.value)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', obj.name, obj.index)
            end
        end

    end

end
