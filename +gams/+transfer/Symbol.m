% GAMS Symbol (Set, Alias, Parameter, Variable or Equation)
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
% GAMS Symbol (Set, Alias, Parameter, Variable or Equation)
%
% Use subclasses to create a GAMS Symbol, see subclass help.
%
% See also: gams.transfer.Set, gams.transfer.Alias, gams.transfer.Parameter,
% gams.transfer.Variable, gams.transfer.Equation
%

%> @ingroup symbol
%> @brief GAMS Symbol (Set, Alias, Parameter, Variable or Equation)
%>
%> Use subclasses to create a GAMS Symbol, see subclass help.
%>
%> @see \ref gams::transfer::Set "Set", \ref gams::transfer::Alias "Alias", \ref
%> gams::transfer::Parameter "Parameter", \ref gams::transfer::Variable "Variable",
%> \ref gams::transfer::Equation "Equation"
classdef Symbol < handle


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
        %> Enables domain entries in records to be recursively added to the
        %> domains in case they are not present in the domains already
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.

        % Enables domain entries in records to be recursively added to the
        % domains in case they are not present in the domains already
        domain_forwarding
    end

    properties
        %> Storage of symbol records
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT for more information.

        % records Storage of symbol records
        records
    end

    properties (Dependent, SetAccess = private)
        %> Format in which records are stored in
        %>
        %> If records are changed, this gets reset to \ref
        %> gams::transfer::RecordsFormat::UNKNOWN "RecordsFormat.UNKNOWN". Calling
        %> \ref gams::transfer::Alias::isValid "Alias.isValid" will detect the
        %> format again.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_FORMAT for more information.

        % format Format in which records are stored in
        %
        % If records are changed, this gets reset to 'unknown'. Calling isValid()
        % will detect the format again.
        format
    end

    properties
        %> Flag to indicate modification
        %>
        %> If the symbol has been modified since last reset of flag (`false`),
        %> this flag will be `true`.

        % Flag to indicate modification
        %
        % If the symbol has been modified since last reset of flag (`false`),
        % this flag will be `true`.
        modified = true
    end

    properties (Hidden, SetAccess = private)
        id

        % container Container this symbol is stored in
        container

        % uels Unique Element Lists for each dimension in case categorical arrays are not supported
        uels
    end

    properties (Hidden)
        name_
        description_
        dimension_
        domain_
        domain_names_
        domain_type_
        domain_forwarding_
        size_
        format_
        number_records_
    end

    properties (Hidden, Constant)
        FORMAT_REEVALUATE = -2;
    end

    methods (Access = protected)

        %> Constructs a GAMS Symbol, see subclasses help
        function obj = Symbol(container, name, description, domain_size, records, domain_forwarding)
            % Constructs a GAMS Symbol, see class help

            obj.id = int32(randi(100000));

            if ~isa(container, 'gams.transfer.Container')
                error('Argument ''container'' must be of type ''gams.transfer.Container''.');
            end
            if ~(isstring(name) && numel(name) == 1) && ~ischar(name)
                error('Argument ''name'' must be of type ''char''.');
            end
            name = char(name);
            if numel(name) >= 64
                error('Symbol name too long. Name length must be smaller than 64.');
            end
            if ~(isstring(description) && numel(description) == 1) && ~ischar(description)
                error('Argument ''description'' must be of type ''char''.');
            end
            description = char(description);
            if numel(description) >= 256
                error('Symbol description too long. Name length must be smaller than 256.');
            end
            if container.indexed && ~isnumeric(domain_size)
                error('Argument ''size'' must be of type ''numeric''.')
            end
            if ~container.indexed && ~iscell(domain_size)
                error('Argument ''domain'' must be of type ''cell''.')
            end
            if ~islogical(domain_forwarding)
                error('Argument ''domain_forwarding'' must be of type ''logical''.');
            end
            if numel(domain_forwarding) == 1
                domain_forwarding = false(1, numel(domain_size)) | domain_forwarding;
            elseif ~isvector(domain_forwarding) || numel(domain_forwarding) ~= numel(domain_size)
                error('domain_forwarding must be vector of size equal to dimension');
            end

            obj.container = container;
            obj.name_ = name;
            obj.description_ = description;
            obj.number_records_ = nan;
            obj.domain_forwarding_ = domain_forwarding;

            % the following inits dimension_, domain_, domain_names_, domain_type_, uels
            if container.indexed
                obj.size = domain_size;
            else
                obj.domain = domain_size;
            end
            obj.format_ = obj.FORMAT_REEVALUATE;

            % add symbol to container
            obj.container.add(obj);

            % assign records
            if ~isempty(records)
                obj.setRecords(records);
            else
                obj.format_ = gams.transfer.RecordsFormat.EMPTY;
            end
        end

    end

    methods

        function dim = get.dimension(obj)
            dim = obj.dimension_;
        end

        function set.dimension(obj, dim)
            if ~isnumeric(dim)
                error('Dimension must be of type ''numeric''.');
            end
            if round(dim) ~= dim
                error('Dimension must be integer.');
            end
            if dim < 0 || dim > 20
                error('Dimension must be within [0,20].');
            end
            if dim == obj.dimension_
                return
            end
            if obj.container.indexed
                if dim < obj.dimension_
                    obj.size = obj.size(1:dim);
                else
                    obj.size(obj.dimension_+1:dim) = 1;
                end
            else
                if dim < obj.dimension_
                    obj.domain = obj.domain(1:dim);
                else
                    obj.domain(obj.dimension_+1:dim) = {'*'};
                end
            end
        end

        function domain = get.domain(obj)
            domain = obj.domain_;
        end

        function set.domain(obj, domain)
            if obj.container.indexed
                error('Setting symbol domain not allowed in indexed mode.');
            end

            old_domain = obj.domain_;
            gams.transfer.cmex.gt_set_sym_domain(obj, domain, obj.container.id, ...
                obj.container.features.c_prop_setget);

            % update uels
            if ~obj.container.features.categorical
                same_domain = false(1, numel(domain));
                for i = 1:min(numel(old_domain), numel(domain))
                    old_domain_i = old_domain{i};
                    if isa(old_domain_i, 'gams.transfer.Set') || ...
                        isa(old_domain_i, 'gams.transfer.Alias')
                        old_domain_i = old_domain_i.name;
                    end
                    new_domain_i = domain{i};
                    if isa(new_domain_i, 'gams.transfer.Set') || ...
                        isa(new_domain_i, 'gams.transfer.Alias')
                        new_domain_i = new_domain_i.name;
                    end
                    same_domain(i) = strcmp(old_domain_i, new_domain_i);
                end

                uels = cell(1, obj.dimension_);
                for i = 1:obj.dimension_
                    if same_domain(i)
                        uels{i} = obj.uels{i};
                    elseif (isa(obj.domain_{i}, 'gams.transfer.Set') || ...
                        isa(obj.domain_{i}, 'gams.transfer.Alias')) && ...
                        obj.domain_{i}.isValidAsDomain()
                        uels{i} = gams.transfer.UniqueElementList();
                        uels{i}.set(obj.domain_{i}.getUELs(1, 'ignore_unused', true), []);
                    else
                        uels{i} = gams.transfer.UniqueElementList();
                    end
                end
                obj.uels = uels;
            end

            % update domain forwarding
            domain_forwarding_ = false(1, obj.dimension_);
            idx = 1:min(obj.dimension_, numel(obj.domain_forwarding_));
            domain_forwarding_(idx) = obj.domain_forwarding_(idx);
            obj.domain_forwarding_ = domain_forwarding_;

            obj.modified = true;
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.domain_names_;
        end

        function domain_labels = get.domain_labels(obj)
            rec_labels = {};
            if obj.container.features.table && istable(obj.records)
                rec_labels = obj.records.Properties.VariableNames;
            elseif isstruct(obj.records)
                rec_labels = fieldnames(obj.records);
            end

            n = 0;
            for i = 1:numel(rec_labels)
                switch rec_labels{i}
                case obj.TEXT_FIELDS
                case obj.VALUE_FIELDS
                otherwise
                    n = n + 1;
                end
            end

            domain_labels = cell(1, n);
            n = 0;
            for i = 1:numel(rec_labels)
                switch rec_labels{i}
                case obj.TEXT_FIELDS
                case obj.VALUE_FIELDS
                otherwise
                    n = n + 1;
                    domain_labels{n} = rec_labels{i};
                end
            end
        end

        function set.domain_labels(obj, labels)
            switch (obj.format_)
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
                old_labels = obj.domain_labels;
                if ~iscellstr(labels)
                    error('Domain labels must be of type ''cellstr''.');
                end
                if numel(labels) ~= obj.dimension_
                    error('Domain labels must have length equal to symbol dimension.');
                end
                if numel(unique(labels)) ~= numel(labels)
                    error('Domain labels must be unique.');
                end
                labels = gams.transfer.Symbol.createDomainLabels(labels);
            otherwise
                error('Setting domain labels supported for ''table'' and ''struct'' format only.');
            end
            switch (obj.format_)
            case gams.transfer.RecordsFormat.STRUCT
                records = struct();
                fields = fieldnames(obj.records);
                for i = 1:numel(fields)
                    idx = find(strcmp(fields{i}, old_labels), 1);
                    if isempty(idx)
                        records.(fields{i}) = obj.records.(fields{i});
                    else
                        records.(labels{idx}) = obj.records.(fields{i});
                    end
                end
                obj.records = records;
            case gams.transfer.RecordsFormat.TABLE
                obj.records = renamevars(obj.records, old_labels, labels);
            end
        end

        function domain_type = get.domain_type(obj)
            domain_type = obj.domain_type_;
        end

        function domain_forwarding = get.domain_forwarding(obj)
            domain_forwarding = obj.domain_forwarding_;
        end

        function set.domain_forwarding(obj, domain_forwarding)
            if ~islogical(domain_forwarding)
                error('domain_forwarding must be logical.');
            end
            if numel(domain_forwarding) == 1
                domain_forwarding = false(1, obj.dimension_) | domain_forwarding;
            elseif ~isvector(domain_forwarding) || numel(domain_forwarding) ~= obj.dimension_
                error('domain_forwarding must be vector of size equal to dimension');
            end
            for i = 1:obj.dimension_
                if ~obj.domain_forwarding_(i) && domain_forwarding(i)
                    obj.resolveDomainViolations(i);
                end
            end
            obj.domain_forwarding_ = domain_forwarding;
            obj.modified = true;
        end

        function sizes = get.size(obj)
            sizes = obj.size_;
        end

        function set.size(obj, sizes)
            if ~obj.container.indexed
                error('Setting symbol size only allowed in indexed mode.');
            end
            if ~isnumeric(sizes)
                error('Size must be of type ''numeric''.');
            end
            for i = 1:numel(sizes)
                if isinf(sizes(i)) || isnan(sizes(i))
                    error('Size must not be inf or nan.');
                end
                if sizes(i) < 0
                    error('Size must be non-negative.');
                end
                if sizes(i) ~= round(sizes(i))
                    error('Size must be integer.');
                end
            end

            obj.size_ = sizes;
            obj.dimension_ = numel(sizes);

            % generate domain (labels)
            obj.domain_names_ = cell(1, obj.dimension_);
            obj.domain_ = cell(1, obj.dimension_);
            for i = 1:obj.dimension_
                obj.domain_{i} = sprintf('dim_%d', i);
                obj.domain_names_{i} = obj.domain_{i};
            end

            % determine domain info type
            obj.domain_type_ = 'relaxed';

            % indicate that we need to recheck symbol records
            obj.format_ = obj.FORMAT_REEVALUATE;
            obj.number_records_ = nan;

            obj.modified = true;
        end

        function form = get.format(obj)
            form = gams.transfer.RecordsFormat.int2str(obj.format_);
        end

        function set.records(obj, records)
            obj.records = records;
            obj.format_ = obj.FORMAT_REEVALUATE;
            obj.number_records_ = nan;
            obj.modified = true;
        end

        function set.modified(obj, modified)
            if ~islogical(modified)
                error('Modified must be logical.');
            end
            obj.modified = modified;
        end

    end

    methods

        %> Sets symbol records in supported format
        %>
        %> If records are not given in any of the supported formats, e.g. struct
        %> or dense_matrix, this function tries to convert the given data into
        %> one of them.
        %>
        %> Conversion is applied based on the following rules:
        %> - `string`: Interpreted as domain entry for first dimension.
        %> - `cellstr`: First dimension of `cellstr` must be equal to symbol
        %>   dimension and second will be the number of records. Row `i` is
        %>   interpreted to hold the domain entries for dimension `i`.
        %> - `numeric vector/matrix`: Interpreted to hold the `level` values (or
        %>   `value` for Parameter). Must satisfy the shape given by symbol
        %>   size since this can only be a matrix format (e.g. `dense_matrix` or
        %>   `sparse_matrix`), because domain entries are not given.
        %> - `cell`: If element is the `i`-th `cellstr`, then this is considered
        %>   to be the domain entries for the `i`-th domain. If element is the
        %>   `j`-th numeric vector/matrix, it is interpreted as the `j`-th
        %>   element of the following: `level` or `value`, `marginal`, `lower`,
        %>   `upper`, `scale`. If symbol is a \ref gams::transfer::Set "Set", the
        %>   `(dim+1)`-th `cellstr` is considered to be the set element texts.
        %> - `struct`: Fields which names match domain labels, are interpreted
        %>   as domain entries of the given domain. Other supported fields are
        %>   `level`, `value`, `marginal`, `lower`, `upper`, `scale`, `element_text`.
        %>   Unsopprted fields are ignored.
        %> - `table`: used as is.
        %>
        %> @note Instead of a `cell`, it is possible to provide the elements as
        %> separate arguments to the function.
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
            % If records are not given in any of the supported formats, e.g.
            % struct or dense_matrix, this function tries to convert the given
            % data into one of them.
            %
            % Conversion is applied based on the following rules:
            % - string: Interpreted as domain entry for first dimension.
            % - cellstr: First dimension of cellstr must be equal to symbol
            %   dimension and second will be the number of records. Row i is
            %   interpreted to hold the domain entries for dimension i.
            % - numeric vector/matrix: Interpreted to hold the level values (or
            %   values for Parameter). Must satisfy the shape given by symbol
            %   size since this can only be a matrix format (e.g. dense_matrix or
            %   sparse_matrix), because domain entries are not given.
            % - cell: If element is the i-th cellstr, then this is considered to
            %   be the domain entries for the i-th domain. If element is the j-th
            %   numeric vector/matrix, it is interpreted as the j-th element of
            %   the following: level or value, marginal, lower, upper, scale.
            %   If symbol is a Set, the (dim+1)-th cellstr is considered to be
            %   the set element texts.
            % - struct: Fields which names match domain labels, are interpreted
            %   as domain entries of the given domain. Other supported fields are
            %   level, value, marginal, lower, upper, scale, element_text. Unsopprted
            %   fields are ignored.
            % - table: used as is.
            %
            % Note: Instead of a cell, it is possible to provide the elements as
            % separate arguments to the function.
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

            obj.records = struct();
            obj.checkDomains();
            obj.updateDomainSetDependentData();

            if nargin == 2
                records = varargin{1};
            else
                records = varargin;
            end

            domain_labels = gams.transfer.Symbol.createDomainLabels(obj.domain_names);

            % collect uels
            uels = cell(1, obj.dimension_);

            % string -> recall with cell of strings
            if isstring(records) && numel(records) == 1 || ischar(records)
                if obj.container.indexed
                    error('Strings not allowed in indexed mode.');
                end
                if obj.dimension_ ~= 1
                    error('Single string as records only accepted if symbol dimension equals 1.');
                end
                uels{1} = {records};
                obj.setRecordsDomainField(domain_labels{1}, uels{1}, {records});

            % cell of strings -> domain entries
            elseif iscellstr(records)
                if obj.container.indexed
                    error('Strings not allowed in indexed mode.');
                end
                s = size(records);
                if s(1) ~= obj.dimension_
                    error('First dimension of cellstr must equal symbol dimension.');
                end
                for i = 1:obj.dimension_
                    [~,uidx,~] = unique(records(i,:), 'first');
                    uels{i} = records(i,sort(uidx));
                    obj.setRecordsDomainField(domain_labels{i}, uels{i}, records(i,:));
                end

            % numeric vector -> interpret as level values in matrix format
            elseif isnumeric(records)
                obj.setRecordsValueField(1, records, true);

            % cell -> cellstr elements to domains or set element texts and
            % numeric vector to values
            elseif iscell(records)
                n_value_fields = 0;
                n_dom_fields = 0;
                for i = 1:numel(records)
                    if isnumeric(records{i})
                        n_value_fields = n_value_fields + 1;
                        if n_value_fields > 5
                            error('Too many value fields in records.');
                        end
                        obj.setRecordsValueField(n_value_fields, records{i}, false);
                    elseif iscellstr(records{i})
                        if obj.container.indexed
                            error('Strings not allowed in indexed mode.');
                        end
                        n_dom_fields = n_dom_fields + 1;
                        if n_dom_fields == obj.dimension_ + 1 && isa(obj, 'gams.transfer.Set')
                            obj.setRecordsTextField(records{i});
                            continue
                        end
                        if n_dom_fields > obj.dimension_
                            error('More domain fields than symbol dimension.');
                        end
                        [~,uidx,~] = unique(records{i}, 'first');
                        uels{n_dom_fields} = records{i}(sort(uidx));
                        obj.setRecordsDomainField(domain_labels{n_dom_fields}, uels{n_dom_fields}, records{i});
                    else
                        error('Cell elements must be cellstr or numeric.');
                    end
                end

            % struct -> check fields for domain or value fields
            elseif isstruct(records) && numel(records) == 1
                fields = fieldnames(records);
                num_domains = 0;
                for i = 1:numel(fields)
                    field = fields{i};
                    j = find(ismember(obj.VALUE_FIELDS, field));
                    if ~isempty(j)
                        obj.setRecordsValueField(j, records.(field), false);
                        continue
                    end
                    j = find(ismember(obj.TEXT_FIELDS, field));
                    if ~isempty(j)
                        obj.setRecordsTextField(records.(field));
                        continue
                    end
                    if (num_domains < obj.dimension_)
                        num_domains = num_domains + 1;
                        rec_field = records.(field);
                        [~,uidx,~] = unique(rec_field, 'first');
                        uels{num_domains} = rec_field(sort(uidx));
                        obj.setRecordsDomainField(field, uels{num_domains}, rec_field);
                    end
                end

            % array struct
            elseif isstruct(records)
                error('Non-scalar structure arrays currently not supported.');

            % table -> just keep it
            elseif obj.container.features.table && istable(records)
                obj.records = records;

            else
                error('Unsupported records format.');
            end

            % check records format
            try
                obj.isValid(2);
            catch e
                obj.records = [];
                error(e.message);
            end

            % store uels
            % Note: we don't need to init when categorical arrays are used, they
            % are initialized already. Moreover, resolving domain violations for
            % domain_forwarding happens automatically in isValid if categorical
            % arrays are used. However, if not, UELs are set now, so we need to
            % update domains now, too.
            if ~obj.container.indexed && ~obj.container.features.categorical
                for i = 1:obj.dimension_
                    if ~isempty(uels{i})
                        obj.setUELs(uels{i}, i, 'rename', true);
                    end

                    % resolve domain violations
                    if obj.domain_forwarding_(i)
                        obj.resolveDomainViolations(i);
                    end
                end
            end
        end

        %> Transforms symbol records into given format
        %>
        %> @see \ref gams::transfer::RecordsFormat "RecordsFormat"
        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: gams.transfer.RecordsFormat

            if ~(isstring(target_format) && numel(target_format) == 1) && ~ischar(target_format);
                error('Argument ''target_format'' must be ''char''.');
            end
            target_format = gams.transfer.RecordsFormat.str2int(target_format);
            if target_format == gams.transfer.RecordsFormat.DENSE_MATRIX && ...
                obj.dimension == 0
                target_format = gams.transfer.RecordsFormat.STRUCT;
            end

            try
                def_vals = obj.default_values;
                def_values(1) = def_vals.level;
                def_values(2) = def_vals.marginal;
                def_values(3) = def_vals.lower;
                def_values(4) = def_vals.upper;
                def_values(5) = def_vals.scale;
            catch
                def_values = gams.transfer.SpecialValues.NA * ones(1, 5);
                def_values(1) = 0;
            end

            % check applicability of transform
            if ~obj.isValid()
                error('Symbol records are invalid.');
            end
            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                return
            case gams.transfer.RecordsFormat.UNKNOWN
                error('Cannot transform current format: %s', obj.format);
            end
            switch target_format
            case gams.transfer.RecordsFormat.EMPTY
                obj.records = [];
            case gams.transfer.RecordsFormat.UNKNOWN
                error('Invalid target format: %s', p.Results.target_format);
            case gams.transfer.RecordsFormat.STRUCT
                if ~obj.SUPPORTS_FORMAT_STRUCT
                    error('Cannot transform this symbol type into ''struct''.');
                end
            case gams.transfer.RecordsFormat.TABLE
                if ~obj.SUPPORTS_FORMAT_TABLE
                    error('Cannot transform this symbol type into ''table''.');
                end
            case gams.transfer.RecordsFormat.DENSE_MATRIX
                if ~obj.SUPPORTS_FORMAT_DENSE_MATRIX
                    error('Cannot transform this symbol type into ''dense_matrix''.');
                end
            case gams.transfer.RecordsFormat.SPARSE_MATRIX
                if ~obj.SUPPORTS_FORMAT_SPARSE_MATRIX
                    error('Cannot transform this symbol type into ''sparse_matrix''.');
                end
            end

            % transform between column based formats
            switch obj.format_
            case gams.transfer.RecordsFormat.STRUCT
                switch target_format
                case gams.transfer.RecordsFormat.STRUCT
                    return
                case gams.transfer.RecordsFormat.TABLE
                    obj.records = struct2table(obj.records);
                    obj.format_ = target_format;
                    return
                end
            case gams.transfer.RecordsFormat.TABLE
                switch target_format
                case gams.transfer.RecordsFormat.STRUCT
                    obj.records = table2struct(obj.records, 'ToScalar', true);
                    obj.format_ = target_format;
                    return
                case gams.transfer.RecordsFormat.TABLE
                    return
                end
            end

            % transform column based formats to matrix based formats
            switch obj.format_
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
                switch target_format
                case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                    if any(isnan(obj.size_) | isinf(obj.size_))
                        error('Matrix sizes not available. Can''t transform to matrix.');
                    end
                    if target_format == gams.transfer.RecordsFormat.SPARSE_MATRIX && obj.dimension_ > 2
                        error('Sparse matrix cannot support dimensions larger than 2.');
                    end

                    records = struct();

                    % get matrix (linear) indices
                    s = ones(1, max(2, obj.dimension_));
                    s(1:obj.dimension_) = obj.size_;
                    if obj.dimension_ > 0
                        idx_sub = cell(1, obj.dimension_);
                        domain_labels = obj.domain_labels;
                        for i = 1:obj.dimension_
                            label = domain_labels{i};
                            if obj.container.indexed
                                idx_sub{i} = obj.records.(label);
                            else
                                % get UEL mapping w.r.t. domain set
                                domain_uels = obj.domain_{i}.getUELs(1, ...
                                    uint64(obj.domain_{i}.records.(obj.domain_{i}.domain_labels{1})));
                                [~, uel_map] = ismember(obj.getUELs(i), domain_uels);
                                if any(uel_map == 0)
                                    error('Found domain violation.');
                                end
                                idx_sub{i} = uel_map(obj.records.(label));
                            end
                        end
                        idx = sub2ind(s, idx_sub{:});
                    else
                        idx = 1;
                    end

                    % store value fields
                    if obj.format_ == gams.transfer.RecordsFormat.STRUCT
                        fields = fieldnames(obj.records);
                    else
                        fields = obj.records.Properties.VariableNames;
                    end
                    for i = 1:numel(fields)
                        j = find(ismember(obj.VALUE_FIELDS, fields{i}));
                        if ~isempty(j)
                            def = def_values(j);
                        else
                            continue
                        end
                        if target_format == gams.transfer.RecordsFormat.DENSE_MATRIX
                            records.(fields{i}) = def * ones(s);
                        elseif def == 0
                            records.(fields{i}) = sparse(s(1), s(2));
                        else
                            records.(fields{i}) = sparse(def * ones(s));
                        end
                        records.(fields{i})(idx) = obj.records.(fields{i});
                    end

                    obj.records = records;
                    obj.format_ = target_format;
                    return
                end
            end

            % transform between matrix based formats
            switch obj.format_
            case gams.transfer.RecordsFormat.DENSE_MATRIX
                switch target_format
                case gams.transfer.RecordsFormat.DENSE_MATRIX
                    return
                case gams.transfer.RecordsFormat.SPARSE_MATRIX
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            obj.records.(f{1}) = sparse(obj.records.(f{1}));
                        end
                    end
                    obj.format_ = target_format;
                    return
                end
            case gams.transfer.RecordsFormat.SPARSE_MATRIX
                switch target_format
                case gams.transfer.RecordsFormat.DENSE_MATRIX
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            obj.records.(f{1}) = full(obj.records.(f{1}));
                        end
                    end
                    obj.format_ = target_format;
                    return
                case gams.transfer.RecordsFormat.SPARSE_MATRIX
                    return
                end
            end

            % transform matrix based formats to column based formats
            switch obj.format_
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                switch target_format
                case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
                    domain_labels = gams.transfer.Symbol.createDomainLabels(obj.domain_names);

                    % get all possible indices
                    s = ones(1, max(2, obj.dimension_));
                    s(1:obj.dimension_) = obj.size_;
                    nrecs = prod(s);
                    kk = cell(1, 20);
                    [kk{:}] = ind2sub(s, 1:nrecs);

                    % get sorted indices
                    k = zeros(nrecs, obj.dimension_);
                    for i = 1:obj.dimension_
                        k(:,i) = kk{i};
                    end
                    [k_sorted, k_idx_sorted] = sortrows(k, 1:obj.dimension_);

                    % get sparse indices
                    idx = false(1, nrecs);
                    for i = 1:numel(obj.VALUE_FIELDS)
                        field = obj.VALUE_FIELDS{i};
                        if ~isfield(obj.records, field)
                            continue
                        end
                        [row, col, val] = find(obj.records.(field));
                        linear_idx = sub2ind(size(obj.records.(field)), row, col);
                        idx(linear_idx(val ~= def_values(i))) = true;
                    end
                    idx = ~idx(k_idx_sorted);
                    k_sorted(idx,:) = [];
                    k_idx_sorted(idx) = [];

                    if target_format == gams.transfer.RecordsFormat.STRUCT
                        records = struct();
                    else
                        records = table();
                    end

                    % get current UELs
                    uels = cell(1, obj.dimension_);
                    if ~obj.container.indexed
                        for i = 1:obj.dimension_
                            uels{i} = obj.domain_{i}.getUELs(1, ...
                                uint64(obj.domain_{i}.records.(obj.domain_{i}.domain_labels{1})));
                        end
                    end

                    % store domain fields
                    for i = 1:obj.dimension_
                        label = domain_labels{i};
                        records.(label) = k_sorted(:,i);
                        if ~obj.container.indexed && obj.container.features.categorical
                            records.(label) = categorical(records.(label), ...
                                1:numel(uels{i}), uels{i}, 'Ordinal', true);
                        end
                    end

                    % store value fields
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            records.(f{1}) = full(obj.records.(f{1})(k_idx_sorted));
                        end
                    end

                    obj.records = records;
                    obj.format_ = target_format;

                    % store UELs
                    % In case of categorical this has already happen
                    if ~obj.container.indexed && ~obj.container.features.categorical
                        for i = 1:obj.dimension_
                            obj.setUELs(uels{i}, i, 'rename', true);
                        end
                    end

                    % remove unused UELs
                    if ~obj.container.indexed
                        obj.removeUELs();
                    end
                    return
                end
            end

            error('Transformation from ''%s'' to ''%s'' not supported.', ...
                obj.format, p.Results.target_format);
        end

        %> Checks equivalence with other symbol
        %>
        %> @note A symbol is always linked to a container. This method does not
        %> check equivalence of the linked containers.
        %>
        %> **Required Arguments:**
        %> 1. symbol (`any`):
        %>    Other symbol
        function eq = equals(obj, symbol)
            % Checks equivalence with other symbol
            %
            % Note: A symbol is always linked to a container. This method does
            % not check equivalence of the linked containers.
            %
            % Required Arguments:
            % 1. symbol (any):
            %    Other symbol

            eq = false;
            if ~isa(symbol, 'gams.transfer.Symbol')
                return
            end

            eq = isequaln(obj.records, symbol.records);
            eq = eq && isequaln(obj.name_, symbol.name_);
            eq = eq && isequaln(obj.description_, symbol.description_);
            eq = eq && isequaln(obj.dimension_, symbol.dimension_);
            eq = eq && isequaln(obj.domain_names_, symbol.domain_names_);
            eq = eq && isequaln(obj.domain_type_, symbol.domain_type_);
            eq = eq && isequaln(obj.domain_forwarding_, symbol.domain_forwarding_);
            eq = eq && isequaln(obj.size_, symbol.size_);
            eq = eq && isequaln(obj.format_, symbol.format_);
            eq = eq && isequaln(obj.number_records_, symbol.number_records_);
            if ~eq
                return
            end

            for i = 1:obj.dimension_
                if isa(obj.domain_{i}, 'gams.transfer.Set') && isa(symbol.domain_{i}, 'gams.transfer.Set')
                    eq = eq && obj.domain_{i}.equals(symbol.domain_{i});
                elseif isa(obj.domain_{i}, 'gams.transfer.Alias') && isa(symbol.domain_{i}, 'gams.transfer.Alias')
                    eq = eq && obj.domain_{i}.equals(symbol.domain_{i});
                elseif ischar(obj.domain_{i}) && ischar(symbol.domain_{i})
                    eq = eq && isequal(obj.domain_{i}, symbol.domain_{i});
                else
                    eq = false;
                end

                if ~obj.container.indexed && ~obj.container.features.categorical
                    eq = eq && obj.uels{i}.equals(symbol.uels{i});
                end
            end
        end

        %> Copies symbol to destination container
        %>
        %> Symbol domains are downgraded to `relaxed` if the destination
        %> container does not have equivalent domain sets, see also \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN.
        %>
        %> **Required Arguments:**
        %> 1. destination (`Container`):
        %>    Destination \ref gams::transfer::Container "Container"
        %>
        %> **Optional Arguments:**
        %> 2. overwrite (`bool`):
        %>    Overwrites symbol with same name in destination if `true`.
        %>    Default: `false`.
        function copy(obj, varargin)
            % Copies symbol to destination container
            %
            % Symbol domains are downgraded to relaxed if the destination
            % container does not have equivalent domain sets.
            %
            % Required Arguments:
            % 1. destination (Container):
            %    Destination container
            %
            % Optional Arguments:
            % 2. overwrite (bool):
            %    Overwrites symbol with same name in destination if true.
            %    Default: false.

            % input arguments
            p = inputParser();
            is_dest = @(x) isa(x, 'gams.transfer.Container');
            addRequired(p, 'destination', is_dest);
            addOptional(p, 'overwrite', '', @islogical);
            parse(p, varargin{:});
            destination = p.Results.destination;
            overwrite = p.Results.overwrite;

            % domain or size depends on indexed mode
            if obj.container.indexed
                if ~destination.indexed
                    error('Destination container must be indexed.');
                end
                domain_size = [];
            else
                if destination.indexed
                    error('Destination container must not be indexed.');
                end
                domain_size = {};
            end

            % create new (empty) symbol
            if isfield(destination.data, obj.name_)
                if ~overwrite
                    error('Symbol already exists in destination.');
                end
                newsym = destination.data.(obj.name_);
            else
                newsym = gams.transfer.Symbol(destination, obj.name_, '', ...
                    domain_size, [], obj.domain_forwarding_);
            end

            % copy data
            newsym.records = obj.records;
            newsym.uels = obj.uels;
            newsym.description_ = obj.description_;
            newsym.dimension_ = obj.dimension_;
            newsym.domain_ = obj.domain_;
            newsym.domain_names_ = obj.domain_names_;
            newsym.domain_type_ = obj.domain_type_;
            newsym.domain_forwarding_ = obj.domain_forwarding_;
            newsym.size_ = obj.size_;
            newsym.format_ = obj.format_;
            newsym.number_records_ = obj.number_records_;
            newsym.modified = true;

            % adapt domain sets
            for i = 1:obj.dimension_
                if ~isa(obj.domain_{i}, 'gams.transfer.Set') && ...
                    ~isa(obj.domain_{i}, 'gams.transfer.Alias')
                    continue;
                end

                if isfield(destination.data, obj.domain_{i}.name_) && ...
                    obj.domain_{i}.equals(destination.data.(obj.domain_{i}.name_))
                    newsym.domain_{i} = destination.data.(obj.domain_{i}.name_);
                else
                    newsym.domain_{i} = obj.domain_{i}.name_;
                    newsym.domain_type_ = 'relaxed';
                    newsym.size_(i) = nan;
                end
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
        function valid = isValid(obj, varargin)
            % Checks correctness of symbol
            %
            % Optional Arguments:
            % 1. verbose (logical):
            %    If true, the reason for an invalid symbol is printed
            % 2. force (logical):
            %    If true, forces reevaluation of validity (resets cache)
            %
            % See also: gams.transfer.Container/isValid

            verbose = 0;
            force = false;
            if nargin > 1 && varargin{1}
                verbose = 1;
            end
            if nargin > 1 && varargin{1} == 2
                verbose = 2;
            end
            if nargin > 2 && varargin{2}
                force = true;
            end

            % delete format information
            if force
                obj.format_ = obj.FORMAT_REEVALUATE;
            end

            valid = false;
            try
                % check if symbol is actually contained in container
                if ~isfield(obj.container.data, obj.name_)
                    obj.format_ = gams.transfer.RecordsFormat.UNKNOWN;
                    error('Symbol is not part of its linked container.');
                end

                % check domains
                obj.checkDomains();
                obj.updateDomainSetDependentData();

                % check if format is already available
                if obj.format_ > 0
                    valid = true;
                    return
                end
                obj.format_ = gams.transfer.RecordsFormat.UNKNOWN;

                % check if records are empty
                if isempty(obj.records)
                    obj.format_ = gams.transfer.RecordsFormat.EMPTY;
                    valid = true;
                    return
                end

                % check data type of records (must be table or struct) and get column names
                if obj.container.features.table && istable(obj.records)
                    labels = obj.records.Properties.VariableNames;
                elseif isstruct(obj.records)
                    labels = fieldnames(obj.records);
                else
                    error('Records must be of type ''table'' or ''struct''.');
                end

                % check if records are empty
                if isempty(labels)
                    obj.format_ = gams.transfer.RecordsFormat.EMPTY;
                    valid = true;
                    return
                end

                % check column / field names and data types
                num_domains = obj.checkRecordFields(labels);

                % check records format
                obj.format_ = obj.checkRecordFormat(labels);

                % check domain fields
                switch obj.format_
                case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
                    if num_domains ~= obj.dimension_
                        error('Incorrect number of domain fields.');
                    end
                otherwise
                    if num_domains ~= 0
                        error('Domain fields not allowed in this format.');
                    end
                end

                valid = true;
            catch e
                obj.format_ = gams.transfer.RecordsFormat.UNKNOWN;
                if verbose == 1
                    warning(e.message);
                elseif verbose == 2
                    error(e.message);
                end
            end

            % resolve domain violations
            if ~obj.container.indexed
                for i = 1:obj.dimension_
                    if obj.domain_forwarding_(i)
                        obj.resolveDomainViolations(i);
                    end
                end
            end
        end

        %> Get domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::Set "Sets" as \ref gams::transfer::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::Symbol::records "records" that is not present in
        %> the corresponding referenced domain set. Such a domain violation will
        %> lead to a GDX error when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `dom_violations = getDomainViolations` returns a list of domain
        %>   violations for all dimensions.
        %> - `dom_violations = getDomainViolations(d)` returns a list of domain
        %>   violations for dimension(s) `d`.
        %>
        %> @see \ref gams::transfer::Symbol::resolveDomainViolations
        %> "Symbol.resolveDomainViolations", \ref
        %> gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations", \ref gams::transfer::DomainViolation
        %> "DomainViolation"
        function dom_violations = getDomainViolations(obj, varargin)
            % Get domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % dom_violations = getDomainViolations returns a list of domain
            % violations for all dimension.
            % dom_violations = getDomainViolations(d) returns a list of domain
            % violations for dimension(s) d.
            %
            % See also: gams.transfer.Symbol.resolveDomainViolations,
            % gams.transfer.Container.getDomainViolations,
            % gams.transfer.DomainViolation

            if obj.container.indexed
                error('Getting domain violations not allowed in indexed mode.');
            end
            if ~obj.isValid()
                error('Symbol must be valid in order to get domain violations.');
            end

            if nargin >= 2
                dim = varargin{1};
                if ~isnumeric(dim) || ~isvector(dim) || ~all(dim == round(dim)) || ...
                    min(dim) < 1 && max(dim) > obj.dimension_
                    error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
                end
            else
                dim = 1:obj.dimension_;
            end

            dom_violations = {};
            for i = dim
                if ~isa(obj.domain_{i}, 'gams.transfer.Set') && ...
                    ~isa(obj.domain_{i}, 'gams.transfer.Alias')
                    continue;
                end

                self_uels = obj.getUELs(i, 'ignore_unused', true);
                domain_uels = obj.domain_{i}.getUELs(1, 'ignore_unused', true);
                [~, ia] = setdiff(lower(self_uels), lower(domain_uels));
                added_uels = self_uels(ia);

                if numel(added_uels) > 0
                    dom_violations{end+1} = gams.transfer.DomainViolation(obj, ...
                        i, obj.domain_{i}, added_uels);
                end
            end
        end

        %> Extends domain sets in order to resolve domain violations
        %>
        %> Domain violations occur when a symbol uses other \ref
        %> gams::transfer::Set "Sets" as \ref gams::transfer::Symbol::domain
        %> "domain"(s) -- and is thus of domain type `regular`, see \ref
        %> GAMS_TRANSFER_MATLAB_SYMBOL_DOMAIN -- and uses a domain entry in its
        %> \ref gams::transfer::Symbol::records "records" that is not present in
        %> the corresponding referenced domain set. Such a domain violation will
        %> lead to a GDX error when writing the data!
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_DOMVIOL for more information.
        %>
        %> - `resolveDomainViolations()` extends the domain sets with the
        %>   violated domain entries for all domains. Hence, the domain
        %>   violations disappear.
        %> - `resolveDomainViolations(d)` extends the domain sets with the
        %>   violated domain entries for dimension(s) `d`. Hence, the domain
        %>   violations disappear for those dimension(s).
        %>
        %> @see \ref gams::transfer::Symbol::getDomainViolations
        %> "Symbol.getDomainViolations", \ref
        %> gams::transfer::Container::resolveDomainViolations
        %> "Container.resolveDomainViolations", \ref
        %> gams::transfer::DomainViolation "DomainViolation"
        function resolveDomainViolations(obj, varargin)
            % Extends domain sets in order to resolve domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % resolveDomainViolations() extends the domain sets with the
            % violated domain entries for all dimensions. Hence, the domain
            % violations disappear.
            % resolveDomainViolations(d) extends the domain sets with the
            % violated domain entries for dimension(s) d. Hence, the domain
            % violations disappear for those dimension(s).
            %
            % See also: gams.transfer.Symbol.getDomainViolations,
            % gams.transfer.Container.resolveDomainViolations,
            % gams.transfer.DomainViolation

            dom_violations = obj.getDomainViolations(varargin{:});
            for i = 1:numel(dom_violations)
                dom_violations{i}.resolve();
            end
        end

        %> Returns the sparsity of symbol records
        %>
        %> - `s = getSparsity()` returns sparsity `s` in the symbol records.
        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % s = getSparsity() returns sparsity s in the symbol records.

            n_dense = prod(obj.size_) * numel(obj.VALUE_FIELDS);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues() / n_dense;
            end
        end

        %> Returns the largest value in records
        %>
        %> - `[v, w] = getMaxValue(varargin)` returns the largest value in
        %>   records `v` and where it is `w`. `varargin` can include a list of
        %>   value fields that should be considered: `"level"`, `"value"`,
        %>   `"lower"`, `"upper"`, `"scale"`. If none is given all available for
        %>   the symbol are considered.
        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % [v, w] = getMaxValue(varargin) returns the largest value in
            % records v and where it is w. varargin can include a list of value
            % fields that should be considered: level, value, lower, upper,
            % scale. If none is given all available for the symbol are
            % considered.

            [value, where] = gams.transfer.getMaxValue(obj, ...
                obj.container.indexed,varargin{:});
        end

        %> Returns the smallest value in records
        %>
        %> - `[v, w] = getMinValue(varargin)` returns the smallest value in
        %>   records `v` and where it is `w`. `varargin` can include a list of
        %>   value fields that should be considered: `"level"`, `"value"`,
        %>   `"lower"`, `"upper"`, `"scale"`. If none is given all available for
        %>   the symbol are considered.
        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % [v, w] = getMinValue(varargin) returns the smallest value in
            % records v and where it is w. varargin can include a list of value
            % fields that should be considered: level, value, lower, upper,
            % scale. If none is given all available for the symbol are
            % considered.

            [value, where] = gams.transfer.getMinValue(obj, ...
                obj.container.indexed, varargin{:});
        end

        %> Returns the mean value over all values in records
        %>
        %> - `v = getMinValue(varargin)` returns the mean value over all values
        %>   in records `v`. `varargin` can include a list of value fields that
        %>   should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % v = getMinValue(varargin) returns the mean value over all values
            % in records v. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.

            value = gams.transfer.getMeanValue(obj, varargin{:});
        end

        %> Returns the largest absolute value in records
        %>
        %> - `[v, w] = getMaxAbsValue(varargin)` returns the largest absolute
        %>   value in records `v` and where it is `w`. `varargin` can include a
        %>   list of value fields that should be considered: `"level"`,
        %>   `"value"`, `"lower"`, `"upper"`, `"scale"`. If none is given all
        %>   available for the symbol are considered.
        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % [v, w] = getMaxAbsValue(varargin) returns the largest absolute
            % value in records v and where it is w. varargin can include a list
            % of value fields that should be considered: level, value, lower,
            % upper, scale. If none is given all available for the symbol are
            % considered.

            [value, where] = gams.transfer.getMaxAbsValue(obj, ...
                obj.container.indexed, varargin{:});
        end

        %> Returns the number of GAMS NA values in records
        %>
        %> - `n = countNA(varargin)` returns the number of GAMS NA values `n` in
        %>   records. `varargin` can include a list of value fields that should
        %>   be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        %>
        %> @see \ref gams::transfer::SpecialValues::NA "SpecialValues.NA", \ref
        %> gams::transfer::SpecialValues::isNA "SpecialValues.isNA"
        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % n = countNA(varargin) returns the number of GAMS NA values n in
            % records. varargin can include a list of value fields that should
            % be considered: level, value, lower, upper, scale. If none is given
            % all available for the symbol are considered.
            %
            % See also: gams.transfer.SpecialValues.NA, gams.transfer.SpecialValues.isna

            n = gams.transfer.countNA(obj, varargin{:});
        end

        %> Returns the number of GAMS UNDEF values in records
        %>
        %> - `n = countUndef(varargin)` returns the number of GAMS UNDEF values
        %>   `n` in records. `varargin` can include a list of value fields that
        %>   should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % n = countUndef(varargin) returns the number of GAMS UNDEF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.

            n = gams.transfer.countUndef(obj, varargin{:});
        end

        %> Returns the number of GAMS EPS values in records
        %>
        %> - `n = countEps(varargin)` returns the number of GAMS EPS values `n` in
        %>   records. `varargin` can include a list of value fields that
        %>   should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        %>
        %> @see \ref gams::transfer::SpecialValues::EPS "SpecialValues.EPS", \ref
        %> gams::transfer::SpecialValues::isEps "SpecialValues.isEps"
        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % n = countEps(varargin) returns the number of GAMS EPS values n in
            % records. varargin can include a list of value fields that should
            % be considered: level, value, lower, upper, scale. If none is given
            % all available for the symbol are considered.
            %
            % See also: gams.transfer.SpecialValues.EPS, gams.transfer.SpecialValues.isEps

            n = gams.transfer.countEps(obj, varargin{:});
        end

        %> Returns the number of GAMS PINF (positive infinity) values in
        %> records
        %>
        %> - `n = countPosInf(varargin)` returns the number of GAMS PINF values
        %>   `n` in records. `varargin` can include a list of value fields that
        %>   should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % n = countPosInf(varargin) returns the number of GAMS PINF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.

            n = gams.transfer.countPosInf(obj, varargin{:});
        end

        %> Returns the number of GAMS MINF (negative infinity) values in
        %> records
        %>
        %> - `n = countNegInf(varargin)` returns the number of GAMS MINF values
        %>   `n` in records. `varargin` can include a list of value fields that
        %>   should be considered: `"level"`, `"value"`, `"lower"`, `"upper"`,
        %>   `"scale"`. If none is given all available for the symbol are
        %>   considered.
        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % n = countNegInf(varargin) returns the number of GAMS MINF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.

            n = gams.transfer.countNegInf(obj, varargin{:});
        end

        %> Returns the number of GDX records (not available for matrix formats)
        %>
        %> - `n = getNumberRecords()` returns the number of records that would
        %> be stored in a GDX file if this symbol would be written to GDX. For
        %> matrix formats `n` is `NaN`.
        function nrecs = getNumberRecords(obj)
            % Returns the number of GDX records (not available for matrix
            % formats)
            %
            % n = getNumberRecords() returns the number of records that would be
            % stored in a GDX file if this symbol would be written to GDX. For
            % matrix formats n is NaN.

            if ~isnan(obj.number_records_)
                nrecs = obj.number_records_;
                return
            end
            if ~obj.isValid()
                nrecs = nan;
                return
            end

            % determine number of records
            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                nrecs = 0;
            case gams.transfer.RecordsFormat.TABLE
                nrecs = height(obj.records);
            case gams.transfer.RecordsFormat.STRUCT
                nrecs = -1;
                fields = gams.transfer.Utils.getAvailableValueFields(obj);
                if numel(fields) > 0
                    nrecs = numel(obj.records.(fields{1}));
                else
                    domain_labels = obj.domain_labels;
                    for i = 1:obj.dimension_
                        label = domain_labels{i};
                        if isfield(obj.records, label)
                            nrecs = numel(obj.records.(label));
                            break;
                        end
                    end
                end
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                nrecs = nan;
            otherwise
                nrecs = nan;
            end

            % we need to convert to double to have a common data type for C
            nrecs = double(nrecs);
            obj.number_records_ = nrecs;
        end

        %> Returns the number of values stored for this symbol.
        %>
        %> - `n = getNumberValues(varargin)` is the sum of values stored of the
        %>   following fields: `"level"`, `"value"`, `"marginal"`, `"lower"`,
        %>   `"upper"`, `"scale"`. The number of values is the basis for the
        %>   sparsity computation. `varargin` can include a list of value fields
        %>   that should be considered: `"level"`, `"value"`, `"lower"`,
        %>   `"upper"`, `"scale"`. If none is given all available for the symbol
        %>   are considered.
        %>
        %> @see \ref gams::transfer::Symbol::getSparsity "Symbol.getSparsity"
        function nvals = getNumberValues(obj, varargin)
            % Returns the number of values stored for this symbol.
            %
            % n = getNumberValues(varargin) is the sum of values stored of the
            % following fields: level, value, marginal, lower, upper, scale. The
            % number of values is the basis for the sparsity computation.
            % varargin can include a list of value fields that should be
            % considered: level, value, lower, upper, scale. If none is given
            % all available for the symbol are considered.
            %
            % See also: gams.transfer.Symbol.getSparsity

            if ~obj.isValid()
                nvals = nan;
                return
            end

            % get available value fields
            values = gams.transfer.Utils.getAvailableValueFields(obj, varargin{:});
            if isempty(values)
                nvals = 0;
                return
            end

            % determine number of records
            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                nvals = 0;
            case {gams.transfer.RecordsFormat.TABLE, gams.transfer.RecordsFormat.STRUCT}
                nvals = numel(values) * obj.getNumberRecords();
            case gams.transfer.RecordsFormat.DENSE_MATRIX
                nvals = numel(values) * prod(obj.size_);
            case gams.transfer.RecordsFormat.SPARSE_MATRIX
                nvals = 0;
                for i = 1:numel(values)
                    nvals = nvals + nnz(obj.records.(values{i}));
                end
            otherwise
                nvals = nan;
            end
        end

        %> Returns the UELs used in this symbol
        %>
        %> - `u = getUELs()` returns the UELs across all dimensions.
        %> - `u = getUELs(d)` returns the UELs used in dimension(s) `d`.
        %> - `u = getUELs(d, i)` returns the UELs `u` for the given UEL codes `i`.
        %> - `u = getUELs(d, _, "ignore_unused", true)` returns only those UELs
        %>   that are actually used in the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function uels = getUELs(obj, varargin)
            % Returns the UELs used in this symbol
            %
            % u = getUELs() returns the UELs across all dimensions.
            % u = getUELs(d) returns the UELs used in dimension(s) d.
            % u = getUELs(d, i) returns the UELs u for the given UEL codes i.
            % u = getUELs(_, 'ignore_unused', true) returns only those UELs that
            % are actually used in the records.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if obj.dimension_ == 0
                uels = {};
                return;
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            is_parname = @(x) strcmpi(x, 'ignore_unused');

            % check optional arguments
            i = 1;
            dim = 1:obj.dimension_;
            codes = [];
            while true
                term = true;
                if i == 1 && nargin > 1
                    if isnumeric(dim) && isvector(dim) && all(dim == round(dim)) && ...
                        min(dim) >= 1 && max(dim) <= obj.dimension_ && ~is_parname(varargin{i})
                        dim = varargin{i};
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
                    end
                elseif i == 2 && nargin > 2
                    if isnumeric(varargin{i}) && ~is_parname(varargin{i})
                        codes = varargin{i};
                        i = i + 1;
                        term = false;
                    elseif ~is_parname(varargin{i})
                        error('Argument ''codes'' must be ''numeric''.');
                    end
                end
                if term || i > 2
                    break;
                end
            end

            % check parameter arguments
            ignore_unused = false;
            while i < nargin - 1
                if strcmpi(varargin{i}, 'ignore_unused')
                    ignore_unused = varargin{i+1};
                    if ~islogical(ignore_unused)
                        error('Argument ''ignore_unused'' must be logical.');
                    end
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 1
                error('Invalid number of arguments');
            end

            uels = {};
            domain_labels = obj.domain_labels;
            for i = dim
                switch obj.format_
                case gams.transfer.RecordsFormat.EMPTY
                    uels_i = {};
                case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                    domain_codes = uint64(obj.domain_{i}.records.(obj.domain_{i}.domain_labels{1}));
                    uels_i = obj.domain_{i}.getUELs(1, domain_codes(codes));
                case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
                    label = domain_labels{i};
                    if obj.container.features.categorical
                        if ignore_unused
                            uels_i = categories(removecats(obj.records.(label)));
                        else
                            uels_i = categories(obj.records.(label));
                        end
                    else
                        uels_i = obj.uels{i}.get();
                        if ignore_unused
                            uels_i = uels_i(unique(obj.records.(label)));
                        end
                    end

                    % filter for given codes
                    if ~isempty(codes)
                        uels_i_orig = uels_i;
                        idx = codes >= 1 & codes <= numel(uels_i_orig);
                        uels_i = cell(numel(codes), 1);
                        uels_i(idx) = uels_i_orig(codes(idx));
                        uels_i(~idx) = {'<undefined>'};
                    end
                otherwise
                    error('Symbol must be valid in order to manage UELs.');
                end
                uels = [uels; reshape(uels_i, [numel(uels_i), 1])];
            end

            if numel(dim) > 1
                [~,uidx,~] = unique(uels, 'first');
                uels = uels(sort(uidx));
            end
        end

        %> Sets UELs
        %>
        %> - `setUELs(u, d)` sets the UELs `u` for dimension(s) `d`. This may
        %>   modify UEL codes used in the property records such that records still
        %>   point to the correct UEL label when UEL codes have changed.
        %> - `setUELs(u, d, 'rename', true)` sets the UELs `u` for dimension(s)
        %>   `d`. This does not modify UEL codes used in the property records.
        %>   This can change the meaning of the records.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function setUELs(obj, uels, dim, varargin)
            % Sets UELs
            %
            % setUELs(u, d) sets the UELs u for dimension(s) d. This may modify
            % UEL codes used in the property records such that records still point
            % to the correct UEL label when UEL codes have changed.
            % setUELs(u, d, 'rename', true) sets the UELs u for dimension(s) d.
            % This does not modify UEL codes used in the property records. This
            % can change the meaning of the records.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            if nargin <= 2
                dim = 1:obj.dimension_;
            elseif ~isnumeric(dim) || ~isvector(dim) || all(dim ~= round(dim)) || min(dim) < 1 || max(dim) > obj.dimension_
                error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            % check optional arguments
            i = 1;

            % check parameter arguments
            rename = false;
            while i < nargin - 3
                if strcmpi(varargin{i}, 'rename')
                    rename = varargin{i+1};
                    if ~islogical(rename)
                        error('Argument ''rename'' must be logical.');
                    end
                else
                    error('Unknown argument name.');
                end
                i = i + 2;
            end

            % check number of arguments
            if i <= nargin - 3
                error('Invalid number of arguments');
            end

            switch obj.format_
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            domain_labels = obj.domain_labels;
            for i = dim
                label = domain_labels{i};
                if rename
                    if obj.container.features.categorical
                        obj.records.(label) = categorical(double(obj.records.(label)), ...
                            1:numel(uels), uels, 'Ordinal', true);
                    else
                        obj.uels{i}.set(uels, []);
                    end
                else
                    if obj.container.features.categorical
                        if obj.format_ == gams.transfer.RecordsFormat.EMPTY
                            warning('Cannot set UELs to empty symbol.');
                        else
                            obj.records.(label) = setcats(obj.records.(label), uels);
                        end
                    else
                        if obj.format_ == gams.transfer.RecordsFormat.EMPTY
                            obj.uels{i}.set(uels, []);
                        else
                            obj.records.(label) = obj.uels{i}.set(uels, obj.records.(label));
                        end
                    end
                end
            end

            obj.modified = true;
        end

        %> Reorders UELs
        %>
        %> Same functionality as `setUELs(uels, dim)`, but checks that no new
        %> categories are added. The meaning of records does not change.
        %>
        %> - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
        %>   appended.
        %>
        %> @see \ref gams::transfer::Symbol::setUELs "Symbol.setUELs"
        function reorderUELs(obj, uels, dim)
            % Reorders UELs
            %
            % Same functionality as setUELs(uels, dim), but checks that no new
            % categories are added. The meaning of records does not change.
            %
            % - `reorderUELs()` reorders UELs by record order for each dimension. Unused UELs are
            %   appended.
            %
            % See also: gams.transfer.Symbol.setUELs

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            if nargin == 1
                domain_labels = obj.domain_labels;
                for i = 1:obj.dimension_
                    uels = obj.getUELs(i);
                    rec_uels_ids = uint64(obj.records.(domain_labels{i}));
                    [~,uidx,~] = unique(rec_uels_ids, 'first');
                    rec_uels_ids = rec_uels_ids(sort(uidx));
                    rec_uels_ids = rec_uels_ids(rec_uels_ids ~= nan);
                    obj.setUELs(uels(rec_uels_ids), i);
                    obj.addUELs(uels, i);
                end
                return
            end
            if nargin <= 2
                dim = 1:obj.dimension_;
            elseif ~isnumeric(dim) || ~isvector(dim) || all(dim ~= round(dim)) || min(dim) < 1 || max(dim) > obj.dimension_
                error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            for i = dim
                current_uels = obj.getUELs(i);

                if numel(uels) ~= numel(current_uels)
                    error('Number of UELs %d not equal to number of current UELs %d', ...
                        numel(uels), numel(current_uels));
                end
                if ~all(ismember(current_uels, uels))
                    error('Adding new UELs not supported for reordering');
                end
            end

            obj.setUELs(uels, dim);
        end

        %> Adds UELs to the symbol
        %>
        %> - `addUELs(u)` adds the UELs `u` for all dimensions.
        %> - `addUELs(u, d)` adds the UELs `u` for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function addUELs(obj, uels, dim)
            % Adds UELs to the symbol
            %
            % addUELs(u) adds the UELs u for all dimensions.
            % addUELs(u, d) adds the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            if nargin < 3
                dim = 1:obj.dimension_;
            end
            if ~isnumeric(dim) || ~isvector(dim) || all(dim ~= round(dim)) || min(dim) < 1 || max(dim) > obj.dimension_
                error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    warning('Cannot add UELs to empty symbol.');
                    return
                end
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            domain_labels = obj.domain_labels;
            for i = dim
                label = domain_labels{i};
                if obj.container.features.categorical
                    if isordinal(obj.records.(label))
                        cats = categories(obj.records.(label));
                        if numel(cats) == 0
                            obj.records.(label) = categorical(uels, 'Ordinal', true);
                        else
                            obj.records.(label) = addcats(obj.records.(label), uels, 'After', cats{end});
                        end
                    else
                        obj.records.(label) = addcats(obj.records.(label), uels);
                    end
                else
                    obj.uels{i}.add(uels);
                end
            end

            obj.modified = true;
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
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function removeUELs(obj, uels, dim)
            % Removes UELs from the symbol
            %
            % removeUELs() removes all unused UELs for all dimensions.
            % removeUELs({}, d) removes all unused UELs for dimension(s) d.
            % removeUELs(u) removes the UELs u for all dimensions.
            % removeUELs(u, d) removes the UELs u for dimension(s) d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if obj.dimension_ == 0
                return
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            if nargin < 2
                uels = {};
            end
            if nargin < 3
                dim = 1:obj.dimension_;
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end
            if ~isnumeric(dim) || ~isvector(dim) || all(dim ~= round(dim)) || min(dim) < 1 || max(dim) > obj.dimension_
                error('Argument ''dimension'' must be integer vector with elements in [1,%d]', obj.dimension_);
            end

            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    return
                end
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            domain_labels = obj.domain_labels;
            for i = dim
                label = domain_labels{i};
                if obj.container.features.categorical
                    if isempty(uels)
                        obj.records.(label) = removecats(obj.records.(label));
                    else
                        obj.records.(label) = removecats(obj.records.(label), uels);
                    end
                else
                    if isempty(uels)
                        uels = setdiff(obj.getUELs(i), obj.getUELs(i, 'ignore_unused', true));
                    end
                    if obj.format_ == gams.transfer.RecordsFormat.EMPTY
                        obj.records.(label) = obj.uels{i}.remove(uels, []);
                    else
                        obj.records.(label) = obj.uels{i}.remove(uels, obj.records.(label));
                    end
                end
            end

            obj.modified = true;
        end

        %> Renames UELs in the symbol
        %>
        %> - `renameUELs(u)` renames the UELs `u` for all dimensions. `u` can
        %>   be a `struct` (field names = old UELs, field values = new UELs),
        %>   `containers.Map` (keys = old UELs, values = new UELs) or `cellstr`
        %>   (full list of UELs, must have as many entries as current UELs). The
        %>   codes for renamed UELs do not change.
        %> - `renameUELs(u, d)` renames the UELs `u` for dimension(s) `d`. `u`
        %>   as above.
        %> - `renameUELs(_, 'allow_merge', true)` enables support of merging one
        %>   UEL into another one (renaming a UEL to an already existing one).
        %>
        %> If an old UEL is provided in `struct` or `containers.Map` that is not
        %> present in the symbol UELs, it will be silently ignored.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function renameUELs(obj, uels, varargin)
            % Renames UELs in the symbol
            %
            % renameUELs(u) renames the UELs u for all dimensions. u can be a
            % struct (field names = old UELs, field values = new UELs),
            % containers.Map (keys = old UELs, values = new UELs) or cellstr
            % (full list of UELs, must have as many entries as current UELs).
            % The codes for renamed UELs do not change.
            % renameUELs(u, d) renames the UELs u for dimension(s) d. u as
            % above.
            % renameUELs(_, 'allow_merge', true) enables support of merging one
            % UEL into another one (renaming a UEL to an already existing one).
            %
            % If an old UEL is provided in `struct` or `containers.Map` that is
            % not present in the symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if obj.dimension_ == 0
                return
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            p = inputParser();
            is_dim = @(x) isnumeric(x) && isvector(x) && all(x == round(x)) && min(x) >= 1 && max(x) <= obj.dimension_;
            addOptional(p, 'dim', 1:obj.dimension_, is_dim);
            addParameter(p, 'allow_merge', false, @islogical);
            parse(p, varargin{:});
            dim = p.Results.dim;
            allow_merge = p.Results.allow_merge;

            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels) && ...
                ~isa(uels, 'containers.Map') && ~isstruct(uels);
                error('Argument ''uels'' must be ''char'', ''cellstr'', ''struct'' or ''containers.Map''.');
            end

            switch obj.format_
            case gams.transfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    return
                end
            case {gams.transfer.RecordsFormat.STRUCT, gams.transfer.RecordsFormat.TABLE}
            case {gams.transfer.RecordsFormat.DENSE_MATRIX, gams.transfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            domain_labels = obj.domain_labels;
            for i = dim
                label = domain_labels{i};

                if isa(uels, 'containers.Map')
                    olduels = keys(uels);
                    newuels = values(uels);
                elseif isstruct(uels)
                    olduels = fieldnames(uels);
                    newuels = cell(size(olduels));
                    for j = 1:numel(olduels)
                        newuel = uels.(olduels{j});
                        if ~(isstring(newuel) && numel(newuel) == 1) && ~ischar(newuel)
                            error('Struct elements of ''uels'' must be ''char''.');
                        end
                        newuels{j} = newuel;
                    end
                else
                    if obj.container.features.categorical
                        olduels = categories(obj.records.(label));
                        newuels = uels;
                    else
                        olduels = obj.uels{i}.get();
                        newuels = uels;
                    end
                end

                if numel(newuels) ~= numel(olduels)
                    error('Number of new UELs %d not equal to number of old UELs %d', ...
                        numel(newuels), numel(olduels));
                end

                if isa(uels, 'containers.Map') || isstruct(uels)
                    if obj.container.features.categorical
                        unavail = ~ismember(olduels, categories(obj.records.(label)));
                    else
                        unavail = ~ismember(olduels, obj.uels{i}.get());
                    end
                    olduels(unavail) = [];
                    newuels(unavail) = [];
                end

                if obj.container.features.categorical
                    if allow_merge
                        obj.records.(label) = categorical(obj.records.(label), 'Ordinal', false);
                        for j = 1:numel(newuels)
                            obj.records.(label) = mergecats(obj.records.(label), ...
                                olduels{j}, newuels{j});
                        end
                        obj.records.(label) = categorical(obj.records.(label), 'Ordinal', true);
                    else
                        obj.records.(label) = renamecats(obj.records.(label), ...
                            olduels, newuels);
                    end
                else
                    if allow_merge
                        obj.records.(label) = obj.uels{i}.rename(olduels, ...
                            newuels, obj.records.(label));
                    else
                        obj.uels{i}.rename(olduels, newuels, []);
                    end
                end
            end

            obj.modified = true;
        end

        %> Converts UELs to lower case
        %>
        %> - `lowerUELs()` converts the UELs for all dimension(s).
        %> - `lowerUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function lowerUELs(obj, dim)
            % Converts UELs to lower case
            %
            % lowerUELs() converts the UELs for all dimension(s).
            % lowerUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is
            % not present in the symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if nargin == 1
                symbols = obj.getUELs();
            else
                symbols = obj.getUELs(dim);
            end

            if isempty(symbols)
                return
            end
            rename_map = containers.Map(symbols, lower(symbols));

            if nargin == 1
                obj.renameUELs(rename_map, 'allow_merge', true);
            else
                obj.renameUELs(rename_map, dim, 'allow_merge', true);
            end
        end

        %> Converts UELs to upper case
        %>
        %> - `upperUELs()` converts the UELs for all dimension(s).
        %> - `upperUELs(d)` converts the UELs for dimension(s) `d`.
        %>
        %> See \ref GAMS_TRANSFER_MATLAB_RECORDS_UELS for more information.
        %>
        %> @note This can only be used if the symbol is valid. UELs are not
        %> available when using the indexed mode, see \ref
        %> GAMS_TRANSFER_MATLAB_CONTAINER_INDEXED.
        %>
        %> @see \ref gams::transfer::Container::indexed "Container.indexed", \ref
        %> gams::transfer::Symbol::isValid "Symbol.isValid"
        function upperUELs(obj, dim)
            % Converts UELs to upper case
            %
            % upperUELs() converts the UELs for all dimension(s).
            % upperUELs(d) converts the UELs for dimension(s) d.
            %
            % If an old UEL is provided in struct or containers.Map that is
            % not present in the symbol UELs, it will be silently ignored.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: gams.transfer.Container.indexed, gams.transfer.Symbol.isValid

            if nargin == 1
                symbols = obj.getUELs();
            else
                symbols = obj.getUELs(dim);
            end

            if isempty(symbols)
                return
            end
            rename_map = containers.Map(symbols, upper(symbols));

            if nargin == 1
                obj.renameUELs(rename_map, 'allow_merge', true);
            else
                obj.renameUELs(rename_map, dim, 'allow_merge', true);
            end
        end

    end

    methods (Hidden)

        function unsetContainer(obj)
            obj.container = gams.transfer.Container('indexed', obj.container.indexed, ...
                'gams_dir', obj.container.gams_dir, 'features', obj.container.features);
            obj.modified = true;
        end

        function unsetDomain(obj, unset_domains)
            for i = 1:obj.dimension_
                if ~isa(obj.domain{i}, 'gams.transfer.Set') && ~isa(obj.domain{i}, 'gams.transfer.Alias')
                    continue
                end
                for j = 1:numel(unset_domains)
                    if obj.domain{i}.name == unset_domains{j}.name
                        obj.domain{i} = '*';
                    end
                end
            end
        end

    end

    methods (Hidden, Static)

        function domain_labels = createDomainLabels(domain_names)
            n = numel(domain_names);
            domain_labels = domain_names;
            for i = 1:n
                if isequal(domain_labels{i}, '*')
                    domain_labels{i} = 'uni';
                end
            end
            if numel(unique(domain_labels)) ~= numel(domain_labels)
                for i = n
                    domain_labels{i} = sprintf('%s_%d', domain_labels{i}, i);
                end
            end
        end

    end

    methods (Hidden, Access = protected)

        function num_domains = checkRecordFields(obj, labels)
            num_domains = 0;
            for i = 1:numel(labels)
                field = obj.records.(labels{i});
                switch labels{i}
                case obj.TEXT_FIELDS
                    if (~obj.container.features.categorical || ~iscategorical(field)) && ~iscellstr(field)
                        error('Field ''element_text'' must be of type ''categorical'' or ''cellstr''.');
                    end
                case obj.VALUE_FIELDS
                    if ~isnumeric(field)
                        error('Field ''%s'' must be of type ''numeric''.', labels{i});
                    end
                otherwise
                    num_domains = num_domains + 1;
                    if obj.container.features.categorical && iscategorical(field)
                        if obj.container.indexed
                            error('Field ''%s'' must not be categorical in indexed mode.', labels{i})
                        end
                        if any(isundefined(field))
                            error('Field ''%s'' has undefined domain entries.', labels{i});
                        end
                    elseif isnumeric(field)
                        if ~obj.container.indexed && obj.container.features.categorical
                            error('Field ''%s'' must be categorical.', labels{i});
                        end
                        if any(isnan(field)) || any(isinf(field))
                            error('Field ''%s'' contains Inf or NaN.', labels{i});
                        end
                        if obj.container.indexed
                            maxuel = obj.size_(i);
                        else
                            maxuel = inf;
                        end
                        if min(field) < 1 || max(field) > maxuel
                            error('Field ''%s'' must have values in [%d,%d].', labels{i}, 1, maxuel);
                        end
                    elseif obj.container.indexed
                        error('Field ''%s'' must be of type ''numeric''.', labels{i});
                    else
                        error('Field ''%s'' must be of type ''categorical'' or ''numeric''.', labels{i});
                    end
                end
            end
        end

        function checkDomains(obj)
            for i = 1:obj.dimension_
                % if we don't have a set as domain, everything is allowed to be stored
                % in this column / field
                if ~isa(obj.domain_{i}, 'gams.transfer.Set') && ...
                    ~isa(obj.domain_{i}, 'gams.transfer.Alias')
                    continue
                end

                % check correct order of symbols
                if ~gams.transfer.cmex.gt_check_sym_order(obj.container.data, obj.domain_{i}.name, obj.name_);
                    error('Domain set ''%s'' is out of order: Try calling the Container method reorderSymbols().', obj.domain_{i}.name);
                end

                % check domain set
                if ~obj.domain_{i}.isValidAsDomain()
                    error('Set ''%s'' is not valid as domain.', obj.domain_{i}.name);
                end
            end
        end

        function records_format = checkRecordFormat(obj, labels)
            records_format = gams.transfer.RecordsFormat.UNKNOWN;

            % check if we have a table
            if obj.container.features.table && istable(obj.records);
                records_format = gams.transfer.RecordsFormat.TABLE;
                return
            end

            % determine shape and size of value and domain fields (columns)
            has_domains = false;
            val_fields_same_size = true;
            val_fields_same_length = true;
            dom_fields_same_length = true;
            val_fields_iscol = true;
            dom_fields_iscol = true;
            val_fields_dense = true;
            val_fields_sparse = true;
            val_nrecs = -1;
            dom_nrecs = -1;
            val_size = -1 * ones(1, obj.dimension_);
            for i = 1:numel(labels)
                field = obj.records.(labels{i});
                switch labels{i}
                case {'value', 'level', 'element_text', 'marginal', 'lower', 'upper', 'scale'}
                    if val_nrecs < 0
                        val_nrecs = numel(field);
                    elseif val_nrecs ~= numel(field)
                        val_fields_same_length = false;
                    end
                    if ~iscolumn(field)
                        val_fields_iscol = false;
                    end
                    if obj.dimension_ > 0
                        if val_size(1) < 0
                            val_size = size(field);
                        elseif ~prod(val_size == size(field))
                            val_fields_same_size = false;
                        end
                    end
                    if issparse(field)
                        val_fields_dense = false;
                    else
                        val_fields_sparse = false;
                    end
                otherwise
                    has_domains = true;
                    if dom_nrecs < 0
                        dom_nrecs = numel(field);
                    elseif dom_nrecs ~= numel(field)
                        dom_fields_same_length = false;
                    end
                    if ~iscolumn(field)
                        dom_fields_iscol = false;
                    end
                end
            end

            % value fields must all be of same shape and type
            if ~val_fields_same_size
                error('Value fields must all have the same size.');
            end
            if ~val_fields_dense && ~val_fields_sparse
                error('Value fields must either be all dense or all sparse.');
            end

            % check if matrix or struct
            if ~has_domains && prod(val_size(1:obj.dimension_) == obj.size_) && ...
                (obj.SUPPORTS_FORMAT_DENSE_MATRIX || obj.SUPPORTS_FORMAT_SPARSE_MATRIX)
                if val_fields_same_size && val_fields_same_length && val_fields_dense
                    if obj.dimension_ == 0
                        records_format = gams.transfer.RecordsFormat.STRUCT;
                    else
                        records_format = gams.transfer.RecordsFormat.DENSE_MATRIX;
                    end
                elseif val_fields_same_size && val_fields_sparse
                    records_format = gams.transfer.RecordsFormat.SPARSE_MATRIX;
                end
            elseif ~dom_fields_iscol || ~val_fields_iscol || ~val_fields_dense
                error('Fields need to match matrix format or to be dense column vectors.')
            elseif ~val_fields_same_size || ~val_fields_same_length || ~dom_fields_same_length || ...
                ~(val_nrecs == dom_nrecs || val_nrecs < 0 || dom_nrecs < 0)
                error('Fields need to match matrix format or to be of same length')
            else
                records_format = gams.transfer.RecordsFormat.STRUCT;
            end
        end

        function setRecordsDomainField(obj, label, uels, domains)
            if numel(size(domains)) > 2
                error('Domain %s has invalid shape.', label);
            end
            domains = reshape(domains, [numel(domains), 1]);

            % in indexed mode we don't need to translate strings to uel codes
            if obj.container.indexed
                obj.records.(label) = domains;
                return;
            end

            % set record values in numerical or categorical format
            if obj.container.features.categorical
                obj.records.(label) = categorical(domains, uels, 'Ordinal', true);
            else
                map = containers.Map(uels, 1:numel(uels));
                recs = zeros(numel(domains), 1);
                for i = 1:numel(domains)
                    recs(i) = map(domains{i});
                end
                obj.records.(label) = recs;
            end
        end

        function setRecordsTextField(obj, texts)
            if ~isa(obj, 'gams.transfer.Set')
                error('Element texts only allowed for Sets.');
            end
            if numel(size(texts)) > 2
                error('Element texts have invalid shape.');
            end
            texts = reshape(texts, [numel(texts), 1]);

            obj.records.element_text = texts;
            if obj.container.features.categorical
                obj.records.element_text = categorical(obj.records.element_text);
            end
        end

        function setRecordsValueField(obj, dim, values, ismatrix)
            % check correctness of format
            if ~isnumeric(values)
                error('Value field must be numeric.');
            end
            if obj.dimension_ == 0 && numel(values) ~= 1
                error('Length of numerical records must equal 1 for scalars');
            end
            if ~ismatrix && isvector(values)
                values = values(:);
            else
                size1 = size(values);
                size2 = ones(1, max(2, obj.dimension_));
                size2(1:obj.dimension_) = obj.size_;
                if any(size1 ~= size2)
                    values = values';
                    size1 = size(values);
                    if any(size1 ~= size2)
                        if ismatrix
                            error('Records size doesn''t match symbol size.');
                        end
                        values = values(:);
                    end
                end
            end

            % check value for symbol type
            if numel(obj.VALUE_FIELDS) == 0
                error('Numerical records only allowed for Parameter, Variable and Equation');
            elseif dim < 1 || dim > numel(obj.VALUE_FIELDS)
                return
            end

            % set records value
            obj.records.(obj.VALUE_FIELDS{dim}) = values;
        end

        function updateDomainSetDependentData(obj)
            for i = 1:obj.dimension_
                if ~isa(obj.domain_{i}, 'gams.transfer.Set') && ...
                    ~isa(obj.domain_{i}, 'gams.transfer.Alias')
                    continue
                end
                obj.domain_names_{i} = obj.domain_{i}.name;
                size = obj.domain_{i}.getNumberRecords();
                if size ~= obj.size_(i)
                    obj.size_(i) = size;
                    obj.modified = true;
                end
            end
        end

    end

end
