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

        function def = copy(obj)
            def = gams.transfer.symbol.data.SparseMatrix();
            def.copyFrom(obj);
        end

        function status = isValid(obj, def)
            status = isValid@gams.transfer.symbol.data.Matrix(obj, def);
        end

        function data = transform(obj, def, format)
            def = obj.validateDefinition('def', 1, def);
            format = lower(gams.transfer.utils.validate('format', 1, format, {'string', 'char'}, -1));

            switch format
            case {'table', 'struct'}
                data = obj.transformToTabular(def, format);
            case 'dense_matrix'
                data = gams.transfer.symbol.data.DenseMatrix(obj.records_);
                values = obj.availableNumericValues(def.values);
                for i = 1:numel(values)
                    data.records.(values{i}.label) = full(data.records.(values{i}.label));
                end
            case 'sparse_matrix'
                data = gams.transfer.symbol.data.SparseMatrix(obj.records_);
            otherwise
                error('Unknown records format: %s', format);
            end
        end

        function nvals = getNumberValues(obj, def, varargin)
            [~, values] = obj.parseDefinitionWithValueFilter(def, varargin{:});
            values = obj.availableNumericValues(values);
            nvals = 0;
            for i = 1:numel(values)
                nvals = nvals + nnz(obj.records_.(values{i}.label));
            end
        end

    end

    methods (Static)

        function obj = Empty(domains)
            obj = gams.transfer.symbol.data.SparseMatrix(struct());
        end

    end

end
