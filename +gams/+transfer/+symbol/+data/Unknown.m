classdef Unknown < gams.transfer.symbol.data.Abstract

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            labels = {};
        end

    end

    methods

        function name = name(obj)
            name = 'unknown';
        end

        function [flag, msg] = isValid(obj)
        end

        function nrecs = getNumberRecords(obj)
            nrecs = nan;
        end

        function nvals = getNumberValues(obj, values)
            nvals = nan;
        end

    end

    methods (Hidden, Access = protected)

        function arg = validateDomains(name, index, arg)

        end

        function uels = getUniqueLabelsAt(obj, domain, ignore_unused)
            error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                obj.name(), domain.index_type.select);
        end

        function setUniqueLabelsAt(obj, uels, domain, rename)
            error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                obj.name(), domain.index_type.select);
        end

        function addUniqueLabelsAt(obj, uels, domain)
            error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                obj.name(), domain.index_type.select);
        end

        function removeUniqueLabelsAt(obj, uels, domain)
            error('Records format ''%s'' does not supported domain index type ''%s''.', ...
                obj.name(), domain.index_type.select);
        end

    end
end
