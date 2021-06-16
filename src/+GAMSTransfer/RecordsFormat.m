classdef RecordsFormat
    % GAMSTransfer Records Formats
    %
    % This class holds the possible GAMSTransfer formats of records similar to
    % an enumeration class. Note that it is not an enumeration class due to
    % compatibility (e.g. for Octave).
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
        % UNKNOWN identifier for unknown records format
        UNKNOWN = -1

        % NOT_READ identifier for records that haven't been read yet
        NOT_READ = 0

        % EMPTY identifier for empty records
        EMPTY = 1

        % STRUCT identifier for records format as struct
        STRUCT = 2

        % DENSE_MATRIX identifier for records format as dense matrix
        DENSE_MATRIX = 3

        % SPARSE_MATRIX identifier for records format as sparse matrix
        SPARSE_MATRIX = 4

        % TABLE identifier for records format as table
        TABLE = 5
    end

    methods (Static)

        function value_str = int2str(value_int)
            % Converts an records format identifier to string
            %
            % s = RecordsFormat.int2str(i) returns a string with the records
            % format name for the given records format identifier i. If i is an
            % invalid identifier, this function returns 'unknown'.
            %
            % Example:
            % s = RecordsFormat.int2str(RecordsFormat.DENSE_MATRIX)
            % s equals 'dense_matrix'
            %

            switch value_int
            case GAMSTransfer.RecordsFormat.NOT_READ
                value_str = 'not_read';
            case GAMSTransfer.RecordsFormat.EMPTY
                value_str = 'empty';
            case GAMSTransfer.RecordsFormat.STRUCT
                value_str = 'struct';
            case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                value_str = 'dense_matrix';
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                value_str = 'sparse_matrix';
            case GAMSTransfer.RecordsFormat.TABLE
                value_str = 'table';
            otherwise
                value_str = 'unknown';
            end
        end

        function value_int = str2int(value_str)
            % Converts an records format name to an identifier
            %
            % i = RecordsFormat.str2int(s) returns an integer identifier for the
            % given records format name s. If s is an invalid format name, this
            % function returns RecordsFormat.UNKNOWN.
            %
            % Example:
            % i = RecordsFormat.str2int('dense_matrix')
            % i equals RecordsFormat.DENSE_MATRIX
            %

            switch lower(char(value_str))
            case 'empty'
                value_int = GAMSTransfer.RecordsFormat.EMPTY;
            case 'not_read'
                value_int = GAMSTransfer.RecordsFormat.NOT_READ;
            case 'struct'
                value_int = GAMSTransfer.RecordsFormat.STRUCT;
            case 'dense_matrix'
                value_int = GAMSTransfer.RecordsFormat.DENSE_MATRIX;
            case 'sparse_matrix'
                value_int = GAMSTransfer.RecordsFormat.SPARSE_MATRIX;
            case 'table'
                value_int = GAMSTransfer.RecordsFormat.TABLE;
            otherwise
                value_int = GAMSTransfer.RecordsFormat.UNKNOWN;
            end
        end

        function bool = isvalid(value)
            % Checks if a records format name or identifier is valid
            %
            % b = RecordsFormat.isvalid(s) returns true if s is a valid records
            % format name or records format identifier and false otherwise.
            %
            % Example:
            % RecordsFormat.isvalid('dense_matrix') is true
            % RecordsFormat.isvalid(RecordsFormat.DENSE_MATRIX) is true
            % RecordsFormat.isvalid('not_a_valid_name') is false
            %

            if ischar(value) || isstring(value)
                switch lower(char(value))
                case 'empty'
                    bool = true;
                case 'not_read'
                    bool = true;
                case 'struct'
                    bool = true;
                case 'dense_matrix'
                    bool = true;
                case 'sparse_matrix'
                    bool = true;
                case 'table'
                    bool = true;
                case 'unknown'
                    bool = true;
                otherwise
                    bool = false;
                end
            elseif isnumeric(value)
                switch value
                case GAMSTransfer.RecordsFormat.NOT_READ
                    bool = true;
                case GAMSTransfer.RecordsFormat.EMPTY
                    bool = true;
                case GAMSTransfer.RecordsFormat.STRUCT
                    bool = true;
                case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                    bool = true;
                case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                    bool = true;
                case GAMSTransfer.RecordsFormat.TABLE
                    bool = true;
                case GAMSTransfer.RecordsFormat.UNKNOWN
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
