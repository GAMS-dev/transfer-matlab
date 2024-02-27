% Symbol Regular Domain (internal)
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
% Symbol Regular Domain (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Regular < gams.transfer.symbol.domain.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        symbol_
    end

    properties (Dependent)
        symbol
        name
    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function obj = set.symbol(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Abstract'});
            obj.symbol_ = symbol;
            obj.time_.reset();
        end

        function name = get.name(obj)
            name = obj.symbol_.name;
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.domain.Abstract, ?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract})

        function obj = Regular(symbol)
            obj.symbol_ = symbol;
            obj.label_ = symbol.name;
            if obj.symbol_.dimension ~= 1
                error('Set ''%s'' cannot be used as domain since dimension is not 1.', obj.symbol_.name);
            end
        end

    end

    methods (Static)

        function obj = construct(symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Abstract'});
            obj = gams.transfer.symbol.domain.Regular(symbol);
            status = symbol.isValidDomain();
            if status ~= gams.transfer.utils.Status.OK
                error(status.message);
            end
        end

    end

    methods

        function domain = copy(obj)
            domain = gams.transfer.symbol.domain.Regular(obj.symbol_);
            domain.copyFrom(obj);
        end

        function copyFrom(obj, domain)
            copyFrom@gams.transfer.symbol.domain.Abstract(obj, domain);
            obj.symbol_ = domain.symbol;
        end

        function eq = equals(obj, domain)
            eq = equals@gams.transfer.symbol.domain.Abstract(obj, domain) && ...
                obj.symbol_.equals(domain.symbol);
        end

        function status = isValid(obj)
            status = obj.symbol_.isValidDomain();
        end

        function flag = hasUniqueLabels(obj) %#ok<MANU>
            flag = true;
        end

        function unique_labels = getUniqueLabels(obj)
            unique_labels = gams.transfer.unique_labels.DomainSet(obj.symbol_);
        end

        function addLabels(obj, labels, forwarding)
            if nargin == 2
                forwarding = obj.forwarding_;
            end

            if ~obj.hasUniqueLabels()
                error('Domain ''%s'' does not define any unique labels and thus cannot add any.', obj.name);
            end
            obj.getUniqueLabels().add_(labels);

            % in case the domain set is has itself a domain different to the universe,
            % the domain violation is likely to exist there as well. We therefore
            % apply the same resolving the parent domain.
            if ~forwarding
                return
            end
            for i = 1:obj.symbol_.dimension
                domain = obj.symbol_.getDomain_(i);
                if domain.hasUniqueLabels()
                    domain.addLabels(labels, true);
                end
            end
        end

        function domain = getRelaxed(obj)
            domain = gams.transfer.symbol.domain.Relaxed(obj.symbol_.name);
            domain.label = obj.label_;
            domain.forwarding = obj.forwarding_;
        end

        function [flag, time] = updatedAfter_(obj, time)
            flag = true;
            if time <= obj.time_
                time = obj.time_;
                return
            end
            [flag_, time_] = obj.symbol_.updatedAfter_(time);
            if flag_
                obj.time_.set(time_);
                time = time_;
                return
            end
            flag = false;
        end

    end

end
