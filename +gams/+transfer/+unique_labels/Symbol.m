% Abstract UELs
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
% Abstract UELs
%

%> @brief Abstract UELs
classdef Symbol < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = protected)
        % TODO add dimension
        symbol_
    end

    methods (Static, Hidden)

        function arg = validateSymbol(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.Set') && ~isa(arg, 'gams.transfer.alias.Set')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.Set'' or ''gams.transfer.alias.Set''.', name, index);
            end
            if arg.dimension ~= 1
                error('Argument ''%s'' (at position %d) must be symbol with dimension 1.', name, index);
            end
        end

    end

    methods (Hidden)

        function validateObjectSymbol(obj)
            if obj.symbol_.dimension ~= 1
                error('Symbol became invalid: must be symbol with dimension 1.');
            end
        end

    end

    properties (Dependent)
        symbol
    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function set.symbol(obj, symbol)
            obj.symbol_ = obj.validateSymbol('symbol', 1, symbol);
        end

    end

    methods

        function obj = Symbol(symbol)
            obj.symbol = symbol;
        end

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.Symbol(obj.symbol_);
        end

        function count = count(obj)
            count = obj.symbol_.getNumberRecords();
        end

        function labels = get(obj)
            obj.validateObjectSymbol();
            label = obj.symbol_.domain_labels{1};
            if isfield(obj.symbol_.records, label)
                labels = obj.symbol_.getUELs(1, uint64(obj.symbol_.records.(label)));
            else
                labels = {};
            end
        end

        function add(obj, labels)
            error('todo');
        end

        function set(obj, labels)
            error('todo');
        end

        function remove(obj, labels)
            error('todo');
        end

        function rename(obj, oldlabels, newlabels)
            error('todo');
        end

    end

end
