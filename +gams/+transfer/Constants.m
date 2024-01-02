classdef Constants

    properties (Constant)

        MAX_NAME_LENGTH = 64
        MAX_DESCRIPTION_LENGTH = 256
        MAX_DIMENSION = 20

        UNIVERSE_NAME = '*'
        UNIVERSE_LABEL = 'uni'

        SUPPORTS_TABLE = gams.transfer.Constants.supportsTable()
        SUPPORTS_CATEGORICAL = gams.transfer.Constants.supportsCategorical()
    end

    methods (Hidden, Static)

        function flag = supportsTable()
            flag = true;
            try
                table();
            catch
                flag = false;
            end
        end

        function flag = supportsCategorical()
            flag = true;
            try
                categorical();
            catch
                flag = false;
            end
        end

    end

end
