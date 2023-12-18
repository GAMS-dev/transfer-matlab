% Domain
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
% Domain
%

%> @brief Domain
classdef Domain < handle

    properties (Hidden, SetAccess = protected)
        base_
        label_
        index_type_ = gams.transfer.def.DomainIndexType()
        unique_labels_ = []
        forwarding_ = false
    end

    methods (Hidden, Static)

        function arg = validateBase(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            if ~strcmp(arg, '*') && ~isvarname(arg)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', name, index)
            end
        end

        function arg = validateLabel(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
        end

        function arg = validateIndexType(name, index, arg)
            if isa(arg, 'gams.transfer.def.DomainIndexType')
                return
            end
            try
                arg = gams.transfer.def.DomainIndexType(arg);
            catch e
                error('Argument ''%s'' (at position %d) cannot create ''gams.transfer.def.DomainIndexType'': %s.', name, index, e.message);
            end
        end

        function arg = validateUniqueLabels(name, index, arg)
            if isnumeric(unique_labels) && isempty(unique_labels)
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
        base
        label
    end

    properties (Dependent, SetAccess = private)
        name
        type
    end

    properties (Dependent)
        index_type
        unique_labels
        forwarding
    end

    properties (Dependent, SetAccess = private)
        size
    end

    methods

        function base = get.base(obj)
            base = obj.base_;
        end

        function obj = set.base(obj, base)
            obj.base_ = obj.validateBase('base', 1, base);
        end

        function label = get.label(obj)
            label = obj.label_;
        end

        function obj = set.label(obj, label)
            obj.label_ = obj.validateLabel('label', label, true);
        end

        function name = get.name(obj)
            name = obj.base_;
        end

        function type = get.type(obj)
            if ischar(obj.base_)
                if strcmp(obj.base_, '*')
                    type = gams.transfer.def.DomainType.None;
                else
                    type = gams.transfer.def.DomainType.Relaxed;
                end
            end
        end

        function index_type = get.index_type(obj)
            index_type = obj.index_type_;
        end

        function obj = set.index_type(obj, index_type)
            obj.index_type_ = obj.validateIndexType('index_type', 1, index_type);
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

        function obj = set.forwarding(obj, forwarding)
            obj.forwarding_ = obj.validateForwarding('forwarding', 1, forwarding);
        end

        function size = get.size(obj)
            if isempty(obj.unique_labels_)
                size = nan;
            else
                size = obj.unique_labels_.size();
            end
        end

    end

    methods

        function obj = Domain(base)
            obj.base = base;
            obj.label_ = obj.name;
        end

        function flag = hasUniqueLabels(obj)
            flag = ~isempty(obj.unique_labels_);
        end

        function appendLabelIndex(obj, index)
            add = ['_', int2str(index)];
            if ~endsWith(obj.label_, add)
                obj.label_ = strcat(obj.label_, add);
            end
        end

    end

    methods (Static)

        function domains = createFromBases(bases)
            bases = gams.transfer.utils.validate('bases', 1, bases, {'cell'});
            domains = cell(1, numel(bases));
            for i = 1:numel(bases)
                domains{i} = gams.transfer.def.Domain(bases{i});
            end
        end

    end

end
