% Domain Set based Unique Labels (internal)
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
% Domain Set based Unique Labels (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) DomainSet < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = protected)
        symbol_
    end

    properties (Dependent)
        symbol
    end

    properties (Dependent, SetAccess = private)
        last_update
    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function set.symbol(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Set'});
            gams.transfer.utils.Validator('symbol.dimension', 1, symbol.dimension).inInterval(1, 1);
            obj.symbol_ = symbol;
        end

        function last_update = get.last_update(obj)
            last_update = obj.symbol_.last_update;
        end

    end

    methods (Hidden, Access = {?gams.transfer.unique_labels.Abstract, ?gams.transfer.symbol.domain.Regular})

        function obj = DomainSet(symbol)
            obj.symbol_ = symbol;
        end

    end

    methods (Static)

        function obj = construct(symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Set'});
            obj = gams.transfer.unique_labels.DomainSet(symbol);
            obj.checkSymbol();
        end

    end

    methods

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.DomainSet(obj.symbol_);
        end

        function count = count(obj)
            obj.checkSymbol();
            count = obj.symbol_.getNumberRecords();
        end

        function labels = get(obj)
            obj.checkSymbol();
            labels = reshape(obj.symbol_.getUELs(1, 'ignore_unused', true), 1, []);
        end

        function clear(obj)
            obj.checkSymbol();
            switch lower(obj.symbol_.format)
            case 'table'
                obj.symbol_.data = gams.transfer.symbol.data.Table.construct();
            case 'struct'
                obj.symbol_.data = gams.transfer.symbol.data.Struct.construct();
            otherwise
                error('Unknown format');
            end
        end

        function add(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;

            % extend domain uels
            symbol_labels = obj.get();
            n = numel(symbol_labels);
            symbol_labels(n+1:n+numel(labels)) = labels;
            if numel(unique(symbol_labels)) ~= numel(symbol_labels)
                error('Unique labels will not be unqiue');
            end

            % check for other values
            values = obj.symbol_.data.availableValues('Abstract', obj.symbol_.def.values);
            for i = 1:numel(values)
                default = values{i}.default;
                values{i} = obj.symbol_.records.(values{i}.label);
                if isstring(default) || ischar(default)
                    values{i} = strrep(cellstr(values{i}), gams.transfer.Constants.UNDEFINED_UNIQUE_LABEL, '');
                    values{i}(n+1:n+numel(labels)) = {default};
                elseif isnumeric(default)
                    values{i}(n+1:n+numel(labels)) = default;
                else
                    error('Unsupported value default type: %s', class(default));
                end
            end

            format = obj.symbol_.format;
            obj.symbol_.setRecords(symbol_labels, values{:});
            obj.symbol_.transformRecords(format);
        end

        function set(obj, labels)
            obj.clear();
            format = obj.symbol_.format;
            labels = gams.transfer.utils.unique(labels);
            labels = reshape(labels, 1, []);
            obj.symbol_.setRecords(labels);
            obj.symbol_.transformRecords(format);
        end

        function [flag, indices] = remove(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            oldlabels = obj.get();
            [~, idx] = ismember(labels, oldlabels);
            idx(idx == 0) = [];
            obj.symbol_.data.removeRows(idx);
            obj.symbol_.removeUELs(labels(idx));
            if nargout > 0
                [flag, indices] = obj.updatedIndices(oldlabels, [], []);
            end
        end

        function rename(obj, oldlabels, newlabels)
            obj.checkSymbol();
            obj.symbol_.renameUELs(containers.Map(oldlabels, newlabels), 1);
        end

        function [flag, indices] = merge(obj, oldlabels, newlabels)
            obj.checkSymbol();
            if nargout > 0
                oldlabels_ = obj.get();
            end
            obj.symbol_.renameUELs(containers.Map(oldlabels, newlabels), 1, 'allow_merge', true);
            if nargout > 0
                [flag, indices] = obj.updatedIndices(oldlabels_, oldlabels, newlabels);
            end
        end

    end

    methods (Hidden, Access = protected)

        function checkSymbol(obj)
            status = obj.symbol_.isValidDomain();
            if status.flag ~= gams.transfer.utils.Status.OK
                error('Domain set ''%s''cannot be used as domain: %s', obj.symbol_.name, status.message);
            end
        end

    end

end
