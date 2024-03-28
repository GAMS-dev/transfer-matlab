% Parameter Definition (internal)
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
% Parameter Definition (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Parameter < gams.transfer.symbol.definition.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = {?gams.transfer.symbol.definition.Abstract, ...
        ?gams.transfer.symbol.Abstract, ?gams.transfer.Container, ?gams.transfer.symbol.data.Abstract})

        values_
    end

    properties (Dependent, SetAccess = private)
        values
    end

    methods

        function values = get.values(obj)
            values = obj.values_;
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract})

        function obj = Parameter()
            persistent values_
            if isempty(values_)
                values_ = {gams.transfer.symbol.value.Numeric('value', 0)};
            end
            obj.values_ = values_;
        end

    end

    methods (Static)

        function obj = construct()
            obj = gams.transfer.symbol.definition.Parameter();
        end

    end

end
