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

#include "mex.h"

#include "idxcc.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#define ERRID "GAMSTransfer:gt_idx_read_records:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_id, format, lastdim, ival, ival2;
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
    mxArray* mx_arr_records = NULL;
    mxArray* mx_arr_uels = NULL;
    mxArray** mx_arr_dom_idx = NULL;
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 4, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_symbol_obj(prhs, 2);
    gt_mex_check_argument_int(prhs, 3, GT_FILTER_NONE, 1, &format);
    if (format != GT_FORMAT_STRUCT && format != GT_FORMAT_DENSEMAT &&
        format != GT_FORMAT_SPARSEMAT && format != GT_FORMAT_TABLE)
        mexErrMsgIdAndTxt(ERRID"prhs3", "Invalid record format.");

    /* create output data */
    plhs = NULL;

    /* get symbol id */
    gt_mex_getfield_int(prhs[2], "symbol", "read_entry", 0, true, GT_FILTER_NONNEGATIVE, 1, &sym_id);

    /* start GDX */
    gt_idx_init_read(&gdx, sysdir, gdx_filename);

    /* read symbol gdx data */
    if (!idxGetSymbolInfo(gdx, sym_id-1, name, GMS_SSSIZE, &ival, gdx_uel_index, &ival2, buf, GMS_SSSIZE))
        mexErrMsgIdAndTxt(ERRID"idxGetSymbolInfo", "GDX error (idxGetSymbolInfo)");
    mxAssert(ival >= 0 && ival <= GLOBAL_MAX_INDEX_DIM, "Invalid dimension of symbol.");
    mxAssert(ival2 >= 0, "Invalid number of records");
    dim = (size_t) ival;
    nrecs = (size_t) ival2;
    if (format == GT_FORMAT_SPARSEMAT && dim > 2)
        mexErrMsgIdAndTxt(ERRID"prhs2", "Sparse format only supported with dimension <= 2.");

    /* modify value fields based on type */
    values_flag[GMS_VAL_LEVEL] = true;
    values_flag[GMS_VAL_MARGINAL] = false;
    values_flag[GMS_VAL_LOWER] = false;
    values_flag[GMS_VAL_UPPER] = false;
    values_flag[GMS_VAL_SCALE] = false;

    /* records / uels struct */
    mx_arr_records = mxCreateStructMatrix(1, 1, 0, NULL);
    mx_arr_uels = mxCreateStructMatrix(1, 1, 0, NULL);

    /* get domain information */
    for (size_t i = 0; i < dim; i++)
        sprintf(domains_ptr[i], "dim_%zu", i+1);
    for (size_t i = 0; i < GLOBAL_MAX_INDEX_DIM; i++)
        mx_dom_nrecs[i] = 1;
    for (size_t i = 0; i < dim; i++)
        mx_dom_nrecs[i] = gdx_uel_index[i];

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
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i])
                    col_nnz[i] = (mwIndex*) mxCalloc(mx_dom_nrecs[1], sizeof(mwIndex));

            if (!idxDataReadStart(gdx, name, &ival, gdx_uel_index, &ival2, buf, GMS_SSSIZE))
                mexErrMsgIdAndTxt(ERRID"idxDataReadStart", "GDX error (idxDataReadStart)");

            /* nonzero counts depent on data, thus we need to loop through it */
            for (size_t i = 0; i < nrecs; i++)
            {
                if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &ival))
                    mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                /* get row and column index */
                memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM);
                for (size_t j = 0; j < dim; j++)
                    mx_idx[j] = gdx_uel_index[j]-1;

                /* non-zero counts for values except current one */
                gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                    mx_dom_nrecs[1], i <= 0, i >= nrecs-1, values_flag, def_values,
                    gdx_values, col_nnz, NULL, NULL, NULL);
            }

            if (!idxDataReadDone(gdx))
                mexErrMsgIdAndTxt(ERRID"idxDataReadDone", "GDX error (idxDataReadDone)");
            break;
    }

    /* add fields to records / uels and create record data structure */
    gt_mex_readdata_addfields(GMS_DT_PAR, dim, format, values_flag, domains_ptr,
        mx_arr_records, mx_arr_uels, &n_dom_fields);
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
            for (size_t i = 0; i < nrecs; i++)
            {
                /* read values */
                if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                /* store domain labels */
                for (size_t j = 0; j < dim; j++)
                    mx_dom_idx[j][i] = gdx_uel_index[j];

                /* parse values */
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (values_flag[j])
                        mx_values[j][i] = gt_utils_sv_gams2matlab(gdx_values[j]);
            }
            break;

        case GT_FORMAT_DENSEMAT:
            for (size_t i = 0; i < nrecs; i++)
            {
                /* read values */
                if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                /* get indices in matrix */
                for (size_t j = 0; j < dim; j++)
                    mx_idx[j] = gdx_uel_index[j] - 1;

                /* parse values */
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                {
                    if (values_flag[j])
                    {
                        idx = (dim > 0) ? mxCalcSingleSubscript(mx_arr_values[j], dim, mx_idx) : 0;
                        mx_values[j][idx] = gt_utils_sv_gams2matlab(gdx_values[j]);
                    }
                }
            }
            break;

        case GT_FORMAT_SPARSEMAT:
            /* store column counts */
            for (size_t i = 0; i < mx_dom_nrecs[1]; i++)
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (values_flag[j])
                    {
                        mx_cols[j][i+1] = mx_cols[j][i] + col_nnz[j][i];
                        col_nnz[j][i] = 0;
                    }

            /* read value records */
            for (size_t i = 0; i < nrecs; i++)
            {
                if (!idxDataRead(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"idxDataRead", "GDX error (idxDataRead)");

                /* get indices in matrix (row: mx_idx[0]; col: mx_idx[1]) and store domain labels */
                memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM * sizeof(mwIndex));
                for (size_t j = 0; j < dim; j++)
                    mx_idx[j] = gdx_uel_index[j] - 1;

                /* update non-zero counts and row indices for values in between and currrent non-zero */
                gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                    mx_dom_nrecs[1], i <= 0, i >= nrecs-1, values_flag, def_values,
                    gdx_values, col_nnz, mx_cols, mx_rows, mx_flat_idx);

                /* store values */
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (values_flag[j] && gdx_values[j] != 0.0)
                        mx_values[j][mx_flat_idx[j]] = gt_utils_sv_gams2matlab(gdx_values[j]);
            }
            break;
    }

    /* close gdx */
    if (!idxDataReadDone(gdx))
        mexErrMsgIdAndTxt(ERRID"idxDataReadDone", "GDX error (idxDataReadDone)");
    idxClose(gdx);
    idxFree(&gdx);

    /* set domain fields */
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            for (size_t i = 0; i < dim; i++)
                mxSetFieldByNumber(mx_arr_records, 0, (int) i, mx_arr_dom_idx[i]);
            break;
    }

    /* set value fields */
    for (size_t i = 0, j = 0; i < GMS_VAL_MAX; i++)
        if (values_flag[i])
            mxSetFieldByNumber(mx_arr_records, 0, (int) (n_dom_fields + j++), mx_arr_values[i]);

    /* convert struct to table */
    if (format == GT_FORMAT_TABLE)
        gt_mex_struct2table(&mx_arr_records);

    /* store records in symbol */
    mxSetProperty((mxArray*) prhs[2], 0, "records", mx_arr_records);
    mxSetProperty((mxArray*) prhs[2], 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
    mxSetProperty((mxArray*) prhs[2], 0, "format_", mxCreateDoubleScalar(mxGetNaN()));

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
