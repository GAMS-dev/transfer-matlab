% Domain Index Type (internal)
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
% Domain Index Type (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef IndexType

    properties (Constant)
        CATEGORICAL = uint8(1)
        INTEGER = uint8(2)
    end

    properties (Hidden, SetAccess = protected)
        value_
    end

    properties (Dependent)
        select
        value
    end

    methods

        function select = get.select(obj)
            switch obj.value_
            case obj.CATEGORICAL
                select = 'CATEGORICAL';
            case obj.INTEGER
                select = 'INTEGER';
            otherwise
                error('Invalid equation type value: %d', obj.value_);
            end
        end

        function obj = set.select(obj, select)
            select = gams.transfer.utils.Validator('select', 1, select).string2char().type('char').nonempty().value;
            switch upper(select)
            case 'CATEGORICAL'
                obj.value_ = gams.transfer.symbol.domain.IndexType.CATEGORICAL;
            case 'INTEGER'
                obj.value_ = gams.transfer.symbol.domain.IndexType.INTEGER;
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

        function obj = IndexType(value)
            if nargin == 0
                if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                    obj.value_ = gams.transfer.symbol.domain.IndexType.CATEGORICAL;
                else
                    obj.value_ = gams.transfer.symbol.domain.IndexType.INTEGER;
                end
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

        function obj = categorical()
            obj = gams.transfer.symbol.domain.IndexType();
            obj.value_ = gams.transfer.symbol.domain.IndexType.CATEGORICAL;
        end

        function obj = integer()
            obj = gams.transfer.symbol.domain.IndexType();
            obj.value_ = gams.transfer.symbol.domain.IndexType.INTEGER;
        end

    end

end
