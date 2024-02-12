% Symbol Domain Violation
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
% Symbol Domain Violation
%
% Domain violations occur when a symbol uses other Set(s) as domain(s) and a
% domain entry in its records that is not present in the corresponding set.
% Such a domain violation will lead to a GDX error when writing the data.
%
% See also: gams.transfer.symbol.Set, gams.transfer.Symbol
%

%> @brief Domain Violation
%>
%> Domain violations occur when a symbol uses other \ref gams::transfer::symbol::Set
%> "Sets" as \ref gams::transfer::symbol::Symbol::domain "domain"(s) -- and is thus of
%> domain type `regular`, see \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses
%> a domain entry in its \ref gams::transfer::symbol::Symbol::records "records" that is
%> not present in the corresponding referenced domain set. Such a domain
%> violation will lead to a GDX error when writing the data! See \ref
%> GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
%>
%> @see \ref gams::transfer::symbol::Set "Set", \ref gams::transfer::symbol::Symbol "Symbol"
classdef Violation

    properties (Hidden, SetAccess = protected)

        symbol_
        dimension_
        domain_
        violations_

    end

    properties (Dependent, SetAccess = private)

        %> Symbol handle this domain violation belongs to

        % symbol Symbol handle this domain violation belongs to
        symbol


        %> Dimension in which domain violation occurs

        % dimension Dimension in which domain violation occurs
        dimension


        %> Domain elements that are not present in domain set

        % violations Domain elements that are not present in domain set
        violations

    end

    methods

        function symbol = get.symbol(obj)
            symbol = obj.symbol_;
        end

        function dimension = get.dimension(obj)
            dimension = obj.dimension_;
        end

        function violations = get.violations(obj)
            violations = obj.violations_;
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.domain.Violation, ?gams.transfer.symbol.Abstract})

        function obj = Violation(symbol, dimension, domain, violations)
            obj.symbol_ = symbol;
            obj.dimension_ = dimension;
            obj.domain_ = domain;
            obj.violations_ = violations;
        end

    end

    methods

        %> Resolve the domain violation by adding the missing elements into
        %> the domain set.
        function resolve(obj)
            % Resolve the domain violation by adding the missing elements into
            % the domain set.

            assert(isa(obj.domain_, 'gams.transfer.symbol.domain.Regular'));
            obj.domain_.resolveViolations(obj.violations_);
        end

    end

end
