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
classdef (Abstract) Domain < handle

    properties (Hidden, SetAccess = protected)
        label_
        unique_labels_ = []
        forwarding_ = false
    end

    methods (Hidden, Static)

        function arg = validateLabel(name, index, arg)
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
            if isnumeric(arg) && isempty(arg)
                arg = [];
                return
            end
            if ~isa(arg, 'gams.transfer.unique_labels.Abstract')
                error('Argument ''%s'' (at position %d) must be empty or ''gams.transfer.unique_labels.Abstract''.', name, index);
            end
        end

        function arg = validateForwarding(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

    end

    properties (Dependent)
        label
        unique_labels
        forwarding
    end

    properties (Abstract)
        name
    end

    properties (Abstract, SetAccess = private)
        base
    end

    methods

        function label = get.label(obj)
            label = obj.label_;
        end

        function set.label(obj, label)
            obj.label_ = obj.validateLabel('label', 1, label);
        end

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function obj = set.unique_labels(obj, unique_labels)
            obj.unique_labels_ = obj.validateUniqueLabels('unique_labels', 1, unique_labels);
        end

        function forwarding = get.forwarding(obj)
            forwarding = obj.forwarding_;
        end

        function set.forwarding(obj, forwarding)
            obj.forwarding_ = obj.validateForwarding('forwarding', 1, forwarding);
        end

    end

    methods (Abstract)
        status = isValid(obj)
    end

    methods

        function eq = equals(obj, domain)
            eq = isequal(class(obj), class(domain)) && ...
                isequal(obj.label_, domain.label) && ...
                isequal(obj.unique_labels_, domain.unique_labels) && ...
                isequal(obj.forwarding_, domain.forwarding);
        end

        function appendLabelIndex(obj, index)
            add = ['_', int2str(index)];
            if ~endsWith(obj.label_, add)
                obj.label_ = strcat(obj.label_, add);
            end
        end

        function flag = hasUniqueLabels(obj)
            flag = ~isempty(obj.unique_labels_);
        end

        function flag = hasSuperUniqueLabels(obj)
            flag = false;
        end

        function unique_labels = getUniqueLabels(obj)
            if ~obj.hasUniqueLabels()
                error('Domain does not maintain working unique labels.');
            end
            unique_labels = obj.unique_labels_;
        end

        function axis = axis(obj, data)
            axis = gams.transfer.symbol.unique_labels.Axis(data, obj);
        end

        function unique_labels = getSuperUniqueLabels(obj)
            error('Domain does not maintain super unique labels.');
        end

    end

end
