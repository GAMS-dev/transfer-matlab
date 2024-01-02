% Set Symbol
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
% Set Symbol
%

%> @brief Set Symbol
classdef Set < gams.transfer.symbol.Abstract

    properties (Hidden, SetAccess = protected)
        is_singleton_ = false
    end

    methods (Hidden, Static)

        function arg = validateIsSingleton(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

    end

    properties (Dependent)
        is_singleton
    end

    methods

        function is_singleton = get.is_singleton(obj)
            is_singleton = obj.is_singleton_;
        end

        function obj = set.is_singleton(obj, is_singleton)
            obj.is_singleton_ = obj.validateIsSingleton('is_singleton', 1, is_singleton);
        end

    end

    methods

        function obj = Set(varargin)

            obj.def_ = gams.transfer.def.Definition();
            obj.data_ = gams.transfer.data.Unknown();

            % parse input arguments
            try
                obj.container_ = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'container', @obj.validateContainer);
                obj.name_ = gams.transfer.utils.parse_argument(varargin, ...
                    2, 'name', @obj.validateName);
                index = 3;
                is_pararg = false;
                while index <= nargin
                    if strcmpi(varargin{index}, 'description')
                        obj.description_ = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'description', @obj.validateDescription);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'domain_forwarding')
                        obj.domain_forwarding = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'domain_forwarding', @gams.transfer.def.Domain.validateForwarding);
                        index = index + 2;
                        is_pararg = true;
                    elseif strcmpi(varargin{index}, 'is_singleton')
                        obj.is_singleton = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'is_singleton', @obj.validateIsSingleton);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 3
                        obj.def_.domains_ = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'domains', @gams.transfer.def.Definition.validateDomains);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % create default value definition
            obj.def_.values_ = struct(...
                'element_text', gams.transfer.def.StringValue('element_text', ''));
        end

    end

    methods (Static)

        function descr = describe(symbols)

            symbols = gams.transfer.utils.validate_cell('symbols', 1, symbols, ...
                {'gams.transfer.symbol.Set'}, 1);

            descr = struct();
            descr.name = cell(numel(symbols), 1);
            descr.is_singleton = true(numel(symbols), 1);
            descr.format = cell(numel(symbols), 1);
            descr.dimension = zeros(numel(symbols), 1);
            descr.domain_type = cell(numel(symbols), 1);
            descr.domain = cell(numel(symbols), 1);
            descr.size = cell(numel(symbols), 1);
            descr.number_records = zeros(numel(symbols), 1);
            descr.number_values = zeros(numel(symbols), 1);
            descr.sparsity = zeros(numel(symbols), 1);

            for i = 1:numel(symbols)
                descr.name{i} = symbols{i}.name;
                descr.is_singleton(i) = symbols{i}.is_singleton;
                descr.format{i} = symbols{i}.format;
                descr.dimension(i) = symbols{i}.dimension;
                % descr.domain_type{i} = symbols{i}.domain_type;
                % descr.domain{i} = gams.transfer.Utils.list2str(symbols{i}.domain);
                % descr.size{i} = gams.transfer.Utils.list2str(symbols{i}.size);
                descr.number_records(i) = symbols{i}.getNumberRecords();
                % descr.number_values(i) = symbols{i}.getNumberValues();
                % descr.sparsity(i) = symbols{i}.getSparsity();
            end

            % convert to categorical if possible
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                descr.name = categorical(descr.name);
                descr.format = categorical(descr.format);
                % descr.domain_type = categorical(descr.domain_type);
                % descr.domain = categorical(descr.domain);
                % descr.size = categorical(descr.size);
            end

            % convert to table if possible
            if gams.transfer.Constants.SUPPORTS_TABLE
                descr = struct2table(descr);
            end
        end

    end

end
