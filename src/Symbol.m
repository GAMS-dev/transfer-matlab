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
    % Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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
        % domain_label Expected domain labels in records
        domain_label

        % domain_info Specifies if domains are stored 'relaxed' or 'regular'
        domain_info

        % format Format in which records are stored in (e.g. struct or dense_matrix)
        format

        % number_records Number of records
        number_records

        % number_values Number of record values (values unequal default value)
        number_values
    end

    properties
        % records Storage of symbol records
        records
    end

    properties (Dependent)
        % uels Unique Element Listing (UEL) used for this symbol
        uels
    end

    properties (Dependent, SetAccess = private)
        % is_valid Indicates if records are stored in a supported format
        is_valid
    end

    properties (Hidden, SetAccess = private)
        % container Container this symbol is stored in
        container

        % read_entry GDX symbol ID (if symbol was read from GDX)
        read_entry
    end

    properties (Hidden)
        name_
        description_
        dimension_
        domain_
        domain_label_
        domain_info_
        size_
        uels_
        format_

        % number_records_ if negative: -1 * number of records - 1; if positive:
        % number of records in symbol data
        number_records_
        number_values_
    end

    methods (Access = protected)

        function obj = Symbol(container, name, description, domain_size, records, read_entry, read_number_records)
            % Constructs a GAMS Symbol, see class help.
            %

            % we rely on the checks of child classes
            obj.container = container;
            obj.name_ = char(name);
            obj.description_ = char(description);

            % the following inits dimension_, domain_, domain_label_, domain_info_ and uels_
            if container.indexed
                obj.size = domain_size;
            else
                obj.domain = domain_size;
            end
            obj.format_ = nan;
            obj.read_entry = read_entry;

            % a negative number_records signals that we store the number of
            % records of the GDX file
            obj.number_records_ = -read_number_records-1;
            obj.number_values_ = nan;

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
            if ~iscell(domain)
                error('Domain must be of type ''cell''.');
            end
            for i = 1:numel(domain)
                if ischar(domain{i})
                    continue;
                elseif isstring(domain{i})
                    domain{i} = char(domain{i});
                elseif isa(domain{i}, 'GAMSTransfer.Set')
                    if domain{i}.dimension ~= 1
                        error('Set ''%s'' must have dimension=1 to be valid as domain.', domain{i}.name);
                    end
                    if obj.container.features.handle_comparison && ne(obj.container, domain{i}.container)
                        error('Set ''%s'' must have same container as symbol ''%s''.', domain{i}.name, obj.name);
                    end
                    continue;
                else
                    error('Domain entry must be of type ''GAMSTransfer.Set'' or ''char''.');
                end
            end

            obj.domain_ = domain;
            obj.dimension_ = numel(domain);

            % generate domain labels
            obj.domain_label_ = cell(1, obj.dimension_);
            for i = 1:obj.dimension_
                if strcmp(obj.domain_{i}, '*')
                    obj.domain_label_{i} = sprintf('uni_%d', i);
                elseif isa(obj.domain_{i}, 'GAMSTransfer.Set')
                    obj.domain_label_{i} = sprintf('%s_%d', obj.domain_{i}.name, i);
                else
                    obj.domain_label_{i} = sprintf('%s_%d', obj.domain_{i}, i);
                end
            end

            % determine domain info type
            obj.domain_info_ = 'regular';
            for i = 1:obj.dimension_
                if (ischar(obj.domain_{i}) || isstring(obj.domain_{i})) && ~strcmp(obj.domain_{i}, '*')
                    obj.domain_info_ = 'relaxed';
                    break
                end
            end

            % determine size
            obj.size_ = zeros(1, obj.dimension_);
            for i = 1:obj.dimension_
                if isa(obj.domain_{i}, 'GAMSTransfer.Set')
                    obj.size_(i) = obj.domain_{i}.number_records;
                else
                    obj.size_(i) = nan;
                end
            end

            % update uels
            new_uels = struct();
            for i = 1:obj.dimension_
                label = obj.domain_label_{i};
                if isfield(obj.uels_, label)
                    new_uels.(label) = obj.uels_.(label);
                elseif isa(obj.domain_{i}, 'GAMSTransfer.Set') && ...
                    (obj.domain_{i}.format_ == GAMSTransfer.RecordsFormat.STRUCT || ...
                    obj.domain_{i}.format_ == GAMSTransfer.RecordsFormat.TABLE) && ...
                    obj.domain_{i}.isValidAsDomain()
                    new_uels.(label) = obj.domain_{i}.getUsedUels(1);
                else
                    new_uels.(label) = {};
                end
            end
            obj.uels_ = new_uels;

            % indicate that we need to recheck symbol records
            obj.format_ = nan;
            obj.number_records_ = nan;
        end

        function domain_label = get.domain_label(obj)
            domain_label = obj.domain_label_;
        end

        function domain_info = get.domain_info(obj)
            domain_info = obj.domain_info_;
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
            obj.domain_label_ = cell(1, obj.dimension_);
            obj.domain_ = cell(1, obj.dimension_);
            for i = 1:obj.dimension_
                obj.domain_{i} = sprintf('dim_%d', i);
                obj.domain_label_{i} = sprintf('dim_%d', i);
            end

            % determine domain info type
            obj.domain_info_ = 'relaxed';

            % update uels
            obj.uels_ = struct();
            for i = 1:obj.dimension_
                obj.uels_.(obj.domain_label_{i}) = {};
            end

            % indicate that we need to recheck symbol records
            obj.format_ = nan;
            obj.number_records_ = nan;
        end

        function form = get.format(obj)
            if isnan(obj.format_)
                obj.check(false);
            end
            form = GAMSTransfer.RecordsFormat.int2str(obj.format_);
        end

        function uels = get.uels(obj)
            uels = obj.uels_;
        end

        function set.uels(obj, uels)
            if obj.container.indexed
                error('Setting symbol UELs not allowed in indexed mode.');
            end
            if ~isstruct(uels)
                error('Property uels must be struct.');
            end
            if numel(fieldnames(uels)) ~= obj.dimension_
                error('UEL struct must have %d fields.', obj.dimension_);
            end
            for i = 1:obj.dimension_
                label = obj.domain_label_{i};
                if ~isfield(uels, label);
                    error('UEL field ''%s'' is missing.', label);
                end
                if ~iscellstr(uels.(label))
                    error('UEL field ''%s'' must be cell of strings.', label);
                end
            end

            % collect categorical arrays
            is_cat = zeros(1, obj.dimension_);
            if obj.container.features.categorical
                label = obj.domain_label_{i};
                for i = 1:obj.dimension_
                    try
                        is_cat(i) = iscategorical(obj.records.(label));
                    end
                end
            end

            % update uel ids in records
            for i = 1:obj.dimension_
                label = obj.domain_label_{i};
                if is_cat(i)
                    obj.records.(label) = setcats(obj.records.(label), uels.(label));
                else
                    new_ids = zeros(numel(obj.uels_.(label)), 1);
                    for j = 1:numel(new_ids)
                        newid = find(ismember(uels.(label), obj.uels_.(label){j}), 1);
                        if ~isempty(newid)
                            new_ids(j) = newid;
                        end
                    end
                    try
                        obj.records.(label) = new_ids(obj.records.(label));
                    end
                end
            end

            obj.uels_ = uels;

            % indicate that we need to recheck symbol records
            obj.format_ = nan;
            obj.number_records_ = nan;
        end

        function nrecs = get.number_records(obj)
            if ~isnan(obj.number_records_)
                if obj.number_records_ < 0
                    nrecs = -obj.number_records_-1;
                else
                    nrecs = obj.number_records_;
                end
                return
            end
            if ~obj.is_valid
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
                        label = obj.domain_label_{i};
                        if isfield(obj.records, label)
                            nrecs = numel(obj.records.(label));
                            break;
                        end
                    end
                end
            case GAMSTransfer.RecordsFormat.DENSE_MATRIX
                nrecs = 0;
                fields = obj.availValueFields();
                for i = 1:numel(fields)
                    nrecs = numel(obj.records.(fields{i}));
                    break;
                end
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                nrecs = nan;
            otherwise
                nrecs = nan;
            end

            obj.number_records_ = nrecs;
        end

        function nvals = get.number_values(obj)
            if ~isnan(obj.number_values_)
                nvals = obj.number_values_;
                return
            end
            if ~obj.is_valid
                nvals = nan;
                return
            end

            % determine number of records
            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                nvals = 0;
            case {GAMSTransfer.RecordsFormat.TABLE, GAMSTransfer.RecordsFormat.STRUCT, ...
                GAMSTransfer.RecordsFormat.DENSE_MATRIX}
                nvals = numel(obj.availValueFields()) * obj.number_records;
            case GAMSTransfer.RecordsFormat.SPARSE_MATRIX
                nvals = 0;
                fields = obj.availValueFields();
                for i = 1:numel(fields)
                    nvals = nvals + nnz(obj.records.(fields{i}));
                end
            otherwise
                nvals = nan;
            end

            obj.number_values_ = nvals;
        end

        function set.records(obj, records)
            obj.records = records;
            obj.format_ = nan;
            obj.number_records_ = nan;
            obj.number_values_ = nan;
        end

        function valid = get.is_valid(obj)
            if isnan(obj.format_)
                obj.check(false);
            end
            valid = obj.format_ ~= GAMSTransfer.RecordsFormat.UNKNOWN && ...
                obj.format_ ~= GAMSTransfer.RecordsFormat.NOT_READ;
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
            % - struct: Fields which names match domain labels, are interpreted
            %   as domain entries of the given domain. Other supported fields are
            %   level, value, marginal, lower, upper, scale. Unsopprted fields
            %   are ignored.
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
            obj.updateDomainSetDependentData();

            if nargin == 2
                records = varargin{1};
            else
                records = varargin;
            end

            % string -> recall with cell of strings
            if isstring(records) && numel(records) == 1 || ischar(records)
                if obj.container.indexed
                    error('Strings not allowed in indexed mode.');
                end
                if obj.dimension_ ~= 1
                    error('Single string as records only accepted if symbol dimension equals 1.');
                end
                obj.setRecordsDomainField(1, {records});

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
                    obj.setRecordsDomainField(i, records(i,:));
                end

            % numeric vector -> interpret as level values in matrix format
            elseif isnumeric(records)
                obj.setRecordsValueField(1, records, true);

            % cell -> cellstr elements to domains and numeric vector to values
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
                        if n_dom_fields > obj.dimension_
                            error('More domain fields than symbol dimension.');
                        end
                        obj.setRecordsDomainField(n_dom_fields, records{i});
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
                    else
                        for j = 1:obj.dimension_
                            if strcmp(field, obj.domain_label_{j}) || ...
                                isa(obj.domain_{j}, 'GAMSTransfer.Set') && ...
                                strcmp(field, obj.domain_{j}.name)
                                obj.setRecordsDomainField(j, records.(field));
                                break;
                            end
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
            obj.check(true);
        end

        function def = getDefaultValues(obj)
            % Returns default values for given symbol type (incl. sub type)
            %
            % Different GAMS symbols have different default values for level,
            % marginal, lower, upper and scale. This function returns a vector
            % of length 5 with these default values.
            %
            % Example:
            % c = Container();
            % v = Variable(c, 'v', 'binary');
            % v.getDefaultValues() equals [0, 0, 0, 1, 1]
            % p = Parameter(c, 'p');
            % p.getDefaultValues() equals [0, NaN, NaN, NaN, NaN]
            %

            def = GAMSTransfer.gt_get_defaults(obj);
        end

        function transformRecords(obj, target_format)
            % Transforms symbol records into given format
            %
            % See also: GAMSTransfer.RecordsFormat
            %

            p = inputParser();
            is_string_char = @(x) isstring(x) && numel(x) == 1 || ischar(x);
            addRequired(p, 'target_format', is_string_char);
            parse(p, target_format);
            target_format = GAMSTransfer.RecordsFormat.str2int(p.Results.target_format);

            def_values = obj.getDefaultValues();

            % check applicability of transform
            if ~obj.is_valid
                error('Symbol records are invalid.');
            end
            switch obj.format_
            case GAMSTransfer.RecordsFormat.EMPTY
                return
            case {GAMSTransfer.RecordsFormat.UNKNOWN, GAMSTransfer.RecordsFormat.NOT_READ}
                error('Cannot transform current format: %s', obj.format);
            end
            switch target_format
            case GAMSTransfer.RecordsFormat.EMPTY
                obj.records = [];
            case {GAMSTransfer.RecordsFormat.UNKNOWN, GAMSTransfer.RecordsFormat.NOT_READ}
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
                    return
                end
            case GAMSTransfer.RecordsFormat.TABLE
                switch target_format
                case GAMSTransfer.RecordsFormat.STRUCT
                    obj.records = table2struct(obj.records, 'ToScalar', true);
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

                    % get linear indices
                    s = ones(1, max(2, obj.dimension_));
                    s(1:obj.dimension_) = obj.size_;
                    if obj.dimension_ > 0
                        idx_sub = cell(1, obj.dimension_);
                        for i = 1:obj.dimension_
                            idx_sub{i} = int32(obj.records.(obj.domain_label_{i}));
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
                        label = obj.domain_label_{i};
                        records.(label) = k_sorted(:,i);
                        if ~obj.container.indexed && obj.container.features.categorical
                            records.(label) = categorical(records.(label), ...
                                1:numel(obj.uels_.(label)), obj.uels_.(label));
                        end
                    end

                    % store value fields
                    for f = obj.VALUE_FIELDS
                        if isfield(obj.records, f{1})
                            records.(f{1}) = full(obj.records.(f{1})(k_idx_sorted));
                        end
                    end

                    obj.records = records;
                    return
                end
            end

            error('Transformation from ''%s'' to ''%s'' not supported.', ...
                obj.format, p.Results.target_format);
        end

        function valid = check(obj, verbose)
            % Checks correctness of symbol
            %
            % If the function argument is true, this function will print the
            % reason why the symbol is invalid.
            %
            % See also: GAMSTransfer.Symbol/is_valid
            %

            valid = false;
            obj.format_ = GAMSTransfer.RecordsFormat.UNKNOWN;
            obj.updateDomainSetDependentData();

            try
                % check if symbol is actually contained in container
                if ~isfield(obj.container.data, obj.name)
                    error('Symbol is not part of its linked container.');
                end

                % if the symbol has not been properly read, we don't check any further
                % Note that format NOT_READ will lead to an invalid symbol
                if isempty(obj.records) && ~isnan(obj.number_records_) && obj.number_records_ < 0
                    obj.format_ = GAMSTransfer.RecordsFormat.NOT_READ;
                    return
                end

                % check domains
                obj.checkDomains();

                % check if records are empty
                if isempty(obj.records)
                    obj.format_ = GAMSTransfer.RecordsFormat.EMPTY;
                    return
                end

                % check data type of records (must be table or struct) and get column names
                if obj.container.features.table && istable(obj.records);
                    labels = obj.records.Properties.VariableNames;
                elseif isstruct(obj.records)
                    labels = fieldnames(obj.records);
                else
                    error('Records must be of type ''table'' or ''struct''.');
                end

                % check if records are empty
                if isempty(labels)
                    obj.format_ = GAMSTransfer.RecordsFormat.EMPTY;
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
                            error('Domain ''%s'' is missing.', obj.domain_label_{i});
                        end
                    end
                end

                valid = true;
            catch e
                obj.format_ = GAMSTransfer.RecordsFormat.UNKNOWN;
                if verbose
                    error(e.message);
                end
            end

            % update uels from categorical arrays
            if ~obj.container.indexed && obj.container.features.categorical && ...
                (obj.format_ == GAMSTransfer.RecordsFormat.TABLE || ...
                obj.format_ == GAMSTransfer.RecordsFormat.STRUCT)
                for i = 1:obj.dimension_
                    label = obj.domain_label_{i};
                    if iscategorical(obj.records.(label))
                        obj.uels_.(label) = categories(obj.records.(label));
                    end
                end
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
            if ~obj.is_valid
                error('Symbol must be valid in order to get domain violations.');
            end

            dom_violations = {};
            for i = 1:obj.dimension_
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set')
                    continue;
                end

                added_uels = setdiff(obj.getUsedUels(i), obj.domain_{i}.getUsedUels(1));
                n_added_uels = numel(added_uels);
                if n_added_uels > 0
                    dom_violations{end+1} = GAMSTransfer.DomainViolation(obj, i, obj.domain_{i}, added_uels);
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
                sparsity = 1 - obj.number_values / n_dense;
            end
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
                if isnan(value) || value > value_
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
                n = n + obj.number_records;
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

        function n = getNumNa(obj, varargin)
            % Returns the number of GAMS NA values in records
            %
            % n = getNumNa(varargin) returns the number of GAMS NA values n in
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
                n = n + sum(GAMSTransfer.SpecialValues.isna(obj.records.(values{i})(:)));
            end
        end

        function n = getNumUndef(obj, varargin)
            % Returns the number of GAMS UNDEF values in records
            %
            % n = getNumUndef(varargin) returns the number of GAMS UNDEF values
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
                n = n + sum(GAMSTransfer.SpecialValues.isundef(obj.records.(values{i})(:)));
            end
        end

        function n = getNumEps(obj, varargin)
            % Returns the number of GAMS EPS values in records
            %
            % n = getNumEps(varargin) returns the number of GAMS EPS values n in
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
                n = n + sum(GAMSTransfer.SpecialValues.iseps(obj.records.(values{i})(:)));
            end
        end

        function n = getNumPosInf(obj, varargin)
            % Returns the number of GAMS PINF (positive infinity) values in
            % records
            %
            % n = getNumPosInf(varargin) returns the number of GAMS PINF values
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
                n = n + sum(GAMSTransfer.SpecialValues.isposinf(obj.records.(values{i})(:)));
            end
        end

        function n = getNumNegInf(obj, varargin)
            % Returns the number of GAMS MINF (negative infinity) values in
            % records
            %
            % n = getNumNegInf(varargin) returns the number of GAMS MINF values
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
                n = n + sum(GAMSTransfer.SpecialValues.isneginf(obj.records.(values{i})(:)));
            end
        end

        function uels = getUsedUels(obj, dim)
            % Returns the UELs that are actually used in the symbol records
            %
            % u = Symbol.getUsedUels(d) returns the actually usesd uels u for
            % the d-th dimension.
            %

            if dim < 1 || dim > obj.dimension
                error('Given dimension must be within [1,%d].', obj.dimension);
            end
            if ~obj.is_valid
                error('Symbol must be valid in order to get used UELs.');
            end

            label = obj.domain_label_{dim};
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                uels = obj.uels_.(label);
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
                uels = obj.uels_.(label);
                uels = uels(unique(obj.records.(label), 'stable'));
            otherwise
                uels = {};
            end
        end

        function trimUels(obj)
            % Removes unused UELs
            %

            for i = 1:obj.dimension_
                obj.uels_.(obj.domain_label_{i}) = obj.getUsedUels(i);
            end
        end

    end

    methods (Hidden, Access = protected)

        function values = availValueFields(obj, values)
            switch obj.format_
            case {GAMSTransfer.RecordsFormat.NOT_READ, GAMSTransfer.RecordsFormat.EMPTY, ...
                GAMSTransfer.RecordsFormat.UNKNOWN}
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
                    label = obj.domain_label_{i};
                    domain{i} = obj.records.(label)(idx);
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
                    label = obj.domain_label_{i};
                    domain{i} = obj.uels_.(label){domain{i}};
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
                        if strcmp(labels{i}, obj.domain_label_{j})
                            is_domain_column = true;
                            has_domain_label(j) = 1;
                        end
                    end
                    if ~is_domain_column
                        error('Field ''%s'' not allowed.', labels{i});
                    end
                    if ~isfield(obj.uels_, labels{i})
                        error('Field ''uels'' is missing the entry for ''%s''.', labels{i});
                    end
                    if obj.container.features.categorical && iscategorical(field)
                        if obj.container.indexed
                            error('Field ''%s'' must not be categorical in indexed mode.', labels{i})
                        end
                        if any(isundefined(field))
                            error('Field ''%s'' has undefined domain entries.', labels{i});
                        end
                    elseif isnumeric(field)
                        if any(isnan(field)) || any(isinf(field))
                            error('Field ''%s'' contains Inf or NaN.', labels{i});
                        end
                        if obj.container.indexed
                            maxuel = obj.size_(i);
                        else
                            maxuel = numel(obj.uels_.(labels{i}));
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
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set')
                    continue
                end

                % check domain set
                if ~obj.domain_{i}.isValidAsDomain()
                    error('Set ''%s'' is not valid as domain.', obj.domain_{i}.name);
                end

                % check correct order of symbols
                if ~GAMSTransfer.gt_check_symorder(obj.container.data, obj.domain_{i}.name, obj.name);
                    error('Domain set ''%s'' is out of order: Try calling reorder().', obj.domain_{i}.name);
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
                    records_format = GAMSTransfer.RecordsFormat.DENSE_MATRIX;
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

        function setRecordsDomainField(obj, dim, domains)
            label = obj.domain_label_{dim};

            if numel(size(domains)) > 2
                error('Domain %d has invalid shape.', dim);
            end
            domains = reshape(domains, [numel(domains), 1]);

            % in indexed mode we don't need to translate strings to uel ids
            if obj.container.indexed
                obj.records.(label) = domains;
                return;
            end

            % set uels
            obj.uels_.(label) = unique(domains, 'stable');

            % set record values in numerical or categorical format
            if obj.container.features.categorical
                obj.records.(label) = categorical(domains, obj.uels_.(label));
            else
                map = containers.Map(obj.uels_.(label), 1:numel(obj.uels_.(label)));
                recs = zeros(s(2), 1);
                for j = 1:s(2)
                    recs(j) = map(domains{j});
                end
                obj.records.(label) = recs;
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
                if ~isa(obj.domain_{i}, 'GAMSTransfer.Set')
                    continue
                end
                obj.domain_label_{i} = sprintf('%s_%d', obj.domain_{i}.name, i);
                obj.size_(i) = obj.domain_{i}.number_records;
            end
        end

    end

end
