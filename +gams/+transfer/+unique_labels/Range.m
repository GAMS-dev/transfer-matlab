% Range based Unique Labels (internal)
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
% Range based Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Range < gams.transfer.unique_labels.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)

        prefix_ = ''
        first_ = 1
        step_ = 1
        length_ = 0
        modified_ = true

    end

    properties (Dependent)
        prefix
        first
        step
        length
        modified
    end

    methods

        function prefix = get.prefix(obj)
            prefix = obj.prefix_;
        end

        function set.prefix(obj, prefix)
            obj.prefix_ = gams.transfer.utils.Validator('prefix', 1, prefix).string2char().type('char').value;
        end

        function first = get.first(obj)
            first = obj.first_;
        end

        function set.first(obj, first)
            gams.transfer.utils.Validator('first', 1, first).integer().scalar().min(0).noNanInf();
            obj.first_ = first;
        end

        function step = get.step(obj)
            step = obj.step_;
        end

        function set.step(obj, step)
            gams.transfer.utils.Validator('step', 1, step).integer().scalar().min(1).noNanInf();
            obj.step_ = step;
        end

        function length = get.length(obj)
            length = obj.length_;
        end

        function set.length(obj, length)
            gams.transfer.utils.Validator('length', 1, length).integer().scalar().min(0).noNanInf();
            obj.length_ = length;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
        end

        function set.modified(obj, modified)
            gams.transfer.utils.Validator('modified', 1, modified).type('logical').scalar();
            obj.modified_ = modified;
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ?gams.transfer.symbol.Abstract})

        function obj = Range(prefix, first, step, length)
            obj.prefix_ = prefix;
            obj.first_ = first;
            obj.step_ = step;
            obj.length_ = length;
        end

    end

    methods (Static)

        function obj = construct(prefix, first, step, length)
            prefix = gams.transfer.utils.Validator('prefix', 1, prefix).string2char().type('char').value;
            gams.transfer.utils.Validator('first', 2, first).integer().scalar().min(0).noNanInf();
            gams.transfer.utils.Validator('step', 3, step).integer().scalar().min(1).noNanInf();
            gams.transfer.utils.Validator('length', 4, length).integer().scalar().min(0).noNanInf();
            obj = gams.transfer.unique_labels.Range(prefix, first, step, length);
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.Range(obj.prefix_, obj.first_, obj.step_, obj.length_);
        end

        function count = count(obj)
            count = obj.length_;
        end

        function labels = get(obj)
            labels = cell(1, obj.length_);
            for i = 1:obj.length_
                labels{i} = [obj.prefix_, int2str(obj.first_ + obj.step_ * (i - 1))];
            end
        end

        function clear(obj)
            obj.prefix_ = '';
            obj.first_ = 1;
            obj.step_ = 1;
            obj.length_ = 0;
            obj.modified_ = true;
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.symbol.data.Abstract, ...
        ?gams.transfer.symbol.domain.Abstract})

        function labels = getAt_(obj, indices)
            labels = cell(1, numel(indices));
            for i = 1:numel(indices)
                labels{i} = [obj.prefix_, int2str(obj.first_ + obj.step_ * (indices(i) - 1))];
            end
        end

    end

end
