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

function test_general(t, cfg)
    test_specialValues(t, cfg);
end

function test_specialValues(t, cfg)
    geps = GAMSTransfer.SpecialValues.EPS;
    gna = GAMSTransfer.SpecialValues.NA;

    t.add('special_values_eps');
    t.assert(GAMSTransfer.SpecialValues.iseps(geps));
    t.assert(~GAMSTransfer.SpecialValues.iseps(0));
    t.assert(GAMSTransfer.SpecialValues.iseps([1, 2, 0, -0, geps, nan, gna]) == [0, 0, 0, 1, 1, 0, 0]);

    t.add('special_values_na');
    t.assert(GAMSTransfer.SpecialValues.isna(gna));
    t.assert(~GAMSTransfer.SpecialValues.isna(nan));
    t.assert(GAMSTransfer.SpecialValues.isna([1, 2, 0, -0, geps, nan, gna]) == [0, 0, 0, 0, 0, 0, 1]);
end
