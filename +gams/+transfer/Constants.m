classdef Constants

    properties (Constant)

        MAX_NAME_LENGTH = 64
        MAX_DESCRIPTION_LENGTH = 256
        MAX_DIMENSION = 20

        UNIVERSE_NAME = '*'
        UNIVERSE_LABEL = 'uni'

        SUPPORTS_TABLE = gams.transfer.Constants.supportsTable()
        SUPPORTS_CATEGORICAL = gams.transfer.Constants.supportsCategorical()

        OPERATING_SYSTEM = gams.transfer.Constants.operatingSystem()

        GDX_LIB_NAME = gams.transfer.Constants.gdxLibName()
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

        function os = operatingSystem()
            os = '';
            if ispc
                os = 'windows';
            elseif ismac
                [~,result] = system('uname -v');
                if any(strfind(result, 'ARM64'))
                    os = 'macos_arm';
                else
                    os = 'macos';
                end
            elseif isunix
                os = 'linux';
            else
                error('Unknown operating system.');
            end
        end

        function gdxlibname = gdxLibName()
            switch gams.transfer.Constants.OPERATING_SYSTEM
            case 'windows'
                gdxlibname = 'gdxcclib64.dll';
            case 'linux'
                gdxlibname = 'libgdxcclib64.so';
            case {'macos', 'macos_arm'}
                gdxlibname = 'libgdxcclib64.dylib';
            otherwise
                error('Unknown operating system.');
            end
        end

    end

end
