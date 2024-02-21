GAMS Transfer Matlab v0.9.0
==================
- Removed property `Container.indexed`. A container may now store indexed or standard symbols
  together. To read or write an indexed GDX file, pass the argument `indexed, true` to
  `Container.read` or `Container.write`. When writing an indexed GDX file, non-indexed symbols are
  ignored. Writing a standard GDX file is always possible for all symbols (however, the meaning of
  indexed symbols may be different). An indexed symbol can be created by passing the size array
  instead of a domain cell for the domain (as before) or by setting `size` property of the symbol.
- Restructured symbol classes:
  - Added subpackages `gams.transfer.symbol` and `gams.transfer.alias` (as well as internal
    subpackages `gams.transfer.incase_ordered_dict`, `gams.transfer.unique_labels`,
    `gams.transfer.symbol.data`, `gams.transfer.symbol.definition`, `gams.transfer.symbol.domain`,
    `gams.transfer.symbol.value` and `gams.transfer.symbol.unique_labels`). Note that internal and/
    or hidden classes and packages may alter its API without notice, so use at own risk. Referring
    to subpackages without `gams.transfer` in the following.
  - Changed symbol and alias classes to `symbol.Set`, `symbol.Parameter`, `symbol.Variable`,
    `symbol.Equation`, `alias.Set` and `alias.Universe`. The previous (constructors of) classes
    `Set`, `Parameter`, `Variable`, `Equation`, `Alias` and `UniverseAlias` are now factory methods
    that forward the call to `Container.addSet`, `Container.addParameter`, `Container.addVariable`,
    `Container.addEquation`, `Container.addAlias` or `Container.addUniverseAlias`, respectively.
    Therefore, the factory methods now benefit from the overwrite feature of the `Container.add*`
    methods.
  - Changed abstract symbol class `Symbol` to `symbol.Abstract` and added abstract alias class
    `alias.Abstract`.
- Changed behaviour of `symbol.Abstract.format` (previously `Symbol.format`):
  - Changed selection of `symbol.Abstract.format`: This was previously detected automatically from
    `symbol.Abstract.records`. It is now chosen explicitly to be one of the four supported formats
    `table`, `struct`, `dense_matrix` or `sparse_matrix` by setting `symbol.Abstract.format`.
    `symbol.Abstract.isValid` will check the records towards the chosen format. Changing the format
    by setting `symbol.Abstract.format` does not change `symbol.Abstract.records`.
  - Changed `symbol.Abstract.format` when reading or creating symbol without records: Previously
    this was `empty` and `symbol.Abstract.records` was `[]`. Now, the format is always one of the
    four supported formats `table`, `struct`, `dense_matrix` or `sparse_matrix` (but without any
    records).
  - Changed `symbol.Abstract.format` when reading a scalar. In this case the formats `struct` and
    `dense_matrix` are identical and `Container.read` preferred `struct`, i.e., `dense_matrix` was
    changed to `struct`. This is not the case anymore.
- Changed enumeration-like classes `VariableType` and `EquationType`:
  - Changed type of enumeration constants from `double` to `uint8`.
  - Added state (property `value` and `select`) to enumeration-like classes `VariableType` and
    `EquationType`.
  - Added methods `binary`, `integer`, `positive`, `negative`, `free`, `sos1`, `sos2`, `semiCont`,
    `semiInt` to `VariableType` to create enumeration with corresponding value.
  - Added methods `eq`, `leq`, `geq`, `nonBinding`, `external`, `cone`, `boolean` to `EquationType`
    to create enumeration with corresponding value.
  - Added methods `values` and `selects` to `VariableType` and `EquationType` to convert input to
    (multiple) enumeration values or selections at once.
  - Removed methods `int2str`, `str2int` and `isValid`. Just use the constructor to create an
    enumeration and then use the properties `value` or `select` instead.
- Changed handling of `symbol.Abstract.domain_labels`: Previously, if not set explicitly, these were
  extracted from the records. This is not the case anymore. They default to
  `symbol.Abstract.domain_names` (with possible unique added IDs). Changing the fields / columns in
  the records may require to update `symbol.Abstract.domain_labels` accordingly. However, updating
  `symbol.Abstract.domain_labels` will also update the corresponding fields / columns if available.
- Changed `symbol.Abstract.setRecords` when passing a `struct`. The domain fields are no longer
  taken by number of occurance, but by `symbol.Abstract.domain_labels`.
- Changed behaviour when resetting `symbol.Abstact.domain` or `symbol.Abstract.size`: This may now
  reset all domain related properties such as `symbol.Abstract.domain_labels` or
  `symbol.Abstract.domain_forwarding`.
- Changed behaviour when removing a symbol or alias that is used as domain in another symbol:
  Previously, the domain was set to the universe `*`. It is now relaxed keeping the symbol name such
  that `symbol.Abstract.domain_names` stay the same.
- Changed behaviour when passing `symbols, {}` to `Container.write`: Previously this wrote all
  symbols, now it is none. To write all symbols, use all symbols in the `symbols` argument (see also
  `Container.list*`) or don't specify the `symbols` argument in the call.
- Changed signature of methods `symbol.Abstract.getMaxValue`, `symbol.Abstract.getMinValue`,
  `symbol.Abstract.getMeanValue`, `symbol.Abstract.getMaxAbsValue`, `symbol.Abstract.countNA`,
  `symbol.Abstract.countUndef`, `symbol.Abstract.countEps`, `symbol.Abstract.countPosInf`,
  `symbol.Abstract.countNegInf` and `symbol.Abstract.getNumberValues`: Previously the considered
  values could be filtered by passing individual strings (e.g. `'level', 'marginal'`). Now use the
  parameter argument `values` (e.g. pass `'values', {'level', 'marginal'}`).
- Changed class `DomainViolation`: Moved to `symbol.domain.Violation`, hid constructor and removed
  property `domain`.
- Changed name of subpackage `gams.transfer.cmex` to `gams.transfer.gdx` (internal).
- Added (or unhided) property `symbol.Abstract.container` and `alias.Abstract.container` referring
  to the `Container` the symbol or alias is stored in.
- Added possibility for matrix formats `dense_matrix` and `sparse_matrix` to maintain UELs.
  Previously UELs were used directly from the domain set for these formats and it was not allowed to
  change the UELs through the `symbol.Abstract.*UELs` methods. Now, if a symbol has a regular
  domain, UELs are initialized with the domain set as UELs. But it is further possible to edit those
  UELs per symbol without modifying the domain set. The size of the matrices in
  `symbol.Abstract.records` is defined by the number of UELs per dimension (`symbol.Abstract.size`
  stays the size defined mainly by the domain). This new feature therefore allows to use matrix
  formats when the symbol domain is relaxed and/or smaller matrices than actually defined by the
  regular domain. Note that the previous behaviour for regular symbols with matrix formats does not
  change.
- Added return of new symbol to `symbol.Abstract.copy` and `alias.Abstract.copy`.
- Added a silent call to `Container.reorderSymbols` in `Container.isValid` if symbols are out of
  order (symbols that use other symbols in the domain must appear after the domain symbols). Even
  though having unordered symbols is rather unlikely, this now makes it unnecessary to manually call
  `Container.reorderSymbols`.

GAMS Transfer Matlab v0.8.0
==================
- Breaking: Renamed package to `gams.transfer` (previously: `GAMSTransfer`) and moved MEX interface
  to `gams.transfer.cmex` (internal use only).
- Added MacOS Arm64 build.
- Added `gams.transfer.setup` and `*.c` MEX source files of internal interface to
  `gams.transfer.cmex`. Calling `gams.transfer.setup` allows to build GAMS Transfer Matlab from
  source. Check with `mex -setup` which C compiler is enbaled in Matlab.

GAMS Transfer Matlab v0.7.0
==================
- Breaking: Renamed records field `text` of Sets to `element_text`.
- Added symbol `UniverseAlias` to represent alises to the universe set.
- Added possibility to change symbol name case with `Container.renameSymbol`.
- Added possibility to reorder UELs by record order with `Symbol.reorderUELs` (passing no
  arguments).
- Added `Container.getSets`, `Container.getParameters`, `Container.getVariables`,
  `Container.getEquations` and `Container.getAliases` to get list of symbol objects of corresponding
  type.
- Added possibility to get/remove all symbols with `Container.getSymbols` or
  `Container.removeSymbols`, respectively.
- Added `Container.lowerUELs`, `Container.upperUELs`, `Symbol.lowerUELs` and `Symbol.upperUELs` to
  convert (all) UELs to lower or upper case, respectively.
- Added GDX library unload before each read/write operation.
- Added columns `where_min` and `where_max` to output of `Container.describeParameters`.
- Changed used GDX library to `gdxcclib64`.
- Changed column names in output of `Container.describe*` methods: `dim` -> `dimension`, `num_recs`
  -> `number_records`, `num_vals` -> `number_values`, `min_value` -> `min`, `max_value` -> `max`,
  `mean_value` -> `mean`.
- Removed `*_marginal`, `count_*`, `where_max_abs_value` and `is_alias` columns in output of
  `Container.describe*` methods.
- Removed `ConstContainer`.
- Fixed bug that limited the number of used UELs in `Symbol.transformRecords` and `Symbol.getUELs`.
- Fixed `Container.eq` in case of containers with different number of symbols.

GAMS Transfer Matlab v0.6.0
==================
- Breaking: `Symbol.domain_labels` now mirrors the column or field names for domains in
  `Symbol.records`. Changing `Symbol.domain_labels` will change `Symbol.records` and vice versa.
  `Symbol.domain_labels` now exists in `struct` and `table` format only. Domain fields in records
  are those fields that are not one of the following:
    - Variables and equations: `level`, `marginal`, `lower`, `upper`, `scale`.
    - Parameters: `value`.
    - Sets: `text`.

GAMS Transfer Matlab v0.5.0
==================
- Breaking: Changed default `Symbol.domain_labels`: If `Symbol.domain_names` is a unqiue list of
  domain names, then those names are used as domain labels. Otherwise, the previous label strategy
  "<name>_<dim>" is used. For example, a symbol with domain `{i, j}`, now expects domain labels `i`
  and `j` in records and with a domain `{i, j, i}` it stays `i_1`, `j_2`, `i_3`.
- Added possibility to modify `Symbol.domain_labels` to any unqiue list of domain labels. If
  `Symbol.domain` is modified, domain labels are reset to default label strategy, described above.
- Changed `Symbol.domain_forwarding` to be a vector of length `Symbol.dimension` to enable/disable
  domain forwarding for each dimension independently.
- Removed `Symbol.getCardinality`, `Symbol.getUELLabels`, `Symbol.initUELs` and
  `Container.getUniverseSet`.
- Fixed possibly incorrect order of UELs of symbols in `dense_matrix` or `sparse_matrix` format.
- Fixed `Symbol.setRecords` for cell input and symbols of dimension >= 3.

GAMS Transfer Matlab v0.4.0
==================
- Improved performance of `Container.hasSymbols`. Among others, this has a significant effect when
  adding many symbols.
- Added support of partial write.
- Added parameter `symbols` to `Container.write`, `Container.getDomainViolations`,
  `Container.resolveDomainViolations` and `Container.isValid`.
- Added parameter `allow_merge` to `Container.renameUELs` and `Symbol.renameUELs` in order support
  merging UELs while renaming (renaming a UEL to an already existing UEL).

GAMS Transfer Matlab v0.3.0
==================
- Breaking: Symbol name uniqueness is now checked case insensitively. For example, it is not
  possible anymore to have two different symbols named `symbol` and `Symbol` or `SYMBOL`.
- Breaking: Changed `Symbol.addUELs` signature from `addUELs(dim, uels)` to `addUELs(uels, dim)`.
  `dim` is now allowed to accept a vector of dimensions.
- Breaking: Changed `Symbol.setUELs` signature from `setUELs(dim, uels)` to `setUELs(uels, dim)` and
  `setUELS(_, 'rename', true/false)`. Setting `rename` to `true` triggers the old `Symbol.initUELs`.
  `dim` is now allowed to accept a vector of dimensions.
- Breaking: Changed `Symbol.removeUELs` signature from `removeUELs(dim, uels)` to `removeUELs()`,
  `removeUELs(uels)` and `removeUELs(uels, dim)`. `dim` is now allowed to accept a vector of
  dimensions.
- Breaking: Changed `Symbol.renameUELs` signature from `renameUELs(dim, olduels, newuels)` to
  `renameUELs(uels)` and `renameUELs(uels, dim)`. `uels` can now be `cellstr`, `struct` or
  `containers.Map`. `dim` is now allowed to accept a vector of dimensions.
- Added method `Container.getSymbolNames` to return the original symbol names for a list of symbol
  names of any case.
- Added method `Container.hasSymbols` to check if symbol name (case insensitive) exists.
- Added method `Container.getUELs` to get UELs from all symbols.
- Added method `Container.removeUELs` to remove UELs from all symbols.
- Added method `Container.renameUELs` to rename UELs in all symbols.
- Added method `Symbol.reorderUELs` to reorder UELs without changing the meaning of records.
- Added flags `Container.modified` and `Symbol.modified` to indicate if a container and/or symbol
  has been modified since last reset.
- Added possibility to filter UEL codes in `Symbol.getUELs`.
- Added possibility to pass a vector of dimensions to `Symbol.getUELs`.
- Added possibility to overwrite symbols with `Container.add*` if main symbol definition (e.g. type,
  domain) is equal.
- Changed `Container.getSymbols`, `Container.removeSymbol`, `Container.renameSymbol`,
  `Container.describe*` and others that use `Container.getSymbols` to accept symbol names case
  insensitively.
- Changed behaviour of default records: Default records do not get written to GDX anymore if the
  records format is `dense_matrix` and either the container is in indexed mode or if the symbol has
  a regular domain.
- Changed behaviour of `getDomainViolations`: As in GDX different character case does not lead to a
  domain violation.
- Categoricals for record domain labels are now created with `Ordinal` set to `true`, but ordinal
  categoricals are not enforced, i.e. users may pass categoricals with `Ordinal` set to `false`.
- Changed symbol read order when reading a subset of symbols: Symbol order is defined by source
  order (e.g. symbol order in GDX file) rather than user supplied order. To establish a custom order
  after the read, use `reorderSymbols`.
- Aliases are now removed if the aliased set is removed.
- Domains are now set to `*` (universe) if the domain set is removed.
- Deprecated `Symbol.getUELLabels`. Use `Symbol.getUELs` instead.
- Deprecated `Symbol.initUELs`. Use `Symbol.setUELs` instead.
- Deprecated `Container.getUniverseSet`. Use `Container.getUELs` instead.
- Fixed failing symbol constructors when using `domain_forwarding`, but none of the optional
  arguments.
- Fixed `Symbol.transformRecords` (table-like to matrix-like formats) in case the domain set records
  and UELs differ.
- Fixed write of sets defined over sets.

GAMS Transfer Matlab v0.2.2
==================
- Fixed read of equation with unknown subtype (recast as `=e=`).
- Fixed partial read of symbols in indexed container.
- Fixed `equals` method in indexed container.
- Fixed possible segfault when reading a subset of symbols as dense matrix with at least one scalar
  symbol.

GAMS Transfer Matlab v0.2.1
==================
- Fixed read of variable with unknown subtype (recast as free).
- Fixed check of variable type on variable creation.
- Fixed `isEps`, `isNA` and `isUndef` of `SpecialValues` for sparse matrix input.
- Fixed default values of external, conic and boolean equations.

GAMS Transfer Matlab v0.2.0
==================
- Added documentation.
- Added "equals" method to Container and Symbol classes to compare containers or. symbols.
- Added "copy" method to Symbol classes to copy symbols to another container.
- Added support to read symbols directly from non-const container.

GAMS Transfer Matlab v0.1.0
==================
- First release
