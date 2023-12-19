% Relaxed Domain
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
% Relaxed Domain
%

%> @brief Relaxed Domain
classdef RelaxedDomain < gams.transfer.def.Domain

    properties (Hidden, SetAccess = protected)
        name_
        unique_labels_ = []
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

        function arg = validateUniqueLabels(name, index, arg)
            if isnumeric(unique_labels) && isempty(unique_labels)
                arg = [];
                return
            end
            if ~isa(arg, 'gams.transfer.unique_labels.Abstract')
                error('Argument ''%s'' (at position %d) must be empty or ''gams.transfer.unique_labels.Abstract''.', name, index);
            end
        end

    end

    properties (Dependent)
        name
        unique_labels
    end

    properties (Dependent, SetAccess = private)
        size
    end

    methods

        function name = get.name(obj)
            name = obj.name_;
        end

        function obj = set.name(obj, name)
            obj.name_ = obj.validateName('name', 1, name);
        end

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function obj = set.unique_labels(obj, unique_labels)
            obj.unique_labels_ = obj.validateUniqueLabels('unique_labels', 1, unique_labels);
        end

        function size = get.size(obj)
            if isempty(obj.unique_labels_)
                size = nan;
            else
                size = obj.unique_labels_.size();
            end
        end

    end

    methods

        function obj = RelaxedDomain(name)
            obj.name = name;
            obj.label_ = name;
        end

        function flag = hasUniqueLabels(obj)
            flag = ~isempty(obj.unique_labels_);
        end

        function uels = getUniqueLabels(obj)
            if ~obj.hasUniqueLabels()
                error('Relaxed domain ''%s'' does not have unique labels.', obj.name_);
            end
            uels = obj.unique_labels_.get();
        end

    end

end
