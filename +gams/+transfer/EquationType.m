% GAMS Equation Type
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
% GAMS Equation Types
%
% This class holds the possible GAMS equation types similar to an enumeration class. Note that it is
% not an enumeration class due to compatibility (e.g. for Octave).
%
% See also: gams.transfer.symbol.Equation
%

%> @brief GAMS Equation Type
%>
%> This class holds the possible GAMS equation types similar to an enumeration class. Note that it
%> is not an enumeration class due to compatibility (e.g. for Octave).
%>
%> @see \ref gams::transfer::symbol::Equation "symbol.Equation"
classdef EquationType

    properties (Constant)
        %> identifier for equality equation

        % EQ identifier for equality equation
        EQ = uint8(0)


        %> identifier for greater-than inequality equation

        % GEQ identifier for greater-than inequality equation
        GEQ = uint8(1)


        %> identifier for less-than inequality equation

        % LEQ identifier for less-than inequality equation
        LEQ = uint8(2)


        %> identifier for nonbinding equation

        % NONBINDING identifier for nonbinding equation
        NONBINDING = uint8(3)


        %> identifier for external equation

        % EXTERNAL identifier for external equation
        EXTERNAL = uint8(4)


        %> identifier for cone equation

        % CONE identifier for cone equation
        CONE = uint8(5)


        %> identifier for boolean equation

        % BOOLEAN identifier for boolean equation
        BOOLEAN = uint8(6)
    end

    properties (Hidden, SetAccess = protected)
        value_ = uint8(3)
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
            select = gams.transfer.utils.Validator('select', 1, select).string2char().type('char').nonempty().value;
            switch upper(select)
            case {'EQ', 'E'}
                obj.value_ = gams.transfer.EquationType.EQ;
            case {'GEQ', 'G'}
                obj.value_ = gams.transfer.EquationType.GEQ;
            case {'LEQ', 'L'}
                obj.value_ = gams.transfer.EquationType.LEQ;
            case {'NONBINDING', 'N'}
                obj.value_ = gams.transfer.EquationType.NONBINDING;
            case {'EXTERNAL', 'X'}
                obj.value_ = gams.transfer.EquationType.EXTERNAL;
            case {'CONE', 'C'}
                obj.value_ = gams.transfer.EquationType.CONE;
            case {'BOOLEAN', 'B'}
                obj.value_ = gams.transfer.EquationType.BOOLEAN;
            otherwise
                error('Invalid equation type selection: %s', select);
            end
        end

        function value = get.value(obj)
            value = obj.value_;
        end

        function obj = set.value(obj, value)
            gams.transfer.utils.Validator('value', 1, value).integer().scalar().inInterval(0, 6);
            obj.value_ = uint8(value);
        end

    end

    methods

        %> Constructs a Equation Type
        %>
        %> **Optional Arguments:**
        %> 1. value (`numeric` or `string`)
        %>    Enumeration value or label. Default: 3 (NONBINDING).
        function obj = EquationType(value)
            % Constructs a Equation Type
            %
            % Optional Arguments:
            % 1. value (numeric or string)
            %    Enumeration value or label. Default: 3 (NONBINDING).

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

        %> Constructs a Equation Type as EQ
        function obj = Eq()
            % Constructs a Equation Type as EQ

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.EQ;
        end

        %> Constructs a Equation Type as LEQ
        function obj = Leq()
            % Constructs a Equation Type as LEQ

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.LEQ;
        end

        %> Constructs a Equation Type as GEQ
        function obj = Geq()
            % Constructs a Equation Type as GEQ

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.GEQ;
        end

        %> Constructs a Equation Type as NONBINDING
        function obj = NonBinding()
            % Constructs a Equation Type as NONBINDING

            obj = gams.transfer.EquationType();
        end

        %> Constructs a Equation Type as EXTERNAL
        function obj = External()
            % Constructs a Equation Type as EXTERNAL

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.EXTERNAL;
        end

        %> Constructs a Equation Type as CONE
        function obj = Cone()
            % Constructs a Equation Type as Cone

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.CONE;
        end

        %> Constructs a Equation Type as BOOLEAN
        function obj = Boolean()
            % Constructs a Equation Type as BOOLEAN

            obj = gams.transfer.EquationType();
            obj.value_ = gams.transfer.EquationType.BOOLEAN;
        end

        %> Converts input to Equation Type enumeration values
        %>
        %> **Required Arguments:**
        %> 1. input (`numeric`, `cell` or `string`)
        %>    Enumeration values or labels.
        function values = values(input)
            % Converts input to Equation Type enumeration values
            %
            % Required Arguments:
            % 1. input (numeric, cell or string)
            %    Enumeration values or labels.

            if isnumeric(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    values(i) = gams.transfer.EquationType(input(i)).value;
                end
            elseif iscell(input)
                values = zeros(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.EquationType')
                        values(i) = input{i}.value;
                    else
                        values(i) = gams.transfer.EquationType(input{i}).value;
                    end
                end
            else
                values = gams.transfer.EquationType(input).value;
            end
        end

        %> Converts input to Equation Type enumeration labels (selections)
        %>
        %> **Required Arguments:**
        %> 1. input (`numeric`, `cell` or `string`)
        %>    Enumeration values or labels.
        function selects = selects(input)
            % Converts input to Equation Type enumeration labels (selections)
            %
            % Required Arguments:
            % 1. input (numeric, cell or string)
            %    Enumeration values or labels.

            if isnumeric(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    selects{i} = gams.transfer.EquationType(input(i)).select;
                end
            elseif iscell(input)
                selects = cell(size(input));
                for i = 1:numel(input)
                    if isa(input{i}, 'gams.transfer.EquationType')
                        selects{i} = input{i}.select;
                    else
                        selects{i} = gams.transfer.EquationType(input{i}).select;
                    end
                end
            else
                selects = {gams.transfer.EquationType(input).select};
            end
        end

    end

end
