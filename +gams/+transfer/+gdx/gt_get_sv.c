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

#include <time.h>

#define ERRID "gams:transfer:cmex:gt_geteps:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    char svname[6];
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_value = NULL;
#else
    double* mx_value = NULL;
#endif

    if (nlhs != 1 && nlhs != 0)
        mexErrMsgIdAndTxt(ERRID"check_argument", "Incorrect number of outputs (%d). 0 or 1 required.", nlhs);
    if (nrhs != 1)
        mexErrMsgIdAndTxt(ERRID"check_argument", "Incorrect number of inputs (%d). 0 required.", nrhs);
    if (!mxIsChar(prhs[0]))
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument 1 has invalid type: need char");

    /* create output data */
    plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);

    /* access data */
#ifdef WITH_R2018A_OR_NEWER
    mx_value = mxGetDoubles(plhs[0]);
#else
    mx_value = mxGetPr(plhs[0]);
#endif

    mxGetString(prhs[0], svname, 6);

    if (!strcmp(svname, "eps"))
        mx_value[0] = gt_utils_geteps();
    else if (!strcmp(svname, "na"))
        mx_value[0] = gt_utils_getna();
    else
        mexErrMsgIdAndTxt(ERRID"check_argument", "Argument 1 must be one of the following: eps, na.");
}
