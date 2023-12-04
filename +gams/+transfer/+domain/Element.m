% Domain Element
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
% Domain Element
%

%> @brief Domain Element
classdef Element < handle

    properties (Hidden, SetAccess = protected)
        def_
        label_ = 'uni'
        index_type_ = gams.transfer.domain.IndexType()
        unique_labels_ = []
    end

    properties (Dependent)
        def
        label
    end

    properties (Dependent, SetAccess = private)
        name
        type
    end

    properties (Dependent)
        index_type
        unique_labels
    end

    properties (Dependent, SetAccess = private)
        size
    end

    methods

        function def = get.def(obj)
            def = obj.def_;
        end

        function obj = set.def(obj, def)
            if isstring(def)
                def = char(def)
            end
            validateattributes(def, {'char'}, {'nonempty', 'vector'}, 'set.def', 'def', 1);
            if ~strcmp(def, '*') && ~isvarname(def)
                error('Invalid def. Must start with letter and must only consist of letters, digits and underscores.')
            end
            obj.def_ = def;
        end

        function label = get.label(obj)
            label = obj.label_;
        end

        function obj = set.label(obj, label)
            if isstring(label)
                label = char(label)
            end
            validateattributes(label, {'char'}, {'nonempty', 'vector'}, 'set.label', 'label', 1);
            if ~isvarname(label)
                error('Invalid label. Must start with letter and must only consist of letters, digits and underscores.')
            end
            obj.label_ = label;
        end

        function name = get.name(obj)
            name = obj.def_;
        end

        function type = get.type(obj)
            if ischar(obj.def_)
                if strcmp(obj.def_, '*')
                    type = gams.transfer.domain.Type('none');
                else
                    type = gams.transfer.domain.Type('relaxed');
                end
            end
        end

        function index_type = get.index_type(obj)
            index_type = obj.index_type_;
        end

        function obj = set.index_type(obj, index_type)
            if isnumeric(index_type) || isstring(index_type) || ischar(index_type)
                index_type = gams.transfer.domain.DomainIndexType(index_type)
            else
                validateattributes(index_type, {'gams.transfer.domain.DomainIndexType'}, {}, 'set.index_type', 'index_type', 1);
            end
            obj.index_type_ = index_type;
        end

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function obj = set.unique_labels(obj, unique_labels)
            if isnumeric(unique_labels) && isempty(unique_labels)
                obj.unique_labels_ = [];
                return
            end
            validateattributes(unique_labels, {'gams.transfer.unique_labels.Abstract'}, {}, 'set.unique_labels', 'unique_labels', 1);
            obj.unique_labels_ = unique_labels;
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

        function obj = Element(def)
            obj.def = def;
            obj.label = obj.name;
            if nargin >= 2
                obj.unique_labels = unique_labels;
            end
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

end
