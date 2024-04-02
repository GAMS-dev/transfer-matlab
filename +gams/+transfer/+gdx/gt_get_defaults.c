/*
 * GAMS - General Algebraic Modeling System Matlab API
 *
 * Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
 * Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
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

#include "gclgms.h"
#include "gt_mex.h"
#include "gt_utils.h"

#define ERRID "gams:transfer:cmex:gt_get_defaults:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int type, subtype;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_defaults = NULL;
#else
    double* mx_defaults = NULL;
#endif

    /* check input / outputs */
    gt_mex_check_arguments_num(1, nlhs, 2, nrhs);
    gt_mex_check_argument_int(prhs, 0, GT_FILTER_NONE, 1, &type);
    gt_mex_check_argument_int(prhs, 1, GT_FILTER_NONE, 1, &subtype);

    /* create output data */
    plhs[0] = mxCreateDoubleMatrix(1, 5, mxREAL);

#ifdef WITH_R2018A_OR_NEWER
    mx_defaults = mxGetDoubles(plhs[0]);
#else
    mx_defaults = mxGetPr(plhs[0]);
#endif

    if (type == GMS_DT_EQU)
        subtype += GMS_EQUEOFFSET;

    /* get defaults */
    gt_utils_type_default_values(type, subtype, true, mx_defaults);
}
