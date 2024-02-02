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
classdef Axis < handle

    properties (Hidden, SetAccess = protected)
        label_
        unique_labels_
    end

    methods (Static, Hidden)

        function arg = validatelabel(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            if ~isvarname(arg)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', name, index)
            end
        end

        function arg = validateUniqueLabels(name, index, arg)
            if ~isa(arg, 'gams.transfer.unique_labels.Abstract')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.unique_labels.Abstract''.', name, index);
            end
        end

    end

    properties (Dependent)
        label
        unique_labels
    end

    methods

        function label = get.label(obj)
            label = obj.label_;
        end

        function set.label(obj, label)
            obj.label_ = obj.validatelabel('label', 1, label);
        end

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function set.unique_labels(obj, unique_labels)
            obj.unique_labels_ = obj.validateUniqueLabels('unique_labels', 1, unique_labels);
        end

    end

    methods

        function obj = Axis(label, unique_labels)
            obj.label = label;
            obj.unique_labels = unique_labels;
        end

        function size = size(obj)
            size = obj.unique_labels_.count();
        end

    end

end
