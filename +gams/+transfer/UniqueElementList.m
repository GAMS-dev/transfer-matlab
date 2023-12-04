% Unique Element List (UEL)
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
% Unique Element List (UEL)
classdef UniqueElementList < handle

    properties (Hidden, SetAccess = private)
        uels_label2ids
        uels_id2labels
    end

    methods

        function obj = UniqueElementList()
            obj.uels_label2ids = javaObject("java.util.LinkedHashMap");
            obj.uels_id2labels = {};
        end

        function eq = equals(obj, other)
            eq = isequaln(obj.uels_id2labels, other.uels_id2labels) && ...
                obj.uels_label2ids.equals(obj.uels_label2ids);
        end

        function size = size(obj)
            size = numel(obj.uels_id2labels);
        end

        function list = get(obj)
            list = obj.uels_id2labels;
        end

        function list = getLabels(obj, ids)
            if ~isnumeric(ids)
                error('Argument must be ''numeric''.');
            end

            list = cell(1, numel(ids));
            for i = 1:numel(ids)
                if ids(i) < 1 || ids(i) > numel(obj.uels_id2labels)
                    list{i} = '<undefined>';
                else
                    list{i} = obj.uels_id2labels{ids(i)};
                end
            end
        end

        function ids = getIds(obj, label)
            if ~iscellstr(label)
                error('Argument must be ''cellstr''.');
            end

            ids = zeros(1, numel(label));
            for i = 1:numel(ids)
                id = obj.uels_label2ids.get(label{i});
                if isempty(id)
                    ids(i) = 0;
                else
                    ids(i) = id;
                end
            end
        end

        function vals = set(obj, list, vals)
            if ischar(list) || isstring(list)
                list = {list};
            elseif ~iscellstr(list)
                error('Argument #1 must be of type ''cellstr''.');
            end
            if ~isnumeric(vals)
                error('Argument #2 must be ''numeric''.');
            end

            if numel(vals) > 0
                newvals = zeros(1, obj.uels_label2ids.size(), class(vals));
                for i = 1:numel(list)
                    if obj.uels_label2ids.containsKey(list{i})
                        id = obj.uels_label2ids.get(list{i});
                        if newvals(id) == 0
                            newvals(id) = i;
                        end
                    end
                end
                vals(vals < 1 | vals > obj.uels_label2ids.size()) = 0;
                idx = vals > 0;
                vals(idx) = newvals(vals(idx));
            end

            obj.uels_label2ids.clear();
            obj.uels_id2labels = {};
            obj.add(list);
        end

        function add(obj, list)
            if ischar(list) || isstring(list)
                list = {list};
            elseif ~iscellstr(list)
                error('Argument must be of type ''cellstr''.');
            end

            for i = 1:numel(list)
                if ~obj.uels_label2ids.containsKey(list{i})
                    obj.uels_label2ids.put(list{i}, obj.uels_label2ids.size() + 1);
                end
            end
            if numel(list) > 0
                obj.updateId2Label();
            end
        end

        function vals = remove(obj, list, vals)
            if ischar(list) || isstring(list)
                list = {list};
            elseif ~iscellstr(list)
                error('Argument #1 must be of type ''cellstr''.');
            end
            if obj.uels_label2ids.size() == 0
                return
            end
            if ~isnumeric(vals)
                error('Argument #2 must be ''numeric''.');
            end
            if numel(list) == 0
                return
            end

            if numel(vals) > 0
                ids = obj.getIds(list);
            end

            for i = 1:numel(list)
                obj.uels_label2ids.remove(list{i});
            end
            obj.updateId2Label();
            for i = 1:numel(obj.uels_id2labels)
                obj.uels_label2ids.put(obj.uels_id2labels{i}, i);
            end

            if numel(vals) > 0
                idx = zeros(size(vals), class(vals));
                for i = 1:numel(ids)
                    if ids(i) > 0
                        vals(vals == ids(i)) = 0;
                        idx(vals > ids(i)) = idx(vals > ids(i)) + 1;
                    end
                end
                vals = vals - idx;
                vals(vals < 1 | vals > obj.uels_label2ids.size()) = 0;
            end
        end

        function vals = rename(obj, oldlist, newlist, vals)
            if ischar(oldlist) || isstring(oldlist)
                oldlist = {oldlist};
            elseif ~iscellstr(oldlist)
                error('Argument #1 must be of type ''cellstr''.');
            end
            if ischar(newlist) || isstring(newlist)
                newlist = {newlist};
            elseif ~iscellstr(newlist)
                error('Argument #1 must be of type ''cellstr''.');
            end
            if numel(oldlist) ~= numel(newlist)
                error('Arguments must have same length.');
            end
            if numel(oldlist) == 0
                return
            end

            remove = false(1, numel(obj.uels_id2labels));
            for i = 1:numel(newlist)
                if strcmp(oldlist{i}, newlist{i})
                    continue
                end
                if obj.uels_label2ids.containsKey(oldlist{i}) && obj.uels_label2ids.containsKey(newlist{i})
                    vals(vals == obj.uels_label2ids.get(oldlist{i})) = obj.uels_label2ids.get(newlist{i});
                    remove(i) = true;
                end
            end
            vals = obj.remove(obj.uels_id2labels(remove), vals);

            list = obj.uels_id2labels;
            for i = 1:numel(newlist)
                if strcmp(oldlist{i}, newlist{i})
                    continue
                end
                if obj.uels_label2ids.containsKey(oldlist{i})
                    list{obj.uels_label2ids.get(oldlist{i})} = newlist{i};
                end
            end
            obj.set(list, []);
        end

    end

    methods (Hidden)

        function updateId2Label(obj)
            obj.uels_id2labels = cell(1, obj.uels_label2ids.keySet().size());
            it = obj.uels_label2ids.keySet().iterator();
            i = 1;
            while it.hasNext()
                obj.uels_id2labels{i} = char(it.next());
                i = i + 1;
            end
        end

    end

end
