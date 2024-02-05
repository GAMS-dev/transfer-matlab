% Equation Definition (internal)
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
% Equation Definition (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Equation < gams.transfer.symbol.definition.Abstract

    properties (Hidden, SetAccess = protected)
        type_ = gams.transfer.EquationType.NonBinding;
    end

    properties (Dependent)
        type
    end

    methods (Hidden, Static)

        function type = createType(name, input)
            if isa(input, 'gams.transfer.EquationType')
                type = input;
                return
            end
            try
                type = gams.transfer.EquationType(input);
            catch e
                error('Cannot create ''gams.transfer.EquationType'' from ''%s'' (at position %d): %s', name, index, e.message);
            end
        end

    end

    methods

        function type = get.type(obj)
            type = obj.type_;
        end

        function obj = set.type(obj, type)
            obj.type_ = obj.createType('type', 1, type);
            obj.resetValues();
        end

    end

    methods

        function obj = Equation()
            obj.resetValues();
        end

        function def = copy(obj)
            def = gams.transfer.symbol.definition.Equation();
            def.copyFrom(obj);
        end

        function copyFrom(obj, symbol)
            copyFrom@gams.transfer.symbol.definition.Abstract(obj, symbol);
            obj.type_ = symbol.type;
        end

        function eq = equals(obj, def)
            eq = equals@gams.transfer.symbol.definition.Abstract(obj, def) && ...
                isequal(obj.type_, def.type);
        end

    end

    methods (Hidden, Access = protected)

        function resetValues(obj)
            gdx_default_values = gams.transfer.gdx.gt_get_defaults(...
                int32(gams.transfer.gdx.SymbolType.EQUATION), int32(obj.type_.value));
            obj.values_ = {...
                gams.transfer.symbol.value.Numeric('level', gdx_default_values(1)), ...
                gams.transfer.symbol.value.Numeric('marginal', gdx_default_values(2)), ...
                gams.transfer.symbol.value.Numeric('lower', gdx_default_values(3)), ...
                gams.transfer.symbol.value.Numeric('upper', gdx_default_values(4)), ...
                gams.transfer.symbol.value.Numeric('scale', gdx_default_values(5))};
        end

    end

end
