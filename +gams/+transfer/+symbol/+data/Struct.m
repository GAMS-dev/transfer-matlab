% Struct Records (internal)
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
% Struct Records (internal)
%
classdef Struct < gams.transfer.symbol.data.Tabular

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            try
                labels = fieldnames(obj.records_);
            catch
                labels = {};
            end
        end

    end

    methods

        function obj = Struct(records)
            if nargin >= 1
                obj.records = records;
            end
        end

        function name = name(obj)
            name = 'struct';
        end

        function def = copy(obj)
            def = gams.transfer.symbol.data.Struct();
            def.copyFrom(obj);
        end

        function status = isValid(obj, def)
            if ~isstruct(obj.records_)
                status = gams.transfer.utils.Status("Record data must be 'struct'.");
                return
            end

            status = isValid@gams.transfer.symbol.data.Tabular(obj, def);
        end

        function nrecs = getNumberRecords(obj, def)
            if obj.isValid(def).flag ~= gams.transfer.utils.Status.OK
                nrecs = nan;
                return
            end

            domains = def.domains;
            values = def.values;
            if numel(values) > 0
                nrecs = numel(obj.records_.(values{1}.label));
            elseif numel(domains) > 0
                nrecs = numel(obj.records_.(domains{1}.label));
            else
                nrecs = 0;
            end
        end

    end

end
