% GAMS Equation Types
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
% GAMS Equation Types
%
% This class holds the possible GAMS equation types similar to an enumeration
% class. Note that it is not an enumeration class due to compatibility (e.g.
% for Octave).
%
% See also: gams.transfer.Equation
%

%> @ingroup symbol
%> @brief GAMS Equation Types
%>
%> This class holds the possible GAMS equation types similar to an enumeration
%> class. Note that it is not an enumeration class due to compatibility (e.g.
%> for Octave).
%>
%> @see \ref gams::transfer::Equation "Equation"
classdef EquationType

    properties (Constant)
        %> identifier for equality equation

        % EQ identifier for equality equation
        EQ = 0


        %> identifier for greater-than inequality equation

        % GEQ identifier for greater-than inequality equation
        GEQ = 1


        %> identifier for less-than inequality equation

        % LEQ identifier for less-than inequality equation
        LEQ = 2


        %> identifier for nonbinding equation

        % NONBINDING identifier for nonbinding equation
        NONBINDING = 3


        %> identifier for external equation

        % EXTERNAL identifier for external equation
        EXTERNAL = 4


        %> identifier for cone equation

        % CONE identifier for cone equation
        CONE = 5


        %> identifier for boolean equation

        % BOOLEAN identifier for boolean equation
        BOOLEAN = 6
    end

    methods (Static)

        %> Converts an equation type identifier to string
        %>
        %> - `s = EquationType.int2str(i)` returns a string with the equation
        %>   type name for the given equation type identifier `i`. If `i` is an
        %>   invalid identifier, this function raises an error.
        %>
        %> **Example:**
        %> ```
        %> s = EquationType.int2str(EquationType.EQ)
        %> ```
        %> `s` equals `"eq"`
        function value_str = int2str(value_int)
            % Converts an equation type identifier to string
            %
            % s = EquationType.int2str(i) returns a string with the equation
            % type name for the given equation type identifier i. If i is an
            % invalid identifier, this function raises an error.
            %
            % Example:
            % s = EquationType.int2str(EquationType.EQ)
            % s equals 'eq'

            switch value_int
            case gams.transfer.EquationType.EQ
                value_str = 'eq';
            case gams.transfer.EquationType.GEQ
                value_str = 'geq';
            case gams.transfer.EquationType.LEQ
                value_str = 'leq';
            case gams.transfer.EquationType.NONBINDING
                value_str = 'nonbinding';
            case gams.transfer.EquationType.EXTERNAL
                value_str = 'external';
            case gams.transfer.EquationType.CONE
                value_str = 'cone';
            case gams.transfer.EquationType.BOOLEAN
                value_str = 'boolean';
            otherwise
                error('Invalid equation type: %d', value_int);
            end
        end

        %> Converts an equation type name to an identifier
        %>
        %> - `i = EquationType.str2int(s)` returns an integer identifier for the
        %> given equation type name `s`. If `s` is an invalid type name, this
        %> function raises an error.
        %>
        %> **Example:**
        %> ```
        %> i1 = EquationType.str2int('eq')
        %> i2 = EquationType.str2int('e')
        %> ```
        %> `i1` and `i2` equal `EquationType.EQ`
        function value_int = str2int(value_str)
            % Converts an equation type name to an identifier
            %
            % i = EquationType.str2int(s) returns an integer identifier for the
            % given equation type name s. If s is an invalid type name, this
            % function raises an error.
            %
            % Example:
            % i1 = EquationType.str2int('eq')
            % i2 = EquationType.str2int('e')
            % i1 and i2 equal EquationType.EQ

            switch lower(char(value_str))
            case {'e', 'eq'}
                value_int = gams.transfer.EquationType.EQ;
            case {'g', 'geq'}
                value_int = gams.transfer.EquationType.GEQ;
            case {'l', 'leq'}
                value_int = gams.transfer.EquationType.LEQ;
            case {'n', 'nonbinding'}
                value_int = gams.transfer.EquationType.NONBINDING;
            case {'x', 'external'}
                value_int = gams.transfer.EquationType.EXTERNAL;
            case {'c', 'cone'}
                value_int = gams.transfer.EquationType.CONE;
            case {'b', 'boolean'}
                value_int = gams.transfer.EquationType.BOOLEAN;
            otherwise
                error('Invalid equation type: %s', value_str);
            end
        end

        %> Checks if an equation type name or identifier is valid
        %>
        %> - `b = EquationType.isValid(s)` returns `true` if `s` is a valid
        %> equation type name or equation type identifier and `false` otherwise.
        %>
        %> **Example:**
        %> ```
        %> EquationType.isValid('eq') % is true
        %> EquationType.isValid(EquationType.EQ) % is true
        %> EquationType.isValid('not_a_valid_name') % is false
        %> ```
        function bool = isValid(value)
            % Checks if an equation type name or identifier is valid
            %
            % b = EquationType.isValid(s) returns true if s is a valid equation
            % type name or equation type identifier and false otherwise.
            %
            % Example:
            % EquationType.isValid('eq') is true
            % EquationType.isValid(EquationType.EQ) is true
            % EquationType.isValid('not_a_valid_name') is false

            if ischar(value) || isstring(value)
                switch lower(char(value))
                case {'e', 'eq'}
                    bool = true;
                case {'g', 'geq'}
                    bool = true;
                case {'l', 'leq'}
                    bool = true;
                case {'n', 'nonbinding'}
                    bool = true;
                case {'x', 'external'}
                    bool = true;
                case {'c', 'cone'}
                    bool = true;
                case {'b', 'boolean'}
                    bool = true;
                otherwise
                    bool = false;
                end
            elseif isnumeric(value)
                switch value
                case gams.transfer.EquationType.EQ
                    bool = true;
                case gams.transfer.EquationType.GEQ
                    bool = true;
                case gams.transfer.EquationType.LEQ
                    bool = true;
                case gams.transfer.EquationType.NONBINDING
                    bool = true;
                case gams.transfer.EquationType.EXTERNAL
                    bool = true;
                case gams.transfer.EquationType.CONE
                    bool = true;
                case gams.transfer.EquationType.BOOLEAN
                    bool = true;
                otherwise
                    bool = false;
                end
            else
                bool = false;
            end
        end

    end

end
