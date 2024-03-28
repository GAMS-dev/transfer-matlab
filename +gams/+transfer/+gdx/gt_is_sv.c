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

#include <string.h>

#include "mex.h"
#include "gt_utils.h"

#define ERRID "gams:transfer:cmex:gt_is_sv:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    char svname[6];
    mxLogical* mx_outputs;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_inputs = NULL;
#else
    double* mx_inputs = NULL;
#endif

    if (nlhs != 1 && nlhs != 0)
        mexErrMsgIdAndTxt(ERRID"check_argument", "Incorrect number of outputs (%d). 0 or 1 required.", nlhs);
    if (nrhs != 2)
        mexErrMsgIdAndTxt(ERRID"check_argument", "Incorrect number of inputs (%d). 1 required.", nrhs);
    if (!mxIsChar(prhs[0]))
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument 1 has invalid type: need char");
    if (!mxIsDouble(prhs[1]))
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument 2 has invalid type: need double");
    if (mxIsSparse(prhs[1]))
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument must not be sparse");

    /* create output data */
    plhs[0] = mxCreateLogicalArray(mxGetNumberOfDimensions(prhs[1]), mxGetDimensions(prhs[1]));

    /* access data */
#ifdef WITH_R2018A_OR_NEWER
    mx_inputs = mxGetDoubles(prhs[1]);
    mx_outputs = mxGetLogicals(plhs[0]);
#else
    mx_inputs = mxGetPr(prhs[1]);
    mx_outputs = (mxLogical*) mxGetData(plhs[0]);
#endif

    mxGetString(prhs[0], svname, 6);

    if (!strcmp(svname, "eps"))
        for (size_t i = 0; i < mxGetNumberOfElements(plhs[0]); i++)
            mx_outputs[i] = gt_utils_iseps(mx_inputs[i]);
    else if (!strcmp(svname, "na"))
        for (size_t i = 0; i < mxGetNumberOfElements(plhs[0]); i++)
            mx_outputs[i] = gt_utils_isna(mx_inputs[i]);
    else
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument 1 must be one of the following: eps, na.");
}
