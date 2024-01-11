classdef Empty < gams.transfer.symbol.data.Abstract

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
            name = 'empty';
        end

        function [flag, msg] = isValid(obj)
            if ~isempty(obj.records_)
                status = gams.transfer.utils.Status("Record data must be empty.");
                return
            end

            status = gams.transfer.utils.Status('OK');
        end

        function nrecs = getNumberRecords(obj)
            nrecs = 0;
        end

        function nvals = getNumberValues(obj, values)
            nvals = 0;
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
