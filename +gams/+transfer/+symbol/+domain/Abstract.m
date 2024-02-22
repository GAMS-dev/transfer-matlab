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
classdef (Abstract, Hidden) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        label_
        index_type_ = gams.transfer.symbol.domain.IndexType();
        forwarding_ = false
        last_update_ = now();
    end

    properties (Dependent)
        label
        index_type
        forwarding
    end

    properties (Hidden, Abstract, SetAccess = private)
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

        function index_type = get.index_type(obj)
            index_type = obj.index_type_;
        end

        function set.index_type(obj, index_type)
            gams.transfer.utils.Validator('index_type', 1, index_type).type('gams.transfer.symbol.domain.IndexType');
            obj.index_type_ = index_type;
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

        function domain = copy(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function copyFrom(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type(class(obj));
            obj.label_ = domain.label;
            obj.forwarding_ = domain.forwarding;
            obj.last_update_ = now();
        end

        function eq = equals(obj, domain)
            eq = isequal(class(obj), class(domain)) && ...
                isequal(obj.label_, domain.label) && ...
                isequal(obj.forwarding_, domain.forwarding);
        end

        function status = isValid(obj)
            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
        end

        function appendLabelIndex(obj, index)
            add = ['_', int2str(index)];
            if numel(obj.label_) <= numel(add) || ~strcmp(obj.label_(end-numel(add)+1:end), add)
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

        function addLabels(obj, labels, forwarding)
            error('Domain ''%s'' does not define any unique labels and thus cannot add any.', obj.name);
        end

    end

end
