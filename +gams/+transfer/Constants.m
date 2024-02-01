% Constants
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
% Constants
%
% Various GAMS Transfer Matlab wide valid constants.

%> @brief Constants
%>
%> Various GAMS Transfer Matlab wide valid constants.
classdef Constants

    properties (Constant)

        %> Max symbol name length

        % MAX_NAME_LENGTH Max symbol name length
        MAX_NAME_LENGTH = 64


        %> Max symbol description length

        % MAX_DESCRIPTION_LENGTH Max symbol description length
        MAX_DESCRIPTION_LENGTH = 256


        %> Max symbol dimension

        % MAX_DIMENSION Max symbol dimension
        MAX_DIMENSION = 20


        %> Name of universe set

        % UNIVERSE_NAME Name of universe set
        UNIVERSE_NAME = '*'


        %> Label of universe set

        % UNIVERSE_LABEL Label of universe set
        UNIVERSE_LABEL = 'uni'


        %> Label of undefined unique label

        % UNDEFINED_UNIQUE_LABEL Label of undefined unique label
        UNDEFINED_UNIQUE_LABEL = '<undefined>'


        %> True if table is supported

        % SUPPORTS_TABLE True if table is supported
        SUPPORTS_TABLE = gams.transfer.Constants.supportsTable()


        %> True if categorical is supported

        % SUPPORTS_CATEGORICAL True if categorical is supported
        SUPPORTS_CATEGORICAL = gams.transfer.Constants.supportsCategorical()


        %> Name of operating system

        % OPERATING_SYSTEM Name of operating system
        OPERATING_SYSTEM = gams.transfer.Constants.operatingSystem()


        %> Name of GDX library

        % GDX_LIB_NAME Name of GDX library
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

            env = getenv('GAMS_TRANSFER_MATLAB_SUPPORTS_TABLE');
            if ~isempty(env)
                if strcmpi(env, 'true')
                    flag = true;
                elseif strcmpi(env, 'false')
                    flag = false;
                end
            end
        end

        function flag = supportsCategorical()
            flag = true;
            try
                categorical();
            catch
                flag = false;
            end

            env = getenv('GAMS_TRANSFER_MATLAB_SUPPORTS_CATEGORICAL');
            if ~isempty(env)
                if strcmpi(env, 'true')
                    flag = true;
                elseif strcmpi(env, 'false')
                    flag = false;
                end
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
