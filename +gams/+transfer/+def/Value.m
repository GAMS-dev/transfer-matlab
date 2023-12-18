% Value Definition
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright  (c) 2020-2023 GAMS Software GmbH <support@gams.com>
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
% Value Definition
%

%> @brief Value Definition
classdef Value < handle

    properties (Hidden, SetAccess = {?gams.transfer.def.Value, ?gams.transfer.symbol.Abstract})
        key_
        type_
        label_
        default_
    end

    methods (Hidden, Static)

        function arg = validateKey(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
        end

        function arg = validateType(name, index, arg)
            if isa(arg, 'gams.transfer.def.ValueType')
                return
            end
            try
                arg = gams.transfer.def.ValueType(arg);
            catch e
                error('Argument ''%s'' (at position %d) cannot create ''gams.transfer.def.ValueType'': %s.', name, index, e.message);
            end
        end

        function arg = validateLabel(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
        end

    end

    properties (Dependent, SetAccess = private)
        key
        type
        default
    end

    properties (Dependent)
        label
    end

    methods

        function key = get.key(obj)
            key = obj.key_;
        end

        function type = get.type(obj)
            type = obj.type_;
        end

        function default = get.default(obj)
            default = obj.default_;
        end

        function label = get.label(obj)
            label = obj.label_;
        end

        function obj = set.label(obj, label)
            obj.label_ = obj.validateLabel('label', 1, label);
        end

    end

    methods (Hidden, Access = {?gams.transfer.def.Value, ?gams.transfer.symbol.Abstract})

        function obj = Value(key, type, default)
            obj.key_ = key;
            obj.type_ = type;
            obj.label_ = key;
            obj.default_ = default;
        end

    end

end
