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

function success = test_uels(cfg)
    t = GAMSTest('uels');
    test_uniqueelementlist(t, cfg);
    test_symbol_uels(t, cfg);
    [~, n_fails] = t.summary();
    success = n_fails == 0;
end

function test_uniqueelementlist(t, cfg);

    u = GAMSTransfer.UniqueElementList();

    t.add('uniqueelementlist_add');
    u.add({'a', 'b', 'm', 'n', 'd'});
    uels = u.get();
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'b');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 5);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);
    u.add({'a', 'e'});
    uels = u.get();
    t.assert(numel(uels) == 6);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'b');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    t.assertEquals(uels{6}, 'e');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);
    t.assert(ids(6) == 6);
    u.add({'a', 'b', 'b'});
    uels = u.get();
    t.assert(numel(uels) == 6);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'b');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    t.assertEquals(uels{6}, 'e');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);
    t.assert(ids(6) == 6);

    t.add('uniqueelementlist_set');
    vals = u.set({}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 0);
    ids = u.getIds(uels);
    t.assert(numel(ids) == 0);
    t.assert(numel(vals) == 10)
    t.assert(vals(1) == 0);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 0);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 0);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 0);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);
    vals = u.set({'a', 'b', 'm', 'n', 'd'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'b');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 5);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);
    t.assert(numel(vals) == 10)
    t.assert(vals(1) == 0);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 0);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 0);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 0);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);
    vals = u.set({'a', 'e'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 2);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'e');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 2);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(numel(vals) == 10)
    t.assert(vals(1) == 1);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 0);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 1);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 0);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);
    vals = u.set({'e', 'a'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 2);
    t.assertEquals(uels{1}, 'e');
    t.assertEquals(uels{2}, 'a');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 2);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(numel(vals) == 10)
    t.assert(vals(1) == 2);
    t.assert(vals(2) == 1);
    t.assert(vals(3) == 0);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 2);
    t.assert(vals(7) == 1);
    t.assert(vals(8) == 0);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);

    t.add('uniqueelementlist_remove');
    u.set({'a', 'b', 'm', 'n', 'd'}, []);
    vals = u.remove({'b', 'n'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'm');
    t.assertEquals(uels{3}, 'd');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 3);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(numel(vals) == 10);
    t.assert(vals(1) == 1);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 2);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 3);
    t.assert(vals(6) == 1);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 2);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 3);
    u.add({'x'});
    vals = u.remove({'m'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'd');
    t.assertEquals(uels{3}, 'x');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 3);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(numel(vals) == 10);
    t.assert(vals(1) == 1);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 2);
    t.assert(vals(4) == 3);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 1);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 2);
    t.assert(vals(9) == 3);
    t.assert(vals(10) == 0);
    vals = u.remove({'m'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 3);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'd');
    t.assertEquals(uels{3}, 'x');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 3);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(numel(vals) == 10);
    t.assert(vals(1) == 1);
    t.assert(vals(2) == 2);
    t.assert(vals(3) == 3);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 1);
    t.assert(vals(7) == 2);
    t.assert(vals(8) == 3);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);
    vals = u.remove({'a', 'd', 'x'}, [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]);
    uels = u.get();
    t.assert(numel(uels) == 0);
    ids = u.getIds(uels);
    t.assert(numel(ids) == 0);
    t.assert(numel(vals) == 10);
    t.assert(vals(1) == 0);
    t.assert(vals(2) == 0);
    t.assert(vals(3) == 0);
    t.assert(vals(4) == 0);
    t.assert(vals(5) == 0);
    t.assert(vals(6) == 0);
    t.assert(vals(7) == 0);
    t.assert(vals(8) == 0);
    t.assert(vals(9) == 0);
    t.assert(vals(10) == 0);

    t.add('uniqueelementlist_rename');
    u.set({'a', 'b', 'm', 'n', 'd'}, []);
    u.rename({'a', 'b'}, {'x', 'y'});
    uels = u.get();
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'x');
    t.assertEquals(uels{2}, 'y');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 5);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);
    u.rename({'a', 'b'}, {'w', 'v'});
    uels = u.get();
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'x');
    t.assertEquals(uels{2}, 'y');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'd');
    ids = u.getIds(uels);
    t.assert(numel(ids) == 5);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 3);
    t.assert(ids(4) == 4);
    t.assert(ids(5) == 5);

    t.add('uniqueelementlist_getlabels');
    u.set({'a', 'b', 'm', 'n', 'd'}, []);
    uels = u.getLabels([1, 2, 3, 4, 2, 3, 1, 5, 1]);
    t.assert(numel(uels) == 9);
    t.assertEquals(uels{1}, 'a');
    t.assertEquals(uels{2}, 'b');
    t.assertEquals(uels{3}, 'm');
    t.assertEquals(uels{4}, 'n');
    t.assertEquals(uels{5}, 'b');
    t.assertEquals(uels{6}, 'm');
    t.assertEquals(uels{7}, 'a');
    t.assertEquals(uels{8}, 'd');
    t.assertEquals(uels{9}, 'a');

end

function test_symbol_uels(t, cfg)

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels');
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    uels = x.getUELs(2);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'j2');
    t.assertEquals(uels{2}, 'j5');
    t.assertEquals(uels{3}, 'j7');
    t.assertEquals(uels{4}, 'j8');
    t.assertEquals(uels{5}, 'j9');

    t.add('symbol_uels_getlabels');
    uels = x.getUELs(1, [0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5]);
    t.assert(numel(uels) == 12);
    t.assertEquals(uels{1}, '<undefined>');
    t.assertEquals(uels{2}, 'i1');
    t.assertEquals(uels{3}, 'i3');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');
    t.assertEquals(uels{6}, '<undefined>');
    t.assertEquals(uels{7}, '<undefined>');
    t.assertEquals(uels{8}, 'i1');
    t.assertEquals(uels{9}, 'i3');
    t.assertEquals(uels{10}, 'i6');
    t.assertEquals(uels{11}, 'i10');
    t.assertEquals(uels{12}, '<undefined>');

    t.add('symbol_uels_add');
    x.addUELs('i11', 1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    t.assertEquals(uels{5}, 'i11');
    x.addUELs({'i12', 'i13'}, 1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 7);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    t.assertEquals(uels{5}, 'i11');
    t.assertEquals(uels{6}, 'i12');
    t.assertEquals(uels{7}, 'i13');
    x.addUELs({'i12', 'i13'}, 1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 7);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    t.assertEquals(uels{5}, 'i11');
    t.assertEquals(uels{6}, 'i12');
    t.assertEquals(uels{7}, 'i13');
    uels = x.getUELs(1, 'ignore_unused', true);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');

    t.add('symbol_uels_set_1');
    x.setUELs({'i1', 'i3', 'i6', 'i10'}, 1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    x.setUELs({'i1', 'i3', 'i10'}, 1);
    t.assert(~x.isValid());
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 0);
    t.assert(ids(5) == 0);
    t.assert(ids(6) == 3);

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels_set_2');
    x.setUELs('i1', 1);
    t.assert(~x.isValid());
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 0);
    t.assert(ids(3) == 0);
    t.assert(ids(4) == 0);
    t.assert(ids(5) == 0);
    t.assert(ids(6) == 0);

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels_init');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    x.setUELs({'i1', 'i3', 'i4', 'i6', 'i10'}, 1, 'rename', true);
    t.assert(x.isValid());
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i6');
    t.assertEquals(uels{5}, 'i10');
    x.setUELs({'i3', 'i1', 'i4', 'i10', 'i5'}, 1, 'rename', true);
    t.assert(x.isValid());
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i3');
    t.assertEquals(uels{2}, 'i1');
    t.assertEquals(uels{3}, 'i4');
    t.assertEquals(uels{4}, 'i10');
    t.assertEquals(uels{5}, 'i5');

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels_remove_1');
    x.removeUELs(1, 'i4');
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    x.removeUELs(1, {'i3', 'i6'});
    t.assert(~x.isValid());
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 0);
    t.assert(ids(3) == 0);
    t.assert(ids(4) == 0);
    t.assert(ids(5) == 0);
    t.assert(ids(6) == 2);

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels_remove_2');
    x.addUELs('i4', 1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 5);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    t.assertEquals(uels{5}, 'i4');
    x.removeUELs(1);
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i1');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);

    c = GAMSTransfer.Container('gams_dir', cfg.gams_dir, 'features', cfg.features);
    c.read(cfg.filenames{1}, 'format', 'struct');
    x = c.data.x;

    t.add('symbol_uels_rename');
    x.renameUELs(1, 'i1', 'i11');
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i11');
    t.assertEquals(uels{2}, 'i3');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i10');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);
    x.renameUELs(1, {'i3', 'i10'}, {'i33', 'i1010'});
    uels = x.getUELs(1);
    t.assert(numel(uels) == 4);
    t.assertEquals(uels{1}, 'i11');
    t.assertEquals(uels{2}, 'i33');
    t.assertEquals(uels{3}, 'i6');
    t.assertEquals(uels{4}, 'i1010');
    ids = int64(x.records.i_1);
    t.assert(numel(ids) == 6);
    t.assert(ids(1) == 1);
    t.assert(ids(2) == 2);
    t.assert(ids(3) == 2);
    t.assert(ids(4) == 3);
    t.assert(ids(5) == 3);
    t.assert(ids(6) == 4);

end
