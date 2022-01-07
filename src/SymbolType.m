classdef SymbolType
    % GAMSTransferSymbol Types
    %
    % This class holds the possible GAMSTransfer symbol types similar to an
    % enumeration class. Note that it is not an enumeration class due to
    % compatibility (e.g. for Octave).
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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

    properties (Constant)
        % SET GAMS Set
        SET = 0

        % PARAMETER GAMS Parameter
        PARAMETER = 1

        % VARIABLE GAMS Variable
        VARIABLE = 2

        % EQUATION GAMS Equation
        EQUATION = 3

        % ALIAS GAMS Alias
        ALIAS = 4
    end

    methods (Static)

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
            %

            switch value_int
            case GAMSTransfer.SymbolType.SET
                value_str = 'set';
            case GAMSTransfer.SymbolType.PARAMETER
                value_str = 'parameter';
            case GAMSTransfer.SymbolType.VARIABLE
                value_str = 'variable';
            case GAMSTransfer.SymbolType.EQUATION
                value_str = 'equation';
            case GAMSTransfer.SymbolType.ALIAS
                value_str = 'alias';
            otherwise
                error('Invalid variable type: %d', value_int);
            end
        end

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
            %

            switch lower(char(value_str))
            case 'set'
                value_int = GAMSTransfer.SymbolType.SET;
            case 'parameter'
                value_int = GAMSTransfer.SymbolType.PARAMETER;
            case 'variable'
                value_int = GAMSTransfer.SymbolType.VARIABLE;
            case 'equation'
                value_int = GAMSTransfer.SymbolType.EQUATION;
            case 'alias'
                value_int = GAMSTransfer.SymbolType.ALIAS;
            otherwise
                error('Invalid variable type: %s', value_str);
            end
        end

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
            %

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
                case GAMSTransfer.SymbolType.SET
                    bool = true;
                case GAMSTransfer.SymbolType.PARAMETER
                    bool = true;
                case GAMSTransfer.SymbolType.VARIABLE
                    bool = true;
                case GAMSTransfer.SymbolType.EQUATION
                    bool = true;
                case GAMSTransfer.SymbolType.ALIAS
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
