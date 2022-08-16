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

function success = test_idx_symbols(cfg)
    t = GAMSTest('idx_symbols');
    test_idx_addSymbols(t, cfg);
    test_idx_changeSymbol(t, cfg);
    test_idx_copySymbol(t, cfg);
    test_idx_setRecords(t, cfg);
    test_idx_writeUnordered(t, cfg);
    test_idx_transformRecords(t, cfg);
    [~, n_fails] = t.summary();
    success = n_fails == 0;
end

function test_idx_addSymbols(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'indexed', true, 'features', cfg.features);

    t.add('idx_add_symbols_parameter_1');
    p1 = GAMSTransfer.Parameter(gdx, 'p1');
    t.testEmptySymbol(p1);
    t.assertEquals(p1.name, 'p1');
    t.assertEquals(p1.description, '');
    t.assert(p1.dimension == 0);
    t.assert(numel(p1.domain) == 0);
    t.assert(numel(p1.domain_names) == 0);
    t.assert(numel(p1.domain_labels) == 0);
    t.assertEquals(p1.domain_type, 'relaxed');
    t.assert(numel(p1.size) == 0);
    t.assert(strcmp(p1.format, 'empty'));
    t.assert(p1.getNumberRecords() == 0);
    t.assert(p1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 'p1'));
    t.assert(gdx.data.p1.id == p1.id);

    t.add('idx_add_symbols_parameter_2');
    p2 = GAMSTransfer.Parameter(gdx, 'p2', 0, 'description', 'descr par 2');
    t.testEmptySymbol(p2);
    t.assertEquals(p2.name, 'p2');
    t.assertEquals(p2.description, 'descr par 2');
    t.assert(p2.dimension == 1);
    t.assert(numel(p2.domain) == 1);
    t.assertEquals(p2.domain{1}, 'dim_1');
    t.assert(numel(p2.domain_names) == 1);
    t.assertEquals(p2.domain_names{1}, 'dim_1');
    t.assert(numel(p2.domain_labels) == 1);
    t.assertEquals(p2.domain_labels{1}, 'dim_1');
    t.assertEquals(p2.domain_type, 'relaxed');
    t.assert(numel(p2.size) == 1);
    t.assert(p2.size(1) == 0);
    t.assert(strcmp(p2.format, 'empty'));
    t.assert(p2.getNumberRecords() == 0);
    t.assert(p2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 'p2'));
    t.assert(gdx.data.p2.id == p2.id);

    t.add('idx_add_symbols_parameter_3');
    p3 = GAMSTransfer.Parameter(gdx, 'p3', [1,2,3], 'description', 'descr par 3');
    t.testEmptySymbol(p3);
    t.assertEquals(p3.name, 'p3');
    t.assertEquals(p3.description, 'descr par 3');
    t.assert(p3.dimension == 3);
    t.assert(numel(p3.domain) == 3);
    t.assertEquals(p3.domain{1}, 'dim_1');
    t.assertEquals(p3.domain{2}, 'dim_2');
    t.assertEquals(p3.domain{3}, 'dim_3');
    t.assert(numel(p3.domain_names) == 3);
    t.assertEquals(p3.domain_names{1}, 'dim_1');
    t.assertEquals(p3.domain_names{2}, 'dim_2');
    t.assertEquals(p3.domain_names{3}, 'dim_3');
    t.assert(numel(p3.domain_labels) == 3);
    t.assertEquals(p3.domain_labels{1}, 'dim_1');
    t.assertEquals(p3.domain_labels{2}, 'dim_2');
    t.assertEquals(p3.domain_labels{3}, 'dim_3');
    t.assertEquals(p3.domain_type, 'relaxed');
    t.assert(numel(p3.size) == 3);
    t.assert(p3.size(1) == 1);
    t.assert(p3.size(2) == 2);
    t.assert(p3.size(3) == 3);
    t.assert(strcmp(p3.format, 'empty'));
    t.assert(p3.getNumberRecords() == 0);
    t.assert(p3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'p3'));
    t.assert(gdx.data.p3.id == p3.id);

    t.add('idx_add_symbols_parameter_fails');
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, p1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 's', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            GAMSTransfer.Parameter(gdx, 's', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 's', 5, 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 's', p3);
    catch
        t.reset();
    end

    t.add('idx_add_symbols_set');
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's1');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Set not allowed in indexed mode.');
    end

    t.add('idx_add_symbols_variable');
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 'v1');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Variable not allowed in indexed mode.');
    end

    t.add('idx_add_symbols_equation');
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 'e1', 'n');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Equation not allowed in indexed mode.');
    end

end

function test_idx_changeSymbol(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'indexed', true, 'features', cfg.features);
    p1 = GAMSTransfer.Parameter(gdx, 'p1', 5);
    p2 = GAMSTransfer.Parameter(gdx, 'p2', [5,10]);

    t.add('idx_change_symbol_name');
    t.assertEquals(p1.name, 'p1');
    t.assert(isfield(gdx.data, 'p1'));
    t.assert(~isfield(gdx.data, 'pp1'));
    pars = gdx.listParameters();
    t.assert(numel(pars) == 2);
    t.assertEquals(pars{1}, 'p1');
    p1.name = 'pp1';
    t.assertEquals(p1.name, 'pp1');
    t.assert(~isfield(gdx.data, 'p1'));
    t.assert(isfield(gdx.data, 'pp1'));
    pars = gdx.listParameters();
    t.assert(numel(pars) == 2);
    t.assertEquals(pars{1}, 'pp1');
    try
        t.assert(false);
        p1.name = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Name must be of type ''char''.');
    end
    try
        t.assert(false);
        p1.name = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Name must be of type ''char''.');
    end

    t.add('idx_change_symbol_description');
    t.assertEquals(p1.description, '');
    t.assertEquals(p2.description, '');
    p1.description = 'descr p1';
    t.assertEquals(p1.description, 'descr p1');
    t.assertEquals(p2.description, '');
    try
        t.assert(false);
        p1.description = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Description must be of type ''char''.');
    end
    try
        t.assert(false);
        p1.description = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Description must be of type ''char''.');
    end

    t.add('idx_change_symbol_dimension');
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.size) == 1);
    t.assert(p1.size(1) == 5);
    p1.dimension = 2;
    t.assert(p1.dimension == 2);
    t.assert(numel(p1.size) == 2);
    t.assert(numel(p1.domain) == 2);
    t.assert(p1.size(1) == 5);
    t.assert(p1.size(2) == 1);
    t.assertEquals(p1.domain{1}, 'dim_1');
    t.assertEquals(p1.domain{2}, 'dim_2');
    p1.dimension = 1;
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.size) == 1);
    t.assert(numel(p1.domain) == 1);
    t.assert(p1.size(1) == 5);
    t.assertEquals(p1.domain{1}, 'dim_1');
    try
        t.assert(false);
        p1.dimension = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be of type ''numeric''.');
    end
    try
        t.assert(false);
        p1.dimension = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be integer.');
    end
    try
        t.assert(false);
        p1.dimension = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be within [0,20].');
    end
    try
        t.assert(false);
        p1.dimension = 21;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be within [0,20].');
    end

    t.add('idx_change_symbol_domain');
    try
        p1.domain = {'dim_1', 'dim_2'};
        t.assert(false);
    catch e
        t.assertEquals(e.message, 'Setting symbol domain not allowed in indexed mode.');
    end

    t.add('idx_change_symbol_domain_label');
    try
        p1.domain_labels = {'dim_1'};
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            t.assert(~isempty(strfind(e.message, 'read-only')));
        end
    end

    t.add('idx_change_symbol_size');
    t.assert(numel(p1.size) == 1);
    t.assert(p1.size == 5);
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.domain) == 1);
    t.assert(numel(p1.domain_labels) == 1);
    p1.size = 10;
    t.assert(p1.size == 10);
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.domain) == 1);
    t.assert(numel(p1.domain_labels) == 1);
    p1.size = [10, 20];
    t.assert(p1.size(1) == 10);
    t.assert(p1.size(2) == 20);
    t.assert(p1.dimension == 2);
    t.assert(numel(p1.domain) == 2);
    t.assertEquals(p1.domain{1}, 'dim_1');
    t.assertEquals(p1.domain{2}, 'dim_2');
    t.assert(numel(p1.domain_labels) == 2);
    t.assertEquals(p1.domain_labels{1}, 'dim_1');
    t.assertEquals(p1.domain_labels{2}, 'dim_2');
    try
        t.assert(false);
        p1.size = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Size must be of type ''numeric''.');
    end
    try
        t.assert(false);
        p1.size = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Size must be integer.');
    end
    try
        t.assert(false);
        p1.size = nan;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Size must not be inf or nan.');
    end
    try
        t.assert(false);
        p1.size = inf;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Size must not be inf or nan.');
    end
    try
        t.assert(false);
        p1.size = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Size must be non-negative.');
    end

    t.add('idx_change_symbol_format');
    try
        p1.format = 'struct';
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            t.assert(~isempty(strfind(e.message, 'read-only')));
        end
    end
end

function test_idx_copySymbol(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
        'features', cfg.features);
    p = GAMSTransfer.Parameter(gdx, 'p', [10]);
    p.records.dim_1 = [2 4]';
    p.records.value = [1 2]';
    t.assert(p.isValid());

    t.add('idx_copy_symbol_parameter_empty');
    gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
        'features', cfg.features);
    p.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'p'));
    t.assertEquals(gdx2.data.p.name, 'p');
    t.assertEquals(gdx2.data.p.description, '');
    t.assert(gdx2.data.p.dimension == 1);
    t.assert(gdx2.data.p.size(1) == 10);
    t.assert(iscell(gdx2.data.p.domain));
    t.assert(numel(gdx2.data.p.domain) == 1);
    t.assertEquals(gdx2.data.p.domain{1}, 'dim_1');
    t.assertEquals(gdx2.data.p.domain_type, 'relaxed');
    t.assert(~gdx2.data.p.domain_forwarding);
    t.assertEquals(gdx2.data.p.format, 'struct');
    t.assert(isfield(gdx2.data.p.records, 'dim_1'));
    t.assert(isfield(gdx2.data.p.records, 'value'));
    t.assert(numel(gdx2.data.p.records.dim_1) == 2);
    t.assertEquals(gdx2.data.p.records.dim_1(1), 2);
    t.assertEquals(gdx2.data.p.records.dim_1(2), 4);
    t.assert(numel(gdx2.data.p.records.value) == 2);
    t.assert(gdx2.data.p.records.value(1) == 1);
    t.assert(gdx2.data.p.records.value(2) == 2);

    t.add('idx_copy_symbol_parameter_overwrite_1');
    gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
        'features', cfg.features);
    GAMSTransfer.Parameter(gdx2, 'p');
    p.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'p'));
    t.assertEquals(gdx2.data.p.name, 'p');
    t.assertEquals(gdx2.data.p.description, '');
    t.assert(gdx2.data.p.dimension == 1);
    t.assert(gdx2.data.p.size(1) == 10);
    t.assert(iscell(gdx2.data.p.domain));
    t.assert(numel(gdx2.data.p.domain) == 1);
    t.assertEquals(gdx2.data.p.domain{1}, 'dim_1');
    t.assertEquals(gdx2.data.p.domain_type, 'relaxed');
    t.assert(~gdx2.data.p.domain_forwarding);
    t.assertEquals(gdx2.data.p.format, 'struct');
    t.assert(isfield(gdx2.data.p.records, 'dim_1'));
    t.assert(isfield(gdx2.data.p.records, 'value'));
    t.assert(numel(gdx2.data.p.records.dim_1) == 2);
    t.assertEquals(gdx2.data.p.records.dim_1(1), 2);
    t.assertEquals(gdx2.data.p.records.dim_1(2), 4);
    t.assert(numel(gdx2.data.p.records.value) == 2);
    t.assert(gdx2.data.p.records.value(1) == 1);
    t.assert(gdx2.data.p.records.value(2) == 2);

    t.add('idx_copy_symbol_parameter_overwrite_2');
    gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
        'features', cfg.features);
    GAMSTransfer.Parameter(gdx2, 'p');
    try
        t.assert(false);
        p.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Symbol already exists in destination.');
    end

    t.add('idx_copy_symbol_parameter_indexed');
    gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', false, 'features', cfg.features);
    try
        t.assert(false);
        p.copy(gdx2);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Destination container must be indexed.');
    end

end

function test_idx_setRecords(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'indexed', true, 'features', cfg.features);

    p1 = GAMSTransfer.Parameter(gdx, 'p1', 5);

    t.add('set_records_string');
    try
        t.assert(false);
        p1.setRecords('test');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Strings not allowed in indexed mode.');
    end

    t.add('set_records_cellstr');
    try
        t.assert(false);
        p1.setRecords({'test1', 'test2', 'test3'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Strings not allowed in indexed mode.');
    end

    t.add('set_records_numeric_1');
    try
        t.assert(false);
        p1.setRecords([1; 2; 3; 4]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Records size doesn''t match symbol size.');
    end

    t.add('set_records_numeric_2');
    p1.setRecords([1; 2; 3; 4; 5]);
    t.assertEquals(p1.format, 'dense_matrix');
    t.assert(isstruct(p1.records));
    t.assert(numel(fieldnames(p1.records)) == 1);
    t.assert(isfield(p1.records, 'value'));
    t.assert(numel(p1.records.value) == 5);
    t.assert(p1.records.value(1) == 1);
    t.assert(p1.records.value(2) == 2);
    t.assert(p1.records.value(3) == 3);
    t.assert(p1.records.value(4) == 4);
    t.assert(p1.records.value(5) == 5);
    t.assert(p1.isValid());

    t.add('set_records_numeric_3');
    p1.setRecords(sparse([1; 0; 0; 4; 0]));
    t.assertEquals(p1.format, 'sparse_matrix');
    t.assert(isstruct(p1.records));
    t.assert(numel(fieldnames(p1.records)) == 1);
    t.assert(isfield(p1.records, 'value'));
    t.assert(numel(p1.records.value) == 5);
    t.assert(p1.records.value(1) == 1);
    t.assert(p1.records.value(2) == 0);
    t.assert(p1.records.value(3) == 0);
    t.assert(p1.records.value(4) == 4);
    t.assert(p1.records.value(5) == 0);
    t.assert(nnz(p1.records.value) == 2);
    t.assert(p1.isValid());

    t.add('set_records_cell_1');
    p1.setRecords({[1; 2; 3; 4; 5]});
    t.assertEquals(p1.format, 'dense_matrix');
    t.assert(isstruct(p1.records));
    t.assert(numel(fieldnames(p1.records)) == 1);
    t.assert(isfield(p1.records, 'value'));
    t.assert(numel(p1.records.value) == 5);
    t.assert(p1.records.value(1) == 1);
    t.assert(p1.records.value(2) == 2);
    t.assert(p1.records.value(3) == 3);
    t.assert(p1.records.value(4) == 4);
    t.assert(p1.records.value(5) == 5);
    t.assert(p1.isValid());

    t.add('set_records_cell_2');
    try
        t.assert(false);
        p1.setRecords({{'i1', 'i4'}, [1; 4]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Strings not allowed in indexed mode.');
    end

    t.add('set_records_cell_3');
    try
        t.assert(false);
        p1.setRecords({[1; 4], [11; 44], [111; 444], [1111; 4444], [11111; 44444]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain ''dim_1'' is missing.');
    end

    t.add('set_records_cell_4');
    try
        t.assert(false);
        p1.setRecords([1; 4], [1; 4], [1; 4], [1; 4], [1; 4], [1; 4]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Too many value fields in records.');
    end

    t.add('set_records_struct_1');
    p1.setRecords(struct('value', [1; 2; 3; 4; 5]));
    t.assertEquals(p1.format, 'dense_matrix');
    t.assert(isstruct(p1.records));
    t.assert(numel(fieldnames(p1.records)) == 1);
    t.assert(isfield(p1.records, 'value'));
    t.assert(numel(p1.records.value) == 5);
    t.assert(p1.records.value(1) == 1);
    t.assert(p1.records.value(2) == 2);
    t.assert(p1.records.value(3) == 3);
    t.assert(p1.records.value(4) == 4);
    t.assert(p1.records.value(5) == 5);
    t.assert(p1.isValid());

    t.add('set_records_struct_2');
    p1.setRecords(struct('marginal', [1; 2; 3; 4; 5]));
    t.assertEquals(p1.format, 'empty');
    t.assert(p1.isValid());

    t.add('set_records_struct_3');
    try
        t.assert(false);
        p1.setRecords(struct('i1_1', {'i1', 'i4'}, 'level', [1; 4]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Non-scalar structure arrays currently not supported.');
    end

    t.add('set_records_struct_4');
    recs = struct();
    recs.dim_1 = [1; 4];
    recs.value = [1; 4];
    p1.setRecords(recs);
    t.assertEquals(p1.format, 'struct');
    t.assert(isstruct(p1.records));
    t.assert(numel(fieldnames(p1.records)) == 2);
    t.assert(isfield(p1.records, 'dim_1'));
    t.assert(isfield(p1.records, 'value'));
    t.assert(numel(p1.records.dim_1) == 2);
    t.assert(numel(p1.records.value) == 2);
    t.assert(p1.records.dim_1(1) == 1);
    t.assert(p1.records.dim_1(2) == 4);
    t.assert(p1.records.value(1) == 1);
    t.assert(p1.records.value(2) == 4);
    t.assert(p1.isValid());

    t.add('set_records_struct_5');
    try
        t.assert(false);
        p1.setRecords(struct('value', [1, 2, 3]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain ''dim_1'' is missing.');
    end

    if gdx.features.table
        t.add('set_records_table_1');
        tbl = table([1; 2; 3], [1; 2; 3]);
        try
            t.assert(false);
            p1.setRecords(tbl);
        catch
            t.reset();
        end

        t.add('set_records_table_2');
        tbl = table([1; 2; 3], [1; 2; 3]);
        tbl.Properties.VariableNames = {'dim_1', 'value'};
        p1.setRecords(tbl);
        t.assertEquals(p1.format, 'table');
        t.assert(p1.isValid());
    end
end

function test_idx_writeUnordered(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'indexed', true, 'features', cfg.features);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    c = GAMSTransfer.Parameter(gdx, 'c', [5,10]);
    c.setRecords(struct('dim_1', [1, 1, 2, 2, 4, 4, 3, 3], ...
        'dim_2', [1, 2, 1, 2, 1, 2, 1, 2], 'value', [11, 12, 21, 22, 41, 42, 31, 32]));

    t.add('idx_write_unordered_1')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_cmex_idx_write: GDX error in record c(3,1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(3,1): Data not sorted when writing raw');
        end
    end

    t.add('idx_write_unordered_2')
    gdx.write(write_filename, 'sorted', false);

    c.setRecords(struct('dim_1', [1, 1, 2, 2], 'dim_2', [1, 2, 2, 1], ...
        'value', [11, 12, 22, 21]));

    t.add('idx_write_unordered_3')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_cmex_idx_write: GDX error in record c(2,1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(2,1): Data not sorted when writing raw');
        end
    end

    t.add('idx_write_unordered_4')
    gdx.write(write_filename, 'sorted', false);

end

function test_idx_transformRecords(t, cfg)

    formats = {'struct', 'table', 'dense_matrix', 'sparse_matrix'};
    a_recs = cell(1, numel(formats));
    b_recs = cell(1, numel(formats));
    c_recs = cell(1, numel(formats));
    a_format = cell(1, numel(formats));
    b_format = cell(1, numel(formats));
    c_format = cell(1, numel(formats));

    for i = 1:numel(formats)
        if strcmp(formats{i}, 'table') && ~gdx.features.table
            continue
        end
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
            'features', cfg.features);
        gdx.read(cfg.filenames{4}, 'format', formats{i});
        a_recs{i} = gdx.data.a.records;
        b_recs{i} = gdx.data.b.records;
        c_recs{i} = gdx.data.c.records;
        a_format{i} = gdx.data.a.format;
        b_format{i} = gdx.data.b.format;
        c_format{i} = gdx.data.c.format;
    end

    for i = 1:numel(formats)
        if strcmp(formats{i}, 'table') && ~gdx.features.table
            continue
        end

        for j = 1:numel(formats)
            if strcmp(formats{j}, 'table') && ~gdx.features.table
                continue
            end

            t.add(sprintf('idx_transform_records_%s_to_%s', formats{i}, formats{j}));
            gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                'features', cfg.features);
            gdx.read(cfg.filenames{4}, 'format', formats{i});
            gdx.data.a.transformRecords(formats{j});
            gdx.data.b.transformRecords(formats{j});
            gdx.data.c.transformRecords(formats{j});
            t.assert(gdx.data.a.isValid());
            t.assert(gdx.data.b.isValid());
            t.assert(gdx.data.c.isValid());
            t.assertEquals(gdx.data.a.format, a_format{j});
            t.assertEquals(gdx.data.b.format, b_format{j});
            t.assertEquals(gdx.data.c.format, c_format{j});
            t.assertEquals(gdx.data.a.records, a_recs{j});
            t.assertEquals(gdx.data.b.records, b_recs{j});
            t.assertEquals(gdx.data.c.records, c_recs{j});
        end
    end
end
