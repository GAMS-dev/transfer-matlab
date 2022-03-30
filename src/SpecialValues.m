% GAMS Special Values
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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
% GAMS Special Values
%

%> GAMS Special Values
classdef SpecialValues

    properties (Constant)
        %> Undefined value

        % UNDEF Undefined value
        UNDEF = nan


        %> Value not available (in Matlab: special nan value)

        % NA Value not available (in Matlab: special nan value)
        NA = GAMSTransfer.gt_cmex_getna()


        %> Explicit zero (in Matlab: negative zero)

        % EPS Explicit zero (in Matlab: negative zero)
        EPS = GAMSTransfer.gt_cmex_geteps()


        %> positive infinity

        % POSINF positive infinity
        POSINF = inf


        %> negative infinity

        % NEGINF negative infinity
        NEGINF = -inf

    end

    methods (Static)

        %> Checks if values are GAMS UNDEF
        %>
        %> - `b = isUndef(v)` checks if the values `v` are GAMS UNDEF values
        %>
        %> **Example:**
        %> ```
        %> b = SpecialValues.isUndef([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
        %> ```
        %> `b` equals `[0, 0, 0, 1]`
        function bool = isUndef(value)
            % Checks if values are GAMS UNDEF
            %
            % b = isUndef(v) checks if the values v are GAMS UNDEF values
            %
            % Example:
            % b = SpecialValues.isUndef([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
            % b equals [0, 0, 0, 1]

            bool = isnan(value) & ~GAMSTransfer.gt_cmex_isna(value);
        end

        %> Checks if values are GAMS NA
        %>
        %> - `b = isNA(v)` checks if the values `v` are GAMS NA values
        %>
        %> **Example:**
        %> ```
        %> b = SpecialValues.isNA([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
        %> ```
        %> `b` equals `[0, 0, 1, 0]`
        function bool = isNA(value)
            % Checks if values are GAMS NA
            %
            % b = isNA(v) checks if the values v are GAMS NA values
            %
            % Example:
            % b = SpecialValues.isNA([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
            % b equals [0, 0, 1, 0]

            bool = GAMSTransfer.gt_cmex_isna(value);
        end

        %> Checks if values are GAMS EPS
        %>
        %> - `b = isEps(v)` checks if the values `v` are GAMS EPS values
        %>
        %> **Example:**
        %> ```
        %> b = SpecialValues.isEps([0, 1, SpecialValues.EPS, SpecialValues.UNDEF])
        %> ```
        %> `b` equals `[0, 0, 1, 0]`
        function bool = isEps(value)
            % Checks if values are GAMS EPS
            %
            % b = isEps(v) checks if the values v are GAMS EPS values
            %
            % Example:
            % b = SpecialValues.isEps([0, 1, SpecialValues.EPS, SpecialValues.UNDEF])
            % b equals [0, 0, 1, 0]

            bool = GAMSTransfer.gt_cmex_iseps(value);
        end

        %> Checks if values are GAMS PINF
        %>
        %> - `b = isPosInf(v)` checks if the values `v` are GAMS POSINF values
        %>
        %> **Example:**
        %> ```
        %> b = SpecialValues.isPosInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
        %> ```
        %> `b` equals `[0, 0, 1, 0]`
        function bool = isPosInf(value)
            % Checks if values are GAMS PINF
            %
            % b = isPosInf(v) checks if the values v are GAMS POSINF values
            %
            % Example:
            % b = SpecialValues.isPosInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
            % b equals [0, 0, 1, 0]

            bool = isinf(value) & value > 0;
        end

        %> Checks if values are GAMS MINF
        %>
        %> - `b = isNegInf(v)` checks if the values `v` are GAMS MINF values
        %>
        %> **Example:**
        %> ```
        %> b = SpecialValues.isNegInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
        %> ```
        %> `b` equals `[0, 0, 0, 1]`
        function bool = isNegInf(value)
            % Checks if values are GAMS MINF
            %
            % b = isNegInf(v) checks if the values v are GAMS MINF values
            %
            % Example:
            % b = SpecialValues.isNegInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
            % b equals [0, 0, 0, 1]

            bool = isinf(value) & value < 0;
        end

    end

end
