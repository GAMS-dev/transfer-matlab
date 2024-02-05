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
% Use subclasses to create a GAMS Symbol, see subclass help.
%
% See also: gams.transfer.symbol.Set, gams.transfer.symbol.Parameter, gams.transfer.symbol.Variable,
% gams.transfer.symbol.Equation
%

%> @brief Abstract Symbol
%>
%> Use subclasses to create a GAMS Symbol, see subclass help.
%>
%> @see \ref gams::transfer::symbol::Set "symbol.Set", \ref gams::transfer::symbol::Parameter
%> "symbol.Parameter", \ref gams::transfer::symbol::Variable "symbol.Variable", \ref
%> gams::transfer::symbol::Equation "symbol.Equation"
classdef (Abstract) Symbol < handle

    properties (Hidden, SetAccess = {?gams.transfer.Container, ?gams.transfer.symbol.Symbol})
        container_
        name_ = ''
        description_ = ''
        def_
        data_
        unique_labels_ = {}
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

        function arg = validateDimension(name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isscalar(arg)
                error('Argument ''%s'' (at position %d) must be scalar.', name, index);
            end
            if round(arg) ~= arg
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            if arg < 0 || arg > gams.transfer.Constants.MAX_DIMENSION
                error('Argument ''%s'' (at position %d) must be in [0, %d].', name, index, gams.transfer.Constants.MAX_DIMENSION);
            end
        end

        function arg = validateDef(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.definition.Definition')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.definition.Definition''.', name, index);
            end
        end

        function arg = validateData(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.data.Abstract')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.data.Abstract''.', name, index);
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

    methods (Hidden)

        function arg = validateUniqueLabels(obj, name, index, arg)
            if ~iscell(arg)
                error('Argument ''%s'' (at position %d) must be ''cell''.', name, index);
            end
            if numel(arg) ~= obj.dimension
                error('Argument ''%s'' (at position %d) must be ''cell'' with %d elements.', name, index, obj.dimension);
            end
            for i = 1:numel(arg)
                if isnumeric(arg{i}) && isempty(arg{i})
                    continue
                end
                if ~isa(arg{i}, 'gams.transfer.unique_labels.Abstract')
                    error('Argument ''%s'' (at position %d, element %d) must be empty or ''gams.transfer.unique_labels.Abstract''.', name, index, i);
                end
            end
        end

    end

    properties (Dependent)
        %> Container the symbol is stored in

        % container Container the symbol is stored in
        container


        %> Symbol name

        % name Symbol name
        name


        %> Symbol description

        % description Symbol description
        description
    end

    properties  (Dependent, Hidden)
        def
        data
        unique_labels
    end

    properties (Dependent)
        %> Dimension of symbol (in [0,20])

        % dimension Dimension of symbol (in [0,20])
        dimension


        %> Shape of symbol (length == dimension)
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN and \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED for more information.

        % size Shape of symbol (length == dimension)
        size


        %> Domain of symbol (length == dimension)
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN for more information.

        % domain Domain of symbol (length == dimension)
        domain


        %> Domain labels in records.
        %>
        %> Domain labels mirror the field/column names for domains in records. They only exist for
        %> \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT "formats" table and struct. Setting domain labels
        %> may modify the given labels to make them unique by adding _<dim>. * is changed to uni.

        % domain_labels Domain labels mirror the field/column names for domains in records. They
        % only exist for formats table and struct. Setting domain labels may modify the given labels
        % to make them unique by adding _<dim>. * is changed to uni.
        domain_labels
    end

    properties (Dependent, SetAccess = private)
        %> Domain names of symbol

        % domain_names Domain names of symbol
        domain_names


        %> Specifies if domains are stored 'relaxed' or 'regular'
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN for more information.

        % domain_type Specifies if domains are stored 'relaxed' or 'regular'
        domain_type
    end

    properties (Dependent)
        %> Enables domain entries in records to be recursively added to the domains in case they are
        %> not present in the domains already
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.

        % Enables domain entries in records to be recursively added to the domains in case they are
        % not present in the domains already
        domain_forwarding


        %> Storage of symbol records
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT for more information.

        % records Storage of symbol records
        records


        %> Format in which records are stored in
        %>
        %> If records are changed, this gets reset to 'unknown'. Calling \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid" will detect the
        %> format again.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT for more information.

        % format Format in which records are stored in
        %
        % If records are changed, this gets reset to 'unknown'. Calling isValid() will detect the
        % format again.
        format
    end

    properties (Dependent)
        %> Flag to indicate modification
        %>
        %> If the symbol has been modified since last reset of flag (`false`), this flag will be
        %> `true`.

        % Flag to indicate modification
        %
        % If the symbol has been modified since last reset of flag (false), this flag will be true.
        modified
    end

    methods

        function container = get.container(obj)
            container = obj.container_;
        end

        function obj = set.container(obj, container)
            if ~isempty(container)
                container = gams.transfer.utils.validate('container', 1, container, {'gams.transfer.Container', 'empty'}, -1);
            end
            obj.container_ = container;
            obj.def_.switchContainer(container);
            obj.modified_ = true;
        end

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            name = obj.validateName('name', 1, name);
            obj.container.renameSymbol(obj.name, name);
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

        function data = get.data(obj)
            data = obj.data_;
        end

        function obj = set.data(obj, data)
            obj.data_ = obj.validateData('data', 1, data);
            obj.modified_ = true;
        end

        function unique_labels = get.unique_labels(obj)
            dimension = numel(obj.unique_labels_);
            if obj.dimension < dimension
                obj.unique_labels_ = obj.unique_labels_(1:obj.dimension);
            elseif obj.dimension > dimension
                obj.unique_labels_(dimension+1:obj.dimension) = {[]};
            end
            unique_labels = obj.unique_labels_;
        end

        function set.unique_labels(obj, unique_labels)
            dimension = numel(obj.unique_labels_);
            if obj.dimension < dimension
                obj.unique_labels_ = obj.unique_labels_(1:obj.dimension);
            elseif obj.dimension > dimension
                obj.unique_labels_(dimension+1:obj.dimension) = {[]};
            end
            obj.unique_labels_ = obj.validateUniqueLabels('unique_labels', 1, unique_labels);
            obj.modified_ = true;
        end

        function dimension = get.dimension(obj)
            dimension = obj.def_.dimension();
        end

        function set.dimension(obj, dimension)
            dimension = obj.validateDimension('dimension', 1, dimension);
            if dimension < obj.dimension
                obj.def_.domains = obj.def_.domains(1:dimension);
            elseif dimension > obj.dimension
                obj.def_.domains(obj.dimension+1:dimension) = {gams.transfer.symbol.domain.Relaxed(gams.transfer.Constants.UNIVERSE_NAME)};
            end
            obj.modified_ = true;
        end

        function size = get.size(obj)
            size = obj.axes().size();
        end

        function set.size(obj, size)
            size = gams.transfer.utils.validate('size', 1, size, {'numeric'}, 1);
            domains = cell(1, numel(size));
            for i = 1:numel(size)
                domains{i} = ['dim_', int2str(i)];
            end
            obj.domain = domains;
            for i = 1:numel(size)
                obj.unique_labels{i} = gams.transfer.unique_labels.Range('', 1, 1, size(i));
            end
            obj.modified_ = true;
        end

        function domain = get.domain(obj)
            domain = obj.def_.domains;
            for i = 1:numel(domain)
                switch class(domain{i})
                case 'gams.transfer.symbol.domain.Regular'
                    domain{i} = domain{i}.symbol;
                case 'gams.transfer.symbol.domain.Relaxed'
                    domain{i} = domain{i}.name;
                otherwise
                    error('Unknown domain type: %s', class(domain{i}));
                end
            end
        end

        function obj = set.domain(obj, domain)
            obj.def_.domains = domain;
            obj.applyDomainForwarding();
            obj.modified_ = true;
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.def_.domainLabels();
        end

        function obj = set.domain_labels(obj, domain_labels)
            labels = obj.domain_labels;
            obj.def_.setDomainLabels(domain_labels);
            obj.data_.renameLabels(labels, obj.domain_labels);
            obj.modified_ = true;
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.def_.domainNames();
        end

        function domain_type = get.domain_type(obj)

            domains = obj.def_.domains;

            is_regular = numel(domains) > 0;
            is_none = true;
            for i = 1:numel(domains)
                switch class(domains{i})
                case 'gams.transfer.symbol.domain.Regular'
                    is_none = false;
                case 'gams.transfer.symbol.domain.Relaxed'
                    if ~strcmp(domains{i}.name, gams.transfer.Constants.UNIVERSE_NAME)
                        is_none = false;
                        is_regular = false;
                    end
                otherwise
                    error('Unknown domain type: %s', class(domains{i}));
                end
            end

            if is_none
                domain_type = 'none';
            elseif is_regular
                domain_type = 'regular';
            else
                domain_type = 'relaxed';
            end
        end

        function domain_forwarding = get.domain_forwarding(obj)
            dim = obj.dimension;
            domain_forwarding = false(1, dim);
            for i = 1:dim
                domain_forwarding(i) = obj.def_.domains{i}.forwarding;
            end
        end

        function obj = set.domain_forwarding(obj, domain_forwarding)
            dim = obj.dimension;
            if numel(domain_forwarding) == 1
                domain_forwarding = false(1, dim) | domain_forwarding;
            end
            for i = 1:dim
                obj.def_.domains{i}.forwarding = domain_forwarding(i);
            end
            obj.applyDomainForwarding();
            obj.modified_ = true;
        end

        function records = get.records(obj)
            records = obj.data_.records;
        end

        function obj = set.records(obj, records)
            obj.data_.records = records;
            obj.modified_ = true;
        end

        function format = get.format(obj)
            format = obj.data_.name();
        end

        function obj = set.format(obj, format)
            switch lower(format)
            case 'table'
                obj.data_ = gams.transfer.symbol.data.Table(obj.records);
            case 'struct'
                obj.data_ = gams.transfer.symbol.data.Struct(obj.records);
            case 'dense_matrix'
                obj.data_ = gams.transfer.symbol.data.DenseMatrix(obj.records);
            case 'sparse_matrix'
                obj.data_ = gams.transfer.symbol.data.SparseMatrix(obj.records);
            otherwise
                error('Unknown format');
            end
        end

        function modified = get.modified(obj)
            modified = obj.modified_;
        end

        function obj = set.modified(obj, modified)
            obj.modified_ = obj.validateModified('modified', 1, modified);
        end

    end

    methods (Abstract)
        symbol = copy(obj, varargin)
    end

    methods (Hidden)

        function copyFrom(obj, symbol)

            % parse input arguments
            try
                symbol = gams.transfer.utils.validate('symbol', 1, symbol, {class(obj)}, -1);
            catch e
                error(e.message);
            end

            obj.description_ = symbol.description;
            obj.def_ = symbol.def.copy();
            obj.data_ = symbol.data.copy();
            obj.unique_labels_ = cell(1, symbol.dimension);
            for i = 1:symbol.dimension
                if isempty(symbol.unique_labels{i})
                    obj.unique_labels_{i} = [];
                else
                    obj.unique_labels_{i} = symbol.unique_labels{i}.copy();
                end
            end
            obj.modified_ = true;
        end

    end

    methods

        %> Checks equivalence with other symbol
        %>
        %> @note A symbol is always linked to a container. This method does not check equivalence of
        %> the linked containers.
        %>
        %> **Required Arguments:**
        %> 1. symbol (`any`):
        %>    Other symbol
        function eq = equals(obj, symbol)
            % Checks equivalence with other symbol
            %
            % Note: A symbol is always linked to a container. This method does not check equivalence
            % of the linked containers.
            %
            % Required Arguments:
            % 1. symbol (any):
            %    Other symbol

            eq = isequal(class(obj), class(symbol)) && ...
                isequal(obj.name_, symbol.name) && ...
                isequal(obj.description_, symbol.description) && ...
                obj.def_.equals(symbol.def) && ...
                obj.data_.equals(symbol.data);
        end

        %> Sets symbol records in supported format
        %>
        %> If records are not given in any of the supported formats, e.g. struct or dense_matrix,
        %> this function tries to convert the given data into one of them.
        %>
        %> Conversion is applied based on the following rules:
        %> - `string`: Interpreted as domain entry for first dimension.
        %> - `cellstr`: First dimension of `cellstr` must be equal to symbol dimension and second
        %>   will be the number of records. Row `i` is interpreted to hold the domain entries for
        %>   dimension `i`.
        %> - `numeric vector/matrix`: Interpreted to hold the `level` values (or `value` for
        %>   Parameter). Must satisfy the shape given by symbol size since this can only be a matrix
        %>   format (e.g. `dense_matrix` or `sparse_matrix`), because domain entries are not given.
        %> - `cell`: If element is the `i`-th `cellstr`, then this is considered to be the domain
        %>   entries for the `i`-th domain. If element is the `j`-th numeric vector/matrix, it is
        %>   interpreted as the `j`-th element of the following: `level` or `value`, `marginal`,
        %>   `lower`, `upper`, `scale`. If symbol is a \ref gams::transfer::Set "Set", the
        %>   `(dim+1)`-th `cellstr` is considered to be the set element texts.
        %> - `struct`: Fields which names match domain labels, are interpreted as domain entries of
        %>   the given domain. Other supported fields are `level`, `value`, `marginal`, `lower`,
        %>   `upper`, `scale`, `element_text`. Unsopprted fields are ignored.
        %> - `table`: used as is.
        %>
        %> @note Instead of a `cell`, it is possible to provide the elements as separate arguments
        %> to the function.
        %>
        %> **Example:**
        %> ```
        %> c = Container();
        %> i = Set(c, 'i', 'description', 'canning plants');
        %> i.setRecords({'seattle', 'san-diego'});
        %> a = Parameter(c, 'a', i, 'description', 'capacity of plant i in cases');
        %> a.setRecords([350, 600]);
        %> supply = Equation(c, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
        %> supply.setRecords(struct('level', [350, 550], 'marginal', [geteps(), 0], 'upper', [350, 600]));
        %> ```
        %>
        %> @see \ref gams::transfer::RecordsFormat "RecordsFormat"
        function setRecords(obj, varargin)
            % Sets symbol records in supported format
            %
            % If records are not given in any of the supported formats, e.g. struct or dense_matrix,
            % this function tries to convert the given data into one of them.
            %
            % Conversion is applied based on the following rules:
            % - string: Interpreted as domain entry for first dimension.
            % - cellstr: First dimension of cellstr must be equal to symbol dimension and second
            %   will be the number of records. Row i is interpreted to hold the domain entries for
            %   dimension i.
            % - numeric vector/matrix: Interpreted to hold the level values (or values for
            %   Parameter). Must satisfy the shape given by symbol size since this can only be a
            %   matrix format (e.g. dense_matrix or sparse_matrix), because domain entries are not
            %   given.
            % - cell: If element is the i-th cellstr, then this is considered to be the domain
            %   entries for the i-th domain. If element is the j-th numeric vector/matrix, it is
            %   interpreted as the j-th element of the following: level or value, marginal, lower,
            %   upper, scale. If symbol is a Set, the (dim+1)-th cellstr is considered to be the set
            %   element texts.
            % - struct: Fields which names match domain labels, are interpreted as domain entries of
            %   the given domain. Other supported fields are level, value, marginal, lower, upper,
            %   scale, element_text. Unsopprted fields are ignored.
            % - table: used as is.
            %
            % Note: Instead of a cell, it is possible to provide the elements as separate arguments
            % to the function.
            %
            % Example:
            % c = Container();
            % i = Set(c, 'i', 'description', 'canning plants');
            % i.setRecords({'seattle', 'san-diego'});
            % a = Parameter(c, 'a', i, 'description', 'capacity of plant i in cases');
            % a.setRecords([350, 600]);
            % supply = Equation(c, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
            % supply.setRecords(struct('level', [350, 550], 'marginal', [geteps(), 0], 'upper', [350, 600]));
            %
            % See also: gams.transfer.RecordsFormat

            if nargin == 2
                records = varargin{1};
            else
                records = varargin;
            end

            if gams.transfer.Constants.SUPPORTS_TABLE && istable(records)
                records = gams.transfer.symbol.data.Table(records);
            end
            if isa(records, 'gams.transfer.symbol.data.Abstract')
                status = records.isValid(obj.axes(), obj.def_.values);
                if status.flag ~= gams.transfer.utils.Status.OK
                    error(status.message);
                end
                obj.data_ = records;
                obj.applyDomainForwarding();
                obj.modified_ = true;
                return
            end

            % reset current records in order to avoid using categoricals as unique_labels
            obj.data_ = gams.transfer.symbol.data.Struct();

            domains = {};
            values = {};
            new_records = struct();

            % string -> recall with cell of strings
            if isstring(records) && numel(records) == 1 || ischar(records)
                if obj.dimension ~= 1
                    error('Single string as records only accepted if symbol dimension equals 1.');
                end
                domain = obj.def_.domains{1};
                new_records.(domain.label) = {records};
                domains{end+1} = domain;

            % cell of strings -> domain entries
            elseif iscellstr(records)
                s = size(records);
                if s(1) ~= obj.dimension
                    error('First dimension of cellstr must equal symbol dimension.');
                end
                for i = 1:obj.dimension
                    domain = obj.def_.domains{i};
                    new_records.(domain.label) = records(i,:);
                    domains{end+1} = domain;
                end

            % numeric vector -> interpret as level values in matrix format
            elseif isnumeric(records) && numel(obj.def_.values) > 0
                value = obj.def_.values{1};
                new_records.(value.label) = records;
                values{end+1} = value;

            % cell -> cellstr elements to domains or set element texts and
            % numeric vector to values
            elseif iscell(records)
                values_used = false(1, numel(obj.def_.values));
                n_domains = 0;
                for i = 1:numel(records)
                    stored_record = false;

                    if isnumeric(records{i})
                        for j = 1:numel(obj.def_.values)
                            value = obj.def_.values{j};
                            if isa(value, 'gams.transfer.symbol.value.Numeric') && ~values_used(j)
                                new_records.(value.label) = records{i};
                                values{end+1} = value;
                                values_used(j) = true;
                                stored_record = true;
                                break;
                            end
                        end
                        if ~stored_record
                            error('Too many value fields in records.');
                        end
                    elseif iscellstr(records{i})
                        n_domains = n_domains + 1;

                        % used all domains -> look for string values
                        if n_domains > obj.dimension
                            for j = 1:numel(obj.def_.values)
                                value = obj.def_.values{j};
                                if isa(value, 'gams.transfer.symbol.value.String') && ~values_used(j)
                                    new_records.(value.label) = records{i};
                                    values{end+1} = value;
                                    values_used(j) = true;
                                    stored_record = true;
                                    break;
                                end
                            end
                            if ~stored_record
                                error('More cellstr values than domains and string value fields.');
                            end
                        else
                            domain = obj.def_.domains{n_domains};
                            new_records.(domain.label) = records{i};
                            domains{end+1} = domain;
                        end
                    else
                        error('Cell elements must be cellstr or numeric.');
                    end
                end

            % struct -> check fields for domain or value fields
            elseif isstruct(records) && numel(records) == 1
                fields = fieldnames(records);
                for i = 1:numel(fields)
                    value = obj.def_.getValue(fields{i});
                    if ~isempty(value)
                        new_records.(value.label) = records.(fields{i});
                        values{end+1} = value;
                        continue;
                    end

                    domain = obj.def_.getDomain(fields{i});
                    if ~isempty(domain)
                        new_records.(domain.label) = records.(fields{i});
                        domains{end+1} = domain;
                    end
                end

            else
                error('Unsupported records format.');
            end

            domains_values = [domains, values];

            % create proper index for domain entries
            for i = 1:numel(domains)
                if isnumeric(new_records.(domains{i}.label))
                    continue
                end
                unique_labels = gams.transfer.utils.unique(new_records.(domains{i}.label));
                new_records.(domains{i}.label) = gams.transfer.unique_labels.Abstract.createIndexFrom(...
                    new_records.(domains{i}.label), unique_labels);
                if ~gams.transfer.Constants.SUPPORTS_CATEGORICAL || ~iscategorical(new_records.(domains{i}.label))
                    obj.unique_labels{i} = gams.transfer.unique_labels.OrderedLabelSet(unique_labels);
                end
            end

            % create categoricals for element_text
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                for i = 1:numel(values)
                    if ~isa(values{i}, 'gams.transfer.symbol.value.String')
                        continue
                    end
                    new_records.(values{i}.label) = categorical(new_records.(values{i}.label));
                end
            end

            % anything sparse or scalar?
            is_sparse = false;
            is_scalar = false;
            for i = 1:numel(values)
                is_sparse = is_sparse || issparse(new_records.(values{i}.label));
                is_scalar = is_scalar || isscalar(new_records.(values{i}.label));
            end

            % select record format
            if numel(domains) > 0
                data = gams.transfer.symbol.data.Struct(new_records);
            elseif is_sparse
                data = gams.transfer.symbol.data.SparseMatrix(new_records);
            elseif is_scalar
                data = gams.transfer.symbol.data.Struct(new_records);
            else
                data = gams.transfer.symbol.data.DenseMatrix(new_records);
            end

            % reshape data
            if isa(data, 'gams.transfer.symbol.data.Tabular')
                for i = 1:numel(domains_values)
                    data.records.(domains_values{i}.label) = data.records.(domains_values{i}.label)(:);
                end
            elseif isa(data, 'gams.transfer.symbol.data.Matrix')
                symbol_size = obj.axes(true).matrixSize();
                if any(isnan(symbol_size))
                    error('Cannot create matrix records, because symbol size is unknown.');
                end
                for i = 1:numel(domains_values)
                    if all(symbol_size == size(data.records.(domains_values{i}.label)))
                        continue;
                    end
                    data.records.(domains_values{i}.label) = data.records.(domains_values{i}.label)';
                    if all(symbol_size == size(data.records.(domains_values{i}.label)))
                        continue;
                    end
                    error('Cannot create matrix records, because value size does not match symbol size.');
                end
            end

            % check records format
            status = data.isValid(obj.axes(), obj.def_.values);
            if status.flag ~= gams.transfer.utils.Status.OK
                error(status.message);
            end

            obj.data_ = data;
            obj.applyDomainForwarding();
            obj.modified_ = true;
        end

        %> Transforms symbol records into given format
        %>
        %> @see \ref gams::transfer::RecordsFormat "RecordsFormat"
        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: gams.transfer.RecordsFormat

            switch target_format
            case 'table'
                data = gams.transfer.symbol.data.Table();
            case 'struct'
                data = gams.transfer.symbol.data.Struct();
            case 'dense_matrix'
                data = gams.transfer.symbol.data.DenseMatrix();
            case 'sparse_matrix'
                data = gams.transfer.symbol.data.SparseMatrix();
            otherwise
                error('Unknown format');
            end

            obj.data_.transformTo(obj.axes(), obj.def_.values, data);
            obj.data_ = data;
        end

        %> Checks correctness of symbol
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_VALIDATE for more information.
        %>
        %> **Optional Arguments:**
        %> 1. verbose (`logical`):
        %>    If `true`, the reason for an invalid symbol is printed
        %> 2. force (`logical`):
        %>    If `true`, forces reevaluation of validity (resets cache)
        %>
        %> @see \ref gams::transfer::Container::isValid "Container.isValid"
        function flag = isValid(obj, varargin)
            % Checks correctness of symbol
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)
            %
            % See also: gams.transfer.Container/isValid

            % TODO: caching

            verbose = 0;
            force = false;
            if nargin > 1
                verbose = max(0, min(2, varargin{1}));
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            if ~isa(obj.container_, 'gams.transfer.Container') || ...
                ~obj.container_.hasSymbols(obj.name_) || obj.container_.getSymbols(obj.name_) ~= obj
                msg = 'Symbol is not contained in its linked container.';
                switch verbose
                case 1
                    warning(msg);
                case 2
                    error(msg);
                end
                flag = false;
                return
            end

            status = obj.def_.isValid();
            if status.flag == gams.transfer.utils.Status.OK
                status = obj.data_.isValid(obj.axes(), obj.def_.values);
            end

            if status.flag ~= gams.transfer.utils.Status.OK
                switch verbose
                case 0
                case 1
                    warning(status.message);

                case 2
                    error(status.message);
                otherwise
                    error('Invalid verbose selection: %d', verbose);
                end
                flag = false;
                return
            end

            obj.applyDomainForwarding();

            flag = true;
        end

        %> Get domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref gams::transfer::symbol::Set "Sets"
        %> as \ref gams::transfer::symbol::Symbol::domain "domain"(s) -- and is thus of domain
        %> type `regular`, see \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in
        %> its \ref gams::transfer::symbol::Symbol::records "records" that is not present in the
        %> corresponding referenced domain set. Such a domain violation will lead to a GDX error
        %> when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `domain_violations = getDomainViolations` returns a list of domain violations for all
        %>   dimensions.
        %> - `domain_violations = getDomainViolations(d)` returns a list of domain violations for
        %>   dimension(s) `d`.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::resolveDomainViolations
        %> "symbol.Symbol.resolveDomainViolations", \ref gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations", \ref gams::transfer::DomainViolation "DomainViolation"
        function domain_violations = getDomainViolations(obj, varargin)
            % Get domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as domain(s) and a domain
            % entry in its records that is not present in the corresponding set. Such a domain
            % violation will lead to a GDX error when writing the data.
            %
            % domain_violations = getDomainViolations returns a list of domain violations for all
            % dimension.
            % domain_violations = getDomainViolations(d) returns a list of domain violations for
            % dimension(s) d.
            %
            % See also: gams.transfer.symbol.Symbol.resolveDomainViolations,
            % gams.transfer.Container.getDomainViolations, gams.transfer.DomainViolation

            if nargin >= 2 && isnumeric(varargin{1})
                try
                    dimensions = varargin{1};
                    domains = obj.validateDimensionToDomain('dimension', 1, dimensions);
                catch e
                    error(e.message);
                end
            else
                dimensions = 1:obj.dimension;
                domains = obj.def_.domains;
            end

            domain_violations = {};
            for i = 1:numel(domains)
                % TODO: should also work for relaxed domains
                if ~isa(domains{i}, 'gams.transfer.symbol.domain.Regular')
                    continue
                end

                % TODO computing domain violation should be moved into axis
                axis1 = obj.axis(dimensions(i));
                axis2 = obj.axis(dimensions(i), true);
                if isequal(axis1.unique_labels, axis2.unique_labels)
                    continue
                end
                working_uels = axis1.unique_labels.getAt(obj.data_.usedUniqueLabels(domains{i}));
                defining_uels = axis2.unique_labels.get();
                [~, ia] = setdiff(lower(working_uels), lower(defining_uels));
                added_uels = working_uels(ia);

                if numel(added_uels) > 0
                    domain_violations{end+1} = gams.transfer.DomainViolation(obj, ...
                        dimensions(i), domains{i}.symbol, added_uels);
                end
            end

        end

        %> Extends domain sets in order to resolve domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref gams::transfer::symbol::Set "Sets"
        %> as \ref gams::transfer::symbol::Symbol::domain "domain"(s) -- and is thus of domain
        %> type `regular`, see \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in
        %> its \ref gams::transfer::symbol::Symbol::records "records" that is not present in the
        %> corresponding referenced domain set. Such a domain violation will lead to a GDX error
        %> when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `resolveDomainViolations()` extends the domain sets with the violated domain entries
        %>   for all domains. Hence, the domain violations disappear.
        %> - `resolveDomainViolations(d)` extends the domain sets with the violated domain entries
        %>   for dimension(s) `d`. Hence, the domain violations disappear for those dimension(s).
        %>
        %> @see \ref gams::transfer::symbol::Symbol::getDomainViolations
        %> "symbol.Symbol.getDomainViolations", \ref
        %> gams::transfer::Container::resolveDomainViolations "Container.resolveDomainViolations",
        %> \ref gams::transfer::DomainViolation "DomainViolation"
        function resolveDomainViolations(obj, varargin)
            % Extends domain sets in order to resolve domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as domain(s) and a domain
            % entry in its records that is not present in the corresponding set. Such a domain
            % violation will lead to a GDX error when writing the data.
            %
            % resolveDomainViolations() extends the domain sets with the violated domain entries for
            % all dimensions. Hence, the domain violations disappear.
            % resolveDomainViolations(d) extends the domain sets with the violated domain entries
            % for dimension(s) d. Hence, the domain violations disappear for those dimension(s).
            %
            % See also: gams.transfer.symbol.Symbol.getDomainViolations,
            % gams.transfer.Container.resolveDomainViolations, gams.transfer.DomainViolation

            domain_violations = obj.getDomainViolations(varargin{:});
            for i = 1:numel(domain_violations)
                domain_violations{i}.resolve();
            end
        end

        %> Returns the sparsity of symbol records
        %>
        %> - `s = getSparsity()` returns sparsity `s` in the symbol records.
        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % s = getSparsity() returns sparsity s in the symbol records.

            sparsity = obj.data_.getSparsity(obj.axes(), obj.def_.values);
        end

    end

    methods (Hidden, Access = protected)

        function values = parseValues(obj, varargin)

            % parse input arguments
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'values')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'string', 'char'}, 1, -1));
                        values = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'values', validate);
                        index = index + 2;
                        is_pararg = true;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = 1:numel(values)
                found_value = false;
                for j = 1:numel(obj.def_.values)
                    if strcmpi(obj.def_.values{j}.label, values{i})
                        values{i} = obj.def_.values{j};
                        found_value = true;
                        break;
                    end
                end
                if ~found_value
                    error('Argument ''values'' contains invalid value: %s.', values{i});
                end
            end
        end

    end

    methods

        %> Returns the largest value in records
        %>
        %> - `[v, w] = getMaxValue(varargin)` returns the largest value in records `v` and where it
        %>   is `w`. `varargin` can include a list of value fields that should be considered:
        %>   `"level"`, `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available
        %>   for the symbol are considered.
        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % [v, w] = getMaxValue(varargin) returns the largest value in records v and where it is
            % w. varargin can include a list of value fields that should be considered: level,
            % value, lower, upper, scale. If none is given all available for the symbol are
            % considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMaxValue(obj.axes(), values);
        end


        %> Returns the smallest value in records
        %>
        %> - `[v, w] = getMinValue(varargin)` returns the smallest value in records `v` and where it
        %>   is `w`. `varargin` can include a list of value fields that should be considered:
        %>   `"level"`, `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available
        %>   for the symbol are considered.
        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % [v, w] = getMinValue(varargin) returns the smallest value in records v and where it is
            % w. varargin can include a list of value fields that should be considered: level,
            % value, lower, upper, scale. If none is given all available for the symbol are
            % considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMinValue(obj.axes(), values);
        end

        %> Returns the mean value over all values in records
        %>
        %> - `v = getMeanValue(varargin)` returns the mean value over all values in records `v`.
        %>   `varargin` can include a list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available for the
        %>   symbol are considered.
        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % v = getMeanValue(varargin) returns the mean value over all values in records v.
            % varargin can include a list of value fields that should be considered: level, value,
            % lower, upper, scale. If none is given all available for the symbol are considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            value = obj.data_.getMeanValue(obj.axes(), values);
        end

        %> Returns the largest absolute value in records
        %>
        %> - `[v, w] = getMaxAbsValue(varargin)` returns the largest absolute value in records `v`
        %>   and where it is `w`. `varargin` can include a list of value fields that should be
        %>   considered: `"level"`, `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all
        %>   available for the symbol are considered.
        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % [v, w] = getMaxAbsValue(varargin) returns the largest absolute value in records v and
            % where it is w. varargin can include a list of value fields that should be considered:
            % level, value, lower, upper, scale. If none is given all available for the symbol are
            % considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMaxAbsValue(obj.axes(), values);
        end

        %> Returns the number of GAMS NA values in records
        %>
        %> - `n = countNA(varargin)` returns the number of GAMS NA values `n` in records. `varargin`
        %>   can include a list of value fields that should be considered: `"level"`, `"value"`,
        %>   `"lower"`, `"upper"`, `"scale"`. If none is given all available for the symbol are
        %>   considered.
        %>
        %> @see \ref gams::transfer::SpecialValues::NA "SpecialValues.NA", \ref
        %> gams::transfer::SpecialValues::isNA "SpecialValues.isNA"
        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % n = countNA(varargin) returns the number of GAMS NA values n in records. varargin can
            % include a list of value fields that should be considered: level, value, lower, upper,
            % scale. If none is given all available for the symbol are considered.
            %
            % See also: gams.transfer.SpecialValues.NA, gams.transfer.SpecialValues.isna

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countNA(values);
        end

        %> Returns the number of GAMS UNDEF values in records
        %>
        %> - `n = countUndef(varargin)` returns the number of GAMS UNDEF values `n` in records.
        %>   `varargin` can include a list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available for the
        %>   symbol are considered.
        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % n = countUndef(varargin) returns the number of GAMS UNDEF values n in records.
            % varargin can include a list of value fields that should be considered: level, value,
            % lower, upper, scale. If none is given all available for the symbol are considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countUndef(values);
        end

        %> Returns the number of GAMS EPS values in records
        %>
        %> - `n = countEps(varargin)` returns the number of GAMS EPS values `n` in records.
        %>   `varargin` can include a list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available for the
        %>   symbol are considered.
        %>
        %> @see \ref gams::transfer::SpecialValues::EPS "SpecialValues.EPS", \ref
        %> gams::transfer::SpecialValues::isEps "SpecialValues.isEps"
        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % n = countEps(varargin) returns the number of GAMS EPS values n in records. varargin
            % can include a list of value fields that should be considered: level, value, lower,
            % upper, scale. If none is given all available for the symbol are considered.
            %
            % See also: gams.transfer.SpecialValues.EPS, gams.transfer.SpecialValues.isEps

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countEps(values);
        end

        %> Returns the number of GAMS PINF (positive infinity) values in
        %> records
        %>
        %> - `n = countPosInf(varargin)` returns the number of GAMS PINF values `n` in records.
        %>   `varargin` can include a list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available for the
        %>   symbol are considered.
        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % n = countPosInf(varargin) returns the number of GAMS PINF values n in records.
            % varargin can include a list of value fields that should be considered: level, value,
            % lower, upper, scale. If none is given all available for the symbol are considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countPosInf(values);
        end

        %> Returns the number of GAMS MINF (negative infinity) values in
        %> records
        %>
        %> - `n = countNegInf(varargin)` returns the number of GAMS MINF values `n` in records.
        %>   `varargin` can include a list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all available for the
        %>   symbol are considered.
        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % n = countNegInf(varargin) returns the number of GAMS MINF values n in records.
            % varargin can include a list of value fields that should be considered: level, value,
            % lower, upper, scale. If none is given all available for the symbol are considered.

            % TODO adapt documentation

            if nargin == 1
                values = obj.def_.values;
            else
                try
                    values = obj.parseValues(varargin{:});
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countNegInf(values);
        end

        %> Returns the number of GDX records (not available for matrix formats)
        %>
        %> - `n = getNumberRecords()` returns the number of records that would be stored in a GDX
        %> file if this symbol would be written to GDX. For matrix formats `n` is `NaN`.
        function nrecs = getNumberRecords(obj)
            % Returns the number of GDX records (not available for matrix
            % formats)
            %
            % n = getNumberRecords() returns the number of records that would be stored in a GDX
            % file if this symbol would be written to GDX. For matrix formats n is NaN.

            nrecs = obj.data_.getNumberRecords(obj.axes(), obj.def_.values);
        end

        %> Returns the number of values stored for this symbol.
        %>
        %> - `n = getNumberValues(varargin)` is the sum of values stored of the following fields:
        %>   `"level"`, `"value"`, `"marginal"`, `"lower"`, `"upper"`, `"scale"`. The number of
        %>   values is the basis for the sparsity computation. `varargin` can include a list of
        %>   value fields that should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are considered.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::getSparsity "symbol.Symbol.getSparsity"
        function nvals = getNumberValues(obj, varargin)
            % Returns the number of values stored for this symbol.
            %
            % n = getNumberValues(varargin) is the sum of values stored of the following fields:
            % level, value, marginal, lower, upper, scale. The number of values is the basis for the
            % sparsity computation. varargin can include a list of value fields that should be
            % considered: level, value, lower, upper, scale. If none is given all available for the
            % symbol are considered.
            %
            % See also: gams.transfer.symbol.Symbol.getSparsity

            % values = obj.validateValueKeys(varargin); % TODO
            nvals = obj.data_.getNumberValues(obj.axes(), obj.def_.values);
        end

    end

    methods (Hidden)

        function argout = validateDimensionToDomain(obj, name, index, arg)
            if ~isnumeric(arg)
                error('Argument ''%s'' (at position %d) must be numeric.', name, index);
            end
            if ~isvector(arg)
                error('Argument ''%s'' (at position %d) must be vector.', name, index);
            end
            if any(round(arg) ~= arg)
                error('Argument ''%s'' (at position %d) must be integer.', name, index);
            end
            argout = cell(1, numel(arg));
            for i = 1:numel(arg)
                if arg(i) < 1 || arg(i) > obj.dimension
                    error('Argument ''%s'' (at position %d) must have values in [1, %d].', name, index, obj.dimension);
                end
                argout{i} = obj.def_.domains{arg(i)};
            end
        end

        function axis = axis(obj, dimension, prioritize_super)
            % TODO check dimension

            domain = obj.def_.domains{dimension};
            if nargin == 2 || ~prioritize_super
                if ~isempty(obj.data_) && obj.data_.hasUniqueLabels(domain)
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, ...
                        gams.transfer.unique_labels.Data(obj.data_, domain));
                elseif ~isempty(obj.unique_labels{dimension})
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, obj.unique_labels{dimension});
                elseif domain.hasUniqueLabels()
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, domain.getUniqueLabels());
                else
                    obj.unique_labels_{dimension} = gams.transfer.unique_labels.OrderedLabelSet();
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, obj.unique_labels{dimension});
                end
            else
                if domain.hasUniqueLabels()
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, domain.getUniqueLabels());
                elseif ~isempty(obj.unique_labels{dimension})
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, obj.unique_labels{dimension});
                elseif ~isempty(obj.data_) && obj.data_.hasUniqueLabels(domain)
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, ...
                        gams.transfer.unique_labels.Data(obj.data_, domain));
                else
                    obj.unique_labels_{dimension} = gams.transfer.unique_labels.OrderedLabelSet();
                    axis = gams.transfer.symbol.unique_labels.Axis(domain.label, obj.unique_labels{dimension});
                end
            end
        end

        function axes = axes(obj, prioritize_super)
            if nargin == 1
                prioritize_super = false;
            end
            dim = obj.dimension;
            axes = cell(1, dim);
            for i = 1:dim
                axes{i} = obj.axis(i, prioritize_super);
            end
            axes = gams.transfer.symbol.unique_labels.Axes(axes);
        end

        function indices = usedUniqueLabels(obj, dimension)
            indices = obj.data_.usedUniqueLabels(obj.def_.domains{dimension});
        end

        function count = countUniqueLabels(obj, dimension)
            count = obj.axis(dimension).unique_labels.count();
        end

        function labels = getUniqueLabels(obj, dimension)
            labels = obj.axis(dimension).unique_labels.get();
        end

        function labels = getUniqueLabelsAt(obj, dimension, indices)
            labels = obj.axis(dimension).unique_labels.getAt(indices);
        end

        function indices = findUniqueLabels(obj, dimension, labels)
            indices = obj.axis(dimension).unique_labels.find(labels);
        end

        function clearUniqueLabels(obj, dimension)
            obj.axis(dimension).unique_labels.clear();
        end

        function addUniqueLabels(obj, dimension, labels)
            obj.axis(dimension).unique_labels.add(labels);
        end

        function setUniqueLabels(obj, dimension, labels)
            obj.axis(dimension).unique_labels.set(labels);
        end

        function updateUniqueLabels(obj, dimension, labels)
            unique_labels = obj.axis(dimension).unique_labels;
            if isa(unique_labels, 'gams.transfer.unique_labels.Data')
                assert(unique_labels.data == obj.data_);
                obj.data_.updateUniqueLabels(obj.def_.domains{dimension}, labels);
            else
                % TODO
            end
        end

        function removeUniqueLabels(obj, dimension, labels)
            obj.axis(dimension).unique_labels.remove(labels);
        end

        function removeUnusedUniqueLabels(obj, dimension)
            unique_labels = obj.axis(dimension).unique_labels;
            if isa(unique_labels, 'gams.transfer.unique_labels.Data')
                assert(unique_labels.data == obj.data_);
                obj.data_.removeUnusedUniqueLabels(obj.def_.domains{dimension});
            else
                % TODO
            end
        end

        function renameUniqueLabels(obj, dimension, oldlabels, newlabels)
            obj.axis(dimension).unique_labels.rename(oldlabels, newlabels);
        end

        function mergeUniqueLabels(obj, dimension, oldlabels, newlabels)
            unique_labels = obj.axis(dimension).unique_labels;
            if isa(unique_labels, 'gams.transfer.unique_labels.Data')
                assert(unique_labels.data == obj.data_);
                obj.data_.mergeUniqueLabels(obj.def_.domains{dimension}, oldlabels, newlabels);
            else
                % TODO
            end
        end

    end

    methods

        %> Returns the UELs used in this symbol
        %>
        %> - `u = getUELs()` returns the UELs across all dimensions.
        %> - `u = getUELs(d)` returns the UELs used in dimension(s) `d`.
        %> - `u = getUELs(d, i)` returns the UELs `u` for the given UEL codes `i`.
        %> - `u = getUELs(d, _, "ignore_unused", true)` returns only those UELs that are actually
        %>   used in the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in this symbol
            %
            % u = getUELs() returns the UELs across all dimensions.
            % u = getUELs(d) returns the UELs used in dimension(s) d.
            % u = getUELs(d, i) returns the UELs u for the given UEL codes i.
            % u = getUELs(_, 'ignore_unused', true) returns only those UELs that are actually used
            % in the records.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            codes = [];
            ignore_unused = false;
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'ignore_unused')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        ignore_unused = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'ignore_unused', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'numeric'}, -1));
                        codes = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'codes', validate);
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            uels = {};
            for i = dimensions
                if isempty(codes) && ignore_unused
                    uels_i = obj.getUniqueLabelsAt(i, obj.usedUniqueLabels(i));
                elseif isempty(codes)
                    uels_i = obj.getUniqueLabels(i);
                elseif ignore_unused
                    uels_i = gams.transfer.utils.filter_unique_labels(...
                        obj.getUniqueLabelsAt(i, obj.usedUniqueLabels(i)), codes);
                else
                    uels_i = obj.getUniqueLabelsAt(i, codes);
                end
                uels = [uels; reshape(uels_i, numel(uels_i), 1)];
            end

            if numel(dimensions) > 1
                uels = gams.transfer.utils.unique(uels);
            end
        end

        %> Sets UELs
        %>
        %> - `setUELs(u, d)` sets the UELs `u` for dimension(s) `d`. This may modify UEL codes used
        %>   in the property records such that records still point to the correct UEL label when UEL
        %>   codes have changed.
        %> - `setUELs(u, d, 'rename', true)` sets the UELs `u` for dimension(s) `d`. This does not
        %>   modify UEL codes used in the property records. This can change the meaning of the
        %>   records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function setUELs(obj, varargin)
            % Sets UELs
            %
            % setUELs(u, d) sets the UELs u for dimension(s) d. This may modify UEL codes used in
            % the property records such that records still point to the correct UEL label when UEL
            % codes have changed.
            % setUELs(u, d, 'rename', true) sets the UELs u for dimension(s) d. This does not modify
            % UEL codes used in the property records. This can change the meaning of the records.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            rename = false;
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', []); % TODO
                index = 2;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'rename')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        rename = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'rename', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                if rename
                    obj.setUniqueLabels(i, uels);
                else
                    obj.updateUniqueLabels(i, uels);
                end
            end
        end

        %> Reorders UELs
        %>
        %> Same functionality as `setUELs(uels, dim)`, but checks that no new categories are added.
        %> The meaning of records does not change.
        %>
        %> - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
        %>   appended.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::setUELs "symbol.Symbol.setUELs"
        function reorderUELs(obj, varargin)
            % Reorders UELs
            %
            % Same functionality as setUELs(uels, dim), but checks that no new categories are added.
            % The meaning of records does not change.
            %
            % - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
            %   appended.
            %
            % See also: gams.transfer.symbol.Symbol.setUELs

            % parse input arguments
            dimensions = 1:obj.dimension;
            uels = {};
            rename = false;
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'rename')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        rename = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'rename', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        uels = gams.transfer.utils.parse_argument(varargin, ...
                            1, 'uels', []); % TODO
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if isempty(uels)
                for i = dimensions
                    labels = obj.getUniqueLabels(i);
                    indices = obj.usedUniqueLabels(i);
                    used_labels = labels(indices);
                    obj.updateUniqueLabels(i, used_labels);
                    obj.addUniqueLabels(i, setdiff(labels, used_labels));
                end
                return
            end

            for i = dimensions
                labels = obj.getUniqueLabels(i);
                if numel(uels) ~= numel(labels)
                    error('Number of UELs %d not equal to number of current UELs %d', ...
                        numel(uels), numel(labels));
                end
                if ~all(ismember(labels, uels))
                    error('Adding new UELs not supported for reordering');
                end
                obj.updateUniqueLabels(i, uels);
            end
        end

        %> Adds UELs to the symbol
        %>
        %> - `addUELs(u)` adds the UELs `u` for all dimensions.
        %> - `addUELs(u, d)` adds the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function addUELs(obj, varargin)
            % Adds UELs to the symbol
            %
            % addUELs(u) adds the UELs u for all dimensions.
            % addUELs(u, d) adds the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', []); % TODO
                index = 2;
                is_pararg = false;
                while index < nargin
                    if ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                obj.addUniqueLabels(i, uels);
            end
        end

        %> Removes UELs from the symbol
        %>
        %> - `removeUELs()` removes all unused UELs for all dimensions.
        %> - `removeUELs({}, d)` removes all unused UELs for dimension(s) `d`.
        %> - `removeUELs(u)` removes the UELs `u` for all dimensions.
        %> - `removeUELs(u, d)` removes the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function removeUELs(obj, varargin)
            % Removes UELs from the symbol
            %
            % removeUELs() removes all unused UELs for all dimensions.
            % removeUELs({}, d) removes all unused UELs for dimension(s) d.
            % removeUELs(u) removes the UELs u for all dimensions.
            % removeUELs(u, d) removes the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            uels = {};
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if ~is_pararg && index == 1
                        uels = gams.transfer.utils.parse_argument(varargin, ...
                            1, 'uels', []); % TODO
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                if isempty(uels)
                    obj.removeUnusedUniqueLabels(i);
                else
                    obj.removeUniqueLabels(i, uels);
                end
            end
        end

        %> Renames UELs in the symbol
        %>
        %> - `renameUELs(u)` renames the UELs `u` for all dimensions. `u` can be a `struct` (field
        %>   names = old UELs, field values = new UELs), `containers.Map` (keys = old UELs, values =
        %>   new UELs) or `cellstr` (full list of UELs, must have as many entries as current UELs).
        %>   The codes for renamed UELs do not change.
        %> - `renameUELs(u, d)` renames the UELs `u` for dimension(s) `d`. `u` as above.
        %> - `renameUELs(_, 'allow_merge', true)` enables support of merging one UEL into another
        %>   one (renaming a UEL to an already existing one).
        %>
        %> If an old UEL is provided in `struct` or `containers.Map` that is not present in the
        %> symbol UELs, it will be silently ignored.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function renameUELs(obj, varargin)
            % Renames UELs in the symbol
            %
            % renameUELs(u) renames the UELs u for all dimensions. u can be a struct (field names =
            % old UELs, field values = new UELs), containers.Map (keys = old UELs, values = new
            % UELs) or cellstr (full list of UELs, must have as many entries as current UELs). The
            % codes for renamed UELs do not change.
            % renameUELs(u, d) renames the UELs u for dimension(s) d. u as above.
            % renameUELs(_, 'allow_merge', true) enables support of merging one UEL into another one
            % (renaming a UEL to an already existing one).
            %
            % If an old UEL is provided in struct or containers.Map that is not present in the
            % symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            allow_merge = false;
            try
                uels = gams.transfer.utils.parse_argument(varargin, ...
                    1, 'uels', []); % TODO
                index = 2;
                is_pararg = false;
                while index < nargin
                    if strcmpi(varargin{index}, 'allow_merge')
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate(x1, x2, x3, {'logical'}, 0));
                        allow_merge = gams.transfer.utils.parse_argument(varargin, ...
                            index + 1, 'allow_merge', validate);
                        index = index + 2;
                        is_pararg = true;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if isa(uels, 'containers.Map')
                % TODO: check data type
                for i = dimensions
                    if allow_merge
                        obj.mergeUniqueLabels(i, keys(uels), values(uels));
                    else
                        obj.renameUniqueLabels(i, keys(uels), values(uels));
                    end
                end
            elseif isstruct(uels)
                oldlabels = fieldnames(uels);
                newlabels = cell(1, numel(oldlabels));
                for i = 1:numel(oldlabels)
                    % TODO: check data type
                    newlabels{i} = uels.(oldlabels{i});
                end
                for i = dimensions
                    if allow_merge
                        obj.mergeUniqueLabels(i, oldlabels, newlabels);
                    else
                        obj.renameUniqueLabels(i, oldlabels, newlabels);
                    end
                end
            elseif iscellstr(uels)
                for i = dimensions
                    oldlabels = obj.getUniqueLabels(i);
                    newlabels = uels;
                    if allow_merge
                        obj.mergeUniqueLabels(i, oldlabels, newlabels);
                    else
                        obj.renameUniqueLabels(i, oldlabels, newlabels);
                    end
                end
            end
        end

        %> Converts UELs to lower case
        %>
        %> - `lowerUELs()` converts the UELs for all dimension(s).
        %> - `lowerUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % lowerUELs() converts the UELs for all dimension(s).
            % lowerUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is not present in the
            % symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            labels = obj.getUELs(dimensions);
            if isempty(labels)
                return
            end
            rename_map = containers.Map(labels, lower(labels));
            obj.renameUELs(rename_map, dimensions, 'allow_merge', true);
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts the UELs for all dimension(s).
        %> - `upperUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not available when using the
        %> indexed mode, see \ref GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::symbol::Symbol::isValid "symbol.Symbol.isValid"
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % upperUELs() converts the UELs for all dimension(s).
            % upperUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is not present in the
            % symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not available when using
            % the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.symbol.Symbol.isValid

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index < nargin
                    if ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.parse_argument(varargin, ...
                            index, 'dimensions', []); % TODO
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            labels = obj.getUELs(dimensions);
            if isempty(labels)
                return
            end
            rename_map = containers.Map(labels, upper(labels));
            obj.renameUELs(rename_map, dimensions, 'allow_merge', true);
        end

    end

    methods (Hidden, Access = private)

        function applyDomainForwarding(obj)
            for i = 1:obj.dimension
                if obj.def_.domains{i}.forwarding
                    obj.resolveDomainViolations(i);
                end
            end
        end

    end

end
