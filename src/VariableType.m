classdef VariableType
    % GAMS Variable Types
    %
    % This class holds the possible GAMS variable types similar to an enumeration
    % class. Note that it is not an enumeration class due to compatibility (e.g.
    % for Octave).
    %
    % See also: GAMSTransfer.Variable
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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
        % BINARY identifier for binary variable
        BINARY = 1

        % INTEGER identifier for integer variable
        INTEGER = 2

        % POSITIVE identifier for positive variable
        POSITIVE = 3

        % NEGATIVE identifier for negative variable
        NEGATIVE = 4

        % FREE identifier for free variable
        FREE = 5

        % SOS1 identifier for SOS1 variable
        SOS1 = 6

        % SOS2 identifier for SOS2 variable
        SOS2 = 7

        % SEMICONT identifier for semi-continuous variable
        SEMICONT = 8

        % SEMIINT identifier for semi-integer variable
        SEMIINT = 9
    end

    methods (Static)

        function value_str = int2str(value_int)
            % Converts a variable type identifier to string
            %
            % s = VariableType.int2str(i) returns a string with the variable
            % type name for the given variable type identifier i. If i is an
            % invalid identifier, this function raises an error.
            %
            % Example:
            % s = VariableType.int2str(VariableType.BINARY)
            % s equals 'binary'
            %

            switch value_int
            case GAMSTransfer.VariableType.BINARY
                value_str = 'binary';
            case GAMSTransfer.VariableType.INTEGER
                value_str = 'integer';
            case GAMSTransfer.VariableType.POSITIVE
                value_str = 'positive';
            case GAMSTransfer.VariableType.NEGATIVE
                value_str = 'negative';
            case GAMSTransfer.VariableType.FREE
                value_str = 'free';
            case GAMSTransfer.VariableType.SOS1
                value_str = 'sos1';
            case GAMSTransfer.VariableType.SOS2
                value_str = 'sos2';
            case GAMSTransfer.VariableType.SEMICONT
                value_str = 'semicont';
            case GAMSTransfer.VariableType.SEMIINT
                value_str = 'semiint';
            otherwise
                error('Invalid variable type: %d', value_int);
            end
        end

        function value_int = str2int(value_str)
            % Converts a variable type name to an identifier
            %
            % i = VariableType.str2int(s) returns an integer identifier for the
            % given variable type name s. If s is an invalid type name, this
            % function raises an error.
            %
            % Example:
            % i = VariableType.str2int('binary')
            % i equals VariableType.BINARY
            %

            switch lower(char(value_str))
            case 'binary'
                value_int = GAMSTransfer.VariableType.BINARY;
            case 'integer'
                value_int = GAMSTransfer.VariableType.INTEGER;
            case 'positive'
                value_int = GAMSTransfer.VariableType.POSITIVE;
            case 'negative'
                value_int = GAMSTransfer.VariableType.NEGATIVE;
            case 'free'
                value_int = GAMSTransfer.VariableType.FREE;
            case 'sos1'
                value_int = GAMSTransfer.VariableType.SOS1;
            case 'sos2'
                value_int = GAMSTransfer.VariableType.SOS2;
            case 'semicont'
                value_int = GAMSTransfer.VariableType.SEMICONT;
            case 'semiint'
                value_int = GAMSTransfer.VariableType.SEMIINT;
            otherwise
                error('Invalid variable type: %s', value_str);
            end
        end

        function bool = isValid(value)
            % Checks if a variable type name or identifier is valid
            %
            % b = VariableType.isValid(s) returns true if s is a valid variable
            % type name or variable type identifier and false otherwise.
            %
            % Example:
            % VariableType.isValid('binary') is true
            % VariableType.isValid(VariableType.BINARY) is true
            % VariableType.isValid('not_a_valid_name') is false
            %

            if ischar(value) || isstring(value)
                switch lower(char(value))
                case 'binary'
                    bool = true;
                case 'integer'
                    bool = true;
                case 'positive'
                    bool = true;
                case 'negative'
                    bool = true;
                case 'free'
                    bool = true;
                case 'sos1'
                    bool = true;
                case 'sos2'
                    bool = true;
                case 'semicont'
                    bool = true;
                case 'semiint'
                    bool = true;
                otherwise
                    bool = false;
                end
            elseif isnumeric(value)
                switch value
                case GAMSTransfer.VariableType.BINARY
                    bool = true;
                case GAMSTransfer.VariableType.INTEGER
                    bool = true;
                case GAMSTransfer.VariableType.POSITIVE
                    bool = true;
                case GAMSTransfer.VariableType.NEGATIVE
                    bool = true;
                case GAMSTransfer.VariableType.FREE
                    bool = true;
                case GAMSTransfer.VariableType.SOS1
                    bool = true;
                case GAMSTransfer.VariableType.SOS2
                    bool = true;
                case GAMSTransfer.VariableType.SEMICONT
                    bool = true;
                case GAMSTransfer.VariableType.SEMIINT
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
