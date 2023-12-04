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
        name_ = ''
        description_ = ''
        data_
        modified_ = true
    end

    properties (Dependent)
        name
        description
        dimension
        data
        modified
    end

    properties (Abstract, Constant)
        VALUE_FIELDS
    end

    methods

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            validateattributes(name, {'string', 'char'}, {}, 'set.name', 'name', 1);
            name = char(name);
            if numel(name) >= gams.transfer.Globals.MAX_NAME_LENGTH
                error('Name length must be smaller than %d.', gams.transfer.Globals.MAX_NAME_LENGTH);
            end
            if strcmp(obj.name, name)
                return
            end
            % obj.container.renameSymbol(obj.name, name);
            obj.name_ = name;
            obj.modified = true;
        end

        function description = get.description(obj)
            description = obj.description_;
        end

        function set.description(obj, description)
            validateattributes(description, {'string', 'char'}, {}, 'set.description', 'description', 1);
            description = char(description);
            if numel(description) >= gams.transfer.Globals.MAX_DESCRIPTION_LENGTH
                error('Description length must be smaller than %d.', gams.transfer.Globals.MAX_DESCRIPTION_LENGTH);
            end
            obj.description_ = description;
            obj.modified = true;
        end

        function dim = get.dimension(obj)
            dim = obj.data.dimension;
        end

        function data = get.data(obj)
            data = obj.data_;
        end

        function set.data(obj, data)
            validateattributes(data, {'gams.transfer.data.Abstract'}, {}, 'set.data', 'data', 1);
            obj.data_ = data;
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
        end

        function obj = set.modified(obj, modified)
            validateattributes(modified, {'logical'}, {'scalar'}, 'set.modified', 'modified', 1);
            obj.modified_ = modified;
        end

    end

end
