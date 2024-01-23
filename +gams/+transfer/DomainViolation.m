% Domain Violation
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
% Domain Violation
%
% Domain violations occur when a symbol uses other Set(s) as domain(s) and a
% domain entry in its records that is not present in the corresponding set.
% Such a domain violation will lead to a GDX error when writing the data.
%
% Required Arguments:
% 1. symbol (Symbol):
%    The GAMS symbol in which the domain violation occurs.
% 2. dimension (int):
%    The dimension of the domain in which the domain violation occurs.
% 3. domain (Set):
%    The GAMS Set that is the domain of symbol.
% 4. violations (cellstr):
%    List of domain entries that are used in symbol but are missing in domain.
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
classdef DomainViolation


    properties (SetAccess = private)

        %> Symbol handle this domain violation belongs to

        % symbol Symbol handle this domain violation belongs to
        symbol


        %> Dimension in which domain violation occurs

        % dimension Dimension in which domain violation occurs
        dimension


        %> Domain for which domain violations are listed

        % domain Domain for which domain violations are listed
        domain


        %> Domain elements that are not present in domain set

        % violations Domain elements that are not present in domain set
        violations

    end

    methods (Hidden, Static)

        function arg = validateSymbol(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.Symbol')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.Symbol''.', name, index);
            end
        end

        function arg = validateDimension(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 0 || arg > gams.transfer.Constants.MAX_DIMENSION
                error('Argument ''%s'' (at position %d) must be in [1, %d].', name, index, gams.transfer.Constants.MAX_DIMENSION);
            end
        end

        function arg = validateDomain(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.Set')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.Set''.', name, index);
            end
        end

        function arg = validateViolations(name, index, arg)
            if ~iscellstr(arg)
                error('Argument ''%s'' (at position %d) must be ''cellstr''.', name, index);
            end
        end

    end

    methods

        %> Constructs a domain violation, see class help
        %>
        %> **Required Arguments:**
        %> 1. symbol (`Symbol`):
        %>    The GAMS symbol in which the domain violation occurs.
        %> 2. dimension (`int`):
        %>    The dimension of the domain in which the domain violation occurs.
        %> 3. domain (`Set`):
        %>    The GAMS \ref gams::transfer::symbol::Set "Set" that is the domain of symbol.
        %> 4. violations (`cellstr`):
        %>    List of domain entries that are used in symbol but are missing in domain.
        %>
        %> @see \ref gams::transfer::symbol::Set "Set", \ref gams::transfer::symbol::Symbol "Symbol"
        function obj = DomainViolation(symbol, dimension, domain, violations)
            % Constructs a domain violation, see class help

            obj.symbol = obj.validateSymbol('symbol', 1, symbol);
            obj.dimension = obj.validateDimension('dimension', 1, dimension);
            obj.domain = obj.validateDomain('domain', 1, domain);
            obj.violations = obj.validateViolations('violations', 1, violations);
        end

        %> Resolve the domain violation by adding the missing elements into
        %> the domain set.
        function resolve(obj)
            % Resolve the domain violation by adding the missing elements into
            % the domain set.

            % in case the domain set is has itself a domain different to the universe,
            % the domain violation is likely to exist there as well. We therefore
            % apply the same resolving the parent domain.
            if ~strcmp(obj.domain.domain{1}, gams.transfer.Constants.UNIVERSE_NAME)
                dv = gams.transfer.DomainViolation(obj.domain, 1, obj.domain.domain{1}, obj.violations);
                dv.resolve();
            end

            % get domain data
            domain_uels = obj.domain.getUELs(1, 'ignore_unused', true);

            % extend domain uels
            n = numel(domain_uels);
            domain_uels(n+1:n+numel(obj.violations)) = obj.violations;

            % get domain format
            has_text = true;
            try
                obj.domain.records.element_text;
            catch
                has_text = false;
            end
            was_table = strcmp(obj.domain.format, 'table');

            % get set texts
            if has_text
                expl_text = obj.domain.records.element_text;
            end

            % set records
            domain_uels = reshape(domain_uels, 1, numel(domain_uels));
            obj.domain.setRecords(domain_uels);
            if has_text
                expl_text(end+1:numel(obj.domain.records.(obj.domain.domain_labels{1}))) = '';
                obj.domain.records.element_text = expl_text;
            end
            if was_table
                obj.domain.transformRecords('table');
            end
        end

    end

end
