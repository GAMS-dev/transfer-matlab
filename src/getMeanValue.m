% Returns the mean value over all values in records
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
% Returns the mean value over all values in records
%
% v = getMinValue(s, varargin) returns the mean value over all values in records
% v of symbol s. varargin can include a list of value fields that should be
% considered: level, value, lower, upper, scale. If none is given all available
% for the symbol are considered.
function value = getMeanValue(symbol, varargin)
    value = nan;

    % get available value fields
    values = GAMSTransfer.Utils.getAvailableValueFields(symbol, varargin{:});
    if isempty(values)
        return
    end

    if isa(symbol, 'GAMSTransfer.Symbol')
        nrecs = symbol.getNumberRecords();
    elseif isfield(symbol, 'number_records')
        nrecs = symbol.number_records;
    else
        nrecs = nan;
    end

    % compute values
    n = 0;
    for i = 1:numel(values)
        value_ = sum(symbol.records.(values{i})(:));
        if isnan(value)
            value = value_;
        else
            value = value + value_;
        end

        n = n + nrecs;
    end
    if n == 0
        value = nan;
        return
    end
    switch GAMSTransfer.RecordsFormat.str2int(symbol.format)
    case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
        value = value / prod(symbol.size);
    otherwise
        value = value / n;
    end
end
