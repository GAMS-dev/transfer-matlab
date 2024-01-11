classdef Struct < gams.transfer.symbol.data.Tabular

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            try
                labels = fieldnames(obj.records_);
            catch
                labels = {};
            end
        end

    end

    methods

        function name = name(obj)
            name = 'struct';
        end

        function status = isValid(obj, def)
            if ~isstruct(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'struct'.");
                return
            end

            status = isValid@gams.transfer.symbol.data.Tabular(obj, def);
        end

    end

end
