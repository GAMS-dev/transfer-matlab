classdef (Abstract) Abstract < handle

    methods (Abstract)
        n = count(obj)

        flag = hasKey(obj, key)
        flags = hasKeys(obj, keys)
        keys = getAllKeys(obj)
        key = getKey(obj, key)
        keys = getKeys(obj, keys)
        key = getKeyAt(obj, index)
        keys = getKeysAt(obj, indices)
        index = findKey(obj, key)
        indices = findKeys(obj, keys)

        entries = getAllEntries(obj)
        entry = getEntry(obj, key)
        entries = getEntries(obj, keys)
        entry = getEntryAt(obj, index)
        entries = getEntriesAt(obj, indices)

        add(obj, key, entry)
        clear(obj)

        symbol = rename(obj, oldkey, newkey)
        remove(obj, keys)
        reorder(obj, permutation)
    end

end
