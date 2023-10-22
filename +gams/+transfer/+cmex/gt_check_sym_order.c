/*
 * GAMS - General Algebraic Modeling System Matlab API
 *
 * Copyright (c) 2020-2023 GAMS Software GmbH <support@gams.com>
 * Copyright (c) 2020-2023 GAMS Development Corp. <support@gams.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "mex.h"
#include "gt_mex.h"

#define ERRID "gams:transfer:cmex:gt_check_sym_order:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int first_symbol_pos, second_symbol_pos;
    char first_symbol[256], second_symbol[256];

    /* check input / outputs */
    gt_mex_check_arguments_num(1, nlhs, 3, nrhs);
    gt_mex_check_argument_struct(prhs, 0);
    gt_mex_check_argument_str(prhs, 1, first_symbol);
    gt_mex_check_argument_str(prhs, 2, second_symbol);

    first_symbol_pos = mxGetFieldNumber(prhs[0], first_symbol);
    second_symbol_pos = mxGetFieldNumber(prhs[0], second_symbol);

    /* create output data */
    plhs[0] = mxCreateLogicalScalar(first_symbol_pos < second_symbol_pos);
}
