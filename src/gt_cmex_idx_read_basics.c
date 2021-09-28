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
#include "gt_cmex_utils.h"
#include "gt_cmex_mex.h"
#include "gt_cmex_gdx_idx.h"

#include <stdio.h>

#define ERRID "GAMSTransfer:gt_cmex_idx_read_basics:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_count, dim, nrecs;
    char name[GMS_SSSIZE], text[GMS_SSSIZE], gdx_filename[GMS_SSSIZE], sysdir[GMS_SSSIZE];
    idxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;
    gdxUelIndex_t sizes_int;
    size_t sizes[GLOBAL_MAX_INDEX_DIM];

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(1, nlhs, 2, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);

    /* start GDX */
    gt_idx_init_read(&gdx, sysdir, gdx_filename);

    /* get number of symbols */
    if (!idxGetSymCount(gdx, &sym_count))
        mexErrMsgIdAndTxt(ERRID"gdxSystemInfo", "GDX error (idxGetSymCount)");

    /* create output data */
    plhs[0] = mxCreateStructMatrix(1, 1, 0, NULL);

    /* read symbols */
    for (int i = 0; i < sym_count; i++)
    {
        /* read symbol gdx data */
        if (!idxGetSymbolInfo(gdx, i, name, GMS_SSSIZE, &dim, sizes_int, &nrecs, text, GMS_SSSIZE))
            mexErrMsgIdAndTxt(ERRID"idxGetSymbolInfo", "GDX error (idxGetSymbolInfo)");

        for (int j = 0; j < dim; j++)
        {
            sprintf(domains_ptr[j], "dim_%d", j+1);
            sizes[j] = sizes_int[j];
        }

        /* add symbol */
        gt_mex_addsymbol(plhs[0], name, text, GMS_DT_PAR, 0, dim, sizes,
            (const char**) domains_ptr, 2, nrecs);
    }

    idxClose(gdx);
    idxFree(&gdx);
}
