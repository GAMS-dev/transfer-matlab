% Symbol Axes (internal)
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
% Symbol Axes (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Axes

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        axes_ = {}
    end

    properties (Dependent)
        axes
    end

    methods

        function axes = get.axes(obj)
            axes = obj.axes_;
        end

        function obj = set.axes(obj, axes)
            gams.transfer.utils.Validator('axes', 1, axes).cellof('gams.transfer.symbol.unique_labels.Axis');
            obj.axes_ = axes;
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.unique_labels.Axis, ?gams.transfer.symbol.Abstract})

        function obj = Axes(axes)
            obj.axes_ = axes;
        end

    end

    methods (Static)

        function obj = construct(axes)
            gams.transfer.utils.Validator('axes', 1, axes).cellof('gams.transfer.symbol.unique_labels.Axis');
            obj = gams.transfer.symbol.unique_labels.Axes(axes);
        end

    end

    methods

        function dimension = dimension(obj)
            dimension = numel(obj.axes_);
        end

        function size = size(obj)
            dim = obj.dimension;
            size = zeros(1, dim);
            for i = 1:dim
                size(i) = obj.axes_{i}.size();
            end
        end

        function size = matrixSize(obj)
            dim = obj.dimension;
            size = ones(1, max(2, dim));
            size(1:dim) = obj.size();
        end

        function axis = axis(obj, dimension)
            axis = obj.axes_{dimension};
        end

        function [axis, idx] = find(obj, domain)
            axis = [];
            idx = 0;
            for i = 1:numel(obj.axes_)
                if obj.axes_{i}.domain == domain
                    axis = obj.axes_{i};
                    idx = i;
                    return
                end
            end
        end

    end

end
