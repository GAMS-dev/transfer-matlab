classdef SymbolType
    % GAMSTransferSymbol Types
    %
    % This class holds the possible GAMSTransfer symbol types similar to an
    % enumeration class. Note that it is not an enumeration class due to
    % compatibility (e.g. for Octave).
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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

    properties (Constant)
        % SET GAMS Set
        SET = 0

        % PARAMETER GAMS Parameter
        PARAMETER = 1

        % VARIABLE GAMS Variable
        VARIABLE = 2

        % EQUATION GAMS Equation
        EQUATION = 3

        % ALIAS GAMS Alias
        ALIAS = 4
    end

end
