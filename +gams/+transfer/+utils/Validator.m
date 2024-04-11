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
                    if isstring(obj.value{i}) && isscalar(obj.value{i})
                        obj.value{i} = char(obj.value{i});
                    end
                end
            end
            if isstring(obj.value) && isscalar(obj.value)
                obj.value = char(obj.value);
            end
        end

        function obj = toCell(obj)
            if ~iscell(obj.value)
                obj.value = {obj.value};
            end
        end

        function obj = fileExtension(obj, ext)
            [~, ~, ext_] = fileparts(obj.value);
            if ~strcmpi(ext_, ext)
                error('Argument ''%s'' (at position %d) must be file name with ''%s'' extension.', obj.name, obj.index, ext);
            end
        end

        function obj = fileExists(obj)
            obj.value = gams.transfer.utils.absolute_path(obj.value);
            if ~isfile(obj.value)
                error('Argument ''%s'' (at position %d) must name a file that exists.', obj.name, obj.index);
            end
        end

        function obj = type(obj, class, allow_none)
            if nargin == 2
                allow_none = false;
            end
            if allow_none && isnumeric(obj.value) && isempty(obj.value)
                return
            end
            if ~isa(obj.value, class)
                none_class = '';
                if allow_none
                    none_class = '[] or ';
                end
                error('Argument ''%s'' (at position %d) must be %s''%s''.', obj.name, obj.index, none_class, class);
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

        function obj = symbolName(obj)
            if isstring(obj.value) && isscalar(obj.value)
                obj.value = char(obj.value);
            end
            if ~ischar(obj.value)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', obj.name, obj.index);
            end
            if numel(obj.value) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', obj.name, obj.index);
            end
            if numel(obj.value) >= gams.transfer.Constants.MAX_NAME_LENGTH
                error('Argument ''%s'' (at position %d) length must be smaller than %d.', obj.name, obj.index, gams.transfer.Constants.MAX_NAME_LENGTH);
            end
            if ~isvarname(obj.value)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', obj.name, obj.index)
            end
        end

        function obj = symbolDescription(obj)
            if isstring(obj.value) && isscalar(obj.value)
                obj.value = char(obj.value);
            end
            if ~ischar(obj.value)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', obj.name, obj.index);
            end
            if numel(obj.value) >= gams.transfer.Constants.MAX_NAME_LENGTH
                error('Argument ''%s'' (at position %d) length must be smaller than %d.', obj.name, obj.index, gams.transfer.Constants.MAX_DESCRIPTION_LENGTH);
            end
        end

        function obj = cell(obj)
            if ~iscell(obj.value)
                error('Argument ''%s'' (at position %d) must be ''cell''.', obj.name, obj.index);
            end
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

        function obj = cellof(obj, class, allow_none)
            if nargin == 2
                allow_none = false;
            end
            if ~iscell(obj.value)
                error('Argument ''%s'' (at position %d) must be ''cell''.', obj.name, obj.index);
            end
            for i = 1:numel(obj.value)
                if allow_none && isnumeric(obj.value{i}) && isempty(obj.value{i})
                    continue
                end
                if ~isa(obj.value{i}, class)
                    none_class = '';
                    if allow_none
                        none_class = '[] or ';
                    end
                    error('Argument ''%s{%d}'' (at position %d) must be %s''%s''.', obj.name, i, obj.index, none_class, class);
                end
            end
        end

        function obj = numeric(obj)
            if ~isnumeric(obj.value)
                error('Argument ''%s'' (at position %d) must be numeric.', obj.name, obj.index);
            end
        end

        function obj = integer(obj)
            if ~isnumeric(obj.value)
                error('Argument ''%s'' (at position %d) must be numeric.', obj.name, obj.index);
            end
            if any(round(obj.value) ~= obj.value)
                error('Argument ''%s'' (at position %d) must be integer.', obj.name, obj.index);
            end
        end

        function obj = noNanInf(obj)
            if isnan(obj.value)
                error('Argument ''%s'' (at position %d) must not be nan.', obj.name, obj.index);
            end
            if isinf(obj.value)
                error('Argument ''%s'' (at position %d) must not be inf.', obj.name, obj.index);
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

        function obj = minnumel(obj, n)
            if numel(obj.value) < n
                error('Argument ''%s'' (at position %d) must have at least %d elements.', obj.name, obj.index, n);
            end
        end

        function obj = maxnumel(obj, n)
            if numel(obj.value) > n
                error('Argument ''%s'' (at position %d) must have at most %d elements.', obj.name, obj.index, n);
            end
        end

        function obj = min(obj, value)
            if min(obj.value(:)) < value
                error('Argument ''%s'' (at position %d) must be equal to or larger than %g.', obj.name, obj.index, value);
            end
        end

        function obj = max(obj, value)
            if max(obj.value(:)) > value
                error('Argument ''%s'' (at position %d) must be equal to or smaller than %g.', obj.name, obj.index, value);
            end
        end

        function obj = in(obj, list)
            for i = 1:numel(list)
                if isequaln(obj.value, list{i})
                    return
                end
            end
            error('Argument ''%s'' (at position %d) does not match any of the allowed values.', obj.name, obj.index);
        end

        function obj = inInterval(obj, left, right)
            if min(obj.value(:)) < left || max(obj.value(:)) > right
                error('Argument ''%s'' (at position %d) must be in [%g,%g].', obj.name, obj.index, left, right);
            end
        end

        function obj = varname(obj)
            if ~isvarname(obj.value)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', obj.name, obj.index)
            end
        end

    end

    methods (Static)

        function minargin(argin, n)
            if argin < n
                error('Argument %d missing.', argin + 1);
            end
        end

    end

end
