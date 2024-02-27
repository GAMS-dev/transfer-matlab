% Abstract Symbol
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
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
classdef (Abstract) Abstract < gams.transfer.utils.Handle

    %#ok<*INUSD,*STOUT,*PROP,*PROPLC,*CPROPLC>

    properties (Hidden, SetAccess = {?gams.transfer.Container, ?gams.transfer.symbol.Abstract})
        container_
        name_ = ''
        description_ = ''
        def_
        data_
        unique_labels_ = {}
        time_
        time_reset_
        cache_axes_
        cache_is_valid_
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

    properties (Dependent, Hidden)
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
        %> gams::transfer::symbol::Abstract::isValid "symbol.Abstract.isValid" will detect the
        %> format again.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT for more information.

        % format Format in which records are stored in
        %
        % If records are changed, this gets reset to 'unknown'. Calling isValid() will detect the
        % format again.
        format
    end

    properties (Abstract, SetAccess = private)
        %> (Abstract) Flag if symbol can be used in indexed mode

        % indexed (Abstract) Flag if symbol can be used in indexed mode
        indexed
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

        function set.container(obj, container)
            gams.transfer.utils.Validator('container', 1, container).type('gams.transfer.Container', true);
            obj.container_ = container;
            obj.def_.switchContainer(container);
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function name = get.name(obj)
            name = obj.name_;
        end

        function set.name(obj, name)
            name = gams.transfer.utils.Validator('name', 1, name).symbolName().value;
            obj.container.renameSymbol(obj.name, name);
            obj.time_.reset();
        end

        function description = get.description(obj)
            description = obj.description_;
        end

        function set.description(obj, description)
            obj.description_ = gams.transfer.utils.Validator('description', 1, description).symbolDescription().value;
            obj.time_.reset();
        end

        function def = get.def(obj)
            def = obj.def_;
        end

        function data = get.data(obj)
            data = obj.data_;
        end

        function set.data(obj, data)
            gams.transfer.utils.Validator('data', 1, data).type('gams.transfer.symbol.data.Abstract');
            obj.data_ = data;
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function unique_labels = get.unique_labels(obj)
            dimension = numel(obj.unique_labels_);
            symbol_dimension = obj.dimension;
            if symbol_dimension < dimension
                obj.unique_labels_ = obj.unique_labels_(1:symbol_dimension);
            elseif symbol_dimension > dimension
                obj.unique_labels_(dimension+1:symbol_dimension) = {[]};
            end
            unique_labels = obj.unique_labels_;
        end

        function set.unique_labels(obj, unique_labels)
            dimension = numel(obj.unique_labels_);
            symbol_dimension = obj.dimension;
            if symbol_dimension < dimension
                obj.unique_labels_ = obj.unique_labels_(1:symbol_dimension);
            elseif symbol_dimension > dimension
                obj.unique_labels_(dimension+1:symbol_dimension) = {[]};
            end
            gams.transfer.utils.Validator('unique_labels', 1, unique_labels)...
                .cellof('gams.transfer.unique_labels.Abstract', true).numel(symbol_dimension);
            obj.unique_labels_ = unique_labels;
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function dimension = get.dimension(obj)
            dimension = numel(obj.def_.domains_);
        end

        function set.dimension(obj, dimension)
            gams.transfer.utils.Validator('dimension', 1, dimension).integer().scalar()...
                .inInterval(0, gams.transfer.Constants.MAX_DIMENSION);
            symbol_dimension = obj.dimension;
            if dimension < symbol_dimension
                obj.def_.domains = obj.def_.domains(1:dimension);
            elseif dimension > symbol_dimension
                obj.def_.domains(symbol_dimension+1:dimension) = ...
                    {gams.transfer.symbol.domain.Relaxed(gams.transfer.Constants.UNIVERSE_NAME)};
            end
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function size = get.size(obj)
            size = obj.getDomainAxes_().size();
        end

        function set.size(obj, size)
            gams.transfer.utils.Validator('size', 1, size).integer().noNanInf().min(0);
            domains = cell(1, numel(size));
            for i = 1:numel(size)
                domains{i} = ['dim_', int2str(i)];
            end
            obj.domain = domains;
            for i = 1:numel(size)
                obj.unique_labels{i} = gams.transfer.unique_labels.Range('', 1, 1, size(i));
                obj.def_.domains{i}.index_type = gams.transfer.symbol.domain.IndexType.integer();
            end
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
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

        function set.domain(obj, domain)
            obj.def_.domains = domain;
            obj.applyDomainForwarding();
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.def_.getDomainLabels();
        end

        function set.domain_labels(obj, domain_labels)
            labels = obj.domain_labels;
            obj.def_.setDomainLabels(domain_labels);
            obj.data_.renameLabels_(labels, obj.domain_labels);
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function domain_names = get.domain_names(obj)
            domains = obj.def_.domains;
            domain_names = cell(1, numel(domains));
            for i = 1:numel(domains)
                domain_names{i} = domains{i}.name;
            end
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

        function set.domain_forwarding(obj, domain_forwarding)
            dim = obj.dimension;
            if numel(domain_forwarding) == 1
                domain_forwarding = false(1, dim) | domain_forwarding;
            end
            for i = 1:dim
                obj.def_.domains{i}.forwarding = domain_forwarding(i);
            end
            obj.applyDomainForwarding();
            obj.time_.reset();
        end

        function records = get.records(obj)
            records = obj.data_.records;
        end

        function set.records(obj, records)
            obj.data_.records = records;
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function format = get.format(obj)
            format = obj.data_.name;
        end

        function set.format(obj, format)
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
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function modified = get.modified(obj)
            modified = isempty(obj.time_reset_) || obj.updatedAfter_(obj.time_reset_);
        end

        function set.modified(obj, modified)
            gams.transfer.utils.Validator('modified', 1, modified).type('logical').scalar();
            if modified
                obj.time_reset_ = [];
            else
                obj.time_reset_ = gams.transfer.utils.Time();
                while (obj.updatedAfter_(obj.time_reset_))
                    obj.time_reset_.reset();
                end
            end
        end

    end

    methods (Hidden)

        function obj = Abstract()
            obj.time_ = gams.transfer.utils.Time();
            obj.cache_axes_ = gams.transfer.utils.Cache();
            obj.cache_is_valid_ = gams.transfer.utils.Cache();
        end

    end

    methods

        %> (Abstract) Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to `relaxed` if the destination container does not have
        %> equivalent domain sets, see also \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination \ref gams::transfer::Container "Container"
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`. Default: `false`.
        function symbol = copy(obj, varargin)
            % (Abstract) Copies symbol to destination container
            %
            % Symbol domains are downgraded to relaxed if the destination container does not have
            % equivalent domain sets.
            %
            % Required Arguments:
            % 1. destination (Container):
            %    Destination container
            %
            % Optional Arguments:
            % 2. overwrite (bool):
            %    Overwrites symbol with same name in destination if true. Default: false.

            st = dbstack;
			error('Method ''%s'' not supported by ''%s''.', st(1).name, class(obj));
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
        %>   `lower`, `upper`, `scale`. If symbol is a \ref gams::transfer::symbol::Set "Set", the
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

            if nargin == 2
                records = varargin{1};
            else
                records = varargin;
            end

            if gams.transfer.Constants.SUPPORTS_TABLE && istable(records)
                records = gams.transfer.symbol.data.Table(records);
            end
            if isa(records, 'gams.transfer.symbol.data.Abstract')
                values = records.availableValues_('Abstract', obj.def_.values);
                status = records.isValid_(obj.getAxes_(), values);
                if status.flag ~= gams.transfer.utils.Status.OK
                    error(status.message);
                end
                obj.data_ = records;

                obj.applyDomainForwarding();

                obj.time_.reset();
                obj.cache_is_valid_.reset();
                obj.cache_axes_.reset();
                return
            end

            % reset current records in order to avoid using categoricals as unique_labels
            obj.data = gams.transfer.symbol.data.Struct();

            domains = {};
            values = {};
            new_records = struct();
            dim = obj.dimension;

            % string -> recall with cell of strings
            if isstring(records) && numel(records) == 1 || ischar(records)
                if dim ~= 1
                    error('Single string as records only accepted if symbol dimension equals 1.');
                end
                domain = obj.def_.domains{1};
                new_records.(domain.label) = {records};
                domains{end+1} = domain;

            % cell of strings -> domain entries
            elseif iscellstr(records)
                s = size(records);
                if s(1) ~= dim
                    error('First dimension of cellstr must equal symbol dimension.');
                end
                domains = cell(1, dim);
                for i = 1:dim
                    domain = obj.def_.domains{i};
                    new_records.(domain.label) = records(i,:);
                    domains{i} = domain;
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
                        if n_domains > dim
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
                    value = obj.def_.findValue(fields{i});
                    if ~isempty(value)
                        new_records.(value.label) = records.(fields{i});
                        values{end+1} = value;
                        continue;
                    end

                    domain = obj.def_.findDomain(fields{i});
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
                switch domains{i}.index_type.value
                case gams.transfer.symbol.domain.IndexType.CATEGORICAL
                    new_records.(domains{i}.label) = gams.transfer.unique_labels.Abstract ...
                        .createCategoricalIndexFromCellstrAndLabels_(...
                        new_records.(domains{i}.label), unique_labels);
                case gams.transfer.symbol.domain.IndexType.INTEGER
                    new_records.(domains{i}.label) = gams.transfer.unique_labels.Abstract ...
                        .createIntegerIndexFromCellstrAndLabels_(...
                        new_records.(domains{i}.label), unique_labels);
                    obj.unique_labels{i} = gams.transfer.unique_labels.OrderedLabelSet(unique_labels);
                otherwise
                    error('Unsupported domain index type: %s', axis.domain.index_type.select);
                end
            end

            % create categoricals for element_text
            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                for i = 1:numel(values)
                    if isa(values{i}, 'gams.transfer.symbol.value.String')
                        new_records.(values{i}.label) = categorical(new_records.(values{i}.label));
                    end
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
                symbol_size = obj.getAxes_().matrixSize();
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

            old_data = obj.data_;
            old_unique_labels = obj.unique_labels_;
            obj.data_ = data;

            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
            obj.time_.reset();

            % check records format
            status = obj.data_.isValid_(obj.getAxes_(), values);
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
            obj.time_.reset();
            if status.flag ~= gams.transfer.utils.Status.OK
                obj.unique_labels_ = old_unique_labels;
                obj.data_ = old_data;
                error(status.message);
            end

            obj.applyDomainForwarding();
        end

        %> Transforms symbol records into given format
        %>
        %> **Required Arguments:**
        %> 1. target_format (`string`):
        %>    Name of format to transform data to (table, struct, dense_matrix or sparse_matrix).
        %>
        %> If the target format is a matrix format, the UELs will be updated to the ones from the
        %> domain plus the added ones. Thus, if there are no domain violations, the matrix size
        %> will equal the size defined by the symbol domain.
        %>
        %> After the transformation UELs will be trimmed which means that unused UELs will be
        %> removed if possible.
        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % Required Arguments:
            % 1. target_format (string):
            %    Name of format to transform data to (table, struct, dense_matrix or sparse_matrix).
            %
            % If the target format is a matrix format, the UELs will be updated to the ones from the
            % domain plus the added ones. Thus, if there are no domain violations, the matrix size
            % will equal the size defined by the symbol domain.
            %
            % After the transformation UELs will be trimmed which means that unused UELs will be
            % removed if possible.

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

            % update axes to domain axes
            if isa(obj.data_, 'gams.transfer.symbol.data.Tabular') && ...
                isa(data, 'gams.transfer.symbol.data.Matrix')
                for i = 1:obj.dimension
                    obj.updateAxisLabelsFromDomain_(i);
                end
            end

            obj.data_.transformTo_(obj.getAxes_(), obj.getValues_(), data);
            obj.data = data;

            for i = 1:obj.dimension
                obj.trimAxisLabels_(i);
            end
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
            % See also: gams.transfer.Container.isValid

            verbose = 0;
            force = false;
            if nargin > 1
                verbose = max(0, min(2, varargin{1}));
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            if force || ~obj.cache_is_valid_.holdsValue() || obj.updatedAfter_(obj.cache_is_valid_.time)
                status = gams.transfer.utils.Status.ok();
                obj.applyDomainForwarding();
                if ~isa(obj.container_, 'gams.transfer.Container') || ...
                    ~obj.container_.hasSymbols(obj.name_) || obj.container_.getSymbols(obj.name_) ~= obj
                    status = gams.transfer.utils.Status('Symbol is not contained in its linked container.');
                end
                if status.flag == gams.transfer.utils.Status.OK
                    status = obj.def_.isValid();
                end
                if status.flag == gams.transfer.utils.Status.OK
                    status = obj.data_.isValid_(obj.getAxes_(), obj.getValues_());
                end
                obj.cache_is_valid_.value = status;
            else
                status = obj.cache_is_valid_.value;
            end

            switch status.flag
            case gams.transfer.utils.Status.FAIL
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
            case gams.transfer.utils.Status.OK
                flag = true;
            case gams.transfer.utils.Status.UNKNOWN
                error('Internal error');
            end
        end

        %> Get domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref gams::transfer::symbol::Set "Sets"
        %> as \ref gams::transfer::symbol::Abstract::domain "domain"(s) -- and is thus of domain
        %> type `regular`, see \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in
        %> its \ref gams::transfer::symbol::Abstract::records "records" that is not present in the
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
        %> @see \ref gams::transfer::symbol::Abstract::resolveDomainViolations
        %> "symbol.Abstract.resolveDomainViolations", \ref
        %> gams::transfer::Container::getDomainViolations "Container.getDomainViolations", \ref
        %> gams::transfer::symbol::domain::Violation "symbol.domain.Violation"
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
            % See also: gams.transfer.symbol.Abstract.resolveDomainViolations,
            % gams.transfer.Container.getDomainViolations, gams.transfer.symbol.domain.Violation

            dim = obj.dimension;
            if nargin >= 2
                gams.transfer.utils.Validator('dimensions', 1, varargin{1}).integer().vector() ...
                    .maxnumel(dim).inInterval(1, dim);
                dimensions = varargin{1};
            else
                dimensions = 1:dim;
            end

            domain_violations = {};
            for i = dimensions
                if ~obj.hasDomainAxis_(i)
                    continue
                end

                labels = obj.getUsedAxisLabels_(i);
                domain_labels = obj.getDomainAxisLabels_(i);
                [~, ia] = setdiff(lower(labels), lower(domain_labels));
                added_labels = labels(ia);

                if numel(added_labels) > 0
                    domain_violations{end+1} = gams.transfer.symbol.domain.Violation(obj, i, ...
                        obj.def_.domains{i}, added_labels);
                end
            end

        end

        %> Extends domain sets in order to resolve domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref gams::transfer::symbol::Set "Sets"
        %> as \ref gams::transfer::symbol::Abstract::domain "domain"(s) -- and is thus of domain
        %> type `regular`, see \ref GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in
        %> its \ref gams::transfer::symbol::Abstract::records "records" that is not present in the
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
        %> @see \ref gams::transfer::symbol::Abstract::getDomainViolations
        %> "symbol.Abstract.getDomainViolations", \ref
        %> gams::transfer::Container::resolveDomainViolations "Container.resolveDomainViolations",
        %> \ref gams::transfer::symbol::domain::Violation "symbol.domain.Violation"
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
            % See also: gams.transfer.symbol.Abstract.getDomainViolations,
            % gams.transfer.Container.resolveDomainViolations, gams.transfer.symbol.domain.Violation

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

            sparsity = obj.data_.getSparsity_(obj.getDomainAxes_(), obj.getNumericValues_());
        end

    end

    methods (Hidden, Access = protected)

        function values = parseValues(obj, varargin)

            % parse input arguments
            has_values = false;
            index = 1;
            while index <= numel(varargin)
                if strcmpi(varargin{index}, 'values')
                    index = index + 1;
                    gams.transfer.utils.Validator.minargin(numel(varargin), index);
                    values = gams.transfer.utils.Validator('values', index, varargin{index}).cellstr().value;
                    has_values = true;
                    index = index + 1;
                else
                    error('Invalid argument at position %d', index);
                end
            end
            if has_values
                for i = 1:numel(values)
                    values{i} = obj.def_.findValue(values{i});
                    if isempty(values{i})
                        error('Argument ''values'' contains invalid value: %s.', values{i});
                    end
                end
            else
                values = obj.def_.values;
            end
            values = obj.data_.availableValues_('Numeric', values);
        end

    end

    methods

        %> Returns the largest value in records
        %>
        %> - `[v, w] = getMaxValue(varargin)` returns the largest value in records `v` and where it
        %>   is `w`.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % - [v, w] = getMaxValue(varargin) returns the largest value in records v and where it
            %   is w.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end

            if nargout >= 2
                [value, where] = obj.data_.getMaxValue_(obj.getAxes_(), values);
            else
                value = obj.data_.getMaxValue_(obj.getAxes_(), values);
            end
        end

        %> Returns the smallest value in records
        %>
        %> - `[v, w] = getMinValue(varargin)` returns the smallest value in records `v` and where it
        %>   is `w`.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % - [v, w] = getMinValue(varargin) returns the smallest value in records v and where it
            %   is w.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            if nargout >= 2
                [value, where] = obj.data_.getMinValue_(obj.getAxes_(), values);
            else
                value = obj.data_.getMinValue_(obj.getAxes_(), values);
            end
        end

        %> Returns the mean value over all values in records
        %>
        %> - `[v, w] = getMeanValue(varargin)` returns the mean value over all values in records `v`
        %>   and where it is `w`.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % - [v, w] = getMeanValue(varargin) returns the mean value over all values in records
            %   v and where it is w.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            value = obj.data_.getMeanValue_(obj.getAxes_(), values);
        end

        %> Returns the largest absolute value in records
        %>
        %> - `[v, w] = getMaxAbsValue(varargin)` returns the largest absolute value in records `v`
        %>   and where it is `w`.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % - [v, w] = getMaxAbsValue(varargin) returns the largest absolute value in records v
            %   and where it is w.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            if nargout >= 2
                [value, where] = obj.data_.getMaxAbsValue_(obj.getAxes_(), values);
            else
                value = obj.data_.getMaxAbsValue_(obj.getAxes_(), values);
            end
        end

        %> Returns the number of GAMS NA values in records
        %>
        %> - `n = countNA(varargin)` returns the number of GAMS NA values `n` in records.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::SpecialValues::NA "SpecialValues.NA", \ref
        %> gams::transfer::SpecialValues::isNA "SpecialValues.isNA"
        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % n = countNA(varargin) returns the number of GAMS NA values n in records.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.SpecialValues.NA, gams.transfer.SpecialValues.isNA

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            n = obj.data_.countNA_(values);
        end

        %> Returns the number of GAMS UNDEF values in records
        %>
        %> - `n = countUndef(varargin)` returns the number of GAMS UNDEF values `n` in records.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::SpecialValues::UNDEF "SpecialValues.UNDEF", \ref
        %> gams::transfer::SpecialValues::isUndef "SpecialValues.isUndef"
        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % n = countUndef(varargin) returns the number of GAMS UNDEF values n in records.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.SpecialValues.UNDEF, gams.transfer.SpecialValues.isUndef

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            n = obj.data_.countUndef_(values);
        end

        %> Returns the number of GAMS EPS values in records
        %>
        %> - `n = countEps(varargin)` returns the number of GAMS EPS values `n` in records.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::SpecialValues::EPS "SpecialValues.EPS", \ref
        %> gams::transfer::SpecialValues::isEps "SpecialValues.isEps"
        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % n = countEps(varargin) returns the number of GAMS EPS values n in records.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.SpecialValues.EPS, gams.transfer.SpecialValues.isEps

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            n = obj.data_.countEps_(values);
        end

        %> Returns the number of GAMS PINF (positive infinity) values in
        %> records
        %>
        %> - `n = countPosInf(varargin)` returns the number of GAMS PINF values `n` in records.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::SpecialValues::POSINF "SpecialValues.POSINF", \ref
        %> gams::transfer::SpecialValues::isPosInf "SpecialValues.isPosInf"
        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % n = countPosInf(varargin) returns the number of GAMS PINF values n in records.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.SpecialValues.POSINF, gams.transfer.SpecialValues.isPosInf

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            n = obj.data_.countPosInf_(values);
        end

        %> Returns the number of GAMS MINF (negative infinity) values in
        %> records
        %>
        %> - `n = countNegInf(varargin)` returns the number of GAMS MINF values `n` in records.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::SpecialValues::NEGINF "SpecialValues.NEGINF", \ref
        %> gams::transfer::SpecialValues::isNegInf "SpecialValues.isNegInf"
        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % n = countNegInf(varargin) returns the number of GAMS MINF values n in records.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.SpecialValues.NEGINF, gams.transfer.SpecialValues.isNegInf

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            n = obj.data_.countNegInf_(values);
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

            nrecs = obj.data_.getNumberRecords_(obj.getAxes_(), obj.getValues_());
        end

        %> Returns the number of values stored for this symbol.
        %>
        %> - `n = getNumberValues(varargin)` is the sum of values stored of the following fields:
        %>   `"level"`, `"value"`, `"marginal"`, `"lower"`, `"upper"`, `"scale"`. The number of
        %>   values is the basis for the sparsity computation.
        %>
        %> **Parameter Arguments:**
        %> - values (`cell`):
        %>   List of value fields that should be considered, e.g. `{'level', 'marginal', 'lower',
        %>   'upper', 'scale'}`. Default: All value fields of symbol.
        %>
        %> @see \ref gams::transfer::symbol::Abstract::getSparsity "symbol.Abstract.getSparsity"
        function nvals = getNumberValues(obj, varargin)
            % Returns the number of values stored for this symbol.
            %
            % n = getNumberValues(varargin) is the sum of values stored of the following fields:
            % level, value, marginal, lower, upper, scale. The number of values is the basis for the
            % sparsity computation.
            %
            % Parameter Arguments:
            % - values (cell):
            %   List of value fields that should be considered, e.g. {'level', 'marginal', 'lower',
            %   'upper', 'scale'}. Default: All value fields of symbol.
            %
            % See also: gams.transfer.symbol.Abstract.getSparsity

            try
                values = obj.parseValues(varargin{:});
            catch e
                error(e.message);
            end
            nvals = obj.data_.getNumberValues_(obj.getAxes_(), values);
        end

    end

    methods (Hidden, Access = {?gams.transfer.symbol.Abstract, ?gams.transfer.Container, ...
        ?gams.transfer.unique_labels.DomainSet, ?gams.transfer.alias.Set, ...
        ?gams.transfer.symbol.domain.Abstract})

        function [flag, time] = updatedAfter_(obj, time)
            flag = true;
            if time <= obj.time_
                time = obj.time_;
                return
            end
            [flag_, time_] = obj.data_.updatedAfter_(time);
            if flag_
                obj.time_.set(time_);
                time = time_;
                return
            end
            [flag_, time_] = obj.def_.updatedAfter_(time);
            if flag_
                obj.time_.set(time_);
                time = time_;
                return
            end
            for i = 1:obj.dimension
                if isempty(obj.unique_labels{i})
                    continue;
                end
                [flag_, time_] = obj.unique_labels{i}.updatedAfter_(time);
                if flag_
                    obj.time_.set(time_);
                    time = time_;
                    return
                end
            end
            flag = false;
        end

        function copyFrom_(obj, symbol)
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
            obj.time_.reset();
            obj.cache_is_valid_.reset();
            obj.cache_axes_.reset();
        end

        function domain = getDomain_(obj, dimension)
            domain = obj.def_.domains{dimension};
        end

        function domains = getDomains_(obj)
            domains = obj.def_.domains;
        end

        function values = getValues_(obj)
            values = obj.data_.availableValues_('Abstract', obj.def_.values);
        end

        function values = getNumericValues_(obj)
            values = obj.data_.availableValues_('Numeric', obj.def_.values);
        end

        function [flag, domain_flag] = isDomainAxis_(obj, dimension)
            domain = obj.def_.domains{dimension};
            domain_flag = domain.hasUniqueLabels();
            if ~isempty(obj.unique_labels{dimension}) || ...
                ~isempty(obj.data_) && obj.data_.hasUniqueLabels_(domain)
                flag = false;
            else
                flag = domain_flag;
            end
        end

        function flag = hasDomainAxis_(obj, dimension)
            flag = obj.def_.domains{dimension}.hasUniqueLabels();
        end

        function unique_labels = getDomainAxisUniqueLabels_(obj, dimension)
            domain = obj.def_.domains{dimension};
            unique_labels = domain.getUniqueLabels();
            if isempty(unique_labels)
                unique_labels = obj.getAxisUniqueLabels_(dimension);
            end
        end

        function axis = getDomainAxis_(obj, dimension)
            domain = obj.def_.domains{dimension};
            unique_labels = domain.getUniqueLabels();
            if ~isempty(unique_labels)
                axis = gams.transfer.symbol.unique_labels.Axis(domain, unique_labels);
            else
                axis = obj.getAxis_(dimension);
            end
        end

        function axes = getDomainAxes_(obj)
            dim = obj.dimension;
            axes = cell(1, dim);
            for i = 1:dim
                axes{i} = obj.getDomainAxis_(i);
            end
            axes = gams.transfer.symbol.unique_labels.Axes(axes);
        end

        function labels = getDomainAxisLabels_(obj, dimension)
            labels = obj.getDomainAxisUniqueLabels_(dimension).get();
        end

        function unique_labels = getAxisUniqueLabels_(obj, dimension)
            unique_labels = obj.getAxes_().axis(dimension).unique_labels_;
        end

        function unique_labels = getInitAxisUniqueLabels_(obj, dimension)
            unique_labels = obj.getAxes_().axis(dimension).unique_labels_;
            if obj.isDomainAxis_(dimension)
                obj.unique_labels{dimension} = gams.transfer.unique_labels.OrderedLabelSet(unique_labels.get());
                unique_labels = obj.unique_labels{dimension};
            end
        end

        function axis = getAxis_(obj, dimension)
            axis = obj.getAxes_().axis(dimension);
        end

        function axes = getAxes_(obj)
            if obj.cache_axes_.holdsValue() && ~obj.updatedAfter_(obj.cache_axes_.time)
                axes = obj.cache_axes_.value;
                return
            end

            dim = obj.dimension;
            axes = cell(1, dim);
            for i = 1:dim
                domain = obj.def_.domains{i};
                if ~isempty(obj.data_)
                    data_unique_labels = obj.data_.getUniqueLabels_(domain);
                else
                    data_unique_labels = [];
                end
                domain_unique_labels = domain.getUniqueLabels();
                if ~isempty(data_unique_labels)
                    unique_labels = data_unique_labels;
                elseif ~isempty(obj.unique_labels{i})
                    unique_labels = obj.unique_labels{i};
                elseif ~isempty(domain_unique_labels)
                    unique_labels = domain_unique_labels;
                else
                    unique_labels = gams.transfer.Constants.EMPTY_UNIQUE_LABELS;
                end
                axes{i} = gams.transfer.symbol.unique_labels.Axis(domain, unique_labels);
            end
            axes = gams.transfer.symbol.unique_labels.Axes(axes);
            obj.cache_axes_.value = axes;
        end

        function labels = getAxisLabels_(obj, dimension)
            labels = obj.getAxisUniqueLabels_(dimension).get();
        end

        function indices = getUsedAxisIndices_(obj, dimension)
            indices = obj.data_.usedUniqueLabels_(obj.getAxes_(), obj.getValues_(), dimension);
        end

        function labels = getUsedAxisLabels_(obj, dimension)
            labels = obj.getAxisUniqueLabels_(dimension).getAt_(obj.getUsedAxisIndices_(dimension));
        end

        function labels = getAxisLabelsAt_(obj, dimension, indices)
            labels = obj.getAxisUniqueLabels_(dimension).getAt_(indices);
        end

        function [flag, indices] = findAxisLabels_(obj, dimension, labels)
            [flag, indices] = obj.getAxisUniqueLabels_(dimension).find_(labels);
        end

        function clearAxisLabels_(obj, dimension)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            unique_labels.clear();
        end

        function addAxisLabels_(obj, dimension, labels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.Empty')
                obj.unique_labels{dimension} = gams.transfer.unique_labels.OrderedLabelSet(labels);
                return
            end
            unique_labels.add_(labels);
        end

        function setAxisLabels_(obj, dimension, labels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.Empty')
                obj.unique_labels{dimension} = gams.transfer.unique_labels.OrderedLabelSet(labels);
                return
            end
            unique_labels.set_(labels);
        end

        function updateAxisLabels_(obj, dimension, labels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.Empty')
                obj.unique_labels{dimension} = gams.transfer.unique_labels.OrderedLabelSet(labels);
                return
            end
            if isa(unique_labels, 'gams.transfer.unique_labels.CategoricalColumn')
                assert(unique_labels.data == obj.data_);
                assert(unique_labels.domain == obj.def_.domains{dimension});
                unique_labels.update_(labels);
                return
            end
            [~, indices] = unique_labels.update_(labels);
            obj.data_.permuteAxis_(obj.getAxes_(), obj.getValues_(), dimension, indices);
        end

        function updateAxisLabelsFromDomain_(obj, dimension)
            [axis_flag, domain_axis_flag] = obj.isDomainAxis_(dimension);
            if axis_flag || ~domain_axis_flag
                return
            end
            domain_labels = obj.getDomainAxisLabels_(dimension);
            labels = obj.getAxisLabels_(dimension);
            [added_flag, added_indices] = obj.findAxisLabels_(dimension, domain_labels);
            labels(added_indices(added_flag)) = [];
            obj.updateAxisLabels_(dimension, horzcat(domain_labels, labels));
        end

        function reorderAxisLabelsByUsage_(obj, dimension)
            labels = obj.getAxisLabels_(dimension);
            used_indices = obj.getUsedAxisIndices_(dimension);
            unused_flag = true(size(labels));
            unused_flag(used_indices) = false;
            obj.updateAxisLabels_(dimension, horzcat(labels(used_indices), labels(unused_flag)));
        end

        function removeAxisLabels_(obj, dimension, labels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.CategoricalColumn')
                assert(unique_labels.data == obj.data_);
                assert(unique_labels.domain == obj.def_.domains{dimension});
                unique_labels.remove_(labels);
                return
            end
            [~, indices] = unique_labels.remove_(labels);
            obj.data_.permuteAxis_(obj.getAxes_(), obj.getValues_(), dimension, indices);
        end

        function removeUnusedAxisLabels_(obj, dimension)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.CategoricalColumn')
                assert(unique_labels.data == obj.data_);
                assert(unique_labels.domain == obj.def_.domains{dimension});
                unique_labels.removeUnused();
                return
            end
            unused = 1:unique_labels.count();
            unused(obj.getUsedAxisIndices_(dimension)) = [];
            obj.removeAxisLabels_(dimension, obj.getAxisLabelsAt_(dimension, unused));
        end

        function trimAxisLabels_(obj, dimension)
            if obj.isDomainAxis_(dimension)
                return
            end
            try
                obj.removeUnusedAxisLabels_(dimension);
            catch e
                if isempty(strfind(e.message, 'not supported'))
                    rethrow(e)
                end
            end
        end

        function renameAxisLabels_(obj, dimension, oldlabels, newlabels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            unique_labels.rename_(oldlabels, newlabels);
        end

        function mergeAxisLabels_(obj, dimension, oldlabels, newlabels)
            unique_labels = obj.getInitAxisUniqueLabels_(dimension);
            if isa(unique_labels, 'gams.transfer.unique_labels.CategoricalColumn')
                assert(unique_labels.data == obj.data_);
                assert(unique_labels.domain == obj.def_.domains{dimension});
                unique_labels.merge_(oldlabels, newlabels);
                return
            end
            [~, indices] = unique_labels.merge_(oldlabels, newlabels);
            obj.data_.permuteAxis_(obj.getAxes_(), obj.getValues_(), dimension, indices);
        end

    end

    methods (Hidden)

        function labels = getAxisLabels(obj, dimension)
            labels = obj.getAxisUniqueLabels_(dimension).get();
        end

        function labels = getAxisLength(obj, dimension)
            labels = obj.getAxisUniqueLabels_(dimension).count();
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
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in this symbol
            %
            % u = getUELs() returns the UELs across all dimensions.
            % u = getUELs(d) returns the UELs used in dimension(s) d.
            % u = getUELs(d, i) returns the UELs u for the given UEL codes i.
            % u = getUELs(_, 'ignore_unused', true) returns only those UELs that are actually used
            % in the records.

            % parse input arguments
            dimensions = 1:obj.dimension;
            codes = [];
            ignore_unused = false;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'ignore_unused')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        ignore_unused = gams.transfer.utils.Validator('ignore_unused', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        codes = gams.transfer.utils.Validator('codes', index, ...
                            varargin{index}).integer().value;
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
                    uels_i = obj.getUsedAxisLabels_(i);
                elseif isempty(codes)
                    uels_i = obj.getAxisLabels_(i);
                elseif ignore_unused
                    uels_i = gams.transfer.utils.filter_unique_labels(obj.getUsedAxisLabels_(i), codes);
                else
                    uels_i = obj.getAxisLabelsAt_(i, codes);
                end
                uels = [uels; reshape(uels_i, [], 1)];
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
        function setUELs(obj, varargin)
            % Sets UELs
            %
            % setUELs(u, d) sets the UELs u for dimension(s) d. This may modify UEL codes used in
            % the property records such that records still point to the correct UEL label when UEL
            % codes have changed.
            % setUELs(u, d, 'rename', true) sets the UELs u for dimension(s) d. This does not modify
            % UEL codes used in the property records. This can change the meaning of the records.

            % parse input arguments
            dimensions = 1:obj.dimension;
            rename = false;
            try
                gams.transfer.utils.Validator.minargin(numel(varargin), 1);
                if iscell(varargin{1})
                    uels = gams.transfer.utils.Validator('uels', 1, varargin{1}).cellstr().value;
                else
                    uels = {gams.transfer.utils.Validator('uels', 1, varargin{1}).types({'string', 'char'}).value};
                end
                index = 2;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'rename')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        rename = gams.transfer.utils.Validator('rename', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
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
                    obj.setAxisLabels_(i, uels);
                else
                    obj.updateAxisLabels_(i, uels);
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
        %> @see \ref gams::transfer::symbol::Abstract::setUELs "symbol.Abstract.setUELs"
        function reorderUELs(obj, varargin)
            % Reorders UELs
            %
            % Same functionality as setUELs(uels, dim), but checks that no new categories are added.
            % The meaning of records does not change.
            %
            % - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
            %   appended.
            %
            % See also: gams.transfer.symbol.Abstract.setUELs

            % parse input arguments
            dimensions = 1:obj.dimension;
            uels = {};
            rename = false;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'rename')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        rename = gams.transfer.utils.Validator('rename', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 1
                        uels = gams.transfer.utils.Validator('uels', index, varargin{index})...
                            .cellstr().value;
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
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
                    obj.reorderAxisLabelsByUsage_(i);
                end
                return
            end

            for i = dimensions
                labels = obj.getAxisLabels_(i);
                if numel(uels) ~= numel(labels)
                    error('Number of UELs %d not equal to number of current UELs %d', ...
                        numel(uels), numel(labels));
                end
                if ~all(ismember(labels, uels))
                    error('Adding new UELs not supported for reordering');
                end
                if rename
                    obj.setAxisLabels_(i, uels);
                else
                    obj.updateAxisLabels_(i, uels);
                end
            end
        end

        %> Adds UELs to the symbol
        %>
        %> - `addUELs(u)` adds the UELs `u` for all dimensions.
        %> - `addUELs(u, d)` adds the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        function addUELs(obj, varargin)
            % Adds UELs to the symbol
            %
            % addUELs(u) adds the UELs u for all dimensions.
            % addUELs(u, d) adds the UELs u for dimension(s) d.

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                gams.transfer.utils.Validator.minargin(numel(varargin), 1);
                if iscell(varargin{1})
                    uels = gams.transfer.utils.Validator('uels', 1, varargin{1}).cellstr().value;
                else
                    uels = {gams.transfer.utils.Validator('uels', 1, varargin{1}).types({'string', 'char'}).value};
                end
                index = 2;
                is_pararg = false;
                while index <= numel(varargin)
                    if ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                obj.addAxisLabels_(i, uels);
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
        function removeUELs(obj, varargin)
            % Removes UELs from the symbol
            %
            % removeUELs() removes all unused UELs for all dimensions.
            % removeUELs({}, d) removes all unused UELs for dimension(s) d.
            % removeUELs(u) removes the UELs u for all dimensions.
            % removeUELs(u, d) removes the UELs u for dimension(s) d.

            % parse input arguments
            uels = {};
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if ~is_pararg && index == 1
                        if iscell(varargin{index})
                            uels = gams.transfer.utils.Validator('uels', index, varargin{index}).cellstr().value;
                        else
                            uels = {gams.transfer.utils.Validator('uels', index, varargin{index}).types({'string', 'char'}).value};
                        end
                        index = index + 1;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
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
                    obj.removeUnusedAxisLabels_(i);
                else
                    obj.removeAxisLabels_(i, uels);
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

            % parse input arguments
            dimensions = 1:obj.dimension;
            allow_merge = false;
            try
                gams.transfer.utils.Validator.minargin(numel(varargin), 1);
                uels = gams.transfer.utils.Validator('uels', 1, varargin{1}).types({'cell', 'struct', 'containers.Map'}).value;
                index = 2;
                is_pararg = false;
                while index <= numel(varargin)
                    if strcmpi(varargin{index}, 'allow_merge')
                        index = index + 1;
                        gams.transfer.utils.Validator.minargin(numel(varargin), index);
                        allow_merge = gams.transfer.utils.Validator('allow_merge', index, ...
                            varargin{index}).type('logical').scalar().value;
                        index = index + 1;
                        is_pararg = true;
                    elseif ~is_pararg && index == 2
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            if isa(uels, 'containers.Map')
                oldlabels = gams.transfer.utils.Validator('keys(uels)', 1, keys(uels)).cellstr().value;
                for i = dimensions
                    if allow_merge
                        obj.mergeAxisLabels_(i, oldlabels, values(uels));
                    else
                        obj.renameAxisLabels_(i, oldlabels, values(uels));
                    end
                end
            elseif isstruct(uels)
                oldlabels = gams.transfer.utils.Validator('fieldnames(uels)', 1, fieldnames(uels)).cellstr().value;
                newlabels = cell(1, numel(oldlabels));
                for i = 1:numel(oldlabels)
                    newlabels{i} = uels.(oldlabels{i});
                end
                for i = dimensions
                    if allow_merge
                        obj.mergeAxisLabels_(i, oldlabels, newlabels);
                    else
                        obj.renameAxisLabels_(i, oldlabels, newlabels);
                    end
                end
            elseif iscell(uels)
                uels = gams.transfer.utils.Validator('uels', 1, uels).string2char().cellstr().value;
                for i = dimensions
                    if allow_merge
                        obj.mergeAxisLabels_(i, obj.getAxisLabels_(i), uels);
                    else
                        obj.renameAxisLabels_(i, obj.getAxisLabels_(i), uels);
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
        function lowerUELs(obj, varargin)
            % Converts UELs to lower case
            %
            % lowerUELs() converts the UELs for all dimension(s).
            % lowerUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is not present in the
            % symbol UELs, it will be silently ignored.

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index < numel(varargin)
                    if ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                labels = obj.getAxisLabels_(i);
                if isempty(labels)
                    continue
                end
                obj.mergeAxisLabels_(i, labels, lower(labels));
            end
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts the UELs for all dimension(s).
        %> - `upperUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        function upperUELs(obj, varargin)
            % Converts UELs to upper case
            %
            % upperUELs() converts the UELs for all dimension(s).
            % upperUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is not present in the
            % symbol UELs, it will be silently ignored.

            % parse input arguments
            dimensions = 1:obj.dimension;
            try
                index = 1;
                is_pararg = false;
                while index <= numel(varargin)
                    if ~is_pararg && index == 1
                        dimensions = gams.transfer.utils.Validator('dimensions', index, ...
                            varargin{index}).integer().vector().maxnumel(obj.dimension)...
                            .inInterval(1, obj.dimension).value;
                        index = index + 1;
                    else
                        error('Invalid argument at position %d', index);
                    end
                end
            catch e
                error(e.message);
            end

            for i = dimensions
                labels = obj.getAxisLabels_(i);
                if isempty(labels)
                    continue
                end
                obj.mergeAxisLabels_(i, labels, upper(labels));
            end
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
