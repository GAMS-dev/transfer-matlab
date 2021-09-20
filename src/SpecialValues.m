classdef SpecialValues
    % GAMS Special Values
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

        % UNDEF Undefined value
        UNDEF = nan

        % NA Value not available (in Matlab: special nan value)
        NA = GAMSTransfer.gt_getna()

        % EPS Explicit zero (in Matlab: negative zero)
        EPS = GAMSTransfer.gt_geteps()

        % POSINF positive infinity
        POSINF = inf

        % NEGINF negative infinity
        NEGINF = -inf

    end

    methods (Static)

        function bool = isUndef(value)
            % Checks if values are GAMS UNDEF
            %
            % b = isUndef(v) checks if the values v are GAMS UNDEF values
            %
            % Example:
            % b = SpecialValues.isUndef([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
            % b equals [0, 0, 0, 1]
            %

            bool = isnan(value) & ~GAMSTransfer.gt_isna(value);
        end

        function bool = isNa(value)
            % Checks if values are GAMS NA
            %
            % b = isNa(v) checks if the values v are GAMS NA values
            %
            % Example:
            % b = SpecialValues.isNa([0, 1, SpecialValues.NA, SpecialValues.UNDEF])
            % b equals [0, 0, 1, 0]
            %

            bool = GAMSTransfer.gt_isna(value);
        end

        function bool = isEps(value)
            % Checks if values are GAMS EPS
            %
            % b = isEps(v) checks if the values v are GAMS EPS values
            %
            % Example:
            % b = SpecialValues.isEps([0, 1, SpecialValues.EPS, SpecialValues.UNDEF])
            % b equals [0, 0, 1, 0]
            %

            bool = GAMSTransfer.gt_iseps(value);
        end

        function bool = isPosInf(value)
            % Checks if values are GAMS PINF
            %
            % b = isPosInf(v) checks if the values v are GAMS POSINF values
            %
            % Example:
            % b = SpecialValues.isPosInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
            % b equals [0, 0, 1, 0]
            %

            bool = isinf(value) & value > 0;
        end

        function bool = isNegInf(value)
            % Checks if values are GAMS MINF
            %
            % b = isNegInf(v) checks if the values v are GAMS MINF values
            %
            % Example:
            % b = SpecialValues.isNegInf([0, 1, SpecialValues.POSINF, SpecialValues.NEGINF])
            % b equals [0, 0, 0, 1]
            %

            bool = isinf(value) & value < 0;
        end

    end

end
