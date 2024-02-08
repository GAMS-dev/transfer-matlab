% Status (internal)
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
% Status (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef Status

    properties (Hidden, SetAccess = protected)
        message_ = ''
    end

    properties (Dependent)
        message
    end

    properties (Dependent, SetAccess = private)
        flag
    end

    properties (Constant)
        UNKNOWN = -1
        FAIL = 0
        OK = 1
    end

    methods

        function message = get.message(obj)
            message = obj.message_;
        end

        function obj = set.message(obj, message)
            if isstring(message)
                message = char(message);
            end
            validateattributes(message, {'char'}, {}, 'set', 'message', 1);
            obj.message_ = message;
        end

        function flag = get.flag(obj)
            if isempty(obj.message_)
                flag = obj.UNKNOWN;
            else
                flag = strcmpi(obj.message_, 'OK');
            end
        end

    end

    methods

        function obj = Status(message)
            if nargin >= 1
                obj.message = message;
            end
        end

        function flag = isUnknown(obj)
            flag = obj.flag() == obj.UNKNOWN;
        end

        function flag = isFail(obj)
            flag = obj.flag() == obj.FAIL;
        end

        function flag = isOK(obj)
            flag = obj.flag() == obj.OK;
        end

        function setUnknown(obj)
            obj.message_ = '';
        end

        function setOK(obj)
            obj.message_ = 'OK';
        end

    end

    methods (Static)

        function obj = createOK()
            obj = gams.transfer.utils.Status('OK');
        end

    end

end
