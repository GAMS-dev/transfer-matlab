% Dictionary
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2023 GAMS Software GmbH <support@gams.com>
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
% Dictionary
%

%> @brief Abstract UELs
classdef OrderedLabelSet < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = private)
        uels_label2ids_
        uels_id2labels_
    end

    methods

        function obj = OrderedLabelSet(labels)
            obj.clear();
            if nargin >= 1
                obj.add(labels);
            end
        end

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.OrderedLabelSet(obj.get());
        end

        function labels = get(obj)
            labels = obj.uels_id2labels_;
        end

        function clear(obj)
            obj.uels_label2ids_ = javaObject("java.util.LinkedHashMap");
            obj.uels_id2labels_ = {};
        end

        function add(obj, labels)
            % TODO check labels
            if ischar(labels) || isstring(labels)
                labels = {labels};
            end
            for i = 1:numel(labels)
                if ~obj.uels_label2ids_.containsKey(labels{i})
                    obj.uels_label2ids_.put(labels{i}, obj.uels_label2ids_.size() + 1);
                end
            end
            if numel(labels) > 0
                obj.updateId2Label();
            end
        end

        function set(obj, labels)
            obj.clear();
            obj.add(labels);
        end

        function remove(obj, labels)
            % TODO check labels
            if ischar(labels) || isstring(labels)
                labels = {labels};
            end
            if obj.uels_label2ids_.size() == 0 || numel(labels) == 0
                return
            end
            for i = 1:numel(labels)
                obj.uels_label2ids_.remove(labels{i});
            end
            obj.updateId2Label();
            for i = 1:numel(obj.uels_id2labels_)
                obj.uels_label2ids_.put(obj.uels_id2labels_{i}, i);
            end
        end

        function rename(obj, oldlabels, newlabels)

        end

    end

    methods (Hidden, Access = protected)

        function updateId2Label(obj)
            obj.uels_id2labels_ = cell(1, obj.uels_label2ids_.keySet().size());
            it = obj.uels_label2ids_.keySet().iterator();
            i = 1;
            while it.hasNext()
                obj.uels_id2labels_{i} = char(it.next());
                i = i + 1;
            end
        end

    end

end
