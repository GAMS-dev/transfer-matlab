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

function success = test_readwrite(cfg)
    t = GAMSTest('readwrite_c');
    test_read(t, cfg, 'c');
    test_readEquals(t, cfg, 'c');
    test_readNoRecords(t, cfg, 'c');
    test_readPartial(t, cfg, 'c');
    test_readSpecialValues(t, cfg, 'c');
    test_readDomainCycle(t, cfg, 'c');
    test_readAcronyms(t, cfg, 'c');
    test_readSymbolTypes(t, cfg, 'c');
    test_readWrite(t, cfg);
    test_readWritePartial(t, cfg);
    test_readWriteCompress(t, cfg);
    test_readWriteDomainCheck(t, cfg);
    [~, n_fails1] = t.summary();

    t = GAMSTest('readwrite_rc');
    test_read(t, cfg, 'rc');
    test_readEquals(t, cfg, 'rc');
    test_readNoRecords(t, cfg, 'rc');
    test_readPartial(t, cfg, 'rc');
    test_readSpecialValues(t, cfg, 'rc');
    test_readDomainCycle(t, cfg, 'rc');
    test_readAcronyms(t, cfg, 'rc');
    test_readSymbolTypes(t, cfg, 'rc');
    [~, n_fails2] = t.summary();

    success = n_fails1 + n_fails2 == 0;
end

function test_read(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container(cfg.filenames{1}, 'gams_dir', cfg.gams_dir);
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1});
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_basic_info');
    t.assertEquals(gdx.gams_dir, cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 5);

    t.add('read_set_basic');
    t.assert(isfield(gdx.data, 'i'));
    s = gdx.data.i;
    t.assert(isa(s, 'gams.transfer.symbol.Set'));
    t.assertEquals(s.name, 'i');
    t.assertEquals(s.description, 'set_i');
    t.assert(~s.is_singleton);
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, '*');
    t.assert(numel(s.domain_labels) == 1);
    t.assertEquals(s.domain_labels{1}, 'uni');
    t.assertEquals(s.domain_type, 'none');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 5);
    t.assert(isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 5);
    t.assert(s.isValid());

    t.add('read_scalar_basic');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    t.assert(isa(s, 'gams.transfer.symbol.Parameter'));
    t.assertEquals(s.name, 'a');
    t.assertEquals(s.description, 'par_a');
    t.assert(s.dimension == 0);
    t.assert(numel(s.domain) == 0);
    t.assert(numel(s.domain_labels) == 0);
    t.assertEquals(s.domain_type, 'none');
    t.assert(numel(s.size) == 0);
    t.assert(~isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 1);
    t.assert(s.isValid());

    t.add('read_parameter_basic');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    t.assert(isa(s, 'gams.transfer.symbol.Parameter'));
    t.assertEquals(s.name, 'b');
    t.assertEquals(s.description, 'par_b');
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, gdx.data.i);
    t.assertEquals(s.domain{1}.name, 'i');
    t.assert(numel(s.domain_labels) == 1);
    t.assertEquals(s.domain_labels{1}, 'i');
    t.assertEquals(s.domain_type, 'regular');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 5);
    t.assert(~isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 3);
    t.assert(s.isValid());

    t.add('read_variable_basic');
    t.assert(isfield(gdx.data, 'x'));
    s = gdx.data.x;
    t.assert(isa(s, 'gams.transfer.symbol.Variable'));
    t.assertEquals(s.name, 'x');
    t.assertEquals(s.description, 'var_x');
    t.assertEquals(s.type, 'positive');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain) == 2);
    t.assertEquals(s.domain{1}, gdx.data.i);
    t.assertEquals(s.domain{2}, gdx.data.j);
    t.assertEquals(s.domain{1}.name, 'i');
    t.assertEquals(s.domain{2}.name, 'j');
    t.assert(numel(s.domain_labels) == 2);
    t.assertEquals(s.domain_labels{1}, 'i');
    t.assertEquals(s.domain_labels{2}, 'j');
    t.assertEquals(s.domain_type, 'regular');
    t.assert(numel(s.size) == 2);
    t.assert(s.size(1) == 5);
    t.assert(s.size(2) == 5);
    t.assert(~isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 6);
    t.assert(s.isValid());

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_set_records_struct');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni'));
    t.assert(isfield(s.records, 'element_text'));
    t.assert(numel(s.records.uni) == 5);
    t.assert(numel(s.records.element_text) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.uni(1), 'i1');
        t.assertEquals(s.records.uni(2), 'i3');
        t.assertEquals(s.records.uni(3), 'i4');
        t.assertEquals(s.records.uni(4), 'i6');
        t.assertEquals(s.records.uni(5), 'i10');
    end
    uni_int = int32(s.records.uni);
    t.assert(uni_int(1) == 1);
    t.assert(uni_int(2) == 2);
    t.assert(uni_int(3) == 3);
    t.assert(uni_int(4) == 4);
    t.assert(uni_int(5) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assert(isundefined(s.records.element_text(1)));
        t.assertEquals(s.records.element_text(2), 'expl text 3');
        t.assert(isundefined(s.records.element_text(3)));
        t.assert(isundefined(s.records.element_text(4)));
        t.assertEquals(s.records.element_text(5), 'expl text 10');
    else
        t.assertEquals(s.records.element_text{1}, '');
        t.assertEquals(s.records.element_text{2}, 'expl text 3');
        t.assertEquals(s.records.element_text{3}, '');
        t.assertEquals(s.records.element_text{4}, '');
        t.assertEquals(s.records.element_text{5}, 'expl text 10');
    end
    uels = s.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_scalar_records_struct');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('read_parameter_records_struct');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'i'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.i) == 3);
    t.assert(numel(s.records.value) == 3);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.i(1), 'i1');
        t.assertEquals(s.records.i(2), 'i3');
        t.assertEquals(s.records.i(3), 'i10');
    end
    i_int = int32(s.records.i);
    t.assert(i_int(1) == 1);
    t.assert(i_int(2) == 2);
    t.assert(i_int(3) == 3);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 10);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i10');

    t.add('read_variable_records_struct');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 7);
    t.assert(isfield(s.records, 'i'));
    t.assert(isfield(s.records, 'j'));
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(isfield(s.records, 'lower'));
    t.assert(isfield(s.records, 'upper'));
    t.assert(isfield(s.records, 'scale'));
    t.assert(numel(s.records.i) == 6);
    t.assert(numel(s.records.j) == 6);
    t.assert(numel(s.records.level) == 6);
    t.assert(numel(s.records.marginal) == 6);
    t.assert(numel(s.records.lower) == 6);
    t.assert(numel(s.records.upper) == 6);
    t.assert(numel(s.records.scale) == 6);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.i(1), 'i1');
        t.assertEquals(s.records.i(2), 'i3');
        t.assertEquals(s.records.i(3), 'i3');
        t.assertEquals(s.records.i(4), 'i6');
        t.assertEquals(s.records.i(5), 'i6');
        t.assertEquals(s.records.i(6), 'i10');
        t.assertEquals(s.records.j(1), 'j2');
        t.assertEquals(s.records.j(2), 'j8');
        t.assertEquals(s.records.j(3), 'j9');
        t.assertEquals(s.records.j(4), 'j5');
        t.assertEquals(s.records.j(5), 'j7');
        t.assertEquals(s.records.j(6), 'j7');
    end
    i_int = int32(s.records.i);
    j_int = int32(s.records.j);
    t.assert(i_int(1) == 1);
    t.assert(i_int(2) == 2);
    t.assert(i_int(3) == 2);
    t.assert(i_int(4) == 3);
    t.assert(i_int(5) == 3);
    t.assert(i_int(6) == 4);
    t.assert(j_int(1) == 1);
    t.assert(j_int(2) == 4);
    t.assert(j_int(3) == 5);
    t.assert(j_int(4) == 2);
    t.assert(j_int(5) == 3);
    t.assert(j_int(6) == 3);
    t.assert(s.records.level(1) == 2);
    t.assert(s.records.level(2) == 0);
    t.assert(s.records.level(3) == 9);
    t.assert(s.records.level(4) == 0);
    t.assert(s.records.level(5) == 0);
    t.assert(s.records.level(6) == 7);
    t.assert(s.records.marginal(1) == 0);
    t.assert(s.records.marginal(2) == 8);
    t.assert(s.records.marginal(3) == 0);
    t.assert(s.records.marginal(4) == 5);
    t.assert(s.records.marginal(5) == 0);
    t.assert(s.records.marginal(6) == 0);
    t.assert(s.records.lower(1) == 0);
    t.assert(s.records.lower(2) == 0);
    t.assert(s.records.lower(3) == 0);
    t.assert(s.records.lower(4) == 0);
    t.assert(s.records.lower(5) == 0);
    t.assert(s.records.lower(6) == 0);
    t.assert(s.records.upper(1) == Inf);
    t.assert(s.records.upper(2) == Inf);
    t.assert(s.records.upper(3) == Inf);
    t.assert(s.records.upper(4) == Inf);
    t.assert(s.records.upper(5) == 30);
    t.assert(s.records.upper(6) == Inf);
    t.assert(s.records.scale(1) == 1);
    t.assert(s.records.scale(2) == 1);
    t.assert(s.records.scale(3) == 1);
    t.assert(s.records.scale(4) == 1);
    t.assert(s.records.scale(5) == 1);
    t.assert(s.records.scale(6) == 1);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    uels = s.getUELs(2);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'j2');
    t.assertEquals(uels{2}, 'j5');
    t.assertEquals(uels{3}, 'j7');
    t.assertEquals(uels{4}, 'j8');
    t.assertEquals(uels{5}, 'j9');

    if gams.transfer.Constants.SUPPORTS_TABLE
        switch container_type
        case 'c'
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{1}, 'format', 'table');
        case 'rc'
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{1}, 'format', 'table');
            gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
        end

        t.add('read_set_records_table');
        s = gdx.data.i;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'uni');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'element_text');
        t.assert(numel(s.records.uni) == 5);
        t.assert(numel(s.records.element_text) == 5);
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            t.assertEquals(s.records.uni(1), 'i1');
            t.assertEquals(s.records.uni(2), 'i3');
            t.assertEquals(s.records.uni(3), 'i4');
            t.assertEquals(s.records.uni(4), 'i6');
            t.assertEquals(s.records.uni(5), 'i10');
        end
        uni_int = int32(s.records.uni);
        t.assert(uni_int(1) == 1);
        t.assert(uni_int(2) == 2);
        t.assert(uni_int(3) == 3);
        t.assert(uni_int(4) == 4);
        t.assert(uni_int(5) == 5);
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            t.assert(isundefined(s.records.element_text(1)));
            t.assertEquals(s.records.element_text(2), 'expl text 3');
            t.assert(isundefined(s.records.element_text(3)));
            t.assert(isundefined(s.records.element_text(4)));
            t.assertEquals(s.records.element_text(5), 'expl text 10');
        else
            t.assertEquals(s.records.element_text{1}, '');
            t.assertEquals(s.records.element_text{2}, 'expl text 3');
            t.assertEquals(s.records.element_text{3}, '');
            t.assertEquals(s.records.element_text{4}, '');
            t.assertEquals(s.records.element_text{5}, 'expl text 10');
        end
        uels = s.getUELs(1);
        t.assert(numel(uels) == 5);
        t.assertEquals(uels{1}, 'i1');
        t.assertEquals(uels{2}, 'i3');
        t.assertEquals(uels{3}, 'i4');
        t.assertEquals(uels{4}, 'i6');
        t.assertEquals(uels{5}, 'i10');

        t.add('read_scalar_records_table');
        s = gdx.data.a;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 1);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'value');
        t.assert(numel(s.records.value) == 1);
        t.assert(s.records.value == 4);

        t.add('read_parameter_records_table');
        s = gdx.data.b;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'i');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'value');
        t.assert(numel(s.records.i) == 3);
        t.assert(numel(s.records.value) == 3);
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            t.assertEquals(s.records.i(1), 'i1');
            t.assertEquals(s.records.i(2), 'i3');
            t.assertEquals(s.records.i(3), 'i10');
        end
        i_int = int32(s.records.i);
        t.assert(i_int(1) == 1);
        t.assert(i_int(2) == 2);
        t.assert(i_int(3) == 3);
        t.assert(s.records.value(1) == 1);
        t.assert(s.records.value(2) == 3);
        t.assert(s.records.value(3) == 10);
        uels = s.getUELs(1);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'i1');
        t.assertEquals(uels{2}, 'i3');
        t.assertEquals(uels{3}, 'i10');

        t.add('read_variable_records_table');
        s = gdx.data.x;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 7);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'i');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'j');
        t.assertEquals(s.records.Properties.VariableNames{3}, 'level');
        t.assertEquals(s.records.Properties.VariableNames{4}, 'marginal');
        t.assertEquals(s.records.Properties.VariableNames{5}, 'lower');
        t.assertEquals(s.records.Properties.VariableNames{6}, 'upper');
        t.assertEquals(s.records.Properties.VariableNames{7}, 'scale');
        t.assert(numel(s.records.i) == 6);
        t.assert(numel(s.records.j) == 6);
        t.assert(numel(s.records.level) == 6);
        t.assert(numel(s.records.marginal) == 6);
        t.assert(numel(s.records.lower) == 6);
        t.assert(numel(s.records.upper) == 6);
        t.assert(numel(s.records.scale) == 6);
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            t.assertEquals(s.records.i(1), 'i1');
            t.assertEquals(s.records.i(2), 'i3');
            t.assertEquals(s.records.i(3), 'i3');
            t.assertEquals(s.records.i(4), 'i6');
            t.assertEquals(s.records.i(5), 'i6');
            t.assertEquals(s.records.i(6), 'i10');
            t.assertEquals(s.records.j(1), 'j2');
            t.assertEquals(s.records.j(2), 'j8');
            t.assertEquals(s.records.j(3), 'j9');
            t.assertEquals(s.records.j(4), 'j5');
            t.assertEquals(s.records.j(5), 'j7');
            t.assertEquals(s.records.j(6), 'j7');
        end
        i_int = int32(s.records.i);
        j_int = int32(s.records.j);
        t.assert(i_int(1) == 1);
        t.assert(i_int(2) == 2);
        t.assert(i_int(3) == 2);
        t.assert(i_int(4) == 3);
        t.assert(i_int(5) == 3);
        t.assert(i_int(6) == 4);
        t.assert(j_int(1) == 1);
        t.assert(j_int(2) == 4);
        t.assert(j_int(3) == 5);
        t.assert(j_int(4) == 2);
        t.assert(j_int(5) == 3);
        t.assert(j_int(6) == 3);
        t.assert(s.records.level(1) == 2);
        t.assert(s.records.level(2) == 0);
        t.assert(s.records.level(3) == 9);
        t.assert(s.records.level(4) == 0);
        t.assert(s.records.level(5) == 0);
        t.assert(s.records.level(6) == 7);
        t.assert(s.records.marginal(1) == 0);
        t.assert(s.records.marginal(2) == 8);
        t.assert(s.records.marginal(3) == 0);
        t.assert(s.records.marginal(4) == 5);
        t.assert(s.records.marginal(5) == 0);
        t.assert(s.records.marginal(6) == 0);
        t.assert(s.records.lower(1) == 0);
        t.assert(s.records.lower(2) == 0);
        t.assert(s.records.lower(3) == 0);
        t.assert(s.records.lower(4) == 0);
        t.assert(s.records.lower(5) == 0);
        t.assert(s.records.lower(6) == 0);
        t.assert(s.records.upper(1) == Inf);
        t.assert(s.records.upper(2) == Inf);
        t.assert(s.records.upper(3) == Inf);
        t.assert(s.records.upper(4) == Inf);
        t.assert(s.records.upper(5) == 30);
        t.assert(s.records.upper(6) == Inf);
        t.assert(s.records.scale(1) == 1);
        t.assert(s.records.scale(2) == 1);
        t.assert(s.records.scale(3) == 1);
        t.assert(s.records.scale(4) == 1);
        t.assert(s.records.scale(5) == 1);
        t.assert(s.records.scale(6) == 1);
        uels = s.getUELs(1);
        t.assert(numel(uels) == 4);
        t.assertEquals(uels{1}, 'i1');
        t.assertEquals(uels{2}, 'i3');
        t.assertEquals(uels{3}, 'i6');
        t.assertEquals(uels{4}, 'i10');
        uels = s.getUELs(2);
        t.assert(numel(uels) == 5);
        t.assertEquals(uels{1}, 'j2');
        t.assertEquals(uels{2}, 'j5');
        t.assertEquals(uels{3}, 'j7');
        t.assertEquals(uels{4}, 'j8');
        t.assertEquals(uels{5}, 'j9');
    end

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_set_records_dense_matrix');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni'));
    t.assert(isfield(s.records, 'element_text'));
    t.assert(numel(s.records.uni) == 5);
    t.assert(numel(s.records.element_text) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.uni(1), 'i1');
        t.assertEquals(s.records.uni(2), 'i3');
        t.assertEquals(s.records.uni(3), 'i4');
        t.assertEquals(s.records.uni(4), 'i6');
        t.assertEquals(s.records.uni(5), 'i10');
    end
    uni_int = int32(s.records.uni);
    t.assert(uni_int(1) == 1);
    t.assert(uni_int(2) == 2);
    t.assert(uni_int(3) == 3);
    t.assert(uni_int(4) == 4);
    t.assert(uni_int(5) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assert(isundefined(s.records.element_text(1)));
        t.assertEquals(s.records.element_text(2), 'expl text 3');
        t.assert(isundefined(s.records.element_text(3)));
        t.assert(isundefined(s.records.element_text(4)));
        t.assertEquals(s.records.element_text(5), 'expl text 10');
    else
        t.assertEquals(s.records.element_text{1}, '');
        t.assertEquals(s.records.element_text{2}, 'expl text 3');
        t.assertEquals(s.records.element_text{3}, '');
        t.assertEquals(s.records.element_text{4}, '');
        t.assertEquals(s.records.element_text{5}, 'expl text 10');
    end
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_scalar_records_dense_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('read_parameter_records_dense_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 5);
    t.assert(size(s.records.value, 1) == 5);
    t.assert(size(s.records.value, 2) == 1);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 0);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 10);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_variable_records_dense_matrix');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'dense_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 5);
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(isfield(s.records, 'lower'));
    t.assert(isfield(s.records, 'upper'));
    t.assert(isfield(s.records, 'scale'));
    t.assert(numel(s.records.level) == 25);
    t.assert(numel(s.records.marginal) == 25);
    t.assert(numel(s.records.lower) == 25);
    t.assert(numel(s.records.upper) == 25);
    t.assert(numel(s.records.scale) == 25);
    t.assert(size(s.records.level, 1) == 5);
    t.assert(size(s.records.level, 2) == 5);
    t.assert(size(s.records.marginal, 1) == 5);
    t.assert(size(s.records.marginal, 2) == 5);
    t.assert(size(s.records.lower, 1) == 5);
    t.assert(size(s.records.lower, 2) == 5);
    t.assert(size(s.records.upper, 1) == 5);
    t.assert(size(s.records.upper, 2) == 5);
    t.assert(size(s.records.scale, 1) == 5);
    t.assert(size(s.records.scale, 2) == 5);
    t.assert(s.records.level(1,1) == 2);
    t.assert(s.records.level(2,4) == 0);
    t.assert(s.records.level(2,5) == 9);
    t.assert(s.records.level(3,2) == 0);
    t.assert(s.records.level(3,3) == 0);
    t.assert(s.records.level(4,2) == 0);
    t.assert(s.records.level(4,3) == 0);
    t.assert(s.records.level(5,3) == 7);
    t.assert(s.records.level(5,5) == 0);
    t.assert(s.records.marginal(1,1) == 0);
    t.assert(s.records.marginal(2,4) == 8);
    t.assert(s.records.marginal(2,5) == 0);
    t.assert(s.records.marginal(3,2) == 0);
    t.assert(s.records.marginal(3,3) == 0);
    t.assert(s.records.marginal(4,2) == 5);
    t.assert(s.records.marginal(4,3) == 0);
    t.assert(s.records.marginal(5,3) == 0);
    t.assert(s.records.marginal(5,5) == 0);
    t.assert(s.records.lower(1,1) == 0);
    t.assert(s.records.lower(2,4) == 0);
    t.assert(s.records.lower(2,5) == 0);
    t.assert(s.records.lower(3,2) == 0);
    t.assert(s.records.lower(3,3) == 0);
    t.assert(s.records.lower(4,2) == 0);
    t.assert(s.records.lower(4,3) == 0);
    t.assert(s.records.lower(5,3) == 0);
    t.assert(s.records.lower(5,5) == 0);
    t.assert(s.records.upper(1,1) == Inf);
    t.assert(s.records.upper(2,4) == Inf);
    t.assert(s.records.upper(2,5) == Inf);
    t.assert(s.records.upper(3,2) == Inf);
    t.assert(s.records.upper(3,3) == Inf);
    t.assert(s.records.upper(4,2) == Inf);
    t.assert(s.records.upper(4,3) == 30);
    t.assert(s.records.upper(5,3) == Inf);
    t.assert(s.records.upper(5,5) == Inf);
    t.assert(s.records.scale(1,1) == 1);
    t.assert(s.records.scale(2,4) == 1);
    t.assert(s.records.scale(2,5) == 1);
    t.assert(s.records.scale(3,2) == 1);
    t.assert(s.records.scale(3,3) == 1);
    t.assert(s.records.scale(4,2) == 1);
    t.assert(s.records.scale(4,3) == 1);
    t.assert(s.records.scale(5,3) == 1);
    t.assert(s.records.scale(5,5) == 1);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');
    uels = s.getUELs(2);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'j2');
    t.assertEquals(uels{2}, 'j5');
    t.assertEquals(uels{3}, 'j7');
    t.assertEquals(uels{4}, 'j8');
    t.assertEquals(uels{5}, 'j9');

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_set_records_sparse_matrix');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni'));
    t.assert(isfield(s.records, 'element_text'));
    t.assert(numel(s.records.uni) == 5);
    t.assert(numel(s.records.element_text) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.uni(1), 'i1');
        t.assertEquals(s.records.uni(2), 'i3');
        t.assertEquals(s.records.uni(3), 'i4');
        t.assertEquals(s.records.uni(4), 'i6');
        t.assertEquals(s.records.uni(5), 'i10');
    end
    uni_int = int32(s.records.uni);
    t.assert(uni_int(1) == 1);
    t.assert(uni_int(2) == 2);
    t.assert(uni_int(3) == 3);
    t.assert(uni_int(4) == 4);
    t.assert(uni_int(5) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assert(isundefined(s.records.element_text(1)));
        t.assertEquals(s.records.element_text(2), 'expl text 3');
        t.assert(isundefined(s.records.element_text(3)));
        t.assert(isundefined(s.records.element_text(4)));
        t.assertEquals(s.records.element_text(5), 'expl text 10');
    else
        t.assertEquals(s.records.element_text{1}, '');
        t.assertEquals(s.records.element_text{2}, 'expl text 3');
        t.assertEquals(s.records.element_text{3}, '');
        t.assertEquals(s.records.element_text{4}, '');
        t.assertEquals(s.records.element_text{5}, 'expl text 10');
    end
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_scalar_records_sparse_matrix');
    s = gdx.data.a;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == 1);
    t.assert(s.records.value == 4);

    t.add('read_parameter_records_sparse_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(issparse(s.records.value));
    t.assert(numel(s.records.value) == 5);
    t.assert(size(s.records.value, 1) == 5);
    t.assert(size(s.records.value, 2) == 1);
    t.assert(nnz(s.records.value) == 3);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 0);
    t.assert(s.records.value(4) == 0);
    t.assert(s.records.value(5) == 10);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_variable_records_sparse_matrix');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'sparse_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 5);
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(isfield(s.records, 'lower'));
    t.assert(isfield(s.records, 'upper'));
    t.assert(isfield(s.records, 'scale'));
    t.assert(issparse(s.records.level));
    t.assert(issparse(s.records.marginal));
    t.assert(issparse(s.records.lower));
    t.assert(issparse(s.records.upper));
    t.assert(issparse(s.records.scale));
    t.assert(numel(s.records.level) == 25);
    t.assert(numel(s.records.marginal) == 25);
    t.assert(numel(s.records.lower) == 25);
    t.assert(numel(s.records.upper) == 25);
    t.assert(numel(s.records.scale) == 25);
    t.assert(size(s.records.level, 1) == 5);
    t.assert(size(s.records.level, 2) == 5);
    t.assert(size(s.records.marginal, 1) == 5);
    t.assert(size(s.records.marginal, 2) == 5);
    t.assert(size(s.records.lower, 1) == 5);
    t.assert(size(s.records.lower, 2) == 5);
    t.assert(size(s.records.upper, 1) == 5);
    t.assert(size(s.records.upper, 2) == 5);
    t.assert(size(s.records.scale, 1) == 5);
    t.assert(size(s.records.scale, 2) == 5);
    t.assert(nnz(s.records.level) + nnz(s.records.marginal) + nnz(s.records.lower) + ...
        nnz(s.records.upper) + nnz(s.records.scale) == 55);
    t.assert(s.records.level(1,1) == 2);
    t.assert(s.records.level(2,4) == 0);
    t.assert(s.records.level(2,5) == 9);
    t.assert(s.records.level(3,2) == 0);
    t.assert(s.records.level(3,3) == 0);
    t.assert(s.records.level(4,2) == 0);
    t.assert(s.records.level(4,3) == 0);
    t.assert(s.records.level(5,3) == 7);
    t.assert(s.records.level(5,5) == 0);
    t.assert(s.records.marginal(1,1) == 0);
    t.assert(s.records.marginal(2,4) == 8);
    t.assert(s.records.marginal(2,5) == 0);
    t.assert(s.records.marginal(3,2) == 0);
    t.assert(s.records.marginal(3,3) == 0);
    t.assert(s.records.marginal(4,2) == 5);
    t.assert(s.records.marginal(4,3) == 0);
    t.assert(s.records.marginal(5,3) == 0);
    t.assert(s.records.marginal(5,5) == 0);
    t.assert(s.records.lower(1,1) == 0);
    t.assert(s.records.lower(2,4) == 0);
    t.assert(s.records.lower(2,5) == 0);
    t.assert(s.records.lower(3,2) == 0);
    t.assert(s.records.lower(3,3) == 0);
    t.assert(s.records.lower(4,2) == 0);
    t.assert(s.records.lower(4,3) == 0);
    t.assert(s.records.lower(5,3) == 0);
    t.assert(s.records.lower(5,5) == 0);
    t.assert(s.records.upper(1,1) == Inf);
    t.assert(s.records.upper(2,4) == Inf);
    t.assert(s.records.upper(2,5) == Inf);
    t.assert(s.records.upper(3,2) == Inf);
    t.assert(s.records.upper(3,3) == Inf);
    t.assert(s.records.upper(4,2) == Inf);
    t.assert(s.records.upper(4,3) == 30);
    t.assert(s.records.upper(5,3) == Inf);
    t.assert(s.records.upper(5,5) == Inf);
    t.assert(s.records.scale(1,1) == 1);
    t.assert(s.records.scale(2,4) == 1);
    t.assert(s.records.scale(2,5) == 1);
    t.assert(s.records.scale(3,2) == 1);
    t.assert(s.records.scale(3,3) == 1);
    t.assert(s.records.scale(4,2) == 1);
    t.assert(s.records.scale(4,3) == 1);
    t.assert(s.records.scale(5,3) == 1);
    t.assert(s.records.scale(5,5) == 1);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');
    uels = s.getUELs(2);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'j2');
    t.assertEquals(uels{2}, 'j5');
    t.assertEquals(uels{3}, 'j7');
    t.assertEquals(uels{4}, 'j8');
    t.assertEquals(uels{5}, 'j9');
end

function test_readEquals(t, cfg, container_type)

    for i = [1,2,5,7]
        switch container_type
        case 'c'
            gdx1 = gams.transfer.Container(cfg.filenames{i}, 'gams_dir', cfg.gams_dir);
            gdx2 = gams.transfer.Container(cfg.filenames{i}, 'gams_dir', cfg.gams_dir);
        case 'rc'
            gdx1 = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx1.read(cfg.filenames{i});
            gdx1 = gams.transfer.Container(gdx1, 'gams_dir', cfg.gams_dir);
            gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx2.read(cfg.filenames{i});
            gdx2 = gams.transfer.Container(gdx2, 'gams_dir', cfg.gams_dir);
        end

        t.add(sprintf('read_equals_%d', i));
        t.assert(gdx1.equals(gdx2));
    end
end

function test_readSameDomainLabels(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container(cfg.filenames{9}, 'gams_dir', cfg.gams_dir);
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{9});
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_same_domain_labels_1');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    t.assertEquals(s.name, 'a');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain_labels) == 2);
    t.assertEquals(s.domain_labels{1}, 'i_1');
    t.assertEquals(s.domain_labels{2}, 'i_2');
    t.assert(s.isValid());

    t.add('read_same_domain_labels_2');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    t.assertEquals(s.name, 'b');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain_labels) == 2);
    t.assertEquals(s.domain_labels{1}, 'i');
    t.assertEquals(s.domain_labels{2}, 'j');
    t.assert(s.isValid());

    t.add('read_same_domain_labels_3');
    t.assert(isfield(gdx.data, 'c'));
    s = gdx.data.c;
    t.assertEquals(s.name, 'c');
    t.assert(s.dimension == 3);
    t.assert(numel(s.domain_labels) == 3);
    t.assertEquals(s.domain_labels{1}, 'i_1');
    t.assertEquals(s.domain_labels{2}, 'j_2');
    t.assertEquals(s.domain_labels{3}, 'i_3');
    t.assert(s.isValid());

    t.add('read_same_domain_labels_4');
    t.assert(isfield(gdx.data, 'd'));
    s = gdx.data.d;
    t.assertEquals(s.name, 'd');
    t.assert(s.dimension == 3);
    t.assert(numel(s.domain_labels) == 3);
    t.assertEquals(s.domain_labels{1}, 'i');
    t.assertEquals(s.domain_labels{2}, 'j');
    t.assertEquals(s.domain_labels{2}, 'k');
    t.assert(s.isValid());

end

function test_readNoRecords(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'records', false);
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'records', false);
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_no_records_set');
    t.assert(isfield(gdx.data, 'i'));
    s = gdx.data.i;
    t.assert(isa(s, 'gams.transfer.symbol.Set'));
    t.assertEquals(s.name, 'i');
    t.assertEquals(s.description, 'set_i');
    t.assert(~s.is_singleton);
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, '*');
    t.assert(numel(s.domain_labels) == 1);
    t.assertEquals(s.domain_labels{1}, 'uni')
    t.assertEquals(s.domain_type, 'none');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 0);
    t.assertEquals(s.format, 'struct');
    t.assert(isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 0);
    t.assert(s.getNumberValues() == 0);
    t.assert(s.isValid());

    t.add('read_no_records_scalar');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    t.assert(isa(s, 'gams.transfer.symbol.Parameter'));
    t.assertEquals(s.name, 'a');
    t.assertEquals(s.description, 'par_a');
    t.assert(s.dimension == 0);
    t.assert(numel(s.domain) == 0);
    t.assert(numel(s.domain_labels) == 0);
    t.assertEquals(s.domain_type, 'none');
    t.assert(numel(s.size) == 0);
    t.assertEquals(s.format, 'struct');
    t.assert(~isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 0);
    t.assert(s.getNumberValues() == 0);
    t.assert(s.isValid());

    t.add('read_no_records_parameter');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    t.assert(isa(s, 'gams.transfer.symbol.Parameter'));
    t.assertEquals(s.name, 'b');
    t.assertEquals(s.description, 'par_b');
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, gdx.data.i);
    t.assertEquals(s.domain{1}.name, 'i');
    t.assert(numel(s.domain_labels) == 1);
    t.assertEquals(s.domain_labels{1}, 'i')
    t.assertEquals(s.domain_type, 'regular');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 0);
    t.assertEquals(s.format, 'struct');
    t.assert(isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 0);
    t.assert(s.getNumberValues() == 0);
    t.assert(s.isValid());

    t.add('read_no_records_variable');
    t.assert(isfield(gdx.data, 'x'));
    s = gdx.data.x;
    t.assert(isa(s, 'gams.transfer.symbol.Variable'));
    t.assertEquals(s.name, 'x');
    t.assertEquals(s.description, 'var_x');
    t.assertEquals(s.type, 'positive');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain) == 2);
    t.assertEquals(s.domain{1}, gdx.data.i);
    t.assertEquals(s.domain{2}, gdx.data.j);
    t.assertEquals(s.domain{1}.name, 'i');
    t.assertEquals(s.domain{2}.name, 'j');
    t.assert(numel(s.domain_labels) == 2);
    t.assertEquals(s.domain_labels{1}, 'i')
    t.assertEquals(s.domain_labels{2}, 'j')
    t.assertEquals(s.domain_type, 'regular');
    t.assert(numel(s.size) == 2);
    t.assert(s.size(1) == 0);
    t.assert(s.size(2) == 0);
    t.assertEquals(s.format, 'struct');
    t.assert(isnan(s.getSparsity()));
    t.assert(s.getNumberRecords() == 0);
    t.assert(s.getNumberValues() == 0);
    t.assert(s.isValid());

end

function test_readPartial(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'i', 'j', 'x'}, ...
            'values', {'level', 'marginal'});
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'i', 'j', 'x'}, ...
            'values', {'level', 'marginal'});
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_partial_basic_info_1');
    t.assertEquals(gdx.gams_dir, cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'j'));
    t.assert(isfield(gdx.data, 'x'));

    t.add('read_partial_order_1');
    names = fieldnames(gdx.data);
    t.assert(numel(names) == 3);
    t.assertEquals(names{1}, 'i');
    t.assertEquals(names{2}, 'j');
    t.assertEquals(names{3}, 'x');

    t.add('read_partial_set_records_struct_1');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct' ));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni'));
    t.assert(isfield(s.records, 'element_text'));
    t.assert(numel(s.records.uni) == 5);
    t.assert(numel(s.records.element_text) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.uni(1), 'i1');
        t.assertEquals(s.records.uni(2), 'i3');
        t.assertEquals(s.records.uni(3), 'i4');
        t.assertEquals(s.records.uni(4), 'i6');
        t.assertEquals(s.records.uni(5), 'i10');
    end
    uni_int = int32(s.records.uni);
    t.assert(uni_int(1) == 1);
    t.assert(uni_int(2) == 2);
    t.assert(uni_int(3) == 3);
    t.assert(uni_int(4) == 4);
    t.assert(uni_int(5) == 5);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assert(isundefined(s.records.element_text(1)));
        t.assertEquals(s.records.element_text(2), 'expl text 3');
        t.assert(isundefined(s.records.element_text(3)));
        t.assert(isundefined(s.records.element_text(4)));
        t.assertEquals(s.records.element_text(5), 'expl text 10');
    else
        t.assertEquals(s.records.element_text{1}, '');
        t.assertEquals(s.records.element_text{2}, 'expl text 3');
        t.assertEquals(s.records.element_text{3}, '');
        t.assertEquals(s.records.element_text{4}, '');
        t.assertEquals(s.records.element_text{5}, 'expl text 10');
    end

    t.add('read_partial_variable_records_struct_1');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 4);
    t.assert(isfield(s.records, 'i'));
    t.assert(isfield(s.records, 'j'));
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(~isfield(s.records, 'lower'));
    t.assert(~isfield(s.records, 'upper'));
    t.assert(~isfield(s.records, 'scale'));
    t.assert(numel(s.records.i) == 6);
    t.assert(numel(s.records.j) == 6);
    t.assert(numel(s.records.level) == 6);
    t.assert(numel(s.records.marginal) == 6);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s.records.i(1), 'i1');
        t.assertEquals(s.records.i(2), 'i3');
        t.assertEquals(s.records.i(3), 'i3');
        t.assertEquals(s.records.i(4), 'i6');
        t.assertEquals(s.records.i(5), 'i6');
        t.assertEquals(s.records.i(6), 'i10');
        t.assertEquals(s.records.j(1), 'j2');
        t.assertEquals(s.records.j(2), 'j8');
        t.assertEquals(s.records.j(3), 'j9');
        t.assertEquals(s.records.j(4), 'j5');
        t.assertEquals(s.records.j(5), 'j7');
        t.assertEquals(s.records.j(6), 'j7');
    end
    i_int = int32(s.records.i);
    j_int = int32(s.records.j);
    t.assert(i_int(1) == 1);
    t.assert(i_int(2) == 2);
    t.assert(i_int(3) == 2);
    t.assert(i_int(4) == 3);
    t.assert(i_int(5) == 3);
    t.assert(i_int(6) == 4);
    t.assert(j_int(1) == 1);
    t.assert(j_int(2) == 4);
    t.assert(j_int(3) == 5);
    t.assert(j_int(4) == 2);
    t.assert(j_int(5) == 3);
    t.assert(j_int(6) == 3);
    t.assert(s.records.level(1) == 2);
    t.assert(s.records.level(2) == 0);
    t.assert(s.records.level(3) == 9);
    t.assert(s.records.level(4) == 0);
    t.assert(s.records.level(5) == 0);
    t.assert(s.records.level(6) == 7);
    t.assert(s.records.marginal(1) == 0);
    t.assert(s.records.marginal(2) == 8);
    t.assert(s.records.marginal(3) == 0);
    t.assert(s.records.marginal(4) == 5);
    t.assert(s.records.marginal(5) == 0);
    t.assert(s.records.marginal(6) == 0);

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'x'}, 'values', {'marginal'});
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'x'}, 'values', {'marginal'});
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_partial_basic_info_2');
    t.assertEquals(gdx.gams_dir, cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 'x'));

    t.add('read_partial_variable_records_struct_2');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 3);
    t.assert(isfield(s.records, 'i'));
    t.assert(isfield(s.records, 'j'));
    t.assert(~isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(~isfield(s.records, 'lower'));
    t.assert(~isfield(s.records, 'upper'));
    t.assert(~isfield(s.records, 'scale'));
    t.assert(numel(s.records.i) == 6);
    t.assert(numel(s.records.j) == 6);
    t.assert(numel(s.records.marginal) == 6);
    t.assert(s.records.marginal(1) == 0);
    t.assert(s.records.marginal(2) == 8);
    t.assert(s.records.marginal(3) == 0);
    t.assert(s.records.marginal(4) == 5);
    t.assert(s.records.marginal(5) == 0);
    t.assert(s.records.marginal(6) == 0);

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'I', 'J', 'X'}, ...
            'values', {'level', 'marginal'});
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'I', 'J', 'X'}, ...
            'values', {'level', 'marginal'});
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_partial_diffcase_basic_info');
    t.assertEquals(gdx.gams_dir, cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'j'));
    t.assert(isfield(gdx.data, 'x'));
    t.assertEquals(gdx.data.i.name, 'i');
    t.assertEquals(gdx.data.j.name, 'j');
    t.assertEquals(gdx.data.x.name, 'x');

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'j', 'x', 'i'}, ...
            'values', {'level', 'marginal'});
    case 'rc'
        gdx1 = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx1.read(cfg.filenames{1}, 'format', 'struct');
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(gdx1, 'symbols', {'j', 'x', 'i'}, 'values', {'level', 'marginal'});
    end

    t.add('read_partial_order_3');
    names = fieldnames(gdx.data);
    t.assert(numel(names) == 3);
    t.assertEquals(names{1}, 'i');
    t.assertEquals(names{2}, 'j');
    t.assertEquals(names{3}, 'x');
end

function test_readSpecialValues(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{2}, 'format', 'struct');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{2}, 'format', 'struct');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_special_values');
    t.assert(isfield(gdx.data, 'GUndef'));
    t.assert(isfield(gdx.data, 'GNA'));
    t.assert(isfield(gdx.data, 'GPInf'));
    t.assert(isfield(gdx.data, 'GMInf'));
    t.assert(isfield(gdx.data, 'GEps'));
    t.assert(isa(gdx.data.GUndef, 'gams.transfer.symbol.Parameter'));
    t.assert(isa(gdx.data.GNA, 'gams.transfer.symbol.Parameter'));
    t.assert(isa(gdx.data.GPInf, 'gams.transfer.symbol.Parameter'));
    t.assert(isa(gdx.data.GMInf, 'gams.transfer.symbol.Parameter'));
    t.assert(isa(gdx.data.GEps, 'gams.transfer.symbol.Parameter'));
    t.assert(isstruct(gdx.data.GUndef.records));
    t.assert(isstruct(gdx.data.GNA.records));
    t.assert(isstruct(gdx.data.GPInf.records));
    t.assert(isstruct(gdx.data.GMInf.records));
    t.assert(isstruct(gdx.data.GEps.records));
    t.assert(isnan(gdx.data.GUndef.records.value));
    t.assert(isnan(gdx.data.GNA.records.value));
    t.assert(gams.transfer.SpecialValues.isNA(gdx.data.GNA.records.value));
    t.assert(gdx.data.GPInf.records.value == Inf);
    t.assert(gdx.data.GMInf.records.value == -Inf);
    t.assert(gdx.data.GEps.records.value == 0);
    t.assert(gams.transfer.SpecialValues.isEps(gdx.data.GEps.records.value));
end

function test_readDomainCycle(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{8}, 'format', 'struct');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{8}, 'format', 'struct');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_domain_cycle_i_of_i');
    t.assert(isfield(gdx.data, 'i'));
    t.assert(gdx.data.i.isValid());
    t.assertEquals(gdx.data.i.format, 'struct');
    t.assertEquals(gdx.data.i.domain_type, 'relaxed');
    t.assert(gdx.data.i.dimension == 1);
    t.assert(numel(gdx.data.i.domain) == 1);
    t.assertEquals(gdx.data.i.domain{1}, 'i');

end

function test_readAcronyms(t, cfg, container_type);

    t.add('read_acronyms_1');
    switch container_type
    case {'c', 'rc'}
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        stdout = evalc("gdx.read(cfg.filenames{6}, 'format', 'struct');");
    end
    t.assert(~isempty(strfind(stdout, ...
        'GDX file contains acronyms. Acronyms are not supported')));

    t.add('read_acronyms_2');
    warning('off');
    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{6}, 'format', 'struct');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{6}, 'format', 'struct');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'a'));
    t.assert(isa(gdx.data.a, 'gams.transfer.symbol.Parameter'));
    t.assert(gdx.data.a.isValid());
    t.assert(numel(gdx.data.a.records.value) == 3);
    t.assert(gdx.data.a.records.value(1) == 1);
    t.assert(gams.transfer.SpecialValues.isNA(gdx.data.a.records.value(2)));
    t.assert(gams.transfer.SpecialValues.isNA(gdx.data.a.records.value(3)));
    warning('on');

end

function test_readSymbolTypes(t, cfg, container_type);

    switch container_type
    case 'c'
        gdx = gams.transfer.Container(cfg.filenames{3}, 'gams_dir', cfg.gams_dir);
    case 'rc'
        gdx = gams.transfer.Container(cfg.filenames{3}, 'gams_dir', cfg.gams_dir);
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_symbol_types_vartypes');
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(isfield(gdx.data, 'x2'));
    t.assert(isfield(gdx.data, 'x3'));
    t.assert(isfield(gdx.data, 'x4'));
    t.assert(isfield(gdx.data, 'x5'));
    t.assert(isfield(gdx.data, 'x6'));
    t.assert(isfield(gdx.data, 'x7'));
    t.assert(isfield(gdx.data, 'x8'));
    t.assert(isfield(gdx.data, 'x9'));
    t.assert(isfield(gdx.data, 'x10'));
    t.assert(isfield(gdx.data, 'x11'));
    t.assertEquals(gdx.data.x1.type, 'free');
    t.assertEquals(gdx.data.x2.type, 'free');
    t.assertEquals(gdx.data.x3.type, 'binary');
    t.assertEquals(gdx.data.x4.type, 'integer');
    t.assertEquals(gdx.data.x5.type, 'positive');
    t.assertEquals(gdx.data.x6.type, 'negative');
    t.assertEquals(gdx.data.x7.type, 'sos1');
    t.assertEquals(gdx.data.x8.type, 'sos2');
    t.assertEquals(gdx.data.x9.type, 'semiint');
    t.assertEquals(gdx.data.x10.type, 'semicont');
    t.assertEquals(gdx.data.x11.type, 'free');

    t.add('read_symbol_types_equtypes');
    t.assert(isfield(gdx.data, 'e1'));
    t.assert(isfield(gdx.data, 'e2'));
    t.assert(isfield(gdx.data, 'e3'));
    t.assertEquals(gdx.data.e1.description, 'equ_1');
    t.assertEquals(gdx.data.e2.description, 'equ_2');
    t.assertEquals(gdx.data.e3.description, 'equ_3');
    t.assertEquals(gdx.data.e1.type, 'eq');
    t.assertEquals(gdx.data.e2.type, 'geq');
    t.assertEquals(gdx.data.e3.type, 'leq');

    switch container_type
    case 'c'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{3}, 'format', 'dense_matrix');
    case 'rc'
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{3}, 'format', 'dense_matrix');
        gdx = gams.transfer.Container(gdx, 'gams_dir', cfg.gams_dir);
    end

    t.add('read_symbol_types_vartypes_default_values');
    t.assert(gdx.data.x1.records.level(2) == 0);
    t.assert(gdx.data.x1.records.marginal(2) == 0);
    t.assert(gdx.data.x1.records.lower(2) == -Inf);
    t.assert(gdx.data.x1.records.upper(2) == Inf);
    t.assert(gdx.data.x1.records.scale(2) == 1);
    t.assert(gdx.data.x2.records.level(2) == 0);
    t.assert(gdx.data.x2.records.marginal(2) == 0);
    t.assert(gdx.data.x2.records.lower(2) == -Inf);
    t.assert(gdx.data.x2.records.upper(2) == Inf);
    t.assert(gdx.data.x2.records.scale(2) == 1);
    t.assert(gdx.data.x3.records.level(2) == 0);
    t.assert(gdx.data.x3.records.marginal(2) == 0);
    t.assert(gdx.data.x3.records.lower(2) == 0);
    t.assert(gdx.data.x3.records.upper(2) == 1);
    t.assert(gdx.data.x3.records.scale(2) == 1);
    t.assert(gdx.data.x4.records.level(2) == 0);
    t.assert(gdx.data.x4.records.marginal(2) == 0);
    t.assert(gdx.data.x4.records.lower(2) == 0);
    t.assert(gdx.data.x4.records.upper(2) == Inf);
    t.assert(gdx.data.x4.records.scale(2) == 1);
    t.assert(gdx.data.x5.records.level(2) == 0);
    t.assert(gdx.data.x5.records.marginal(2) == 0);
    t.assert(gdx.data.x5.records.lower(2) == 0);
    t.assert(gdx.data.x5.records.upper(2) == Inf);
    t.assert(gdx.data.x5.records.scale(2) == 1);
    t.assert(gdx.data.x6.records.level(2) == 0);
    t.assert(gdx.data.x6.records.marginal(2) == 0);
    t.assert(gdx.data.x6.records.lower(2) == -Inf);
    t.assert(gdx.data.x6.records.upper(2) == 0);
    t.assert(gdx.data.x6.records.scale(2) == 1);
    t.assert(gdx.data.x7.records.level(2,1) == 0);
    t.assert(gdx.data.x7.records.marginal(2,1) == 0);
    t.assert(gdx.data.x7.records.lower(2,1) == 0);
    t.assert(gdx.data.x7.records.upper(2,1) == Inf);
    t.assert(gdx.data.x7.records.scale(2,1) == 1);
    t.assert(gdx.data.x8.records.level(2,1) == 0);
    t.assert(gdx.data.x8.records.marginal(2,1) == 0);
    t.assert(gdx.data.x8.records.lower(2,1) == 0);
    t.assert(gdx.data.x8.records.upper(2,1) == Inf);
    t.assert(gdx.data.x8.records.scale(2,1) == 1);
    t.assert(gdx.data.x9.records.level(2) == 0);
    t.assert(gdx.data.x9.records.marginal(2) == 0);
    t.assert(gdx.data.x9.records.lower(2) == 1);
    t.assert(gdx.data.x9.records.upper(2) == Inf);
    t.assert(gdx.data.x9.records.scale(2) == 1);
    t.assert(gdx.data.x10.records.level(2) == 0);
    t.assert(gdx.data.x10.records.marginal(2) == 0);
    t.assert(gdx.data.x10.records.lower(2) == 1);
    t.assert(gdx.data.x10.records.upper(2) == Inf);
    t.assert(gdx.data.x10.records.scale(2) == 1);

    t.add('read_symbol_types_equtypes_default_values');
    t.assert(gdx.data.e1.records.level(2) == 0);
    t.assert(gdx.data.e1.records.marginal(2) == 0);
    t.assert(gdx.data.e1.records.lower(2) == 0);
    t.assert(gdx.data.e1.records.upper(2) == 0);
    t.assert(gdx.data.e1.records.scale(2) == 1);
    t.assert(gdx.data.e2.records.level(2) == 0);
    t.assert(gdx.data.e2.records.marginal(2) == 0);
    t.assert(gdx.data.e2.records.lower(2) == 0);
    t.assert(gdx.data.e2.records.upper(2) == Inf);
    t.assert(gdx.data.e2.records.scale(2) == 1);
    t.assert(gdx.data.e3.records.level(2) == 0);
    t.assert(gdx.data.e3.records.marginal(2) == 0);
    t.assert(gdx.data.e3.records.lower(2) == -Inf);
    t.assert(gdx.data.e3.records.upper(2) == 0);
    t.assert(gdx.data.e3.records.scale(2) == 1);
end

function test_readWrite(t, cfg)

    for i = [1,2,5,7,9]
        write_filename = fullfile(cfg.working_dir, 'write.gdx');
        gdxdump = fullfile(cfg.gams_dir, 'gdxdump');

        t.add(sprintf('read_write_struct_%d', i));
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{i}, 'format', 'struct');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        if gams.transfer.Constants.SUPPORTS_TABLE
            t.add(sprintf('read_write_table_%d', i));
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{i}, 'format', 'table');
            gdx.write(write_filename);
            t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
            t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
        end

        t.add(sprintf('read_write_dense_matrix_%d', i));
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{i}, 'format', 'dense_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        if i ~= 9
            t.add(sprintf('read_write_sparse_matrix_%d', i));
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{i}, 'format', 'sparse_matrix');
            gdx.write(write_filename);
            t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
            t.assert(system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
        end
    end
end

function test_readWritePartial(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'x'});

    t.add('read_write_partial_1');
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 'x'));
    t.assert(gdx.isValid());
    t.assertEquals(gdx.data.x.domain_type, 'relaxed');

    gdx.read(cfg.filenames{1}, 'format', 'struct', 'symbols', {'i', 'j'});

    t.add('read_write_partial_2');
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'j'));
    t.assert(isfield(gdx.data, 'x'));
    t.assert(gdx.isValid());
    t.assertEquals(gdx.data.i.domain_type, 'none');
    t.assertEquals(gdx.data.j.domain_type, 'none');
    t.assertEquals(gdx.data.x.domain_type, 'relaxed');

    write_filename = fullfile(cfg.working_dir, 'write.gdx');
    gdx.write(write_filename);
    gdx = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);

    t.add('read_write_partial_3');
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'j'));
    t.assert(isfield(gdx.data, 'x'));
    t.assert(gdx.isValid());

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx.read(cfg.filenames{1});

    t.add('read_write_partial_4');
    gdx.write(write_filename, 'symbols', {'x'});
    gdx = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 'x'));
    t.assert(gdx.isValid());
    t.assertEquals(gdx.data.x.domain_type, 'relaxed');

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx.read(cfg.filenames{1});

    t.add('read_write_partial_5');
    gdx.write(write_filename, 'symbols', {});
    gdx = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assert(numel(fieldnames(gdx.data)) == 0);
    t.assert(gdx.isValid());

end

function test_readWriteCompress(t, cfg)

    for i = [1,2,5]
        write_filename = fullfile(cfg.working_dir, 'write.gdx');
        gdxdump = fullfile(cfg.gams_dir, 'gdxdump');

        t.add(sprintf('read_write_struct_%d', i));
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{i}, 'format', 'struct');
        gdx.write(write_filename, 'compress', true);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(~system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        if gams.transfer.Constants.SUPPORTS_TABLE
            t.add(sprintf('read_write_table_%d', i));
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{i}, 'format', 'table');
            gdx.write(write_filename, 'compress', true);
            t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
            t.assert(~system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
        end

        t.add(sprintf('read_write_dense_matrix_%d', i));
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{i}, 'format', 'dense_matrix');
        gdx.write(write_filename, 'compress', true);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(~system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));

        t.add(sprintf('read_write_sparse_matrix_%d', i));
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{i}, 'format', 'sparse_matrix');
        gdx.write(write_filename, 'compress', true);
        t.testGdxDiff(cfg.gams_dir, cfg.filenames{i}, write_filename);
        t.assert(~system(sprintf('%s %s -v | grep -q "Compression.*1"', gdxdump, write_filename)));
    end
end

function test_readWriteDomainCheck(t, cfg)

    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    t.add('read_write_domain_check_regular');
    gdx = gams.transfer.Container(cfg.filenames{1}, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx.data.x.domain_type, 'regular');
    gdx.write(write_filename);
    gdx2 = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx2.data.x.domain_type, 'regular');

    t.add('read_write_domain_check_relaxed_1');
    gdx = gams.transfer.Container(cfg.filenames{1}, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx.data.x.domain_type, 'regular');
    x = gdx.data.x;
    x.domain{1} = 'i';
    x.domain{2} = 'j';
    t.assertEquals(gdx.data.x.domain_type, 'relaxed');
    gdx.write(write_filename);
    gdx2 = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx2.data.x.domain_type, 'relaxed');
    x = gdx2.data.x;
    x.domain{1} = gdx2.data.i;
    x.domain{2} = gdx2.data.j;
    t.assertEquals(gdx2.data.x.domain_type, 'regular');
    gdx2.write(write_filename);
    gdx = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx.data.x.domain_type, 'regular');

    t.add('read_write_domain_check_relaxed_2');
    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx.read(cfg.filenames{1}, 'format', 'struct');
    t.assertEquals(gdx.data.x.domain_type, 'regular');
    records = gdx.data.x.records;
    x = gdx.data.x;
    uels1 = x.getUELs(1);
    uels2 = x.getUELs(2);
    x.domain{1} = 'k1';
    x.domain{2} = 'k2';
    x.records = struct();
    x.records.k1 = records.i;
    x.records.k2 = records.j;
    x.records.level = records.level;
    x.records.marginal = records.marginal;
    x.records.lower = records.lower;
    x.records.upper = records.upper;
    x.records.scale = records.scale;
    x.setUELs(uels1, 1, 'rename', true);
    x.setUELs(uels2, 2, 'rename', true);
    t.assertEquals(gdx.data.x.domain_type, 'relaxed');
    gdx.write(write_filename);
    gdx2 = gams.transfer.Container(write_filename, 'gams_dir', cfg.gams_dir);
    t.assertEquals(gdx2.data.x.domain_type, 'relaxed');

end
