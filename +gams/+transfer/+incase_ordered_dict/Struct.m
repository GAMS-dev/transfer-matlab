% Struct based Case Insensitive Ordered Dictionary (internal)
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
% Struct based Case Insensitive Ordered Dictionary (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Struct < gams.transfer.incase_ordered_dict.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        count_ = 0
        keys_ = struct()
        entries_ = struct()
    end

    methods

        function n = count(obj)
            n = obj.count_;
        end

        function flag = exists(obj, keys)
            if iscell(keys)
                flag = true(size(keys));
                for i = 1:numel(keys)
                    flag(i) = isfield(obj.keys_, lower(keys{i}));
                end
            else
                flag = isfield(obj.keys_, lower(keys));
            end
        end

        function keys = keys(obj, keys)
            if nargin == 1
                keys = fieldnames(obj.entries_);
            elseif iscell(keys)
                for i = 1:numel(keys)
                    keys{i} = obj.keys_.(lower(keys{i}));
                end
            else
                keys = obj.keys_.(lower(keys));
            end
        end

        function keys = keysAt(obj, indices)
            keys = fieldnames(obj.keys_);
            if numel(indices) == 1
                keys = keys{indices};
            else
                keys = keys(indices);
            end
        end

        function indices = find(obj, keys)
            if iscell(keys)
                indices = zeros(size(keys));
                for i = 1:numel(keys)
                    index = find(strcmpi(fieldnames(obj.keys_), keys{i}), 1, 'first');
                    if isempty(index)
                        indices(i) = 0;
                    else
                        indices(i) = index;
                    end
                end
            else
                indices = find(strcmpi(fieldnames(obj.keys_), keys), 1, 'first');
                if isempty(indices)
                    indices = 0;
                end
            end
        end

        function entries = entries(obj, keys)
            if nargin == 1
                entries = struct2cell(obj.entries_);
            elseif iscell(keys)
                entries = cell(size(keys));
                for i = 1:numel(keys)
                    entries{i} = obj.entries_.(obj.keys(keys{i}));
                end
            else
                entries = obj.entries_.(obj.keys(keys));
            end
        end

        function entries = entriesAt(obj, indices)
            entries = obj.entries();
            if numel(indices) == 1
                entries = entries{indices};
            else
                entries = entries(indices);
            end
        end

        function obj = add(obj, key, entry)
            if obj.exists(key)
                error('Entry ''%s'' already exists.', key);
            end
            obj.keys_.(lower(key)) = key;
            obj.entries_.(key) = entry;
            obj.count_ = obj.count_ + 1;
        end

        function obj = clear(obj)
            obj.count_ = 0;
            obj.keys_ = struct();
            obj.entries_ = struct();
        end

        function [obj, symbol] = rename(obj, oldkey, newkey)
            index = obj.find(oldkey);
            if index < 1
                return
            end
            oldkey = obj.keys(oldkey);

            % add new symbol / remove old symbol
            obj.entries_.(newkey) = obj.entries_.(oldkey);
            obj.entries_ = rmfield(obj.entries_, oldkey);
            obj.keys_ = rmfield(obj.keys_, lower(oldkey));
            obj.keys_.(lower(newkey)) = newkey;
            symbol = obj.entries_.(newkey);

            % get old ordering
            permutation = [1:index-1, obj.count_, index:obj.count_-1];
            obj = obj.reorder(permutation);
        end

        function obj = remove(obj, keys)
            if ~iscell(keys)
                keys = {keys};
            end
            for i = 1:numel(keys)
                if ~obj.exists(keys{i})
                    continue
                end
                key = obj.keys(keys{i});
                obj.entries_ = rmfield(obj.entries_, key);
                obj.keys_ = rmfield(obj.keys_, lower(key));
            end
        end

        function obj = reorder(obj, permutation)
            obj.entries_ = orderfields(obj.entries_, permutation);
            obj.keys_ = orderfields(obj.keys_, permutation);
        end
    end

end
