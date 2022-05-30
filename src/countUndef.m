% Returns the number of GAMS UNDEF values in records
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
% Returns the number of GAMS UNDEF values in records
%
% n = countUndef(s, varargin) returns the number of GAMS UNDEF values n in
% symbol s records. varargin can include a list of value fields that should be
% considered: level, value, lower, upper, scale. If none is given all available
% for the symbol are considered.
function n = countUndef(symbol, varargin)
    n = 0;

    % get available value fields
    values = GAMSTransfer.Utils.getAvailableValueFields(symbol, varargin{:});
    if isempty(values)
        return
    end

    % get count
    for i = 1:numel(values)
        n = n + sum(GAMSTransfer.SpecialValues.isUndef(full(symbol.records.(values{i})(:))));
    end
end
