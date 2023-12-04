% Table Record
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
% Table Record
%

%> @brief Table Record
classdef Table < gams.transfer.data.Tabular

    properties (Dependent)
        labels
    end

    methods

        function labels = get.labels(obj)
            labels = obj.records.Properties.VariableNames;
        end

    end

    methods

        function obj = Table(varargin)

            % parse input arguments
            p = inputParser();
            addRequired(p, 'domains', ...
                @(x) validateattributes(x, {'cell'}, {'nonempty'}, 'Table', 'domains', 1));
            parse(p, varargin{:});

            obj.domains = p.Results.domains;
            obj.domain_labels = obj.domains{1}.makeLabels();

            records = struct();
            labels = obj.domain_labels;
            for i = 1:numel(labels)
                records.(labels{i}) = categorical([], [], {}, 'Ordinal', true);
            end
            labels = obj.value_labels;
            for i = 1:numel(labels)
                records.(labels{i}) = [];
            end
            obj.records = struct2table(records);
        end

        function name = name(obj)
            name = 'table';
        end

        function [flag, msg] = isValid(obj)
            if ~istable(obj.records)
                flag = false;
                msg = "Record data must be 'table'.";
                return
            end

            [flag, msg] = isValid@gams.transfer.data.Tabular(obj);
        end

    end

end
