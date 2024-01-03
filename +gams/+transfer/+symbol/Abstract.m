% Abstract Symbol
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
% Abstract Symbol
%

%> @brief Abstract Symbol
classdef (Abstract) Abstract < handle

    properties (Hidden, SetAccess = protected)
        container_
        name_ = ''
        description_ = ''
        def_
        data_
        modified_ = true
    end

    methods (Hidden, Static)

        function arg = validateContainer(name, index, arg)
            if ~isa(arg, 'gams.transfer.Container')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.Container''.', name, index);
            end
        end

        function arg = validateName(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) <= 0
                error('Argument ''%s'' (at position %d) length must be greater than 0.', name, index);
            end
            if numel(arg) >= gams.transfer.Constants.MAX_NAME_LENGTH
                error('Argument ''%s'' (at position %d) length must be smaller than %d.', name, index, gams.transfer.Constants.MAX_NAME_LENGTH);
            end
        end

        function arg = validateDescription(name, index, arg)
            if isstring(arg)
                arg = char(arg);
            elseif ~ischar(arg)
                error('Argument ''%s'' (at position %d) must be ''string'' or ''char''.', name, index);
            end
            if numel(arg) >= gams.transfer.Constants.MAX_DESCRIPTION_LENGTH
                error('Argument ''%s'' (at position %d) length must be smaller than %d.', name, index, gams.transfer.Constants.MAX_DESCRIPTION_LENGTH);
            end
        end

        function arg = validateDef(name, index, arg, keys)
            if ~isa(arg, 'gams.transfer.def.Definition')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.def.Definition''.', name, index);
            end
        end

        function arg = validateData(name, index, arg)
            if ~isa(arg, 'gams.transfer.data.Abstract')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.data.Abstract''.', name, index);
            end
        end

        function arg = validateModified(name, index, arg)
            if ~islogical(arg)
                error('Argument ''%s'' (at position %d) must be ''logical''.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
        end

    end

    properties (Dependent, SetAccess = protected)
        container
    end

    properties (Dependent)
        name
        description
    end

    properties (Dependent, Hidden)
        def
        data
    end

    properties (Dependent)
        dimension
        size
        domain
        domain_labels
    end

    properties (Dependent, SetAccess = private)
        domain_names
        domain_type
    end

    properties (Dependent)
        domain_forwarding
        records
    end

    properties (Dependent, SetAccess = private)
        format
    end

    properties (Dependent)
        modified
    end

    methods

        function container = get.container(obj)
            container = obj.container_;
        end

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            obj.name_ = obj.validateName('name', 1, name);
            % obj.container.renameSymbol(obj.name, name);
            obj.modified_ = true;
        end

        function description = get.description(obj)
            description = obj.description_;
        end

        function set.description(obj, description)
            obj.description_ = obj.validateDescription('description', 1, description);
            obj.modified_ = true;
        end

        function def = get.def(obj)
            def = obj.def_;
        end

        function obj = set.def(obj, def)
            obj.def_ = obj.validateDef('def', 1, def, obj.VALUE_KEYS);
            obj.modified_ = true;
        end

        function data = get.data(obj)
            data = obj.data_;
        end

        function obj = set.data(obj, data)
            obj.data_ = obj.validateData('data', 1, data);
            obj.modified_ = true;
        end

        function dimension = get.dimension(obj)
            dimension = obj.def_.dimension();
        end

        function size = get.size(obj)
            size = obj.def_.size();
        end

        function domain = get.domain(obj)
            domain = obj.def_.domainBases();
        end

        function obj = set.domain(obj, domain)
            obj.def_.setDomainBases(domain);
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.def_.domainLabels();
        end

        function obj = set.domain_labels(obj, domain_labels)
            obj.def_.setDomainLabels(domain_labels);
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.def_.domainNames();
        end

        function domain_type = get.domain_type(obj)
            domain_type = lower(obj.def_.domainType().select);
        end

        function domain_forwarding = get.domain_forwarding(obj)
            dim = obj.dimension;
            domain_forwarding = false;
            for i = 1:dim
                domain_forwarding = domain_forwarding || obj.def_.domains{i}.forwarding;
            end
        end

        function obj = set.domain_forwarding(obj, domain_forwarding)
            for i = 1:obj.dimension
                obj.def_.domains{i}.forwarding = domain_forwarding;
            end
        end

        function records = get.records(obj)
            records = obj.data_.records;
        end

        function obj = set.records(obj, records)
            obj.data_.records = records;
        end

        function format = get.format(obj)
            format = obj.data_.name();
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
        end

        function obj = set.modified(obj, modified)
            obj.modified_ = obj.validateModified('modified', 1, modified);
        end

    end

    methods

        function eq = equals(obj, symbol)
            error('todo');
        end

        function copy(obj, varargin)
            error('todo');
        end

        function flag = isValid(obj, varargin)
            flag = false;
        end

        function sparsity = getSparsity(obj)
            sparsity = obj.data_.getSparsity(obj.def_);
        end

        function n = countNA(obj, varargin)
            values = obj.validateValueKeys(varargin);
            n = obj.data_.countNA(values);
        end

        function n = countUndef(obj, varargin)
            values = obj.validateValueKeys(varargin);
            n = obj.data_.countUndef(values);
        end

        function n = countEps(obj, varargin)
            values = obj.validateValueKeys(varargin);
            n = obj.data_.countEps(values);
        end

        function n = countPosInf(obj, varargin)
            values = obj.validateValueKeys(varargin);
            n = obj.data_.countPosInf(values);
        end

        function n = countNegInf(obj, varargin)
            values = obj.validateValueKeys(varargin);
            n = obj.data_.countNegInf(values);
        end

        function nrecs = getNumberRecords(obj)
            nrecs = obj.data_.getNumberRecords();
        end

        function nvals = getNumberValues(obj, varargin)
            values = obj.validateValueKeys(varargin);
            nvals = obj.data_.getNumberValues(values);
        end

        function uels = getUELs(obj, varargin)
            if nargin >= 2 && isnumeric(varargin{1})
                varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
            end
            uels = obj.data_.getUELs(varargin{:});
        end

        function setUELs(obj, varargin)
            if nargin >= 3 && isnumeric(varargin{2})
                varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
            end
            obj.data_.setUELs(varargin{:});
        end

        function reorderUELs(obj, varargin)
            if nargin >= 3 && isnumeric(varargin{2})
                varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
            end
            obj.data_.reorderUELs(varargin{:});
        end

        function addUELs(obj, varargin)
            if nargin >= 3 && isnumeric(varargin{2})
                varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
            end
            obj.data_.addUELs(varargin{:});
        end

        function removeUELs(obj, varargin)
            if nargin >= 3 && isnumeric(varargin{2})
                varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
            end
            obj.data_.removeUELs(varargin{:});
        end

        function renameUELs(obj, varargin)
            if nargin >= 3 && isnumeric(varargin{2})
                varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
            end
            obj.data_.renameUELs(varargin{:});
        end

        function lowerUELs(obj, varargin)
            if nargin >= 2 && isnumeric(varargin{1})
                varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
            end
            obj.data_.lowerUELs(varargin{:});
        end

        function upperUELs(obj, varargin)
            if nargin >= 2 && isnumeric(varargin{1})
                varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
            end
            obj.data_.upperUELs(varargin{:});
        end

    end

end
