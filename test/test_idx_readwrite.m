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

function success = test_idx_readwrite(cfg)
    t = GAMSTest('idx_readwrite_c');
    test_idx_read(t, cfg, 'c');
    test_idx_readSpecialValues(t, cfg, 'c');
    test_idx_readWrite(t, cfg);
    [~, n_fails1] = t.summary();

    t = GAMSTest('idx_readwrite_cc');
    test_idx_read(t, cfg, 'cc');
    test_idx_readSpecialValues(t, cfg, 'cc');
    [~, n_fails2] = t.summary();

    t = GAMSTest('idx_readwrite_rcc');
    test_idx_read(t, cfg, 'rcc');
    test_idx_readSpecialValues(t, cfg, 'rcc');
    [~, n_fails3] = t.summary();

    success = n_fails1 + n_fails2 + n_fails3 == 0;
end

function test_idx_read(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container(cfg.filenames{4}, 'gams_dir', ...
            cfg.gams_dir, 'indexed', true, 'features', cfg.features);
    case 'cc'
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{4}, 'gams_dir', ...
            cfg.gams_dir, 'indexed', true, 'features', cfg.features);
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, ...
            'indexed', true, 'features', cfg.features);
        gdx.read(cfg.filenames{4});
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, ...
            'indexed', true, 'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('idx_read_basic_info');
    t.assertEquals(gdx.gams_dir, cfg.gams_dir);
    t.assert(gdx.indexed);
    t.assert(numel(fieldnames(gdx.data)) == 3);

    t.add('idx_read_scalar_basic');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    if is_const_cont
        t.assertEquals(s.symbol_type, 'parameter');
    else
        t.assert(isa(s, 'GAMSTransfer.Parameter'));
    end
    t.assertEquals(s.name, 'a');
    t.assertEquals(s.description, 'par_a');
    t.assert(s.dimension == 0);
    t.assert(numel(s.domain) == 0);
    t.assert(numel(s.domain_labels) == 0);
    t.assertEquals(s.domain_type, 'relaxed');
    t.assert(numel(s.size) == 0);
    if is_const_cont
        t.assert(~isnan(s.sparsity));
        t.assert(s.number_records == 1);
    else
        t.assert(s.getCardenality() == 1);
        t.assert(~isnan(s.getSparsity()));
        t.assert(s.getNumberRecords() == 1);
        t.assert(s.isValid());
    end

    t.add('idx_read_parameter_1d_basic');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    if is_const_cont
        t.assertEquals(s.symbol_type, 'parameter');
    else
        t.assert(isa(s, 'GAMSTransfer.Parameter'));
    end
    t.assertEquals(s.name, 'b');
    t.assertEquals(s.description, 'par_b');
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, 'dim_1');
    t.assert(numel(s.domain_labels) == 1);
    t.assertEquals(s.domain_labels{1}, 'dim_1');
    t.assertEquals(s.domain_type, 'relaxed');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 5);
    if is_const_cont
        t.assert(~isnan(s.sparsity));
        t.assert(s.number_records == 3);
    else
        t.assert(s.getCardenality() == 5);
        t.assert(~isnan(s.getSparsity()));
        t.assert(s.getNumberRecords() == 3);
        t.assert(s.isValid());
    end

    t.add('indexed_parameter_2d_basic');
    t.assert(isfield(gdx.data, 'c'));
    s = gdx.data.c;
    if is_const_cont
        t.assertEquals(s.symbol_type, 'parameter');
    else
        t.assert(isa(s, 'GAMSTransfer.Parameter'));
    end
    t.assertEquals(s.name, 'c');
    t.assertEquals(s.description, 'par_c');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain) == 2);
    t.assertEquals(s.domain{1}, 'dim_1');
    t.assertEquals(s.domain{2}, 'dim_2');
    t.assert(numel(s.domain_labels) == 2);
    t.assertEquals(s.domain_labels{1}, 'dim_1');
    t.assertEquals(s.domain_labels{2}, 'dim_2');
    t.assertEquals(s.domain_type, 'relaxed');
    t.assert(numel(s.size) == 2);
    t.assert(s.size(1) == 5);
    t.assert(s.size(2) == 10);
    if is_const_cont
        t.assert(~isnan(s.sparsity));
        t.assert(s.number_records == 3);
    else
        t.assert(s.getCardenality() == 50);
        t.assert(~isnan(s.getSparsity()));
        t.assert(s.getNumberRecords() == 3);
        t.assert(s.isValid());
    end

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'struct');
    case 'cc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'struct');
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'struct');
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('idx_read_scalar_records_struct');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('idx_read_parameter_1d_records_struct');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'dim_1'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.dim_1) == 3);
    t.assert(numel(s.records.value) == 3);
    t.assert(s.records.dim_1(1) == 1);
    t.assert(s.records.dim_1(2) == 3);
    t.assert(s.records.dim_1(3) == 5);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 5);

    t.add('indexed_parameter_2d_records_struct');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 3);
    t.assert(isfield(s.records, 'dim_1'));
    t.assert(isfield(s.records, 'dim_2'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.dim_1) == 3);
    t.assert(numel(s.records.dim_2) == 3);
    t.assert(numel(s.records.value) == 3);
    t.assert(s.records.dim_1(1) == 1);
    t.assert(s.records.dim_1(2) == 3);
    t.assert(s.records.dim_1(3) == 4);
    t.assert(s.records.dim_2(1) == 6);
    t.assert(s.records.dim_2(2) == 7);
    t.assert(s.records.dim_2(3) == 9);
    t.assert(s.records.value(1) == 16);
    t.assert(s.records.value(2) == 37);
    t.assert(s.records.value(3) == 49);

    if gdx.features.table
        switch container_type
        case 'c'
            gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
            gdx.read(cfg.filenames{4}, 'format', 'table');
        case 'cc'
            gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
            gdx.read(cfg.filenames{4}, 'format', 'table');
        case 'rcc'
            gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
            gdx.read(cfg.filenames{4}, 'format', 'table');
            gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
        end
        is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

        t.add('indexed_scalar_records_table');
        s = gdx.data.a;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        if ~is_const_cont
            t.assert(s.isValid());
        end
        t.assert(numel(s.records.Properties.VariableNames) == 1);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'value');
        t.assert(numel(s.records.value) == 1);
        t.assert(s.records.value == 4);

        t.add('indexed_parameter_1d_records_table');
        s = gdx.data.b;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        if ~is_const_cont
            t.assert(s.isValid());
        end
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'dim_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'value');
        t.assert(numel(s.records.dim_1) == 3);
        t.assert(numel(s.records.value) == 3);
        t.assert(s.records.dim_1(1) == 1);
        t.assert(s.records.dim_1(2) == 3);
        t.assert(s.records.dim_1(3) == 5);
        t.assert(s.records.value(1) == 1);
        t.assert(s.records.value(2) == 3);
        t.assert(s.records.value(3) == 5);

        t.add('indexed_parameter_2d_records_table');
        s = gdx.data.c;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        if ~is_const_cont
            t.assert(s.isValid());
        end
        t.assert(numel(s.records.Properties.VariableNames) == 3);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'dim_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'dim_2');
        t.assertEquals(s.records.Properties.VariableNames{3}, 'value');
        t.assert(numel(s.records.dim_1) == 3);
        t.assert(numel(s.records.dim_2) == 3);
        t.assert(numel(s.records.value) == 3);
        t.assert(s.records.dim_1(1) == 1);
        t.assert(s.records.dim_1(2) == 3);
        t.assert(s.records.dim_1(3) == 4);
        t.assert(s.records.dim_2(1) == 6);
        t.assert(s.records.dim_2(2) == 7);
        t.assert(s.records.dim_2(3) == 9);
        t.assert(s.records.value(1) == 16);
        t.assert(s.records.value(2) == 37);
        t.assert(s.records.value(3) == 49);
    end

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
    case 'cc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('indexed_scalar_records_dense_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('indexed_parameter_1d_records_dense_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'dense_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 5);
    t.assert(size(s.records.value, 1) == 5);
    t.assert(size(s.records.value, 2) == 1);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 0);
    t.assert(s.records.value(3) == 3);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 5);

    t.add('indexed_parameter_2d_records_dense_matrix');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'dense_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 50);
    t.assert(size(s.records.value, 1) == s.size(1));
    t.assert(size(s.records.value, 2) == s.size(2));
    t.assert(s.records.value(1,6) == 16);
    t.assert(s.records.value(3,7) == 37);
    t.assert(s.records.value(3,2) == 0);
    t.assert(s.records.value(3,5) == 0);
    t.assert(s.records.value(4,9) == 49);
    t.assert(s.records.value(4,10) == 0);
    t.assert(s.records.value(5,1) == 0);
    t.assert(s.records.value(5,3) == 0);
    t.assert(s.records.value(5,9) == 0);

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
    case 'cc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('indexed_scalar_records_sparse_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == 1);
    t.assert(nnz(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('indexed_parameter_1d_records_sparse_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == s.size(1));
    t.assert(nnz(s.records.value) == 3);
    t.assert(size(s.records.value, 1) == s.size(1));
    t.assert(size(s.records.value, 2) == 1);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 0);
    t.assert(s.records.value(3) == 3);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 5);

    t.add('indexed_parameter_2d_records_sparse_matrix');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    if ~is_const_cont
        t.assert(s.isValid());
    end
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == s.size(1)*s.size(2));
    t.assert(nnz(s.records.value) == 3);
    t.assert(size(s.records.value, 1) == s.size(1));
    t.assert(size(s.records.value, 2) == s.size(2));
    t.assert(s.records.value(1,6) == 16);
    t.assert(s.records.value(3,7) == 37);
    t.assert(s.records.value(3,2) == 0);
    t.assert(s.records.value(3,5) == 0);
    t.assert(s.records.value(4,9) == 49);
    t.assert(s.records.value(4,10) == 0);
    t.assert(s.records.value(5,1) == 0);
    t.assert(s.records.value(5,3) == 0);
    t.assert(s.records.value(5,9) == 0);
end

function test_idx_readEquals(t, cfg, container_type)

    for i = [2,4]
        switch container_type
        case 'c'
            gdx1 = GAMSTransfer.Container(cfg.filenames{i}, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
            gdx2 = GAMSTransfer.Container(cfg.filenames{i}, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
        case 'cc'
            gdx1 = GAMSTransfer.ConstContainer(cfg.filenames{i}, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
            gdx2 = GAMSTransfer.ConstContainer(cfg.filenames{i}, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
        case 'rcc'
            gdx1 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
            gdx1.read(cfg.filenames{i});
            gdx1 = GAMSTransfer.Container(gdx1, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
            gdx2 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
            gdx2.read(cfg.filenames{i});
            gdx2 = GAMSTransfer.Container(gdx2, 'gams_dir', cfg.gams_dir, ...
                'indexed', true, 'features', cfg.features);
        end
        is_const_cont = isa(gdx1, 'GAMSTransfer.ConstContainer');

        t.add(sprintf('idx_read_equals_%d', i));
        t.assert(gdx1.equals(gdx2));
    end
end

function test_idx_readSpecialValues(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{2}, 'format', 'struct');
    case 'cc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{2}, 'format', 'struct');
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{2}, 'format', 'struct');
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('idx_read_special_values');
    t.assert(isfield(gdx.data, 'GUndef'));
    t.assert(isfield(gdx.data, 'GNA'));
    t.assert(isfield(gdx.data, 'GPInf'));
    t.assert(isfield(gdx.data, 'GMInf'));
    t.assert(isfield(gdx.data, 'GEps'));
    if is_const_cont
        t.assertEquals(gdx.data.GUndef.symbol_type, 'parameter');
        t.assertEquals(gdx.data.GNA.symbol_type, 'parameter');
        t.assertEquals(gdx.data.GPInf.symbol_type, 'parameter');
        t.assertEquals(gdx.data.GMInf.symbol_type, 'parameter');
        t.assertEquals(gdx.data.GEps.symbol_type, 'parameter');
    else
        t.assert(isa(gdx.data.GUndef, 'GAMSTransfer.Parameter'));
        t.assert(isa(gdx.data.GNA, 'GAMSTransfer.Parameter'));
        t.assert(isa(gdx.data.GPInf, 'GAMSTransfer.Parameter'));
        t.assert(isa(gdx.data.GMInf, 'GAMSTransfer.Parameter'));
        t.assert(isa(gdx.data.GEps, 'GAMSTransfer.Parameter'));
    end
    t.assert(isstruct(gdx.data.GUndef.records));
    t.assert(isstruct(gdx.data.GNA.records));
    t.assert(isstruct(gdx.data.GPInf.records));
    t.assert(isstruct(gdx.data.GMInf.records));
    t.assert(isstruct(gdx.data.GEps.records));
    t.assert(isnan(gdx.data.GUndef.records.value));
    t.assert(isnan(gdx.data.GNA.records.value));
    t.assert(GAMSTransfer.SpecialValues.isNA(gdx.data.GNA.records.value));
    t.assert(gdx.data.GPInf.records.value == Inf);
    t.assert(gdx.data.GMInf.records.value == -Inf);

    % doesn't return 0 ("bug" in IDX API (special values already translated))
    % t.assert(gdx.data.GEps.records.value == 0);
    % t.assert(GAMSTransfer.SpecialValues.iseps(gdx.data.GEps.records.value));
end

function test_idx_readWrite(t, cfg)

    for i = [2,4]
        write_filename = fullfile(cfg.working_dir, 'write.gdx');
        gdxdump = fullfile(cfg.gams_dir, 'gdxdump');

        t.add(sprintf('idx_read_write_struct_%d', i));
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{i}, 'format', 'struct');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        if gdx.features.table
            t.add(sprintf('idx_read_write_table_%d', i));
            gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
            gdx.read(cfg.filenames{i}, 'format', 'table');
            gdx.write(write_filename);
            t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
            t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
        end

        t.add(sprintf('idx_read_write_dense_matrix_%d', i));
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{i}, 'format', 'dense_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        t.add(sprintf('idx_read_write_sparse_matrix_%d', i));
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{i}, 'format', 'sparse_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
    end
end
