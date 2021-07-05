/*
 * GAMS - General Algebraic Modeling System Matlab API
 *
 * Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
 * Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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

#include "gdxcc.h"
#include "gt_mex.h"
#include "gt_utils.h"

#define ERRID "GAMSTransfer:gt_get_defaults:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int type, subtype;
    bool singleton;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_defaults = NULL;
#else
    double* mx_defaults = NULL;
#endif

    /* check input / outputs */
    gt_mex_check_arguments_num(1, nlhs, 1, nrhs);
    gt_mex_check_argument_symbol_obj(prhs, 0);

    /* create output data */
    plhs[0] = mxCreateDoubleMatrix(1, 5, mxREAL);

#ifdef WITH_R2018A_OR_NEWER
    mx_defaults = mxGetDoubles(plhs[0]);
#else
    mx_defaults = mxGetPr(plhs[0]);
#endif

    /* get symbol type */
    if (mxIsClass(prhs[0], "GAMSTransfer.Set"))
    {
        gt_mex_getfield_bool(prhs[0], "symbol", "singleton", false, true, 1, &singleton);
        type = GMS_DT_SET;
        subtype = (singleton) ? GMS_SETTYPE_SINGLETON : GMS_SETTYPE_DEFAULT;
    }
    else if (mxIsClass(prhs[0], "GAMSTransfer.Parameter"))
    {
        type = GMS_DT_PAR;
        subtype = 0;
    }
    else if (mxIsClass(prhs[0], "GAMSTransfer.Variable"))
    {
        gt_mex_getfield_int(prhs[0], "symbol", "type_", 0, true, GT_FILTER_NONE, 1, &subtype);
        type = GMS_DT_VAR;
    }
    else if (mxIsClass(prhs[0], "GAMSTransfer.Equation"))
    {
        gt_mex_getfield_int(prhs[0], "symbol", "type_", 0, true, GT_FILTER_NONE, 1, &subtype);
        type = GMS_DT_EQU;
        subtype += GMS_EQU_USERINFO_BASE;
    }
    else
    {
        mexErrMsgIdAndTxt(ERRID"type", "Symbol has invalid type.");
        return;
    }

    /* get defaults */
    gt_utils_type_default_values(type, subtype, true, mx_defaults);
}
