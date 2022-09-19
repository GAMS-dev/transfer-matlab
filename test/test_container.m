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

function success = test_container(cfg)
    t = GAMSTest('container_c');
    test_equals(t, cfg, 'c');
    test_getlist(t, cfg, 'c');
    test_describe(t, cfg, 'c');
    test_describePartial(t, cfg, 'c');
    test_idx_describe(t, cfg, 'c');
    test_const2standard(t, cfg);
    test_remove(t, cfg);
    [~, n_fails1] = t.summary();

    t = GAMSTest('container_cc');
    test_equals(t, cfg, 'cc');
    test_getlist(t, cfg, 'cc');
    test_describe(t, cfg, 'cc');
    test_describePartial(t, cfg, 'cc');
    test_idx_describe(t, cfg, 'cc');
    [~, n_fails2] = t.summary();

    t = GAMSTest('container_rc');
    test_equals(t, cfg, 'rc');
    test_getlist(t, cfg, 'rc');
    test_describe(t, cfg, 'rc');
    test_describePartial(t, cfg, 'rc');
    test_idx_describe(t, cfg, 'rc');
    [~, n_fails3] = t.summary();
    n_fails3 = 0;

    t = GAMSTest('container_rcc');
    test_equals(t, cfg, 'rcc');
    test_getlist(t, cfg, 'rcc');
    test_describe(t, cfg, 'rcc');
    test_describePartial(t, cfg, 'rcc');
    test_idx_describe(t, cfg, 'rcc');
    [~, n_fails4] = t.summary();

    success = n_fails1 + n_fails2 + n_fails3 + n_fails4 == 0;
end

function test_equals(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx1 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    case 'cc'
        gdx1 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
    case 'rc'
        gdx1 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx1 = GAMSTransfer.Container(gdx1, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.Container(gdx2, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
    case 'rcc'
        gdx1 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx1 = GAMSTransfer.Container(gdx1, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx2 = GAMSTransfer.Container(gdx2, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
    end
    is_const_cont = isa(gdx1, 'GAMSTransfer.ConstContainer');

    t.add('equals_1');
    t.assert(gdx1.equals(gdx2));
end

function test_getlist(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'cc'
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'rc'
        gdx = GAMSTransfer.Container(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('get_list_has');
    t.assert(gdx.hasSymbols('i'));
    t.assert(gdx.hasSymbols('I'));
    t.assert(gdx.hasSymbols('x1'));
    t.assert(gdx.hasSymbols('X1'));
    t.assert(gdx.hasSymbols('e1'));
    t.assert(gdx.hasSymbols('E1'));
    t.assert(gdx.hasSymbols('a'));
    t.assert(gdx.hasSymbols('A'));
    t.assert(gdx.hasSymbols('i2'));
    t.assert(gdx.hasSymbols('I2'));
    t.assert(~gdx.hasSymbols('I3'));
    t.assert(~gdx.hasSymbols('Z'));

    t.add('get_list_names');
    t.assertEquals(gdx.getSymbolNames('i'), 'i');
    t.assertEquals(gdx.getSymbolNames('I'), 'i');
    t.assertEquals(gdx.getSymbolNames('x1'), 'x1');
    t.assertEquals(gdx.getSymbolNames('X1'), 'x1');
    t.assertEquals(gdx.getSymbolNames('e1'), 'e1');
    t.assertEquals(gdx.getSymbolNames('E1'), 'e1');
    t.assertEquals(gdx.getSymbolNames('a'), 'a');
    t.assertEquals(gdx.getSymbolNames('A'), 'a');
    t.assertEquals(gdx.getSymbolNames('i2'), 'i2');
    t.assertEquals(gdx.getSymbolNames('I2'), 'i2');

    if ~is_const_cont
        t.add('get_list_empty')
        l = gdx.getSymbols({});
        t.assert(iscell(l));
        t.assert(isempty(l));

        t.add('get_list_set_1');
        l = gdx.getSymbols('i');
        t.assert(isa(l, 'GAMSTransfer.Set'));
        t.assertEquals(l.name, 'i');

        t.add('get_list_set_2');
        l = gdx.getSymbols('I');
        t.assert(isa(l, 'GAMSTransfer.Set'));
        t.assertEquals(l.name, 'i');

        t.add('get_list_variable_1');
        l = gdx.getSymbols('x1');
        t.assert(isa(l, 'GAMSTransfer.Variable'));
        t.assertEquals(l.name, 'x1');

        t.add('get_list_variable_2');
        l = gdx.getSymbols('X1');
        t.assert(isa(l, 'GAMSTransfer.Variable'));
        t.assertEquals(l.name, 'x1');

        t.add('get_list_equation_1');
        l = gdx.getSymbols('e1');
        t.assert(isa(l, 'GAMSTransfer.Equation'));
        t.assertEquals(l.name, 'e1');

        t.add('get_list_equation_2');
        l = gdx.getSymbols('E1');
        t.assert(isa(l, 'GAMSTransfer.Equation'));
        t.assertEquals(l.name, 'e1');

        t.add('get_list_parameter_1');
        l = gdx.getSymbols('a');
        t.assert(isa(l, 'GAMSTransfer.Parameter'));
        t.assertEquals(l.name, 'a');

        t.add('get_list_parameter_2');
        l = gdx.getSymbols('A');
        t.assert(isa(l, 'GAMSTransfer.Parameter'));
        t.assertEquals(l.name, 'a');

        t.add('get_list_alias_1');
        l = gdx.getSymbols('i2');
        t.assert(isa(l, 'GAMSTransfer.Alias'));
        t.assertEquals(l.name, 'i2');

        t.add('get_list_alias_2');
        l = gdx.getSymbols('I2');
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
        t.assert(numel(l) == 11);
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
        t.assert(isa(l{11}, 'GAMSTransfer.Variable'));
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
        t.assertEquals(l{11}.name, 'x11');

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

    t.add('get_list_variables_types_1');
    l = gdx.listVariables('types', 'positive');
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'x5');

    t.add('get_list_variables_types_2');
    l = gdx.listVariables('types', {'binary', 'integer'});
    t.assert(numel(l) == 2);
    t.assertEquals(l{1}, 'x3');
    t.assertEquals(l{2}, 'x4');

    t.add('get_list_equations_types_1');
    l = gdx.listEquations('types', 'e');
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'e1');
    l = gdx.listEquations('types', 'eq');
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'e1');

    t.add('get_list_equations_types_2');
    l = gdx.listEquations('types', {'leq', 'g'});
    t.assert(numel(l) == 2);
    t.assertEquals(l{1}, 'e2');
    t.assertEquals(l{2}, 'e3');

    switch container_type
    case {'c', 'rc', 'rcc'}
        gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    case 'cc'
        gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('get_list_sets_is_valid_1');
    l = gdx.listSets('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 0);

    t.add('get_list_sets_is_valid_2');
    l = gdx.listVariables('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 0);

    switch container_type
    case 'c'
        gdx.read(cfg.filenames{1}, 'symbols', {'x'});
    case 'cc'
        gdx.read(cfg.filenames{1}, 'symbols', {'x'});
    case 'rc'
        cgdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
        cgdx.read(cfg.filenames{1}, 'symbols', {'x'});
        gdx.read(cgdx, 'symbols', {'x'});
    case 'rcc'
        cgdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
        cgdx.read(cfg.filenames{1}, 'symbols', {'x'});
        gdx.read(cgdx, 'symbols', {'x'});
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('get_list_sets_is_valid_3');
    l = gdx.listSets('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 0);

    t.add('get_list_sets_is_valid_4');
    l = gdx.listVariables();
    t.assert(iscell(l));
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'x');
    l = gdx.listVariables('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'x');

    switch container_type
    case 'c'
        gdx.read(cfg.filenames{1}, 'symbols', {'i', 'j'});
    case 'cc'
        gdx.read(cfg.filenames{1}, 'symbols', {'i', 'j', 'x'});
    case 'rc'
        cgdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
        cgdx.read(cfg.filenames{1}, 'symbols', {'i', 'j', 'x'});
        gdx.read(cgdx, 'symbols', {'i', 'j'});
    case 'rcc'
        cgdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
        cgdx.read(cfg.filenames{1}, 'symbols', {'i', 'j', 'x'});
        gdx.read(cgdx, 'symbols', {'i', 'j'});
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('get_list_sets_is_valid_5');
    l = gdx.listSets('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 2);
    t.assertEquals(l{1}, 'i');
    t.assertEquals(l{2}, 'j');
    l = gdx.listVariables('is_valid', true);
    t.assert(iscell(l));
    t.assert(numel(l) == 1);
    t.assertEquals(l{1}, 'x');

end

function test_describe(t, cfg, container_type)

    for i = 1:4
        switch i
        case 1
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'struct');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'struct');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'struct');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'struct');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_sets = 'describe_sets_struct';
            test_name_describe_parameters = 'describe_parameters_struct';
            test_name_describe_variables = 'describe_variables_struct';
        case 2
            if ~cfg.features.table
                continue
            end
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'table');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'table');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'table');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'table');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_sets = 'describe_sets_table';
            test_name_describe_parameters = 'describe_parameters_table';
            test_name_describe_variables = 'describe_variables_table';
        case 3
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'dense_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_sets = 'describe_sets_dense_matrix';
            test_name_describe_parameters = 'describe_parameters_dense_matrix';
            test_name_describe_variables = 'describe_variables_dense_matrix';
        case 4
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'features', cfg.features);
                gdx.read(cfg.filenames{1}, 'format', 'sparse_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_sets = 'describe_sets_sparse_matrix';
            test_name_describe_parameters = 'describe_parameters_sparse_matrix';
            test_name_describe_variables = 'describe_variables_sparse_matrix';
        end

        tbl = gdx.describeSets();

        t.add(test_name_describe_sets);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 11);
            t.assert(height(tbl) == 2);
            t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
            t.assertEquals(tbl.Properties.VariableNames{2}, 'is_alias');
            t.assertEquals(tbl.Properties.VariableNames{3}, 'is_singleton');
            t.assertEquals(tbl.Properties.VariableNames{4}, 'format');
            t.assertEquals(tbl.Properties.VariableNames{5}, 'dim');
            t.assertEquals(tbl.Properties.VariableNames{6}, 'domain_type');
            t.assertEquals(tbl.Properties.VariableNames{7}, 'domain');
            t.assertEquals(tbl.Properties.VariableNames{8}, 'size');
            t.assertEquals(tbl.Properties.VariableNames{9}, 'num_recs');
            t.assertEquals(tbl.Properties.VariableNames{10}, 'num_vals');
            t.assertEquals(tbl.Properties.VariableNames{11}, 'sparsity');
            if gdx.features.categorical
                t.assertEquals(tbl{1,'name'}, 'i');
                switch i
                case {1,3,4}
                    t.assertEquals(tbl{1,'format'}, 'struct');
                case 2
                    t.assertEquals(tbl{1,'format'}, 'table');
                end
            else
                t.assertEquals(tbl{1,'name'}{1}, 'i');
                switch i
                case {1,3,4}
                    t.assertEquals(tbl{1,'format'}{1}, 'struct');
                case 2
                    t.assertEquals(tbl{1,'format'}{1}, 'table');
                end
            end
            t.assert(~tbl{1,'is_alias'});
            t.assert(~tbl{1,'is_singleton'});
            t.assert(tbl{1,'dim'} == 1);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'domain_type'}, 'none');
                t.assertEquals(tbl{1,'domain'}, '[*]');
                t.assertEquals(tbl{1,'size'}, '[NaN]');
            else
                t.assertEquals(tbl{1,'domain_type'}{1}, 'none');
                t.assertEquals(tbl{1,'domain'}{1}, '[*]');
                t.assertEquals(tbl{1,'size'}{1}, '[NaN]');
            end
            t.assert(tbl{1,'num_recs'} == 5);
            t.assert(tbl{1,'num_vals'} == 0);
            t.assert(isnan(tbl{1,'sparsity'}));
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 11);
            t.assert(numel(tbl.name) == 2);
            t.assert(isfield(tbl, 'name'));
            t.assert(isfield(tbl, 'is_alias'));
            t.assert(isfield(tbl, 'is_singleton'));
            t.assert(isfield(tbl, 'format'));
            t.assert(isfield(tbl, 'dim'));
            t.assert(isfield(tbl, 'domain'));
            t.assert(isfield(tbl, 'size'));
            t.assert(isfield(tbl, 'num_recs'));
            t.assert(isfield(tbl, 'num_vals'));
            t.assert(isfield(tbl, 'sparsity'));
            if gdx.features.categorical
                t.assertEquals(tbl.name(1), 'i');
                switch i
                case {1,3,4}
                    t.assertEquals(tbl.format(1), 'struct');
                case 2
                    t.assertEquals(tbl.format(1), 'table');
                end
            else
                t.assertEquals(tbl.name{1}, 'i');
                switch i
                case {1,3,4}
                    t.assertEquals(tbl.format{1}, 'struct');
                case 2
                    t.assertEquals(tbl.format{1}, 'table');
                end
            end
            t.assert(~tbl.is_alias(1));
            t.assert(~tbl.is_singleton(1));
            t.assert(tbl.dim(1) == 1);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(1), 'none');
                t.assertEquals(tbl.domain(1), '[*]');
                t.assertEquals(tbl.size(1), '[NaN]');
            else
                t.assertEquals(tbl.domain_type{1}, 'none');
                t.assertEquals(tbl.domain{1}, '[*]');
                t.assertEquals(tbl.size{1}, '[NaN]');
            end
            t.assert(tbl.num_recs(1) == 5);
            t.assert(tbl.num_vals(1) == 0);
            t.assert(isnan(tbl.sparsity(1)));
        end

        tbl = gdx.describeParameters();

        t.add(test_name_describe_parameters);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 16);
            t.assert(height(tbl) == 2);
            t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
            t.assertEquals(tbl.Properties.VariableNames{2}, 'format');
            t.assertEquals(tbl.Properties.VariableNames{3}, 'dim');
            t.assertEquals(tbl.Properties.VariableNames{4}, 'domain_type');
            t.assertEquals(tbl.Properties.VariableNames{5}, 'domain');
            t.assertEquals(tbl.Properties.VariableNames{6}, 'size');
            t.assertEquals(tbl.Properties.VariableNames{7}, 'num_recs');
            t.assertEquals(tbl.Properties.VariableNames{8}, 'num_vals');
            t.assertEquals(tbl.Properties.VariableNames{9}, 'sparsity');
            t.assertEquals(tbl.Properties.VariableNames{10}, 'min_value');
            t.assertEquals(tbl.Properties.VariableNames{11}, 'mean_value');
            t.assertEquals(tbl.Properties.VariableNames{12}, 'max_value');
            t.assertEquals(tbl.Properties.VariableNames{13}, 'where_max_abs_value');
            t.assertEquals(tbl.Properties.VariableNames{14}, 'count_na');
            t.assertEquals(tbl.Properties.VariableNames{15}, 'count_undef');
            t.assertEquals(tbl.Properties.VariableNames{16}, 'count_eps');
            if gdx.features.categorical
                t.assertEquals(tbl{1,'name'}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl{1,'format'}, 'struct') || isequal(tbl{1,'format'}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl{1,'format'}, 'table');
                case 4
                    t.assertEquals(tbl{1,'format'}, 'sparse_matrix');
                end
            else
                t.assertEquals(tbl{1,'name'}{1}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl{1,'format'}{1}, 'struct') || isequal(tbl{1,'format'}{1}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl{1,'format'}{1}, 'table');
                case 4
                    t.assertEquals(tbl{1,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{1,'dim'} == 0);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'domain_type'}, 'none');
                t.assertEquals(tbl{1,'domain'}, '[]');
                t.assertEquals(tbl{1,'size'}, '[]');
            else
                t.assertEquals(tbl{1,'domain_type'}{1}, 'none');
                t.assertEquals(tbl{1,'domain'}{1}, '[]');
                t.assertEquals(tbl{1,'size'}{1}, '[]');
            end
            switch i
            case {1,3}
                t.assert(tbl{1,'num_recs'} == 1 || isnan(tbl{1,'num_recs'}));
            case 2
                t.assert(tbl{1,'num_recs'} == 1);
            case {3,4}
                t.assert(isnan(tbl{1,'num_recs'}));
            end
            t.assert(tbl{1,'num_vals'} == 1);
            t.assert(tbl{1,'sparsity'} == 0);
            t.assert(tbl{1,'min_value'} == 4);
            t.assert(tbl{1,'mean_value'} == 4);
            t.assert(tbl{1,'max_value'} == 4);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'where_max_abs_value'}, '[]');
            else
                t.assertEquals(tbl{1,'where_max_abs_value'}{1}, '[]');
            end
            t.assert(tbl{1,'count_na'} == 0);
            t.assert(tbl{1,'count_undef'} == 0);
            t.assert(tbl{1,'count_eps'} == 0);
            if gdx.features.categorical
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
            else
                t.assertEquals(tbl{2,'name'}{1}, 'b');
                switch i
                case 1
                    t.assertEquals(tbl{2,'format'}{1}, 'struct');
                case 2
                    t.assertEquals(tbl{2,'format'}{1}, 'table');
                case 3
                    t.assertEquals(tbl{2,'format'}{1}, 'dense_matrix');
                case 4
                    t.assertEquals(tbl{2,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{2,'dim'} == 1);
            if gdx.features.categorical
                t.assertEquals(tbl{2,'domain_type'}, 'regular');
                t.assertEquals(tbl{2,'domain'}, '[i]');
                t.assertEquals(tbl{2,'size'}, '[5]');
            else
                t.assertEquals(tbl{2,'domain_type'}{1}, 'regular');
                t.assertEquals(tbl{2,'domain'}{1}, '[i]');
                t.assertEquals(tbl{2,'size'}{1}, '[5]');
            end
            switch i
            case {1,2}
                t.assert(tbl{2,'num_recs'} == 3);
                t.assert(tbl{2,'num_vals'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
            case 3
                t.assert(isnan(tbl{2,'num_recs'}));
                t.assert(tbl{2,'num_vals'} == 5);
                t.assert(tbl{2,'sparsity'} == 0);
            case 4
                t.assert(isnan(tbl{2,'num_recs'}));
                t.assert(tbl{2,'num_vals'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
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
            if gdx.features.categorical
                t.assertEquals(tbl{2,'where_max_abs_value'}, '[i10]');
            else
                t.assertEquals(tbl{2,'where_max_abs_value'}{1}, '[i10]');
            end
            t.assert(tbl{2,'count_na'} == 0);
            t.assert(tbl{2,'count_undef'} == 0);
            t.assert(tbl{2,'count_eps'} == 0);
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 16);
            t.assert(numel(tbl.name) == 2);
            t.assert(isfield(tbl, 'name'));
            t.assert(isfield(tbl, 'format'));
            t.assert(isfield(tbl, 'dim'));
            t.assert(isfield(tbl, 'domain_type'));
            t.assert(isfield(tbl, 'domain'));
            t.assert(isfield(tbl, 'size'));
            t.assert(isfield(tbl, 'num_recs'));
            t.assert(isfield(tbl, 'num_vals'));
            t.assert(isfield(tbl, 'sparsity'));
            t.assert(isfield(tbl, 'min_value'));
            t.assert(isfield(tbl, 'mean_value'));
            t.assert(isfield(tbl, 'max_value'));
            t.assert(isfield(tbl, 'where_max_abs_value'));
            t.assert(isfield(tbl, 'count_na'));
            t.assert(isfield(tbl, 'count_undef'));
            t.assert(isfield(tbl, 'count_eps'));
            if gdx.features.categorical
                t.assertEquals(tbl.name(1), 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl.format(1), 'struct') || isequal(tbl.format(1), 'dense_matrix'));
                case 2
                    t.assertEquals(tbl.format(1), 'table');
                case 4
                    t.assertEquals(tbl.format(1), 'sparse_matrix');
                end
            else
                t.assertEquals(tbl.name{1}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl.format{1}, 'struct') || isequal(tbl.format{1}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl.format{1}, 'table');
                case 4
                    t.assertEquals(tbl.format{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl.dim(1) == 0);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(1), 'none');
                t.assertEquals(tbl.domain(1), '[]');
                t.assertEquals(tbl.size(1), '[]');
            else
                t.assertEquals(tbl.domain_type{1}, 'none');
                t.assertEquals(tbl.domain{1}, '[]');
                t.assertEquals(tbl.size{1}, '[]');
            end
            switch i
            case {1,3}
                t.assert(tbl.num_recs(1) == 1 || isnan(tbl.num_recs(1)));
            case 2
                t.assert(tbl.num_recs(1) == 1);
            case {3,4}
                t.assert(isnan(tbl.num_recs(1)));
            end
            t.assert(tbl.num_vals(1) == 1);
            t.assert(tbl.sparsity(1) == 0);
            t.assert(tbl.min_value(1) == 4);
            t.assert(tbl.mean_value(1) == 4);
            t.assert(tbl.max_value(1) == 4);
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_value(1), '[]');
            else
                t.assertEquals(tbl.where_max_abs_value{1}, '[]');
            end
            t.assert(tbl.count_na(1) == 0);
            t.assert(tbl.count_undef(1) == 0);
            t.assert(tbl.count_eps(1) == 0);
            if gdx.features.categorical
                t.assertEquals(tbl.name(2), 'b');
                switch i
                case 1
                    t.assertEquals(tbl.format(2), 'struct');
                case 2
                    t.assertEquals(tbl.format(2), 'table');
                case 3
                    t.assertEquals(tbl.format(2), 'dense_matrix');
                case 4
                    t.assertEquals(tbl.format(2), 'sparse_matrix');
                end
            else
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
            end
            t.assert(tbl.dim(2) == 1);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(2), 'regular');
                t.assertEquals(tbl.domain(2), '[i]');
                t.assertEquals(tbl.size(2), '[5]');
            else
                t.assertEquals(tbl.domain_type{2}, 'regular');
                t.assertEquals(tbl.domain{2}, '[i]');
                t.assertEquals(tbl.size{2}, '[5]');
            end
            switch i
            case {1,2}
                t.assert(tbl.num_recs(2) == 3);
                t.assert(tbl.num_vals(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
            case 3
                t.assert(isnan(tbl.num_recs(2)));
                t.assert(tbl.num_vals(2) == 5);
                t.assert(tbl.sparsity(2) == 0);
            case 4
                t.assert(isnan(tbl.num_recs(2)));
                t.assert(tbl.num_vals(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
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
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_value(2), '[i10]');
            else
                t.assertEquals(tbl.where_max_abs_value{2}, '[i10]');
            end
            t.assert(tbl.count_na(2) == 0);
            t.assert(tbl.count_undef(2) == 0);
            t.assert(tbl.count_eps(2) == 0);
        end

        tbl = gdx.describeVariables();

        t.add(test_name_describe_variables);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 24);
            t.assert(height(tbl) == 1);
            t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
            t.assertEquals(tbl.Properties.VariableNames{2}, 'type');
            t.assertEquals(tbl.Properties.VariableNames{3}, 'format');
            t.assertEquals(tbl.Properties.VariableNames{4}, 'dim');
            t.assertEquals(tbl.Properties.VariableNames{5}, 'domain_type');
            t.assertEquals(tbl.Properties.VariableNames{6}, 'domain');
            t.assertEquals(tbl.Properties.VariableNames{7}, 'size');
            t.assertEquals(tbl.Properties.VariableNames{8}, 'num_recs');
            t.assertEquals(tbl.Properties.VariableNames{9}, 'num_vals');
            t.assertEquals(tbl.Properties.VariableNames{10}, 'sparsity');
            t.assertEquals(tbl.Properties.VariableNames{11}, 'min_level');
            t.assertEquals(tbl.Properties.VariableNames{12}, 'mean_level');
            t.assertEquals(tbl.Properties.VariableNames{13}, 'max_level');
            t.assertEquals(tbl.Properties.VariableNames{14}, 'where_max_abs_level');
            t.assertEquals(tbl.Properties.VariableNames{15}, 'count_na_level');
            t.assertEquals(tbl.Properties.VariableNames{16}, 'count_undef_level');
            t.assertEquals(tbl.Properties.VariableNames{17}, 'count_eps_level');
            t.assertEquals(tbl.Properties.VariableNames{18}, 'min_marginal');
            t.assertEquals(tbl.Properties.VariableNames{19}, 'mean_marginal');
            t.assertEquals(tbl.Properties.VariableNames{20}, 'max_marginal');
            t.assertEquals(tbl.Properties.VariableNames{21}, 'where_max_abs_marginal');
            t.assertEquals(tbl.Properties.VariableNames{22}, 'count_na_marginal');
            t.assertEquals(tbl.Properties.VariableNames{23}, 'count_undef_marginal');
            t.assertEquals(tbl.Properties.VariableNames{24}, 'count_eps_marginal');
            if gdx.features.categorical
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
            else
                t.assertEquals(tbl{1,'name'}{1}, 'x');
                t.assertEquals(tbl{1,'type'}{1}, 'positive');
                switch i
                case 1
                    t.assertEquals(tbl{1,'format'}{1}, 'struct');
                case 2
                    t.assertEquals(tbl{1,'format'}{1}, 'table');
                case 3
                    t.assertEquals(tbl{1,'format'}{1}, 'dense_matrix');
                case 4
                    t.assertEquals(tbl{1,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{1,'dim'} == 2);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'domain_type'}, 'regular');
                t.assertEquals(tbl{1,'domain'}, '[i,j]');
                t.assertEquals(tbl{1,'size'}, '[5,5]');
            else
                t.assertEquals(tbl{1,'domain_type'}{1}, 'regular');
                t.assertEquals(tbl{1,'domain'}{1}, '[i,j]');
                t.assertEquals(tbl{1,'size'}{1}, '[5,5]');
            end
            switch i
            case {1,2}
                t.assert(tbl{1,'num_recs'} == 6);
                t.assert(tbl{1,'num_vals'} == 30);
                t.assert(tbl{1,'sparsity'} == 0.76);
            case 3
                t.assert(isnan(tbl{1,'num_recs'}));
                t.assert(tbl{1,'num_vals'} == 125);
                t.assert(tbl{1,'sparsity'} == 0);
            case 4
                t.assert(isnan(tbl{1,'num_recs'}));
                t.assert(tbl{1,'num_vals'} == 55);
                t.assert(tbl{1,'sparsity'} == 0.56);
            end
            t.assert(tbl{1,'min_level'} == 0);
            switch i
            case {1,2}
                t.assert(tbl{1,'mean_level'} == 18/6);
            case {3,4}
                t.assert(tbl{1,'mean_level'} == 18/25);
            end
            t.assert(tbl{1,'max_level'} == 9);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'where_max_abs_level'}, '[i3,j9]');
            else
                t.assertEquals(tbl{1,'where_max_abs_level'}{1}, '[i3,j9]');
            end
            t.assert(tbl{1,'count_na_level'} == 0);
            t.assert(tbl{1,'count_undef_level'} == 0);
            t.assert(tbl{1,'count_eps_level'} == 0);
            t.assert(tbl{1,'min_marginal'} == 0);
            switch i
            case {1,2}
                t.assert(tbl{1,'mean_marginal'} == 13/6);
            case {3,4}
                t.assert(tbl{1,'mean_marginal'} == 13/25);
            end
            t.assert(tbl{1,'max_marginal'} == 8);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'where_max_abs_marginal'}, '[i3,j8]');
            else
                t.assertEquals(tbl{1,'where_max_abs_marginal'}{1}, '[i3,j8]');
            end
            t.assert(tbl{1,'count_na_marginal'} == 0);
            t.assert(tbl{1,'count_undef_marginal'} == 0);
            t.assert(tbl{1,'count_eps_marginal'} == 0);
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 24);
            t.assert(numel(tbl.name) == 1);
            t.assert(isfield(tbl, 'name'));
            t.assert(isfield(tbl, 'type'));
            t.assert(isfield(tbl, 'format'));
            t.assert(isfield(tbl, 'dim'));
            t.assert(isfield(tbl, 'domain_type'));
            t.assert(isfield(tbl, 'domain'));
            t.assert(isfield(tbl, 'size'));
            t.assert(isfield(tbl, 'num_recs'));
            t.assert(isfield(tbl, 'num_vals'));
            t.assert(isfield(tbl, 'sparsity'));
            t.assert(isfield(tbl, 'min_level'));
            t.assert(isfield(tbl, 'mean_level'));
            t.assert(isfield(tbl, 'max_level'));
            t.assert(isfield(tbl, 'where_max_abs_level'));
            t.assert(isfield(tbl, 'count_na_level'));
            t.assert(isfield(tbl, 'count_undef_level'));
            t.assert(isfield(tbl, 'count_eps_level'));
            t.assert(isfield(tbl, 'min_marginal'));
            t.assert(isfield(tbl, 'mean_marginal'));
            t.assert(isfield(tbl, 'max_marginal'));
            t.assert(isfield(tbl, 'where_max_abs_marginal'));
            t.assert(isfield(tbl, 'count_na_marginal'));
            t.assert(isfield(tbl, 'count_undef_marginal'));
            t.assert(isfield(tbl, 'count_eps_marginal'));
            if gdx.features.categorical
                t.assertEquals(tbl.name(1), 'x');
                t.assertEquals(tbl.type(1), 'positive');
                switch i
                case 1
                    t.assertEquals(tbl.format(1), 'struct');
                case 2
                    t.assertEquals(tbl.format(1), 'table');
                case 3
                    t.assertEquals(tbl.format(1), 'dense_matrix');
                case 4
                    t.assertEquals(tbl.format(1), 'sparse_matrix');
                end
            else
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
            end
            t.assert(tbl.dim(1) == 2);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(1), 'regular');
                t.assertEquals(tbl.domain(1), '[i,j]');
                t.assertEquals(tbl.size(1), '[5,5]');
            else
                t.assertEquals(tbl.domain_type{1}, 'regular');
                t.assertEquals(tbl.domain{1}, '[i,j]');
                t.assertEquals(tbl.size{1}, '[5,5]');
            end
            switch i
            case {1,2}
                t.assert(tbl.num_recs(1) == 6);
                t.assert(tbl.num_vals(1) == 30);
                t.assert(tbl.sparsity(1) == 0.76);
            case 3
                t.assert(isnan(tbl.num_recs(1)));
                t.assert(tbl.num_vals(1) == 125);
                t.assert(tbl.sparsity(1) == 0);
            case 4
                t.assert(isnan(tbl.num_recs(1)));
                t.assert(tbl.num_vals(1) == 55);
                t.assert(tbl.sparsity(1) == 0.56);
            end
            t.assert(tbl.min_level(1) == 0);
            switch i
            case {1,2}
                t.assert(tbl.mean_level(1) == 18/6);
            case {3,4}
                t.assert(tbl.mean_level(1) == 18/25);
            end
            t.assert(tbl.max_level(1) == 9);
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_level(1), '[i3,j9]');
            else
                t.assertEquals(tbl.where_max_abs_level{1}, '[i3,j9]');
            end
            t.assert(tbl.count_na_level(1) == 0);
            t.assert(tbl.count_undef_level(1) == 0);
            t.assert(tbl.count_eps_level(1) == 0);
            t.assert(tbl.min_marginal(1) == 0);
            switch i
            case {1,2}
                t.assert(tbl.mean_marginal(1) == 13/6);
            case {3,4}
                t.assert(tbl.mean_marginal(1) == 13/25);
            end
            t.assert(tbl.max_marginal(1) == 8);
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_marginal(1), '[i3,j8]');
            else
                t.assertEquals(tbl.where_max_abs_marginal{1}, '[i3,j8]');
            end
            t.assert(tbl.count_na_marginal(1) == 0);
            t.assert(tbl.count_undef_marginal(1) == 0);
            t.assert(tbl.count_eps_marginal(1) == 0);
        end
    end

    tbl = gdx.describeEquations();

    t.add('describe_equations');
    if gdx.features.table
        t.assert(istable(tbl));
        t.assert(numel(tbl.Properties.VariableNames) == 24);
        t.assert(height(tbl) == 0);
        t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
        t.assertEquals(tbl.Properties.VariableNames{2}, 'type');
        t.assertEquals(tbl.Properties.VariableNames{3}, 'format');
        t.assertEquals(tbl.Properties.VariableNames{4}, 'dim');
        t.assertEquals(tbl.Properties.VariableNames{5}, 'domain_type');
        t.assertEquals(tbl.Properties.VariableNames{6}, 'domain');
        t.assertEquals(tbl.Properties.VariableNames{7}, 'size');
        t.assertEquals(tbl.Properties.VariableNames{8}, 'num_recs');
        t.assertEquals(tbl.Properties.VariableNames{9}, 'num_vals');
        t.assertEquals(tbl.Properties.VariableNames{10}, 'sparsity');
        t.assertEquals(tbl.Properties.VariableNames{11}, 'min_level');
        t.assertEquals(tbl.Properties.VariableNames{12}, 'mean_level');
        t.assertEquals(tbl.Properties.VariableNames{13}, 'max_level');
        t.assertEquals(tbl.Properties.VariableNames{14}, 'where_max_abs_level');
        t.assertEquals(tbl.Properties.VariableNames{15}, 'count_na_level');
        t.assertEquals(tbl.Properties.VariableNames{16}, 'count_undef_level');
        t.assertEquals(tbl.Properties.VariableNames{17}, 'count_eps_level');
        t.assertEquals(tbl.Properties.VariableNames{18}, 'min_marginal');
        t.assertEquals(tbl.Properties.VariableNames{19}, 'mean_marginal');
        t.assertEquals(tbl.Properties.VariableNames{20}, 'max_marginal');
        t.assertEquals(tbl.Properties.VariableNames{21}, 'where_max_abs_marginal');
        t.assertEquals(tbl.Properties.VariableNames{22}, 'count_na_marginal');
        t.assertEquals(tbl.Properties.VariableNames{23}, 'count_undef_marginal');
        t.assertEquals(tbl.Properties.VariableNames{24}, 'count_eps_marginal');
    else
        t.assert(isstruct(tbl));
        t.assert(numel(fieldnames(tbl)) == 24);
        t.assert(numel(tbl.name) == 0);
        t.assert(isfield(tbl, 'name'));
        t.assert(isfield(tbl, 'type'));
        t.assert(isfield(tbl, 'format'));
        t.assert(isfield(tbl, 'dim'));
        t.assert(isfield(tbl, 'domain_type'));
        t.assert(isfield(tbl, 'domain'));
        t.assert(isfield(tbl, 'size'));
        t.assert(isfield(tbl, 'num_recs'));
        t.assert(isfield(tbl, 'num_vals'));
        t.assert(isfield(tbl, 'sparsity'));
        t.assert(isfield(tbl, 'min_level'));
        t.assert(isfield(tbl, 'mean_level'));
        t.assert(isfield(tbl, 'max_level'));
        t.assert(isfield(tbl, 'where_max_abs_level'));
        t.assert(isfield(tbl, 'count_na_level'));
        t.assert(isfield(tbl, 'count_undef_level'));
        t.assert(isfield(tbl, 'count_eps_level'));
        t.assert(isfield(tbl, 'min_marginal'));
        t.assert(isfield(tbl, 'mean_marginal'));
        t.assert(isfield(tbl, 'max_marginal'));
        t.assert(isfield(tbl, 'where_max_abs_marginal'));
        t.assert(isfield(tbl, 'count_na_marginal'));
        t.assert(isfield(tbl, 'count_undef_marginal'));
        t.assert(isfield(tbl, 'count_eps_marginal'));
    end
end

function test_describePartial(t, cfg, container_type)

    switch container_type
    case 'c'
        gdx = GAMSTransfer.Container(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'cc'
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'rc'
        gdx = GAMSTransfer.Container(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    case 'rcc'
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{3}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    end
    is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');

    t.add('describe_partial_sets_1');
    tbl = gdx.describeSets(gdx.listSymbols('types', ...
        [GAMSTransfer.SymbolType.SET, GAMSTransfer.SymbolType.ALIAS]));
    if gdx.features.table
        t.assert(height(tbl) == 4);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'i');
            t.assertEquals(tbl{2,'name'}, 'j');
            t.assertEquals(tbl{3,'name'}, 'i2');
            t.assertEquals(tbl{4,'name'}, 'j2');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'i');
            t.assertEquals(tbl{2,'name'}{1}, 'j');
            t.assertEquals(tbl{3,'name'}{1}, 'i2');
            t.assertEquals(tbl{4,'name'}{1}, 'j2');
        end
    else
        t.assert(numel(tbl.name) == 4);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'i');
            t.assertEquals(tbl.name(2), 'j');
            t.assertEquals(tbl.name(3), 'i2');
            t.assertEquals(tbl.name(4), 'j2');
        else
            t.assertEquals(tbl.name{1}, 'i');
            t.assertEquals(tbl.name{2}, 'j');
            t.assertEquals(tbl.name{3}, 'i2');
            t.assertEquals(tbl.name{4}, 'j2');
        end
    end

    t.add('describe_partial_sets_2');
    tbl = gdx.describeSets({'i', 'i2'});
    if gdx.features.table
        t.assert(height(tbl) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'i');
            t.assertEquals(tbl{2,'name'}, 'i2');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'i');
            t.assertEquals(tbl{2,'name'}{1}, 'i2');
        end
    else
        t.assert(numel(tbl.name) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'i');
            t.assertEquals(tbl.name(2), 'i2');
        else
            t.assertEquals(tbl.name{1}, 'i');
            t.assertEquals(tbl.name{2}, 'i2');
        end
    end

    t.add('describe_partial_alias_1');
    tbl = gdx.describeAliases();
    if gdx.features.table
        t.assert(height(tbl) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'i2');
            t.assertEquals(tbl{2,'name'}, 'j2');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'i2');
            t.assertEquals(tbl{2,'name'}{1}, 'j2');
        end
    else
        t.assert(numel(tbl.name) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'i2');
            t.assertEquals(tbl.name(2), 'j2');
        else
            t.assertEquals(tbl.name{1}, 'i2');
            t.assertEquals(tbl.name{2}, 'j2');
        end
    end

    t.add('describe_partial_sets_2');
    tbl = gdx.describeAliases({'i2'});
    if gdx.features.table
        t.assert(height(tbl) == 1);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'i2');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'i2');
        end
    else
        t.assert(numel(tbl.name) == 1);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'i2');
        else
            t.assertEquals(tbl.name{1}, 'i2');
        end
    end

    t.add('describe_partial_parameters_1');
    tbl = gdx.describeParameters();
    if gdx.features.table
        t.assert(height(tbl) == 1);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'a');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'a');
        end
    else
        t.assert(numel(tbl.name) == 1);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'a');
        else
            t.assertEquals(tbl.name{1}, 'a');
        end
    end

    t.add('describe_partial_parameters_2');
    tbl = gdx.describeParameters({});
    if gdx.features.table
        t.assert(height(tbl) == 0);
    else
        t.assert(numel(tbl.name) == 0);
    end

    t.add('describe_partial_variables_1');
    tbl = gdx.describeVariables();
    if gdx.features.table
        t.assert(height(tbl) == 11);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'x1');
            t.assertEquals(tbl{2,'name'}, 'x2');
            t.assertEquals(tbl{3,'name'}, 'x3');
            t.assertEquals(tbl{4,'name'}, 'x4');
            t.assertEquals(tbl{5,'name'}, 'x5');
            t.assertEquals(tbl{6,'name'}, 'x6');
            t.assertEquals(tbl{7,'name'}, 'x7');
            t.assertEquals(tbl{8,'name'}, 'x8');
            t.assertEquals(tbl{9,'name'}, 'x9');
            t.assertEquals(tbl{10,'name'}, 'x10');
            t.assertEquals(tbl{11,'name'}, 'x11');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'x1');
            t.assertEquals(tbl{2,'name'}{1}, 'x2');
            t.assertEquals(tbl{3,'name'}{1}, 'x3');
            t.assertEquals(tbl{4,'name'}{1}, 'x4');
            t.assertEquals(tbl{5,'name'}{1}, 'x5');
            t.assertEquals(tbl{6,'name'}{1}, 'x6');
            t.assertEquals(tbl{7,'name'}{1}, 'x7');
            t.assertEquals(tbl{8,'name'}{1}, 'x8');
            t.assertEquals(tbl{9,'name'}{1}, 'x9');
            t.assertEquals(tbl{10,'name'}{1}, 'x10');
            t.assertEquals(tbl{11,'name'}{1}, 'x11');
        end
    else
        t.assert(numel(tbl.name) == 11);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'x1');
            t.assertEquals(tbl.name(2), 'x2');
            t.assertEquals(tbl.name(3), 'x3');
            t.assertEquals(tbl.name(4), 'x4');
            t.assertEquals(tbl.name(5), 'x5');
            t.assertEquals(tbl.name(6), 'x6');
            t.assertEquals(tbl.name(7), 'x7');
            t.assertEquals(tbl.name(8), 'x8');
            t.assertEquals(tbl.name(9), 'x9');
            t.assertEquals(tbl.name(10), 'x10');
            t.assertEquals(tbl.name(11), 'x11');
        else
            t.assertEquals(tbl.name{1}, 'x1');
            t.assertEquals(tbl.name{2}, 'x2');
            t.assertEquals(tbl.name{3}, 'x3');
            t.assertEquals(tbl.name{4}, 'x4');
            t.assertEquals(tbl.name{5}, 'x5');
            t.assertEquals(tbl.name{6}, 'x6');
            t.assertEquals(tbl.name{7}, 'x7');
            t.assertEquals(tbl.name{8}, 'x8');
            t.assertEquals(tbl.name{9}, 'x9');
            t.assertEquals(tbl.name{10}, 'x10');
            t.assertEquals(tbl.name{11}, 'x11');
        end
    end

    t.add('describe_partial_variables_2');
    tbl = gdx.describeVariables({'x9', 'x4', 'x2'});
    if gdx.features.table
        t.assert(height(tbl) == 3);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'x9');
            t.assertEquals(tbl{2,'name'}, 'x4');
            t.assertEquals(tbl{3,'name'}, 'x2');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'x9');
            t.assertEquals(tbl{2,'name'}{1}, 'x4');
            t.assertEquals(tbl{3,'name'}{1}, 'x2');
        end
    else
        t.assert(numel(tbl.name) == 3);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'x9');
            t.assertEquals(tbl.name(2), 'x4');
            t.assertEquals(tbl.name(3), 'x2');
        else
            t.assertEquals(tbl.name{1}, 'x9');
            t.assertEquals(tbl.name{2}, 'x4');
            t.assertEquals(tbl.name{3}, 'x2');
        end
    end

    t.add('describe_partial_equations_1');
    tbl = gdx.describeEquations();
    if gdx.features.table
        t.assert(height(tbl) == 3);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'e1');
            t.assertEquals(tbl{2,'name'}, 'e2');
            t.assertEquals(tbl{3,'name'}, 'e3');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'e1');
            t.assertEquals(tbl{2,'name'}{1}, 'e2');
            t.assertEquals(tbl{3,'name'}{1}, 'e3');
        end
    else
        t.assert(numel(tbl.name) == 3);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'e1');
            t.assertEquals(tbl.name(2), 'e2');
            t.assertEquals(tbl.name(3), 'e3');
        else
            t.assertEquals(tbl.name{1}, 'e1');
            t.assertEquals(tbl.name{2}, 'e2');
            t.assertEquals(tbl.name{3}, 'e3');
        end
    end

    t.add('describe_partial_equations_2');
    tbl = gdx.describeEquations({'e1', 'e1'});
    if gdx.features.table
        t.assert(height(tbl) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl{1,'name'}, 'e1');
            t.assertEquals(tbl{2,'name'}, 'e1');
        else
            t.assertEquals(tbl{1,'name'}{1}, 'e1');
            t.assertEquals(tbl{2,'name'}{1}, 'e1');
        end
    else
        t.assert(numel(tbl.name) == 2);
        if gdx.features.categorical
            t.assertEquals(tbl.name(1), 'e1');
            t.assertEquals(tbl.name(2), 'e1');
        else
            t.assertEquals(tbl.name{1}, 'e1');
            t.assertEquals(tbl.name{2}, 'e1');
        end
    end

end

function test_idx_describe(t, cfg, container_type)

    for i = 1:4
        switch i
        case 1
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'struct');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'struct');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'struct');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'struct');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_parameters = 'idx_describe_parameters_struct';
        case 2
            if ~cfg.features.table
                continue
            end
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'table');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'table');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'table');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'table');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_parameters = 'idx_describe_parameters_table';
        case 3
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'dense_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_parameters = 'idx_describe_parameters_dense_matrix';
        case 4
            switch container_type
            case 'c'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
            case 'cc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
            case 'rc'
                gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            case 'rcc'
                gdx = GAMSTransfer.ConstContainer('gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
                gdx.read(cfg.filenames{4}, 'format', 'sparse_matrix');
                gdx = GAMSTransfer.Container(gdx, 'gams_dir', cfg.gams_dir, 'indexed', true, ...
                    'features', cfg.features);
            end
            is_const_cont = isa(gdx, 'GAMSTransfer.ConstContainer');
            test_name_describe_parameters = 'idx_describe_parameters_sparse_matrix';
        end

        tbl = gdx.describeParameters();

        t.add(test_name_describe_parameters);
        if gdx.features.table
            t.assert(istable(tbl));
            t.assert(numel(tbl.Properties.VariableNames) == 16);
            t.assert(height(tbl) == 3);
            t.assertEquals(tbl.Properties.VariableNames{1}, 'name');
            t.assertEquals(tbl.Properties.VariableNames{2}, 'format');
            t.assertEquals(tbl.Properties.VariableNames{3}, 'dim');
            t.assertEquals(tbl.Properties.VariableNames{4}, 'domain_type');
            t.assertEquals(tbl.Properties.VariableNames{5}, 'domain');
            t.assertEquals(tbl.Properties.VariableNames{6}, 'size');
            t.assertEquals(tbl.Properties.VariableNames{7}, 'num_recs');
            t.assertEquals(tbl.Properties.VariableNames{8}, 'num_vals');
            t.assertEquals(tbl.Properties.VariableNames{9}, 'sparsity');
            t.assertEquals(tbl.Properties.VariableNames{10}, 'min_value');
            t.assertEquals(tbl.Properties.VariableNames{11}, 'mean_value');
            t.assertEquals(tbl.Properties.VariableNames{12}, 'max_value');
            t.assertEquals(tbl.Properties.VariableNames{13}, 'where_max_abs_value');
            t.assertEquals(tbl.Properties.VariableNames{14}, 'count_na');
            t.assertEquals(tbl.Properties.VariableNames{15}, 'count_undef');
            t.assertEquals(tbl.Properties.VariableNames{16}, 'count_eps');
            if gdx.features.categorical
                t.assertEquals(tbl{1,'name'}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl{1,'format'}, 'struct') || isequal(tbl{1,'format'}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl{1,'format'}, 'table');
                case 4
                    t.assertEquals(tbl{1,'format'}, 'sparse_matrix');
                end
            else
                t.assertEquals(tbl{1,'name'}{1}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl{1,'format'}{1}, 'struct') || isequal(tbl{1,'format'}{1}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl{1,'format'}{1}, 'table');
                case 4
                    t.assertEquals(tbl{1,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{1,'dim'} == 0);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'domain_type'}, 'relaxed');
                t.assertEquals(tbl{1,'domain'}, '[]');
                t.assertEquals(tbl{1,'size'}, '[]');
            else
                t.assertEquals(tbl{1,'domain_type'}{1}, 'relaxed');
                t.assertEquals(tbl{1,'domain'}{1}, '[]');
                t.assertEquals(tbl{1,'size'}{1}, '[]');
            end
            switch i
            case {1,3}
                t.assert(tbl{1,'num_recs'} == 1 || isnan(tbl{1,'num_recs'}));
            case 2
                t.assert(tbl{1,'num_recs'} == 1);
            case 4
                t.assert(isnan(tbl{1,'num_recs'}));
            end
            t.assert(tbl{1,'num_vals'} == 1);
            t.assert(tbl{1,'sparsity'} == 0);
            t.assert(tbl{1,'min_value'} == 4);
            t.assert(tbl{1,'mean_value'} == 4);
            t.assert(tbl{1,'max_value'} == 4);
            if gdx.features.categorical
                t.assertEquals(tbl{1,'where_max_abs_value'}, '[]');
            else
                t.assertEquals(tbl{1,'where_max_abs_value'}{1}, '[]');
            end
            t.assert(tbl{1,'count_na'} == 0);
            t.assert(tbl{1,'count_undef'} == 0);
            t.assert(tbl{1,'count_eps'} == 0);
            if gdx.features.categorical
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
            else
                t.assertEquals(tbl{2,'name'}{1}, 'b');
                switch i
                case 1
                    t.assertEquals(tbl{2,'format'}{1}, 'struct');
                case 2
                    t.assertEquals(tbl{2,'format'}{1}, 'table');
                case 3
                    t.assertEquals(tbl{2,'format'}{1}, 'dense_matrix');
                case 4
                    t.assertEquals(tbl{2,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{2,'dim'} == 1);
            if gdx.features.categorical
                t.assertEquals(tbl{2,'domain_type'}, 'relaxed');
                t.assertEquals(tbl{2,'domain'}, '[dim_1]');
                t.assertEquals(tbl{2,'size'}, '[5]');
            else
                t.assertEquals(tbl{2,'domain_type'}{1}, 'relaxed');
                t.assertEquals(tbl{2,'domain'}{1}, '[dim_1]');
                t.assertEquals(tbl{2,'size'}{1}, '[5]');
            end
            switch i
            case {1,2}
                t.assert(tbl{2,'num_recs'} == 3);
                t.assert(tbl{2,'num_vals'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
            case 3
                t.assert(isnan(tbl{2,'num_recs'}));
                t.assert(tbl{2,'num_vals'} == 5);
                t.assert(tbl{2,'sparsity'} == 0);
            case 4
                t.assert(isnan(tbl{2,'num_recs'}));
                t.assert(tbl{2,'num_vals'} == 3);
                t.assert(tbl{2,'sparsity'} == 0.4);
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
            if gdx.features.categorical
                t.assertEquals(tbl{2,'where_max_abs_value'}, '[5]');
            else
                t.assertEquals(tbl{2,'where_max_abs_value'}{1}, '[5]');
            end
            t.assert(tbl{2,'count_na'} == 0);
            t.assert(tbl{2,'count_undef'} == 0);
            t.assert(tbl{2,'count_eps'} == 0);
            if gdx.features.categorical
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
            else
                t.assertEquals(tbl{3,'name'}{1}, 'c');
                switch i
                case 1
                    t.assertEquals(tbl{3,'format'}{1}, 'struct');
                case 2
                    t.assertEquals(tbl{3,'format'}{1}, 'table');
                case 3
                    t.assertEquals(tbl{3,'format'}{1}, 'dense_matrix');
                case 4
                    t.assertEquals(tbl{3,'format'}{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl{3,'dim'} == 2);
            if gdx.features.categorical
                t.assertEquals(tbl{3,'domain_type'}, 'relaxed');
                t.assertEquals(tbl{3,'domain'}, '[dim_1,dim_2]');
                t.assertEquals(tbl{3,'size'}, '[5,10]');
            else
                t.assertEquals(tbl{3,'domain_type'}{1}, 'relaxed');
                t.assertEquals(tbl{3,'domain'}{1}, '[dim_1,dim_2]');
                t.assertEquals(tbl{3,'size'}{1}, '[5,10]');
            end
            switch i
            case {1,2}
                t.assert(tbl{3,'num_recs'} == 3);
                t.assert(tbl{3,'num_vals'} == 3);
                t.assert(tbl{3,'sparsity'} == 0.94);
            case 3
                t.assert(isnan(tbl{3,'num_recs'}));
                t.assert(tbl{3,'num_vals'} == 50);
                t.assert(tbl{3,'sparsity'} == 0);
            case 4
                t.assert(isnan(tbl{3,'num_recs'}));
                t.assert(tbl{3,'num_vals'} == 3);
                t.assert(tbl{3,'sparsity'} == 0.94);
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
            if gdx.features.categorical
                t.assertEquals(tbl{3,'where_max_abs_value'}, '[4,9]');
            else
                t.assertEquals(tbl{3,'where_max_abs_value'}{1}, '[4,9]');
            end
            t.assert(tbl{3,'count_na'} == 0);
            t.assert(tbl{3,'count_undef'} == 0);
            t.assert(tbl{3,'count_eps'} == 0);
        else
            t.assert(isstruct(tbl));
            t.assert(numel(fieldnames(tbl)) == 16);
            t.assert(numel(tbl.name) == 3);
            t.assert(isfield(tbl, 'name'));
            t.assert(isfield(tbl, 'format'));
            t.assert(isfield(tbl, 'dim'));
            t.assert(isfield(tbl, 'domain_type'));
            t.assert(isfield(tbl, 'domain'));
            t.assert(isfield(tbl, 'size'));
            t.assert(isfield(tbl, 'num_recs'));
            t.assert(isfield(tbl, 'num_vals'));
            t.assert(isfield(tbl, 'sparsity'));
            t.assert(isfield(tbl, 'min_value'));
            t.assert(isfield(tbl, 'mean_value'));
            t.assert(isfield(tbl, 'max_value'));
            t.assert(isfield(tbl, 'where_max_abs_value'));
            t.assert(isfield(tbl, 'count_na'));
            t.assert(isfield(tbl, 'count_undef'));
            t.assert(isfield(tbl, 'count_eps'));
            if gdx.features.categorical
                t.assertEquals(tbl.name(1), 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl.format(1), 'struct') || isequal(tbl.format(1), 'dense_matrix'));
                case 2
                    t.assertEquals(tbl.format(1), 'table');
                case 4
                    t.assertEquals(tbl.format(1), 'sparse_matrix');
                end
            else
                t.assertEquals(tbl.name{1}, 'a');
                switch i
                case {1,3}
                    t.assert(isequal(tbl.format{1}, 'struct') || isequal(tbl.format{1}, 'dense_matrix'));
                case 2
                    t.assertEquals(tbl.format{1}, 'table');
                case 4
                    t.assertEquals(tbl.format{1}, 'sparse_matrix');
                end
            end
            t.assert(tbl.dim(1) == 0);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(1), 'relaxed');
                t.assertEquals(tbl.domain(1), '[]');
                t.assertEquals(tbl.size(1), '[]');
            else
                t.assertEquals(tbl.domain_type{1}, 'relaxed');
                t.assertEquals(tbl.domain{1}, '[]');
                t.assertEquals(tbl.size{1}, '[]');
            end
            switch i
            case {1,2,3}
                t.assert(tbl.num_recs(1) == 1);
            case 4
                t.assert(isnan(tbl.num_recs(1)));
            end
            t.assert(tbl.num_vals(1) == 1);
            t.assert(tbl.sparsity(1) == 0);
            t.assert(tbl.min_value(1) == 4);
            t.assert(tbl.mean_value(1) == 4);
            t.assert(tbl.max_value(1) == 4);
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_value(1), '[]');
            else
                t.assertEquals(tbl.where_max_abs_value{1}, '[]');
            end
            t.assert(tbl.count_na(1) == 0);
            t.assert(tbl.count_undef(1) == 0);
            t.assert(tbl.count_eps(1) == 0);
            if gdx.features.categorical
                t.assertEquals(tbl.name(2), 'b');
                switch i
                case 1
                    t.assertEquals(tbl.format(2), 'struct');
                case 2
                    t.assertEquals(tbl.format(2), 'table');
                case 3
                    t.assertEquals(tbl.format(2), 'dense_matrix');
                case 4
                    t.assertEquals(tbl.format(2), 'sparse_matrix');
                end
            else
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
            end
            t.assert(tbl.dim(2) == 1);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(2), 'relaxed');
                t.assertEquals(tbl.domain(2), '[dim_1]');
                t.assertEquals(tbl.size(2), '[5]');
            else
                t.assertEquals(tbl.domain_type{2}, 'relaxed');
                t.assertEquals(tbl.domain{2}, '[dim_1]');
                t.assertEquals(tbl.size{2}, '[5]');
            end
            switch i
            case {1,2}
                t.assert(tbl.num_recs(2) == 3);
                t.assert(tbl.num_vals(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
            case 3
                t.assert(isnan(tbl.num_recs(2)));
                t.assert(tbl.num_vals(2) == 5);
                t.assert(tbl.sparsity(2) == 0);
            case 4
                t.assert(isnan(tbl.num_recs(2)));
                t.assert(tbl.num_vals(2) == 3);
                t.assert(tbl.sparsity(2) == 0.4);
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
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_value(2), '[5]');
            else
                t.assertEquals(tbl.where_max_abs_value{2}, '[5]');
            end
            t.assert(tbl.count_na(2) == 0);
            t.assert(tbl.count_undef(2) == 0);
            t.assert(tbl.count_eps(2) == 0);
            if gdx.features.categorical
                t.assertEquals(tbl.name(3), 'c');
                switch i
                case 1
                    t.assertEquals(tbl.format(3), 'struct');
                case 2
                    t.assertEquals(tbl.format(3), 'table');
                case 3
                    t.assertEquals(tbl.format(3), 'dense_matrix');
                case 4
                    t.assertEquals(tbl.format(3), 'sparse_matrix');
                end
            else
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
            end
            t.assert(tbl.dim(3) == 2);
            if gdx.features.categorical
                t.assertEquals(tbl.domain_type(3), 'relaxed');
                t.assertEquals(tbl.domain(3), '[dim_1,dim_2]');
                t.assertEquals(tbl.size(3), '[5,10]');
            else
                t.assertEquals(tbl.domain_type{3}, 'relaxed');
                t.assertEquals(tbl.domain{3}, '[dim_1,dim_2]');
                t.assertEquals(tbl.size{3}, '[5,10]');
            end
            switch i
            case {1,2}
                t.assert(tbl.num_recs(3) == 3);
                t.assert(tbl.num_vals(3) == 3);
                t.assert(tbl.sparsity(3) == 0.94);
            case 3
                t.assert(isnan(tbl.num_recs(3)));
                t.assert(tbl.num_vals(3) == 50);
                t.assert(tbl.sparsity(3) == 0);
            case 4
                t.assert(isnan(tbl.num_recs(3)));
                t.assert(tbl.num_vals(3) == 3);
                t.assert(tbl.sparsity(3) == 0.94);
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
            if gdx.features.categorical
                t.assertEquals(tbl.where_max_abs_value(3), '[4,9]');
            else
                t.assertEquals(tbl.where_max_abs_value{3}, '[4,9]');
            end
            t.assert(tbl.count_na(3) == 0);
            t.assert(tbl.count_undef(3) == 0);
            t.assert(tbl.count_eps(3) == 0);
        end
    end
end

function test_const2standard(t, cfg)

    t.add('const2standard_no_idx_no_idx');
    try
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{1}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    catch
        t.assert(false);
    end

    t.add('const2standard_idx_idx');
    try
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{4}, 'indexed', true, ...
            'gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'indexed', true, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    catch
        t.assert(false);
    end

    t.add('const2standard_no_idx_idx');
    try
        t.assert(false);
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{1}, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'indexed', true, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Indexed flags of source and this container must match.');
    end

    t.add('const2standard_idx_no_idx');
    try
        t.assert(false);
        gdx = GAMSTransfer.ConstContainer(cfg.filenames{4}, 'indexed', true, ...
            'gams_dir', cfg.gams_dir, 'features', cfg.features);
        gdx = GAMSTransfer.Container(gdx, 'gams_dir', ...
            cfg.gams_dir, 'features', cfg.features);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Indexed flags of source and this container must match.');
    end

end

function test_remove(t, cfg)

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'features', cfg.features);
    i1 = GAMSTransfer.Set(gdx, 'i1');
    a1 = GAMSTransfer.Alias(gdx, 'a1', i1);
    x1 = GAMSTransfer.Variable(gdx, 'x1', 'free', {i1});

    t.add('remove_1');
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i1'));
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(x1.isValid());
    gdx.removeSymbols('i1');
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(~i1.isValid());
    t.assert(~a1.isValid());
    t.assert(~x1.isValid());

    t.add('remove_2');
    gdx.removeSymbols({'i1', 'a1', 'x1'});
    t.assert(numel(fieldnames(gdx.data)) == 0)
    t.assert(~i1.isValid());
    t.assert(~a1.isValid());
    t.assert(~x1.isValid());

    gdx = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
        'features', cfg.features);
    i1 = GAMSTransfer.Set(gdx, 'i1');
    a1 = GAMSTransfer.Alias(gdx, 'a1', i1);
    x1 = GAMSTransfer.Variable(gdx, 'x1', 'free', {i1});

    t.add('remove_diffcase_1');
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 'i1'));
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(x1.isValid());
    gdx.removeSymbols('I1');
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(~i1.isValid());
    t.assert(~a1.isValid());
    t.assert(~x1.isValid());

    t.add('remove_diffcase_2');
    gdx.removeSymbols({'I1', 'A1', 'X1'});
    t.assert(numel(fieldnames(gdx.data)) == 0)
    t.assert(~i1.isValid());
    t.assert(~a1.isValid());
    t.assert(~x1.isValid());

end
