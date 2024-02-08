% Abstract Symbol Domain (internal)
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
% Abstract Symbol Domain (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Abstract, Hidden) Abstract < handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        label_
        forwarding_ = false
        last_update_ = now();
    end

    properties (Dependent)
        label
        forwarding
    end

    properties (Abstract, SetAccess = private)
        last_update
    end

    properties (Abstract)
        name
    end

    methods

        function label = get.label(obj)
            label = obj.label_;
        end

        function set.label(obj, label)
            obj.label_ = gams.transfer.utils.Validator('label', 1, label).string2char().type('char').nonempty().varname().value;
            obj.last_update_ = now();
        end

        function forwarding = get.forwarding(obj)
            forwarding = obj.forwarding_;
        end

        function set.forwarding(obj, forwarding)
            obj.forwarding_ = gams.transfer.utils.Validator('forwarding', 1, forwarding).type('logical').scalar().value;
            obj.last_update_ = now();
        end

    end

    methods

        function eq = equals(obj, domain)
            eq = isequal(class(obj), class(domain)) && ...
                isequal(obj.label_, domain.label) && ...
                isequal(obj.forwarding_, domain.forwarding);
        end

        function status = isValid(obj)
            error('Abstract method. Call method of subclass ''%s''.', class(obj));
        end

        function appendLabelIndex(obj, index)
            add = ['_', int2str(index)];
            if ~endsWith(obj.label_, add)
                obj.label_ = strcat(obj.label_, add);
            end
            obj.last_update_ = now();
        end

        function flag = hasUniqueLabels(obj) %#ok<MANU>
            flag = false;
        end

        function unique_labels = getUniqueLabels(obj) %#ok<MANU>
            unique_labels = [];
        end

    end

end
