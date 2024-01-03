classdef CaseInsensitiveStruct < gams.transfer.ordered_dict.Abstract

    properties (Hidden, SetAccess = protected)
        count_ = 0
        keys_ = struct()
        entries_ = struct()
    end

    methods (Hidden, Static)

        function arg = validateKey(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if ~isvarname(arg)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', name, index);
            end
        end

    end

    properties (Dependent, SetAccess = protected)
        entries
    end

    methods

        function entries = get.entries(obj)
            entries = obj.entries_;
        end

    end

    methods
        function n = count(obj)
            n = obj.count_;
        end

        function flag = hasKey(obj, key)
            flag = isfield(obj.keys_, lower(key));
        end

        function flags = hasKeys(obj, keys)
            keys = gams.transfer.utils.validate('keys', 1, keys, {'cell'}, -1);
            flags = true(size(keys));
            for i = 1:numel(keys)
                flags(i) = obj.hasKey(keys{i});
            end
        end

        function keys = getAllKeys(obj)
            keys = fieldnames(obj.entries_);
        end

        function key = getKey(obj, key)
            key = obj.keys_.(lower(key));
        end

        function keys = getKeys(obj, keys)
            keys = gams.transfer.utils.validate('keys', 1, keys, {'cell'}, -1);
            for i = 1:numel(keys)
                keys{i} = obj.getKey(keys{i});
            end
        end

        function key = getKeyAt(obj, index)
            keys = fieldnames(obj.keys_);
            key = keys{index};
        end

        function keys = getKeysAt(obj, indices)
            keys = fieldnames(obj.keys_);
            keys = keys(indices);
        end

        function index = findKey(obj, key)
            index = find(strcmpi(fieldnames(obj.keys_), key), 1, 'first');
            if isempty(index)
                index = 0;
            end
        end

        function indices = findKeys(obj, keys)
            keys = gams.transfer.utils.validate('keys', 1, keys, {'cell'}, -1);
            indices = zeros(size(keys));
            for i = 1:numel(keys)
                indices(i) = obj.findKey(keys{i});
            end
        end

        function entries = getAllEntries(obj)
            entries = struct2cell(obj.entries_);
        end

        function entry = getEntry(obj, key)
            entry = obj.entries_.(obj.getKey(key));
        end

        function entries = getEntries(obj, keys)
            keys = obj.getKeys(keys);
            entries = cell(size(keys));
            for i = 1:numel(keys)
                entries{i} = obj.getEntry(keys{i});
            end
        end

        function entry = getEntryAt(obj, index)
            entry = obj.entries_.(obj.getKeyAt(index));
        end

        function entries = getEntriesAt(obj, indices)
            entries = cell(size(indices));
            keys = obj.getKeysAt(indices);
            for i = 1:numel(indices)
                entries{i} = obj.entries_.(keys{i});
            end
        end

        function add(obj, key, entry)
            key = obj.validateKey('key', 1, key);
            if obj.hasKey(key)
                error('Entry ''%s'' already exists.', key);
            end
            obj.keys_.(lower(key)) = key;
            obj.entries_.(key) = entry;
            obj.count_ = obj.count_ + 1;
        end

        function clear(obj)
            obj.count_ = 0;
            obj.keys_ = struct();
            obj.entries_ = struct();
        end

        function symbol = rename(obj, oldkey, newkey)
            index = obj.findKey(oldkey);
            if index < 1
                return
            end
            oldkey = obj.getKey(oldkey);

            % add new symbol / remove old symbol
            obj.entries_.(newkey) = obj.entries_.(oldkey);
            obj.entries_ = rmfield(obj.entries_, oldkey);
            obj.keys_ = rmfield(obj.keys_, lower(oldkey));
            obj.keys_.(lower(newkey)) = newkey;
            symbol = obj.entries_.(newkey);

            % get old ordering
            permutation = [1:index-1, obj.count_, index:obj.count_-1];
            obj.reorder(permutation);
        end

        function remove(obj, keys)
            if ~iscell(keys)
                keys = {keys};
            end
            for i = 1:numel(keys)
                if ~obj.hasKey(keys{i})
                    continue
                end
                key = obj.getKey(keys{i});
                obj.entries_ = rmfield(obj.entries_, key);
                obj.keys_ = rmfield(obj.keys_, lower(key));
            end
        end

        function reorder(obj, permutation)
            obj.entries_ = orderfields(obj.entries_, permutation);
            obj.keys_ = orderfields(obj.keys_, permutation);
        end
    end

end
