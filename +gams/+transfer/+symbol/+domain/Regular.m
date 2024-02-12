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

    properties (Dependent, SetAccess = private)
        last_update
    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function obj = set.symbol(obj, symbol)
            gams.transfer.utils.Validator('symbol', 1, symbol).types({'gams.transfer.symbol.Set', 'gams.transfer.alias.Abstract'});
            obj.symbol_ = symbol;
            obj.last_update_ = now();
        end

        function name = get.name(obj)
            name = obj.symbol_.name;
        end

        function last_update = get.last_update(obj)
            last_update = max(obj.last_update_, obj.symbol_.last_update);
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

            if obj.symbol_.dimension ~= 1
                status = gams.transfer.utils.Status(sprintf("Set '%s' cannot be used as domain since dimension is not 1.", obj.symbol_.name));
                return
            end

            % TODO: may cycle
            % if ~obj.symbol_.isValid()
            %     status = gams.transfer.utils.Status(sprintf("Domain set '%s' is invalid.", obj.symbol_.name));
            %     return
            % end

            status = gams.transfer.utils.Status.createOK();
        end

        function flag = hasUniqueLabels(obj) %#ok<MANU>
            flag = true;
        end

        function unique_labels = getUniqueLabels(obj)
            unique_labels = gams.transfer.unique_labels.DomainSet(obj.symbol_);
        end

        function resolveViolations(obj, labels)
            labels = gams.transfer.utils.Validator('labels', 1, labels).string2char().cellstr().value;
            % in case the domain set is has itself a domain different to the universe,
            % the domain violation is likely to exist there as well. We therefore
            % apply the same resolving the parent domain.
            if obj.symbol_.dimension > 0
                domain = obj.symbol_.def.domains{1};
                if domain.hasUniqueLabels()
                    domain.resolveViolations(labels);
                end
            end
            obj.getUniqueLabels().add(labels);
        end

        function domain = getRelaxed(obj)
            domain = gams.transfer.symbol.domain.Relaxed(obj.symbol_.name);
            domain.label = obj.label_;
            domain.forwarding = obj.forwarding_;
        end

    end

end
