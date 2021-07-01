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

function test_container(t, cfg)
    test_getlist(t, cfg);
    test_describe(t, cfg);
    test_idx_describe(t, cfg);
    test_remove(t, cfg);
end

function test_getlist(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{3});

    t.add('get_list_empty')
    l = gdx.getSymbols({});
    t.assert(iscell(l));
    t.assert(isempty(l));

    t.add('get_list_set');
    l = gdx.getSymbols('i');
    t.assert(isa(l, 'GAMSTransfer.Set'));
    t.assertEquals(l.name, 'i');

    t.add('get_list_variable');
    l = gdx.getSymbols('x1');
    t.assert(isa(l, 'GAMSTransfer.Variable'));
    t.assertEquals(l.name, 'x1');

    t.add('get_list_equation');
    l = gdx.getSymbols('e1');
    t.assert(isa(l, 'GAMSTransfer.Equation'));
    t.assertEquals(l.name, 'e1');

    t.add('get_list_parameter');
    l = gdx.getSymbols('a');
    t.assert(isa(l, 'GAMSTransfer.Parameter'));
    t.assertEquals(l.name, 'a');

    t.add('get_list_alias');
    l = gdx.getSymbols('i2');
    t.assert(isa(l, 'GAMSTransfer.Alias'));
    t.assertEquals(l.name, 'i2');

    t.add('get_list_sets');
    l = gdx.getSymbols(gdx.listSets());
    t.assert(iscell(l));
    t.assert(numel(l) == 2);
    t.assert(isa(l{1}, 'GAMSTransfer.Set'));
    t.assert(isa(l{2}, 'GAMSTransfer.Set'));
    t.assertEquals(l{1}.name, 'i');
    t.assertEquals(l{2}.name, 'j');

    t.add('get_list_variables');
    l = gdx.getSymbols(gdx.listVariables());
    t.assert(iscell(l));
    t.assert(numel(l) == 10);
    t.assert(isa(l{1}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{2}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{3}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{4}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{5}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{6}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{7}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{8}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{9}, 'GAMSTransfer.Variable'));
    t.assert(isa(l{10}, 'GAMSTransfer.Variable'));
    t.assertEquals(l{1}.name, 'x1');
    t.assertEquals(l{2}.name, 'x2');
    t.assertEquals(l{3}.name, 'x3');
    t.assertEquals(l{4}.name, 'x4');
    t.assertEquals(l{5}.name, 'x5');
    t.assertEquals(l{6}.name, 'x6');
    t.assertEquals(l{7}.name, 'x7');
    t.assertEquals(l{8}.name, 'x8');
    t.assertEquals(l{9}.name, 'x9');
    t.assertEquals(l{10}.name, 'x10');

    t.add('get_list_equations');
    l = gdx.getSymbols(gdx.listEquations());
    t.assert(iscell(l));
    t.assert(numel(l) == 3);
    t.assert(isa(l{1}, 'GAMSTransfer.Equation'));
    t.assert(isa(l{2}, 'GAMSTransfer.Equation'));
    t.assert(isa(l{3}, 'GAMSTransfer.Equation'));
    t.assertEquals(l{1}.name, 'e1');
    t.assertEquals(l{2}.name, 'e2');
    t.assertEquals(l{3}.name, 'e3');

    t.add('get_list_parameters');
    l = gdx.getSymbols(gdx.listParameters());
    t.assert(iscell(l));
    t.assert(numel(l) == 1);
    t.assert(isa(l{1}, 'GAMSTransfer.Parameter'));
    t.assertEquals(l{1}.name, 'a');

    t.add('get_list_aliases');
    l = gdx.getSymbols(gdx.listAliases());
    t.assert(iscell(l));
    t.assert(numel(l) == 2);
    t.assert(isa(l{1}, 'GAMSTransfer.Alias'));
    t.assert(isa(l{2}, 'GAMSTransfer.Alias'));
    t.assertEquals(l{1}.name, 'i2');
    t.assertEquals(l{2}.name, 'j2');

end

function test_describe(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{1});

    tbl = gdx.describeSets();

    t.add('describe_sets_basic');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 8);
        t.assert(height(tbl) == 2);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'singleton');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'count');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'sparsity');
        t.assertEquals(tbl{1,'name'}, 'i');
        t.assertEquals(tbl{1,'format'}, 'not_read');
        t.assert(~tbl{1,'singleton'});
        t.assert(tbl{1,'dim'} == 1);
        t.assertEquals(tbl{1,'domain'}, '[*]');
        t.assertEquals(tbl{1,'size'}, '[NaN]');
        t.assert(tbl{1,'count'} == 5);
        t.assert(isnan(tbl{1,'sparsity'}));
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 8);
        t.assert(numel(tbl.name) == 2);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'singleton'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'count'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assertEquals(tbl.name{1}, 'i');
        t.assertEquals(tbl.format{1}, 'not_read');
        t.assert(~tbl.singleton(1));
        t.assert(tbl.dim(1) == 1);
        t.assertEquals(tbl.domain{1}, '[*]');
        t.assertEquals(tbl.size{1}, '[NaN]');
        t.assert(tbl.count(1) == 5);
        t.assert(isnan(tbl.sparsity(1)));
    end

    tbl = gdx.describeParameters();

    t.add('describe_parameters_basic');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 16);
        t.assert(height(tbl) == 2);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'count');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'sparsity');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'min_value');
        t.assertEquals(tbl.Properties.VariableNames{9}, 'mean_value');
        t.assertEquals(tbl.Properties.VariableNames{10}, 'max_value');
        t.assertEquals(tbl.Properties.VariableNames{11}, 'where_max_abs_value');
        t.assertEquals(tbl.Properties.VariableNames{12}, 'num_na');
        t.assertEquals(tbl.Properties.VariableNames{13}, 'num_undef');
        t.assertEquals(tbl.Properties.VariableNames{14}, 'num_eps');
        t.assertEquals(tbl.Properties.VariableNames{15}, 'num_minf');
        t.assertEquals(tbl.Properties.VariableNames{16}, 'num_pinf');
        t.assertEquals(tbl{1,'name'}, 'a');
        t.assertEquals(tbl{1,'format'}, 'not_read');
        t.assert(tbl{1,'dim'} == 0);
        t.assertEquals(tbl{1,'domain'}, '[]');
        t.assertEquals(tbl{1,'size'}, '[]');
        t.assert(tbl{1,'count'} == 1);
        t.assert(tbl{1,'sparsity'} == 0);
        t.assert(isnan(tbl{1,'min_value'}));
        t.assert(isnan(tbl{1,'mean_value'}));
        t.assert(isnan(tbl{1,'max_value'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{1,'where_max_abs_value'}));
        else
            t.assert(isempty(tbl{1,'where_max_abs_value'}));
        end
        t.assert(tbl{1,'num_na'} == 0);
        t.assert(tbl{1,'num_undef'} == 0);
        t.assert(tbl{1,'num_eps'} == 0);
        t.assert(tbl{1,'num_minf'} == 0);
        t.assert(tbl{1,'num_pinf'} == 0);
        t.assertEquals(tbl{2,'name'}, 'b');
        t.assertEquals(tbl{2,'format'}, 'not_read');
        t.assert(tbl{2,'dim'} == 1);
        t.assertEquals(tbl{2,'domain'}, '[i]');
        t.assertEquals(tbl{2,'size'}, '[5]');
        t.assert(tbl{2,'count'} == 3);
        t.assert(tbl{2,'sparsity'} == 0.4);
        t.assert(isnan(tbl{2,'min_value'}));
        t.assert(isnan(tbl{2,'mean_value'}));
        t.assert(isnan(tbl{2,'max_value'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{2,'where_max_abs_value'}));
        else
            t.assert(isempty(tbl{2,'where_max_abs_value'}));
        end
        t.assert(tbl{2,'num_na'} == 0);
        t.assert(tbl{2,'num_undef'} == 0);
        t.assert(tbl{2,'num_eps'} == 0);
        t.assert(tbl{2,'num_minf'} == 0);
        t.assert(tbl{2,'num_pinf'} == 0);
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 16);
        t.assert(numel(tbl.name) == 2);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'count'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assert(isfield(tbl, 'min_value'));
        t.assert(isfield(tbl, 'mean_value'));
        t.assert(isfield(tbl, 'max_value'));
        t.assert(isfield(tbl, 'where_max_abs_value'));
        t.assert(isfield(tbl, 'num_na'));
        t.assert(isfield(tbl, 'num_undef'));
        t.assert(isfield(tbl, 'num_eps'));
        t.assert(isfield(tbl, 'num_minf'));
        t.assert(isfield(tbl, 'num_pinf'));
        t.assertEquals(tbl.name{1}, 'a');
        t.assertEquals(tbl.format{1}, 'not_read');
        t.assert(tbl.dim(1) == 0);
        t.assertEquals(tbl.domain{1}, '[]');
        t.assertEquals(tbl.size{1}, '[]');
        t.assert(tbl.count(1) == 1);
        t.assert(tbl.sparsity(1) == 0);
        t.assert(isnan(tbl.min_value(1)));
        t.assert(isnan(tbl.mean_value(1)));
        t.assert(isnan(tbl.max_value(1)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_value{1}));
        else
            t.assert(isempty(tbl.where_max_abs_value{1}));
        end
        t.assert(tbl.num_na(1) == 0);
        t.assert(tbl.num_undef(1) == 0);
        t.assert(tbl.num_eps(1) == 0);
        t.assert(tbl.num_minf(1) == 0);
        t.assert(tbl.num_pinf(1) == 0);
        t.assertEquals(tbl.name{2}, 'b');
        t.assertEquals(tbl.format{2}, 'not_read');
        t.assert(tbl.dim(2) == 1);
        t.assertEquals(tbl.domain{2}, '[i]');
        t.assertEquals(tbl.size{2}, '[5]');
        t.assert(tbl.count(2) == 3);
        t.assert(tbl.sparsity(2) == 0.4);
        t.assert(isnan(tbl.min_value(2)));
        t.assert(isnan(tbl.mean_value(2)));
        t.assert(isnan(tbl.max_value(2)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_value{2}));
        else
            t.assert(isempty(tbl.where_max_abs_value{2}));
        end
        t.assert(tbl.num_na(2) == 0);
        t.assert(tbl.num_undef(2) == 0);
        t.assert(tbl.num_eps(2) == 0);
        t.assert(tbl.num_minf(2) == 0);
        t.assert(tbl.num_pinf(2) == 0);
    end

    tbl = gdx.describeVariables();

    t.add('describe_variables_basic');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 21);
        t.assert(height(tbl) == 1);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'type');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'count');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'sparsity');
        t.assertEquals(tbl.Properties.VariableNames{9}, 'min_level');
        t.assertEquals(tbl.Properties.VariableNames{10}, 'mean_level');
        t.assertEquals(tbl.Properties.VariableNames{11}, 'max_level');
        t.assertEquals(tbl.Properties.VariableNames{12}, 'where_max_abs_level');
        t.assertEquals(tbl.Properties.VariableNames{13}, 'min_marginal');
        t.assertEquals(tbl.Properties.VariableNames{14}, 'mean_marginal');
        t.assertEquals(tbl.Properties.VariableNames{15}, 'max_marginal');
        t.assertEquals(tbl.Properties.VariableNames{16}, 'where_max_abs_marginal');
        t.assertEquals(tbl.Properties.VariableNames{17}, 'num_na');
        t.assertEquals(tbl.Properties.VariableNames{18}, 'num_undef');
        t.assertEquals(tbl.Properties.VariableNames{19}, 'num_eps');
        t.assertEquals(tbl.Properties.VariableNames{20}, 'num_minf');
        t.assertEquals(tbl.Properties.VariableNames{21}, 'num_pinf');
        t.assertEquals(tbl{1,'name'}, 'x');
        t.assertEquals(tbl{1,'type'}, 'positive');
        t.assertEquals(tbl{1,'format'}, 'not_read');
        t.assert(tbl{1,'dim'} == 2);
        t.assertEquals(tbl{1,'domain'}, '[i,j]');
        t.assertEquals(tbl{1,'size'}, '[5,5]');
        t.assert(tbl{1,'count'} == 6);
        t.assert(tbl{1,'sparsity'} == 0.76);
        t.assert(isnan(tbl{1,'min_level'}));
        t.assert(isnan(tbl{1,'mean_level'}));
        t.assert(isnan(tbl{1,'max_level'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{1,'where_max_abs_level'}));
        else
            t.assert(isempty(tbl{1,'where_max_abs_level'}));
        end
        t.assert(isnan(tbl{1,'min_marginal'}));
        t.assert(isnan(tbl{1,'mean_marginal'}));
        t.assert(isnan(tbl{1,'max_marginal'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{1,'where_max_abs_marginal'}));
        else
            t.assert(isempty(tbl{1,'where_max_abs_marginal'}));
        end
        t.assert(tbl.num_na(1) == 0);
        t.assert(tbl.num_undef(1) == 0);
        t.assert(tbl.num_eps(1) == 0);
        t.assert(tbl.num_minf(1) == 0);
        t.assert(tbl.num_pinf(1) == 0);
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 21);
        t.assert(numel(tbl.name) == 1);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'type'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'count'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assert(isfield(tbl, 'min_level'));
        t.assert(isfield(tbl, 'mean_level'));
        t.assert(isfield(tbl, 'max_level'));
        t.assert(isfield(tbl, 'where_max_abs_level'));
        t.assert(isfield(tbl, 'min_marginal'));
        t.assert(isfield(tbl, 'mean_marginal'));
        t.assert(isfield(tbl, 'max_marginal'));
        t.assert(isfield(tbl, 'where_max_abs_marginal'));
        t.assert(isfield(tbl, 'num_na'));
        t.assert(isfield(tbl, 'num_undef'));
        t.assert(isfield(tbl, 'num_eps'));
        t.assert(isfield(tbl, 'num_minf'));
        t.assert(isfield(tbl, 'num_pinf'));
        t.assertEquals(tbl.name{1}, 'x');
        t.assertEquals(tbl.type{1}, 'positive');
        t.assertEquals(tbl.format{1}, 'not_read');
        t.assert(tbl.dim(1) == 2);
        t.assertEquals(tbl.domain{1}, '[i,j]');
        t.assertEquals(tbl.size{1}, '[5,5]');
        t.assert(tbl.count(1) == 6);
        t.assert(tbl.sparsity(1) == 0.76);
        t.assert(isnan(tbl.min_level(1)));
        t.assert(isnan(tbl.mean_level(1)));
        t.assert(isnan(tbl.max_level(1)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_level{1}));
        else
            t.assert(isempty(tbl.where_max_abs_level{1}));
        end
        t.assert(isnan(tbl.min_marginal(1)));
        t.assert(isnan(tbl.mean_marginal(1)));
        t.assert(isnan(tbl.max_marginal(1)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_marginal{1}));
        else
            t.assert(isempty(tbl.where_max_abs_marginal{1}));
        end
        t.assert(tbl.num_na(1) == 0);
        t.assert(tbl.num_undef(1) == 0);
        t.assert(tbl.num_eps(1) == 0);
        t.assert(tbl.num_minf(1) == 0);
        t.assert(tbl.num_pinf(1) == 0);
    end

    tbl = gdx.describeEquations();

    t.add('describe_equations_basic');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 21);
        t.assert(height(tbl) == 0);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'type');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'count');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'sparsity');
        t.assertEquals(tbl.Properties.VariableNames{9}, 'min_level');
        t.assertEquals(tbl.Properties.VariableNames{10}, 'mean_level');
        t.assertEquals(tbl.Properties.VariableNames{11}, 'max_level');
        t.assertEquals(tbl.Properties.VariableNames{12}, 'where_max_abs_level');
        t.assertEquals(tbl.Properties.VariableNames{13}, 'min_marginal');
        t.assertEquals(tbl.Properties.VariableNames{14}, 'mean_marginal');
        t.assertEquals(tbl.Properties.VariableNames{15}, 'max_marginal');
        t.assertEquals(tbl.Properties.VariableNames{16}, 'where_max_abs_marginal');
        t.assertEquals(tbl.Properties.VariableNames{17}, 'num_na');
        t.assertEquals(tbl.Properties.VariableNames{18}, 'num_undef');
        t.assertEquals(tbl.Properties.VariableNames{19}, 'num_eps');
        t.assertEquals(tbl.Properties.VariableNames{20}, 'num_minf');
        t.assertEquals(tbl.Properties.VariableNames{21}, 'num_pinf');
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 21);
        t.assert(numel(tbl.name) == 0);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'type'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'count'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assert(isfield(tbl, 'min_level'));
        t.assert(isfield(tbl, 'mean_level'));
        t.assert(isfield(tbl, 'max_level'));
        t.assert(isfield(tbl, 'where_max_abs_level'));
        t.assert(isfield(tbl, 'min_marginal'));
        t.assert(isfield(tbl, 'mean_marginal'));
        t.assert(isfield(tbl, 'max_marginal'));
        t.assert(isfield(tbl, 'where_max_abs_marginal'));
        t.assert(isfield(tbl, 'num_na'));
        t.assert(isfield(tbl, 'num_undef'));
        t.assert(isfield(tbl, 'num_eps'));
        t.assert(isfield(tbl, 'num_minf'));
        t.assert(isfield(tbl, 'num_pinf'));
    end

    for i = 1:4
        if ~gdx.features.table && i == 2
            continue
        end

        switch i
        case 1
            gdx.read('format', 'struct');
            test_name_describe_sets = 'describe_sets_struct';
            test_name_describe_parameters = 'describe_parameters_struct';
            test_name_describe_variables = 'describe_variables_struct';
        case 2
            gdx.read('format', 'table');
            test_name_describe_sets = 'describe_sets_table';
            test_name_describe_parameters = 'describe_parameters_table';
            test_name_describe_variables = 'describe_variables_table';
        case 3
            gdx.read('format', 'dense_matrix');
            test_name_describe_sets = 'describe_sets_dense_matrix';
            test_name_describe_parameters = 'describe_parameters_dense_matrix';
            test_name_describe_variables = 'describe_variables_dense_matrix';
        case 4
            gdx.read('format', 'sparse_matrix');
            test_name_describe_sets = 'describe_sets_sparse_matrix';
            test_name_describe_parameters = 'describe_parameters_sparse_matrix';
            test_name_describe_variables = 'describe_variables_sparse_matrix';
        end

        tbl = gdx.describeSets();

        t.add(test_name_describe_sets);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 8);
            t.assert(height(tbl) == 2);
            t.assertEquals(tbl{1,'name'}, 'i');
            t.assert(~tbl{1,'singleton'});
            switch i
            case {1,3,4}
                t.assertEquals(tbl{1,'format'}, 'struct');
            case 2
                t.assertEquals(tbl{1,'format'}, 'table');
            end
            t.assert(tbl{1,'dim'} == 1);
            t.assertEquals(tbl{1,'domain'}, '[*]');
            t.assertEquals(tbl{1,'size'}, '[NaN]');
            t.assert(tbl{1,'count'} == 5);
            t.assert(isnan(tbl{1,'sparsity'}));
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 8);
            t.assert(numel(tbl.name) == 2);
            t.assertEquals(tbl.name{1}, 'i');
            t.assert(~tbl.singleton(1));
            switch i
            case {1,3,4}
                t.assertEquals(tbl.format{1}, 'struct');
            case 2
                t.assertEquals(tbl.format{1}, 'table');
            end
            t.assert(tbl.dim(1) == 1);
            t.assertEquals(tbl.domain{1}, '[*]');
            t.assertEquals(tbl.size{1}, '[NaN]');
            t.assert(tbl.count(1) == 5);
            t.assert(isnan(tbl.sparsity(1)));
        end

        tbl = gdx.describeParameters();

        t.add(test_name_describe_parameters);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 16);
            t.assert(height(tbl) == 2);
            t.assertEquals(tbl{1,'name'}, 'a');
            switch i
            case {1,3}
                t.assert(isequal(tbl{1,'format'}, 'struct') || isequal(tbl{1,'format'}, 'dense_matrix'));
            case 2
                t.assertEquals(tbl{1,'format'}, 'table');
            case 4
                t.assertEquals(tbl{1,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{1,'dim'} == 0);
            t.assertEquals(tbl{1,'domain'}, '[]');
            t.assertEquals(tbl{1,'size'}, '[]');
            t.assert(tbl{1,'count'} == 1);
            t.assert(tbl{1,'sparsity'} == 0);
            t.assert(tbl{1,'min_value'} == 4);
            t.assert(tbl{1,'mean_value'} == 4);
            t.assert(tbl{1,'max_value'} == 4);
            t.assertEquals(tbl{1,'where_max_abs_value'}, '[]');
            t.assert(tbl{1,'num_na'} == 0);
            t.assert(tbl{1,'num_undef'} == 0);
            t.assert(tbl{1,'num_eps'} == 0);
            t.assert(tbl{1,'num_minf'} == 0);
            t.assert(tbl{1,'num_pinf'} == 0);
            t.assertEquals(tbl{2,'name'}, 'b');
            switch i
            case 1
                t.assertEquals(tbl{2,'format'}, 'struct');
            case 2
                t.assertEquals(tbl{2,'format'}, 'table');
            case 3
                t.assertEquals(tbl{2,'format'}, 'dense_matrix');
            case 4
                t.assertEquals(tbl{2,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{2,'dim'} == 1);
            t.assertEquals(tbl{2,'domain'}, '[i]');
            t.assertEquals(tbl{2,'size'}, '[5]');
            switch i
            case {1,2,4}
                t.assert(tbl{2,'count'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
            case 3
                t.assert(tbl{2,'count'} == 5);
                t.assert(tbl{2,'sparsity'} == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl{2,'min_value'} == 1);
                t.assert(tbl{2,'mean_value'} == 14/3);
            case {3,4}
                t.assert(tbl{2,'min_value'} == 0);
                t.assert(tbl{2,'mean_value'} == 14/5);
            end
            t.assert(tbl{2,'max_value'} == 10);
            t.assertEquals(tbl{2,'where_max_abs_value'}, '[i10]');
            t.assert(tbl{2,'num_na'} == 0);
            t.assert(tbl{2,'num_undef'} == 0);
            t.assert(tbl{2,'num_eps'} == 0);
            t.assert(tbl{2,'num_minf'} == 0);
            t.assert(tbl{2,'num_pinf'} == 0);
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 16);
            t.assert(numel(tbl.name) == 2);
            t.assertEquals(tbl.name{1}, 'a');
            switch i
            case {1,3}
                t.assert(isequal(tbl.format{1}, 'struct') || isequal(tbl.format{1}, 'dense_matrix'));
            case 2
                t.assertEquals(tbl.format{1}, 'table');
            case 4
                t.assertEquals(tbl.format{1}, 'sparse_matrix');
            end
            t.assert(tbl.dim(1) == 0);
            t.assertEquals(tbl.domain{1}, '[]');
            t.assertEquals(tbl.size{1}, '[]');
            t.assert(tbl.count(1) == 1);
            t.assert(tbl.sparsity(1) == 0);
            t.assert(tbl.min_value(1) == 4);
            t.assert(tbl.mean_value(1) == 4);
            t.assert(tbl.max_value(1) == 4);
            t.assertEquals(tbl.where_max_abs_value{1}, '[]');
            t.assert(tbl.num_na(1) == 0);
            t.assert(tbl.num_undef(1) == 0);
            t.assert(tbl.num_eps(1) == 0);
            t.assert(tbl.num_minf(1) == 0);
            t.assert(tbl.num_pinf(1) == 0);
            t.assertEquals(tbl.name{2}, 'b');
            switch i
            case 1
                t.assertEquals(tbl.format{2}, 'struct');
            case 2
                t.assertEquals(tbl.format{2}, 'table');
            case 3
                t.assertEquals(tbl.format{2}, 'dense_matrix');
            case 4
                t.assertEquals(tbl.format{2}, 'sparse_matrix');
            end
            t.assert(tbl.dim(2) == 1);
            t.assertEquals(tbl.domain{2}, '[i]');
            t.assertEquals(tbl.size{2}, '[5]');
            switch i
            case {1,2,4}
                t.assert(tbl.count(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
            case 3
                t.assert(tbl.count(2) == 5);
                t.assert(tbl.sparsity(2) == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl.min_value(2) == 1);
                t.assert(tbl.mean_value(2) == 14/3);
            case {3,4}
                t.assert(tbl.min_value(2) == 0);
                t.assert(tbl.mean_value(2) == 14/5);
            end
            t.assert(tbl.max_value(2) == 10);
            t.assertEquals(tbl.where_max_abs_value{2}, '[i10]');
            t.assert(tbl.num_na(2) == 0);
            t.assert(tbl.num_undef(2) == 0);
            t.assert(tbl.num_eps(2) == 0);
            t.assert(tbl.num_minf(2) == 0);
            t.assert(tbl.num_pinf(2) == 0);
        end

        tbl = gdx.describeVariables();

        t.add(test_name_describe_variables);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 21);
            t.assert(height(tbl) == 1);
            t.assertEquals(tbl{1,'name'}, 'x');
            t.assertEquals(tbl{1,'type'}, 'positive');
            switch i
            case 1
                t.assertEquals(tbl{1,'format'}, 'struct');
            case 2
                t.assertEquals(tbl{1,'format'}, 'table');
            case 3
                t.assertEquals(tbl{1,'format'}, 'dense_matrix');
            case 4
                t.assertEquals(tbl{1,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{1,'dim'} == 2);
            t.assertEquals(tbl{1,'domain'}, '[i,j]');
            t.assertEquals(tbl{1,'size'}, '[5,5]');
            switch i
            case {1,2}
                t.assert(tbl{1,'count'} == 6);
                t.assert(tbl{1,'sparsity'} == 0.76);
            case 3
                t.assert(tbl{1,'count'} == 25);
                t.assert(tbl{1,'sparsity'} == 0);
            case 4
                t.assert(tbl{1,'count'} == 3);
                t.assert(tbl{1,'sparsity'} == 0.88);
            end
            t.assert(tbl{1,'min_level'} == 0);
            switch i
            case {1,2}
                t.assert(tbl{1,'mean_level'} == 18/6);
            case {3,4}
                t.assert(tbl{1,'mean_level'} == 18/25);
            end
            t.assert(tbl{1,'max_level'} == 9);
            t.assertEquals(tbl{1,'where_max_abs_level'}, '[i3,j9]');
            t.assert(tbl{1,'min_marginal'} == 0);
            switch i
            case {1,2}
                t.assert(tbl{1,'mean_marginal'} == 13/6);
            case {3,4}
                t.assert(tbl{1,'mean_marginal'} == 13/25);
            end
            t.assert(tbl{1,'max_marginal'} == 8);
            t.assertEquals(tbl{1,'where_max_abs_marginal'}, '[i3,j8]');
            t.assert(tbl{1,'num_na'} == 0);
            t.assert(tbl{1,'num_undef'} == 0);
            t.assert(tbl{1,'num_eps'} == 0);
            t.assert(tbl{1,'num_minf'} == 0);
            switch i
            case {1,2}
                t.assert(tbl{1,'num_pinf'} == 5);
            case {3,4}
                t.assert(tbl{1,'num_pinf'} == 24);
            end
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 21);
            t.assert(numel(tbl.name) == 1);
            t.assertEquals(tbl.name{1}, 'x');
            t.assertEquals(tbl.type{1}, 'positive');
            switch i
            case 1
                t.assertEquals(tbl.format{1}, 'struct');
            case 2
                t.assertEquals(tbl.format{1}, 'table');
            case 3
                t.assertEquals(tbl.format{1}, 'dense_matrix');
            case 4
                t.assertEquals(tbl.format{1}, 'sparse_matrix');
            end
            t.assert(tbl.dim(1) == 2);
            t.assertEquals(tbl.domain{1}, '[i,j]');
            t.assertEquals(tbl.size{1}, '[5,5]');
            switch i
            case {1,2}
                t.assert(tbl.count(1) == 6);
                t.assert(tbl.sparsity(1) == 0.76);
            case 3
                t.assert(tbl.count(1) == 25);
                t.assert(tbl.sparsity(1) == 0);
            case 4
                t.assert(tbl.count(1) == 3);
                t.assert(tbl.sparsity(1) == 0.88);
            end
            t.assert(tbl.min_level(1) == 0);
            switch i
            case {1,2}
                t.assert(tbl.mean_level(1) == 18/6);
            case {3,4}
                t.assert(tbl.mean_level(1) == 18/25);
            end
            t.assert(tbl.max_level(1) == 9);
            t.assertEquals(tbl.where_max_abs_level{1}, '[i3,j9]');
            t.assert(tbl.min_marginal(1) == 0);
            switch i
            case {1,2}
                t.assert(tbl.mean_marginal(1) == 13/6);
            case {3,4}
                t.assert(tbl.mean_marginal(1) == 13/25);
            end
            t.assert(tbl.max_marginal(1) == 8);
            t.assertEquals(tbl.where_max_abs_marginal{1}, '[i3,j8]');
            t.assert(tbl.num_na(1) == 0);
            t.assert(tbl.num_undef(1) == 0);
            t.assert(tbl.num_eps(1) == 0);
            t.assert(tbl.num_minf(1) == 0);
            switch i
            case {1,2}
                t.assert(tbl.num_pinf(1) == 5);
            case {3,4}
                t.assert(tbl.num_pinf(1) == 24);
            end
        end
    end
end

function test_idx_describe(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{4}, 'indexed', true);

    tbl = gdx.describeParameters();

    t.add('idx_describe_parameters_basic');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 16);
        t.assert(height(tbl) == 3);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'count');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'sparsity');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'min_value');
        t.assertEquals(tbl.Properties.VariableNames{9}, 'mean_value');
        t.assertEquals(tbl.Properties.VariableNames{10}, 'max_value');
        t.assertEquals(tbl.Properties.VariableNames{11}, 'where_max_abs_value');
        t.assertEquals(tbl.Properties.VariableNames{12}, 'num_na');
        t.assertEquals(tbl.Properties.VariableNames{13}, 'num_undef');
        t.assertEquals(tbl.Properties.VariableNames{14}, 'num_eps');
        t.assertEquals(tbl.Properties.VariableNames{15}, 'num_minf');
        t.assertEquals(tbl.Properties.VariableNames{16}, 'num_pinf');
        t.assertEquals(tbl{1,'name'}, 'a');
        t.assertEquals(tbl{1,'format'}, 'not_read');
        t.assert(tbl{1,'dim'} == 0);
        t.assertEquals(tbl{1,'domain'}, '[]');
        t.assertEquals(tbl{1,'size'}, '[]');
        t.assert(tbl{1,'count'} == 1);
        t.assert(tbl{1,'sparsity'} == 0);
        t.assert(isnan(tbl{1,'min_value'}));
        t.assert(isnan(tbl{1,'mean_value'}));
        t.assert(isnan(tbl{1,'max_value'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{1,'where_max_abs_value'}));
        else
            t.assert(isempty(tbl{1,'where_max_abs_value'}));
        end
        t.assert(tbl{1,'num_na'} == 0);
        t.assert(tbl{1,'num_undef'} == 0);
        t.assert(tbl{1,'num_eps'} == 0);
        t.assert(tbl{1,'num_minf'} == 0);
        t.assert(tbl{1,'num_pinf'} == 0);
        t.assertEquals(tbl{2,'name'}, 'b');
        t.assertEquals(tbl{2,'format'}, 'not_read');
        t.assert(tbl{2,'dim'} == 1);
        t.assertEquals(tbl{2,'domain'}, '[dim_1]');
        t.assertEquals(tbl{2,'size'}, '[5]');
        t.assert(tbl{2,'count'} == 3);
        t.assert(tbl{2,'sparsity'} == 0.4);
        t.assert(isnan(tbl{2,'min_value'}));
        t.assert(isnan(tbl{2,'mean_value'}));
        t.assert(isnan(tbl{2,'max_value'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{2,'where_max_abs_value'}));
        else
            t.assert(isempty(tbl{2,'where_max_abs_value'}));
        end
        t.assert(tbl{2,'num_na'} == 0);
        t.assert(tbl{2,'num_undef'} == 0);
        t.assert(tbl{2,'num_eps'} == 0);
        t.assert(tbl{2,'num_minf'} == 0);
        t.assert(tbl{2,'num_pinf'} == 0);
        t.assertEquals(tbl{3,'name'}, 'c');
        t.assertEquals(tbl{3,'format'}, 'not_read');
        t.assert(tbl{3,'dim'} == 2);
        t.assertEquals(tbl{3,'domain'}, '[dim_1,dim_2]');
        t.assertEquals(tbl{3,'size'}, '[5,10]');
        t.assert(tbl{3,'count'} == 3);
        t.assert(tbl{3,'sparsity'} == 0.94);
        t.assert(isnan(tbl{3,'min_value'}));
        t.assert(isnan(tbl{3,'mean_value'}));
        t.assert(isnan(tbl{3,'max_value'}));
        if gdx.features.categorical
            t.assert(isundefined(tbl{3,'where_max_abs_value'}));
        else
            t.assert(isempty(tbl{3,'where_max_abs_value'}));
        end
        t.assert(tbl{3,'num_na'} == 0);
        t.assert(tbl{3,'num_undef'} == 0);
        t.assert(tbl{3,'num_eps'} == 0);
        t.assert(tbl{3,'num_minf'} == 0);
        t.assert(tbl{3,'num_pinf'} == 0);
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 16);
        t.assert(numel(tbl.name) == 3);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'count'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assert(isfield(tbl, 'min_value'));
        t.assert(isfield(tbl, 'mean_value'));
        t.assert(isfield(tbl, 'max_value'));
        t.assert(isfield(tbl, 'where_max_abs_value'));
        t.assert(isfield(tbl, 'num_na'));
        t.assert(isfield(tbl, 'num_undef'));
        t.assert(isfield(tbl, 'num_eps'));
        t.assert(isfield(tbl, 'num_minf'));
        t.assert(isfield(tbl, 'num_pinf'));
        t.assertEquals(tbl.name{1}, 'a');
        t.assertEquals(tbl.format{1}, 'not_read');
        t.assert(tbl.dim(1) == 0);
        t.assertEquals(tbl.domain{1}, '[]');
        t.assertEquals(tbl.size{1}, '[]');
        t.assert(tbl.count(1) == 1);
        t.assert(tbl.sparsity(1) == 0);
        t.assert(isnan(tbl.min_value(1)));
        t.assert(isnan(tbl.mean_value(1)));
        t.assert(isnan(tbl.max_value(1)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_value{1}));
        else
            t.assert(isempty(tbl.where_max_abs_value{1}));
        end
        t.assert(tbl.num_na(1) == 0);
        t.assert(tbl.num_undef(1) == 0);
        t.assert(tbl.num_eps(1) == 0);
        t.assert(tbl.num_minf(1) == 0);
        t.assert(tbl.num_pinf(1) == 0);
        t.assertEquals(tbl.name{2}, 'b');
        t.assertEquals(tbl.format{2}, 'not_read');
        t.assert(tbl.dim(2) == 1);
        t.assertEquals(tbl.domain{2}, '[dim_1]');
        t.assertEquals(tbl.size{2}, '[5]');
        t.assert(tbl.count(2) == 3);
        t.assert(tbl.sparsity(2) == 0.4);
        t.assert(isnan(tbl.min_value(2)));
        t.assert(isnan(tbl.mean_value(2)));
        t.assert(isnan(tbl.max_value(2)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_value{2}));
        else
            t.assert(isempty(tbl.where_max_abs_value{2}));
        end
        t.assert(tbl.num_na(2) == 0);
        t.assert(tbl.num_undef(2) == 0);
        t.assert(tbl.num_eps(2) == 0);
        t.assert(tbl.num_minf(2) == 0);
        t.assert(tbl.num_pinf(2) == 0);
        t.assertEquals(tbl.name{3}, 'c');
        t.assertEquals(tbl.format{3}, 'not_read');
        t.assert(tbl.dim(3) == 2);
        t.assertEquals(tbl.domain{3}, '[dim_1,dim_2]');
        t.assertEquals(tbl.size{3}, '[5,10]');
        t.assert(tbl.count(3) == 3);
        t.assert(tbl.sparsity(3) == 0.94);
        t.assert(isnan(tbl.min_value(3)));
        t.assert(isnan(tbl.mean_value(3)));
        t.assert(isnan(tbl.max_value(3)));
        if gdx.features.categorical
            t.assert(isundefined(tbl.where_max_abs_value{3}));
        else
            t.assert(isempty(tbl.where_max_abs_value{3}));
        end
        t.assert(tbl.num_na(3) == 0);
        t.assert(tbl.num_undef(3) == 0);
        t.assert(tbl.num_eps(3) == 0);
        t.assert(tbl.num_minf(3) == 0);
        t.assert(tbl.num_pinf(3) == 0);
    end

    for i = 1:4
        if ~gdx.features.table && i == 2
            continue
        end

        switch i
        case 1
            gdx.read('format', 'struct');
            test_name_describe_parameters = 'idx_describe_parameters_struct';
        case 2
            gdx.read('format', 'table');
            test_name_describe_parameters = 'idx_describe_parameters_table';
        case 3
            gdx.read('format', 'dense_matrix');
            test_name_describe_parameters = 'idx_describe_parameters_dense_matrix';
        case 4
            gdx.read('format', 'sparse_matrix');
            test_name_describe_parameters = 'idx_describe_parameters_sparse_matrix';
        end

        tbl = gdx.describeParameters();

        t.add(test_name_describe_parameters);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 16);
            t.assert(height(tbl) == 3);
            t.assertEquals(tbl{1,'name'}, 'a');
            switch i
            case {1,3}
                t.assert(isequal(tbl{1,'format'}, 'struct') || isequal(tbl{1,'format'}, 'dense_matrix'));
            case 2
                t.assertEquals(tbl{1,'format'}, 'table');
            case 4
                t.assertEquals(tbl{1,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{1,'dim'} == 0);
            t.assertEquals(tbl{1,'domain'}, '[]');
            t.assertEquals(tbl{1,'size'}, '[]');
            t.assert(tbl{1,'count'} == 1);
            t.assert(tbl{1,'sparsity'} == 0);
            t.assert(tbl{1,'min_value'} == 4);
            t.assert(tbl{1,'mean_value'} == 4);
            t.assert(tbl{1,'max_value'} == 4);
            t.assertEquals(tbl{1,'where_max_abs_value'}, '[]');
            t.assert(tbl{1,'num_na'} == 0);
            t.assert(tbl{1,'num_undef'} == 0);
            t.assert(tbl{1,'num_eps'} == 0);
            t.assert(tbl{1,'num_minf'} == 0);
            t.assert(tbl{1,'num_pinf'} == 0);
            t.assertEquals(tbl{2,'name'}, 'b');
            switch i
            case 1
                t.assertEquals(tbl{2,'format'}, 'struct');
            case 2
                t.assertEquals(tbl{2,'format'}, 'table');
            case 3
                t.assertEquals(tbl{2,'format'}, 'dense_matrix');
            case 4
                t.assertEquals(tbl{2,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{2,'dim'} == 1);
            t.assertEquals(tbl{2,'domain'}, '[dim_1]');
            t.assertEquals(tbl{2,'size'}, '[5]');
            switch i
            case {1,2,4}
                t.assert(tbl{2,'count'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
            case 3
                t.assert(tbl{2,'count'} == 5);
                t.assert(tbl{2,'sparsity'} == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl{2,'min_value'} == 1);
                t.assert(tbl{2,'mean_value'} == 9/3);
            case {3,4}
                t.assert(tbl{2,'min_value'} == 0);
                t.assert(tbl{2,'mean_value'} == 9/5);
            end
            t.assert(tbl{2,'max_value'} == 5);
            t.assertEquals(tbl{2,'where_max_abs_value'}, '[5]');
            t.assert(tbl{2,'num_na'} == 0);
            t.assert(tbl{2,'num_undef'} == 0);
            t.assert(tbl{2,'num_eps'} == 0);
            t.assert(tbl{2,'num_minf'} == 0);
            t.assert(tbl{2,'num_pinf'} == 0);
            t.assertEquals(tbl{3,'name'}, 'c');
            switch i
            case 1
                t.assertEquals(tbl{3,'format'}, 'struct');
            case 2
                t.assertEquals(tbl{3,'format'}, 'table');
            case 3
                t.assertEquals(tbl{3,'format'}, 'dense_matrix');
            case 4
                t.assertEquals(tbl{3,'format'}, 'sparse_matrix');
            end
            t.assert(tbl{3,'dim'} == 2);
            t.assertEquals(tbl{3,'domain'}, '[dim_1,dim_2]');
            t.assertEquals(tbl{3,'size'}, '[5,10]');
            switch i
            case {1,2,4}
                t.assert(tbl{3,'count'} == 3);
                t.assert(tbl{3,'sparsity'} == 0.94);
            case 3
                t.assert(tbl{3,'count'} == 50);
                t.assert(tbl{3,'sparsity'} == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl{3,'min_value'} == 16);
                t.assert(tbl{3,'mean_value'} == 102/3);
            case {3,4}
                t.assert(tbl{3,'min_value'} == 0);
                t.assert(tbl{3,'mean_value'} == 102/50);
            end
            t.assert(tbl{3,'max_value'} == 49);
            t.assertEquals(tbl{3,'where_max_abs_value'}, '[4,9]');
            t.assert(tbl{3,'num_na'} == 0);
            t.assert(tbl{3,'num_undef'} == 0);
            t.assert(tbl{3,'num_eps'} == 0);
            t.assert(tbl{3,'num_minf'} == 0);
            t.assert(tbl{3,'num_pinf'} == 0);
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 16);
            t.assert(numel(tbl.name) == 3);
            t.assertEquals(tbl.name{1}, 'a');
            switch i
            case {1,3}
                t.assert(isequal(tbl.format{1}, 'struct') || isequal(tbl.format{1}, 'dense_matrix'));
            case 2
                t.assertEquals(tbl.format{1}, 'table');
            case 4
                t.assertEquals(tbl.format{1}, 'sparse_matrix');
            end
            t.assert(tbl.dim(1) == 0);
            t.assertEquals(tbl.domain{1}, '[]');
            t.assertEquals(tbl.size{1}, '[]');
            t.assert(tbl.count(1) == 1);
            t.assert(tbl.sparsity(1) == 0);
            t.assert(tbl.min_value(1) == 4);
            t.assert(tbl.mean_value(1) == 4);
            t.assert(tbl.max_value(1) == 4);
            t.assertEquals(tbl.where_max_abs_value{1}, '[]');
            t.assert(tbl.num_na(1) == 0);
            t.assert(tbl.num_undef(1) == 0);
            t.assert(tbl.num_eps(1) == 0);
            t.assert(tbl.num_minf(1) == 0);
            t.assert(tbl.num_pinf(1) == 0);
            t.assertEquals(tbl.name{2}, 'b');
            switch i
            case 1
                t.assertEquals(tbl.format{2}, 'struct');
            case 2
                t.assertEquals(tbl.format{2}, 'table');
            case 3
                t.assertEquals(tbl.format{2}, 'dense_matrix');
            case 4
                t.assertEquals(tbl.format{2}, 'sparse_matrix');
            end
            t.assert(tbl.dim(2) == 1);
            t.assertEquals(tbl.domain{2}, '[dim_1]');
            t.assertEquals(tbl.size{2}, '[5]');
            switch i
            case {1,2,4}
                t.assert(tbl.count(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
            case 3
                t.assert(tbl.count(2) == 5);
                t.assert(tbl.sparsity(2) == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl.min_value(2) == 1);
                t.assert(tbl.mean_value(2) == 9/3);
            case {3,4}
                t.assert(tbl.min_value(2) == 0);
                t.assert(tbl.mean_value(2) == 9/5);
            end
            t.assert(tbl.max_value(2) == 5);
            t.assertEquals(tbl.where_max_abs_value{2}, '[5]');
            t.assert(tbl.num_na(2) == 0);
            t.assert(tbl.num_undef(2) == 0);
            t.assert(tbl.num_eps(2) == 0);
            t.assert(tbl.num_minf(2) == 0);
            t.assert(tbl.num_pinf(2) == 0);
            t.assertEquals(tbl.name{3}, 'c');
            switch i
            case 1
                t.assertEquals(tbl.format{3}, 'struct');
            case 2
                t.assertEquals(tbl.format{3}, 'table');
            case 3
                t.assertEquals(tbl.format{3}, 'dense_matrix');
            case 4
                t.assertEquals(tbl.format{3}, 'sparse_matrix');
            end
            t.assert(tbl.dim(3) == 2);
            t.assertEquals(tbl.domain{3}, '[dim_1,dim_2]');
            t.assertEquals(tbl.size{3}, '[5,10]');
            switch i
            case {1,2,4}
                t.assert(tbl.count(3) == 3);
                t.assert(tbl.sparsity(3) == 0.94);
            case 3
                t.assert(tbl.count(3) == 50);
                t.assert(tbl.sparsity(3) == 0);
            end
            switch i
            case {1,2}
                t.assert(tbl.min_value(3) == 16);
                t.assert(tbl.mean_value(3) == 102/3);
            case {3,4}
                t.assert(tbl.min_value(3) == 0);
                t.assert(tbl.mean_value(3) == 102/50);
            end
            t.assert(tbl.max_value(3) == 49);
            t.assertEquals(tbl.where_max_abs_value{3}, '[4,9]');
            t.assert(tbl.num_na(3) == 0);
            t.assert(tbl.num_undef(3) == 0);
            t.assert(tbl.num_eps(3) == 0);
            t.assert(tbl.num_minf(3) == 0);
            t.assert(tbl.num_pinf(3) == 0);
        end
    end
end

function test_remove(t, cfg)

    gdx = GAMSTransfer.Container();
    i1 = GAMSTransfer.Set(gdx, 'i1');
    a1 = GAMSTransfer.Alias(gdx, 'a1', i1);
    x1 = GAMSTransfer.Variable(gdx, 'x1', 'free', {i1});

    t.add('remove_1');
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i1'));
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(i1.is_valid);
    t.assert(a1.is_valid);
    t.assert(x1.is_valid);
    gdx.removeSymbol('i1');
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(~i1.is_valid);
    t.assert(~a1.is_valid);
    t.assert(~x1.is_valid);

end
