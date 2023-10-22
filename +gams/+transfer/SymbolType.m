% GAMS Transfer Symbol Types
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
% GAMS Transfer Symbol Types
%
% This class holds the possible GAMS Transfer symbol types similar to an
% enumeration class. Note that it is not an enumeration class due to
% compatibility (e.g. for Octave).
%

%> @ingroup symbol
%> @brief GAMS Transfer Symbol Types
%>
%> This class holds the possible GAMS Transfer symbol types similar to an
%> enumeration class. Note that it is not an enumeration class due to
%> compatibility (e.g. for Octave).
classdef SymbolType

    properties (Constant)
        %> GAMS Set

        % SET GAMS Set
        SET = 0


        %> GAMS Parameter

        % PARAMETER GAMS Parameter
        PARAMETER = 1


        %> GAMS Variable

        % VARIABLE GAMS Variable
        VARIABLE = 2


        %> GAMS Equation

        % EQUATION GAMS Equation
        EQUATION = 3


        %> GAMS Alias

        % ALIAS GAMS Alias
        ALIAS = 4
    end

    methods (Static)

        %> Converts a symbol type identifier to string
        %>
        %> - `s = SymbolType.int2str(i)` returns a string with the symbol type
        %>   name for the given symbol type identifier `i`. If `i` is an invalid
        %>   identifier, this function raises an error.
        %>
        %> **Example:**
        %> ```
        %> s = SymbolType.int2str(SymbolType.SET)
        %> ```
        %> `s` equals `"set"`
        function value_str = int2str(value_int)
            % Converts a symbol type identifier to string
            %
            % s = SymbolType.int2str(i) returns a string with the symbol type
            % name for the given symbol type identifier i. If i is an invalid
            % identifier, this function raises an error.
            %
            % Example:
            % s = SymbolType.int2str(SymbolType.SET)
            % s equals 'set'

            switch value_int
            case gams.transfer.SymbolType.SET
                value_str = 'set';
            case gams.transfer.SymbolType.PARAMETER
                value_str = 'parameter';
            case gams.transfer.SymbolType.VARIABLE
                value_str = 'variable';
            case gams.transfer.SymbolType.EQUATION
                value_str = 'equation';
            case gams.transfer.SymbolType.ALIAS
                value_str = 'alias';
            otherwise
                error('Invalid variable type: %d', value_int);
            end
        end

        %> Converts a symbol type name to an identifier
        %>
        %> - `i = SymbolType.str2int(s)` returns an integer identifier for the
        %>   given symbol type name `s`. If `s` is an invalid type name, this
        %>   function raises an error.
        %>
        %> **Example:**
        %> ```
        %> i = SymbolType.str2int('set')
        %> ```
        %> `i` equals `SymbolType.SET`
        function value_int = str2int(value_str)
            % Converts a symbol type name to an identifier
            %
            % i = SymbolType.str2int(s) returns an integer identifier for the
            % given symbol type name s. If s is an invalid type name, this
            % function raises an error.
            %
            % Example:
            % i = SymbolType.str2int('set')
            % i equals SymbolType.SET

            switch lower(char(value_str))
            case 'set'
                value_int = gams.transfer.SymbolType.SET;
            case 'parameter'
                value_int = gams.transfer.SymbolType.PARAMETER;
            case 'variable'
                value_int = gams.transfer.SymbolType.VARIABLE;
            case 'equation'
                value_int = gams.transfer.SymbolType.EQUATION;
            case 'alias'
                value_int = gams.transfer.SymbolType.ALIAS;
            otherwise
                error('Invalid variable type: %s', value_str);
            end
        end

        %> Checks if a symbol type name or identifier is valid
        %>
        %> - `b = SymbolType.isValid(s)` returns true if `s` is a valid symbol
        %>   type name or variable type identifier and false otherwise.
        %>
        %> **Example:**
        %> ```
        %> SymbolType.isValid('set') is true
        %> SymbolType.isValid(SymbolType.SET) is true
        %> SymbolType.isValid('not_a_valid_name') is false
        %> ```
        function bool = isValid(value)
            % Checks if a symbol type name or identifier is valid
            %
            % b = SymbolType.isValid(s) returns true if s is a valid symbol
            % type name or variable type identifier and false otherwise.
            %
            % Example:
            % SymbolType.isValid('set') is true
            % SymbolType.isValid(SymbolType.SET) is true
            % SymbolType.isValid('not_a_valid_name') is false

            if ischar(value) || isstring(value)
                switch lower(char(value))
                case 'set'
                    bool = true;
                case 'parameter'
                    bool = true;
                case 'variable'
                    bool = true;
                case 'equation'
                    bool = true;
                case 'alias'
                    bool = true;
                otherwise
                    bool = false;
                end
            elseif isnumeric(value)
                switch value
                case gams.transfer.SymbolType.SET
                    bool = true;
                case gams.transfer.SymbolType.PARAMETER
                    bool = true;
                case gams.transfer.SymbolType.VARIABLE
                    bool = true;
                case gams.transfer.SymbolType.EQUATION
                    bool = true;
                case gams.transfer.SymbolType.ALIAS
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
