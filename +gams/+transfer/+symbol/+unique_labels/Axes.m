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
classdef (Hidden) Axes < handle

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

        function set.axes(obj, axes)
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
            size = zeros(1, obj.dimension);
            for i = 1:obj.dimension
                size(i) = obj.axes_{i}.size();
            end
        end

        function size = matrixSize(obj)
            size = ones(1, max(2, obj.dimension));
            size(1:obj.dimension) = obj.size();
        end

        function axis = axis(obj, dimension)
            axis = obj.axes_{dimension};
        end

        function labels = getUniqueLabelsAt(obj, indices)
            gams.transfer.utils.Validator('indices', 1, indices).type('cell');
            labels = cell(size(indices));
            for i = 1:numel(labels)
                gams.transfer.utils.Validator(sprintf('indices{%d}', i), 1, indices{i}).numeric().integer().minnumel(obj.dimension);
                labels{i} = cell(1, obj.dimension);
                for j = 1:obj.dimension
                    labels{i}{j} = obj.axes{j}.unique_labels.getAt(indices{i}(j));
                end
            end
            if numel(indices) == 1
                labels = labels{1};
            end
        end

    end

end
