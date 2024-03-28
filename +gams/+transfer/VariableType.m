% GAMS Variable Type
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
% GAMS Variable Type
%
% This class holds the possible GAMS variable types similar to an enumeration class. Note that it is
% not an enumeration class due to compatibility (e.g. for Octave).
%
% See also: gams.transfer.Variable, gams.transfer.symbol.Variable
%

%> @brief GAMS Variable Type
%>
%> This class holds the possible GAMS variable types similar to an enumeration class. Note that it
%> is not an enumeration class due to compatibility (e.g. for Octave).
%>
%> @see \ref gams::transfer::Variable "Variable", \ref gams::transfer::symbol::Variable
%> "symbol.Variable"
classdef VariableType

    properties (Constant)
        %> identifier for binary variable

        % BINARY identifier for binary variable
        BINARY = uint8(1)


        %> identifier for integer variable

        % INTEGER identifier for integer variable
        INTEGER = uint8(2)


        %> identifier for positive variable

        % POSITIVE identifier for positive variable
        POSITIVE = uint8(3)


        %> identifier for negative variable

        % NEGATIVE identifier for negative variable
        NEGATIVE = uint8(4)


        %> identifier for free variable

        % FREE identifier for free variable
        FREE = uint8(5)


        %> identifier for SOS1 variable

        % SOS1 identifier for SOS1 variable
        SOS1 = uint8(6)


        %> SOS2 identifier for SOS2 variable

        % SOS2 identifier for SOS2 variable
        SOS2 = uint8(7)


        %> identifier for semi-continuous variable

        % SEMICONT identifier for semi-continuous variable
        SEMICONT = uint8(8)


        %> identifier for semi-integer variable

        % SEMIINT identifier for semi-integer variable
        SEMIINT = uint8(9)
    end

    properties (Hidden, SetAccess = protected)
        value_ = uint8(5)
    end

    properties (Dependent)
        %> Selection of enum option

        % select Selection of enum option
        select


        %> Value of enum option

        % value Value of enum option
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
            select = gams.transfer.utils.Validator('select', 1, select).string2char().type('char').nonempty().value;
            switch upper(select)
            case 'BINARY'
                obj.value_ = gams.transfer.VariableType.BINARY;
            case 'INTEGER'
                obj.value_ = gams.transfer.VariableType.INTEGER;
            case 'POSITIVE'
                obj.value_ = gams.transfer.VariableType.POSITIVE;
            case 'NEGATIVE'
                obj.value_ = gams.transfer.VariableType.NEGATIVE;
            case 'FREE'
                obj.value_ = gams.transfer.VariableType.FREE;
            case 'SOS1'
                obj.value_ = gams.transfer.VariableType.SOS1;
            case 'SOS2'
                obj.value_ = gams.transfer.VariableType.SOS2;
            case 'SEMICONT'
                obj.value_ = gams.transfer.VariableType.SEMICONT;
            case 'SEMIINT'
                obj.value_ = gams.transfer.VariableType.SEMIINT;
            otherwise
                error('Invalid variable type selection: %s', select);
            end
        end

        function value = get.value(obj)
            value = obj.value_;
        end

        function obj = set.value(obj, value)
            gams.transfer.utils.Validator('value', 1, value).integer().scalar().inInterval(1, 9);
            obj.value_ = uint8(value);
        end

    end

    methods

        %> Constructs a Variable Type
        %>
        %> **Optional Arguments:**
        %> 1. value (`numeric` or `string`)
        %>    Enumeration value or label. Default: 5 (FREE).
        function obj = VariableType(value)
            % Constructs a Variable Type
            %
            % Optional Arguments:
            % 1. value (numeric or string)
            %    Enumeration value or label. Default: 5 (FREE).

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

        %> Constructs a Variable Type as BINARY
        function obj = binary()
            % Constructs a Variable Type as BINARY

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.BINARY;
        end

        %> Constructs a Variable Type as INTEGER
        function obj = integer()
            % Constructs a Variable Type as INTEGER

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.INTEGER;
        end

        %> Constructs a Variable Type as POSITIVE
        function obj = positive()
            % Constructs a Variable Type as POSITIVE

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.POSITIVE;
        end

        %> Constructs a Variable Type as NEGATIVE
        function obj = negative()
            % Constructs a Variable Type as NEGATIVE

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.NEGATIVE;
        end

        %> Constructs a Variable Type as FREE
        function obj = free()
            % Constructs a Variable Type as FREE

            obj = gams.transfer.VariableType();
        end

        %> Constructs a Variable Type as SOS1
        function obj = sos1()
            % Constructs a Variable Type as SOS1

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.SOS1;
        end

        %> Constructs a Variable Type as SOS2
        function obj = sos2()
            % Constructs a Variable Type as SOS2

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.SOS2;
        end

        %> Constructs a Variable Type as SEMICONT
        function obj = semiCont()
            % Constructs a Variable Type as SEMICONT

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.SEMICONT;
        end

        %> Constructs a Variable Type as SEMIINT
        function obj = semiInt()
            % Constructs a Variable Type as SEMIINT

            obj = gams.transfer.VariableType();
            obj.value_ = gams.transfer.VariableType.SEMIINT;
        end

        %> Converts input to Variable Type enumeration values
        %>
        %> **Required Arguments:**
        %> 1. input (`numeric`, `cell` or `string`)
        %>    Enumeration values or labels.
        function values = values(input)
            % Converts input to Variable Type enumeration values
            %
            % Required Arguments:
            % 1. input (numeric, cell or string)
            %    Enumeration values or labels.

            if isnumeric(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    values(i) = gams.transfer.VariableType(input(i)).value;
                end
            elseif iscell(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.VariableType')
                        values(i) = input{i}.value;
                    else
                        values(i) = gams.transfer.VariableType(input{i}).value;
                    end
                end
            else
                values = gams.transfer.VariableType(input).value;
            end
        end

        %> Converts input to Variable Type enumeration labels (selections)
        %>
        %> **Required Arguments:**
        %> 1. input (`numeric`, `cell` or `string`)
        %>    Enumeration values or labels.
        function selects = selects(input)
            % Converts input to Variable Type enumeration labels (selections)
            %
            % Required Arguments:
            % 1. input (numeric, cell or string)
            %    Enumeration values or labels.

            if isnumeric(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    selects{i} = gams.transfer.VariableType(input(i)).select;
                end
            elseif iscell(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.VariableType')
                        selects{i} = input{i}.select;
                    else
                        selects{i} = gams.transfer.VariableType(input{i}).select;
                    end
                end
            else
                selects = {gams.transfer.VariableType(input).select};
            end
        end

    end

end
