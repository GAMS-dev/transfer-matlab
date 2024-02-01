% Symbol Relaxed Domain (internal)
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright  (c) 2020-2023 GAMS Software GmbH <support@gams.com>
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
% Symbol Relaxed Domain (internal)
%
classdef Relaxed < gams.transfer.symbol.domain.Domain

    properties (Hidden, SetAccess = protected)
        name_
    end

    methods (Hidden, Static)

        function arg = validateName(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            if ~strcmp(arg, '*') && ~isvarname(arg)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', name, index)
            end
        end

    end

    properties (Dependent)
        name
    end

    properties (Dependent, SetAccess = private)
        base
    end

    methods

        function name = get.name(obj)
            name = obj.name_;
        end

        function obj = set.name(obj, name)
            obj.name_ = obj.validateName('name', 1, name);
        end

        function base = get.base(obj)
            base = obj.name_;
        end

    end

    methods

        function obj = Relaxed(name)
            obj.name = name;
            if strcmp(obj.name_, gams.transfer.Constants.UNIVERSE_NAME)
                obj.label_ = gams.transfer.Constants.UNIVERSE_LABEL;
            else
                obj.label_ = name;
            end
        end

        function eq = equals(obj, domain)
            eq = equals@gams.transfer.symbol.domain.Domain(obj, domain) && ...
                isequal(obj.name_, domain.name);
        end

        function status = isValid(obj)
            status = gams.transfer.utils.Status.createOK();
        end

    end

end
