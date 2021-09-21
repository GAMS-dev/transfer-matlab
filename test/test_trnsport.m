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

function success = test_trnsport(cfg)
    t = GAMSTest('GAMSTransfer/trnsport');

    geps = GAMSTransfer.SpecialValues.EPS;

    for k = 1:3
        if k == 1
            m = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
                'features', cfg.features);
            i = GAMSTransfer.Set(m, 'i', ...
                'records', {'seattle', 'san-diego'}, ...
                'description', 'canning plants');
            j = GAMSTransfer.Set(m, 'j', ...
                'records', {'new-york', 'chicago', 'topeka'}, ...
                'description', 'markets');
            a = GAMSTransfer.Parameter(m, 'a', i, ...
                'records', [350, 600], ...
                'description', 'capacity of plant i in cases');
            b = GAMSTransfer.Parameter(m, 'b', j, ...
                'records', [325, 300, 275], ...
                'description', 'demand at market j in cases');
            d = GAMSTransfer.Parameter(m, 'd', {i,j}, ...
                'records', [2.5, 1.7, 1.8; 2.5, 1.8, 1.4], ...
                'description', 'distance in thousands of miles');
            f = GAMSTransfer.Parameter(m, 'f', ...
                'records', 90, ...
                'description', 'freight in dollars per case per thousand miles');
            c = GAMSTransfer.Parameter(m, 'c', {i,j}, ...
                'records', [0.225, 0.153, 0.162; 0.225, 0.162, 0.126], ...
                'description', 'transport cost in thousands of dollars per case');
            x = GAMSTransfer.Variable(m, 'x', 'positive', {i,j}, ...
                'records', {[50, 300, 0; 275, 0, 275], [0, 0, 0.036; 0, 0.009, 0]}, ...
                'description', 'shipment quantities in cases');
            z = GAMSTransfer.Variable(m, 'z', ...
                'records', 153.675, ...
                'description', 'total transportation costs in thousands of dollars');
            cost = GAMSTransfer.Equation(m, 'cost', 'e', {}, ...
                'records', {0, 1, 0, 0}, ...
                'description', 'define objective function');
            supply = GAMSTransfer.Equation(m, 'supply', 'l', i, ...
                'records', struct('level', [350, 550], 'marginal', [geps, 0], 'upper', [350, 600]), ...
                'description', 'observe supply limit at plant i');
            demand = GAMSTransfer.Equation(m, 'demand', 'g', j, ...
                'records', {[325, 300, 275], [0.225, 0.153, 0.126], [325, 300, 275]}, ...
                'description', 'satisfy demand at market j');
        elseif k == 2
            m = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
                'features', cfg.features);
            i = GAMSTransfer.Set(m, 'i', 'description', 'canning plants');
            i.setRecords({'seattle', 'san-diego'});
            j = GAMSTransfer.Set(m, 'j', 'description', 'markets');
            j.setRecords({'new-york', 'chicago', 'topeka'});
            a = GAMSTransfer.Parameter(m, 'a', i, 'description', 'capacity of plant i in cases');
            a.setRecords([350, 600]);
            b = GAMSTransfer.Parameter(m, 'b', j, 'description', 'demand at market j in cases');
            b.setRecords([325, 300, 275]);
            d = GAMSTransfer.Parameter(m, 'd', {i,j}, 'description', 'distance in thousands of miles');
            d.setRecords([2.5, 1.7, 1.8; 2.5, 1.8, 1.4]);
            f = GAMSTransfer.Parameter(m, 'f', 'description', 'freight in dollars per case per thousand miles');
            f.setRecords(90);
            c = GAMSTransfer.Parameter(m, 'c', {i,j}, 'description', 'transport cost in thousands of dollars per case');
            c.setRecords([0.225, 0.153, 0.162; 0.225, 0.162, 0.126]);
            x = GAMSTransfer.Variable(m, 'x', 'positive', {i,j}, 'description', 'shipment quantities in cases');
            x.setRecords([50, 300, 0; 275, 0, 275], [0, 0, 0.036; 0, 0.009, 0]);
            z = GAMSTransfer.Variable(m, 'z', 'description', 'total transportation costs in thousands of dollars');
            z.setRecords(153.675);
            cost = GAMSTransfer.Equation(m, 'cost', 'e', 'description', 'define objective function');
            cost.setRecords(0, 1, 0, 0);
            supply = GAMSTransfer.Equation(m, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
            supply.setRecords(struct('level', [350, 550], 'marginal', [geps, 0], 'upper', [350, 600]));
            demand = GAMSTransfer.Equation(m, 'demand', 'g', j, 'description', 'satisfy demand at market j');
            demand.setRecords([325, 300, 275], [0.225, 0.153, 0.126], [325, 300, 275]);
        elseif k == 3
            m = GAMSTransfer.Container('gams_dir', cfg.gams_dir, ...
                'features', cfg.features);
            i = GAMSTransfer.Set(m, 'i', 'description', 'canning plants');
            if m.features.categorical
                i.records = struct('uni_1', categorical({'seattle'; 'san-diego'}, ...
                    {'seattle'; 'san-diego'}));
            else
                i.records = struct('uni_1', (1:2)');
                i.initUELs(1, {'seattle'; 'san-diego'});
            end
            j = GAMSTransfer.Set(m, 'j', 'description', 'markets');
            if m.features.categorical
                j.records = struct('uni_1', categorical({'new-york'; 'chicago'; 'topeka'}, ...
                    {'new-york'; 'chicago'; 'topeka'}));
            else
                j.records = struct('uni_1', (1:3)');
                j.initUELs(1, {'new-york'; 'chicago'; 'topeka'});
            end
            a = GAMSTransfer.Parameter(m, 'a', i, 'description', 'capacity of plant i in cases');
            a.records = struct('value', [350; 600]);
            b = GAMSTransfer.Parameter(m, 'b', j, 'description', 'demand at market j in cases');
            b.records = struct('value', [325; 300; 275]);
            d = GAMSTransfer.Parameter(m, 'd', {i,j}, 'description', 'distance in thousands of miles');
            d.records = struct('value', [2.5, 1.7, 1.8; 2.5, 1.8, 1.4]);
            f = GAMSTransfer.Parameter(m, 'f', 'description', 'freight in dollars per case per thousand miles');
            f.records = struct('value', 90);
            c = GAMSTransfer.Parameter(m, 'c', {i,j}, 'description', 'transport cost in thousands of dollars per case');
            c.records = struct('value', [0.225, 0.153, 0.162; 0.225, 0.162, 0.126]);
            x = GAMSTransfer.Variable(m, 'x', 'positive', {i,j}, 'description', 'shipment quantities in cases');
            x.records = struct('level', [50, 300, 0; 275, 0, 275], 'marginal', [0, 0, 0.036; 0, 0.009, 0]);
            z = GAMSTransfer.Variable(m, 'z', 'description', 'total transportation costs in thousands of dollars');
            z.records = struct('level', 153.675);
            cost = GAMSTransfer.Equation(m, 'cost', 'e', 'description', 'define objective function');
            cost.records = struct('level', 0, 'marginal', 1, 'lower', 0, 'upper', 0);
            supply = GAMSTransfer.Equation(m, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
            supply.records = struct('level', [350; 550], 'marginal', [geps; 0], 'upper', [350; 600]);
            demand = GAMSTransfer.Equation(m, 'demand', 'g', j, 'description', 'satisfy demand at market j');
            demand.records = struct('level', [325; 300; 275], 'marginal', [0.225; 0.153; 0.126], 'lower', [325; 300; 275]);
        elseif k == 4
            m = GAMSTransfer.Container(fullfile(cfg.working_dir, 'write_trnsport_1.gdx'), ...
                'gams_dir', cfg.gams_dir, 'features', cfg.features);
        elseif k == 5
            m = GAMSTransfer.Container(fullfile(cfg.working_dir, 'write_trnsport_2.gdx'), ...
                'gams_dir', cfg.gams_dir, 'features', cfg.features);
        elseif k == 6
            m = GAMSTransfer.Container(fullfile(cfg.working_dir, 'write_trnsport_3.gdx'), ...
                'gams_dir', cfg.gams_dir, 'features', cfg.features);
        end

        if k == 4 || k == 5 || k == 6
            m.read('format', 'dense_matrix', 'symbols', {'i', 'j'}, 'values', {});
            m.read('format', 'dense_matrix', 'symbols', {'a', 'b', 'd', 'f', 'c'});
            m.read('format', 'dense_matrix', 'symbols', {'x'}, 'values', {'level', 'marginal'});
            m.read('format', 'dense_matrix', 'symbols', {'z'}, 'values', {'level'});
            m.read('format', 'dense_matrix', 'symbols', {'cost'}, 'values', {'level', 'marginal', 'lower', 'upper'});
            m.read('format', 'dense_matrix', 'symbols', {'supply'}, 'values', {'level', 'marginal', 'upper'});
            m.read('format', 'dense_matrix', 'symbols', {'demand'}, 'values', {'level', 'marginal', 'lower'});
            i = m.data.i;
            j = m.data.j;
            a = m.data.a;
            b = m.data.b;
            d = m.data.d;
            f = m.data.f;
            c = m.data.c;
            x = m.data.x;
            z = m.data.z;
            cost = m.data.cost;
            supply = m.data.supply;
            demand = m.data.demand;
        end

        t.add(sprintf('test_trnsport_symbols_%d', k));
        t.assert(isstruct(m.data));
        t.assert(numel(fieldnames(m.data)) == 12);
        t.assert(isfield(m.data, 'i'));
        t.assert(isfield(m.data, 'j'));
        t.assert(isfield(m.data, 'a'));
        t.assert(isfield(m.data, 'b'));
        t.assert(isfield(m.data, 'd'));
        t.assert(isfield(m.data, 'f'));
        t.assert(isfield(m.data, 'c'));
        t.assert(isfield(m.data, 'x'));
        t.assert(isfield(m.data, 'z'));
        t.assert(isfield(m.data, 'cost'));
        t.assert(isfield(m.data, 'supply'));
        t.assert(isfield(m.data, 'demand'));

        t.add(sprintf('test_trnsport_symbol_i_%d', k));
        t.assert(isa(i, 'GAMSTransfer.Set'));
        t.assertEquals(i.name, 'i');
        t.assertEquals(i.description, 'canning plants');
        t.assert(~i.is_singleton);
        t.assert(i.dimension == 1);
        t.assert(numel(i.domain) == 1);
        t.assertEquals(i.domain{1}, '*');
        t.assert(numel(i.domain_labels) == 1);
        t.assertEquals(i.domain_labels{1}, 'uni_1');
        t.assertEquals(i.domain_info, 'none');
        t.assert(numel(i.size) == 1);
        t.assert(isnan(i.size));
        t.assert(i.isValid());
        t.assertEquals(i.format, 'struct');
        t.assert(i.getNumberRecords() == 2);
        t.assert(isstruct(i.records));
        t.assert(numel(fieldnames(i.records)) == 1);
        t.assert(isfield(i.records, 'uni_1'));
        t.assert(numel(i.records.uni_1) == 2);
        if m.features.categorical
            t.assertEquals(i.records.uni_1(1), 'seattle');
            t.assertEquals(i.records.uni_1(2), 'san-diego');
        else
            t.assert(i.records.uni_1(1) == 1);
            t.assert(i.records.uni_1(2) == 2);
        end
        uels = i.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');

        t.add(sprintf('test_trnsport_symbol_j_%d', k));
        t.assert(isa(j, 'GAMSTransfer.Set'));
        t.assertEquals(j.name, 'j');
        t.assertEquals(j.description, 'markets');
        t.assert(~j.is_singleton);
        t.assert(j.dimension == 1);
        t.assert(numel(j.domain) == 1);
        t.assertEquals(j.domain{1}, '*');
        t.assert(numel(j.domain_labels) == 1);
        t.assertEquals(j.domain_labels{1}, 'uni_1');
        t.assertEquals(j.domain_info, 'none');
        t.assert(numel(j.size) == 1);
        t.assert(isnan(j.size));
        t.assert(j.isValid());
        t.assertEquals(j.format, 'struct');
        t.assert(j.getNumberRecords() == 3);
        t.assert(isstruct(j.records));
        t.assert(numel(fieldnames(j.records)) == 1);
        t.assert(isfield(j.records, 'uni_1'));
        t.assert(numel(j.records.uni_1) == 3);
        if m.features.categorical
            t.assertEquals(j.records.uni_1(1), 'new-york');
            t.assertEquals(j.records.uni_1(2), 'chicago');
            t.assertEquals(j.records.uni_1(3), 'topeka');
        else
            t.assert(j.records.uni_1(1) == 1);
            t.assert(j.records.uni_1(2) == 2);
            t.assert(j.records.uni_1(3) == 3);
        end
        uels = j.getUELs(1);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        t.add(sprintf('test_trnsport_symbol_a_%d', k));
        t.assert(isa(a, 'GAMSTransfer.Parameter'));
        t.assertEquals(a.name, 'a');
        t.assertEquals(a.description, 'capacity of plant i in cases');
        t.assert(a.dimension == 1);
        t.assert(numel(a.domain) == 1);
        t.assertEquals(a.domain{1}.id, i.id);
        t.assertEquals(a.domain{1}.name, 'i');
        t.assert(numel(a.domain_labels) == 1);
        t.assertEquals(a.domain_labels{1}, 'i_1');
        t.assertEquals(a.domain_info, 'regular');
        t.assert(numel(a.size) == 1);
        t.assert(a.size == 2);
        t.assert(a.isValid());
        t.assertEquals(a.format, 'dense_matrix');
        t.assert(isnan(a.getNumberRecords()));
        t.assert(a.getNumberValues() == 2);
        t.assert(isstruct(a.records));
        t.assert(numel(fieldnames(a.records)) == 1);
        t.assert(isfield(a.records, 'value'));
        t.assert(numel(a.records.value) == 2);
        t.assert(a.records.value(1) == 350);
        t.assert(a.records.value(2) == 600);
        uels = a.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');

        t.add(sprintf('test_trnsport_symbol_b_%d', k));
        t.assert(isa(b, 'GAMSTransfer.Parameter'));
        t.assertEquals(b.name, 'b');
        t.assertEquals(b.description, 'demand at market j in cases');
        t.assert(b.dimension == 1);
        t.assert(numel(b.domain) == 1);
        t.assertEquals(b.domain{1}.id, j.id);
        t.assertEquals(b.domain{1}.name, 'j');
        t.assert(numel(b.domain_labels) == 1);
        t.assertEquals(b.domain_labels{1}, 'j_1');
        t.assertEquals(b.domain_info, 'regular');
        t.assert(numel(b.size) == 1);
        t.assert(b.size == 3);
        t.assert(b.isValid());
        t.assertEquals(b.format, 'dense_matrix');
        t.assert(isnan(b.getNumberRecords()));
        t.assert(b.getNumberValues() == 3);
        t.assert(isstruct(b.records));
        t.assert(numel(fieldnames(b.records)) == 1);
        t.assert(isfield(b.records, 'value'));
        t.assert(numel(b.records.value) == 3);
        t.assert(b.records.value(1) == 325);
        t.assert(b.records.value(2) == 300);
        t.assert(b.records.value(3) == 275);
        uels = b.getUELs(1);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        t.add(sprintf('test_trnsport_symbol_d_%d', k));
        t.assert(isa(d, 'GAMSTransfer.Parameter'));
        t.assertEquals(d.name, 'd');
        t.assertEquals(d.description, 'distance in thousands of miles');
        t.assert(d.dimension == 2);
        t.assert(numel(d.domain) == 2);
        t.assertEquals(d.domain{1}.id, i.id);
        t.assertEquals(d.domain{2}.id, j.id);
        t.assertEquals(d.domain{1}.name, 'i');
        t.assertEquals(d.domain{2}.name, 'j');
        t.assert(numel(d.domain_labels) == 2);
        t.assertEquals(d.domain_labels{1}, 'i_1');
        t.assertEquals(d.domain_labels{2}, 'j_2');
        t.assertEquals(d.domain_info, 'regular');
        t.assert(numel(d.size) == 2);
        t.assert(all(d.size == [2,3]));
        t.assert(d.isValid());
        t.assertEquals(d.format, 'dense_matrix');
        t.assert(isnan(d.getNumberRecords()));
        t.assert(d.getNumberValues() == 6);
        t.assert(isstruct(d.records));
        t.assert(numel(fieldnames(d.records)) == 1);
        t.assert(isfield(d.records, 'value'));
        t.assert(numel(d.records.value) == 6);
        t.assert(d.records.value(1,1) == 2.5);
        t.assert(d.records.value(1,2) == 1.7);
        t.assert(d.records.value(1,3) == 1.8);
        t.assert(d.records.value(2,1) == 2.5);
        t.assert(d.records.value(2,2) == 1.8);
        t.assert(d.records.value(2,3) == 1.4);
        uels = d.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');
        uels = d.getUELs(2);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        t.add(sprintf('test_trnsport_symbol_f_%d', k));
        t.assert(isa(f, 'GAMSTransfer.Parameter'));
        t.assertEquals(f.name, 'f');
        t.assertEquals(f.description, 'freight in dollars per case per thousand miles');
        t.assert(f.dimension == 0);
        t.assert(numel(f.domain) == 0);
        t.assert(numel(f.domain_labels) == 0);
        t.assertEquals(f.domain_info, 'none');
        t.assert(numel(f.size) == 0);
        t.assert(f.isValid());
        t.assertEquals(f.format, 'struct');
        t.assert(f.getNumberRecords() == 1);
        t.assert(f.getNumberValues() == 1);
        t.assert(isstruct(f.records));
        t.assert(numel(fieldnames(f.records)) == 1);
        t.assert(isfield(f.records, 'value'));
        t.assert(numel(f.records.value) == 1);
        t.assert(f.records.value(1) == 90);

        t.add(sprintf('test_trnsport_symbol_c_%d', k));
        t.assert(isa(c, 'GAMSTransfer.Parameter'));
        t.assertEquals(c.name, 'c');
        t.assertEquals(c.description, 'transport cost in thousands of dollars per case');
        t.assert(c.dimension == 2);
        t.assert(numel(c.domain) == 2);
        t.assertEquals(c.domain{1}.id, i.id);
        t.assertEquals(c.domain{2}.id, j.id);
        t.assertEquals(c.domain{1}.name, 'i');
        t.assertEquals(c.domain{2}.name, 'j');
        t.assert(numel(c.domain_labels) == 2);
        t.assertEquals(c.domain_labels{1}, 'i_1');
        t.assertEquals(c.domain_labels{2}, 'j_2');
        t.assertEquals(c.domain_info, 'regular');
        t.assert(numel(c.size) == 2);
        t.assert(all(c.size == [2,3]));
        t.assert(c.isValid());
        t.assertEquals(c.format, 'dense_matrix');
        t.assert(isnan(c.getNumberRecords()));
        t.assert(c.getNumberValues() == 6);
        t.assert(isstruct(c.records));
        t.assert(numel(fieldnames(c.records)) == 1);
        t.assert(isfield(c.records, 'value'));
        t.assert(numel(c.records.value) == 6);
        t.assert(c.records.value(1,1) == 0.225);
        t.assert(c.records.value(1,2) == 0.153);
        t.assert(c.records.value(1,3) == 0.162);
        t.assert(c.records.value(2,1) == 0.225);
        t.assert(c.records.value(2,2) == 0.162);
        t.assert(c.records.value(2,3) == 0.126);
        uels = c.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');
        uels = c.getUELs(2);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        t.add(sprintf('test_trnsport_symbol_x_%d', k));
        t.assert(isa(x, 'GAMSTransfer.Variable'));
        t.assertEquals(x.name, 'x');
        t.assertEquals(x.description, 'shipment quantities in cases');
        t.assert(x.dimension == 2);
        t.assert(numel(x.domain) == 2);
        t.assertEquals(x.domain{1}.id, i.id);
        t.assertEquals(x.domain{2}.id, j.id);
        t.assertEquals(x.domain{1}.name, 'i');
        t.assertEquals(x.domain{2}.name, 'j');
        t.assert(numel(x.domain_labels) == 2);
        t.assertEquals(x.domain_labels{1}, 'i_1');
        t.assertEquals(x.domain_labels{2}, 'j_2');
        t.assertEquals(x.domain_info, 'regular');
        t.assert(numel(x.size) == 2);
        t.assert(all(x.size == [2,3]));
        t.assert(x.isValid());
        t.assertEquals(x.format, 'dense_matrix');
        t.assert(isnan(x.getNumberRecords()));
        t.assert(x.getNumberValues() == 12);
        t.assert(isstruct(x.records));
        t.assert(numel(fieldnames(x.records)) == 2);
        t.assert(isfield(x.records, 'level'));
        t.assert(isfield(x.records, 'marginal'));
        t.assert(numel(x.records.level) == 6);
        t.assert(x.records.level(1,1) == 50);
        t.assert(x.records.level(1,2) == 300);
        t.assert(x.records.level(1,3) == 0);
        t.assert(x.records.level(2,1) == 275);
        t.assert(x.records.level(2,2) == 0);
        t.assert(x.records.level(2,3) == 275);
        t.assert(numel(x.records.marginal) == 6);
        t.assert(x.records.marginal(1,1) == 0);
        t.assert(x.records.marginal(1,2) == 0);
        t.assert(x.records.marginal(1,3) == 0.036);
        t.assert(x.records.marginal(2,1) == 0);
        t.assert(x.records.marginal(2,2) == 0.009);
        t.assert(x.records.marginal(2,3) == 0);
        uels = x.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');
        uels = x.getUELs(2);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        t.add(sprintf('test_trnsport_symbol_z_%d', k));
        t.assert(isa(z, 'GAMSTransfer.Variable'));
        t.assertEquals(z.name, 'z');
        t.assertEquals(z.description, 'total transportation costs in thousands of dollars');
        t.assert(z.dimension == 0);
        t.assert(numel(z.domain) == 0);
        t.assert(numel(z.domain_labels) == 0);
        t.assertEquals(z.domain_info, 'none');
        t.assert(numel(z.size) == 0);
        t.assert(z.isValid());
        t.assertEquals(z.format, 'struct');
        t.assert(z.getNumberRecords() == 1);
        t.assert(z.getNumberValues() == 1);
        t.assert(isstruct(z.records));
        t.assert(numel(fieldnames(z.records)) == 1);
        t.assert(isfield(z.records, 'level'));
        t.assert(numel(z.records.level) == 1);
        t.assert(z.records.level(1) == 153.675);

        t.add(sprintf('test_trnsport_symbol_cost_%d', k));
        t.assert(isa(cost, 'GAMSTransfer.Equation'));
        t.assertEquals(cost.name, 'cost');
        t.assertEquals(cost.description, 'define objective function');
        t.assert(cost.dimension == 0);
        t.assert(numel(cost.domain) == 0);
        t.assert(numel(cost.domain_labels) == 0);
        t.assertEquals(cost.domain_info, 'none');
        t.assert(numel(cost.size) == 0);
        t.assert(cost.isValid());
        t.assertEquals(cost.format, 'struct');
        t.assert(cost.getNumberRecords() == 1);
        t.assert(cost.getNumberValues() == 4);
        t.assert(isstruct(cost.records));
        t.assert(numel(fieldnames(cost.records)) == 4);
        t.assert(isfield(cost.records, 'level'));
        t.assert(isfield(cost.records, 'marginal'));
        t.assert(isfield(cost.records, 'lower'));
        t.assert(isfield(cost.records, 'upper'));
        t.assert(numel(cost.records.level) == 1);
        t.assert(numel(cost.records.marginal) == 1);
        t.assert(numel(cost.records.lower) == 1);
        t.assert(numel(cost.records.upper) == 1);
        t.assert(cost.records.level(1) == 0);
        t.assert(cost.records.marginal(1) == 1);
        t.assert(cost.records.lower(1) == 0);
        t.assert(cost.records.upper(1) == 0);

        t.add(sprintf('test_trnsport_symbol_supply_%d', k));
        t.assert(isa(supply, 'GAMSTransfer.Equation'));
        t.assertEquals(supply.name, 'supply');
        t.assertEquals(supply.description, 'observe supply limit at plant i');
        t.assert(supply.dimension == 1);
        t.assert(numel(supply.domain) == 1);
        t.assertEquals(supply.domain{1}.id, i.id);
        t.assertEquals(supply.domain{1}.name, 'i');
        t.assert(numel(supply.domain_labels) == 1);
        t.assertEquals(supply.domain_labels{1}, 'i_1');
        t.assertEquals(supply.domain_info, 'regular');
        t.assert(numel(supply.size) == 1);
        t.assert(supply.size == 2);
        t.assert(supply.isValid());
        t.assertEquals(supply.format, 'dense_matrix');
        t.assert(isnan(supply.getNumberRecords()));
        t.assert(supply.getNumberValues() == 6);
        t.assert(isstruct(supply.records));
        t.assert(numel(fieldnames(supply.records)) == 3);
        t.assert(isfield(supply.records, 'level'));
        t.assert(isfield(supply.records, 'marginal'));
        t.assert(isfield(supply.records, 'upper'));
        t.assert(numel(supply.records.level) == 2);
        t.assert(numel(supply.records.marginal) == 2);
        t.assert(numel(supply.records.upper) == 2);
        t.assert(supply.records.level(1) == 350);
        t.assert(supply.records.level(2) == 550);
        t.assert(GAMSTransfer.SpecialValues.isEps(supply.records.marginal(1)));
        t.assert(supply.records.marginal(2) == 0);
        t.assert(supply.records.upper(1) == 350);
        t.assert(supply.records.upper(2) == 600);
        uels = supply.getUELs(1);
        t.assert(numel(uels) == 2);
        t.assertEquals(uels{1}, 'seattle');
        t.assertEquals(uels{2}, 'san-diego');

        t.add(sprintf('test_trnsport_symbol_demand_%d', k));
        t.assert(isa(demand, 'GAMSTransfer.Equation'));
        t.assertEquals(demand.name, 'demand');
        t.assertEquals(demand.description, 'satisfy demand at market j');
        t.assert(demand.dimension == 1);
        t.assert(numel(demand.domain) == 1);
        t.assertEquals(demand.domain{1}.id, j.id);
        t.assertEquals(demand.domain{1}.name, 'j');
        t.assert(numel(demand.domain_labels) == 1);
        t.assertEquals(demand.domain_labels{1}, 'j_1');
        t.assertEquals(demand.domain_info, 'regular');
        t.assert(numel(demand.size) == 1);
        t.assert(demand.size == 3);
        t.assert(demand.isValid());
        t.assertEquals(demand.format, 'dense_matrix');
        t.assert(isnan(demand.getNumberRecords()));
        t.assert(demand.getNumberValues() == 9);
        t.assert(isstruct(demand.records));
        t.assert(numel(fieldnames(demand.records)) == 3);
        t.assert(isfield(demand.records, 'level'));
        t.assert(isfield(demand.records, 'marginal'));
        t.assert(isfield(demand.records, 'lower'));
        t.assert(numel(demand.records.level) == 3);
        t.assert(numel(demand.records.marginal) == 3);
        t.assert(numel(demand.records.lower) == 3);
        t.assert(demand.records.level(1) == 325);
        t.assert(demand.records.level(2) == 300);
        t.assert(demand.records.level(3) == 275);
        t.assert(demand.records.marginal(1) == 0.225);
        t.assert(demand.records.marginal(2) == 0.153);
        t.assert(demand.records.marginal(3) == 0.126);
        t.assert(demand.records.lower(1) == 325);
        t.assert(demand.records.lower(2) == 300);
        t.assert(demand.records.lower(3) == 275);
        uels = demand.getUELs(1);
        t.assert(numel(uels) == 3);
        t.assertEquals(uels{1}, 'new-york');
        t.assertEquals(uels{2}, 'chicago');
        t.assertEquals(uels{3}, 'topeka');

        if k == 1
            m.write(fullfile(cfg.working_dir, 'write_trnsport_1.gdx'));
        elseif k == 2
            m.write(fullfile(cfg.working_dir, 'write_trnsport_2.gdx'));
        elseif k == 3
            m.write(fullfile(cfg.working_dir, 'write_trnsport_3.gdx'));
        end
    end

    [~, n_fails] = t.summary();
    success = n_fails == 0;
end
