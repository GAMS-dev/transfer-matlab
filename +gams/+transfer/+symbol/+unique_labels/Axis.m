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
classdef Axis < handle

    properties (Hidden, SetAccess = protected)
        unique_labels_
        super_unique_labels_
        diverged_ = true
    end

    properties (Dependent, SetAccess = private)
        unique_labels
        super_unique_labels
        diverged
    end

    methods

        function unique_labels = get.unique_labels(obj)
            unique_labels = obj.unique_labels_;
        end

        function super_unique_labels = get.super_unique_labels(obj)
            super_unique_labels = obj.super_unique_labels_;
        end

        function diverged = get.diverged(obj)
            diverged = obj.diverged_;
        end

    end

    methods

        function obj = Axis(data, domain)
            % TODO check data
            % TODO check domain

            count_objects = domain.hasUniqueLabels() + domain.hasSuperUniqueLabels();
            if ~isempty(data)
                count_objects = count_objects + data.hasUniqueLabels(domain);
            end
            switch count_objects
            case 0
                domain.unique_labels = gams.transfer.unique_labels.OrderedLabelSet();
            case 1
                obj.diverged_ = false;
            case 2
            case 3
                warning('Symbol data and domain maintain working unique labels. Removing those from domain.');
                domain.unique_labels = [];
            end

            if ~isempty(data) && data.hasUniqueLabels(domain)
                obj.unique_labels_ = gams.transfer.unique_labels.Data(data, domain);
            elseif domain.hasUniqueLabels()
                obj.unique_labels_ = domain.getUniqueLabels();
            else
                assert(domain.hasSuperUniqueLabels());
                obj.unique_labels_ = domain.getSuperUniqueLabels();
            end

            if domain.hasSuperUniqueLabels()
                obj.super_unique_labels_ = domain.getSuperUniqueLabels();
            elseif domain.hasUniqueLabels()
                obj.super_unique_labels_ = domain.getUniqueLabels();
            else
                assert(~isempty(data) && data.hasUniqueLabels(domain));
                obj.super_unique_labels_ = gams.transfer.unique_labels.Data(data, domain);
            end
        end

        function size = size(obj, use_super_unique_labels)
            if nargin == 1 || ~use_super_unique_labels
                size = obj.unique_labels_.count();
            else
                size = obj.super_unique_labels_.count();
            end
        end

        function label = labelAt(obj, index, use_super_unique_labels)
            % TODO check index
            if nargin == 2 || ~use_super_unique_labels
                label = obj.unique_labels_.getAt(index);
            else
                label = obj.super_unique_labels_.getAt(index);
            end
            label = label{1};
        end

        function labels = labels(obj, use_super_unique_labels)
            if nargin == 1 || ~use_super_unique_labels
                labels = obj.unique_labels_.get();
            else
                labels = obj.super_unique_labels_.get();
            end
        end

        % function index = createIndex(obj, input, use_super_unique_labels)
        %     if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        %         index = obj.createCategoricalIndex(input, use_super_unique_labels);
        %     else
        %         index = obj.createIntegerIndex(input, use_super_unique_labels);
        %     end
        % end

        % function index = createCategoricalIndex(obj, input, use_super_unique_labels)
        %     if use_super_unique_labels
        %         unique_labels = obj.super_unique_labels_.get();
        %     else
        %         unique_labels =
        %     end
        %     index = gams.transfer.symbol.data.Data.createCategoricalIndex(input, obj.unique_labels_.get());
        % end

        % function index = createIntegerIndex(obj, input, use_super_unique_labels)
        %     index = gams.transfer.symbol.data.Data.createIntegerIndex(input, obj.unique_labels_.get());
        % end

    end

end
