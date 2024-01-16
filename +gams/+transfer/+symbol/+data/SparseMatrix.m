% Sparse Matrix Records (internal)
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
% Sparse Matrix Records (internal)
%
classdef SparseMatrix < gams.transfer.symbol.data.Matrix

    methods

        function obj = SparseMatrix(records)
            if nargin >= 1
                obj.records = records;
            end
        end

        function name = name(obj)
            name = 'sparse_matrix';
        end

        function status = isValid(obj, def)
            status = isValid@gams.transfer.symbol.data.Matrix(obj, def);
        end

        function nvals = getNumberValues(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            nvals = 0;
            for i = 1:numel(values)
                nvals = nvals + nnz(obj.records_.(values{i}.label));
            end
        end

    end

end
