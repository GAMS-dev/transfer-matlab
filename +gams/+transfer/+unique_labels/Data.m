% Abstract UELs
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
% Abstract UELs
%

%> @brief Abstract UELs
classdef Data < gams.transfer.unique_labels.Abstract

    properties (Hidden, SetAccess = protected)
        data_
        domain_
    end

    methods (Static, Hidden)

        function arg = validateData(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.data.Tabular')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.data.Tabular''.', name, index);
            end
        end

    end

    methods (Hidden)

        function arg = validateDomain(obj, name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.domain.Abstract')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.domain.Abstract''.', name, index);
            end
            if ~obj.data_.isLabel(arg.label)
                error('Argument ''%s'' (at position %d) must refer to column in data.', name, index);
            end
            if ~iscategorical(obj.data_.records.(arg.label))
                error('Argument ''%s'' (at position %d) must refer to categorical column in data.', name, index);
            end
        end

    end

    properties (Dependent)
        data
        domain
    end

    methods

        function data = get.data(obj)
            data = obj.data_;
        end

        function set.data(obj, data)
            obj.data_ = obj.validateData('data', 1, data);
        end

        function domain = get.domain(obj)
            domain = obj.domain_;
        end

        function set.domain(obj, domain)
            obj.domain_ = obj.validateDomain('domain', 1, domain);
        end

    end

    methods

        function obj = Data(data, domain)
            obj.data = data;
            obj.domain = domain;
        end

        function unique_labels = copy(obj)
            unique_labels = gams.transfer.unique_labels.Data(obj.data_, obj.domain_);
        end

        function labels = get(obj)
            labels = obj.data_.getUniqueLabels(obj.domain_);
        end

        function add(obj, labels)
            obj.data_.addUniqueLabels(obj.domain_, labels);
        end

        function set(obj, labels)
            obj.data_.setUniqueLabels(obj.domain_, labels);
        end

        function remove(obj, labels)
            obj.data_.removeUniqueLabels(obj.domain_, labels);
        end

        function rename(obj, oldlabels, newlabels)
            obj.data_.renameUniqueLabels(obj.domain_, oldlabels, newlabels);
        end

    end

end
