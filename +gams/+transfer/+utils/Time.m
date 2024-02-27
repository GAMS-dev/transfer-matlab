% Timer (internal)
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
% Timer (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Time < handle

    properties (Hidden, SetAccess = protected)
        time_
    end

    properties (Dependent, SetAccess = private)
        time
    end

    methods

        function time = get.time(obj)
            if gams.transfer.Constants.SUPPORTS_DATETIME
                time = datetime(obj.time_, 'ConvertFrom', 'datenum');
            else
                time = obj.time_;
            end
        end

    end

    methods

        function obj = Time()
            obj.time_ = now();
        end

        function reset(obj)
            obj.time_ = now();
        end

        function set(obj, time)
            assert(isa(time, 'gams.transfer.utils.Time'));
            obj.time_ = time.time_;
        end

        function flag = lt(obj, obj2)
            flag = obj.time_ < obj2.time_;
        end

        function flag = gt(obj, obj2)
            flag = obj.time_ > obj2.time_;
        end

        function flag = le(obj, obj2)
            flag = obj.time_ <= obj2.time_;
        end

        function flag = ge(obj, obj2)
            flag = obj.time_ >= obj2.time_;
        end

        function flag = eq(obj, obj2)
            flag = obj.time_ == obj2.time_;
        end

        function flag = ne(obj, obj2)
            flag = obj.time_ ~= obj2.time_;
        end

    end

end
