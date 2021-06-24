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

function test_symbols(t, cfg)
    test_addSymbols(t, cfg);
    test_changeSymbol(t, cfg);
    test_defaultvalues(t, cfg);
    test_domainViolation(t, cfg);
    test_setRecords(t, cfg);
    test_writeUnordered(t, cfg);
    test_reorder(t, cfg);
    test_transformRecords(t, cfg)
end

function test_addSymbols(t, cfg)

    gdx = GAMSTransfer.Container();

    t.add('add_symbols_set_1');
    s1 = GAMSTransfer.Set(gdx, 's1');
    t.testEmptySymbol(s1);
    t.assertEquals(s1.name, 's1');
    t.assertEquals(s1.description, '');
    t.assert(~s1.singleton);
    t.assert(s1.dimension == 1);
    t.assert(numel(s1.domain) == 1);
    t.assertEquals(s1.domain{1}, '*');
    t.assert(numel(s1.domain_label) == 1);
    t.assert(s1.domain_label{1} == 'uni_1');
    t.assertEquals(s1.domain_info, 'regular');
    t.assert(numel(s1.size) == 1);
    t.assert(isnan(s1.size(1)));
    t.assert(strcmp(s1.format, 'empty'));
    t.assert(s1.number_records == 0);
    t.assert(isfield(s1.uels, 'uni_1'));
    t.assert(numel(s1.uels.uni_1) == 0);
    t.assert(s1.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 1);
    t.assert(isfield(gdx.data, 's1'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s1 == s1);
    end

    t.add('add_symbols_set_2');
    s2 = GAMSTransfer.Set(gdx, 's2', {s1}, 'description', 'descr s2');
    t.testEmptySymbol(s2);
    t.assertEquals(s2.name, 's2');
    t.assertEquals(s2.description, 'descr s2');
    t.assert(~s2.singleton);
    t.assert(s2.dimension == 1);
    t.assert(numel(s2.domain) == 1);
    if gdx.features.handle_comparison
        t.assert(s2.domain{1} == s1);
    end
    t.assertEquals(s2.domain{1}.name, 's1');
    t.assert(numel(s2.domain_label) == 1);
    t.assert(s2.domain_label{1} == 's1_1');
    t.assertEquals(s2.domain_info, 'regular');
    t.assert(numel(s2.size) == 1);
    t.assert(s2.size(1) == 0);
    t.assert(strcmp(s2.format, 'empty'));
    t.assert(s2.number_records == 0);
    t.assert(isfield(s2.uels, 's1_1'));
    t.assert(numel(s2.uels.s1_1) == 0);
    t.assert(s2.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 2);
    t.assert(isfield(gdx.data, 's2'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s2 == s2);
    end

    t.add('add_symbols_set_3');
    s3 = GAMSTransfer.Set(gdx, 's3', {s1, '*'}, 'singleton', true);
    t.testEmptySymbol(s3);
    t.assertEquals(s3.name, 's3');
    t.assertEquals(s3.description, '');
    t.assert(s3.singleton);
    t.assert(s3.dimension == 2);
    t.assert(numel(s3.domain) == 2);
    if gdx.features.handle_comparison
        t.assert(s3.domain{1} == s1);
    end
    t.assertEquals(s3.domain{1}.name, 's1');
    t.assertEquals(s3.domain{2}, '*');
    t.assert(numel(s3.domain_label) == 2);
    t.assert(s3.domain_label{1} == 's1_1');
    t.assert(s3.domain_label{2} == 'uni_2');
    t.assertEquals(s3.domain_info, 'regular');
    t.assert(numel(s3.size) == 2);
    t.assert(s3.size(1) == 0);
    t.assert(isnan(s3.size(2)));
    t.assert(strcmp(s3.format, 'empty'));
    t.assert(s3.number_records == 0);
    t.assert(isfield(s3.uels, 's1_1'));
    t.assert(isfield(s3.uels, 'uni_2'));
    t.assert(numel(s3.uels.s1_1) == 0);
    t.assert(numel(s3.uels.uni_2) == 0);
    t.assert(s3.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 3);
    t.assert(isfield(gdx.data, 's3'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s3 == s3);
    end

    t.add('add_symbols_set_4');
    s4 = GAMSTransfer.Set(gdx, 's4', s2, 'description', 'descr s4', 'singleton', true);
    t.testEmptySymbol(s4);
    t.assertEquals(s4.name, 's4');
    t.assertEquals(s4.description, 'descr s4');
    t.assert(s4.singleton);
    t.assert(s4.dimension == 1);
    t.assert(numel(s4.domain) == 1);
    if gdx.features.handle_comparison
        t.assert(s4.domain{1} == s2);
    end
    t.assertEquals(s4.domain{1}.name, 's2');
    t.assert(numel(s4.domain_label) == 1);
    t.assert(s4.domain_label{1} == 's2_1');
    t.assertEquals(s4.domain_info, 'regular');
    t.assert(numel(s4.size) == 1);
    t.assert(s4.size(1) == 0);
    t.assert(strcmp(s4.format, 'empty'));
    t.assert(s4.number_records == 0);
    t.assert(isfield(s4.uels, 's2_1'));
    t.assert(numel(s4.uels.s2_1) == 0);
    t.assert(s4.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 4);
    t.assert(isfield(gdx.data, 's4'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s4 == s4);
    end

    t.add('add_symbols_set_5');
    s5 = GAMSTransfer.Set(gdx, 's5', {'s1', s2});
    t.testEmptySymbol(s5);
    t.assertEquals(s5.name, 's5');
    t.assertEquals(s5.description, '');
    t.assert(~s5.singleton);
    t.assert(s5.dimension == 2);
    t.assert(numel(s5.domain) == 2);
    t.assert(s5.domain{1} == 's1');
    if gdx.features.handle_comparison
        t.assert(s5.domain{2} == s2);
    end
    t.assertEquals(s5.domain{2}.name, 's2');
    t.assert(numel(s5.domain_label) == 2);
    t.assert(s5.domain_label{1} == 's1_1');
    t.assert(s5.domain_label{2} == 's2_2');
    t.assertEquals(s5.domain_info, 'relaxed');
    t.assert(numel(s5.size) == 2);
    t.assert(isnan(s5.size(1)));
    t.assert(s5.size(2) == 0);
    t.assert(strcmp(s5.format, 'empty'));
    t.assert(s5.number_records == 0);
    t.assert(isfield(s5.uels, 's1_1'));
    t.assert(isfield(s5.uels, 's2_2'));
    t.assert(numel(s5.uels.s1_1) == 0);
    t.assert(numel(s5.uels.s2_2) == 0);
    t.assert(s5.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 5);
    t.assert(isfield(gdx.data, 's5'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s5 == s5);
    end

    t.add('add_symbols_set_6');
    s6 = GAMSTransfer.Set(gdx, 's6', 's1');
    t.testEmptySymbol(s6);
    t.assertEquals(s6.name, 's6');
    t.assertEquals(s6.description, '');
    t.assert(~s6.singleton);
    t.assert(s6.dimension == 1);
    t.assert(numel(s6.domain) == 1);
    t.assert(s6.domain{1} == 's1');
    t.assert(numel(s6.domain_label) == 1);
    t.assert(s6.domain_label{1} == 's1_1');
    t.assertEquals(s6.domain_info, 'relaxed');
    t.assert(numel(s6.size) == 1);
    t.assert(isnan(s6.size(1)));
    t.assert(strcmp(s6.format, 'empty'));
    t.assert(s6.number_records == 0);
    t.assert(isfield(s6.uels, 's1_1'));
    t.assert(numel(s6.uels.s1_1) == 0);
    t.assert(s6.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 6);
    t.assert(isfield(gdx.data, 's6'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.s6 == s6);
    end

    t.add('add_symbols_set_fails');
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            GAMSTransfer.Set(gdx, 's', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's', s1, [], 'singleton', 1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Set(gdx, 's', s3);
    catch
        t.reset();
    end

    t.add('add_symbols_alias_1');
    a1 = GAMSTransfer.Alias(gdx, 'a1', s1);
    t.testEmptySymbol(a1);
    t.assertEquals(a1.name, 'a1');
    if gdx.features.handle_comparison
        t.assert(a1.aliased_with == s1);
    end
    t.assertEquals(a1.aliased_with.name, 's1');
    t.assert(a1.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 7);
    t.assert(isfield(gdx.data, 'a1'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.a1 == a1);
    end

    t.add('add_symbols_alias_2');
    a2 = GAMSTransfer.Alias(gdx, 'a2', a1);
    t.testEmptySymbol(a2);
    t.assertEquals(a2.name, 'a2');
    if gdx.features.handle_comparison
        t.assert(a2.aliased_with == s1);
    end
    t.assertEquals(a2.aliased_with.name, 's1');
    t.assert(a2.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 8);
    t.assert(isfield(gdx.data, 'a2'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.a2 == a2);
    end

    t.add('add_symbols_alias_3');
    a3 = GAMSTransfer.Alias(gdx, 'a3', a2);
    t.testEmptySymbol(a3);
    t.assertEquals(a3.name, 'a3');
    if gdx.features.handle_comparison
        t.assert(a3.aliased_with == s1);
    end
    t.assertEquals(a3.aliased_with.name, 's1');
    t.assert(a3.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 9);
    t.assert(isfield(gdx.data, 'a3'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.a3 == a3);
    end

    t.add('add_symbols_parameter_1');
    p1 = GAMSTransfer.Parameter(gdx, 'p1');
    t.testEmptySymbol(p1);
    t.assertEquals(p1.name, 'p1');
    t.assertEquals(p1.description, '');
    t.assert(p1.dimension == 0);
    t.assert(numel(p1.domain) == 0);
    t.assert(numel(p1.domain_label) == 0);
    t.assertEquals(p1.domain_info, 'regular');
    t.assert(numel(p1.size) == 0);
    t.assert(strcmp(p1.format, 'empty'));
    t.assert(p1.number_records == 0);
    t.assert(numel(fieldnames(p1.uels)) == 0);
    t.assert(p1.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 10);
    t.assert(isfield(gdx.data, 'p1'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.p1 == p1);
    end

    t.add('add_symbols_parameter_2');
    p2 = GAMSTransfer.Parameter(gdx, 'p2', s1, 'description', 'descr par 2');
    t.testEmptySymbol(p2);
    t.assertEquals(p2.name, 'p2');
    t.assertEquals(p2.description, 'descr par 2');
    t.assert(p2.dimension == 1);
    t.assert(numel(p2.domain) == 1);
    if gdx.features.handle_comparison
        t.assert(p2.domain{1} == s1);
    end
    t.assertEquals(p2.domain{1}.name, 's1');
    t.assert(numel(p2.domain_label) == 1);
    t.assertEquals(p2.domain_label{1}, 's1_1');
    t.assertEquals(p2.domain_info, 'regular');
    t.assert(numel(p2.size) == 1);
    t.assert(p2.size(1) == 0);
    t.assert(strcmp(p2.format, 'empty'));
    t.assert(p2.number_records == 0);
    t.assert(isfield(p2.uels, 's1_1'));
    t.assert(numel(p2.uels.s1_1) == 0);
    t.assert(p2.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 11);
    t.assert(isfield(gdx.data, 'p2'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.p2 == p2);
    end

    t.add('add_symbols_parameter_3');
    p3 = GAMSTransfer.Parameter(gdx, 'p3', {s1, '*', 's2'}, 'description', 'descr par 3');
    t.testEmptySymbol(p3);
    t.assertEquals(p3.name, 'p3');
    t.assertEquals(p3.description, 'descr par 3');
    t.assert(p3.dimension == 3);
    t.assert(numel(p3.domain) == 3);
    if gdx.features.handle_comparison
        t.assert(p3.domain{1} == s1);
    end
    t.assertEquals(p3.domain{1}.name, 's1');
    t.assertEquals(p3.domain{2}, '*');
    t.assert(p3.domain{3} == 's2');
    t.assert(numel(p3.domain_label) == 3);
    t.assertEquals(p3.domain_label{1}, 's1_1');
    t.assertEquals(p3.domain_label{2}, 'uni_2');
    t.assertEquals(p3.domain_label{3}, 's2_3');
    t.assertEquals(p3.domain_info, 'relaxed');
    t.assert(numel(p3.size) == 3);
    t.assert(p3.size(1) == 0);
    t.assert(isnan(p3.size(2)));
    t.assert(isnan(p3.size(3)));
    t.assert(strcmp(p3.format, 'empty'));
    t.assert(p3.number_records == 0);
    t.assert(isfield(p3.uels, 's1_1'));
    t.assert(isfield(p3.uels, 'uni_2'));
    t.assert(isfield(p3.uels, 's2_3'));
    t.assert(numel(p3.uels.s1_1) == 0);
    t.assert(numel(p3.uels.uni_2) == 0);
    t.assert(numel(p3.uels.s2_3) == 0);
    t.assert(p3.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 12);
    t.assert(isfield(gdx.data, 'p3'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.p3 == p3);
    end

    t.add('add_symbols_parameter_fails');
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 's', 2);
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
        GAMSTransfer.Parameter(gdx, 's', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Parameter(gdx, 's', s3);
    catch
        t.reset();
    end

    t.add('add_symbols_variable_1');
    v1 = GAMSTransfer.Variable(gdx, 'v1');
    t.testEmptySymbol(v1);
    t.assertEquals(v1.name, 'v1');
    t.assertEquals(v1.description, '');
    t.assert(v1.type == 'free');
    t.assert(v1.dimension == 0);
    t.assert(numel(v1.domain) == 0);
    t.assert(numel(v1.domain_label) == 0);
    t.assertEquals(v1.domain_info, 'regular');
    t.assert(numel(v1.size) == 0);
    t.assert(strcmp(v1.format, 'empty'));
    t.assert(v1.number_records == 0);
    t.assert(numel(fieldnames(v1.uels)) == 0);
    t.assert(v1.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 13);
    t.assert(isfield(gdx.data, 'v1'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.v1 == v1);
    end

    t.add('add_symbols_variable_2');
    v2 = GAMSTransfer.Variable(gdx, 'v2', GAMSTransfer.VariableType.BINARY, {}, 'description', 'descr var 2');
    t.testEmptySymbol(v2);
    t.assertEquals(v2.name, 'v2');
    t.assertEquals(v2.description, 'descr var 2');
    t.assert(v2.type == 'binary');
    t.assert(v2.dimension == 0);
    t.assert(numel(v2.domain) == 0);
    t.assert(numel(v2.domain_label) == 0);
    t.assertEquals(v2.domain_info, 'regular');
    t.assert(numel(v2.size) == 0);
    t.assert(strcmp(v2.format, 'empty'));
    t.assert(v2.number_records == 0);
    t.assert(numel(fieldnames(v2.uels)) == 0);
    t.assert(v2.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 14);
    t.assert(isfield(gdx.data, 'v2'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.v2 == v2);
    end

    t.add('add_symbols_variable_3');
    v3 = GAMSTransfer.Variable(gdx, 'v3', 'sos1', {s1, '*'});
    t.testEmptySymbol(v3);
    t.assertEquals(v3.name, 'v3');
    t.assertEquals(v3.description, '');
    t.assert(v3.type == 'sos1');
    t.assert(v3.dimension == 2);
    t.assert(numel(v3.domain) == 2);
    if gdx.features.handle_comparison
        t.assert(v3.domain{1} == s1);
    end
    t.assertEquals(v3.domain{1}.name, 's1');
    t.assertEquals(v3.domain{2}, '*');
    t.assert(numel(v3.domain_label) == 2);
    t.assertEquals(v3.domain_label{1}, 's1_1');
    t.assertEquals(v3.domain_label{2}, 'uni_2');
    t.assertEquals(v3.domain_info, 'regular');
    t.assert(numel(v3.size) == 2);
    t.assert(v3.size(1) == 0);
    t.assert(isnan(v3.size(2)));
    t.assert(strcmp(v3.format, 'empty'));
    t.assert(v3.number_records == 0);
    t.assert(isfield(v3.uels, 's1_1'));
    t.assert(isfield(v3.uels, 'uni_2'));
    t.assert(numel(v3.uels.s1_1) == 0);
    t.assert(numel(v3.uels.uni_2) == 0);
    t.assert(v3.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 15);
    t.assert(isfield(gdx.data, 'v3'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.v3 == v3);
    end

    t.add('add_symbols_variable_4');
    v = GAMSTransfer.Variable(gdx, 'v41', 'binary');
    t.assertEquals(v.type, 'binary');
    v = GAMSTransfer.Variable(gdx, 'v42', 'integer');
    t.assertEquals(v.type, 'integer');
    v = GAMSTransfer.Variable(gdx, 'v43', 'positive');
    t.assertEquals(v.type, 'positive');
    v = GAMSTransfer.Variable(gdx, 'v44', 'negative');
    t.assertEquals(v.type, 'negative');
    v = GAMSTransfer.Variable(gdx, 'v45', 'free');
    t.assertEquals(v.type, 'free');
    v = GAMSTransfer.Variable(gdx, 'v46', 'sos1');
    t.assertEquals(v.type, 'sos1');
    v = GAMSTransfer.Variable(gdx, 'v47', 'sos2');
    t.assertEquals(v.type, 'sos2');
    v = GAMSTransfer.Variable(gdx, 'v48', 'semiint');
    t.assertEquals(v.type, 'semiint');
    v = GAMSTransfer.Variable(gdx, 'v49', 'semicont');
    t.assertEquals(v.type, 'semicont');

    t.add('add_symbols_variable_5');
    v = GAMSTransfer.Variable(gdx, 'v51', 1);
    t.assertEquals(v.type, 'binary');
    v = GAMSTransfer.Variable(gdx, 'v52', 2);
    t.assertEquals(v.type, 'integer');
    v = GAMSTransfer.Variable(gdx, 'v53', 3);
    t.assertEquals(v.type, 'positive');
    v = GAMSTransfer.Variable(gdx, 'v54', 4);
    t.assertEquals(v.type, 'negative');
    v = GAMSTransfer.Variable(gdx, 'v55', 5);
    t.assertEquals(v.type, 'free');
    v = GAMSTransfer.Variable(gdx, 'v56', 6);
    t.assertEquals(v.type, 'sos1');
    v = GAMSTransfer.Variable(gdx, 'v57', 7);
    t.assertEquals(v.type, 'sos2');
    v = GAMSTransfer.Variable(gdx, 'v58', 8);
    t.assertEquals(v.type, 'semicont');
    v = GAMSTransfer.Variable(gdx, 'v59', 9);
    t.assertEquals(v.type, 'semiint');

    t.add('add_symbols_variable_fails');
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, s1, 'stupid');
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 's', 'free', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 's', 'free', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            GAMSTransfer.Variable(gdx, 's', 'free', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 's', 'free', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Variable(gdx, 's', 'free', s3);
    catch
        t.reset();
    end

    t.add('add_symbols_equation_1');
    e1 = GAMSTransfer.Equation(gdx, 'e1');
    t.testEmptySymbol(e1);
    t.assertEquals(e1.name, 'e1');
    t.assertEquals(e1.description, '');
    t.assert(e1.type == 'nonbinding');
    t.assert(e1.dimension == 0);
    t.assert(numel(e1.domain) == 0);
    t.assert(numel(e1.domain_label) == 0);
    t.assertEquals(e1.domain_info, 'regular');
    t.assert(numel(e1.size) == 0);
    t.assert(strcmp(e1.format, 'empty'));
    t.assert(e1.number_records == 0);
    t.assert(numel(fieldnames(e1.uels)) == 0);
    t.assert(e1.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 34);
    t.assert(isfield(gdx.data, 'e1'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.e1 == e1);
    end

    t.add('add_symbols_equation_2');
    e2 = GAMSTransfer.Equation(gdx, 'e2', GAMSTransfer.EquationType.EQ, {}, 'description', 'descr equ 2');
    t.testEmptySymbol(e2);
    t.assertEquals(e2.name, 'e2');
    t.assertEquals(e2.description, 'descr equ 2');
    t.assert(e2.type == 'eq');
    t.assert(e2.dimension == 0);
    t.assert(numel(e2.domain) == 0);
    t.assert(numel(e2.domain_label) == 0);
    t.assertEquals(e2.domain_info, 'regular');
    t.assert(numel(e2.size) == 0);
    t.assert(strcmp(e2.format, 'empty'));
    t.assert(e2.number_records == 0);
    t.assert(numel(fieldnames(e2.uels)) == 0);
    t.assert(e2.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 35);
    t.assert(isfield(gdx.data, 'e2'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.e2 == e2);
    end

    t.add('add_symbols_equation_3');
    e3 = GAMSTransfer.Equation(gdx, 'e3', 'leq', {s1, '*'});
    t.testEmptySymbol(e3);
    t.assertEquals(e3.name, 'e3');
    t.assertEquals(e3.description, '');
    t.assert(e3.type == 'leq');
    t.assert(e3.dimension == 2);
    t.assert(numel(e3.domain) == 2);
    if gdx.features.handle_comparison
        t.assert(e3.domain{1} == s1);
    end
    t.assertEquals(s3.domain{1}.name, 's1');
    t.assertEquals(e3.domain{2}, '*');
    t.assert(numel(e3.domain_label) == 2);
    t.assertEquals(e3.domain_label{1}, 's1_1');
    t.assertEquals(e3.domain_label{2}, 'uni_2');
    t.assertEquals(e3.domain_info, 'regular');
    t.assert(numel(e3.size) == 2);
    t.assert(e3.size(1) == 0);
    t.assert(isnan(e3.size(2)));
    t.assert(strcmp(e3.format, 'empty'));
    t.assert(e3.number_records == 0);
    t.assert(isfield(e3.uels, 's1_1'));
    t.assert(isfield(e3.uels, 'uni_2'));
    t.assert(numel(e3.uels.s1_1) == 0);
    t.assert(numel(e3.uels.uni_2) == 0);
    t.assert(e3.is_valid);
    t.assert(numel(fieldnames(gdx.data)) == 36);
    t.assert(isfield(gdx.data, 'e3'));
    if gdx.features.handle_comparison
        t.assert(gdx.data.e3 == e3);
    end

    t.add('add_symbols_equation_4');
    e = GAMSTransfer.Equation(gdx, 'e41', 'eq');
    t.assertEquals(e.type, 'eq');
    e = GAMSTransfer.Equation(gdx, 'e42', 'geq');
    t.assertEquals(e.type, 'geq');
    e = GAMSTransfer.Equation(gdx, 'e43', 'leq');
    t.assertEquals(e.type, 'leq');
    e = GAMSTransfer.Equation(gdx, 'e44', 'nonbinding');
    t.assertEquals(e.type, 'nonbinding');
    e = GAMSTransfer.Equation(gdx, 'e45', 'external');
    t.assertEquals(e.type, 'external');
    e = GAMSTransfer.Equation(gdx, 'e46', 'cone');
    t.assertEquals(e.type, 'cone');
    e = GAMSTransfer.Equation(gdx, 'e47', 'boolean');
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_5');
    e = GAMSTransfer.Equation(gdx, 'e51', 'e');
    t.assertEquals(e.type, 'eq');
    e = GAMSTransfer.Equation(gdx, 'e52', 'g');
    t.assertEquals(e.type, 'geq');
    e = GAMSTransfer.Equation(gdx, 'e53', 'l');
    t.assertEquals(e.type, 'leq');
    e = GAMSTransfer.Equation(gdx, 'e54', 'n');
    t.assertEquals(e.type, 'nonbinding');
    e = GAMSTransfer.Equation(gdx, 'e55', 'x');
    t.assertEquals(e.type, 'external');
    e = GAMSTransfer.Equation(gdx, 'e56', 'c');
    t.assertEquals(e.type, 'cone');
    e = GAMSTransfer.Equation(gdx, 'e57', 'b');
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_6');
    e = GAMSTransfer.Equation(gdx, 'e61', 0);
    t.assertEquals(e.type, 'eq');
    e = GAMSTransfer.Equation(gdx, 'e62', 1);
    t.assertEquals(e.type, 'geq');
    e = GAMSTransfer.Equation(gdx, 'e63', 2);
    t.assertEquals(e.type, 'leq');
    e = GAMSTransfer.Equation(gdx, 'e64', 3);
    t.assertEquals(e.type, 'nonbinding');
    e = GAMSTransfer.Equation(gdx, 'e65', 4);
    t.assertEquals(e.type, 'external');
    e = GAMSTransfer.Equation(gdx, 'e66', 5);
    t.assertEquals(e.type, 'cone');
    e = GAMSTransfer.Equation(gdx, 'e67', 6);
    t.assertEquals(e.type, 'boolean');

    t.add('add_symbols_equation_fails');
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 4);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, s1);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, s1, 'stupid');
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 's', 'e', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 's', 'e', {2, 3});
    catch
        t.reset();
    end
    if exist('OCTAVE_VERSION', 'builtin') <= 0
        try
            t.assert(false);
            GAMSTransfer.Equation(gdx, 's', 'e', ["s1", "s2"]);
        catch
            t.reset();
        end
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 's', 'e', s1, [], 'description', 2);
    catch
        t.reset();
    end
    try
        t.assert(false);
        GAMSTransfer.Equation(gdx, 's', 'e', s3);
    catch
        t.reset();
    end

end

function test_changeSymbol(t, cfg)

    gdx = GAMSTransfer.Container();
    i1 = GAMSTransfer.Set(gdx, 'i1');
    x1 = GAMSTransfer.Variable(gdx, 'x1', 'free', {i1});
    x2 = GAMSTransfer.Variable(gdx, 'x2', 'free', {i1,i1});

    t.add('change_symbol_name');
    t.assertEquals(x1.name, 'x1');
    t.assert(isfield(gdx.data, 'x1'));
    t.assert(~isfield(gdx.data, 'xx1'));
    vars = gdx.listVariables();
    t.assert(numel(vars) == 2);
    t.assertEquals(vars{1}, 'x1');
    x1.name = 'xx1';
    t.assertEquals(x1.name, 'xx1');
    t.assert(~isfield(gdx.data, 'x1'));
    t.assert(isfield(gdx.data, 'xx1'));
    vars = gdx.listVariables();
    t.assert(numel(vars) == 2);
    t.assertEquals(vars{1}, 'xx1');
    try
        t.assert(false);
        x1.name = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Name must be of type ''char''.');
    end
    try
        t.assert(false);
        x1.name = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Name must be of type ''char''.');
    end

    t.add('change_symbol_description');
    t.assertEquals(x1.description, '');
    t.assertEquals(x2.description, '');
    x1.description = 'descr x1';
    t.assertEquals(x1.description, 'descr x1');
    t.assertEquals(x2.description, '');
    try
        t.assert(false);
        x1.description = 2;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Description must be of type ''char''.');
    end
    try
        t.assert(false);
        x1.description = NaN;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Description must be of type ''char''.');
    end

    t.add('change_symbol_dimension');
    t.assert(x1.dimension == 1);
    t.assert(numel(x1.domain) == 1);
    if gdx.features.handle_comparison
        t.assertEquals(x1.domain{1}, i1);
    end
    t.assertEquals(x1.domain{1}.name, 'i1');
    x1.dimension = 2;
    t.assert(x1.dimension == 2);
    t.assert(numel(x1.domain) == 2);
    if gdx.features.handle_comparison
        t.assertEquals(x1.domain{1}, i1);
    end
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assertEquals(x1.domain{2}, '*');
    x1.dimension = 1;
    t.assert(x1.dimension == 1);
    t.assert(numel(x1.domain) == 1);
    if gdx.features.handle_comparison
        t.assertEquals(x1.domain{1}, i1);
    end
    t.assertEquals(x1.domain{1}.name, 'i1');
    try
        t.assert(false);
        x1.dimension = '2';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be of type ''numeric''.');
    end
    try
        t.assert(false);
        x1.dimension = 2.5;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be integer.');
    end
    try
        t.assert(false);
        x1.dimension = -1;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be within [0,20].');
    end
    try
        t.assert(false);
        x1.dimension = 21;
    catch e
        t.reset();
        t.assertEquals(e.message, 'Dimension must be within [0,20].');
    end

    t.add('change_symbol_domain');
    t.assert(numel(x1.domain) == 1);
    if gdx.features.handle_comparison
        t.assertEquals(x1.domain{1}, i1);
    end
    t.assertEquals(x1.domain{1}.name, 'i1');
    x1.domain = {i1,i1};
    t.assert(x1.dimension == 2);
    t.assert(numel(x1.domain) == 2);
    if gdx.features.handle_comparison
        t.assertEquals(x1.domain{1}, i1);
        t.assertEquals(x1.domain{2}, i1);
    end
    t.assertEquals(x1.domain{1}.name, 'i1');
    t.assertEquals(x1.domain{2}.name, 'i1');
    x1.domain = {'*'};
    t.assert(x1.dimension == 1);
    t.assertEquals(x1.domain, {'*'});
    x1.domain = {'a', 'b'};
    t.assert(x1.dimension == 2);
    t.assertEquals(x1.domain, {'a', 'b'});
    try
        t.assert(false);
        x1.domain = '*';
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain must be of type ''cell''.');
    end
    try
        t.assert(false);
        x1.domain = {x2};
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain entry must be of type ''GAMSTransfer.Set'' or ''char''.');
    end

    t.add('change_symbol_domain_label');
    try
        x1.domain_label = {'uni_1'};
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            msg_begin = 'You cannot set the read-only property';
            t.assertEquals(e.message(1:numel(msg_begin)), msg_begin);
        end
    end

    t.add('change_symbol_size');
    try
        t.assert(false);
        x1.size = [1,2];
    catch e
        t.reset();
        t.assertEquals(e.message, 'Setting symbol size only allowed in indexed mode.');
    end

    t.add('change_symbol_format');
    try
        x1.format = 'struct';
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            msg_begin = 'You cannot set the read-only property';
            t.assertEquals(e.message(1:numel(msg_begin)), msg_begin);
        end
    end

    t.add('change_symbol_number_records');
    try
        x1.number_records = 2;
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            msg_begin = 'You cannot set the read-only property';
            t.assertEquals(e.message(1:numel(msg_begin)), msg_begin);
        end
    end

    t.add('change_symbol_is_valid');
    try
        x1.is_valid = false;
        t.assert(false);
    catch e
        if exist('OCTAVE_VERSION', 'builtin') > 0
            msg_end = 'has private access and cannot be set in this context';
            t.assertEquals(e.message(end-numel(msg_end)+1:end), msg_end);
        else
            msg_begin = 'You cannot set the read-only property';
            t.assertEquals(e.message(1:numel(msg_begin)), msg_begin);
        end
    end

    t.add('change_symbol_uels');
    t.assert(isstruct(x1.uels));
    t.assert(numel(fieldnames(x1.uels)) == 2);
    t.assert(isfield(x1.uels, 'a_1'));
    t.assert(isfield(x1.uels, 'b_2'));
    t.assert(iscell(x1.uels.a_1));
    t.assert(iscell(x1.uels.b_2));
    t.assert(isempty(x1.uels.a_1));
    t.assert(isempty(x1.uels.b_2));
    x1.uels.a_1 = {'a1', 'a2', 'a3'};
    t.assert(isstruct(x1.uels));
    t.assert(numel(fieldnames(x1.uels)) == 2);
    t.assert(isfield(x1.uels, 'a_1'));
    t.assert(isfield(x1.uels, 'b_2'));
    t.assert(iscell(x1.uels.a_1));
    t.assert(iscell(x1.uels.b_2));
    t.assertEquals(x1.uels.a_1, {'a1', 'a2', 'a3'});
    t.assert(isempty(x1.uels.b_2));
    x1.domain = {'a', 'c'};
    t.assert(isstruct(x1.uels));
    t.assert(numel(fieldnames(x1.uels)) == 2);
    t.assert(isfield(x1.uels, 'a_1'));
    t.assert(isfield(x1.uels, 'c_2'));
    t.assert(iscell(x1.uels.a_1));
    t.assert(iscell(x1.uels.c_2));
    t.assertEquals(x1.uels.a_1, {'a1', 'a2', 'a3'});
    t.assert(isempty(x1.uels.c_2));
    x1.domain = {'c', 'a'};
    t.assert(isstruct(x1.uels));
    t.assert(numel(fieldnames(x1.uels)) == 2);
    t.assert(isfield(x1.uels, 'c_1'));
    t.assert(isfield(x1.uels, 'a_2'));
    t.assert(iscell(x1.uels.c_1));
    t.assert(iscell(x1.uels.a_2));
    t.assert(isempty(x1.uels.c_1));
    t.assert(isempty(x1.uels.a_2));
    try
        t.assert(false);
        x1.uels.c_1 = 'c1';
    catch e
        t.reset();
        t.assertEquals(e.message, 'UEL field ''c_1'' must be cell of strings.');
    end

end

function test_defaultvalues(t, cfg)

    gdx = GAMSTransfer.Container();

    t.add('default_values_sets');
    s = GAMSTransfer.Set(gdx, 'i1');
    def = s.getDefaultValues();
    t.assert(def(1) == 0);
    t.assert(all(GAMSTransfer.SpecialValues.isna(def(2:end))));

    t.add('default_values_parameters');
    s = GAMSTransfer.Parameter(gdx, 'a1');
    def = s.getDefaultValues();
    t.assert(def(1) == 0);
    t.assert(all(GAMSTransfer.SpecialValues.isna(def(2:end))));

    t.add('default_values_variables');
    s = GAMSTransfer.Variable(gdx, 'x1', 'binary');
    t.assert(s.getDefaultValues() == [0, 0, 0, 1, 1]);
    s = GAMSTransfer.Variable(gdx, 'x2', 'integer');
    t.assert(s.getDefaultValues() == [0, 0, 0, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x3', 'positive');
    t.assert(s.getDefaultValues() == [0, 0, 0, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x4', 'negative');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, 0, 1]);
    s = GAMSTransfer.Variable(gdx, 'x5', 'free');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x6', 'sos1');
    t.assert(s.getDefaultValues() == [0, 0, 0, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x7', 'sos2');
    t.assert(s.getDefaultValues() == [0, 0, 0, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x8', 'semiint');
    t.assert(s.getDefaultValues() == [0, 0, 1, Inf, 1]);
    s = GAMSTransfer.Variable(gdx, 'x9', 'semicont');
    t.assert(s.getDefaultValues() == [0, 0, 1, Inf, 1]);

    t.add('default_values_equations');
    s = GAMSTransfer.Equation(gdx, 'e1', 'e');
    t.assert(s.getDefaultValues() == [0, 0, 0, 0, 1]);
    s = GAMSTransfer.Equation(gdx, 'e2', 'l');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, 0, 1]);
    s = GAMSTransfer.Equation(gdx, 'e3', 'g');
    t.assert(s.getDefaultValues() == [0, 0, 0, Inf, 1]);
    s = GAMSTransfer.Equation(gdx, 'e4', 'n');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, Inf, 1]);
    s = GAMSTransfer.Equation(gdx, 'e5', 'x');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, Inf, 1]);
    s = GAMSTransfer.Equation(gdx, 'e6', 'b');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, Inf, 1]);
    s = GAMSTransfer.Equation(gdx, 'e7', 'c');
    t.assert(s.getDefaultValues() == [0, 0, -Inf, Inf, 1]);

end

function test_domainViolation(t, cfg);

    gdx = GAMSTransfer.Container();
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i1 = GAMSTransfer.Set(gdx, 'i1', '*');
    i1.uels.uni_1 = {'i1', 'i2', 'i3', 'i4'};
    i1.records.uni_1 = (1:4)';
    i2 = GAMSTransfer.Set(gdx, 'i2', i1);
    i2.uels.i1_1 = {'i1', 'i2'};
    i2.records.i1_1 = (1:2)';
    a1 = GAMSTransfer.Parameter(gdx, 'a1', {i1, i1});
    a1.uels.i1_1 = {'i0', 'i1'};
    a1.uels.i1_2 = {'i1', 'i2'};
    a1.records = struct('i1_1', [1;1;2;2], 'i1_2', [1;2;1;2], 'value', [1;2;3;4]);
    a2 = GAMSTransfer.Parameter(gdx, 'a2', {i1, '*'});
    a2.uels.i1_1 = {'i1', 'i5'};
    a2.uels.uni_2 = {'i1', 'i5'};
    a2.records = struct('i1_1', [1;1;2;2], 'uni_2', [1;2;1;2], 'value', [1;2;3;4]);
    a3 = GAMSTransfer.Parameter(gdx, 'a3', i2);
    a3.uels.i2_1 = {'i1', 'i7'};
    a3.records = struct('i2_1', [1;2], 'value', [1;2]);

    t.add('domain_violation_1');
    t.assert(i1.is_valid);
    t.assert(a1.is_valid);
    t.assert(a2.is_valid);
    t.assert(a3.is_valid);
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 3);
    t.assert(isa(domviol{1}, 'GAMSTransfer.DomainViolation'));
    t.assert(isa(domviol{2}, 'GAMSTransfer.DomainViolation'));
    t.assert(isa(domviol{3}, 'GAMSTransfer.DomainViolation'));
    t.assertEquals(domviol{1}.symbol.name, 'a1');
    t.assertEquals(domviol{2}.symbol.name, 'a2');
    t.assertEquals(domviol{3}.symbol.name, 'a3');
    t.assert(domviol{1}.dimension == 1);
    t.assert(domviol{2}.dimension == 1);
    t.assert(domviol{3}.dimension == 1);
    t.assertEquals(domviol{1}.domain.name, 'i1');
    t.assertEquals(domviol{2}.domain.name, 'i1');
    t.assertEquals(domviol{3}.domain.name, 'i2');
    t.assert(iscellstr(domviol{1}.violations));
    t.assert(iscellstr(domviol{2}.violations));
    t.assert(iscellstr(domviol{3}.violations));
    t.assert(numel(domviol{1}.violations) == 1);
    t.assert(numel(domviol{2}.violations) == 1);
    t.assert(numel(domviol{3}.violations) == 1);
    t.assertEquals(domviol{1}.violations{1}, 'i0');
    t.assertEquals(domviol{2}.violations{1}, 'i5');
    t.assertEquals(domviol{3}.violations{1}, 'i7');

    t.add('domain_violation_2');
    try
        t.assert(false);
        gdx.write(write_filename);
    catch e
        t.reset();
        if exist('OCTAVE_VERSION', 'builtin') > 0
            t.assertEquals(e.message, 'gt_gdx_write: GDX error in record a1(i0,i1): Domain violation');
        else
            t.assertEquals(e.message, 'GDX error in record a1(i0,i1): Domain violation');
        end
    end

    t.add('domain_violation_3');
    gdx.resolveDomainViolations();
    domviol = gdx.getDomainViolations();
    t.assert(numel(domviol) == 0);
    elems = i1.uels.uni_1(i1.records.uni_1);
    t.assert(iscell(elems));
    t.assert(numel(elems) == 7);
    t.assert(elems{1} == 'i1');
    t.assert(elems{2} == 'i2');
    t.assert(elems{3} == 'i3');
    t.assert(elems{4} == 'i4');
    t.assert(elems{5} == 'i0');
    t.assert(elems{6} == 'i5');
    t.assert(elems{7} == 'i7');
    t.assert(i1.is_valid);
    t.assert(a1.is_valid);
    t.assert(a2.is_valid);
    t.assert(a3.is_valid);

end

function test_setRecords(t, cfg)

    gdx = GAMSTransfer.Container();

    GAMSTransfer.Set(gdx, 'i1');
    s1 = GAMSTransfer.Variable(gdx, 'x1', 'free', {'i'});
    s2 = GAMSTransfer.Variable(gdx, 'x2', 'free', {'i', '*'});
    s3 = GAMSTransfer.Variable(gdx, 'x3', 'free', {gdx.data.i1});

    t.add('set_records_string_1');
    s1.setRecords('test');
    t.assertEquals(s1.format, 'struct');
    t.assert(isstruct(s1.records));
    t.assert(numel(fieldnames(s1.records)) == 1);
    t.assert(isfield(s1.records, 'i_1'));
    t.assert(numel(s1.records.i_1) == 1);
    if gdx.features.categorical
        t.assertEquals(s1.records.i_1(1), 'test');
    else
        t.assert(s1.records.i_1(1) == 1);
    end
    t.assert(isstruct(s1.uels));
    t.assert(numel(fieldnames(s1.uels)) == 1);
    t.assert(isfield(s1.uels, 'i_1'));
    t.assert(numel(s1.uels.i_1) == 1);
    t.assertEquals(s1.uels.i_1{1}, 'test');
    t.assert(s1.is_valid);

    t.add('set_records_string_2');
    try
        t.assert(false);
        s2.setRecords('test');
    catch e
        t.reset();
        t.assertEquals(e.message, 'Single string as records only accepted if symbol dimension equals 1.');
    end

    t.add('set_records_cellstr_1');
    s1.setRecords({'test1', 'test2', 'test3'});
    t.assertEquals(s1.format, 'struct');
    t.assert(isstruct(s1.records));
    t.assert(numel(fieldnames(s1.records)) == 1);
    t.assert(isfield(s1.records, 'i_1'));
    t.assert(numel(s1.records.i_1) == 3);
    if gdx.features.categorical
        t.assertEquals(s1.records.i_1(1), 'test1');
        t.assertEquals(s1.records.i_1(2), 'test2');
        t.assertEquals(s1.records.i_1(3), 'test3');
    else
        t.assert(s1.records.i_1(1) == 1);
        t.assert(s1.records.i_1(2) == 2);
        t.assert(s1.records.i_1(3) == 3);
    end
    t.assert(isstruct(s1.uels));
    t.assert(numel(fieldnames(s1.uels)) == 1);
    t.assert(isfield(s1.uels, 'i_1'));
    t.assert(numel(s1.uels.i_1) == 3);
    t.assertEquals(s1.uels.i_1{1}, 'test1');
    t.assertEquals(s1.uels.i_1{2}, 'test2');
    t.assertEquals(s1.uels.i_1{3}, 'test3');
    t.assert(s1.is_valid);

    t.add('set_records_cellstr_2');
    try
        t.assert(false);
        s2.setRecords({'test1', 'test2', 'test3'});
    catch e
        t.reset();
        t.assertEquals(e.message, 'First dimension of cellstr must equal symbol dimension.');
    end

    t.add('set_records_cellstr_3');
    s2.setRecords({'test11', 'test12', 'test13'; 'test21', 'test22', 'test23'});
    t.assertEquals(s2.format, 'struct');
    t.assert(isstruct(s2.records));
    t.assert(numel(fieldnames(s2.records)) == 2);
    t.assert(isfield(s2.records, 'i_1'));
    t.assert(isfield(s2.records, 'uni_2'));
    t.assert(numel(s2.records.i_1) == 3);
    t.assert(numel(s2.records.uni_2) == 3);
    if gdx.features.categorical
        t.assertEquals(s2.records.i_1(1), 'test11');
        t.assertEquals(s2.records.i_1(2), 'test12');
        t.assertEquals(s2.records.i_1(3), 'test13');
        t.assertEquals(s2.records.uni_2(1), 'test21');
        t.assertEquals(s2.records.uni_2(2), 'test22');
        t.assertEquals(s2.records.uni_2(3), 'test23');
    else
        t.assert(s2.records.i_1(1) == 1);
        t.assert(s2.records.i_1(2) == 2);
        t.assert(s2.records.i_1(3) == 3);
        t.assert(s2.records.uni_2(1) == 1);
        t.assert(s2.records.uni_2(2) == 2);
        t.assert(s2.records.uni_2(3) == 3);
    end
    t.assert(isstruct(s2.uels));
    t.assert(numel(fieldnames(s2.uels)) == 2);
    t.assert(isfield(s2.uels, 'i_1'));
    t.assert(isfield(s2.uels, 'uni_2'));
    t.assert(numel(s2.uels.i_1) == 3);
    t.assert(numel(s2.uels.uni_2) == 3);
    t.assertEquals(s2.uels.i_1{1}, 'test11');
    t.assertEquals(s2.uels.i_1{2}, 'test12');
    t.assertEquals(s2.uels.i_1{3}, 'test13');
    t.assertEquals(s2.uels.uni_2{1}, 'test21');
    t.assertEquals(s2.uels.uni_2{2}, 'test22');
    t.assertEquals(s2.uels.uni_2{3}, 'test23');
    t.assert(s2.is_valid);

    gdx.data.i1.setRecords({'i1', 'i2', 'i3', 'i4'});

    t.add('set_records_numeric_1');
    try
        t.assert(false);
        s1.setRecords([1; 2; 3; 4]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Records size doesn''t match symbol size.');
    end

    t.add('set_records_numeric_2');
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
    t.assert(s3.is_valid);

    t.add('set_records_numeric_3');
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
    t.assert(s3.is_valid);

    t.add('set_records_numeric_4');
    try
        t.assert(false);
        s3.setRecords([1; 2; 3; 4; 5]);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Records size doesn''t match symbol size.');
    end

    t.add('set_records_cell_1');
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
    t.assert(s3.is_valid);

    t.add('set_records_cell_2');
    s3.setRecords({{'i1', 'i4'}, [1; 4]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.is_valid);

    t.add('set_records_cell_3');
    s3.setRecords({[1; 4], {'i1', 'i4'}, [11; 44]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 3);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(isfield(s3.records, 'marginal'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    t.assert(numel(s3.records.marginal) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.records.marginal(1) == 11);
    t.assert(s3.records.marginal(2) == 44);
    t.assert(s3.is_valid);

    t.add('set_records_cell_4');
    s3.setRecords({[1; 4], {'i1', 'i4'}, [11; 44], [111; 444], [1111; 4444], [11111; 44444]});
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 6);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(isfield(s3.records, 'marginal'));
    t.assert(isfield(s3.records, 'lower'));
    t.assert(isfield(s3.records, 'upper'));
    t.assert(isfield(s3.records, 'scale'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    t.assert(numel(s3.records.marginal) == 2);
    t.assert(numel(s3.records.lower) == 2);
    t.assert(numel(s3.records.upper) == 2);
    t.assert(numel(s3.records.scale) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
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
    t.assert(s3.is_valid);

    t.add('set_records_cell_5');
    try
        t.assert(false);
        s2.setRecords({{'i1', 'i4'}, [1; 4]});
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain ''uni_2'' is missing.');
    end

    t.add('set_records_cell_6');
    try
        t.assert(false);
        s3.setRecords({{'i1', 'i4'}, [1; 4], {'i1', 'i4'}});
    catch e
        t.reset();
        t.assertEquals(e.message, 'More domain fields than symbol dimension.');
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
    t.assert(s3.is_valid);

    t.add('set_records_struct_2');
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
    t.assert(s3.is_valid);

    t.add('set_records_struct_3');
    try
        t.assert(false);
        s3.setRecords(struct('i1_1', {'i1', 'i4'}, 'level', [1; 4]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Non-scalar structure arrays currently not supported.');
    end

    t.add('set_records_struct_4');
    recs = struct();
    recs.i1_1 = {'i1', 'i4'};
    recs.level = [1; 4];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.is_valid);

    t.add('set_records_struct_5');
    recs = struct();
    recs.i1_1 = {'i1', 'i4'};
    recs.level = [1; 4];
    recs.shit_field = [nan, inf];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.is_valid);

    t.add('set_records_struct_6');
    recs = struct();
    recs.i1 = {'i1', 'i4'};
    recs.level = [1; 4];
    s3.setRecords(recs);
    t.assertEquals(s3.format, 'struct');
    t.assert(isstruct(s3.records));
    t.assert(numel(fieldnames(s3.records)) == 2);
    t.assert(isfield(s3.records, 'i1_1'));
    t.assert(isfield(s3.records, 'level'));
    t.assert(numel(s3.records.i1_1) == 2);
    t.assert(numel(s3.records.level) == 2);
    if gdx.features.categorical
        t.assertEquals(s3.records.i1_1(1), 'i1');
        t.assertEquals(s3.records.i1_1(2), 'i4');
    else
        t.assert(s3.records.i1_1(1) == 1);
        t.assert(s3.records.i1_1(2) == 2);
    end
    t.assertEquals(s3.uels.i1_1{1}, 'i1');
    t.assertEquals(s3.uels.i1_1{2}, 'i4');
    t.assert(s3.records.level(1) == 1);
    t.assert(s3.records.level(2) == 4);
    t.assert(s3.is_valid);

    t.add('set_records_struct_7');
    recs = struct();
    recs.i1_1 = {'i1', 'i4'};
    recs.level = [1];
    try
        t.assert(false);
        s3.setRecords(recs);
    catch e
        t.reset();
        t.assertEquals(e.message, 'Fields need to match matrix format or to be of same length');
    end

    t.add('set_records_struct_8');
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
    t.assert(s3.is_valid);

    t.add('set_records_struct_9');
    try
        t.assert(false);
        s3.setRecords(struct('level', [1, 2, 3]));
    catch e
        t.reset();
        t.assertEquals(e.message, 'Domain ''i1_1'' is missing.');
    end

    if gdx.features.table
        t.add('set_records_table_1');
        tbl = table(categorical({'i1'; 'i2'; 'i3'}), [1; 2; 3]);
        try
            t.assert(false);
            s3.setRecords(tbl);
        catch e
            t.reset();
        end

        t.add('set_records_table_2');
        tbl = table(categorical({'i1'; 'i2'; 'i3'}), [1; 2; 3]);
        tbl.Properties.VariableNames = {'i1_1', 'level'};
        s3.setRecords(tbl);
        t.assertEquals(s3.format, 'table');
        t.assert(s3.is_valid);
    end
end

function test_writeUnordered(t, cfg)

    gdx = GAMSTransfer.Container();
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    i = GAMSTransfer.Set(gdx, 'i', 'records', {'i1', 'i2', 'i3', 'i4', 'i5'});
    j = GAMSTransfer.Set(gdx, 'j', 'records', {'j1', 'j2', 'j3', 'j4', 'j5'});
    c = GAMSTransfer.Parameter(gdx, 'c', {i,j});
    c.setRecords({'i1', 'i1', 'i2', 'i2', 'i4', 'i4', 'i3', 'i3'}, ...
        {'j1', 'j2', 'j1', 'j2', 'j1', 'j2', 'j1', 'j2'}, ...
        [11, 12, 21, 22, 41, 42, 31, 32]);

    t.add('write_unordered_1')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        t.assertEquals(e.message, 'GDX error in record c(i3,j1): Data not sorted when writing raw');
    end

    t.add('write_unordered_2')
    gdx.write(write_filename, 'sorted', false);

    c.setRecords({'i1', 'i1', 'i2', 'i2'}, {'j1', 'j2', 'j2', 'j1'}, ...
        [11, 12, 22, 21]);

    t.add('write_unordered_3')
    try
        t.assert(false);
        gdx.write(write_filename, 'sorted', true);
    catch e
        t.reset();
        t.assertEquals(e.message, 'GDX error in record c(i2,j1): Data not sorted when writing raw');
    end

    t.add('write_unordered_4')
    gdx.write(write_filename, 'sorted', false);

end

function test_reorder(t, cfg)

    gdx = GAMSTransfer.Container();
    write_filename = fullfile(cfg.working_dir, 'write.gdx');

    s1 = GAMSTransfer.Set(gdx, 's1', 'records', {'i1', 'i2', 'i3', 'i4', 'i5'});
    s2 = GAMSTransfer.Set(gdx, 's2');
    s3 = GAMSTransfer.Set(gdx, 's3');
    s4 = GAMSTransfer.Set(gdx, 's4', 'records', {'j1', 'j2', 'j3', 'j4', 'j5'});

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
    t.assert(numel(fieldnames(gdx.data)) == 4);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's2');
    t.assertEquals(fields{3}, 's3');
    t.assertEquals(fields{4}, 's4');
    try
        t.assert(false);
        gdx.write(write_filename);
    catch e
        t.reset();
        t.assertEquals(e.message, 'GDX error: Unknown domain');
    end

    gdx.reorder();

    t.add('reorder_3');
    t.assert(numel(fieldnames(gdx.data)) == 4);
    fields = fieldnames(gdx.data);
    t.assertEquals(fields{1}, 's1');
    t.assertEquals(fields{2}, 's2');
    t.assertEquals(fields{3}, 's4');
    t.assertEquals(fields{4}, 's3');
    try
        gdx.write(write_filename);
    catch
        t.assert(false);
    end

    s2.domain = {s3};
    s3.domain = {s4};
    gdx.reorder();

    t.add('reorder_4');
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

    t.add('reorder_5');
    try
        t.assert(false);
        gdx.reorder();
    catch e
        t.reset();
        t.assertEquals(e.message, 'Circular domain set dependency in: [s2,s3].');
    end

end

function test_transformRecords(t, cfg)

    gdx = GAMSTransfer.Container(cfg.filenames{1});

    formats = {'struct', 'table', 'dense_matrix', 'sparse_matrix'};
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
        if strcmp(formats{i}, 'table') && ~gdx.features.table
            continue
        end
        gdx.read('format', formats{i});
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
        if strcmp(formats{i}, 'table') && ~gdx.features.table
            continue
        end

        for j = 1:numel(formats)
            if strcmp(formats{j}, 'table') && ~gdx.features.table
                continue
            end

            t.add(sprintf('transform_records_%s_to_%s', formats{i}, formats{j}));
            gdx.read('format', formats{i});
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
