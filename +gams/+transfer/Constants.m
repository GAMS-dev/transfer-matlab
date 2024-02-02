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
        SUPPORTS_TABLE = gams.transfer.utils.supports_table()


        %> True if categorical is supported

        % SUPPORTS_CATEGORICAL True if categorical is supported
        SUPPORTS_CATEGORICAL = gams.transfer.utils.supports_categorical()


        %> Name of operating system

        % OPERATING_SYSTEM Name of operating system
        OPERATING_SYSTEM = gams.transfer.utils.operating_system()


        %> Name of GDX library

        % GDX_LIBRARY_NAME Name of GDX library
        GDX_LIBRARY_NAME = gams.transfer.utils.gdx_library_name()
    end

end
