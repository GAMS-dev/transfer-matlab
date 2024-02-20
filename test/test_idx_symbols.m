%
% GAMS - General Algebraic Modeling System Matlab API
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

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    t.add('idx_add_symbols_parameter_1');
    p1 = gams.transfer.Parameter(gdx, 'p1');
    t.testEmptySymbol(p1);
    t.assertEquals(p1.name, 'p1');
    t.assertEquals(p1.description, '');
    t.assert(p1.dimension == 0);
    t.assert(numel(p1.domain) == 0);
    t.assert(numel(p1.domain_names) == 0);
    t.assert(numel(p1.domain_labels) == 0);
    t.assertEquals(p1.domain_type, 'none');
    t.assert(numel(p1.size) == 0);
    t.assert(strcmp(p1.format, 'struct'));
    t.assert(p1.getNumberRecords() == 0);
    t.assert(p1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 'p1'));
    t.assert(gdx.data.p1 == p1);

    t.add('idx_add_symbols_parameter_2');
    p2 = gams.transfer.Parameter(gdx, 'p2', 0, 'description', 'descr par 2');
    t.testEmptySymbol(p2);
    t.assertEquals(p2.name, 'p2');
    t.assertEquals(p2.description, 'descr par 2');
    t.assert(p2.dimension == 1);
    t.assert(numel(p2.domain) == 1);
    t.assertEquals(p2.domain{1}, 'dim_1');
    t.assert(numel(p2.domain_names) == 1);
    t.assertEquals(p2.domain_names{1}, 'dim_1');
    t.assert(numel(p2.domain_labels) == 1);
    t.assertEquals(p2.domain_type, 'relaxed');
    t.assert(numel(p2.size) == 1);
    t.assert(p2.size(1) == 0);
    t.assert(strcmp(p2.format, 'struct'));
    t.assert(p2.getNumberRecords() == 0);
    t.assert(p2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 'p2'));
    t.assert(gdx.data.p2 == p2);

    t.add('idx_add_symbols_parameter_3');
    p3 = gams.transfer.Parameter(gdx, 'p3', [1,2,3], 'description', 'descr par 3');
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
    t.assertEquals(p3.domain_type, 'relaxed');
    t.assert(numel(p3.size) == 3);
    t.assert(p3.size(1) == 1);
    t.assert(p3.size(2) == 2);
    t.assert(p3.size(3) == 3);
    t.assert(strcmp(p3.format, 'struct'));
    t.assert(p3.getNumberRecords() == 0);
    t.assert(p3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'p3'));
    t.assert(gdx.data.p3 == p3);

    t.add('idx_add_symbols_parameter_fails');
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, p1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', {2, 3});
    catch
        t.reset();
    end
    if ~gams.transfer.Constants.IS_OCTAVE
        try
            t.assert(false);
            gams.transfer.Parameter(gdx, 's', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', 5, 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', p3);
    catch
        t.reset();
    end

end

function test_idx_changeSymbol(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    p1 = gams.transfer.Parameter(gdx, 'p1', 5);
    p2 = gams.transfer.Parameter(gdx, 'p2', [5,10]);

    t.add('idx_change_symbol_name_1');
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

    t.add('idx_change_symbol_name_2');
    try
        t.assert(false);
        p1.name = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 1) must be ''string'' or ''char''.');
    end
    try
        t.assert(false);
        p1.name = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 1) must be ''string'' or ''char''.');
    end

    t.add('idx_change_symbol_description_1');
    t.assertEquals(p1.description, '');
    t.assertEquals(p2.description, '');
    p1.description = 'descr p1';
    t.assertEquals(p1.description, 'descr p1');
    t.assertEquals(p2.description, '');

    t.add('idx_change_symbol_description_2');
    try
        t.assert(false);
        p1.description = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 1) must be ''string'' or ''char''.');
    end
    try
        t.assert(false);
        p1.description = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 1) must be ''string'' or ''char''.');
    end

    t.add('idx_change_symbol_dimension_1');
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.size) == 1);
    t.assert(p1.size(1) == 5);
    p1.dimension = 2;
    t.assert(p1.dimension == 2);
    t.assert(numel(p1.size) == 2);
    t.assert(numel(p1.domain) == 2);
    t.assert(p1.size(1) == 5);
    t.assert(p1.size(2) == 0);
    t.assertEquals(p1.domain{1}, 'dim_1');
    t.assertEquals(p1.domain{2}, '*');
    p1.dimension = 1;
    t.assert(p1.dimension == 1);
    t.assert(numel(p1.size) == 1);
    t.assert(numel(p1.domain) == 1);
    t.assert(p1.size(1) == 5);
    t.assertEquals(p1.domain{1}, 'dim_1');

    t.add('idx_change_symbol_dimension_2');
    try
        t.assert(false);
        p1.dimension = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be numeric.');
    end
    try
        t.assert(false);
        p1.dimension = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be integer.');
    end
    try
        t.assert(false);
        p1.dimension = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be in [0,20].');
    end
    try
        t.assert(false);
        p1.dimension = 21;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be in [0,20].');
    end

    t.add('idx_change_symbol_size_1');
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

    t.add('idx_change_symbol_size_2');
    try
        t.assert(false);
        p1.size = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''size'' (at position 1) must be numeric.');
    end
    try
        t.assert(false);
        p1.size = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''size'' (at position 1) must be integer.');
    end
    try
        t.assert(false);
        p1.size = nan;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''size'' (at position 1) must be integer.');
    end
    try
        t.assert(false);
        p1.size = inf;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''size'' (at position 1) must not be inf.');
    end
    try
        t.assert(false);
        p1.size = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''size'' (at position 1) must be equal to or larger than 0.');
    end

    t.add('idx_change_symbol_domain_labels_1');
    p1.size = [10, 10];
    p1.records = struct();
    p1.records.dim_1 = [1; 2; 3];
    p1.records.dim_2 = [2; 4; 6];
    p1.records.value = [1; 2; 3];
    t.assert(p1.isValid());
    t.assert(numel(p1.size) == 2);
    t.assert(p1.dimension == 2);
    t.assert(numel(p1.domain) == 2);
    t.assert(numel(p1.domain_labels) == 2);
    t.assertEquals(p1.domain_labels{1}, 'dim_1');
    t.assertEquals(p1.domain_labels{2}, 'dim_2');
    t.assert(isfield(p1.records, 'dim_1'));
    t.assert(isfield(p1.records, 'dim_2'));
    t.assert(~isfield(p1.records, 'd1'));
    t.assert(~isfield(p1.records, 'd2'));
    p1.domain_labels = {'d1', 'd2'};
    t.assert(numel(p1.size) == 2);
    t.assert(p1.dimension == 2);
    t.assert(numel(p1.domain) == 2);
    t.assert(numel(p1.domain_labels) == 2);
    t.assertEquals(p1.domain_labels{1}, 'd1');
    t.assertEquals(p1.domain_labels{2}, 'd2');
    t.assert(~isfield(p1.records, 'dim_1'));
    t.assert(~isfield(p1.records, 'dim_2'));
    t.assert(isfield(p1.records, 'd1'));
    t.assert(isfield(p1.records, 'd2'));
    t.assert(p1.isValid());

    t.add('idx_change_symbol_domain_labels_2');
    try
        t.assert(false);
        p1.domain_labels = '*';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''domain_labels'' (at position 1) must be ''cell''.');
    end
    try
        t.assert(false);
        p1.domain_labels = {'*'};
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''domain_labels'' (at position 1) must have 2 elements.');
    end
end

function test_idx_copySymbol(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    p = gams.transfer.Parameter(gdx, 'p', [10]);
    p.records.dim_1 = [2 4]';
    p.records.value = [1 2]';
    t.assert(p.isValid());

    t.add('idx_copy_symbol_parameter_empty');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
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
    t.assert(~gdx2.data.p.domain_forwarding(1));
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
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Parameter(gdx2, 'p');
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
    t.assert(~gdx2.data.p.domain_forwarding(1));
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
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Parameter(gdx2, 'p');
    try
        t.assert(false);
        p.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Symbol already exists in destination.');
    end

end

function test_idx_setRecords(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    p1 = gams.transfer.Parameter(gdx, 'p1', 5);

    t.add('set_records_numeric_1');
    try
        t.assert(false);
        p1.setRecords([1; 2; 3; 4]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Cannot create matrix records, because value size does not match symbol size.');
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

    t.add('set_records_cell_3');
    try
        t.assert(false);
        p1.setRecords({[1; 4], [11; 44], [111; 444], [1111; 4444], [11111; 44444]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Too many value fields in records.');
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

    t.add('set_records_struct_3');
    try
        t.assert(false);
        p1.setRecords(struct('i1_1', {'i1', 'i4'}, 'level', [1; 4]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Unsupported records format.');
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
        t.assertEquals(e.message, 'Cannot create matrix records, because value size does not match symbol size.');
    end

    if gams.transfer.Constants.SUPPORTS_TABLE
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

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    c = gams.transfer.Parameter(gdx, 'c', [5,10]);
    c.setRecords(struct('dim_1', [1, 1, 2, 2, 4, 4, 3, 3], ...
        'dim_2', [1, 2, 1, 2, 1, 2, 1, 2], 'value', [11, 12, 21, 22, 41, 42, 31, 32]));

    t.add('idx_write_unordered_1')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true, 'indexed', true);
    catch e
        t.reset();
        if gams.transfer.Constants.IS_OCTAVE
            t.assertEquals(e.message, 'gt_idx_write: GDX error in record c(3,1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(3,1): Data not sorted when writing raw');
        end
    end

    t.add('idx_write_unordered_2')
    gdx.write(write_filename, 'sorted', false, 'indexed', true);

    c.setRecords(struct('dim_1', [1, 1, 2, 2], 'dim_2', [1, 2, 2, 1], ...
        'value', [11, 12, 22, 21]));

    t.add('idx_write_unordered_3')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true, 'indexed', true);
    catch e
        t.reset();
        if gams.transfer.Constants.IS_OCTAVE
            t.assertEquals(e.message, 'gt_idx_write: GDX error in record c(2,1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(2,1): Data not sorted when writing raw');
        end
    end

    t.add('idx_write_unordered_4')
    gdx.write(write_filename, 'sorted', false, 'indexed', true);

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
        if strcmp(formats{i}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
            continue
        end
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{4}, 'format', formats{i}, 'indexed', true);
        a_recs{i} = gdx.data.a.records;
        b_recs{i} = gdx.data.b.records;
        c_recs{i} = gdx.data.c.records;
        a_format{i} = gdx.data.a.format;
        b_format{i} = gdx.data.b.format;
        c_format{i} = gdx.data.c.format;
    end

    for i = 1:numel(formats)
        if strcmp(formats{i}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
            continue
        end

        for j = 1:numel(formats)
            if strcmp(formats{j}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
                continue
            end

            t.add(sprintf('idx_transform_records_%s_to_%s', formats{i}, formats{j}));
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{4}, 'format', formats{i}, 'indexed', true);
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
