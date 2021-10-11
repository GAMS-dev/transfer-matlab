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

#include <stdio.h>
#include <string.h>
#include <inttypes.h>

#include "mex.h"
#include "gt_cmex_mex.h"
#include "gt_cmex_utils.h"

#define ERRID "GAMSTransfer:gt_cmex_set_sym_domain:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int container_id;
    bool dominfo_regular, dominfo_none, support_setget;
    size_t dim;
    char domname[256], label[512];
    mxArray* mx_arr_domentry = NULL;
    mxArray* mx_arr_domnames = NULL;
    mxArray* mx_arr_domlabels = NULL;
    mxArray* mx_arr_size = NULL;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_size;
#else
    double* mx_size;
#endif

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 4, nrhs);
    gt_mex_check_argument_symbol_obj(prhs, 0);
    if (!mxIsCell(prhs[1]))
        mexErrMsgIdAndTxt(ERRID"domain", "Domain must be of type 'cell'.");
    gt_mex_check_argument_int(prhs, 2, GT_FILTER_NONNEGATIVE, 1, &container_id);
    gt_mex_check_argument_bool(prhs, 3, 1, &support_setget);

    dim = mxGetNumberOfElements(prhs[1]);
    mx_arr_domnames = mxCreateCellMatrix(1, dim);
    mx_arr_domlabels = mxCreateCellMatrix(1, dim);
    mx_arr_size = mxCreateDoubleMatrix(1, dim, mxREAL);
    dominfo_none = true;
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
                sprintf(label, "uni_%d", (int) i+1);
            else
            {
                sprintf(label, "%s_%d", domname, (int) i+1);
                dominfo_regular = false;
                dominfo_none = false;
            }
            mxSetCell(mx_arr_domnames, i, mxCreateString(domname));
            mxSetCell(mx_arr_domlabels, i, mxCreateString(label));

            /* set size */
            mx_size[i] = mxGetNaN();
        }
        else if (mxIsClass(mx_arr_domentry, "GAMSTransfer.Set") ||
            mxIsClass(mx_arr_domentry, "GAMSTransfer.Alias"))
        {
            int domdim;
            mxArray* mx_arr_container;
            mxArray* mx_arr_contid;
            mxArray* call_plhs[1] = {NULL};
            mxArray* call_prhs[1] = {NULL};
#ifdef WITH_R2018A_OR_NEWER
            mxDouble* mx_domnrecs;
#else
            double* mx_domnrecs;
#endif

            /* get domain attributes */
            gt_mex_getfield_str(mx_arr_domentry, "domain", "name_", "", true, domname, 256);
            if (mxIsClass(mx_arr_domentry, "GAMSTransfer.Alias"))
                mx_arr_domentry = mxGetProperty(mx_arr_domentry, 0, "alias_with");
            gt_mex_getfield_int(mx_arr_domentry, "domain", "dimension_", 0, true,
                GT_FILTER_NONNEGATIVE, 1, &domdim);

            /* check domain set */
            if (domdim != 1)
                mexErrMsgIdAndTxt(ERRID"dimension", "Domain set '%s' must have dimension=1 to be valid as domain.", domname);

            /* get number of records */
            call_prhs[0] = mx_arr_domentry;
            if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "getNumberRecords"))
                mexErrMsgIdAndTxt(ERRID"number_records", "Calling 'getNumberRecords' failed.");
#ifdef WITH_R2018A_OR_NEWER
    mx_domnrecs = mxGetDoubles(call_plhs[0]);
#else
    mx_domnrecs = mxGetPr(call_plhs[0]);
#endif
            mx_size[i] = mx_domnrecs[0];

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
            sprintf(label, "%s_%d", domname, (int) i+1);
            mxSetCell(mx_arr_domnames, i, mxCreateString(domname));
            mxSetCell(mx_arr_domlabels, i, mxCreateString(label));
            dominfo_none = false;
        }
        else
            mexErrMsgIdAndTxt(ERRID"domain", "Domain entry must be of type 'GAMSTransfer.Set' or 'char'.");
    }

    mxSetProperty((mxArray*) prhs[0], 0, "dimension_", mxCreateDoubleScalar(dim));
    mxSetProperty((mxArray*) prhs[0], 0, "domain_names_", mx_arr_domnames);
    mxSetProperty((mxArray*) prhs[0], 0, "domain_labels_", mx_arr_domlabels);
    if (dominfo_none)
        mxSetProperty((mxArray*) prhs[0], 0, "domain_type_", mxCreateString("none"));
    else if (dominfo_regular)
        mxSetProperty((mxArray*) prhs[0], 0, "domain_type_", mxCreateString("regular"));
    else
        mxSetProperty((mxArray*) prhs[0], 0, "domain_type_", mxCreateString("relaxed"));
    mxSetProperty((mxArray*) prhs[0], 0, "size_", mx_arr_size);
    mxSetProperty((mxArray*) prhs[0], 0, "format_", mxCreateDoubleScalar(GT_FORMAT_REEVALUATE));
    mxSetProperty((mxArray*) prhs[0], 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
}
