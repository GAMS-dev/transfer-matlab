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

#include "gdxcc.h"
#include "mex.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#include <string.h>

#define ERRID "GAMSTransfer:gt_gdx_read_basics:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_count, uel_count, dim, type, subtype, nrecs, dominfo;
    char name[GMS_SSSIZE], text[GMS_SSSIZE], gdx_filename[GMS_SSSIZE], sysdir[GMS_SSSIZE];
    gdxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(1, nlhs, 2, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);

    /* start GDX */
    gt_gdx_init_read(&gdx, sysdir, gdx_filename);

    /* get number of symbols and uels */
    if (!gdxSystemInfo(gdx, &sym_count, &uel_count))
        mexErrMsgIdAndTxt(ERRID"gdxSystemInfo", "GDX error (gdxSystemInfo)");

    /* create output data */
    plhs[0] = mxCreateStructMatrix(1, 1, 0, NULL);

    /* read symbols */
    for (int i = 0; i < sym_count; i++)
    {
        /* read symbol gdx data */
        if (!gdxSymbolInfo(gdx, i+1, name, &dim, &type))
            mexErrMsgIdAndTxt(ERRID"gdxSymbolInfo", "GDX error (gdxSymbolInfo)");
        if (!gdxSymbolInfoX(gdx, i+1, &nrecs, &subtype, text))
            mexErrMsgIdAndTxt(ERRID"gdxSymbolInfoX", "GDX error (gdxSymbolInfoX)");

        /* read symbol domain info */
        dominfo = gdxSymbolGetDomainX(gdx, i+1, domains_ptr);
        if (dominfo < 1 || dominfo > 3)
            mexErrMsgIdAndTxt(ERRID"gdxSymbolGetDomainX", "GDX error (gdxSymbolGetDomainX)");

        if (type == GMS_DT_EQU)
            subtype -= GMS_EQU_USERINFO_BASE;

        /* add symbol */
        gt_mex_addsymbol(plhs[0], name, text, type, subtype, dim, NULL,
            (const char**) domains_ptr, dominfo, nrecs);
    }

    gdxClose(gdx);
    gdxFree(&gdx);
}
