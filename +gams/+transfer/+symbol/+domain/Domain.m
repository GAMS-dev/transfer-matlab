% Symbol Domain (internal)
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
% Symbol Domain (internal)
%
classdef (Abstract) Domain

    properties (Hidden, SetAccess = protected)
        label_
        index_type_ = gams.transfer.symbol.domain.IndexType()
        forwarding_ = false
    end

    methods (Hidden, Static)

        function arg = validateLabel(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            if ~isvarname(arg)
                error('Argument ''%s'' (at position %d) must start with letter and must only consist of letters, digits and underscores.', name, index)
            end
        end

        function arg = validateIndexType(name, index, arg)
            if isa(arg, 'gams.transfer.symbol.domain.IndexType')
                return
            end
            try
                arg = gams.transfer.symbol.domain.IndexType(arg);
            catch e
                error('Argument ''%s'' (at position %d) cannot create ''gams.transfer.symbol.domain.IndexType'': %s.', name, index, e.message);
            end
        end

        function arg = validateForwarding(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

    end

    properties (Dependent)
        label
    end

    properties (Dependent)
        index_type
        forwarding
    end

    properties (Abstract)
        name
    end

    properties (Abstract, SetAccess = private)
        base
        size
    end

    methods

        function label = get.label(obj)
            label = obj.label_;
        end

        function obj = set.label(obj, label)
            obj.label_ = obj.validateLabel('label', 1, label);
        end

        function index_type = get.index_type(obj)
            index_type = obj.index_type_;
        end

        function obj = set.index_type(obj, index_type)
            obj.index_type_ = obj.validateIndexType('index_type', 1, index_type);
        end

        function forwarding = get.forwarding(obj)
            forwarding = obj.forwarding_;
        end

        function obj = set.forwarding(obj, forwarding)
            obj.forwarding_ = obj.validateForwarding('forwarding', 1, forwarding);
        end

    end

    methods (Abstract)
        status = isValid(obj)
        flag = hasUniqueLabels(obj)
        uels = getUniqueLabels(obj)
    end

    methods

        function eq = equals(obj, domain)
            eq = isequal(class(obj), class(domain)) && ...
                isequal(obj.label_, domain.label) && ...
                isequal(obj.index_type_, domain.index_type) && ...
                isequal(obj.forwarding_, domain.forwarding);
        end

        function index = createIndex(obj, index_type, labels, uels_from_labels)
            index_type = obj.validateIndexType('index_type', 1, index_type);
            % TODO: check labels
            % TODO: check uels_from_labels

            if uels_from_labels
                uels = gams.transfer.utils.unique(labels);
            else
                uels = obj.getUniqueLabels();
            end

            switch index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                index = categorical(labels, uels, 'Ordinal', true);
            case gams.transfer.symbol.domain.IndexType.INTEGER
                % TODO: use find of unique labels class
                map = containers.Map(uels, 1:numel(uels));
                index = zeros(numel(labels), 1);
                for i = 1:numel(labels)
                    index(i) = map(labels{i});
                end
            otherwise
                error('Unknown domain index type');
            end
        end

        function index = createIndexFromIntegers(obj, index_type, index)
            index_type = obj.validateIndexType('index_type', 1, index_type);
            % TODO: check index

            switch index_type.value
            case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                uels = obj.getUniqueLabels();
                index = categorical(index, 1:numel(uels), uels, 'Ordinal', true);
            case gams.transfer.symbol.domain.IndexType.INTEGER
                n_uels = numel(obj.getUniqueLabels());
                index(index < 1) = 0;
                index(index > n_uels) = 0;
            otherwise
                error('Unknown domain index type');
            end
        end

        function obj = appendLabelIndex(obj, index)
            add = ['_', int2str(index)];
            if ~endsWith(obj.label_, add)
                obj.label_ = strcat(obj.label_, add);
            end
        end

    end

end
