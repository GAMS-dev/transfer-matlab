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

function test_idx_readwrite(t, cfg)
    test_idx_read(t, cfg);
    test_idx_readSpecialValues(t, cfg);
    test_idx_readWrite(t, cfg);
end

function test_idx_read(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{4}, 'indexed', true);

    t.add('idx_read_basic_info');
    t.assertEquals(gdx.system_directory, cfg.system_dir);
    t.assertEquals(gdx.filename, cfg.filenames{4});
    t.assert(gdx.indexed);
    t.assert(numel(fieldnames(gdx.data)) == 3);

    t.add('idx_read_scalar_basic');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Parameter'));
    t.assertEquals(s.name, 'a');
    t.assertEquals(s.description, 'par_a');
    t.assert(s.dimension == 0);
    t.assert(numel(s.domain) == 0);
    t.assert(numel(s.domain_label) == 0);
    t.assertEquals(s.domain_info, 'relaxed');
    t.assert(numel(s.size) == 0);
    t.assert(s.sparsity == 0);
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.number_records == 1);
    t.assert(numel(fieldnames(s.uels)) == 0);
    t.assert(~s.is_valid);

    t.add('idx_read_parameter_1d_basic');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Parameter'));
    t.assertEquals(s.name, 'b');
    t.assertEquals(s.description, 'par_b');
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, 'dim_1');
    t.assert(numel(s.domain_label) == 1);
    t.assertEquals(s.domain_label{1}, 'dim_1');
    t.assertEquals(s.domain_info, 'relaxed');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 5);
    t.assert(s.sparsity == 1 - 3/5);
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.number_records == 3);
    t.assert(numel(fieldnames(s.uels)) == 1);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assertEquals(s.uels.dim_1, {});
    t.assert(~s.is_valid);

    t.add('indexed_parameter_2d_basic');
    t.assert(isfield(gdx.data, 'c'));
    s = gdx.data.c;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Parameter'));
    t.assertEquals(s.name, 'c');
    t.assertEquals(s.description, 'par_c');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain) == 2);
    t.assertEquals(s.domain{1}, 'dim_1');
    t.assertEquals(s.domain{2}, 'dim_2');
    t.assert(numel(s.domain_label) == 2);
    t.assertEquals(s.domain_label{1}, 'dim_1');
    t.assertEquals(s.domain_label{2}, 'dim_2');
    t.assertEquals(s.domain_info, 'relaxed');
    t.assert(numel(s.size) == 2);
    t.assert(s.size(1) == 5);
    t.assert(s.size(2) == 10);
    t.assert(s.sparsity == 1 - 3/50);
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.number_records == 3);
    t.assert(numel(fieldnames(s.uels)) == 2);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(isfield(s.uels, 'dim_2'));
    t.assertEquals(s.uels.dim_1, {});
    t.assertEquals(s.uels.dim_2, {});
    t.assert(~s.is_valid);

    gdx.read('format', 'struct');

    t.add('idx_read_scalar_records_struct');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(s.records.value == 4);
    t.assert(numel(fieldnames(s.uels)) == 0);

    t.add('idx_read_parameter_1d_records_struct');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'dim_1'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.dim_1) == s.number_records);
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(s.records.dim_1(1) == 1);
    t.assert(s.records.dim_1(2) == 3);
    t.assert(s.records.dim_1(3) == 5);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 5);
    t.assert(numel(fieldnames(s.uels)) == 1);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(numel(s.uels.dim_1) == 0);

    t.add('indexed_parameter_2d_records_struct');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 3);
    t.assert(isfield(s.records, 'dim_1'));
    t.assert(isfield(s.records, 'dim_2'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.dim_1) == s.number_records);
    t.assert(numel(s.records.dim_2) == s.number_records);
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(s.records.dim_1(1) == 1);
    t.assert(s.records.dim_1(2) == 3);
    t.assert(s.records.dim_1(3) == 4);
    t.assert(s.records.dim_2(1) == 6);
    t.assert(s.records.dim_2(2) == 7);
    t.assert(s.records.dim_2(3) == 9);
    t.assert(s.records.value(1) == 16);
    t.assert(s.records.value(2) == 37);
    t.assert(s.records.value(3) == 49);
    t.assert(numel(fieldnames(s.uels)) == 2);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(isfield(s.uels, 'dim_2'));
    t.assert(numel(s.uels.dim_1) == 0);
    t.assert(numel(s.uels.dim_2) == 0);

    if gdx.features.table
        gdx.read('format', 'table');

        t.add('indexed_scalar_records_table');
        s = gdx.data.a;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.is_valid);
        t.assert(numel(s.records.Properties.VariableNames) == 1);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'value');
        t.assert(numel(s.records.value) == s.number_records);
        t.assert(s.records.value == 4);
        t.assert(numel(fieldnames(s.uels)) == 0);

        t.add('indexed_parameter_1d_records_table');
        s = gdx.data.b;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.is_valid);
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'dim_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'value');
        t.assert(numel(s.records.dim_1) == s.number_records);
        t.assert(numel(s.records.value) == s.number_records);
        t.assert(s.records.dim_1(1) == 1);
        t.assert(s.records.dim_1(2) == 3);
        t.assert(s.records.dim_1(3) == 5);
        t.assert(s.records.value(1) == 1);
        t.assert(s.records.value(2) == 3);
        t.assert(s.records.value(3) == 5);
        t.assert(numel(fieldnames(s.uels)) == 1);
        t.assert(isfield(s.uels, 'dim_1'));
        t.assert(numel(s.uels.dim_1) == 0);

        t.add('indexed_parameter_2d_records_table');
        s = gdx.data.c;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.is_valid);
        t.assert(numel(s.records.Properties.VariableNames) == 3);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'dim_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'dim_2');
        t.assertEquals(s.records.Properties.VariableNames{3}, 'value');
        t.assert(numel(s.records.dim_1) == s.number_records);
        t.assert(numel(s.records.dim_2) == s.number_records);
        t.assert(numel(s.records.value) == s.number_records);
        t.assert(s.records.dim_1(1) == 1);
        t.assert(s.records.dim_1(2) == 3);
        t.assert(s.records.dim_1(3) == 4);
        t.assert(s.records.dim_2(1) == 6);
        t.assert(s.records.dim_2(2) == 7);
        t.assert(s.records.dim_2(3) == 9);
        t.assert(s.records.value(1) == 16);
        t.assert(s.records.value(2) == 37);
        t.assert(s.records.value(3) == 49);
        t.assert(numel(fieldnames(s.uels)) == 2);
        t.assert(isfield(s.uels, 'dim_1'));
        t.assert(isfield(s.uels, 'dim_2'));
        t.assert(numel(s.uels.dim_1) == 0);
        t.assert(numel(s.uels.dim_2) == 0);
    end

    gdx.read('format', 'dense_matrix');

    t.add('indexed_scalar_records_dense_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(s.records.value == 4);
    t.assert(numel(fieldnames(s.uels)) == 0);

    t.add('indexed_parameter_1d_records_dense_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'dense_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(size(s.records.value, 1) == s.number_records);
    t.assert(size(s.records.value, 2) == 1);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 0);
    t.assert(s.records.value(3) == 3);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 5);
    t.assert(numel(fieldnames(s.uels)) == 1);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(numel(s.uels.dim_1) == 0);

    t.add('indexed_parameter_2d_records_dense_matrix');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'dense_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == s.number_records);
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
    t.assert(numel(fieldnames(s.uels)) == 2);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(isfield(s.uels, 'dim_2'));
    t.assert(numel(s.uels.dim_1) == 0);
    t.assert(numel(s.uels.dim_2) == 0);

    gdx.read('format', 'sparse_matrix');

    t.add('indexed_scalar_records_dense_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == s.number_records);
    t.assert(nnz(s.records.value) == s.number_records);
    t.assert(s.records.value == 4);
    t.assert(numel(fieldnames(s.uels)) == 0);

    t.add('indexed_parameter_1d_records_dense_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == s.size(1));
    t.assert(nnz(s.records.value) == s.number_records);
    t.assert(size(s.records.value, 1) == s.size(1));
    t.assert(size(s.records.value, 2) == 1);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 0);
    t.assert(s.records.value(3) == 3);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 5);
    t.assert(numel(fieldnames(s.uels)) == 1);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(numel(s.uels.dim_1) == 0);

    t.add('indexed_parameter_2d_records_dense_matrix');
    s = gdx.data.c;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.is_valid);
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == s.size(1)*s.size(2));
    t.assert(nnz(s.records.value) == s.number_records);
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
    t.assert(numel(fieldnames(s.uels)) == 2);
    t.assert(isfield(s.uels, 'dim_1'));
    t.assert(isfield(s.uels, 'dim_2'));
    t.assert(numel(s.uels.dim_1) == 0);
    t.assert(numel(s.uels.dim_2) == 0);
end

function test_idx_readSpecialValues(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{2}, 'indexed', true);
    gdx.read('format', 'struct');

    t.add('idx_read_special_values');
    t.assert(isfield(gdx.data, 'GUndef'));
    t.assert(isfield(gdx.data, 'GNA'));
    t.assert(isfield(gdx.data, 'GPInf'));
    t.assert(isfield(gdx.data, 'GMInf'));
    t.assert(isfield(gdx.data, 'GEps'));
    t.assert(isa(gdx.data.GUndef, 'GAMSTransfer.Parameter'));
    t.assert(isa(gdx.data.GNA, 'GAMSTransfer.Parameter'));
    t.assert(isa(gdx.data.GPInf, 'GAMSTransfer.Parameter'));
    t.assert(isa(gdx.data.GMInf, 'GAMSTransfer.Parameter'));
    t.assert(isa(gdx.data.GEps, 'GAMSTransfer.Parameter'));
    t.assert(isstruct(gdx.data.GUndef.records));
    t.assert(isstruct(gdx.data.GNA.records));
    t.assert(isstruct(gdx.data.GPInf.records));
    t.assert(isstruct(gdx.data.GMInf.records));
    t.assert(isstruct(gdx.data.GEps.records));
    t.assert(isnan(gdx.data.GUndef.records.value));
    t.assert(isnan(gdx.data.GNA.records.value));
    t.assert(GAMSTransfer.isna(gdx.data.GNA.records.value));
    t.assert(gdx.data.GPInf.records.value == Inf);
    t.assert(gdx.data.GMInf.records.value == -Inf);

    % doesn't return 0 (bug in IDX API (special values already translated): steve says 'no bug'; renke says 'definitely bug')
    % t.assert(gdx.data.GEps.records.value == 0);
    % t.assert(GAMSTransfer.iseps(gdx.data.GEps.records.value));
end

function test_idx_readWrite(t, cfg)

    for i = [2,4]
        gdx = GAMSTransfer.Container(cfg.filenames{i}, 'indexed', true);
        write_filename = fullfile(cfg.working_dir, 'write.gdx');

        t.add(sprintf('idx_read_write_struct_%d', i));
        gdx.read('format', 'struct');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);

        if gdx.features.table
            t.add(sprintf('idx_read_write_table_%d', i));
            gdx.read('format', 'table');
            gdx.write(write_filename);
            t.testGdxDiff(cfg.filenames{i}, write_filename);
        end

        t.add(sprintf('idx_read_write_dense_matrix_%d', i));
        gdx.read('format', 'dense_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);

        t.add(sprintf('idx_read_write_sparse_matrix_%d', i));
        gdx.read('format', 'sparse_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);
    end
end
