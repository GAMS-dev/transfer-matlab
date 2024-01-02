% GAMS Variable Type
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
% GAMS Variable Type
%

%> @brief Variable Type
classdef VariableType

    properties (Constant)
        BINARY = uint8(1)
        INTEGER = uint8(2)
        POSITIVE = uint8(3)
        NEGATIVE = uint8(4)
        FREE = uint8(5)
        SOS1 = uint8(6)
        SOS2 = uint8(7)
        SEMICONT = uint8(8)
        SEMIINT = uint8(9)
    end

    properties (Hidden, SetAccess = protected)
        value_ = uint8(5)
    end

    methods (Hidden, Static)

        function arg = validateValue(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 1 || arg > 9
                error('Argument ''%s'' (at position %d) must be in [1, 9].', name, index);
            end
            arg = uint8(arg);
        end

        function arg = validateSelect(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            switch upper(arg)
            case 'BINARY'
                arg = gams.transfer.symbol.VariableType.BINARY;
            case 'INTEGER'
                arg = gams.transfer.symbol.VariableType.INTEGER;
            case 'POSITIVE'
                arg = gams.transfer.symbol.VariableType.POSITIVE;
            case 'NEGATIVE'
                arg = gams.transfer.symbol.VariableType.NEGATIVE;
            case 'FREE'
                arg = gams.transfer.symbol.VariableType.FREE;
            case 'SOS1'
                arg = gams.transfer.symbol.VariableType.SOS1;
            case 'SOS2'
                arg = gams.transfer.symbol.VariableType.SOS2;
            case 'SEMICONT'
                arg = gams.transfer.symbol.VariableType.SEMICONT;
            case 'SEMIINT'
                arg = gams.transfer.symbol.VariableType.SEMIINT;
            otherwise
                error('Argument ''%s'' (at position %d) is invalid selection: %s.', name, index, arg);
            end
        end

    end

    properties (Dependent)
        % Selection of enum option
        select
        % Value of enum option
        value
    end

    methods

        function select = get.select(obj)
            switch obj.value_
            case obj.BINARY
                select = 'BINARY';
            case obj.INTEGER
                select = 'INTEGER';
            case obj.POSITIVE
                select = 'POSITIVE';
            case obj.NEGATIVE
                select = 'NEGATIVE';
            case obj.FREE
                select = 'FREE';
            case obj.SOS1
                select = 'SOS1';
            case obj.SOS2
                select = 'SOS2';
            case obj.SEMICONT
                select = 'SEMICONT';
            case obj.SEMIINT
                select = 'SEMIINT';
            otherwise
                error('Invalid variable type value: %d', obj.value_);
            end
        end

        function obj = set.select(obj, select)
            obj.value_ = obj.validateSelect('select', 1, select);
        end

        function value = get.value(obj)
            value = obj.value_;
        end

        function obj = set.value(obj, value)
            obj.value_ = obj.validateValue('value', 1, value);
        end

    end

    methods

        function obj = VariableType(value)
            if nargin == 0
                return
            end
            if ischar(value) || isstring(value)
                obj.select = value;
            elseif isnumeric(value)
                obj.value = value;
            else
                error('Argument ''value'' (at position 1) must be ''string'', ''char'' or numeric.');
            end
        end

    end

    methods (Static)

        function obj = Binary()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.BINARY;
        end

        function obj = Integer()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.INTEGER;
        end

        function obj = Positive()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.POSITIVE;
        end

        function obj = Negative()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.NEGATIVE;
        end

        function obj = Free()
            obj = gams.transfer.symbol.VariableType();
        end

        function obj = Sos1()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.SOS1;
        end

        function obj = Sos2()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.SOS2;
        end

        function obj = SemiCont()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.SEMICONT;
        end

        function obj = SemiInt()
            obj = gams.transfer.symbol.VariableType();
            obj.value_ = gams.transfer.symbol.VariableType.SemiInt;
        end

        function values = values(input)
            if isnumeric(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    values(i) = gams.transfer.symbol.VariableType(input(i)).value;
                end
            elseif iscell(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.symbol.VariableType')
                        values(i) = input{i}.value;
                    else
                        values(i) = gams.transfer.symbol.VariableType(input{i}).value;
                    end
                end
            else
                values = gams.transfer.symbol.VariableType(input).value;
            end
        end

        function selects = selects(input)
            if isnumeric(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    selects{i} = gams.transfer.symbol.VariableType(input(i)).select;
                end
            elseif iscell(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.symbol.VariableType')
                        selects{i} = input{i}.select;
                    else
                        selects{i} = gams.transfer.symbol.VariableType(input{i}).select;
                    end
                end
            else
                selects = {gams.transfer.symbol.VariableType(input).select};
            end
        end

    end

end
