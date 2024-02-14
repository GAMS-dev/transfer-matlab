% Abstract Case Insensitive Ordered Dictionary (internal)
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
% Abstract Case Insensitive Ordered Dictionary (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Abstract < gams.transfer.utils.Handle

    methods

        function n = count(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function flag = exists(obj, keys)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function keys = keys(obj, keys)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function keys = keysAt(obj, indices)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function indices = find(obj, keys)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function entries = entries(obj, keys)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function entries = entriesAt(obj, indices)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function add(obj, key, entry)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function clear(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function symbol = rename(obj, oldkey, newkey)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function remove(obj, keys)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function reorder(obj, permutation)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

    end

end
