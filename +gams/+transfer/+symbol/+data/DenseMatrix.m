% Dense Matrix Data (internal)
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
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
% Dense Matrix Data (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) DenseMatrix < gams.transfer.symbol.data.Matrix

    %#ok<*INUSD,*STOUT>
    properties (Constant)
        name = 'dense_matrix'
    end

    methods

        function obj = DenseMatrix(records)
            obj.records_ = struct();
            if nargin >= 1
                obj.records = records;
            end
        end

        function data = copy(obj)
            data = gams.transfer.symbol.data.DenseMatrix();
            data.copyFrom(obj);
        end

        function status = isValid(obj, axes, values)
            values = obj.availableValues('Numeric', values);
            for i = 1:numel(values)
                label = values{i}.label;
                if issparse(obj.records_.(label))
                    status = gams.transfer.utils.Status(sprintf("Records '%s' must not be sparse.", label));
                    return
                end
            end
            status = isValid@gams.transfer.symbol.data.Matrix(obj, axes, values);
        end

        function nvals = getNumberValues(obj, axes, values)
            values = obj.availableValues('Numeric', values);
            nvals = 0;
            for i = 1:numel(values)
                nvals = nvals + numel(obj.records_.(values{i}.label));
            end
        end

        function transformToMatrix(obj, axes, values, data)
            values = obj.availableValues('Numeric', values);
            if isa(data, 'gams.transfer.symbol.data.DenseMatrix')
                for i = 1:numel(values)
                    data.records.(values{i}.label) = obj.records_.(values{i}.label);
                end
            elseif isa(data, 'gams.transfer.symbol.data.SparseMatrix')
                for i = 1:numel(values)
                    data.records.(values{i}.label) = sparse(obj.records_.(values{i}.label));
                end
            else
                error('Invalid data: %s', class(data));
            end
        end

    end

end
