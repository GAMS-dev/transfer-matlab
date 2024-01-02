% Regular Domain
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright  (c) 2020-2023 GAMS Software GmbH <support@gams.com>
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
% Regular Domain
%

%> @brief RegularDomain
classdef RegularDomain < gams.transfer.def.Domain

    properties (Hidden, SetAccess = protected)
        symbol_
    end

    methods (Hidden, Static)

        function arg = validateSymbol(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.Set')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.Set''.', name, index);
            end
        end

    end

    properties (Dependent)
        symbol
        name
    end

    properties (Dependent, SetAccess = private)
        base
        size
    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function obj = set.symbol(obj, symbol)
            obj.symbol_ = obj.validateSymbol('symbol', 1, symbol);
        end

        function name = get.name(obj)
            name = obj.symbol_.name;
        end

        function base = get.base(obj)
            base = obj.symbol_;
        end

        function size = get.size(obj)
            size = obj.symbol_.getNumberRecords();
        end

    end

    methods

        function obj = RegularDomain(symbol)
            obj.symbol = symbol;
            obj.label_ = symbol.name;
        end

        function flag = hasUniqueLabels(obj)
            flag = true;
        end

        function uels = getUniqueLabels(obj)
            assert(obj.symbol_.dimension == 1);
            % TODO: better if getUELs would have argument 'order_by' = 'records'
            label = obj.symbol_.def.domains{1}.label;
            uels = obj.symbol_.getUELs(1, uint64(obj.symbol_.records.(label)));
        end

    end

end
