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

function success = test_general(cfg)
    t = GAMSTest('general');
    test_specialValues(t, cfg);
    [~, n_fails] = t.summary();
    success = n_fails == 0;
end

function test_specialValues(t, cfg)
    geps = GAMSTransfer.SpecialValues.EPS;
    gna = GAMSTransfer.SpecialValues.NA;
    gundef = GAMSTransfer.SpecialValues.UNDEF;
    vec = [1, 2, 0, -0, geps, nan, gna, gundef];
    srow = [1, 2, 3, 4, 5, 6, 7, 8];
    scol = [7, 3, 1, 2, 8, 4, 6, 5];
    svec = sparse(srow, scol, vec);

    t.add('special_values_eps');
    t.assert(GAMSTransfer.SpecialValues.isEps(geps));
    t.assert(~GAMSTransfer.SpecialValues.isEps(0));
    t.assert(GAMSTransfer.SpecialValues.isEps(vec) == [0, 0, 0, 1, 1, 0, 0, 0]);

    t.add('special_values_eps_sparse');
    seps = GAMSTransfer.SpecialValues.isEps(svec);
    for i = 1:8
        for j = 1:8
            t.assert(~seps(i, j));
        end
    end

    t.add('special_values_na');
    t.assert(GAMSTransfer.SpecialValues.isNA(gna));
    t.assert(~GAMSTransfer.SpecialValues.isNA(nan));
    t.assert(GAMSTransfer.SpecialValues.isNA(vec) == [0, 0, 0, 0, 0, 0, 1, 0]);

    t.add('special_values_na_sparse');
    seps = GAMSTransfer.SpecialValues.isNA(svec);
    for i = 1:8
        for j = 1:8
            if i == srow(7) && j == scol(7)
                t.assert(seps(i, j));
            else
                t.assert(~seps(i, j));
            end
        end
    end

    t.add('special_values_undef');
    t.assert(GAMSTransfer.SpecialValues.isUndef(gundef));
    t.assert(GAMSTransfer.SpecialValues.isUndef(nan));
    t.assert(GAMSTransfer.SpecialValues.isUndef(vec) == [0, 0, 0, 0, 0, 1, 0, 1]);

    t.add('special_values_undef_sparse');
    seps = GAMSTransfer.SpecialValues.isUndef(svec);
    for i = 1:8
        for j = 1:8
            if i == srow(6) && j == scol(6) || i == srow(8) && j == scol(8)
                t.assert(seps(i, j));
            else
                t.assert(~seps(i, j));
            end
        end
    end
end
