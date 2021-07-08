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

function test_readwrite(cfg)
    t = GAMSTest('GAMSTransfer/readwrite');
    test_read(t, cfg);
    test_readPartial(t, cfg);
    test_readSpecialValues(t, cfg);
    test_readSymbolTypes(t, cfg);
    test_readWrite(t, cfg);
    test_readWriteDomainCheck(t, cfg);
    t.summary();
end

function test_read(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{1}, 'features', cfg.features);

    t.add('read_basic_info');
    t.assertEquals(gdx.system_directory, cfg.system_dir);
    t.assertEquals(gdx.filename, cfg.filenames{1});
    t.assert(~gdx.indexed);
    t.assert(numel(fieldnames(gdx.data)) == 5);

    t.add('read_set_basic');
    t.assert(isfield(gdx.data, 'i'));
    s = gdx.data.i;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Set'));
    t.assertEquals(s.name, 'i');
    t.assertEquals(s.description, 'set_i');
    t.assert(~s.singleton);
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    t.assertEquals(s.domain{1}, '*');
    t.assert(numel(s.domain_label) == 1);
    t.assertEquals(s.domain_label{1}, 'uni_1');
    t.assertEquals(s.domain_info, 'regular');
    t.assert(numel(s.size) == 1);
    t.assert(isnan(s.size(1)));
    t.assert(isnan(s.getSparsity()));
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.getNumRecords() == 5);
    t.assert(~s.isValid());

    t.add('read_scalar_basic');
    t.assert(isfield(gdx.data, 'a'));
    s = gdx.data.a;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Parameter'));
    t.assertEquals(s.name, 'a');
    t.assertEquals(s.description, 'par_a');
    t.assert(s.dimension == 0);
    t.assert(numel(s.domain) == 0);
    t.assert(numel(s.domain_label) == 0);
    t.assertEquals(s.domain_info, 'regular');
    t.assert(numel(s.size) == 0);
    t.assert(isnan(s.getSparsity()));
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.getNumRecords() == 1);
    t.assert(~s.isValid());

    t.add('read_parameter_basic');
    t.assert(isfield(gdx.data, 'b'));
    s = gdx.data.b;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Parameter'));
    t.assertEquals(s.name, 'b');
    t.assertEquals(s.description, 'par_b');
    t.assert(s.dimension == 1);
    t.assert(numel(s.domain) == 1);
    if gdx.features.handle_comparison
        t.assertEquals(s.domain{1}, gdx.data.i);
    end
    t.assertEquals(s.domain{1}.name, 'i');
    t.assert(numel(s.domain_label) == 1);
    t.assertEquals(s.domain_label{1}, 'i_1');
    t.assertEquals(s.domain_info, 'regular');
    t.assert(numel(s.size) == 1);
    t.assert(s.size(1) == 5);
    t.assert(isnan(s.getSparsity()));
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.getNumRecords() == 3);
    t.assert(~s.isValid());

    t.add('read_variable_basic');
    t.assert(isfield(gdx.data, 'x'));
    s = gdx.data.x;
    t.testEmptySymbol(s);
    t.assert(isa(s, 'GAMSTransfer.Variable'));
    t.assertEquals(s.name, 'x');
    t.assertEquals(s.description, 'var_x');
    t.assertEquals(s.type, 'positive');
    t.assert(s.dimension == 2);
    t.assert(numel(s.domain) == 2);
    if gdx.features.handle_comparison
        t.assertEquals(s.domain{1}, gdx.data.i);
        t.assertEquals(s.domain{2}, gdx.data.j);
    end
    t.assertEquals(s.domain{1}.name, 'i');
    t.assertEquals(s.domain{2}.name, 'j');
    t.assert(numel(s.domain_label) == 2);
    t.assertEquals(s.domain_label{1}, 'i_1');
    t.assertEquals(s.domain_label{2}, 'j_2');
    t.assertEquals(s.domain_info, 'regular');
    t.assert(numel(s.size) == 2);
    t.assert(s.size(1) == 5);
    t.assert(s.size(2) == 5);
    t.assert(isnan(s.getSparsity()));
    t.assert(strcmp(s.format, 'not_read'));
    t.assert(s.getNumRecords() == 6);
    t.assert(~s.isValid());

    gdx.read('format', 'struct');

    t.add('read_set_records_struct');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni_1'));
    t.assert(isfield(s.records, 'text'));
    t.assert(numel(s.records.uni_1) == s.getNumRecords());
    t.assert(numel(s.records.text) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.uni_1(1), 'i1');
        t.assertEquals(s.records.uni_1(2), 'i3');
        t.assertEquals(s.records.uni_1(3), 'i4');
        t.assertEquals(s.records.uni_1(4), 'i6');
        t.assertEquals(s.records.uni_1(5), 'i10');
    end
    uni_1_int = int32(s.records.uni_1);
    t.assert(uni_1_int(1) == 1);
    t.assert(uni_1_int(2) == 2);
    t.assert(uni_1_int(3) == 3);
    t.assert(uni_1_int(4) == 4);
    t.assert(uni_1_int(5) == 5);
    if gdx.features.categorical
        t.assert(isundefined(s.records.text(1)));
        t.assertEquals(s.records.text(2), 'expl text 3');
        t.assert(isundefined(s.records.text(3)));
        t.assert(isundefined(s.records.text(4)));
        t.assertEquals(s.records.text(5), 'expl text 10');
    else
        t.assertEquals(s.records.text{1}, '');
        t.assertEquals(s.records.text{2}, 'expl text 3');
        t.assertEquals(s.records.text{3}, '');
        t.assertEquals(s.records.text{4}, '');
        t.assertEquals(s.records.text{5}, 'expl text 10');
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
    t.assert(numel(s.records.value) == s.getNumRecords());
    t.assert(s.records.value == 4);

    t.add('read_parameter_records_struct');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'i_1'));
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.i_1) == s.getNumRecords());
    t.assert(numel(s.records.value) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.i_1(1), 'i1');
        t.assertEquals(s.records.i_1(2), 'i3');
        t.assertEquals(s.records.i_1(3), 'i10');
    end
    i_1_int = int32(s.records.i_1);
    t.assert(i_1_int(1) == 1);
    t.assert(i_1_int(2) == 2);
    t.assert(i_1_int(3) == 5);
    t.assert(s.records.value(1) == 1);
    t.assert(s.records.value(2) == 3);
    t.assert(s.records.value(3) == 10);
    uels = s.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');

    t.add('read_variable_records_struct');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 7);
    t.assert(isfield(s.records, 'i_1'));
    t.assert(isfield(s.records, 'j_2'));
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(isfield(s.records, 'lower'));
    t.assert(isfield(s.records, 'upper'));
    t.assert(isfield(s.records, 'scale'));
    t.assert(numel(s.records.i_1) == s.getNumRecords());
    t.assert(numel(s.records.j_2) == s.getNumRecords());
    t.assert(numel(s.records.level) == s.getNumRecords());
    t.assert(numel(s.records.marginal) == s.getNumRecords());
    t.assert(numel(s.records.lower) == s.getNumRecords());
    t.assert(numel(s.records.upper) == s.getNumRecords());
    t.assert(numel(s.records.scale) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.i_1(1), 'i1');
        t.assertEquals(s.records.i_1(2), 'i3');
        t.assertEquals(s.records.i_1(3), 'i3');
        t.assertEquals(s.records.i_1(4), 'i6');
        t.assertEquals(s.records.i_1(5), 'i6');
        t.assertEquals(s.records.i_1(6), 'i10');
        t.assertEquals(s.records.j_2(1), 'j2');
        t.assertEquals(s.records.j_2(2), 'j8');
        t.assertEquals(s.records.j_2(3), 'j9');
        t.assertEquals(s.records.j_2(4), 'j5');
        t.assertEquals(s.records.j_2(5), 'j7');
        t.assertEquals(s.records.j_2(6), 'j7');
    end
    i_1_int = int32(s.records.i_1);
    j_2_int = int32(s.records.j_2);
    t.assert(i_1_int(1) == 1);
    t.assert(i_1_int(2) == 2);
    t.assert(i_1_int(3) == 2);
    t.assert(i_1_int(4) == 4);
    t.assert(i_1_int(5) == 4);
    t.assert(i_1_int(6) == 5);
    t.assert(j_2_int(1) == 1);
    t.assert(j_2_int(2) == 4);
    t.assert(j_2_int(3) == 5);
    t.assert(j_2_int(4) == 2);
    t.assert(j_2_int(5) == 3);
    t.assert(j_2_int(6) == 3);
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

    if gdx.features.table
        gdx.read('format', 'table');

        t.add('read_set_records_table');
        s = gdx.data.i;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'uni_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'text');
        t.assert(numel(s.records.uni_1) == s.getNumRecords());
        t.assert(numel(s.records.text) == s.getNumRecords());
        if gdx.features.categorical
            t.assertEquals(s.records.uni_1(1), 'i1');
            t.assertEquals(s.records.uni_1(2), 'i3');
            t.assertEquals(s.records.uni_1(3), 'i4');
            t.assertEquals(s.records.uni_1(4), 'i6');
            t.assertEquals(s.records.uni_1(5), 'i10');
        end
        uni_1_int = int32(s.records.uni_1);
        t.assert(uni_1_int(1) == 1);
        t.assert(uni_1_int(2) == 2);
        t.assert(uni_1_int(3) == 3);
        t.assert(uni_1_int(4) == 4);
        t.assert(uni_1_int(5) == 5);
        if gdx.features.categorical
            t.assert(isundefined(s.records.text(1)));
            t.assertEquals(s.records.text(2), 'expl text 3');
            t.assert(isundefined(s.records.text(3)));
            t.assert(isundefined(s.records.text(4)));
            t.assertEquals(s.records.text(5), 'expl text 10');
        else
            t.assertEquals(s.records.text{1}, '');
            t.assertEquals(s.records.text{2}, 'expl text 3');
            t.assertEquals(s.records.text{3}, '');
            t.assertEquals(s.records.text{4}, '');
            t.assertEquals(s.records.text{5}, 'expl text 10');
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
        t.assert(numel(s.records.value) == s.getNumRecords());
        t.assert(s.records.value == 4);

        t.add('read_parameter_records_table');
        s = gdx.data.b;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 2);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'i_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'value');
        t.assert(numel(s.records.i_1) == s.getNumRecords());
        t.assert(numel(s.records.value) == s.getNumRecords());
        if gdx.features.categorical
            t.assertEquals(s.records.i_1(1), 'i1');
            t.assertEquals(s.records.i_1(2), 'i3');
            t.assertEquals(s.records.i_1(3), 'i10');
        end
        i_1_int = int32(s.records.i_1);
        t.assert(i_1_int(1) == 1);
        t.assert(i_1_int(2) == 2);
        t.assert(i_1_int(3) == 5);
        t.assert(s.records.value(1) == 1);
        t.assert(s.records.value(2) == 3);
        t.assert(s.records.value(3) == 10);
        uels = s.getUELs(1);
        t.assert(numel(uels) == 5);
        t.assertEquals(uels{1}, 'i1');
        t.assertEquals(uels{2}, 'i3');
        t.assertEquals(uels{3}, 'i4');
        t.assertEquals(uels{4}, 'i6');
        t.assertEquals(uels{5}, 'i10');

        t.add('read_variable_records_table');
        s = gdx.data.x;
        t.assert(~isempty(s.records));
        t.assert(istable(s.records));
        t.assert(strcmp(s.format, 'table'));
        t.assert(s.isValid());
        t.assert(numel(s.records.Properties.VariableNames) == 7);
        t.assertEquals(s.records.Properties.VariableNames{1}, 'i_1');
        t.assertEquals(s.records.Properties.VariableNames{2}, 'j_2');
        t.assertEquals(s.records.Properties.VariableNames{3}, 'level');
        t.assertEquals(s.records.Properties.VariableNames{4}, 'marginal');
        t.assertEquals(s.records.Properties.VariableNames{5}, 'lower');
        t.assertEquals(s.records.Properties.VariableNames{6}, 'upper');
        t.assertEquals(s.records.Properties.VariableNames{7}, 'scale');
        t.assert(numel(s.records.i_1) == s.getNumRecords());
        t.assert(numel(s.records.j_2) == s.getNumRecords());
        t.assert(numel(s.records.level) == s.getNumRecords());
        t.assert(numel(s.records.marginal) == s.getNumRecords());
        t.assert(numel(s.records.lower) == s.getNumRecords());
        t.assert(numel(s.records.upper) == s.getNumRecords());
        t.assert(numel(s.records.scale) == s.getNumRecords());
        if gdx.features.categorical
            t.assertEquals(s.records.i_1(1), 'i1');
            t.assertEquals(s.records.i_1(2), 'i3');
            t.assertEquals(s.records.i_1(3), 'i3');
            t.assertEquals(s.records.i_1(4), 'i6');
            t.assertEquals(s.records.i_1(5), 'i6');
            t.assertEquals(s.records.i_1(6), 'i10');
            t.assertEquals(s.records.j_2(1), 'j2');
            t.assertEquals(s.records.j_2(2), 'j8');
            t.assertEquals(s.records.j_2(3), 'j9');
            t.assertEquals(s.records.j_2(4), 'j5');
            t.assertEquals(s.records.j_2(5), 'j7');
            t.assertEquals(s.records.j_2(6), 'j7');
        end
        i_1_int = int32(s.records.i_1);
        j_2_int = int32(s.records.j_2);
        t.assert(i_1_int(1) == 1);
        t.assert(i_1_int(2) == 2);
        t.assert(i_1_int(3) == 2);
        t.assert(i_1_int(4) == 4);
        t.assert(i_1_int(5) == 4);
        t.assert(i_1_int(6) == 5);
        t.assert(j_2_int(1) == 1);
        t.assert(j_2_int(2) == 4);
        t.assert(j_2_int(3) == 5);
        t.assert(j_2_int(4) == 2);
        t.assert(j_2_int(5) == 3);
        t.assert(j_2_int(6) == 3);
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

    gdx.read('format', 'dense_matrix');

    t.add('read_set_records_dense_matrix');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni_1'));
    t.assert(isfield(s.records, 'text'));
    t.assert(numel(s.records.uni_1) == s.getNumRecords());
    t.assert(numel(s.records.text) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.uni_1(1), 'i1');
        t.assertEquals(s.records.uni_1(2), 'i3');
        t.assertEquals(s.records.uni_1(3), 'i4');
        t.assertEquals(s.records.uni_1(4), 'i6');
        t.assertEquals(s.records.uni_1(5), 'i10');
    end
    uni_1_int = int32(s.records.uni_1);
    t.assert(uni_1_int(1) == 1);
    t.assert(uni_1_int(2) == 2);
    t.assert(uni_1_int(3) == 3);
    t.assert(uni_1_int(4) == 4);
    t.assert(uni_1_int(5) == 5);
    if gdx.features.categorical
        t.assert(isundefined(s.records.text(1)));
        t.assertEquals(s.records.text(2), 'expl text 3');
        t.assert(isundefined(s.records.text(3)));
        t.assert(isundefined(s.records.text(4)));
        t.assertEquals(s.records.text(5), 'expl text 10');
    else
        t.assertEquals(s.records.text{1}, '');
        t.assertEquals(s.records.text{2}, 'expl text 3');
        t.assertEquals(s.records.text{3}, '');
        t.assertEquals(s.records.text{4}, '');
        t.assertEquals(s.records.text{5}, 'expl text 10');
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
    t.assert(numel(s.records.value) == s.getNumRecords());
    t.assert(s.records.value == 4);

    t.add('read_parameter_records_dense_matrix');
    s = gdx.data.b;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct') || strcmp(s.format, 'dense_matrix'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 1);
    t.assert(isfield(s.records, 'value'));
    t.assert(numel(s.records.value) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.value, 1) == gdx.data.i.getNumRecords());
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
    t.assert(numel(s.records.level) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.marginal) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.lower) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.upper) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.scale) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(size(s.records.level, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.level, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.marginal, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.marginal, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.lower, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.lower, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.upper, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.upper, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.scale, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.scale, 2) == gdx.data.j.getNumRecords());
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

    gdx.read('format', 'sparse_matrix');

    t.add('read_set_records_sparse_matrix');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni_1'));
    t.assert(isfield(s.records, 'text'));
    t.assert(numel(s.records.uni_1) == s.getNumRecords());
    t.assert(numel(s.records.text) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.uni_1(1), 'i1');
        t.assertEquals(s.records.uni_1(2), 'i3');
        t.assertEquals(s.records.uni_1(3), 'i4');
        t.assertEquals(s.records.uni_1(4), 'i6');
        t.assertEquals(s.records.uni_1(5), 'i10');
    end
    uni_1_int = int32(s.records.uni_1);
    t.assert(uni_1_int(1) == 1);
    t.assert(uni_1_int(2) == 2);
    t.assert(uni_1_int(3) == 3);
    t.assert(uni_1_int(4) == 4);
    t.assert(uni_1_int(5) == 5);
    if gdx.features.categorical
        t.assert(isundefined(s.records.text(1)));
        t.assertEquals(s.records.text(2), 'expl text 3');
        t.assert(isundefined(s.records.text(3)));
        t.assert(isundefined(s.records.text(4)));
        t.assertEquals(s.records.text(5), 'expl text 10');
    else
        t.assertEquals(s.records.text{1}, '');
        t.assertEquals(s.records.text{2}, 'expl text 3');
        t.assertEquals(s.records.text{3}, '');
        t.assertEquals(s.records.text{4}, '');
        t.assertEquals(s.records.text{5}, 'expl text 10');
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
    t.assert(numel(s.records.value) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.value, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.value, 2) == 1);
    t.assert(nnz(s.records.value) == s.getNumValues());
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
    t.assert(numel(s.records.level) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.marginal) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.lower) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.upper) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(numel(s.records.scale) == gdx.data.i.getNumRecords() * gdx.data.j.getNumRecords());
    t.assert(size(s.records.level, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.level, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.marginal, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.marginal, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.lower, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.lower, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.upper, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.upper, 2) == gdx.data.j.getNumRecords());
    t.assert(size(s.records.scale, 1) == gdx.data.i.getNumRecords());
    t.assert(size(s.records.scale, 2) == gdx.data.j.getNumRecords());
    t.assert(nnz(s.records.level) + nnz(s.records.marginal) + nnz(s.records.lower) + ...
        nnz(s.records.upper) + nnz(s.records.scale) == s.getNumValues());
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

function test_readPartial(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{1}, 'features', cfg.features);
    gdx.read('format', 'struct', 'symbols', {'i', 'j', 'x'}, 'values', {'level', 'marginal'});

    t.add('read_partial_basic_info');
    t.assertEquals(gdx.system_directory, cfg.system_dir);
    t.assertEquals(gdx.filename, cfg.filenames{1});
    t.assert(~gdx.indexed);
    t.assert(numel(fieldnames(gdx.data)) == 5);
    t.assert(isfield(gdx.data, 'i'));
    t.assert(isfield(gdx.data, 'j'));
    t.assert(isfield(gdx.data, 'a'));
    t.assert(isfield(gdx.data, 'b'));
    t.assert(isfield(gdx.data, 'x'));
    t.testEmptySymbol(gdx.data.a);
    t.testEmptySymbol(gdx.data.b);

    t.add('read_partial_set_records_struct');
    s = gdx.data.i;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct' ));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 2);
    t.assert(isfield(s.records, 'uni_1'));
    t.assert(isfield(s.records, 'text'));
    t.assert(numel(s.records.uni_1) == s.getNumRecords());
    t.assert(numel(s.records.text) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.uni_1(1), 'i1');
        t.assertEquals(s.records.uni_1(2), 'i3');
        t.assertEquals(s.records.uni_1(3), 'i4');
        t.assertEquals(s.records.uni_1(4), 'i6');
        t.assertEquals(s.records.uni_1(5), 'i10');
    end
    uni_1_int = int32(s.records.uni_1);
    t.assert(uni_1_int(1) == 1);
    t.assert(uni_1_int(2) == 2);
    t.assert(uni_1_int(3) == 3);
    t.assert(uni_1_int(4) == 4);
    t.assert(uni_1_int(5) == 5);
    if gdx.features.categorical
        t.assert(isundefined(s.records.text(1)));
        t.assertEquals(s.records.text(2), 'expl text 3');
        t.assert(isundefined(s.records.text(3)));
        t.assert(isundefined(s.records.text(4)));
        t.assertEquals(s.records.text(5), 'expl text 10');
    else
        t.assertEquals(s.records.text{1}, '');
        t.assertEquals(s.records.text{2}, 'expl text 3');
        t.assertEquals(s.records.text{3}, '');
        t.assertEquals(s.records.text{4}, '');
        t.assertEquals(s.records.text{5}, 'expl text 10');
    end

    t.add('read_partial_variable_records_struct_1');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 4);
    t.assert(isfield(s.records, 'i_1'));
    t.assert(isfield(s.records, 'j_2'));
    t.assert(isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(~isfield(s.records, 'lower'));
    t.assert(~isfield(s.records, 'upper'));
    t.assert(~isfield(s.records, 'scale'));
    t.assert(numel(s.records.i_1) == s.getNumRecords());
    t.assert(numel(s.records.j_2) == s.getNumRecords());
    t.assert(numel(s.records.level) == s.getNumRecords());
    t.assert(numel(s.records.marginal) == s.getNumRecords());
    if gdx.features.categorical
        t.assertEquals(s.records.i_1(1), 'i1');
        t.assertEquals(s.records.i_1(2), 'i3');
        t.assertEquals(s.records.i_1(3), 'i3');
        t.assertEquals(s.records.i_1(4), 'i6');
        t.assertEquals(s.records.i_1(5), 'i6');
        t.assertEquals(s.records.i_1(6), 'i10');
        t.assertEquals(s.records.j_2(1), 'j2');
        t.assertEquals(s.records.j_2(2), 'j8');
        t.assertEquals(s.records.j_2(3), 'j9');
        t.assertEquals(s.records.j_2(4), 'j5');
        t.assertEquals(s.records.j_2(5), 'j7');
        t.assertEquals(s.records.j_2(6), 'j7');
    end
    i_1_int = int32(s.records.i_1);
    j_2_int = int32(s.records.j_2);
    t.assert(i_1_int(1) == 1);
    t.assert(i_1_int(2) == 2);
    t.assert(i_1_int(3) == 2);
    t.assert(i_1_int(4) == 4);
    t.assert(i_1_int(5) == 4);
    t.assert(i_1_int(6) == 5);
    t.assert(j_2_int(1) == 1);
    t.assert(j_2_int(2) == 4);
    t.assert(j_2_int(3) == 5);
    t.assert(j_2_int(4) == 2);
    t.assert(j_2_int(5) == 3);
    t.assert(j_2_int(6) == 3);
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

    gdx.read('format', 'struct', 'symbols', {'x'}, 'values', {'marginal'});

    t.add('read_partial_variable_records_struct_2');
    s = gdx.data.x;
    t.assert(~isempty(s.records));
    t.assert(isstruct(s.records));
    t.assert(strcmp(s.format, 'struct'));
    t.assert(s.isValid());
    t.assert(numel(fieldnames(s.records)) == 3);
    t.assert(isfield(s.records, 'i_1'));
    t.assert(isfield(s.records, 'j_2'));
    t.assert(~isfield(s.records, 'level'));
    t.assert(isfield(s.records, 'marginal'));
    t.assert(~isfield(s.records, 'lower'));
    t.assert(~isfield(s.records, 'upper'));
    t.assert(~isfield(s.records, 'scale'));
    t.assert(numel(s.records.i_1) == s.getNumRecords());
    t.assert(numel(s.records.j_2) == s.getNumRecords());
    t.assert(numel(s.records.marginal) == s.getNumRecords());
    t.assert(s.records.marginal(1) == 0);
    t.assert(s.records.marginal(2) == 8);
    t.assert(s.records.marginal(3) == 0);
    t.assert(s.records.marginal(4) == 5);
    t.assert(s.records.marginal(5) == 0);
    t.assert(s.records.marginal(6) == 0);
end

function test_readSpecialValues(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{2}, 'features', cfg.features);
    gdx.read('format', 'struct');

    t.add('read_special_values');
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
    t.assert(GAMSTransfer.SpecialValues.isna(gdx.data.GNA.records.value));
    t.assert(gdx.data.GPInf.records.value == Inf);
    t.assert(gdx.data.GMInf.records.value == -Inf);
    t.assert(gdx.data.GEps.records.value == 0);
    t.assert(GAMSTransfer.SpecialValues.iseps(gdx.data.GEps.records.value));
end

function test_readSymbolTypes(t, cfg);

    gdx = GAMSTransfer.Container(cfg.filenames{3}, 'features', cfg.features);

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
    t.testEmptySymbol(gdx.data.x1);
    t.testEmptySymbol(gdx.data.x2);
    t.testEmptySymbol(gdx.data.x3);
    t.testEmptySymbol(gdx.data.x4);
    t.testEmptySymbol(gdx.data.x5);
    t.testEmptySymbol(gdx.data.x6);
    t.testEmptySymbol(gdx.data.x7);
    t.testEmptySymbol(gdx.data.x8);
    t.testEmptySymbol(gdx.data.x9);
    t.testEmptySymbol(gdx.data.x10);
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

    t.add('read_symbol_types_equtypes');
    t.assert(isfield(gdx.data, 'e1'));
    t.assert(isfield(gdx.data, 'e2'));
    t.assert(isfield(gdx.data, 'e3'));
    t.testEmptySymbol(gdx.data.e1);
    t.testEmptySymbol(gdx.data.e2);
    t.testEmptySymbol(gdx.data.e3);
    t.assertEquals(gdx.data.e1.description, 'equ_1');
    t.assertEquals(gdx.data.e2.description, 'equ_2');
    t.assertEquals(gdx.data.e3.description, 'equ_3');
    t.assertEquals(gdx.data.e1.type, 'eq');
    t.assertEquals(gdx.data.e2.type, 'geq');
    t.assertEquals(gdx.data.e3.type, 'leq');

    gdx.read('format', 'dense_matrix');

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

    for i = [1,2,5]
        gdx = GAMSTransfer.Container(cfg.filenames{i}, 'features', cfg.features);
        write_filename = fullfile(cfg.working_dir, 'write.gdx');

        t.add(sprintf('read_write_struct_%d', i));
        gdx.read('format', 'struct');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);

        if gdx.features.table
            t.add(sprintf('read_write_table_%d', i));
            gdx.read('format', 'table');
            gdx.write(write_filename);
            t.testGdxDiff(cfg.filenames{i}, write_filename);
        end

        t.add(sprintf('read_write_dense_matrix_%d', i));
        gdx.read('format', 'dense_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);

        t.add(sprintf('read_write_sparse_matrix_%d', i));
        gdx.read('format', 'sparse_matrix');
        gdx.write(write_filename);
        t.testGdxDiff(cfg.filenames{i}, write_filename);
    end
end

function test_readWriteDomainCheck(t, cfg)

    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    t.add('read_write_domain_check_regular');
    gdx = GAMSTransfer.Container(cfg.filenames{1}, 'features', cfg.features);
    gdx.read();
    t.assertEquals(gdx.data.x.domain_info, 'regular');
    gdx.write(write_filename);
    gdx2 = GAMSTransfer.Container(write_filename, 'features', cfg.features);
    gdx2.read();
    t.assertEquals(gdx2.data.x.domain_info, 'regular');

    t.add('read_write_domain_check_relaxed_1');
    gdx = GAMSTransfer.Container(cfg.filenames{1}, 'features', cfg.features);
    gdx.read();
    t.assertEquals(gdx.data.x.domain_info, 'regular');
    x = gdx.data.x;
    x.domain{1} = 'i';
    x.domain{2} = 'j';
    t.assertEquals(gdx.data.x.domain_info, 'relaxed');
    gdx.write(write_filename);
    gdx2 = GAMSTransfer.Container(write_filename, 'features', cfg.features);
    gdx2.read();
    t.assertEquals(gdx2.data.x.domain_info, 'relaxed');
    x = gdx2.data.x;
    x.domain{1} = gdx2.data.i;
    x.domain{2} = gdx2.data.j;
    t.assertEquals(gdx2.data.x.domain_info, 'regular');
    gdx2.write(write_filename);
    gdx = GAMSTransfer.Container(write_filename, 'features', cfg.features);
    gdx.read();
    t.assertEquals(gdx.data.x.domain_info, 'regular');

    t.add('read_write_domain_check_relaxed_2');
    gdx = GAMSTransfer.Container(cfg.filenames{1}, 'features', cfg.features);
    gdx.read('format', 'struct');
    t.assertEquals(gdx.data.x.domain_info, 'regular');
    records = gdx.data.x.records;
    x = gdx.data.x;
    uels1 = x.getUELs(1);
    uels2 = x.getUELs(2);
    x.domain{1} = 'k1';
    x.domain{2} = 'k2';
    x.records = struct();
    x.records.k1_1 = records.i_1;
    x.records.k2_2 = records.j_2;
    x.records.level = records.level;
    x.records.marginal = records.marginal;
    x.records.lower = records.lower;
    x.records.upper = records.upper;
    x.records.scale = records.scale;
    x.initUELs(1, uels1);
    x.initUELs(2, uels2);
    t.assertEquals(gdx.data.x.domain_info, 'relaxed');
    gdx.write(write_filename);
    gdx2 = GAMSTransfer.Container(write_filename, 'features', cfg.features);
    gdx2.read();
    t.assertEquals(gdx2.data.x.domain_info, 'relaxed');

end
