% GAMS Symbol Type
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
% GAMS Symbol Type
%

%> @brief Symbol Type
classdef SymbolType

    properties (Constant)
        SET = uint8(0)
        PARAMETER = uint8(1)
        VARIABLE = uint8(2)
        EQUATION = uint8(3)
        ALIAS = uint8(4)
    end

    properties (Hidden, SetAccess = protected)
        value_ = uint8(0)
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
                error('Argument ''%s'' (at position %d) must be parameter.', name, index);
            end
            if arg < 0 || arg > 4
                error('Argument ''%s'' (at position %d) must be in [0, 4].', name, index);
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
            case 'SET'
                arg = gams.transfer.symbol.SymbolType.SET;
            case 'PARAMETER'
                arg = gams.transfer.symbol.SymbolType.PARAMETER;
            case 'VARIABLE'
                arg = gams.transfer.symbol.SymbolType.VARIABLE;
            case 'EQUATION'
                arg = gams.transfer.symbol.SymbolType.EQUATION;
            case 'ALIAS'
                arg = gams.transfer.symbol.SymbolType.ALIAS;
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
            case obj.SET
                select = 'SET';
            case obj.PARAMETER
                select = 'PARAMETER';
            case obj.VARIABLE
                select = 'VARIABLE';
            case obj.EQUATION
                select = 'EQUATION';
            case obj.ALIAS
                select = 'ALIAS';
            otherwise
                error('Invalid symbol type value: %d', obj.value_);
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

        function obj = SymbolType(value)
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

        function obj = Set()
            obj = gams.transfer.symbol.SymbolType();
            obj.value_ = gams.transfer.symbol.SymbolType.SET;
        end

        function obj = Parameter()
            obj = gams.transfer.symbol.SymbolType();
            obj.value_ = gams.transfer.symbol.SymbolType.PARAMETER;
        end

        function obj = Variable()
            obj = gams.transfer.symbol.SymbolType();
            obj.value_ = gams.transfer.symbol.SymbolType.VARIABLE;
        end

        function obj = Equation()
            obj = gams.transfer.symbol.SymbolType();
            obj.value_ = gams.transfer.symbol.SymbolType.EQUATION;
        end

        function obj = Alias()
            obj = gams.transfer.symbol.SymbolType();
        end

    end

end
