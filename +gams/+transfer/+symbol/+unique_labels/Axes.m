% Symbol Domain (internal)
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright  (c) 2020-2023 GAMS Software GmbH <support@gams.com>
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
% Symbol Domain (internal)
%
classdef Axes < handle

    properties (Hidden, SetAccess = protected)
        axes_ = {}
    end

    methods (Static, Hidden)

        function arg = validateAxes(name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            for i = 1:numel(arg)
                if ~isa(arg{i}, 'gams.transfer.symbol.unique_labels.Axis')
                    error('Argument ''%s'' (at position %d, element %d) must be ''gams.transfer.symbol.unique_labels.Axis''.', name, index, i);
                end
            end
        end

    end

    properties (Dependent)
        axes
    end

    properties (Dependent, SetAccess = private)
        dimension
    end


    methods

        function axes = get.axes(obj)
            axes = obj.axes_;
        end

        function set.axes(obj, axes)
            obj.axes_ = obj.validateAxes('axes', 1, axes);
        end

        function dimension = get.dimension(obj)
            dimension = numel(obj.axes_);
        end

    end

    methods

        function obj = Axes(data, domains)
            % TODO check data
            % TODO check domains

            obj.axes_ = cell(1, numel(domains));
            for i = 1:numel(domains)
                obj.axes_{i} = gams.transfer.symbol.unique_labels.Axis(data, domains{i});
            end
        end

        function size = size(obj, use_super_unique_labels)
            if nargin == 1
                use_super_unique_labels = false;
            end
            size = zeros(1, obj.dimension);
            for i = 1:obj.dimension
                size(i) = obj.axes_{i}.size(use_super_unique_labels);
            end
        end

        function size = matrixSize(obj, use_super_unique_labels)
            if nargin == 1
                use_super_unique_labels = false;
            end
            size = ones(1, max(2, obj.dimension));
            size(1:obj.dimension) = obj.size(use_super_unique_labels);
        end

        function axis = axis(obj, dimension)
            % TODO check dimension
            axis = obj.axes_{dimension};
        end

    end

end
