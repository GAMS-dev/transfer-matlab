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
#include <stdio.h>
#include <inttypes.h>

#include "mex.h"

#include "idxcc.h"
#include "gt_cmex_utils.h"
#include "gt_cmex_mex.h"
#include "gt_cmex_gdx_idx.h"

#define ERRID "GAMSTransfer:gt_cmex_idx_read_records:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_id, format, orig_format, lastdim, ival, ival2;
    double dval;
    size_t dim, nrecs, n_dom_fields;
    bool values_flag[GMS_VAL_MAX];
    char buf[GMS_SSSIZE], name[GMS_SSSIZE], gdx_filename[GMS_SSSIZE], sysdir[GMS_SSSIZE];
    double def_values[GMS_VAL_MAX];
    idxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;
    gdxUelIndex_t gdx_uel_index;
    gdxValues_t gdx_values;
    mwIndex idx;
    mwIndex mx_flat_idx[GMS_VAL_MAX];
    mwIndex mx_idx[GLOBAL_MAX_INDEX_DIM];
    mwIndex mx_idx_last[GLOBAL_MAX_INDEX_DIM];
    mwSize mx_dom_nrecs[GLOBAL_MAX_INDEX_DIM];
    mwIndex* col_nnz[GMS_VAL_MAX] = {NULL};
    mwIndex* mx_rows[GMS_VAL_MAX] = {NULL};
    mwIndex* mx_cols[GMS_VAL_MAX] = {NULL};
#ifdef WITH_R2018A_OR_NEWER
    mxUint64** mx_dom_idx = NULL;
    mxDouble* mx_values[GMS_VAL_MAX] = {NULL};
#else
    UINT64_T** mx_dom_idx = NULL;
    double* mx_values[GMS_VAL_MAX] = {NULL};
#endif
    mxArray* mx_arr_symbol_name = NULL;
    mxArray* mx_arr_symbol = NULL;
    mxArray* mx_arr_records = NULL;
    mxArray** mx_arr_dom_idx = NULL;
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 5, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_struct(prhs, 2);
    gt_mex_check_argument_cell(prhs, 3);
    gt_mex_check_argument_int(prhs, 4, GT_FILTER_NONE, 1, &orig_format);
    if (orig_format != GT_FORMAT_STRUCT && orig_format != GT_FORMAT_DENSEMAT &&
        orig_format != GT_FORMAT_SPARSEMAT && orig_format != GT_FORMAT_TABLE)
        mexErrMsgIdAndTxt(ERRID"prhs3", "Invalid record format.");

    /* create output data */
    plhs = NULL;

    /* start GDX */
    gt_idx_init_read(&gdx, sysdir, gdx_filename);

    for (size_t i = 0; i < mxGetNumberOfElements(prhs[3]); i++)
    {
        /* reset data */
        for (size_t j = 0; j < GMS_VAL_MAX; j++)
        {
            col_nnz[j] = NULL;
            mx_rows[j] = NULL;
            mx_cols[j] = NULL;
            mx_values[j] = NULL;
            mx_arr_values[j] = NULL;
        }
        format = orig_format;

        /* get symbol and symbol id */
        mx_arr_symbol_name = mxGetCell(prhs[3], i);
        if (!mxIsChar(mx_arr_symbol_name))
            mexErrMsgIdAndTxt(ERRID"symbol", "Symbol name must be of type 'char'.");
        mxGetString(mx_arr_symbol_name, buf, GMS_SSSIZE);
        gt_mex_getfield_symbol_obj(prhs[2], "Container.data", buf, true, &mx_arr_symbol);
        if (mxIsClass(mx_arr_symbol, "GAMSTransfer.Alias"))
            continue;
        gt_mex_getfield_dbl(mx_arr_symbol, "symbol", "read_entry", mxGetNaN(), true, 1, &dval);
        if (mxIsNaN(dval))
            continue;
        gt_mex_getfield_int(mx_arr_symbol, "symbol", "read_entry", 0, true,
            GT_FILTER_NONNEGATIVE, 1, &sym_id);

        /* read symbol gdx data */
        if (!idxGetSymbolInfo(gdx, sym_id-1, name, GMS_SSSIZE, &ival, gdx_uel_index, &ival2, buf, GMS_SSSIZE))
            mexErrMsgIdAndTxt(ERRID"idxGetSymbolInfo", "GDX error (idxGetSymbolInfo)");
        mxAssert(ival >= 0 && ival <= GLOBAL_MAX_INDEX_DIM, "Invalid dimension of symbol.");
        mxAssert(ival2 >= 0, "Invalid number of records");
        dim = (size_t) ival;
        nrecs = (size_t) ival2;
        if (format == GT_FORMAT_SPARSEMAT && dim > 2)
            mexErrMsgIdAndTxt(ERRID"prhs2", "Sparse format only supported with dimension <= 2.");

        /* prefer struct instead of dense_matrix for scalars */
        if (format == GT_FORMAT_DENSEMAT && dim == 0)
            format = GT_FORMAT_STRUCT;

        /* modify value fields based on type */
        values_flag[GMS_VAL_LEVEL] = true;
        values_flag[GMS_VAL_MARGINAL] = false;
        values_flag[GMS_VAL_LOWER] = false;
        values_flag[GMS_VAL_UPPER] = false;
        values_flag[GMS_VAL_SCALE] = false;

        /* records / uels struct */
        mx_arr_records = mxCreateStructMatrix(1, 1, 0, NULL);

        /* get domain information */
        for (size_t j = 0; j < dim; j++)
            sprintf(domains_ptr[j], "dim_%d", (int) j+1);
        for (size_t j = 0; j < GLOBAL_MAX_INDEX_DIM; j++)
            mx_dom_nrecs[j] = 1;
        for (size_t j = 0; j < dim; j++)
            mx_dom_nrecs[j] = gdx_uel_index[j];

        /* get default values dependent on type */
        gt_utils_type_default_values(GMS_DT_PAR, 0, true, def_values);

        /* create format dependent data (e.g. number of nonzeros, domain fields) */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                mx_arr_dom_idx = (mxArray**) mxCalloc(dim, sizeof(*mx_arr_dom_idx));
#ifdef WITH_R2018A_OR_NEWER
                mx_dom_idx = (mxUint64**) mxCalloc(dim, sizeof(*mx_dom_idx));
#else
                mx_dom_idx = (UINT64_T**) mxCalloc(dim, sizeof(*mx_dom_idx));
#endif
                break;

            case GT_FORMAT_SPARSEMAT:
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (values_flag[j])
                        col_nnz[j] = (mwIndex*) mxCalloc(mx_dom_nrecs[1], sizeof(mwIndex));

                if (!idxDataReadStart(gdx, name, &ival, gdx_uel_index, &ival2, buf, GMS_SSSIZE))
                    mexErrMsgIdAndTxt(ERRID"idxDataReadStart", "GDX error (idxDataReadStart)");

                /* nonzero counts depent on data, thus we need to loop through it */
                for (size_t j = 0; j < nrecs; j++)
                {
                    if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &ival))
                        mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                    /* get row and column index */
                    memset(mx_idx, 0, sizeof(mx_idx));
                    for (size_t k = 0; k < dim; k++)
                        mx_idx[k] = gdx_uel_index[k]-1;

                    /* non-zero counts for values except current one */
                    gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                        mx_dom_nrecs[1], j <= 0, j >= nrecs-1, values_flag, def_values,
                        gdx_values, col_nnz, NULL, NULL, NULL);
                }

                if (!idxDataReadDone(gdx))
                    mexErrMsgIdAndTxt(ERRID"idxDataReadDone", "GDX error (idxDataReadDone)");
                break;
        }

        /* add fields to records / uels and create record data structure */
        gt_mex_readdata_addfields(GMS_DT_PAR, dim, format, values_flag, domains_ptr,
            mx_arr_records, &n_dom_fields);
        gt_mex_readdata_create(dim, nrecs, format, values_flag, def_values,
            mx_dom_nrecs, col_nnz, mx_arr_dom_idx, mx_dom_idx, mx_arr_values,
            mx_values, mx_rows, mx_cols);

        /* start reading records */
        if (!idxDataReadStart(gdx, name, &ival, gdx_uel_index, &ival2, buf, GMS_SSSIZE))
            mexErrMsgIdAndTxt(ERRID"idxDataReadStart", "GDX error (idxDataReadStart)");

        /* store record values */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                for (size_t j = 0; j < nrecs; j++)
                {
                    /* read values */
                    if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                    /* store domain labels */
                    for (size_t k = 0; k < dim; k++)
                        mx_dom_idx[k][j] = gdx_uel_index[k];

                    /* parse values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (values_flag[k])
                            mx_values[k][j] = gt_utils_sv_gams2matlab(gdx_values[k], 0, NULL);
                }
                break;

            case GT_FORMAT_DENSEMAT:
                for (size_t j = 0; j < nrecs; j++)
                {
                    /* read values */
                    if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                    /* get indices in matrix */
                    for (size_t k = 0; k < dim; k++)
                        mx_idx[k] = gdx_uel_index[k] - 1;

                    /* parse values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                    {
                        if (values_flag[k])
                        {
                            idx = (dim > 0) ? mxCalcSingleSubscript(mx_arr_values[k], dim, mx_idx) : 0;
                            mx_values[k][idx] = gt_utils_sv_gams2matlab(gdx_values[k], 0, NULL);
                        }
                    }
                }
                break;

            case GT_FORMAT_SPARSEMAT:
                /* store column counts */
                for (size_t j = 0; j < mx_dom_nrecs[1]; j++)
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (values_flag[k])
                        {
                            mx_cols[k][j+1] = mx_cols[k][j] + col_nnz[k][j];
                            col_nnz[k][j] = 0;
                        }

                /* read value records */
                for (size_t j = 0; j < nrecs; j++)
                {
                    if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                    /* get indices in matrix (row: mx_idx[0]; col: mx_idx[1]) and store domain labels */
                    memset(mx_idx, 0, sizeof(mx_idx));
                    for (size_t k = 0; k < dim; k++)
                        mx_idx[k] = gdx_uel_index[k] - 1;

                    /* update non-zero counts and row indices for values in between and currrent non-zero */
                    gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                        mx_dom_nrecs[1], j <= 0, j >= nrecs-1, values_flag, def_values,
                        gdx_values, col_nnz, mx_cols, mx_rows, mx_flat_idx);

                    /* store values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (values_flag[k] && gdx_values[k] != 0.0)
                            mx_values[k][mx_flat_idx[k]] = gt_utils_sv_gams2matlab(gdx_values[k], 0, NULL);
                }
                break;
        }

        /* close gdx */
        if (!idxDataReadDone(gdx))
            mexErrMsgIdAndTxt(ERRID"idxDataReadDone", "GDX error (idxDataReadDone)");

        /* set domain fields */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                for (size_t j = 0; j < dim; j++)
                    mxSetFieldByNumber(mx_arr_records, 0, (int) j, mx_arr_dom_idx[j]);
                break;
        }

        /* set value fields */
        for (size_t j = 0, k = 0; j < GMS_VAL_MAX; j++)
            if (values_flag[j])
                mxSetFieldByNumber(mx_arr_records, 0, (int) (n_dom_fields + k++), mx_arr_values[j]);

        /* convert struct to table */
        if (format == GT_FORMAT_TABLE)
            gt_mex_struct2table(&mx_arr_records);

        /* store records in symbol */
        mxSetProperty(mx_arr_symbol, 0, "records", mx_arr_records);
        mxSetProperty(mx_arr_symbol, 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
        mxSetProperty(mx_arr_symbol, 0, "format_", mxCreateDoubleScalar(format));

        /* free */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                mxFree(mx_arr_dom_idx);
                mxFree(mx_dom_idx);
                break;
            case GT_FORMAT_SPARSEMAT:
                for (size_t i = 0; i < dim; i++)
                    if (values_flag[i])
                        mxFree(col_nnz[i]);
                break;
        }
    }

    idxClose(gdx);
    idxFree(&gdx);
}
