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

function success = test_symbols(cfg)
    t = GAMSTest('symbols');
    test_addSymbols(t, cfg);
    test_overwriteSymbols(t, cfg);
    test_changeSymbol(t, cfg);
    test_copySymbol(t, cfg);
    test_defaultvalues(t, cfg);
    test_domainViolation(t, cfg);
    test_setRecords(t, cfg);
    test_writeUnordered(t, cfg);
    test_reorder(t, cfg);
    test_transformRecords(t, cfg);
    [~, n_fails] = t.summary();
    success = n_fails == 0;
end

function test_addSymbols(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    t.add('add_symbols_set_1');
    s1 = gams.transfer.Set(gdx, 's1');
    t.testEmptySymbol(s1);
    t.assertEquals(s1.name, 's1');
    t.assertEquals(s1.description, '');
    t.assert(~s1.is_singleton);
    t.assert(s1.dimension == 1);
    t.assert(numel(s1.domain) == 1);
    t.assertEquals(s1.domain{1}, '*');
    t.assert(numel(s1.domain_names) == 1);
    t.assertEquals(s1.domain_names{1}, '*');
    t.assert(numel(s1.domain_labels) == 1);
    t.assertEquals(s1.domain_type, 'none');
    t.assert(numel(s1.size) == 1);
    t.assert(s1.size(1) == 0);
    t.assert(strcmp(s1.format, 'struct'));
    t.assert(s1.getNumberRecords() == 0);
    t.assert(numel(s1.getUELs(1)) == 0);
    t.assert(s1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 's1'));
    t.assert(gdx.data.s1 == s1);
    t.assert(s1.modified);

    t.add('add_symbols_set_2');
    s2 = gams.transfer.Set(gdx, 's2', {s1}, 'description', 'descr s2');
    t.testEmptySymbol(s2);
    t.assertEquals(s2.name, 's2');
    t.assertEquals(s2.description, 'descr s2');
    t.assert(~s2.is_singleton);
    t.assert(s2.dimension == 1);
    t.assert(numel(s2.domain) == 1);
    t.assert(s2.domain{1} == s1);
    t.assertEquals(s2.domain{1}.name, 's1');
    t.assert(numel(s2.domain_names) == 1);
    t.assertEquals(s2.domain_names{1}, 's1');
    t.assert(numel(s2.domain_labels) == 1);
    t.assertEquals(s2.domain_type, 'regular');
    t.assert(numel(s2.size) == 1);
    t.assert(s2.size(1) == 0);
    t.assert(strcmp(s2.format, 'struct'));
    t.assert(s2.getNumberRecords() == 0);
    t.assert(numel(s2.getUELs(1)) == 0);
    t.assert(s2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 's2'));
    t.assert(gdx.data.s2 == s2);
    t.assert(s2.modified);

    t.add('add_symbols_set_3');
    s3 = gams.transfer.Set(gdx, 's3', {s1, '*'}, 'is_singleton', true);
    t.testEmptySymbol(s3);
    t.assertEquals(s3.name, 's3');
    t.assertEquals(s3.description, '');
    t.assert(s3.is_singleton);
    t.assert(s3.dimension == 2);
    t.assert(numel(s3.domain) == 2);
    t.assert(s3.domain{1} == s1);
    t.assertEquals(s3.domain{1}.name, 's1');
    t.assertEquals(s3.domain{2}, '*');
    t.assert(numel(s3.domain_names) == 2);
    t.assertEquals(s3.domain_names{1}, 's1');
    t.assertEquals(s3.domain_names{2}, '*');
    t.assert(numel(s3.domain_labels) == 2);
    t.assertEquals(s3.domain_type, 'regular');
    t.assert(numel(s3.size) == 2);
    t.assert(s3.size(1) == 0);
    t.assert(s3.size(2) == 0);
    t.assert(strcmp(s3.format, 'struct'));
    t.assert(s3.getNumberRecords() == 0);
    t.assert(numel(s3.getUELs(1)) == 0);
    t.assert(numel(s3.getUELs(2)) == 0);
    t.assert(s3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 's3'));
    t.assert(gdx.data.s3 == s3);
    t.assert(s3.modified);

    t.add('add_symbols_set_4');
    s4 = gams.transfer.Set(gdx, 's4', s2, 'description', 'descr s4', 'is_singleton', true);
    t.testEmptySymbol(s4);
    t.assertEquals(s4.name, 's4');
    t.assertEquals(s4.description, 'descr s4');
    t.assert(s4.is_singleton);
    t.assert(s4.dimension == 1);
    t.assert(numel(s4.domain) == 1);
    t.assert(s4.domain{1} == s2);
    t.assertEquals(s4.domain{1}.name, 's2');
    t.assert(numel(s4.domain_names) == 1);
    t.assertEquals(s4.domain_names{1}, 's2');
    t.assert(numel(s4.domain_labels) == 1);
    t.assertEquals(s4.domain_type, 'regular');
    t.assert(numel(s4.size) == 1);
    t.assert(s4.size(1) == 0);
    t.assert(strcmp(s4.format, 'struct'));
    t.assert(s4.getNumberRecords() == 0);
    t.assert(numel(s4.getUELs(1)) == 0);
    t.assert(s4.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 4);
    t.assert(isfield(gdx.data, 's4'));
    t.assert(gdx.data.s4 == s4);
    t.assert(s4.modified);

    t.add('add_symbols_set_5');
    s5 = gams.transfer.Set(gdx, 's5', {'s1', s2});
    t.testEmptySymbol(s5);
    t.assertEquals(s5.name, 's5');
    t.assertEquals(s5.description, '');
    t.assert(~s5.is_singleton);
    t.assert(s5.dimension == 2);
    t.assert(numel(s5.domain) == 2);
    t.assert(s5.domain{1} == 's1');
    t.assert(s5.domain{2} == s2);
    t.assertEquals(s5.domain{2}.name, 's2');
    t.assert(numel(s5.domain_names) == 2);
    t.assertEquals(s5.domain_names{1}, 's1');
    t.assertEquals(s5.domain_names{2}, 's2');
    t.assert(numel(s5.domain_labels) == 2);
    t.assertEquals(s5.domain_type, 'relaxed');
    t.assert(numel(s5.size) == 2);
    t.assert(s5.size(1) == 0);
    t.assert(s5.size(2) == 0);
    t.assert(strcmp(s5.format, 'struct'));
    t.assert(s5.getNumberRecords() == 0);
    t.assert(numel(s5.getUELs(1)) == 0);
    t.assert(numel(s5.getUELs(2)) == 0);
    t.assert(s5.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 5);
    t.assert(isfield(gdx.data, 's5'));
    t.assert(gdx.data.s5 == s5);
    t.assert(s5.modified);

    t.add('add_symbols_set_6');
    s6 = gams.transfer.Set(gdx, 's6', 's1');
    t.testEmptySymbol(s6);
    t.assertEquals(s6.name, 's6');
    t.assertEquals(s6.description, '');
    t.assert(~s6.is_singleton);
    t.assert(s6.dimension == 1);
    t.assert(numel(s6.domain) == 1);
    t.assert(s6.domain{1} == 's1');
    t.assert(numel(s6.domain_names) == 1);
    t.assertEquals(s6.domain_names{1}, 's1');
    t.assert(numel(s6.domain_labels) == 1);
    t.assertEquals(s6.domain_type, 'relaxed');
    t.assert(numel(s6.size) == 1);
    t.assert(s6.size(1) == 0);
    t.assert(strcmp(s6.format, 'struct'));
    t.assert(s6.getNumberRecords() == 0);
    t.assert(numel(s6.getUELs(1)) == 0);
    t.assert(s6.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 6);
    t.assert(isfield(gdx.data, 's6'));
    t.assert(gdx.data.s6 == s6);
    t.assert(s6.modified);

    t.add('add_symbols_set_fails');
    try
        t.assert(false);
        gams.transfer.Set(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, 's', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            gams.transfer.Set(gdx, 's', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, 's', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, 's', s1, [], 'is_singleton', 1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, 's', s3);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, repmat('s', [1, 64]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 2) length must be smaller than 64.');
    end
    try
        t.assert(false);
        gams.transfer.Set(gdx, 's', 'description', repmat('d', [1, 256]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 4) length must be smaller than 256.');
    end

    t.add('add_symbols_alias_1');
    a1 = gams.transfer.Alias(gdx, 'a1', s1);
    t.testEmptySymbol(a1);
    t.assertEquals(a1.name, 'a1');
    t.assert(a1.alias_with == s1);
    t.assertEquals(a1.alias_with.name, 's1');
    t.assertEquals(a1.description, '');
    t.assert(~a1.is_singleton);
    t.assert(a1.dimension == 1);
    t.assert(numel(a1.domain) == 1);
    t.assertEquals(a1.domain{1}, '*');
    t.assert(numel(a1.domain_names) == 1);
    t.assertEquals(a1.domain_names{1}, '*');
    t.assert(numel(a1.domain_labels) == 1);
    t.assertEquals(a1.domain_type, 'none');
    t.assert(numel(a1.size) == 1);
    t.assert(a1.size(1) == 0);
    t.assert(strcmp(a1.format, 'struct'));
    t.assert(a1.getNumberRecords() == 0);
    t.assert(numel(a1.getUELs(1)) == 0);
    t.assert(a1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 7);
    t.assert(isfield(gdx.data, 'a1'));
    t.assert(gdx.data.a1 == a1);
    t.assert(a1.modified);

    t.add('add_symbols_alias_2');
    a2 = gams.transfer.Alias(gdx, 'a2', a1);
    t.testEmptySymbol(a2);
    t.assertEquals(a2.name, 'a2');
    t.assert(a2.alias_with == s1);
    t.assertEquals(a2.alias_with.name, 's1');
    t.assert(a2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 8);
    t.assert(isfield(gdx.data, 'a2'));
    t.assert(gdx.data.a2 == a2);
    t.assert(a2.modified);

    t.add('add_symbols_alias_3');
    a3 = gams.transfer.Alias(gdx, 'a3', a2);
    t.testEmptySymbol(a3);
    t.assertEquals(a3.name, 'a3');
    t.assert(a3.alias_with == s1);
    t.assertEquals(a3.alias_with.name, 's1');
    t.assert(a3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 9);
    t.assert(isfield(gdx.data, 'a3'));
    t.assert(gdx.data.a3 == a3);
    t.assert(a3.modified);

    t.add('add_symbols_parameter_1');
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
    t.assert(numel(fieldnames(gdx.data)) == 10);
    t.assert(isfield(gdx.data, 'p1'));
    t.assert(gdx.data.p1 == p1);
    t.assert(p1.modified);

    t.add('add_symbols_parameter_2');
    p2 = gams.transfer.Parameter(gdx, 'p2', s1, 'description', 'descr par 2');
    t.testEmptySymbol(p2);
    t.assertEquals(p2.name, 'p2');
    t.assertEquals(p2.description, 'descr par 2');
    t.assert(p2.dimension == 1);
    t.assert(numel(p2.domain) == 1);
    t.assert(p2.domain{1} == s1);
    t.assertEquals(p2.domain{1}.name, 's1');
    t.assert(numel(p2.domain_names) == 1);
    t.assertEquals(p2.domain_names{1}, 's1');
    t.assert(numel(p2.domain_labels) == 1);
    t.assertEquals(p2.domain_type, 'regular');
    t.assert(numel(p2.size) == 1);
    t.assert(p2.size(1) == 0);
    t.assert(strcmp(p2.format, 'struct'));
    t.assert(p2.getNumberRecords() == 0);
    t.assert(numel(p2.getUELs(1)) == 0);
    t.assert(p2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 11);
    t.assert(isfield(gdx.data, 'p2'));
    t.assert(gdx.data.p2 == p2);
    t.assert(p2.modified);

    t.add('add_symbols_parameter_3');
    p3 = gams.transfer.Parameter(gdx, 'p3', {s1, '*', 's2'}, 'description', 'descr par 3');
    t.testEmptySymbol(p3);
    t.assertEquals(p3.name, 'p3');
    t.assertEquals(p3.description, 'descr par 3');
    t.assert(p3.dimension == 3);
    t.assert(numel(p3.domain) == 3);
    t.assert(p3.domain{1} == s1);
    t.assertEquals(p3.domain{1}.name, 's1');
    t.assertEquals(p3.domain{2}, '*');
    t.assert(p3.domain{3} == 's2');
    t.assert(numel(p3.domain_names) == 3);
    t.assertEquals(p3.domain_names{1}, 's1');
    t.assertEquals(p3.domain_names{2}, '*');
    t.assertEquals(p3.domain_names{3}, 's2');
    t.assert(numel(p3.domain_labels) == 3);
    t.assertEquals(p3.domain_type, 'relaxed');
    t.assert(numel(p3.size) == 3);
    t.assert(p3.size(1) == 0);
    t.assert(p3.size(2) == 0);
    t.assert(p3.size(3) == 0);
    t.assert(strcmp(p3.format, 'struct'));
    t.assert(p3.getNumberRecords() == 0);
    t.assert(numel(p3.getUELs(1)) == 0);
    t.assert(numel(p3.getUELs(2)) == 0);
    t.assert(numel(p3.getUELs(3)) == 0);
    t.assert(p3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 12);
    t.assert(isfield(gdx.data, 'p3'));
    t.assert(gdx.data.p3 == p3);
    t.assert(p3.modified);

    t.add('add_symbols_parameter_fails');
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            gams.transfer.Parameter(gdx, 's', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', s3);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, repmat('s', [1, 64]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 2) length must be smaller than 64.');
    end
    try
        t.assert(false);
        gams.transfer.Parameter(gdx, 's', 'description', repmat('d', [1, 256]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 4) length must be smaller than 256.');
    end

    t.add('add_symbols_variable_1');
    v1 = gams.transfer.Variable(gdx, 'v1');
    t.testEmptySymbol(v1);
    t.assertEquals(v1.name, 'v1');
    t.assertEquals(v1.description, '');
    t.assert(v1.type == 'free');
    t.assert(v1.dimension == 0);
    t.assert(numel(v1.domain) == 0);
    t.assert(numel(v1.domain_names) == 0);
    t.assert(numel(v1.domain_labels) == 0);
    t.assertEquals(v1.domain_type, 'none');
    t.assert(numel(v1.size) == 0);
    t.assert(strcmp(v1.format, 'struct'));
    t.assert(v1.getNumberRecords() == 0);
    t.assert(v1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 13);
    t.assert(isfield(gdx.data, 'v1'));
    t.assert(gdx.data.v1 == v1);
    t.assert(v1.modified);

    t.add('add_symbols_variable_2');
    v2 = gams.transfer.Variable(gdx, 'v2', gams.transfer.VariableType.BINARY, {}, 'description', 'descr var 2');
    t.testEmptySymbol(v2);
    t.assertEquals(v2.name, 'v2');
    t.assertEquals(v2.description, 'descr var 2');
    t.assert(v2.type == 'binary');
    t.assert(v2.dimension == 0);
    t.assert(numel(v2.domain) == 0);
    t.assert(numel(v2.domain_names) == 0);
    t.assert(numel(v2.domain_labels) == 0);
    t.assertEquals(v2.domain_type, 'none');
    t.assert(numel(v2.size) == 0);
    t.assert(strcmp(v2.format, 'struct'));
    t.assert(v2.getNumberRecords() == 0);
    t.assert(v2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 14);
    t.assert(isfield(gdx.data, 'v2'));
    t.assert(gdx.data.v2 == v2);
    t.assert(v2.modified);

    t.add('add_symbols_variable_3');
    v3 = gams.transfer.Variable(gdx, 'v3', 'sos1', {s1, '*'});
    t.testEmptySymbol(v3);
    t.assertEquals(v3.name, 'v3');
    t.assertEquals(v3.description, '');
    t.assert(v3.type == 'sos1');
    t.assert(v3.dimension == 2);
    t.assert(numel(v3.domain) == 2);
    t.assert(v3.domain{1} == s1);
    t.assertEquals(v3.domain{1}.name, 's1');
    t.assertEquals(v3.domain{2}, '*');
    t.assert(numel(v3.domain_names) == 2);
    t.assertEquals(v3.domain_names{1}, 's1');
    t.assertEquals(v3.domain_names{2}, '*');
    t.assert(numel(v3.domain_labels) == 2);
    t.assertEquals(v3.domain_type, 'regular');
    t.assert(numel(v3.size) == 2);
    t.assert(v3.size(1) == 0);
    t.assert(v3.size(2) == 0);
    t.assert(strcmp(v3.format, 'struct'));
    t.assert(v3.getNumberRecords() == 0);
    t.assert(numel(v3.getUELs(1)) == 0);
    t.assert(numel(v3.getUELs(2)) == 0);
    t.assert(v3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 15);
    t.assert(isfield(gdx.data, 'v3'));
    t.assert(gdx.data.v3 == v3);
    t.assert(v3.modified);

    t.add('add_symbols_variable_4');
    v = gams.transfer.Variable(gdx, 'v41', 'binary');
    t.assertEquals(v.type, 'binary');
    v = gams.transfer.Variable(gdx, 'v42', 'integer');
    t.assertEquals(v.type, 'integer');
    v = gams.transfer.Variable(gdx, 'v43', 'positive');
    t.assertEquals(v.type, 'positive');
    v = gams.transfer.Variable(gdx, 'v44', 'negative');
    t.assertEquals(v.type, 'negative');
    v = gams.transfer.Variable(gdx, 'v45', 'free');
    t.assertEquals(v.type, 'free');
    v = gams.transfer.Variable(gdx, 'v46', 'sos1');
    t.assertEquals(v.type, 'sos1');
    v = gams.transfer.Variable(gdx, 'v47', 'sos2');
    t.assertEquals(v.type, 'sos2');
    v = gams.transfer.Variable(gdx, 'v48', 'semiint');
    t.assertEquals(v.type, 'semiint');
    v = gams.transfer.Variable(gdx, 'v49', 'semicont');
    t.assertEquals(v.type, 'semicont');

    t.add('add_symbols_variable_5');
    v = gams.transfer.Variable(gdx, 'v51', 1);
    t.assertEquals(v.type, 'binary');
    v = gams.transfer.Variable(gdx, 'v52', 2);
    t.assertEquals(v.type, 'integer');
    v = gams.transfer.Variable(gdx, 'v53', 3);
    t.assertEquals(v.type, 'positive');
    v = gams.transfer.Variable(gdx, 'v54', 4);
    t.assertEquals(v.type, 'negative');
    v = gams.transfer.Variable(gdx, 'v55', 5);
    t.assertEquals(v.type, 'free');
    v = gams.transfer.Variable(gdx, 'v56', 6);
    t.assertEquals(v.type, 'sos1');
    v = gams.transfer.Variable(gdx, 'v57', 7);
    t.assertEquals(v.type, 'sos2');
    v = gams.transfer.Variable(gdx, 'v58', 8);
    t.assertEquals(v.type, 'semicont');
    v = gams.transfer.Variable(gdx, 'v59', 9);
    t.assertEquals(v.type, 'semiint');

    t.add('add_symbols_variable_fails');
    try
        t.assert(false);
        gams.transfer.Variable(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, s1, 'stupid');
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, 's', 'free', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            gams.transfer.Variable(gdx, 's', 'free', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, 's', 'free', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, 's', 'free', s3);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, repmat('s', [1, 64]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 2) length must be smaller than 64.');
    end
    try
        t.assert(false);
        gams.transfer.Variable(gdx, 's', 'description', repmat('d', [1, 256]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 4) length must be smaller than 256.');
    end

    t.add('add_symbols_equation_1');
    e1 = gams.transfer.Equation(gdx, 'e1', 'n');
    t.testEmptySymbol(e1);
    t.assertEquals(e1.name, 'e1');
    t.assertEquals(e1.description, '');
    t.assert(e1.type == 'nonbinding');
    t.assert(e1.dimension == 0);
    t.assert(numel(e1.domain) == 0);
    t.assert(numel(e1.domain_names) == 0);
    t.assert(numel(e1.domain_labels) == 0);
    t.assertEquals(e1.domain_type, 'none');
    t.assert(numel(e1.size) == 0);
    t.assert(strcmp(e1.format, 'struct'));
    t.assert(e1.getNumberRecords() == 0);
    t.assert(e1.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 34);
    t.assert(isfield(gdx.data, 'e1'));
    t.assert(gdx.data.e1 == e1);
    t.assert(e1.modified);

    t.add('add_symbols_equation_2');
    e2 = gams.transfer.Equation(gdx, 'e2', gams.transfer.EquationType.EQ, {}, 'description', 'descr equ 2');
    t.testEmptySymbol(e2);
    t.assertEquals(e2.name, 'e2');
    t.assertEquals(e2.description, 'descr equ 2');
    t.assert(e2.type == 'eq');
    t.assert(e2.dimension == 0);
    t.assert(numel(e2.domain) == 0);
    t.assert(numel(e2.domain_names) == 0);
    t.assert(numel(e2.domain_labels) == 0);
    t.assertEquals(e2.domain_type, 'none');
    t.assert(numel(e2.size) == 0);
    t.assert(strcmp(e2.format, 'struct'));
    t.assert(e2.getNumberRecords() == 0);
    t.assert(e2.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 35);
    t.assert(isfield(gdx.data, 'e2'));
    t.assert(gdx.data.e2 == e2);
    t.assert(e2.modified);

    t.add('add_symbols_equation_3');
    e3 = gams.transfer.Equation(gdx, 'e3', 'leq', {s1, '*'});
    t.testEmptySymbol(e3);
    t.assertEquals(e3.name, 'e3');
    t.assertEquals(e3.description, '');
    t.assert(e3.type == 'leq');
    t.assert(e3.dimension == 2);
    t.assert(numel(e3.domain) == 2);
    t.assert(e3.domain{1} == s1);
    t.assertEquals(s3.domain{1}.name, 's1');
    t.assertEquals(e3.domain{2}, '*');
    t.assert(numel(e3.domain_names) == 2);
    t.assertEquals(e3.domain_names{1}, 's1');
    t.assertEquals(e3.domain_names{2}, '*');
    t.assert(numel(e3.domain_labels) == 2);
    t.assertEquals(e3.domain_type, 'regular');
    t.assert(numel(e3.size) == 2);
    t.assert(e3.size(1) == 0);
    t.assert(e3.size(2) == 0);
    t.assert(strcmp(e3.format, 'struct'));
    t.assert(e3.getNumberRecords() == 0);
    t.assert(numel(e3.getUELs(1)) == 0);
    t.assert(numel(e3.getUELs(2)) == 0);
    t.assert(e3.isValid());
    t.assert(numel(fieldnames(gdx.data)) == 36);
    t.assert(isfield(gdx.data, 'e3'));
    t.assert(gdx.data.e3 == e3);
    t.assert(e3.modified);

    t.add('add_symbols_equation_4');
    e = gams.transfer.Equation(gdx, 'e41', 'eq');
    t.assertEquals(e.type, 'eq');
    e = gams.transfer.Equation(gdx, 'e42', 'geq');
    t.assertEquals(e.type, 'geq');
    e = gams.transfer.Equation(gdx, 'e43', 'leq');
    t.assertEquals(e.type, 'leq');
    e = gams.transfer.Equation(gdx, 'e44', 'nonbinding');
    t.assertEquals(e.type, 'nonbinding');
    e = gams.transfer.Equation(gdx, 'e45', 'external');
    t.assertEquals(e.type, 'external');
    e = gams.transfer.Equation(gdx, 'e46', 'cone');
    t.assertEquals(e.type, 'cone');
    e = gams.transfer.Equation(gdx, 'e47', 'boolean');
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_5');
    e = gams.transfer.Equation(gdx, 'e51', 'e');
    t.assertEquals(e.type, 'eq');
    e = gams.transfer.Equation(gdx, 'e52', 'g');
    t.assertEquals(e.type, 'geq');
    e = gams.transfer.Equation(gdx, 'e53', 'l');
    t.assertEquals(e.type, 'leq');
    e = gams.transfer.Equation(gdx, 'e54', 'n');
    t.assertEquals(e.type, 'nonbinding');
    e = gams.transfer.Equation(gdx, 'e55', 'x');
    t.assertEquals(e.type, 'external');
    e = gams.transfer.Equation(gdx, 'e56', 'c');
    t.assertEquals(e.type, 'cone');
    e = gams.transfer.Equation(gdx, 'e57', 'b');
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_6');
    e = gams.transfer.Equation(gdx, 'e61', 0);
    t.assertEquals(e.type, 'eq');
    e = gams.transfer.Equation(gdx, 'e62', 1);
    t.assertEquals(e.type, 'geq');
    e = gams.transfer.Equation(gdx, 'e63', 2);
    t.assertEquals(e.type, 'leq');
    e = gams.transfer.Equation(gdx, 'e64', 3);
    t.assertEquals(e.type, 'nonbinding');
    e = gams.transfer.Equation(gdx, 'e65', 4);
    t.assertEquals(e.type, 'external');
    e = gams.transfer.Equation(gdx, 'e66', 5);
    t.assertEquals(e.type, 'cone');
    e = gams.transfer.Equation(gdx, 'e67', 6);
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_fails');
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 's');
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, s1, 'stupid');
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 's', 'e', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            gams.transfer.Equation(gdx, 's', 'e', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 's', 'e', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 's', 'e', s3);
    catch
        t.reset();
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, repmat('s', [1, 64]), 'n');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 2) length must be smaller than 64.');
    end
    try
        t.assert(false);
        gams.transfer.Equation(gdx, 's', 'n', 'description', repmat('d', [1, 256]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 5) length must be smaller than 256.');
    end

end

function test_overwriteSymbols(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    t.add('overwrite_symbols_set_1');
    s = gdx.addSet('s');
    t.assertEquals(s.description, '');
    t.assertEquals(s.getNumberRecords(), 0)
    gdx.addSet('s', 'description', 'set1');
    t.assertEquals(s.description, 'set1');
    t.assertEquals(s.getNumberRecords(), 0)
    gdx.addSet('s', 'records', {'i1', 'i2'});
    t.assertEquals(s.description, '');
    t.assertEquals(s.getNumberRecords(), 2)

    t.add('overwrite_symbols_set_2');
    try
        t.assert(false);
        gdx.addSet('s', 'is_singleton', true);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''s'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addSet('s', {'i'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''s'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addSet('s', 'domain_forwarding', true);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''s'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addParameter('s');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''s'' (with different symbol type) already exists.');
    end

    t.add('overwrite_symbols_parameter_1');
    p = gdx.addParameter('p');
    t.assertEquals(p.description, '');
    t.assertEquals(p.getNumberRecords(), 0)
    gdx.addParameter('p', 'description', 'par1');
    t.assertEquals(p.description, 'par1');
    t.assertEquals(p.getNumberRecords(), 0)
    gdx.addParameter('p', 'records', 1);
    t.assertEquals(p.description, '');
    t.assertEquals(p.getNumberRecords(), 1)

    t.add('overwrite_symbols_parameter_2');
    try
        t.assert(false);
        gdx.addParameter('p', {'i'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''p'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addSet('p');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''p'' (with different symbol type) already exists.');
    end

    t.add('overwrite_symbols_variable_1');
    v = gdx.addVariable('v');
    t.assertEquals(v.description, '');
    t.assertEquals(v.getNumberRecords(), 0)
    gdx.addVariable('v', 'description', 'var1');
    t.assertEquals(v.description, 'var1');
    t.assertEquals(v.getNumberRecords(), 0)
    gdx.addVariable('v', 'records', 1);
    t.assertEquals(v.description, '');
    t.assertEquals(v.getNumberRecords(), 1)

    t.add('overwrite_symbols_variable_2');
    try
        t.assert(false);
        gdx.addVariable('v', 'binary');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''v'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addVariable('v', 'free', {'i'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''v'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addSet('v');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''v'' (with different symbol type) already exists.');
    end

    t.add('overwrite_symbols_equation_1');
    e = gdx.addEquation('e', 'l');
    t.assertEquals(e.description, '');
    t.assertEquals(e.getNumberRecords(), 0)
    gdx.addEquation('e', 'l', 'description', 'equ1');
    t.assertEquals(e.description, 'equ1');
    t.assertEquals(e.getNumberRecords(), 0)
    gdx.addEquation('e', 'l', 'records', 1);
    t.assertEquals(e.description, '');
    t.assertEquals(e.getNumberRecords(), 1)

    t.add('overwrite_symbols_equation_2');
    try
        t.assert(false);
        gdx.addEquation('e', 'g');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''e'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addEquation('e', 'l', {'i'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''e'' (with different definition) already exists.');
    end
    try
        t.assert(false);
        gdx.addSet('e');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''e'' (with different symbol type) already exists.');
    end

    t.add('overwrite_symbols_alias_1');
    s2 = gdx.addSet('s2');
    a = gdx.addAlias('a', s);
    t.assertEquals(a.alias_with.name, 's');
    gdx.addAlias('a', s2);
    t.assertEquals(a.alias_with.name, 's2');

    t.add('overwrite_symbols_alias_2');
    try
        t.assert(false);
        gdx.addSet('a');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''a'' (with different symbol type) already exists.');
    end

end

function test_changeSymbol(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    i1 = gams.transfer.Set(gdx, 'i1');
    i2 = gams.transfer.Set(gdx, 'i2', 'records', {'i21', 'i22', 'i23'});
    x1 = gams.transfer.Variable(gdx, 'x1', 'free', {i1});
    x2 = gams.transfer.Variable(gdx, 'x2', 'free', {i1,i1});
    x3 = gams.transfer.Variable(gdx, 'x3', 'free', {i2}, 'records', {{'i21', 'i22', 'i23'}, [1 2 3]});

    t.add('change_symbol_name_1');
    gdx.modified = false;
    t.assertEquals(x1.name, 'x1');
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(~isfield(gdx.data, 'xx1'));
    vars = gdx.listVariables();
    t.assert(numel(vars) == 3);
    t.assertEquals(vars{1}, 'x1');
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.name = 'xx1';
    t.assertEquals(x1.name, 'xx1');
    t.assert(~isfield(gdx.data, 'x1'));
    t.assert(isfield(gdx.data, 'xx1'));
    vars = gdx.listVariables();
    t.assert(numel(vars) == 3);
    t.assertEquals(vars{1}, 'xx1');
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);

    t.add('change_symbol_name_2');
    try
        t.assert(false);
        x1.name = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 1) must be ''string'' or ''char''.');
    end
    try
        t.assert(false);
        x1.name = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''name'' (at position 1) must be ''string'' or ''char''.');
    end
    try
        t.assert(false);
        x1.name = 'x2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''x2'' already exists.');
    end
    try
        t.assert(false);
        x1.name = 'X2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Symbol ''X2'' already exists.');
    end

    t.add('change_symbol_description_1');
    t.assertEquals(x1.description, '');
    t.assertEquals(x2.description, '');
    x1.description = 'descr x1';
    t.assertEquals(x1.description, 'descr x1');
    t.assertEquals(x2.description, '');

    t.add('change_symbol_description_2');
    try
        t.assert(false);
        x1.description = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 1) must be ''string'' or ''char''.');
    end
    try
        t.assert(false);
        x1.description = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''description'' (at position 1) must be ''string'' or ''char''.');
    end

    t.add('change_symbol_dimension_1');
    gdx.modified = false;
    t.assert(x1.dimension == 1);
    t.assert(numel(x1.domain) == 1);
    t.assertEquals(x1.domain{1}, i1);
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.dimension = 2;
    t.assert(x1.dimension == 2);
    t.assert(numel(x1.domain) == 2);
    t.assertEquals(x1.domain{1}, i1);
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assertEquals(x1.domain{2}, '*');
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.dimension = 1;
    t.assert(x1.dimension == 1);
    t.assert(numel(x1.domain) == 1);
    t.assertEquals(x1.domain{1}, i1);
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);

    t.add('change_symbol_dimension_2');
    try
        t.assert(false);
        x1.dimension = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be numeric.');
    end
    try
        t.assert(false);
        x1.dimension = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be integer.');
    end
    try
        t.assert(false);
        x1.dimension = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be in [0,20].');
    end
    try
        t.assert(false);
        x1.dimension = 21;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''dimension'' (at position 1) must be in [0,20].');
    end

    t.add('change_symbol_dimension_3');
    gdx.modified = false;
    t.assert(x3.dimension == 1);
    t.assert(numel(x3.domain) == 1);
    t.assertEquals(x3.domain{1}, i2);
    t.assertEquals(x3.domain{1}.name, 'i2');
    t.assert(x3.isValid());
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x3.dimension = 2;
    t.assert(x3.dimension == 2);
    t.assert(numel(x3.domain) == 2);
    t.assertEquals(x3.domain{1}, i2);
    t.assertEquals(x3.domain{1}.name, 'i2');
    t.assertEquals(x3.domain{2}, '*');
    t.assert(~x3.isValid());
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(x3.modified);
    x3.dimension = 1;
    t.assert(x3.dimension == 1);
    t.assert(numel(x3.domain) == 1);
    t.assertEquals(x3.domain{1}, i2);
    t.assertEquals(x3.domain{1}.name, 'i2');
    t.assert(x3.isValid());
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(x3.modified);

    t.add('change_symbol_domain_1');
    gdx.modified = false;
    t.assert(numel(x1.domain) == 1);
    t.assertEquals(x1.domain{1}, i1);
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.domain = {i1,i1};
    t.assert(x1.dimension == 2);
    t.assert(numel(x1.domain) == 2);
    t.assertEquals(x1.domain{1}, i1);
    t.assertEquals(x1.domain{2}, i1);
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assertEquals(x1.domain{2}.name, 'i1');
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.domain = {'*'};
    t.assert(x1.dimension == 1);
    t.assertEquals(x1.domain, {'*'});
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.domain = {'a', 'b'};
    t.assert(x1.dimension == 2);
    t.assertEquals(x1.domain, {'a', 'b'});
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);

    t.add('change_symbol_domain_2');
    try
        t.assert(false);
        x1.domain = {x2};
    catch e
        t.reset();
        t.assertEquals(e.message, 'Cannot create domains from ''domains'' (at position 1): Element 1 must be ''gams.transfer.symbol.domain.Abstract'', ''gams.transfer.symbol.Set'', ''char'' or ''string''.');
    end

    t.add('change_symbol_domain_labels_1');
    x1.domain = {i2};
    x1.records = struct();
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        x1.records.i2 = categorical({'i21', 'i22', 'i23'})';
    else
        x1.records.i2 = [1; 2; 3];
    end
    x1.records.level = [1; 2; 3];
    t.assert(x1.isValid());
    gdx.modified = false;
    t.assert(numel(x1.domain) == 1);
    t.assertEquals(x1.domain{1}, i2);
    t.assertEquals(x1.domain{1}.name, 'i2');
    t.assertEquals(x1.domain_labels{1}, 'i2');
    t.assert(isfield(x1.records, 'i2'));
    t.assert(~isfield(x1.records, 'first'));
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.domain_labels = {'first'};
    t.assert(x1.dimension == 1);
    t.assert(numel(x1.domain) == 1);
    t.assertEquals(x1.domain{1}, i2);
    t.assertEquals(x1.domain{1}.name, 'i2');
    t.assertEquals(x1.domain_labels{1}, 'first');
    t.assert(isfield(x1.records, 'first'));
    t.assert(~isfield(x1.records, 'i2'));
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    t.assert(x1.isValid());

    t.add('change_symbol_domain_labels_2');
    x1.domain = {'i', 'j'};
    x1.records = struct();
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        x1.records.i = categorical({'i21', 'i22', 'i23'})';
        x1.records.j = categorical({'j21', 'j22', 'j23'})';
    else
        x1.records.i = [1; 2; 3];
        x1.records.j = [1; 2; 3];
    end
    x1.records.level = [1; 2; 3];
    t.assert(x1.isValid());
    gdx.modified = false;
    t.assert(x1.dimension == 2);
    t.assertEquals(x1.domain, {'i', 'j'});
    t.assertEquals(x1.domain_labels{1}, 'i');
    t.assertEquals(x1.domain_labels{2}, 'j');
    t.assert(isfield(x1.records, 'i'));
    t.assert(isfield(x1.records, 'j'));
    t.assert(~isfield(x1.records, 'one'));
    t.assert(~isfield(x1.records, 'two'));
    t.assert(~gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(~x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    x1.domain_labels = {'one', 'two'};
    t.assert(x1.dimension == 2);
    t.assertEquals(x1.domain, {'i', 'j'});
    t.assertEquals(x1.domain_labels{1}, 'one');
    t.assertEquals(x1.domain_labels{2}, 'two');
    t.assert(~isfield(x1.records, 'i'));
    t.assert(~isfield(x1.records, 'j'));
    t.assert(isfield(x1.records, 'one'));
    t.assert(isfield(x1.records, 'two'));
    t.assert(gdx.modified);
    t.assert(~i1.modified);
    t.assert(~i2.modified);
    t.assert(x1.modified);
    t.assert(~x2.modified);
    t.assert(~x3.modified);
    t.assert(x1.isValid());

    t.add('change_symbol_domain_labels_3');
    try
        t.assert(false);
        x1.domain_labels = '*';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''domain_labels'' (at position 1) must be ''cell''.');
    end
    try
        t.assert(false);
        x1.domain_labels = {'*'};
    catch e
        t.reset();
        t.assertEquals(e.message, 'Argument ''domain_labels'' (at position 1) must have 2 elements.');
    end

end

function test_copySymbol(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    i = gams.transfer.Set(gdx, 'i', 'description', 'set i', 'records', {'i1', 'i2', 'i3'});
    a = gams.transfer.Alias(gdx, 'a', i);
    x = gams.transfer.Variable(gdx, 'x', 'binary', {i});
    e = gams.transfer.Equation(gdx, 'e', 'leq', {a, i}, 'description', 'equ e');
    p = gams.transfer.Parameter(gdx, 'p', {i}, 'records', {{'i1', 'i2'}, [1 2]});
    gdx.modified = false;

    t.add('copy_symbol_set_empty');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    i.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'i'));
    t.assertEquals(gdx2.data.i.name, 'i');
    t.assertEquals(gdx2.data.i.description, 'set i');
    t.assert(gdx2.data.i.dimension == 1);
    t.assert(gdx2.data.i.size(1) == 3);
    t.assert(iscell(gdx2.data.i.domain));
    t.assert(numel(gdx2.data.i.domain) == 1);
    t.assertEquals(gdx2.data.i.domain{1}, '*');
    t.assert(isfield(gdx2.data.i.records, 'uni'));
    t.assert(numel(gdx2.data.i.records.uni) == 3);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(gdx2.data.i.records.uni(1), 'i1');
        t.assertEquals(gdx2.data.i.records.uni(2), 'i2');
        t.assertEquals(gdx2.data.i.records.uni(3), 'i3');
    else
        t.assertEquals(gdx2.data.i.records.uni(1), 1);
        t.assertEquals(gdx2.data.i.records.uni(2), 2);
        t.assertEquals(gdx2.data.i.records.uni(3), 3);
    end
    t.assert(~gdx2.data.i.domain_forwarding(1));
    t.assertEquals(gdx2.data.i.format, 'struct');
    t.assert(~i.modified);
    t.assert(gdx2.data.i.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_set_overwrite_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Set(gdx2, 'i');
    gdx2.modified = false;
    i.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'i'));
    t.assertEquals(gdx2.data.i.name, 'i');
    t.assertEquals(gdx2.data.i.description, 'set i');
    t.assert(gdx2.data.i.dimension == 1);
    t.assert(gdx2.data.i.size(1) == 3);
    t.assert(iscell(gdx2.data.i.domain));
    t.assert(numel(gdx2.data.i.domain) == 1);
    t.assertEquals(gdx2.data.i.domain{1}, '*');
    t.assert(isfield(gdx2.data.i.records, 'uni'));
    t.assert(numel(gdx2.data.i.records.uni) == 3);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(gdx2.data.i.records.uni(1), 'i1');
        t.assertEquals(gdx2.data.i.records.uni(2), 'i2');
        t.assertEquals(gdx2.data.i.records.uni(3), 'i3');
    else
        t.assertEquals(gdx2.data.i.records.uni(1), 1);
        t.assertEquals(gdx2.data.i.records.uni(2), 2);
        t.assertEquals(gdx2.data.i.records.uni(3), 3);
    end
    t.assert(~gdx2.data.i.domain_forwarding(1));
    t.assertEquals(gdx2.data.i.format, 'struct');
    t.assert(~i.modified);
    t.assert(gdx2.data.i.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_set_overwrite_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Set(gdx2, 'i');
    try
        t.assert(false);
        i.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Symbol already exists in destination.');
    end

    t.add('copy_symbol_alias_empty_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    try
        t.assert(false);
        a.copy(gdx2);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Aliased symbol not available in destination');
    end

    t.add('copy_symbol_alias_empty_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    i.copy(gdx2);
    a.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 2);
    t.assert(isfield(gdx2.data, 'i'));
    t.assertEquals(gdx2.data.i.name, 'i');
    t.assert(isfield(gdx2.data, 'a'));
    t.assertEquals(gdx2.data.a.name, 'a');
    t.assert(gdx2.data.i == gdx2.data.a.alias_with);
    t.assert(~a.modified);
    t.assert(gdx2.data.a.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_alias_overwrite_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    i.copy(gdx2);
    j = gams.transfer.Set(gdx2, 'j');
    gams.transfer.Alias(gdx2, 'a', j);
    gdx2.modified = false;
    a.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 3);
    t.assert(isfield(gdx2.data, 'i'));
    t.assertEquals(gdx2.data.i.name, 'i');
    t.assert(isfield(gdx2.data, 'a'));
    t.assertEquals(gdx2.data.a.name, 'a');
    t.assert(gdx2.data.i == gdx2.data.a.alias_with);
    t.assert(~a.modified);
    t.assert(gdx2.data.a.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_alias_overwrite_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    j = gams.transfer.Set(gdx2, 'j');
    gams.transfer.Alias(gdx2, 'a', j);
    try
        t.assert(false);
        a.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Aliased symbol not available in destination');
    end

    t.add('copy_symbol_variable_empty_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    x.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'x'));
    t.assertEquals(gdx2.data.x.name, 'x');
    t.assertEquals(gdx2.data.x.description, '');
    t.assertEquals(gdx2.data.x.type, 'binary');
    t.assert(gdx2.data.x.dimension == 1);
    t.assert(gdx2.data.x.size(1) == 0);
    t.assert(iscell(gdx2.data.x.domain));
    t.assert(numel(gdx2.data.x.domain) == 1);
    t.assertEquals(gdx2.data.x.domain{1}, 'i');
    t.assertEquals(gdx2.data.x.domain_type, 'relaxed');
    t.assert(~gdx2.data.x.domain_forwarding(1));
    t.assertEquals(gdx2.data.x.format, 'struct');
    t.assert(~x.modified);
    t.assert(gdx2.data.x.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_variable_empty_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    i.copy(gdx2);
    x.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 2);
    t.assert(isfield(gdx2.data, 'x'));
    t.assertEquals(gdx2.data.x.name, 'x');
    t.assertEquals(gdx2.data.x.description, '');
    t.assertEquals(gdx2.data.x.type, 'binary');
    t.assert(gdx2.data.x.dimension == 1);
    t.assert(gdx2.data.x.size(1) == 3);
    t.assert(iscell(gdx2.data.x.domain));
    t.assert(numel(gdx2.data.x.domain) == 1);
    t.assert(gdx2.data.x.domain{1} == gdx2.data.i);
    t.assertEquals(gdx2.data.x.domain_type, 'regular');
    t.assert(~gdx2.data.x.domain_forwarding(1));
    t.assertEquals(gdx2.data.x.format, 'struct');
    t.assert(~x.modified);
    t.assert(gdx2.data.x.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_variable_overwrite_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Variable(gdx2, 'x');
    gdx2.modified = false;
    x.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'x'));
    t.assertEquals(gdx2.data.x.name, 'x');
    t.assertEquals(gdx2.data.x.description, '');
    t.assertEquals(gdx2.data.x.type, 'binary');
    t.assert(gdx2.data.x.dimension == 1);
    t.assert(gdx2.data.x.size(1) == 0);
    t.assert(iscell(gdx2.data.x.domain));
    t.assert(numel(gdx2.data.x.domain) == 1);
    t.assertEquals(gdx2.data.x.domain{1}, 'i');
    t.assertEquals(gdx2.data.x.domain_type, 'relaxed');
    t.assert(~gdx2.data.x.domain_forwarding(1));
    t.assertEquals(gdx2.data.x.format, 'struct');
    t.assert(~x.modified);
    t.assert(gdx2.data.x.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_variable_overwrite_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Variable(gdx2, 'x');
    try
        t.assert(false);
        x.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Symbol already exists in destination.');
    end

    t.add('copy_symbol_equation_empty_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    e.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'e'));
    t.assertEquals(gdx2.data.e.name, 'e');
    t.assertEquals(gdx2.data.e.description, 'equ e');
    t.assertEquals(gdx2.data.e.type, 'leq');
    t.assert(gdx2.data.e.dimension == 2);
    t.assert(gdx2.data.e.size(1) == 0);
    t.assert(gdx2.data.e.size(2) == 0);
    t.assert(iscell(gdx2.data.e.domain));
    t.assert(numel(gdx2.data.e.domain) == 2);
    t.assertEquals(gdx2.data.e.domain{1}, 'a');
    t.assertEquals(gdx2.data.e.domain{2}, 'i');
    t.assertEquals(gdx2.data.e.domain_type, 'relaxed');
    t.assert(~gdx2.data.e.domain_forwarding(1));
    t.assert(~gdx2.data.e.domain_forwarding(2));
    t.assertEquals(gdx2.data.e.format, 'struct');
    t.assert(~e.modified);
    t.assert(gdx2.data.e.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_equation_empty_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    i.copy(gdx2);
    a.copy(gdx2);
    e.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 3);
    t.assert(isfield(gdx2.data, 'e'));
    t.assertEquals(gdx2.data.e.name, 'e');
    t.assertEquals(gdx2.data.e.description, 'equ e');
    t.assertEquals(gdx2.data.e.type, 'leq');
    t.assert(gdx2.data.e.dimension == 2);
    t.assert(gdx2.data.e.size(1) == 3);
    t.assert(gdx2.data.e.size(2) == 3);
    t.assert(iscell(gdx2.data.e.domain));
    t.assert(numel(gdx2.data.e.domain) == 2);
    t.assert(gdx2.data.e.domain{1} == gdx2.data.a);
    t.assert(gdx2.data.e.domain{2} == gdx2.data.i);
    t.assertEquals(gdx2.data.e.domain_type, 'regular');
    t.assert(~gdx2.data.e.domain_forwarding(1));
    t.assert(~gdx2.data.e.domain_forwarding(2));
    t.assertEquals(gdx2.data.e.format, 'struct');
    t.assert(~e.modified);
    t.assert(gdx2.data.e.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_equation_overwrite_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Equation(gdx2, 'e', 'geq');
    gdx2.modified = false;
    e.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'e'));
    t.assertEquals(gdx2.data.e.name, 'e');
    t.assertEquals(gdx2.data.e.description, 'equ e');
    t.assertEquals(gdx2.data.e.type, 'leq');
    t.assert(gdx2.data.e.dimension == 2);
    t.assert(gdx2.data.e.size(1) == 0);
    t.assert(gdx2.data.e.size(2) == 0);
    t.assert(iscell(gdx2.data.e.domain));
    t.assert(numel(gdx2.data.e.domain) == 2);
    t.assertEquals(gdx2.data.e.domain{1}, 'a');
    t.assertEquals(gdx2.data.e.domain{2}, 'i');
    t.assertEquals(gdx2.data.e.domain_type, 'relaxed');
    t.assert(~gdx2.data.e.domain_forwarding(1));
    t.assert(~gdx2.data.e.domain_forwarding(2));
    t.assertEquals(gdx2.data.e.format, 'struct');
    t.assert(~e.modified);
    t.assert(gdx2.data.e.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_variable_overwrite_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Equation(gdx2, 'e', 'geq');
    try
        t.assert(false);
        e.copy(gdx2, false);
    catch ex
        t.reset();
        t.assertEquals(ex.message, 'Symbol already exists in destination.');
    end

    t.add('copy_symbol_parameter_empty_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    p.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'p'));
    t.assertEquals(gdx2.data.p.name, 'p');
    t.assertEquals(gdx2.data.p.description, '');
    t.assert(gdx2.data.p.dimension == 1);
    t.assert(gdx2.data.p.size(1) == 2);
    t.assert(iscell(gdx2.data.p.domain));
    t.assert(numel(gdx2.data.p.domain) == 1);
    t.assertEquals(gdx2.data.p.domain{1}, 'i');
    t.assertEquals(gdx2.data.p.domain_type, 'relaxed');
    t.assert(~gdx2.data.p.domain_forwarding(1));
    t.assertEquals(gdx2.data.p.format, 'struct');
    t.assert(isfield(gdx2.data.p.records, 'i'));
    t.assert(isfield(gdx2.data.p.records, 'value'));
    t.assert(numel(gdx2.data.p.records.i) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(gdx2.data.p.records.i(1), 'i1');
        t.assertEquals(gdx2.data.p.records.i(2), 'i2');
    else
        t.assertEquals(gdx2.data.p.records.i(1), 1);
        t.assertEquals(gdx2.data.p.records.i(2), 2);
    end
    t.assert(numel(gdx2.data.p.records.value) == 2);
    t.assert(gdx2.data.p.records.value(1) == 1);
    t.assert(gdx2.data.p.records.value(2) == 2);
    t.assert(~p.modified);
    t.assert(gdx2.data.p.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_parameter_empty_2');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gdx2.modified = false;
    i.copy(gdx2);
    p.copy(gdx2);
    t.assert(numel(fieldnames(gdx2.data)) == 2);
    t.assert(isfield(gdx2.data, 'p'));
    t.assertEquals(gdx2.data.p.name, 'p');
    t.assertEquals(gdx2.data.p.description, '');
    t.assert(gdx2.data.p.dimension == 1);
    t.assert(gdx2.data.p.size(1) == 2);
    t.assert(iscell(gdx2.data.p.domain));
    t.assert(numel(gdx2.data.p.domain) == 1);
    t.assert(gdx2.data.p.domain{1} == gdx2.data.i);
    t.assertEquals(gdx2.data.p.domain_type, 'regular');
    t.assert(~gdx2.data.p.domain_forwarding(1));
    t.assertEquals(gdx2.data.p.format, 'struct');
    t.assert(isfield(gdx2.data.p.records, 'i'));
    t.assert(isfield(gdx2.data.p.records, 'value'));
    t.assert(numel(gdx2.data.p.records.i) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(gdx2.data.p.records.i(1), 'i1');
        t.assertEquals(gdx2.data.p.records.i(2), 'i2');
    else
        t.assertEquals(gdx2.data.p.records.i(1), 1);
        t.assertEquals(gdx2.data.p.records.i(2), 2);
    end
    t.assert(numel(gdx2.data.p.records.value) == 2);
    t.assert(gdx2.data.p.records.value(1) == 1);
    t.assert(gdx2.data.p.records.value(2) == 2);
    t.assert(~p.modified);
    t.assert(gdx2.data.p.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_parameter_overwrite_1');
    gdx2 = gams.transfer.Container('gams_dir', cfg.gams_dir);
    gams.transfer.Parameter(gdx2, 'p');
    gdx2.modified = false;
    p.copy(gdx2, true);
    t.assert(numel(fieldnames(gdx2.data)) == 1);
    t.assert(isfield(gdx2.data, 'p'));
    t.assertEquals(gdx2.data.p.name, 'p');
    t.assertEquals(gdx2.data.p.description, '');
    t.assert(gdx2.data.p.dimension == 1);
    t.assert(gdx2.data.p.size(1) == 2);
    t.assert(iscell(gdx2.data.p.domain));
    t.assert(numel(gdx2.data.p.domain) == 1);
    t.assertEquals(gdx2.data.p.domain{1}, 'i');
    t.assertEquals(gdx2.data.p.domain_type, 'relaxed');
    t.assert(~gdx2.data.p.domain_forwarding(1));
    t.assertEquals(gdx2.data.p.format, 'struct');
    t.assert(isfield(gdx2.data.p.records, 'i'));
    t.assert(isfield(gdx2.data.p.records, 'value'));
    t.assert(numel(gdx2.data.p.records.i) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(gdx2.data.p.records.i(1), 'i1');
        t.assertEquals(gdx2.data.p.records.i(2), 'i2');
    else
        t.assertEquals(gdx2.data.p.records.i(1), 1);
        t.assertEquals(gdx2.data.p.records.i(2), 2);
    end
    t.assert(numel(gdx2.data.p.records.value) == 2);
    t.assert(gdx2.data.p.records.value(1) == 1);
    t.assert(gdx2.data.p.records.value(2) == 2);
    t.assert(~p.modified);
    t.assert(gdx2.data.p.modified);
    t.assert(~gdx.modified);
    t.assert(gdx2.modified);

    t.add('copy_symbol_parameter_overwrite_2');
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

function test_defaultvalues(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    t.add('default_values_variables');
    s = gams.transfer.Variable(gdx, 'x1', 'binary');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == 1);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x2', 'integer');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x3', 'positive');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x4', 'negative');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == -Inf);
    t.assert(s.default_values.upper == 0);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x5', 'free');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == -Inf);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x6', 'sos1');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x7', 'sos2');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x8', 'semiint');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 1);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Variable(gdx, 'x9', 'semicont');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 1);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);

    t.add('default_values_equations');
    s = gams.transfer.Equation(gdx, 'e1', 'e');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == 0);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e2', 'l');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == -Inf);
    t.assert(s.default_values.upper == 0);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e3', 'g');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e4', 'n');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == -Inf);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e5', 'x');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == 0);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e6', 'b');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == 0);
    t.assert(s.default_values.scale == 1);
    s = gams.transfer.Equation(gdx, 'e7', 'c');
    t.assert(s.default_values.level == 0);
    t.assert(s.default_values.marginal == 0);
    t.assert(s.default_values.lower == 0);
    t.assert(s.default_values.upper == Inf);
    t.assert(s.default_values.scale == 1);

end

function test_domainViolation(t, cfg);

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i1 = gams.transfer.Set(gdx, 'i1', '*', 'records', {'i1', 'i2', 'i3', 'i4'});
    i2 = gams.transfer.Set(gdx, 'i2', i1, 'records', {'i1', 'i2'});
    a1 = gams.transfer.Parameter(gdx, 'a1', {i1, i1}, 'records', ...
        {{'i0', 'i0', 'I1', 'i1'}, {'i1', 'I2', 'I1', 'i2'}, [1;2;3;4]});
    a2 = gams.transfer.Parameter(gdx, 'a2', {i1, '*'}, 'records', ...
        {{'i1', 'I1', 'i5', 'I5'}, {'i1', 'I5', 'I1', 'i5'}, [1;2;3;4]});
    a3 = gams.transfer.Parameter(gdx, 'a3', i2, 'records', ...
        {{'I1', 'i7'}, [1;2]});

    t.add('domain_violation_1');
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(a2.isValid());
    t.assert(a3.isValid());
    t.assert(~a1.domain_forwarding(1));
    t.assert(~a1.domain_forwarding(2));
    t.assert(~a2.domain_forwarding(1));
    t.assert(~a2.domain_forwarding(2));
    t.assert(~a3.domain_forwarding(1));
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 3);
    t.assert(isa(domviol{1}, 'gams.transfer.symbol.domain.Violation'));
    t.assert(isa(domviol{2}, 'gams.transfer.symbol.domain.Violation'));
    t.assert(isa(domviol{3}, 'gams.transfer.symbol.domain.Violation'));
    t.assertEquals(domviol{1}.symbol.name, 'a1');
    t.assertEquals(domviol{2}.symbol.name, 'a2');
    t.assertEquals(domviol{3}.symbol.name, 'a3');
    t.assert(domviol{1}.dimension == 1);
    t.assert(domviol{2}.dimension == 1);
    t.assert(domviol{3}.dimension == 1);
    t.assert(iscellstr(domviol{1}.violations));
    t.assert(iscellstr(domviol{2}.violations));
    t.assert(iscellstr(domviol{3}.violations));
    t.assert(numel(domviol{1}.violations) == 1);
    t.assert(numel(domviol{2}.violations) == 1);
    t.assert(numel(domviol{3}.violations) == 1);
    t.assertEquals(domviol{1}.violations{1}, 'i0');
    t.assertEquals(lower(domviol{2}.violations{1}), 'i5');
    t.assertEquals(domviol{3}.violations{1}, 'i7');

    t.add('domain_violation_2');
    try
        t.assert(false);
        gdx.write(write_filename);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_gdx_write: GDX error for a1: Domain violation');
        else
            t.assertEquals(e.message, 'GDX error for a1: Domain violation');
        end
    end

    t.add('domain_violation_3');
    gdx.resolveDomainViolations();
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 0);
    elems = i1.getUELs(1);
    t.assert(iscell(elems));
    t.assert(numel(elems) == 7);
    t.assert(elems{1} == 'i1');
    t.assert(elems{2} == 'i2');
    t.assert(elems{3} == 'i3');
    t.assert(elems{4} == 'i4');
    t.assert(elems{5} == 'i0');
    t.assert(lower(elems{6}) == 'i5');
    t.assert(elems{7} == 'i7');
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(a2.isValid());
    t.assert(a3.isValid());

    t.add('domain_violation_4');
    gdx.write(write_filename);

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i1 = gams.transfer.Set(gdx, 'i1', '*', 'records', {'i1', 'i2', 'i3', 'i4'});
    i2 = gams.transfer.Set(gdx, 'i2', i1, 'records', {'i1', 'i2'});
    a1 = gams.transfer.Parameter(gdx, 'a1', {i1, i1}, 'records', ...
        {{'i0', 'i0', 'I1', 'i1'}, {'i1', 'I2', 'I1', 'i2'}, [1;2;3;4]});
    a2 = gams.transfer.Parameter(gdx, 'a2', {i1, '*'}, 'records', ...
        {{'i1', 'I1', 'i5', 'I5'}, {'i1', 'I5', 'I1', 'i5'}, [1;2;3;4]});
    a3 = gams.transfer.Parameter(gdx, 'a3', i2, 'records', ...
        {{'I1', 'i7'}, [1;2]});

    t.add('domain_violation_with_grow_1');
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(a2.isValid());
    t.assert(a3.isValid());
    t.assert(~a1.domain_forwarding(1));
    t.assert(~a1.domain_forwarding(2));
    t.assert(~a2.domain_forwarding(1));
    t.assert(~a2.domain_forwarding(2));
    t.assert(~a3.domain_forwarding(1));
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 3);
    t.assert(isa(domviol{1}, 'gams.transfer.symbol.domain.Violation'));
    t.assert(isa(domviol{2}, 'gams.transfer.symbol.domain.Violation'));
    t.assert(isa(domviol{3}, 'gams.transfer.symbol.domain.Violation'));
    t.assertEquals(domviol{1}.symbol.name, 'a1');
    t.assertEquals(domviol{2}.symbol.name, 'a2');
    t.assertEquals(domviol{3}.symbol.name, 'a3');
    t.assert(domviol{1}.dimension == 1);
    t.assert(domviol{2}.dimension == 1);
    t.assert(domviol{3}.dimension == 1);
    t.assert(iscellstr(domviol{1}.violations));
    t.assert(iscellstr(domviol{2}.violations));
    t.assert(iscellstr(domviol{3}.violations));
    t.assert(numel(domviol{1}.violations) == 1);
    t.assert(numel(domviol{2}.violations) == 1);
    t.assert(numel(domviol{3}.violations) == 1);
    t.assertEquals(domviol{1}.violations{1}, 'i0');
    t.assertEquals(lower(domviol{2}.violations{1}), 'i5');
    t.assertEquals(domviol{3}.violations{1}, 'i7');

    t.add('domain_violation_with_grow_2');
    a1.domain_forwarding = true;
    a2.domain_forwarding = true;
    a3.domain_forwarding = true;
    t.assert(a1.domain_forwarding(1));
    t.assert(a1.domain_forwarding(2));
    t.assert(a2.domain_forwarding(1));
    t.assert(a2.domain_forwarding(2));
    t.assert(a3.domain_forwarding(1));
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 0);
    elems = i1.getUELs(1);
    t.assert(iscell(elems));
    t.assert(numel(elems) == 7);
    t.assert(elems{1} == 'i1');
    t.assert(elems{2} == 'i2');
    t.assert(elems{3} == 'i3');
    t.assert(elems{4} == 'i4');
    t.assert(elems{5} == 'i0');
    t.assert(lower(elems{6}) == 'i5');
    t.assert(elems{7} == 'i7');
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(a2.isValid());
    t.assert(a3.isValid());

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i1 = gams.transfer.Set(gdx, 'i1', '*', 'records', {'i1', 'i2', 'i3', 'i4'});
    i2 = gams.transfer.Set(gdx, 'i2', i1, 'records', {'i1', 'i2'});
    a1 = gams.transfer.Parameter(gdx, 'a1', {i1, i1}, 'records', ...
        {{'i0', 'i0', 'I1', 'i1'}, {'i1', 'I2', 'I1', 'i2'}, [1;2;3;4]}, ...
        'domain_forwarding', true);
    a2 = gams.transfer.Parameter(gdx, 'a2', {i1, '*'}, 'records', ...
        {{'i1', 'I1', 'i5', 'I5'}, {'i1', 'I5', 'I1', 'i5'}, [1;2;3;4]}, ...
        'domain_forwarding', true);
    a3 = gams.transfer.Parameter(gdx, 'a3', i2, 'records', ...
        {{'I1', 'i7'}, [1;2]}, 'domain_forwarding', true);

    t.add('domain_violation_with_grow_3');
    t.assert(a1.domain_forwarding(1));
    t.assert(a1.domain_forwarding(2));
    t.assert(a2.domain_forwarding(1));
    t.assert(a2.domain_forwarding(2));
    t.assert(a3.domain_forwarding(1));
    t.assert(numel(domviol) == 0);
    elems = i1.getUELs(1);
    t.assert(iscell(elems));
    t.assert(numel(elems) == 7);
    t.assert(elems{1} == 'i1');
    t.assert(elems{2} == 'i2');
    t.assert(elems{3} == 'i3');
    t.assert(elems{4} == 'i4');
    t.assert(elems{5} == 'i0');
    t.assert(lower(elems{6}) == 'i5');
    t.assert(elems{7} == 'i7');
    t.assert(i1.isValid());
    t.assert(a1.isValid());
    t.assert(a2.isValid());
    t.assert(a3.isValid());

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i1 = gams.transfer.Set(gdx, 'i1', '*', 'records', {'i1', 'i2', 'i3', 'i4'});
    i2 = gams.transfer.Set(gdx, 'i2', i1, 'records', {'i1', 'i2'});
    a1 = gams.transfer.Parameter(gdx, 'a1', {i1, i1}, 'records', ...
        {{'i0', 'i0', 'I1', 'i1'}, {'i1', 'I2', 'I1', 'i2'}, [1;2;3;4]});
    a2 = gams.transfer.Parameter(gdx, 'a2', {i1, '*'}, 'records', ...
        {{'i1', 'I1', 'i5', 'I5'}, {'i1', 'I5', 'I1', 'i5'}, [1;2;3;4]});
    a3 = gams.transfer.Parameter(gdx, 'a3', i2, 'records', ...
        {{'I1', 'i7'}, [1;2]});

    t.add('domain_violation_with_grow_4');
    a1.domain_forwarding(2) = true;
    a2.domain_forwarding(2) = true;
    a3.domain_forwarding(1) = true;
    t.assert(~a1.domain_forwarding(1));
    t.assert(a1.domain_forwarding(2));
    t.assert(~a2.domain_forwarding(1));
    t.assert(a2.domain_forwarding(2));
    t.assert(a3.domain_forwarding(1));
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 2);
    t.assert(isa(domviol{1}, 'gams.transfer.symbol.domain.Violation'));
    t.assert(isa(domviol{2}, 'gams.transfer.symbol.domain.Violation'));
    t.assertEquals(domviol{1}.symbol.name, 'a1');
    t.assertEquals(domviol{2}.symbol.name, 'a2');
    t.assert(domviol{1}.dimension == 1);
    t.assert(domviol{2}.dimension == 1);
    t.assert(iscellstr(domviol{1}.violations));
    t.assert(iscellstr(domviol{2}.violations));
    t.assert(numel(domviol{1}.violations) == 1);
    t.assert(numel(domviol{2}.violations) == 1);
    t.assertEquals(domviol{1}.violations{1}, 'i0');
    t.assertEquals(lower(domviol{2}.violations{1}), 'i5');
end

function test_setRecords(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    i1 = gams.transfer.Set(gdx, 'i1');
    s1 = gams.transfer.Variable(gdx, 'x1', 'free', {'i'});
    s2 = gams.transfer.Variable(gdx, 'x2', 'free', {'i', '*'});
    s3 = gams.transfer.Variable(gdx, 'x3', 'free', {gdx.data.i1});

    t.add('set_records_string_1');
    gdx.modified = false;
    s1.setRecords('test');
    t.assertEquals(s1.format, 'struct');
    t.assert(isstruct(s1.records));
    t.assert(numel(fieldnames(s1.records)) == 1);
    t.assert(isfield(s1.records, 'i'));
    t.assert(numel(s1.records.i) == 1);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s1.records.i(1), 'test');
    else
        t.assert(s1.records.i(1) == 1);
    end
    uels = s1.getUELs(1);
    t.assert(numel(uels) == 1);
    t.assertEquals(uels{1}, 'test');
    t.assert(s1.isValid());
    t.assert(s1.modified);

    t.add('set_records_string_2');
    try
        t.assert(false);
        s2.setRecords('test');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Single string as records only accepted if symbol dimension equals 1.');
    end

    t.add('set_records_cellstr_1');
    gdx.modified = false;
    s1.setRecords({'test1', 'test2', 'test3'});
    t.assertEquals(s1.format, 'struct');
    t.assert(isstruct(s1.records));
    t.assert(numel(fieldnames(s1.records)) == 1);
    t.assert(isfield(s1.records, 'i'));
    t.assert(numel(s1.records.i) == 3);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s1.records.i(1), 'test1');
        t.assertEquals(s1.records.i(2), 'test2');
        t.assertEquals(s1.records.i(3), 'test3');
    else
        t.assert(s1.records.i(1) == 1);
        t.assert(s1.records.i(2) == 2);
        t.assert(s1.records.i(3) == 3);
    end
    uels = s1.getUELs(1);
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'test1');
    t.assertEquals(uels{2}, 'test2');
    t.assertEquals(uels{3}, 'test3');
    t.assert(s1.isValid());
    t.assert(s1.modified);

    t.add('set_records_cellstr_2');
    try
        t.assert(false);
        s2.setRecords({'test1', 'test2', 'test3'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'First dimension of cellstr must equal symbol dimension.');
    end

    t.add('set_records_cellstr_3');
    gdx.modified = false;
    s2.setRecords({'test11', 'test12', 'test13'; 'test21', 'test22', 'test23'});
    t.assertEquals(s2.format, 'struct');
    t.assert(isstruct(s2.records));
    t.assert(numel(fieldnames(s2.records)) == 2);
    t.assert(isfield(s2.records, 'i'));
    t.assert(isfield(s2.records, 'uni'));
    t.assert(numel(s2.records.i) == 3);
    t.assert(numel(s2.records.uni) == 3);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s2.records.i(1), 'test11');
        t.assertEquals(s2.records.i(2), 'test12');
        t.assertEquals(s2.records.i(3), 'test13');
        t.assertEquals(s2.records.uni(1), 'test21');
        t.assertEquals(s2.records.uni(2), 'test22');
        t.assertEquals(s2.records.uni(3), 'test23');
    else
        t.assert(s2.records.i(1) == 1);
        t.assert(s2.records.i(2) == 2);
        t.assert(s2.records.i(3) == 3);
        t.assert(s2.records.uni(1) == 1);
        t.assert(s2.records.uni(2) == 2);
        t.assert(s2.records.uni(3) == 3);
    end
    uels = s2.getUELs(1);
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'test11');
    t.assertEquals(uels{2}, 'test12');
    t.assertEquals(uels{3}, 'test13');
    uels = s2.getUELs(2);
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'test21');
    t.assertEquals(uels{2}, 'test22');
    t.assertEquals(uels{3}, 'test23');
    t.assert(s2.isValid());
    t.assert(s2.modified);

    i1.setRecords({'i1', 'i2', 'i3', 'i4'});

    t.add('set_records_numeric_1');
    try
        t.assert(false);
        s1.setRecords([1; 2; 3; 4]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Cannot create matrix records, because value size does not match symbol size.');
    end

    t.add('set_records_numeric_2');
    gdx.modified = false;
    s3.setRecords([1; 2; 3; 4]);
    t.assertEquals(s3.format, 'dense_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.level) == 4);
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 2);
    t.assert(s3.records.level(3) == 3);
    t.assert(s3.records.level(4) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_numeric_3');
    gdx.modified = false;
    s3.setRecords(sparse([1; 0; 0; 4]));
    t.assertEquals(s3.format, 'sparse_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.level) == 4);
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 0);
    t.assert(s3.records.level(3) == 0);
    t.assert(s3.records.level(4) == 4);
    t.assert(nnz(s3.records.level) == 2);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_numeric_4');
    try
        t.assert(false);
        s3.setRecords([1; 2; 3; 4; 5]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Cannot create matrix records, because value size does not match symbol size.');
    end

    t.add('set_records_cell_1');
    gdx.modified = false;
    s3.setRecords({[1; 2; 3; 4]});
    t.assertEquals(s3.format, 'dense_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.level) == 4);
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 2);
    t.assert(s3.records.level(3) == 3);
    t.assert(s3.records.level(4) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_cell_2');
    gdx.modified = false;
    s3.setRecords({{'i1', 'i4'}, [1; 4]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    uels = s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_cell_3');
    gdx.modified = false;
    s3.setRecords({[1; 4], {'i1', 'i4'}, [11; 44]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 3);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(isfield(s3.records, 'marginal'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    t.assert(numel(s3.records.marginal) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    uels = s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.records.marginal(1) == 11);
    t.assert(s3.records.marginal(2) == 44);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_cell_4');
    gdx.modified = false;
    s3.setRecords({[1; 4], {'i1', 'i4'}, [11; 44], [111; 444], [1111; 4444], [11111; 44444]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 6);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(isfield(s3.records, 'marginal'));
    t.assert(isfield(s3.records, 'lower'));
    t.assert(isfield(s3.records, 'upper'));
    t.assert(isfield(s3.records, 'scale'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    t.assert(numel(s3.records.marginal) == 2);
    t.assert(numel(s3.records.lower) == 2);
    t.assert(numel(s3.records.upper) == 2);
    t.assert(numel(s3.records.scale) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    uels = s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.records.marginal(1) == 11);
    t.assert(s3.records.marginal(2) == 44);
    t.assert(s3.records.lower(1) == 111);
    t.assert(s3.records.lower(2) == 444);
    t.assert(s3.records.upper(1) == 1111);
    t.assert(s3.records.upper(2) == 4444);
    t.assert(s3.records.scale(1) == 11111);
    t.assert(s3.records.scale(2) == 44444);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_cell_5');
    try
        t.assert(false);
        s2.setRecords({{'i1', 'i4'}, [1; 4]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Records have no domain column ''uni''.');
    end

    t.add('set_records_cell_6');
    try
        t.assert(false);
        s3.setRecords({{'i1', 'i4'}, [1; 4], {'i1', 'i4'}});
    catch e
        t.reset();
        t.assertEquals(e.message, 'More cellstr values than domains and string value fields.');
    end

    t.add('set_records_cell_7');
    try
        t.assert(false);
        s3.setRecords({{'i1', 'i4'}, [1; 4], [1; 4], [1; 4], [1; 4], [1; 4], [1; 4]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Too many value fields in records.');
    end

    t.add('set_records_struct_1');
    gdx.modified = false;
    s3.setRecords(struct('level', [1; 2; 3; 4]));
    t.assertEquals(s3.format, 'dense_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.level) == 4);
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 2);
    t.assert(s3.records.level(3) == 3);
    t.assert(s3.records.level(4) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_2');
    gdx.modified = false;
    s3.setRecords(struct('marginal', [1; 2; 3; 4]));
    t.assertEquals(s3.format, 'dense_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'marginal'));
    t.assert(numel(s3.records.marginal) == 4);
    t.assert(s3.records.marginal(1) == 1);
    t.assert(s3.records.marginal(2) == 2);
    t.assert(s3.records.marginal(3) == 3);
    t.assert(s3.records.marginal(4) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_3');
    try
        t.assert(false);
        s3.setRecords(struct('i1', {'i1', 'i4'}, 'level', [1; 4]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Unsupported records format.');
    end

    t.add('set_records_struct_4');
    gdx.modified = false;
    recs = struct();
    recs.i1 = {'i1', 'i4'};
    recs.level = [1; 4];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    uels = s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_5');
    gdx.modified = false;
    recs = struct();
    recs.i1 = {'i1', 'i4'};
    recs.level = [1; 4];
    recs.shit_field = [nan, inf];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_6');
    gdx.modified = false;
    recs = struct();
    recs.i1 = {'i1', 'i4'};
    recs.level = [1; 4];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(s3.records.i1(1), 'i1');
        t.assertEquals(s3.records.i1(2), 'i4');
    else
        t.assert(s3.records.i1(1) == 1);
        t.assert(s3.records.i1(2) == 2);
    end
    uels = s3.getUELs(1);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_7');
    recs = struct();
    recs.i1 = {'i1', 'i4'};
    recs.level = [1];
    try
        t.assert(false);
        s3.setRecords(recs);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Records value column ''level'' must have same size as other columns.');
    end

    t.add('set_records_struct_8');
    gdx.modified = false;
    s3.setRecords(struct('level', [1, 2, 3, 4]));
    t.assertEquals(s3.format, 'dense_matrix');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 1);
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.level) == 4);
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 2);
    t.assert(s3.records.level(3) == 3);
    t.assert(s3.records.level(4) == 4);
    t.assert(s3.isValid());
    t.assert(s3.modified);

    t.add('set_records_struct_9');
    try
        t.assert(false);
        s3.setRecords(struct('level', [1, 2, 3]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Cannot create matrix records, because value size does not match symbol size.');
    end

    if gams.transfer.Constants.SUPPORTS_TABLE
        t.add('set_records_table_1');
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            tbl = table(categorical({'i1'; 'i2'; 'i3'}), [1; 2; 3]);
        else
            tbl = table([1; 2; 3], [1; 2; 3]);
            % s3.setUELs({'i1'; 'i2'; 'i3'}, 1, 'rename', true); % need to set records first
        end
        try
            t.assert(false);
            s3.setRecords(tbl);
        catch
            t.reset();
        end

        t.add('set_records_table_2');
        gdx.modified = false;
        if gams.transfer.Constants.SUPPORTS_CATEGORICAL
            tbl = table(categorical({'i1'; 'i2'; 'i3'}), [1; 2; 3]);
        else
            tbl = table([1; 2; 3], [1; 2; 3]);
            % s3.setUELs({'i1'; 'i2'; 'i3'}, 1, 'rename', true); % need to set records first
        end
        tbl.Properties.VariableNames = {'i1', 'level'};
        s3.setRecords(tbl);
        if ~gams.transfer.Constants.SUPPORTS_CATEGORICAL
            s3.setUELs({'i1'; 'i2'; 'i3'}, 1, 'rename', true);
        end
        t.assertEquals(s3.format, 'table');
        t.assert(s3.isValid());
        t.assert(s3.modified);
    end

    t.add('set_records_set_element_text_1');
    gdx.modified = false;
    i1.setRecords({'i1', 'i2', 'i3', 'i4'}, {'text_i1', 'text_i2', 'text_i3', 'text_i4'});
    t.assert(i1.isValid());
    t.assertEquals(i1.format, 'struct');
    t.assert(numel(fieldnames(i1.records)) == 2);
    t.assert(isfield(i1.records, 'uni'));
    t.assert(isfield(i1.records, 'element_text'));
    t.assert(numel(i1.records.uni) == 4);
    t.assert(numel(i1.records.element_text) == 4);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(i1.records.uni(1), 'i1');
        t.assertEquals(i1.records.uni(2), 'i2');
        t.assertEquals(i1.records.uni(3), 'i3');
        t.assertEquals(i1.records.uni(4), 'i4');
        t.assertEquals(i1.records.element_text(1), 'text_i1');
        t.assertEquals(i1.records.element_text(2), 'text_i2');
        t.assertEquals(i1.records.element_text(3), 'text_i3');
        t.assertEquals(i1.records.element_text(4), 'text_i4');
    else
        t.assert(i1.records.uni(1) == 1);
        t.assert(i1.records.uni(2) == 2);
        t.assert(i1.records.uni(3) == 3);
        t.assert(i1.records.uni(4) == 4);
        t.assertEquals(i1.records.element_text{1}, 'text_i1');
        t.assertEquals(i1.records.element_text{2}, 'text_i2');
        t.assertEquals(i1.records.element_text{3}, 'text_i3');
        t.assertEquals(i1.records.element_text{4}, 'text_i4');
    end
    uels = i1.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i2');
    t.assertEquals(uels{3}, 'i3');
    t.assertEquals(uels{4}, 'i4');
    t.assert(i1.modified);

    t.add('set_records_set_element_text_2');
    gdx.modified = false;
    recs = struct();
    recs.uni = {'i1', 'i2', 'i3', 'i4'};
    recs.element_text = {'text_i1', 'text_i2', 'text_i3', 'text_i4'};
    i1.setRecords(recs);
    t.assert(i1.isValid());
    t.assertEquals(i1.format, 'struct');
    t.assert(numel(fieldnames(i1.records)) == 2);
    t.assert(isfield(i1.records, 'uni'));
    t.assert(isfield(i1.records, 'element_text'));
    t.assert(numel(i1.records.uni) == 4);
    t.assert(numel(i1.records.element_text) == 4);
    if gams.transfer.Constants.SUPPORTS_CATEGORICAL
        t.assertEquals(i1.records.uni(1), 'i1');
        t.assertEquals(i1.records.uni(2), 'i2');
        t.assertEquals(i1.records.uni(3), 'i3');
        t.assertEquals(i1.records.uni(4), 'i4');
        t.assertEquals(i1.records.element_text(1), 'text_i1');
        t.assertEquals(i1.records.element_text(2), 'text_i2');
        t.assertEquals(i1.records.element_text(3), 'text_i3');
        t.assertEquals(i1.records.element_text(4), 'text_i4');
    else
        t.assert(i1.records.uni(1) == 1);
        t.assert(i1.records.uni(2) == 2);
        t.assert(i1.records.uni(3) == 3);
        t.assert(i1.records.uni(4) == 4);
        t.assertEquals(i1.records.element_text{1}, 'text_i1');
        t.assertEquals(i1.records.element_text{2}, 'text_i2');
        t.assertEquals(i1.records.element_text{3}, 'text_i3');
        t.assertEquals(i1.records.element_text{4}, 'text_i4');
    end
    uels = i1.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i2');
    t.assertEquals(uels{3}, 'i3');
    t.assertEquals(uels{4}, 'i4');
    t.assert(i1.modified);

end

function test_writeUnordered(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i = gams.transfer.Set(gdx, 'i', 'records', {'i1', 'i2', 'i3', 'i4', 'i5'});
    j = gams.transfer.Set(gdx, 'j', 'records', {'j1', 'j2', 'j3', 'j4', 'j5'});
    c = gams.transfer.Parameter(gdx, 'c', {i,j});
    c.setRecords({'i1', 'i1', 'i2', 'i2', 'i4', 'i4', 'i3', 'i3'}, ...
        {'j1', 'j2', 'j1', 'j2', 'j1', 'j2', 'j1', 'j2'}, ...
        [11, 12, 21, 22, 41, 42, 31, 32]);

    t.add('write_unordered_1')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_gdx_write: GDX error in record c(i3,j1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(i3,j1): Data not sorted when writing raw');
        end
    end

    t.add('write_unordered_2')
    gdx.write(write_filename, 'sorted', false);

    t.add('write_unordered_3')
    gdx.write(write_filename, 'uel_priority', {'i1', 'i2', 'i4', 'i3'});

    c.setRecords({'i1', 'i1', 'i2', 'i2'}, {'j1', 'j2', 'j2', 'j1'}, ...
        [11, 12, 22, 21]);

    t.add('write_unordered_3')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_gdx_write: GDX error in record c(i2,j1): Data not sorted when writing raw');
        else
            t.assertEquals(e.message, 'GDX error in record c(i2,j1): Data not sorted when writing raw');
        end
    end

    t.add('write_unordered_4')
    gdx.write(write_filename, 'sorted', false);

end

function test_reorder(t, cfg)

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    s1 = gams.transfer.Set(gdx, 's1', 'records', {'i1', 'i2', 'i3', 'i4', 'i5'});
    s2 = gams.transfer.Set(gdx, 's2');
    s3 = gams.transfer.Set(gdx, 's3');
    s4 = gams.transfer.Set(gdx, 's4', 'records', {'j1', 'j2', 'j3', 'j4', 'j5'});

    t.add('reorder_1');
    t.assert(numel(fieldnames(gdx.data)) == 4);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's2');
    t.assertEquals(fields{3}, 's3');
    t.assertEquals(fields{4}, 's4');
    try
        gdx.write(write_filename);
    catch
        t.assert(false);
    end

    s2.domain = {s1};
    s3.domain = {s4};

    t.add('reorder_2');
    gdx.modified = false;
    t.assert(numel(fieldnames(gdx.data)) == 4);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's2');
    t.assertEquals(fields{3}, 's3');
    t.assertEquals(fields{4}, 's4');
    gdx.isValid();
    t.assert(gdx.modified);
    t.assert(~s1.modified);
    t.assert(~s2.modified);
    t.assert(~s3.modified);
    t.assert(~s4.modified);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's2');
    t.assertEquals(fields{3}, 's4');
    t.assertEquals(fields{4}, 's3');
    try
        gdx.write(write_filename);
    catch e
        t.assert(false);
    end

    s2.domain = {s3};

    gdx.modified = false;
    gdx.reorderSymbols();

    t.add('reorder_3');
    t.assert(gdx.modified);
    t.assert(~s1.modified);
    t.assert(~s2.modified);
    t.assert(~s3.modified);
    t.assert(~s4.modified);
    t.assert(numel(fieldnames(gdx.data)) == 4);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's4');
    t.assertEquals(fields{3}, 's3');
    t.assertEquals(fields{4}, 's2');
    try
        gdx.write(write_filename);
    catch
        t.assert(false);
    end

    s2.domain = {s3};
    s3.domain = {s2};

    t.add('reorder_4');
    try
        t.assert(false);
        gdx.reorderSymbols();
    catch e
        t.reset();
        t.assertEquals(e.message, 'Circular domain set dependency in: [s2,s3].');
    end

    gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);

    s1 = gams.transfer.Set(gdx, 's1', 'records', {'i1', 'i2', 'i3', 'i4', 'i5'});
    s1.domain = {s1};

    t.add('reorder_5');
    try
        t.assert(false);
        gdx.reorderSymbols();
    catch e
        t.reset();
        t.assertEquals(e.message, 'Circular domain set dependency in: [s1].');
    end

end

function test_transformRecords(t, cfg)

    formats = {'struct', 'table', 'dense_matrix', 'sparse_matrix'};
    gdx = cell(1, numel(formats));
    i_recs = cell(1, numel(formats));
    j_recs = cell(1, numel(formats));
    a_recs = cell(1, numel(formats));
    b_recs = cell(1, numel(formats));
    x_recs = cell(1, numel(formats));
    i_format = cell(1, numel(formats));
    j_format = cell(1, numel(formats));
    a_format = cell(1, numel(formats));
    b_format = cell(1, numel(formats));
    x_format = cell(1, numel(formats));

    for i = 1:numel(formats)
        if strcmp(formats{i}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
            continue
        end
        gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
        gdx.read(cfg.filenames{1}, 'format', formats{i});
        i_recs{i} = gdx.data.i.records;
        j_recs{i} = gdx.data.j.records;
        a_recs{i} = gdx.data.a.records;
        b_recs{i} = gdx.data.b.records;
        x_recs{i} = gdx.data.x.records;
        i_format{i} = gdx.data.i.format;
        j_format{i} = gdx.data.j.format;
        a_format{i} = gdx.data.a.format;
        b_format{i} = gdx.data.b.format;
        x_format{i} = gdx.data.x.format;
    end

    for i = 1:numel(formats)
        if strcmp(formats{i}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
            continue
        end

        for j = 1:numel(formats)
            if strcmp(formats{j}, 'table') && ~gams.transfer.Constants.SUPPORTS_TABLE
                continue
            end

            t.add(sprintf('transform_records_%s_to_%s', formats{i}, formats{j}));
            gdx = gams.transfer.Container('gams_dir', cfg.gams_dir);
            gdx.read(cfg.filenames{1}, 'format', formats{i});
            try
                if strcmp(formats{j}, 'dense_matrix') || strcmp(formats{j}, 'sparse_matrix')
                    t.assert(false);
                else
                    t.assert(true);
                end
                gdx.data.i.transformRecords(formats{j});
                gdx.data.j.transformRecords(formats{j});
            catch
                if strcmp(formats{j}, 'dense_matrix') || strcmp(formats{j}, 'sparse_matrix')
                    t.reset();
                end
            end
            gdx.data.a.transformRecords(formats{j});
            gdx.data.b.transformRecords(formats{j});
            gdx.data.x.transformRecords(formats{j});
            t.assert(gdx.data.i.isValid());
            t.assert(gdx.data.j.isValid());
            t.assert(gdx.data.a.isValid());
            t.assert(gdx.data.b.isValid());
            t.assert(gdx.data.x.isValid());
            if strcmp(formats{j}, 'dense_matrix') || strcmp(formats{j}, 'sparse_matrix')
                t.assertEquals(gdx.data.i.format, i_format{i});
                t.assertEquals(gdx.data.j.format, j_format{i});
            else
                t.assertEquals(gdx.data.i.format, i_format{j});
                t.assertEquals(gdx.data.j.format, j_format{j});
            end
            t.assertEquals(gdx.data.a.format, a_format{j});
            t.assertEquals(gdx.data.b.format, b_format{j});
            t.assertEquals(gdx.data.x.format, x_format{j});
            if strcmp(formats{j}, 'dense_matrix') || strcmp(formats{j}, 'sparse_matrix')
                t.assertEquals(gdx.data.i.records, i_recs{i});
                t.assertEquals(gdx.data.j.records, j_recs{i});
            else
                t.assertEquals(gdx.data.i.records, i_recs{j});
                t.assertEquals(gdx.data.j.records, j_recs{j});
            end
            t.assertEquals(gdx.data.a.records, a_recs{j});
            t.assertEquals(gdx.data.b.records, b_recs{j});
            t.assertEquals(gdx.data.x.records, x_recs{j});
        end
    end
end
