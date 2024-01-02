% GAMS Alias
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
% GAMS Set Alias
classdef Abstract < handle

    properties (Hidden, SetAccess = protected)
        container_
        name_ = ''
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
    end

    properties (Abstract, Dependent)
        alias_with
        description
        is_singleton
        dimension
        size
        domain
        domain_labels
    end

    properties (Abstract, Dependent, SetAccess = private)
        domain_names
        domain_type
    end

    properties (Abstract, Dependent)
        domain_forwarding
        records
    end

    properties (Abstract, Dependent, SetAccess = private)
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

        function obj = set.name(obj, name)
            obj.name_ = obj.validateName('name', 1, name);
            % obj.container.renameSymbol(obj.name, name);
            obj.modified_ = true;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
        end

        function obj = set.modified(obj, modified)
            obj.modified_ = obj.validateModified('modified', 1, modified);
        end

    end

    methods (Abstract)
        eq = equals(obj, symbol)
        copy(obj, varargin)
        flag = isValid(obj, varargin)
        uels = getUELs(obj, varargin)
        removeUELs(obj, varargin)
        renameUELs(obj, uels)
        lowerUELs(obj)
        upperUELs(obj)
    end

end
