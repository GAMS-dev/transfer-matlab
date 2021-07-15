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
#include "gt_mex.h"
#include "gt_utils.h"

#define ERRID "GAMSTransfer:gt_set_sym_domain:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int container_id;
    bool dominfo_regular;
    size_t dim;
    char domname[256], label[265];
    mxArray* mx_arr_domentry = NULL;
    mxArray* mx_arr_domlabels = NULL;
    mxArray* mx_arr_size = NULL;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_size;
#else
    double* mx_size;
#endif

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 3, nrhs);
    gt_mex_check_argument_symbol_obj(prhs, 0);
    if (!mxIsCell(prhs[1]))
        mexErrMsgIdAndTxt(ERRID"domain", "Domain must be of type 'cell'.");
    gt_mex_check_argument_int(prhs, 2, GT_FILTER_NONNEGATIVE, 1, &container_id);

    dim = mxGetNumberOfElements(prhs[1]);
    mx_arr_domlabels = mxCreateCellMatrix(1, dim);
    mx_arr_size = mxCreateDoubleMatrix(1, dim, mxREAL);
    dominfo_regular = true;

#ifdef WITH_R2018A_OR_NEWER
    mx_size = mxGetDoubles(mx_arr_size);
#else
    mx_size = mxGetPr(mx_arr_size);
#endif

    for (size_t i = 0; i < dim; i++)
    {
        mx_arr_domentry = mxGetCell(prhs[1], i);
        if (mxIsChar(mx_arr_domentry))
        {
            /* set domain label */
            mxGetString(mx_arr_domentry, domname, 256);
            if (!strcmp(domname, "*"))
                sprintf(label, "uni_%d", i+1);
            else
            {
                sprintf(label, "%s_%d", domname, i+1);
                dominfo_regular = false;
            }
            mxSetCell(mx_arr_domlabels, i, mxCreateString(label));

            /* set size */
            mx_size[i] = mxGetNaN();
        }
        else if (mxIsClass(mx_arr_domentry, "GAMSTransfer.Set"))
        {
            int domdim, domnrecs, dom_contid;
            mxArray* mx_arr_container;
            mxArray* mx_arr_contid;

            /* check domain set */
            gt_mex_getfield_str(mx_arr_domentry, "domain", "name_", "", true, domname, 256);
            gt_mex_getfield_int(mx_arr_domentry, "domain", "dimension_", 0, true,
                GT_FILTER_NONNEGATIVE, 1, &domdim);

            if (domdim != 1)
                mexErrMsgIdAndTxt(ERRID"dimension", "Domain set '%s' must have dimension=1 to be valid as domain.", domname);
            gt_mex_getfield_int(mx_arr_domentry, "domain", "number_records_c_", 0,
                true, GT_FILTER_NONNEGATIVE, 1, &domnrecs);

            /* check domain set container */
            mx_arr_container = mxGetProperty(mx_arr_domentry, 0, "container");
            mx_arr_contid = mxGetProperty(mx_arr_container, 0, "id");
#ifdef WITH_R2018A_OR_NEWER
            mxInt32* mx_contid = mxGetInt32s(mx_arr_contid);
#else
            INT32_T* mx_contid = (INT32_T*) mxGetData(mx_arr_contid);
#endif

            if (mx_contid[0] != container_id)
                mexErrMsgIdAndTxt(ERRID"container", "Domain set '%s' must have same container as symbol.", domname);

            /* set domain label */
            sprintf(label, "%s_%d", domname, i+1);
            mxSetCell(mx_arr_domlabels, i, mxCreateString(label));

            /* set size */
            mx_size[i] = domnrecs;
        }
        else
            mexErrMsgIdAndTxt(ERRID"domain", "Domain entry must be of type 'GAMSTransfer.Set' or 'char'.");
    }

    mxSetProperty(prhs[0], 0, "dimension_", mxCreateDoubleScalar(dim));
    mxSetProperty(prhs[0], 0, "domain_label_", mx_arr_domlabels);
    if (dominfo_regular)
        mxSetProperty(prhs[0], 0, "domain_info_", mxCreateString("regular"));
    else
        mxSetProperty(prhs[0], 0, "domain_info_", mxCreateString("relaxed"));
    mxSetProperty(prhs[0], 0, "size_", mx_arr_size);
    mxSetProperty(prhs[0], 0, "format_", mxCreateDoubleScalar(GT_FORMAT_REEVALUATE));
    mxSetProperty(prhs[0], 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
}
