% Variable Symbol
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
% Variable Symbol
%

%> @brief Variable Symbol
classdef Variable < gams.transfer.symbol.Abstract

    properties (Hidden, SetAccess = protected)
        type_ = gams.transfer.symbol.VariableType.Free
    end

    methods (Hidden, Static)

        function arg = validateType(name, index, arg)
            if isa(arg, 'gams.transfer.symbol.VariableType')
                return
            end
            try
                arg = gams.transfer.symbol.VariableType(arg);
            catch e
                error('Argument ''%s'' (at position %d) cannot create ''gams.transfer.symbol.VariableType'': %s.', name, index, e.message);
            end
        end

    end

    properties (Dependent)
        type
    end

    methods

        function type = get.type(obj)
            type = lower(obj.type_.select);
        end

        function obj = set.type(obj, type)
            obj.type_ = obj.validateType('type', 1, type);
        end

    end

    methods

        function obj = Variable(varargin)

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
                    elseif ~is_pararg && index == 3
                        obj.type_ = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'type', @obj.validateType);
                    elseif ~is_pararg && index == 4
                        domain_bases = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'domain', []);
                        obj.def_.domains_ = gams.transfer.def.Domain.createFromBases(domain_bases);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            % create default value definition
            % gdx_default_values = gams.transfer.cmex.gt_get_defaults(obj);
            gdx_default_values = zeros(1, 5);
            obj.def_.values_ = struct(...
                'level', gams.transfer.def.Value('level', gams.transfer.def.ValueType.Numeric, gdx_default_values(1)), ...
                'marginal', gams.transfer.def.Value('marginal', gams.transfer.def.ValueType.Numeric, gdx_default_values(2)), ...
                'lower', gams.transfer.def.Value('lower', gams.transfer.def.ValueType.Numeric, gdx_default_values(3)), ...
                'upper', gams.transfer.def.Value('upper', gams.transfer.def.ValueType.Numeric, gdx_default_values(4)), ...
                'scale', gams.transfer.def.Value('scale', gams.transfer.def.ValueType.Numeric, gdx_default_values(5)));
        end

    end

end
