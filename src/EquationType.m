classdef EquationType
    % GAMS Equation Types
    %
    % This class holds the possible GAMS equation types similar to an enumeration
    % class. Note that it is not an enumeration class due to compatibility (e.g.
    % for Octave).
    %
    % See also: GAMSTransfer.Equation
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
        % EQ identifier for equality equation
        EQ = 0

        % GEQ identifier for greater-than inequality equation
        GEQ = 1

        % LEQ identifier for less-than inequality equation
        LEQ = 2

        % NONBINDING identifier for nonbinding equation
        NONBINDING = 3

        % EXTERNAL identifier for external equation
        EXTERNAL = 4

        % CONE identifier for cone equation
        CONE = 5

        % BOOLEAN identifier for boolean equation
        BOOLEAN = 6
    end

    methods (Static)

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
            %

            switch value_int
            case GAMSTransfer.EquationType.EQ
                value_str = 'eq';
            case GAMSTransfer.EquationType.GEQ
                value_str = 'geq';
            case GAMSTransfer.EquationType.LEQ
                value_str = 'leq';
            case GAMSTransfer.EquationType.NONBINDING
                value_str = 'nonbinding';
            case GAMSTransfer.EquationType.EXTERNAL
                value_str = 'external';
            case GAMSTransfer.EquationType.CONE
                value_str = 'cone';
            case GAMSTransfer.EquationType.BOOLEAN
                value_str = 'boolean';
            otherwise
                error('Invalid equation type: %d', value_int);
            end
        end

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
            %

            switch lower(char(value_str))
            case {'e', 'eq'}
                value_int = GAMSTransfer.EquationType.EQ;
            case {'g', 'geq'}
                value_int = GAMSTransfer.EquationType.GEQ;
            case {'l', 'leq'}
                value_int = GAMSTransfer.EquationType.LEQ;
            case {'n', 'nonbinding'}
                value_int = GAMSTransfer.EquationType.NONBINDING;
            case {'x', 'external'}
                value_int = GAMSTransfer.EquationType.EXTERNAL;
            case {'c', 'cone'}
                value_int = GAMSTransfer.EquationType.CONE;
            case {'b', 'boolean'}
                value_int = GAMSTransfer.EquationType.BOOLEAN;
            otherwise
                error('Invalid equation type: %s', value_str);
            end
        end

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
            %

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
                case GAMSTransfer.EquationType.EQ
                    bool = true;
                case GAMSTransfer.EquationType.GEQ
                    bool = true;
                case GAMSTransfer.EquationType.LEQ
                    bool = true;
                case GAMSTransfer.EquationType.NONBINDING
                    bool = true;
                case GAMSTransfer.EquationType.EXTERNAL
                    bool = true;
                case GAMSTransfer.EquationType.CONE
                    bool = true;
                case GAMSTransfer.EquationType.BOOLEAN
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
