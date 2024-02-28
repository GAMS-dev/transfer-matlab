% Ordered Label Set based Unique Labels (internal)
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
% Ordered Label Set based Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) OrderedLabelSet < gams.transfer.unique_labels.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = private)
        uels_label2ids_
        uels_id2labels_
        time_ = gams.transfer.utils.Time()
    end

    methods

        function obj = OrderedLabelSet(labels)
            obj.clear();
            if nargin >= 1
                obj.add(labels);
            end
        end

    end

    methods (Static)

        function obj = construct(labels)
            if nargin == 1
                obj = gams.transfer.unique_labels.OrderedLabelSet(labels);
            else
                obj = gams.transfer.unique_labels.OrderedLabelSet();
            end
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.OrderedLabelSet(obj.get());
        end

        function labels = get(obj)
            labels = obj.uels_id2labels_;
        end

        function clear(obj)
            obj.uels_label2ids_ = javaObject("java.util.LinkedHashMap");
            obj.uels_id2labels_ = {};
            obj.time_ = obj.time_.reset();
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.symbol.data.Abstract, ...
        ?gams.transfer.symbol.domain.Abstract})

        function [flag, time] = updatedAfter_(obj, time)
            flag = time <= obj.time_;
            if flag
                time = obj.time_;
            end
        end

        function add_(obj, labels)
            for i = 1:numel(labels)
                if ~obj.uels_label2ids_.containsKey(labels{i})
                    obj.uels_label2ids_.put(labels{i}, obj.uels_label2ids_.size() + 1);
                end
            end
            if numel(labels) > 0
                obj.updateId2Label_();
            end
            obj.time_ = obj.time_.reset();
        end

        function set_(obj, labels)
            obj.clear();
            obj.add_(labels);
        end

        function [flag, indices] = remove_(obj, labels)
            if nargout > 0
                oldlabels = obj.get();
            end
            for i = 1:numel(labels)
                obj.uels_label2ids_.remove(labels{i});
            end
            obj.updateId2Label_();
            for i = 1:numel(obj.uels_id2labels_)
                obj.uels_label2ids_.put(obj.uels_id2labels_{i}, i);
            end
            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels, [], []);
            end
            obj.time_ = obj.time_.reset();
        end

        function rename_(obj, oldlabels, newlabels)
            if numel(oldlabels) == 0
                return
            end

            labels = obj.uels_id2labels_;
            for i = 1:numel(oldlabels)
                if strcmp(oldlabels{i}, newlabels{i}) || ~obj.uels_label2ids_.containsKey(oldlabels{i})
                    continue
                end
                if obj.uels_label2ids_.containsKey(newlabels{i})
                    error('Unique label ''%s'' already exists', newlabels{i});
                end
                labels{obj.uels_label2ids_.get(oldlabels{i})} = newlabels{i};
            end
            obj.set(labels);
        end

        function [flag, indices] = merge_(obj, oldlabels, newlabels)
            if nargout > 0
                oldlabels_ = obj.get();
            end

            for i = 1:numel(oldlabels)
                if strcmp(oldlabels{i}, newlabels{i}) || ~obj.uels_label2ids_.containsKey(oldlabels{i})
                    continue
                end
                labels = obj.uels_id2labels_;
                if obj.uels_label2ids_.containsKey(newlabels{i})
                    labels(obj.uels_label2ids_.get(oldlabels{i})) = [];
                else
                    labels{obj.uels_label2ids_.get(oldlabels{i})} = newlabels{i};
                end
                obj.clear();
                for j = 1:numel(labels)
                    obj.uels_label2ids_.put(labels{j}, obj.uels_label2ids_.size() + 1);
                end
                obj.updateId2Label_();
            end

            if nargout > 0
                [flag, indices] = obj.updatedIndices_(oldlabels_, oldlabels, newlabels);
            end
        end

    end

    methods (Hidden, Access = protected)

        function updateId2Label_(obj)
            obj.uels_id2labels_ = cell(1, obj.uels_label2ids_.keySet().size());
            it = obj.uels_label2ids_.keySet().iterator();
            i = 1;
            while it.hasNext()
                obj.uels_id2labels_{i} = char(it.next());
                i = i + 1;
            end
            obj.time_ = obj.time_.reset();
        end

    end

end
