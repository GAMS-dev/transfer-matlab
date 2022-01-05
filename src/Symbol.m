classdef Symbol < handle
    % This class represents a GAMS Symbol (Set, Alias, Parameter, Variable or
    % Equation).
    %
    % Use subclasses to create a GAMS Symbol, see subclass help.
    %
    % See also: GAMSTransfer.Set, GAMSTransfer.Alias, GAMSTransfer.Parameter,
    % GAMSTransfer.Variable, GAMSTransfer.Equation
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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

    properties (Dependent)
        % dimension Dimension of symbol (in [0,20])
        dimension

        % size Shape of symbol (length == dimension)
        size

        % domain Domain of symbol (length == dimension)
        domain
    end

    properties (Dependent, SetAccess = private)
        % domain_names Domain names of symbol
        domain_names

        % domain_labels Expected domain labels in records
        domain_labels

        % domain_type Specifies if domains are stored 'relaxed' or 'regular'
        domain_type
    end

    properties (Dependent)
        domain_forwarding
    end

    properties
        % records Storage of symbol records
        records
    end

    properties (Dependent, SetAccess = private)
        % format Format in which records are stored in
        %
        % If records are changed, this gets reset to 'unknown'. Calling isValid()
        % will detect the format again.
        format
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
        domain_labels_
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

        function obj = Symbol(container, name, description, domain_size, records, domain_forwarding)
            % Constructs a GAMS Symbol, see class help.
            %

            obj.id = int32(randi(100000));

            if ~isa(container, 'GAMSTransfer.Container')
                error('Argument ''container'' must be of type ''GAMSTransfer.Container''.');
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

            obj.container = container;
            obj.name_ = name;
            obj.description_ = description;
            obj.domain_forwarding_ = domain_forwarding;
            obj.number_records_ = nan;

            % the following inits dimension_, domain_, domain_names_, domain_labels_,
            % domain_type_, uels
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

            GAMSTransfer.gt_cmex_set_sym_domain(obj, domain, obj.container.id, ...
                obj.container.features.c_prop_setget);
            obj.domain_ = domain;

            % update uels
            if ~obj.container.features.categorical
                uels = struct();
                for i = 1:obj.dimension_
                    label = obj.domain_labels_{i};
                    if isfield(obj.uels, label)
                        uels.(label) = obj.uels.(label);
                    elseif (isa(obj.domain_{i}, 'GAMSTransfer.Set') || ...
                        isa(obj.domain_{i}, 'GAMSTransfer.Alias')) && ...
                        obj.domain_{i}.isValidAsDomain()
                        uels.(label) = GAMSTransfer.UniqueElementList();
                        uels.(label).set(obj.domain_{i}.getUELs(1, 'ignore_unused', true), []);
                    else
                        uels.(label) = GAMSTransfer.UniqueElementList();
                    end
                end
                obj.uels = uels;
            end
        end

        function domain_names = get.domain_names(obj)
            domain_names = obj.domain_names_;
        end

        function domain_labels = get.domain_labels(obj)
            domain_labels = obj.domain_labels_;
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
            if ~obj.domain_forwarding_ && domain_forwarding
                obj.resolveDomainViolations();
            end
            obj.domain_forwarding_ = domain_forwarding;
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
                    error('Size must not be non-negative.');
                end
                if sizes(i) ~= round(sizes(i))
                    error('Size must be integer.');
                end
            end

            obj.size_ = sizes;
            obj.dimension_ = numel(sizes);

            % generate domain (labels)
            obj.domain_names_ = cell(1, obj.dimension_);
            obj.domain_labels_ = cell(1, obj.dimension_);
            obj.domain_ = cell(1, obj.dimension_);
            for i = 1:obj.dimension_
                obj.domain_{i} = sprintf('dim_%d', i);
                obj.domain_names_{i} = obj.domain_{i};
                obj.domain_labels_{i} = obj.domain_{i};
            end

            % determine domain info type
            obj.domain_type_ = 'relaxed';

            % indicate that we need to recheck symbol records
            obj.format_ = obj.FORMAT_REEVALUATE;
            obj.number_records_ = nan;
        end

        function form = get.format(obj)
            form = GAMSTransfer.RecordsFormat.int2str(obj.format_);
        end

        function set.records(obj, records)
            obj.records = records;
            obj.format_ = obj.FORMAT_REEVALUATE;
            obj.number_records_ = nan;
        end

    end

    methods

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
            %   level, value, marginal, lower, upper, scale, text. Unsopprted
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
            % See also: GAMSTransfer.RecordsFormat
            %

            obj.records = struct();
            obj.checkDomains();
            obj.updateDomainSetDependentData();

            if nargin == 2
                records = varargin{1};
            else
                records = varargin;
            end

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
                obj.setRecordsDomainField(1, uels{1}, {records});

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
                    obj.setRecordsDomainField(i, uels{i}, records(i,:));
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
                        if n_dom_fields == obj.dimension_ + 1 && isa(obj, 'GAMSTransfer.Set')
                            obj.setRecordsTextField(records{i});
                            continue
                        end
                        if n_dom_fields > obj.dimension_
                            error('More domain fields than symbol dimension.');
                        end
                        [~,uidx,~] = unique(records{i}, 'first');
                        uels{n_dom_fields} = records{i}(sort(uidx));
                        obj.setRecordsDomainField(n_dom_fields, uels{n_dom_fields}, records{i});
                    else
                        error('Cell elements must be cellstr or numeric.');
                    end
                end

            % struct -> check fields for domain or value fields
            elseif isstruct(records) && numel(records) == 1
                fields = fieldnames(records);
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
                    for j = 1:obj.dimension_
                        if strcmp(field, obj.domain_labels_{j}) || ...
                            (isa(obj.domain_{j}, 'GAMSTransfer.Set') || ...
                            isa(obj.domain_{j}, 'GAMSTransfer.Alias')) && ...
                            strcmp(field, obj.domain_{j}.name)
                            rec_field = records.(field);
                            [~,uidx,~] = unique(rec_field, 'first');
                            uels{j} = rec_field(sort(uidx));
                            obj.setRecordsDomainField(j, uels{j}, rec_field);
                            break;
                        end
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
                        obj.initUELs(i, uels{i});
                    end
                end

                % resolve domain violations
                if obj.domain_forwarding_
                    obj.resolveDomainViolations();
                end
            end
        end

        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: GAMSTransfer.RecordsFormat
            %

            if ~(isstring(target_format) && numel(target_format) == 1) && ~ischar(target_format);
                error('Argument ''target_format'' must be ''char''.');
            end
            target_format = GAMSTransfer.RecordsFormat.str2int(target_format);
            if target_format == GAMSTransfer.RecordsFormat.DENSE_MATRIX && ...
                obj.dimension == 0
                target_format = GAMSTransfer.RecordsFormat.STRUCT;
            end

            try
                def_vals = obj.default_values;
                def_values(1) = def_vals.level;
                def_values(2) = def_vals.marginal;
                def_values(3) = def_vals.lower;
                def_values(4) = def_vals.upper;
                def_values(5) = def_vals.scale;
            catch
                def_values = GAMSTransfer.SpecialValues.NA * ones(1, 5);
                def_values(1) = 0;
            end

            % check applicability of transform
            if ~obj.isValid()
                error('Symbol records are invalid.');
            end
            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                return
            case GAMSTransfer.RecordsFormat.UNKNOWN
                error('Cannot transform current format: %s', obj.format);
            end
            switch target_format
            case GAMSTransfer.RecordsFormat.EMPTY
                obj.records = [];
            case GAMSTransfer.RecordsFormat.UNKNOWN
                error('Invalid target format: %s', p.Results.target_format);
            case GAMSTransfer.RecordsFormat.STRUCT
                if ~obj.SUPPORTS_FORMAT_STRUCT
                    error('Cannot transform this symbol type into ''struct''.');
                end
            case GAMSTransfer.RecordsFormat.TABLE
                if ~obj.SUPPORTS_FORMAT_TABLE
                    error('Cannot transform this symbol type into ''table''.');
                end
            case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                if ~obj.SUPPORTS_FORMAT_DENSE_MATRIX
                    error('Cannot transform this symbol type into ''dense_matrix''.');
                end
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                if ~obj.SUPPORTS_FORMAT_SPARSE_MATRIX
                    error('Cannot transform this symbol type into ''sparse_matrix''.');
                end
            end

            % transform between column based formats
            switch obj.format_
            case GAMSTransfer.RecordsFormat.STRUCT
                switch target_format
                case GAMSTransfer.RecordsFormat.STRUCT
                    return
                case GAMSTransfer.RecordsFormat.TABLE
                    obj.records = struct2table(obj.records);
                    obj.format_ = target_format;
                    return
                end
            case GAMSTransfer.RecordsFormat.TABLE
                switch target_format
                case GAMSTransfer.RecordsFormat.STRUCT
                    obj.records = table2struct(obj.records, 'ToScalar', true);
                    obj.format_ = target_format;
                    return
                case GAMSTransfer.RecordsFormat.TABLE
                    return
                end
            end

            % transform column based formats to matrix based formats
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
                switch target_format
                case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                    if any(isnan(obj.size_) | isinf(obj.size_))
                        error('Matrix sizes not available. Can''t transform to matrix.');
                    end
                    if target_format == GAMSTransfer.RecordsFormat.SPARSE_MATRIX && obj.dimension_ > 2
                        error('Sparse matrix cannot support dimensions larger than 2.');
                    end

                    records = struct();

                    % get matrix (linear) indices
                    s = ones(1, max(2, obj.dimension_));
                    s(1:obj.dimension_) = obj.size_;
                    if obj.dimension_ > 0
                        idx_sub = cell(1, obj.dimension_);
                        for i = 1:obj.dimension_
                            if obj.container.indexed
                                idx_sub{i} = obj.records.(obj.domain_labels_{i});
                            else
                                % get UEL mapping w.r.t. domain set
                                [~, uel_map] = ismember(obj.getUELs(i), obj.domain_{i}.getUELs(1));
                                if any(uel_map == 0)
                                    error('Found domain violation.');
                                end
                                idx_sub{i} = uel_map(obj.records.(obj.domain_labels_{i}));
                            end
                        end
                        idx = sub2ind(s, idx_sub{:});
                    else
                        idx = 1;
                    end

                    % store value fields
                    if obj.format_ == GAMSTransfer.RecordsFormat.STRUCT
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
                        if target_format == GAMSTransfer.RecordsFormat.DENSE_MATRIX
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
            case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                switch target_format
                case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                    return
                case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            obj.records.(f{1}) = sparse(obj.records.(f{1}));
                        end
                    end
                    obj.format_ = target_format;
                    return
                end
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                switch target_format
                case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            obj.records.(f{1}) = full(obj.records.(f{1}));
                        end
                    end
                    obj.format_ = target_format;
                    return
                case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                    return
                end
            end

            % transform matrix based formats to column based formats
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                switch target_format
                case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
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

                    if target_format == GAMSTransfer.RecordsFormat.STRUCT
                        records = struct();
                    else
                        records = table();
                    end

                    % store domain fields
                    for i = 1:obj.dimension_
                        label = obj.domain_labels_{i};
                        records.(label) = k_sorted(:,i);
                        if ~obj.container.indexed && obj.container.features.categorical
                            uels = obj.domain_{i}.getUELs(1, 'ignore_unused', true);
                            records.(label) = categorical(records.(label), ...
                                1:numel(uels), uels);
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
                            obj.initUELs(i, obj.domain_{i}.getUELs(1, 'ignore_unused', true));
                        end
                    end

                    % remove unused UELs
                    if ~obj.container.indexed
                        for i = 1:obj.dimension_
                            obj.removeUELs(i);
                        end
                    end
                    return
                end
            end

            error('Transformation from ''%s'' to ''%s'' not supported.', ...
                obj.format, p.Results.target_format);
        end

        function valid = isValid(obj, varargin)
            % Checks correctness of symbol
            %
            % Optional Arguments:
            % 1. verbose: logical
            %    If true, the reason for an invalid symbol is printed
            % 2. force: logical
            %    If true, forces reevaluation of validity (resets cache)
            %
            % See also: GAMSTransfer.Container/isValid
            %

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
                    obj.format_ = GAMSTransfer.RecordsFormat.UNKNOWN;
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
                obj.format_ = GAMSTransfer.RecordsFormat.UNKNOWN;

                % check if records are empty
                if isempty(obj.records)
                    obj.format_ = GAMSTransfer.RecordsFormat.EMPTY;
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
                    obj.format_ = GAMSTransfer.RecordsFormat.EMPTY;
                    valid = true;
                    return
                end

                % check column / field names and data types
                has_domain_label = obj.checkRecordFields(labels);

                % check records format
                obj.format_ = obj.checkRecordFormat(labels);

                % check domain fields
                switch obj.format_
                case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
                    % check if domain fields are given
                    for i = 1:obj.dimension_
                        if ~has_domain_label(i)
                            error('Domain ''%s'' is missing.', obj.domain_labels_{i});
                        end
                    end
                end

                valid = true;
            catch e
                obj.format_ = GAMSTransfer.RecordsFormat.UNKNOWN;
                if verbose == 1
                    warning(e.message);
                elseif verbose == 2
                    error(e.message);
                end
            end

            % resolve domain violations
            if obj.domain_forwarding_
                obj.resolveDomainViolations();
            end
        end

        function dom_violations = getDomainViolations(obj)
            % Get domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % dom_violations = getDomainViolations returns a list of domain
            % violations.
            %
            % See also: GAMSTransfer.Symbol.resovleDomainViolations,
            % GAMSTransfer.Container.getDomainViolations, GAMSTransfer.DomainViolation
            %

            if obj.container.indexed
                error('Getting domain violations not allowed in indexed mode.');
            end
            if ~obj.isValid()
                error('Symbol must be valid in order to get domain violations.');
            end

            dom_violations = {};
            for i = 1:obj.dimension_
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set') && ...
                    ~isa(obj.domain_{i}, 'GAMSTransfer.Alias')
                    continue;
                end

                added_uels = setdiff(obj.getUELs(i, 'ignore_unused', true), ...
                    obj.domain_{i}.getUELs(1, 'ignore_unused', true));
                if numel(added_uels) > 0
                    dom_violations{end+1} = GAMSTransfer.DomainViolation(obj, ...
                        i, obj.domain_{i}, added_uels);
                end
            end
        end

        function resolveDomainViolations(obj)
            % Extends domain sets in order to resolve domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as
            % domain(s) and a domain entry in its records that is not present in
            % the corresponding set. Such a domain violation will lead to a GDX
            % error when writing the data.
            %
            % resolveDomainViolations() extends the domain sets with the
            % violated domain entries. Hence, the domain violations disappear.
            %
            % See also: GAMSTransfer.Symbol.getDomainViolations,
            % GAMSTransfer.Container.resovleDomainViolations, GAMSTransfer.DomainViolation
            %

            dom_violations = obj.getDomainViolations();
            for i = 1:numel(dom_violations)
                dom_violations{i}.resolve();
            end
        end

        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % s = getSparsity() returns sparsity s in the symbol records.
            %

            n_dense = prod(obj.size_) * numel(obj.VALUE_FIELDS);
            if n_dense == 0
                sparsity = NaN;
            else
                sparsity = 1 - obj.getNumberValues() / n_dense;
            end
        end

        function card = getCardenality(obj)
            % Returns the cardenality of symbol records
            %
            % s = getCardenality() returns cardenality s (maximum number of
            % values) in the symbol records.
            %

            card = prod(obj.size_);
        end

        function [value, where] = getMaxValue(obj, varargin)
            % Returns the largest value in records
            %
            % [v, w] = getMaxValue(varargin) returns the largest value in
            % records v and where it is w. varargin can include a list of value
            % fields that should be considered: level, value, lower, upper,
            % scale. If none is given all available for the symbol are
            % considered.
            %

            value = nan;
            where = {};

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % compute values
            idx = nan;
            for i = 1:numel(values)
                [value_, idx_] = max(obj.records.(values{i})(:));
                if ~isempty(value_) && (isnan(value) || value < value_)
                    value = value_;
                    idx = idx_;
                end
            end

            % translate linear index to domain entry
            if ~isnan(idx)
                where = obj.getInd2Domain(idx);
            end
        end

        function [value, where] = getMinValue(obj, varargin)
            % Returns the smallest value in records
            %
            % [v, w] = getMinValue(varargin) returns the smallest value in
            % records v and where it is w. varargin can include a list of value
            % fields that should be considered: level, value, lower, upper,
            % scale. If none is given all available for the symbol are
            % considered.
            %

            value = nan;
            where = {};

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % compute values
            idx = nan;
            for i = 1:numel(values)
                [value_, idx_] = min(obj.records.(values{i})(:));
                if ~isempty(value_) && (isnan(value) || value > value_)
                    value = value_;
                    idx = idx_;
                end
            end

            % translate linear index to domain entry
            if ~isnan(idx)
                where = obj.getInd2Domain(idx);
            end
        end

        function value = getMeanValue(obj, varargin)
            % Returns the mean value over all values in records
            %
            % v = getMinValue(varargin) returns the mean value over all values
            % in records v. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.
            %

            value = nan;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % compute values
            n = 0;
            for i = 1:numel(values)
                value_ = sum(obj.records.(values{i})(:));
                if isnan(value)
                    value = value_;
                else
                    value = value + value_;
                end
                n = n + obj.getNumberRecords();
            end
            if n == 0
                value = nan;
                return
            end
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                value = value / prod(obj.size_);
            otherwise
                value = value / n;
            end
        end

        function [value, where] = getMaxAbsValue(obj, varargin)
            % Returns the largest absolute value in records
            %
            % [v, w] = getMaxAbsValue(varargin) returns the largest absolute
            % value in records v and where it is w. varargin can include a list
            % of value fields that should be considered: level, value, lower,
            % upper, scale. If none is given all available for the symbol are
            % considered.
            %

            value = nan;
            where = {};

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % compute values
            idx = nan;
            for i = 1:numel(values)
                [value_, idx_] = max(abs(obj.records.(values{i})(:)));
                if isnan(value) || value < value_
                    value = value_;
                    idx = idx_;
                end
            end

            % translate linear index to domain entry
            if ~isnan(idx)
                where = obj.getInd2Domain(idx);
            end
        end

        function n = countNA(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % n = countNA(varargin) returns the number of GAMS NA values n in
            % records. varargin can include a list of value fields that should
            % be considered: level, value, lower, upper, scale. If none is given
            % all available for the symbol are considered.
            %
            % See also: GAMSTransfer.SpecialValues.NA, GAMSTransfer.SpecialValues.isna
            %

            n = 0;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % get count
            for i = 1:numel(values)
                n = n + sum(GAMSTransfer.SpecialValues.isNA(obj.records.(values{i})(:)));
            end
        end

        function n = countUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % n = countUndef(varargin) returns the number of GAMS UNDEF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.
            %

            n = 0;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % get count
            for i = 1:numel(values)
                n = n + sum(GAMSTransfer.SpecialValues.isUndef(obj.records.(values{i})(:)));
            end
        end

        function n = countEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % n = countEps(varargin) returns the number of GAMS EPS values n in
            % records. varargin can include a list of value fields that should
            % be considered: level, value, lower, upper, scale. If none is given
            % all available for the symbol are considered.
            %
            % See also: GAMSTransfer.SpecialValues.EPS, GAMSTransfer.SpecialValues.iseps
            %

            n = 0;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % get count
            for i = 1:numel(values)
                n = n + sum(GAMSTransfer.SpecialValues.isEps(obj.records.(values{i})(:)));
            end
        end

        function n = countPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % n = countPosInf(varargin) returns the number of GAMS PINF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.
            %

            n = 0;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % get count
            for i = 1:numel(values)
                n = n + sum(GAMSTransfer.SpecialValues.isPosInf(obj.records.(values{i})(:)));
            end
        end

        function n = countNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % n = countNegInf(varargin) returns the number of GAMS MINF values
            % n in records. varargin can include a list of value fields that
            % should be considered: level, value, lower, upper, scale. If none
            % is given all available for the symbol are considered.
            %

            n = 0;

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                return
            end

            % get count
            for i = 1:numel(values)
                n = n + sum(GAMSTransfer.SpecialValues.isNegInf(obj.records.(values{i})(:)));
            end
        end

        function nrecs = getNumberRecords(obj)
            % Returns the number of GDX records (not available for matrix
            % formats)
            %
            % n = getNumberRecords() returns the number of records that would be
            % stored in a GDX file if this symbol would be written to GDX. For
            % matrix formats n is NaN.
            %

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
            case GAMSTransfer.RecordsFormat.EMPTY
                nrecs = 0;
            case GAMSTransfer.RecordsFormat.TABLE
                nrecs = height(obj.records);
            case GAMSTransfer.RecordsFormat.STRUCT
                nrecs = -1;
                fields = obj.availValueFields();
                if numel(fields) > 0
                    nrecs = numel(obj.records.(fields{1}));
                else
                    for i = 1:obj.dimension_
                        label = obj.domain_labels_{i};
                        if isfield(obj.records, label)
                            nrecs = numel(obj.records.(label));
                            break;
                        end
                    end
                end
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                nrecs = nan;
            otherwise
                nrecs = nan;
            end

            % we need to convert to double to have a common data type for C
            nrecs = double(nrecs);
            obj.number_records_ = nrecs;
        end

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
            % See also: GAMSTransfer.Symbol.getSparsity
            %

            if ~obj.isValid()
                nvals = nan;
                return
            end

            % get available value fields
            values = obj.availValueFields(varargin{:});
            if isempty(values)
                nvals = 0;
                return
            end

            % determine number of records
            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                nvals = 0;
            case {GAMSTransfer.RecordsFormat.TABLE, GAMSTransfer.RecordsFormat.STRUCT}
                nvals = numel(values) * obj.getNumberRecords();
            case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                nvals = numel(values) * prod(obj.size_);
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                nvals = 0;
                for i = 1:numel(values)
                    nvals = nvals + nnz(obj.records.(values{i}));
                end
            otherwise
                nvals = nan;
            end
        end

        function uels = getUELs(obj, dim, varargin)
            % Returns the UELs used in this symbol
            %
            % u = getUELs(d) returns the UELs used in dimension d of this symbol
            % u = getUELs(d, 'ignore_unused', true) returns only those UELs that
            % are actually used in the records
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if nargin == 4 && strcmpi(varargin{1}, 'ignore_unused')
                ignore_unused = varargin{2};
                if ~islogical(ignore_unused)
                    error('Argument ''ignore_unused'' must be logical.');
                end
            else
                ignore_unused = false;
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                uels = {};
                return
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                uels = obj.domain_{dim}.getUELs(1, 'ignore_unused', true);
                return
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                if ignore_unused
                    uels = categories(removecats(obj.records.(label)));
                else
                    uels = categories(obj.records.(label));
                end
            else
                uels = obj.uels.(label).get();
                if ignore_unused
                    uels = uels(unique(obj.records.(label)));
                end
            end
        end

        function uels = getUELLabels(obj, dim, ids)
            % Returns the UELs labels for the given UEL IDs
            %
            % u = getUELLabels(d, i) returns the UELs labels u for the given UEL
            % IDs i for the UELs stored for dimension d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if ~isnumeric(ids)
                error('Argument ''ids'' must be numeric');
            end

            uel_label = obj.getUELs(dim);
            idx = ids >= 1 & ids <= numel(uel_label);
            uels = cell(1, numel(ids));
            uels(idx) = uel_label(ids(idx));
            uels(~idx) = {'<undefined>'};
        end

        function initUELs(obj, dim, uels)
            % Sets the UELs without modifying UEL IDs in records
            %
            % initUELs(d, u) sets the UELs u for dimension d. In contrast to
            % the method setUELs(d, u), this method does not modify UEL IDs
            % used in the property records.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid,
            % GAMSTransfer.Symbol.setUELs
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    warning('Cannot init UELs to empty symbol.');
                    return
                end
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                obj.records.(label) = categorical(double(obj.records.(label)), 1:numel(uels), uels);
            else
                obj.uels.(label).set(uels, []);
            end
        end

        function setUELs(obj, dim, uels)
            % Sets the UELs with updating UEL IDs in records
            %
            % setUELs(d, u) sets the UELs u for dimension d. In contrast to the
            % method initUELs(d, u), this method may modify UEL IDs used in the
            % property records such that records still point to the correct UEL
            % label when UEL IDs have changed.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid,
            % GAMSTransfer.Symbol.initUELs
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    warning('Cannot set UELs to empty symbol.');
                    return
                end
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                obj.records.(label) = setcats(obj.records.(label), uels);
            else
                if obj.format_ == GAMSTransfer.RecordsFormat.EMPTY
                    obj.uels.(label).set(uels, []);
                else
                    obj.records.(label) = obj.uels.(label).set(uels, obj.records.(label));
                end
            end
        end

        function addUELs(obj, dim, uels)
            % Adds UELs to the symbol
            %
            % addUELs(d, u) adds the UELs u for dimension d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    warning('Cannot add UELs to empty symbol.');
                    return
                end
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                obj.records.(label) = addcats(obj.records.(label), uels);
            else
                obj.uels.(label).add(uels);
            end
        end

        function removeUELs(obj, dim, uels)
            % Removes UELs from the symbol
            %
            % removeUELs(d) removes all unused UELs for dimension d.
            % removeUELs(d, u) removes the UELs u for dimension d.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if nargin == 3
                if ~(isstring(uels) && numel(uels) == 1) && ~ischar(uels) && ~iscellstr(uels);
                    error('Argument ''uels'' must be ''char'' or ''cellstr''.');
                end
            else
                uels = {};
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    return
                end
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                if isempty(uels)
                    obj.records.(label) = removecats(obj.records.(label));
                else
                    obj.records.(label) = removecats(obj.records.(label), uels);
                end
            else
                if isempty(uels)
                    uels = setdiff(obj.getUELs(dim), obj.getUELs(dim, 'ignore_unused', true));
                end
                if obj.format_ == GAMSTransfer.RecordsFormat.EMPTY
                    obj.records.(label) = obj.uels.(label).remove(uels, []);
                else
                    obj.records.(label) = obj.uels.(label).remove(uels, obj.records.(label));
                end
            end

        end

        function renameUELs(obj, dim, olduels, newuels)
            % Renames UELs in the symbol
            %
            % renameUELs(d, u1, u2) renames the UELs u1 to the labels given in
            % u2 for dimension d. The IDs for these UELs do not change.
            %
            % Note: This can only be used if the symbol is valid. UELs are not
            % available when using the indexed mode.
            %
            % See also: GAMSTransfer.Container.indexed, GAMSTransfer.Symbol.isValid
            %

            if ~isnumeric(dim) || dim ~= round(dim) || dim < 1 || dim > obj.dimension_
                error('Argument ''dimension'' must be integer in [1,%d]', obj.dimension_);
            end
            if ~(isstring(olduels) && numel(olduels) == 1) && ~ischar(olduels) && ~iscellstr(olduels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end
            if ~(isstring(newuels) && numel(newuels) == 1) && ~ischar(newuels) && ~iscellstr(newuels);
                error('Argument ''uels'' must be ''char'' or ''cellstr''.');
            end

            if ~obj.isValid()
                error('Symbol must be valid in order to manage UELs.');
            end
            if obj.container.indexed
                error('UELs not supported in indexed mode.');
            end

            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                if obj.container.features.categorical
                    return
                end
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                error('Matrix formats do not maintain UELs. Modify domain set instead.');
            otherwise
                error('Symbol must be valid in order to manage UELs.');
            end

            label = obj.domain_labels_{dim};
            if obj.container.features.categorical
                obj.records.(label) = renamecats(obj.records.(label), olduels, newuels);
            else
                obj.uels.(label).rename(olduels, newuels);
            end
        end

    end

    methods (Hidden, Access = protected)

        function values = availValueFields(obj, values)
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.EMPTY, GAMSTransfer.RecordsFormat.UNKNOWN}
                values = {};
                return
            case GAMSTransfer.RecordsFormat.TABLE
                fields = obj.records.Properties.VariableNames;
            otherwise
                fields = fieldnames(obj.records);
            end
            if nargin == 1
                values = obj.VALUE_FIELDS;
            else
                values = intersect(obj.VALUE_FIELDS, values);
            end
            values = intersect(fields, values);
        end

        function domain = getInd2Domain(obj, idx)
            domain = cell(1, obj.dimension_);
            if obj.dimension_ == 0
                return;
            end

            % get linear index
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
                for i = 1:obj.dimension_
                    label = obj.domain_labels_{i};
                    domain{i} = double(obj.records.(label)(idx));
                end
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                k = cell(1, 20);
                [k{:}] = ind2sub(obj.size_, idx);
                for i = 1:numel(domain)
                    domain{i} = k{i};
                end
            end

            % convert to uel labels
            if ~obj.container.indexed
                for i = 1:obj.dimension_
                    label = obj.domain_labels_{i};
                    d = obj.getUELLabels(i, domain{i});
                    domain{i} = d{1};
                end
            end
        end

        function has_domain_label = checkRecordFields(obj, labels)
            has_domain_label = zeros(1, obj.dimension_);

            % check name and data type
            for i = 1:numel(labels)
                field = obj.records.(labels{i});
                switch labels{i}
                case obj.TEXT_FIELDS
                    if (~obj.container.features.categorical || ~iscategorical(field)) && ~iscellstr(field)
                        error('Field ''text'' must be of type ''categorical'' or ''cellstr''.');
                    end
                case obj.VALUE_FIELDS
                    if ~isnumeric(field)
                        error('Field ''%s'' must be of type ''numeric''.', labels{i});
                    end
                otherwise
                    is_domain_column = false;
                    for j = 1:obj.dimension_
                        if strcmp(labels{i}, obj.domain_labels_{j})
                            is_domain_column = true;
                            has_domain_label(j) = 1;
                        end
                    end
                    if ~is_domain_column
                        error('Field ''%s'' not allowed.', labels{i});
                    end
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
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set') && ...
                    ~isa(obj.domain_{i}, 'GAMSTransfer.Alias')
                    continue
                end

                % check correct order of symbols
                if ~GAMSTransfer.gt_cmex_check_sym_order(obj.container.data, obj.domain_{i}.name, obj.name_);
                    error('Domain set ''%s'' is out of order: Try calling the Container method reorderSymbols().', obj.domain_{i}.name);
                end

                % check domain set
                if ~obj.domain_{i}.isValidAsDomain()
                    error('Set ''%s'' is not valid as domain.', obj.domain_{i}.name);
                end
            end
        end

        function records_format = checkRecordFormat(obj, labels)
            records_format = GAMSTransfer.RecordsFormat.UNKNOWN;

            % check if we have a table
            if obj.container.features.table && istable(obj.records);
                records_format = GAMSTransfer.RecordsFormat.TABLE;
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
                case {'value', 'level', 'text', 'marginal', 'lower', 'upper', 'scale'}
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
                        records_format = GAMSTransfer.RecordsFormat.STRUCT;
                    else
                        records_format = GAMSTransfer.RecordsFormat.DENSE_MATRIX;
                    end
                elseif val_fields_same_size && val_fields_sparse
                    records_format = GAMSTransfer.RecordsFormat.SPARSE_MATRIX;
                end
            elseif ~dom_fields_iscol || ~val_fields_iscol || ~val_fields_dense
                error('Fields need to match matrix format or to be dense column vectors.')
            elseif ~val_fields_same_size || ~val_fields_same_length || ~dom_fields_same_length || ...
                ~(val_nrecs == dom_nrecs || val_nrecs < 0 || dom_nrecs < 0)
                error('Fields need to match matrix format or to be of same length')
            else
                records_format = GAMSTransfer.RecordsFormat.STRUCT;
            end
        end

        function setRecordsDomainField(obj, dim, uels, domains)
            label = obj.domain_labels_{dim};

            if numel(size(domains)) > 2
                error('Domain %d has invalid shape.', dim);
            end
            domains = reshape(domains, [numel(domains), 1]);

            % in indexed mode we don't need to translate strings to uel ids
            if obj.container.indexed
                obj.records.(label) = domains;
                return;
            end

            % set record values in numerical or categorical format
            if obj.container.features.categorical
                obj.records.(label) = categorical(domains, uels);
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
            if ~isa(obj, 'GAMSTransfer.Set')
                error('Element texts only allowed for Sets.');
            end
            if numel(size(texts)) > 2
                error('Element texts have invalid shape.');
            end
            texts = reshape(texts, [numel(texts), 1]);

            obj.records.text = texts;
            if obj.container.features.categorical
                obj.records.text = categorical(obj.records.text);
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
            s = size(values);
            s = s(1:obj.dimension_);
            if any(s ~= obj.size_)
                values = values';
                s = size(values);
                s = s(1:obj.dimension_);
                if any(s ~= obj.size_)
                    if ismatrix
                        error('Records size doesn''t match symbol size.');
                    end
                    values = values(:);
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
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set') && ...
                    ~isa(obj.domain_{i}, 'GAMSTransfer.Alias')
                    continue
                end
                obj.domain_names_{i} = obj.domain_{i}.name;
                obj.domain_labels_{i} = sprintf('%s_%d', obj.domain_{i}.name, i);
                obj.size_(i) = obj.domain_{i}.getNumberRecords();
            end
        end

    end

end
