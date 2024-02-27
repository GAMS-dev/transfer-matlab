% handle class (internal)
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
% handle class (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Handle < handle

    properties (Hidden, GetAccess = protected, SetAccess = private)
        id_
    end

    methods (Hidden)

        function obj = Handle()
            obj.id_ = int32(randi(intmax('int32')));
        end

    end

    methods

        function flag = eq(obj, obj2)
            if gams.transfer.Constants.IS_OCTAVE
                % octave cannot check if two objects point to the same data. For this application it
                % is sufficient if it is very unlikely that this test is incorrect.
                flag = obj.id_ == obj2.id_;
            else
                flag = eq@handle(obj, obj2);
            end
        end

        function flag = ne(obj, obj2)
            if gams.transfer.Constants.IS_OCTAVE
                % octave cannot check if two objects point to the same data. For this application it
                % is sufficient if it is very unlikely that this test is incorrect.
                flag = obj.id_ ~= obj2.id_;
            else
                flag = ne@handle(obj, obj2);
            end
        end

    end

end
