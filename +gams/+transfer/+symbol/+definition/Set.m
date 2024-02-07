% Set Definition (internal)
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
% Set Definition (internal)
%
classdef (Hidden) Set < gams.transfer.symbol.definition.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = {?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract, ?gams.transfer.Container})
        is_singleton_ = false
    end

    properties (Dependent)
        is_singleton
    end

    methods

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.is_singleton_;
        end

        function obj = set.is_singleton(obj, is_singleton)
            gams.transfer.utils.Validator('is_singleton', 1, is_singleton).type('logical').scalar();
            obj.is_singleton_ = is_singleton;
            obj.resetValues();
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract})

        function obj = Set(is_singleton)
            obj.is_singleton_ = is_singleton;
        end

    end

    methods (Static)

        function obj = construct(is_singleton)
            gams.transfer.utils.Validator('is_singleton', 1, is_singleton).type('logical').scalar();
            obj = gams.transfer.symbol.definition.Set(is_singleton);
        end

    end

    methods

        function def = copy(obj)
            def = gams.transfer.symbol.definition.Set(obj.is_singleton_);
            def.copyFrom(obj);
        end

        function eq = equals(obj, def)
            eq = equals@gams.transfer.symbol.definition.Abstract(obj, def) && ...
                isequal(obj.is_singleton_, def.is_singleton);
        end

    end

    methods (Hidden, Access = protected)

        function resetValues(obj)
            obj.values_ = {gams.transfer.symbol.value.String('element_text', '')};
        end

    end

end
