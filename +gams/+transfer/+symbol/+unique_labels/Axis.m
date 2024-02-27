% Symbol Axis (internal)
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
% Symbol Axis (internal)
%
% Attention: Internal classes or functions have limited documentation and its properties, methods
% and method or function signatures can change without notice.
%
classdef (Hidden) Axis

    %#ok<*INUSD,*STOUT>

    properties (Hidden, SetAccess = protected)
        domain_
        unique_labels_
    end

    properties (Dependent)
        domain
        unique_labels
    end

    methods

        function domain = get.domain(obj)
            domain = obj.domain_;
        end

        function obj = set.domain(obj, domain)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            obj.domain_ = domain;
        end

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function obj = set.unique_labels(obj, unique_labels)
            gams.transfer.utils.Validator('unique_labels', 1, unique_labels) ...
                .type('gams.transfer.unique_labels.Abstract');
            obj.unique_labels_ = unique_labels;
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.unique_labels.Axis, ?gams.transfer.symbol.Abstract})

        function obj = Axis(domain, unique_labels)
            obj.domain_ = domain;
            obj.unique_labels_ = unique_labels;
        end

    end

    methods (Static)

        function obj = construct(domain, working_unique_labels, unique_labels)
            gams.transfer.utils.Validator('domain', 1, domain).type('gams.transfer.symbol.domain.Abstract');
            gams.transfer.utils.Validator('unique_labels', 2, unique_labels) ...
                .type('gams.transfer.unique_labels.Abstract');
            obj = gams.transfer.symbol.unique_labels.Axis(domain, unique_labels);
        end

    end

    methods

        function size = size(obj)
            size = obj.unique_labels_.count();
        end

    end

end
