% Symbol Relaxed Domain (internal)
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
% Symbol Relaxed Domain (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Relaxed < gams.transfer.symbol.domain.Abstract

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        name_
    end

    properties (Dependent)
        name
    end

    methods

        function name = get.name(obj)
            name = obj.name_;
        end

        function obj = set.name(obj, name)
            valid = gams.transfer.utils.Validator('name', 1, name).string2char().type('char').nonempty();
            if ~strcmp(name, gams.transfer.Constants.UNIVERSE_NAME)
                valid.varname();
            end
            obj.name_ = valid.value;
            obj.time_ = obj.time_.reset();
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.domain.Abstract, ?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.Abstract})

        function obj = Relaxed(name)
            obj.name_ = name;
            if strcmp(obj.name_, gams.transfer.Constants.UNIVERSE_NAME)
                obj.label_ = gams.transfer.Constants.UNIVERSE_LABEL;
            else
                obj.label_ = obj.name_;
            end
        end

    end

    methods (Static)

        function obj = construct(name)
            valid = gams.transfer.utils.Validator('name', 1, name).string2char().type('char').nonempty();
            if ~strcmp(name, gams.transfer.Constants.UNIVERSE_NAME)
                valid.varname();
            end
            obj = gams.transfer.symbol.domain.Relaxed(valid.value);
        end

    end

    methods

        function domain = copy(obj)
            domain = gams.transfer.symbol.domain.Relaxed(obj.name_);
            domain.copyFrom_(obj);
        end

        function eq = equals(obj, domain)
            eq = equals@gams.transfer.symbol.domain.Abstract(obj, domain) && ...
                isequal(obj.name_, domain.name);
        end

        function status = isValid(obj) %#ok<MANU>
            status = gams.transfer.utils.Status.ok();
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.domain.Abstract, ...
        ?gams.transfer.symbol.definition.Abstract, ?gams.transfer.symbol.domain.Violation})

        function copyFrom_(obj, domain)
            copyFrom_@gams.transfer.symbol.domain.Abstract(obj, domain);
            obj.name_ = domain.name;
        end

    end

end
