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

        function arg = validateDef(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.definition.Definition')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.definition.Definition''.', name, index);
            end
        end

        function arg = validateData(name, index, arg)
            if ~isa(arg, 'gams.transfer.symbol.data.Data')
                error('Argument ''%s'' (at position %d) must be ''gams.transfer.symbol.data.Data''.', name, index);
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
        %> Container the symbol is stored in

        % container Container the symbol is stored in
        container
    end

    properties (Dependent)
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
    end

    properties (Dependent, SetAccess = private)
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

            domains = obj.def_.domains;

            is_regular = numel(domains) > 0;
            is_none = true;
            for i = 1:numel(domains)
                switch class(domains{i})
                case 'gams.transfer.symbol.domain.Regular'
                    is_none = false;
                case 'gams.transfer.symbol.domain.Relaxed'
                    is_regular = false;
                    if ~strcmp(domains{i}.name, gams.transfer.Constants.UNIVERSE_NAME)
                        is_none = false;
                    end
                otherwise
                    error('Unknown domain type: %s', class(domains{i}));
                end
            end

            if is_regular
                domain_type = 'regular';
            elseif is_none
                domain_type = 'none';
            else
                domain_type = 'relaxed';
            end
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

            if gams.transfer.Constants.SUPPORTS_CATEGORICAL
                index_type = gams.transfer.symbol.domain.IndexType.Categorical();
            else
                index_type = gams.transfer.symbol.domain.IndexType.Integer();
            end

            if isa(records, 'gams.transfer.symbol.data.Data')
                obj.data_ = records;
                return

            % string -> recall with cell of strings
            elseif isstring(records) && numel(records) == 1 || ischar(records)
                if obj.dimension ~= 1
                    error('Single string as records only accepted if symbol dimension equals 1.');
                end
                domain = obj.def_.domains{1};
                if domain.HOLDS_UNIQUE_LABELS
                    domain.unique_labels = gams.transfer.unique_labels.Dictionary({records});
                end
                data = gams.transfer.symbol.data.Struct.Empty(obj.def_.domains);
                data.records.(domain.label) = domain.createIndex(index_type, {records});
                % TODO: release unique labels if categorical

            % cell of strings -> domain entries
            elseif iscellstr(records)
                s = size(records);
                if s(1) ~= obj.dimension
                    error('First dimension of cellstr must equal symbol dimension.');
                end
                data = gams.transfer.symbol.data.Struct.Empty(obj.def_.domains);
                for i = 1:obj.dimension
                    domain = obj.def_.domains{i};
                    if domain.HOLDS_UNIQUE_LABELS
                        domain.unique_labels = gams.transfer.unique_labels.Dictionary(records(i,:));
                    end
                    data.records.(domain.label) = domain.createIndex(index_type, records(i,:));
                    % TODO: release unique labels if categorical
                end

            % numeric vector -> interpret as level values in matrix format
            elseif isnumeric(records) && numel(obj.def_.values) > 0
                assert(isa(obj.def_.values{1}, 'gams.transfer.symbol.value.Numeric'));
                data = gams.transfer.symbol.data.DenseMatrix.Empty(obj.def_.domains);
                data.records.(obj.def_.values{1}.label) = records;

            % cell -> cellstr elements to domains or set element texts and
            % numeric vector to values
            elseif iscell(records)
                n_values = 0;
                n_domains = 0;
                data = gams.transfer.symbol.data.Struct.Empty(obj.def_.domains);
                for i = 1:numel(records)
                    if isnumeric(records{i})
                        n_values = n_values + 1;
                        if n_values > numel(obj.def_.values)
                            error('Too many value fields in records.');
                        end
                        data.records.(obj.def_.values{n_values}.label) = records{i}(:);
                    % elseif iscellstr(records{i})
                    %     n_domains = n_domains + 1;
                    %     if n_dom_fields == obj.dimension_ + 1 && isa(obj, 'gams.transfer.Set')
                    %         obj.setRecordsTextField(records{i});
                    %         continue
                    %     end
                    %     if n_dom_fields > obj.dimension_
                    %         error('More domain fields than symbol dimension.');
                    %     end
                    %     [~,uidx,~] = unique(records{i}, 'first');
                    %     uels{n_dom_fields} = records{i}(sort(uidx));
                    %     obj.setRecordsDomainField(domain_labels{n_dom_fields}, uels{n_dom_fields}, records{i});
                    else
                        error('Cell elements must be cellstr or numeric.');
                    end
                end

            % struct -> check fields for domain or value fields
            elseif isstruct(records) && numel(records) == 1
                fields = fieldnames(records);
                data = gams.transfer.symbol.data.Struct.Empty(obj.def_.domains);
                for i = 1:numel(fields)
                    value = obj.def_.getValue(fields{i});
                    if ~isempty(value)
                        data.records.(value.label) = records.(fields{i})(:);
                        continue;
                    end

                    domain = obj.def_.getDomain(fields{i});
                    if ~isempty(domain)
                        if domain.HOLDS_UNIQUE_LABELS
                            domain.unique_labels = gams.transfer.unique_labels.Dictionary(records.(fields{i}));
                        end
                        data.records.(domain.label) = domain.createIndex(index_type, records.(fields{i}));
                        % TODO: release unique labels if categorical
                    end
                end

            % table -> just keep it
            elseif gams.transfer.Constants.SUPPORTS_TABLE && istable(records)
                data = gams.transfer.data.Table(records);

            else
                error('Unsupported records format.');
            end

            % check records format
            status = data.isValid(obj.def_);
            if status.flag ~= gams.transfer.utils.Status.OK
                error(status.message);
            end

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

            if ~obj.container_.hasSymbols(obj.name_) || obj.container_.getSymbols(obj.name_) ~= obj
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
                status = obj.data_.isValid(obj.def_);
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

            % TODO domain forwarding

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
        %> - `dom_violations = getDomainViolations` returns a list of domain violations for all
        %>   dimensions.
        %> - `dom_violations = getDomainViolations(d)` returns a list of domain violations for
        %>   dimension(s) `d`.
        %>
        %> @see \ref gams::transfer::symbol::Symbol::resolveDomainViolations
        %> "symbol.Symbol.resolveDomainViolations", \ref gams::transfer::Container::getDomainViolations
        %> "Container.getDomainViolations", \ref gams::transfer::DomainViolation "DomainViolation"
        function getDomainViolations(obj)
            % Get domain violations
            %
            % Domain violations occur when this symbol uses other Set(s) as domain(s) and a domain
            % entry in its records that is not present in the corresponding set. Such a domain
            % violation will lead to a GDX error when writing the data.
            %
            % dom_violations = getDomainViolations returns a list of domain violations for all
            % dimension.
            % dom_violations = getDomainViolations(d) returns a list of domain violations for
            % dimension(s) d.
            %
            % See also: gams.transfer.symbol.Symbol.resolveDomainViolations,
            % gams.transfer.Container.getDomainViolations, gams.transfer.DomainViolation

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
        function resolveDomainViolations(obj)
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

        end

        %> Returns the sparsity of symbol records
        %>
        %> - `s = getSparsity()` returns sparsity `s` in the symbol records.
        function sparsity = getSparsity(obj)
            % Returns the sparsity of symbol records
            %
            % s = getSparsity() returns sparsity s in the symbol records.

            sparsity = obj.data_.getSparsity(obj.def_);
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
                        validate = @(x1, x2, x3) (gams.transfer.utils.validate_cell(x1, x2, x3, {'string', 'char'}, 1));
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMaxValue(obj.def_, args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMinValue(obj.def_, args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            value = obj.data_.getMeanValue(obj.def_, args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            [value, where] = obj.data_.getMaxAbsValue(obj.def_, args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countNA(args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countUndef(args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countEps(args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countPosInf(args{:});
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
                args = {};
            else
                try
                    args = {'values', obj.parseValues(varargin{:})};
                catch e
                    error(e.message);
                end
            end

            n = obj.data_.countNegInf(args{:});
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

            nrecs = obj.data_.getNumberRecords(obj.def_);
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
            nvals = obj.data_.getNumberValues(obj.def_);
        end

    end

    methods (Hidden, Access = protected)

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

            if nargin >= 2 && isnumeric(varargin{1})
                try
                    varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
                catch e
                    error(e.message);
                end
            end
            uels = obj.data_.getUELs(varargin{:});
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

            if nargin >= 3 && isnumeric(varargin{2})
                try
                    varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
                catch e
                    error(e.message);
                end
            end
            obj.data_.setUELs(varargin{:});
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

            if nargin >= 3 && isnumeric(varargin{2})
                try
                    varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
                catch e
                    error(e.message);
                end
            end
            obj.data_.reorderUELs(varargin{:});
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

            if nargin >= 3 && isnumeric(varargin{2})
                try
                    varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
                catch e
                    error(e.message);
                end
            end
            obj.data_.addUELs(varargin{:});
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

            if nargin >= 3 && isnumeric(varargin{2})
                try
                    varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
                catch e
                    error(e.message);
                end
            end
            obj.data_.removeUELs(varargin{:});
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

            if nargin >= 3 && isnumeric(varargin{2})
                try
                    varargin{2} = obj.validateDimensionToDomain('dimension', 2, varargin{2});
                catch e
                    error(e.message);
                end
            end
            obj.data_.renameUELs(varargin{:});
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

            if nargin >= 2 && isnumeric(varargin{1})
                try
                    varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
                catch e
                    error(e.message);
                end
            end
            obj.data_.lowerUELs(varargin{:});
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

            if nargin >= 2 && isnumeric(varargin{1})
                try
                    varargin{1} = obj.validateDimensionToDomain('dimension', 1, varargin{1});
                catch e
                    error(e.message);
                end
            end
            obj.data_.upperUELs(varargin{:});
        end

    end

end
