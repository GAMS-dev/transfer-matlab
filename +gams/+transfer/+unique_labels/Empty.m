% Empty Unique Labels (internal)
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
% Empty Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Empty < gams.transfer.unique_labels.Abstract

    properties (Dependent, SetAccess = private)
        last_update
    end

    methods

        function last_update = get.last_update(obj)
            last_update = 0;
        end

    end

    methods (Static)

        function obj = construct()
            obj = gams.transfer.unique_labels.Empty();
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.Empty();
        end

        function count = count(obj)
            count = 0;
        end

        function labels = get(obj)
            labels = {};
        end

        function clear(obj)
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.symbol.data.Abstract, ...
        ?gams.transfer.symbol.domain.Abstract})

        function labels = getAt_(obj, indices)
            labels = cell(size(indices));
            labels(:) = {gams.transfer.Constants.UNDEFINED_UNIQUE_LABEL};
        end

        function [flag, indices] = remove_(obj, labels)
            flag = [];
            indices = [];
        end

        function rename_(obj, oldlabels, newlabels)
        end

        function [flag, indices] = merge_(obj, oldlabels, newlabels)
            flag = [];
            indices = [];
        end

    end

    methods (Hidden)

        function flag = supportsIndexed(obj)
            flag = true;
        end

    end

end
