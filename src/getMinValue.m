function [value, where] = getMinValue(symbol, indexed, varargin)
    % Returns the smallest value in records
    %
    % [v, w] = getMinValue(s, varargin) returns the smallest value in records v of
    % symbol s and where it is w. varargin can include a list of value fields
    % that should be considered: level, value, lower, upper, scale. If none is
    % given all available for the symbol are considered.
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
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

    value = nan;
    where = {};

    % get available value fields
    values = GAMSTransfer.Utils.getAvailableValueFields(symbol, varargin{:});
    if isempty(values)
        return
    end

    % compute values
    idx = nan;
    for i = 1:numel(values)
        [value_, idx_] = min(symbol.records.(values{i})(:));
        if ~isempty(value_) && (isnan(value) || value > value_)
            value = value_;
            idx = idx_;
        end
    end

    % translate linear index to domain entry
    if ~isnan(idx)
        where = GAMSTransfer.Utils.getInd2Domain(symbol, indexed, idx);
    end
end
