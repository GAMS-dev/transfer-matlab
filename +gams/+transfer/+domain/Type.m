% GAMS Domain Type
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
% GAMS Domain Type
%

%> @brief Domain Type
classdef Type

    properties (Constant)
        NONE = 1
        REGULAR = 2
        RELAXED = 3
    end

    properties (Hidden, SetAccess = protected)
        value_ = 1
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
            case obj.NONE
                select = 'NONE';
            case obj.REGULAR
                select = 'REGULAR';
            case obj.RELAXED
                select = 'RELAXED';
            otherwise
                error('Invalid domain index value: %d', obj.value_);
            end
        end

        function obj = set.select(obj, select)
            if isstring(select)
                select = char(select)
            end
            validateattributes(select, {'char'}, {'nonempty', 'vector'}, 'set.select', 'select', 1);
            switch select
                case {'NONE', lower('NONE')}
                    obj.value = obj.NONE;
                case {'REGULAR', lower('REGULAR')}
                    obj.value = obj.REGULAR;
                case {'RELAXED', lower('RELAXED')}
                    obj.value = obj.RELAXED;
                otherwise
                    error('Invalid domain index selection: %s', select);
            end
        end

        function value = get.value(obj)
            value = obj.value_;
        end

        function obj = set.value(obj, value)
            validateattributes(value, {'numeric'}, {'integer', 'scalar', '>=', 1, '<=', 3}, 'set.value', 'value', 1);
            obj.value_ = value;
        end

    end

    methods

        function obj = Type(value)
            if nargin >= 1
                try
                    obj.select = value;
                catch
                    try
                        obj.value = value;
                    catch
                        error('Invalid domain index type value')
                    end
                end
            end
        end

    end

end
