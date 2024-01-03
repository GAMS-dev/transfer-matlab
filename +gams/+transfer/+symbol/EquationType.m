% GAMS Equation Type
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
% GAMS Equation Type
%

%> @brief Equation Type
classdef EquationType

    properties (Constant)
        EQ = uint8(0)
        GEQ = uint8(1)
        LEQ = uint8(2)
        NONBINDING = uint8(3)
        EXTERNAL = uint8(4)
        CONE = uint8(5)
        BOOLEAN = uint8(6)
    end

    properties (Hidden, SetAccess = protected)
        value_ = uint8(3)
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
            if arg < 0 || arg > 6
                error('Argument ''%s'' (at position %d) must be in [0, 6].', name, index);
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
            case {'EQ', 'E'}
                arg = gams.transfer.symbol.EquationType.EQ;
            case {'GEQ', 'G'}
                arg = gams.transfer.symbol.EquationType.GEQ;
            case {'LEQ', 'L'}
                arg = gams.transfer.symbol.EquationType.LEQ;
            case {'NONBINDING', 'N'}
                arg = gams.transfer.symbol.EquationType.NONBINDING;
            case {'EXTERNAL', 'X'}
                arg = gams.transfer.symbol.EquationType.EXTERNAL;
            case {'CONE', 'C'}
                arg = gams.transfer.symbol.EquationType.CONE;
            case {'BOOLEAN', 'B'}
                arg = gams.transfer.symbol.EquationType.BOOLEAN;
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
            case obj.EQ
                select = 'EQ';
            case obj.GEQ
                select = 'GEQ';
            case obj.LEQ
                select = 'LEQ';
            case obj.NONBINDING
                select = 'NONBINDING';
            case obj.EXTERNAL
                select = 'EXTERNAL';
            case obj.CONE
                select = 'CONE';
            case obj.BOOLEAN
                select = 'BOOLEAN';
            otherwise
                error('Invalid equation type value: %d', obj.value_);
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

        function obj = EquationType(value)
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

        function obj = Eq()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.EQ;
        end

        function obj = Leq()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.LEQ;
        end

        function obj = Geq()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.GEQ;
        end

        function obj = NonBinding()
            obj = gams.transfer.symbol.EquationType();
        end

        function obj = External()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.EXTERNAL;
        end

        function obj = Cone()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.CONE;
        end

        function obj = Boolean()
            obj = gams.transfer.symbol.EquationType();
            obj.value_ = gams.transfer.symbol.EquationType.BOOLEAN;
        end

        function values = values(input)
            if isnumeric(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    values(i) = gams.transfer.symbol.EquationType(input(i)).value;
                end
            elseif iscell(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.symbol.EquationType')
                        values(i) = input{i}.value;
                    else
                        values(i) = gams.transfer.symbol.EquationType(input{i}).value;
                    end
                end
            else
                values = gams.transfer.symbol.EquationType(input).value;
            end
        end

        function selects = selects(input)
            if isnumeric(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    selects{i} = gams.transfer.symbol.EquationType(input(i)).select;
                end
            elseif iscell(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.symbol.EquationType')
                        selects{i} = input{i}.select;
                    else
                        selects{i} = gams.transfer.symbol.EquationType(input{i}).select;
                    end
                end
            else
                selects = {gams.transfer.symbol.EquationType(input).select};
            end
        end

    end

end
