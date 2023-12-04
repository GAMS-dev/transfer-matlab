classdef Struct < gams.transfer.data.Tabular

    methods

        function name = name(obj)
            name = 'struct';
        end

        function [flag, msg] = isValid(obj)
            if ~isstruct(obj.records)
                flag = false;
                msg = "Record data must be 'struct'.";
                return
            end

            [flag, msg] = isValid@gams.transfer.data.Tabular(obj);
        end

        function flag = isDefinedLabel(obj, label)
            assert(isstruct(obj.records));
            flag = isfield(obj.records, label);
        end

        function labels = getLabels(obj)
            assert(isstruct(obj.records));
            labels = fieldnames(obj.records);
        end

    end
end
