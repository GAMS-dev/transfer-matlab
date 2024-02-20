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

#include "idxcc.h"
#include "mex.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define ERRID "gams:transfer:cmex:gt_idx_write:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int format;
    size_t dim, nrecs;
    char gdx_filename[GMS_SSSIZE], buf[GMS_SSSIZE], sysdir[GMS_SSSIZE], name[GMS_SSSIZE];
    char text[GMS_SSSIZE];
    double def_values[GMS_VAL_MAX];
    bool was_table, support_table, issorted, have_nrecs;
    char* data_name = NULL;
    idxHandle_t gdx = NULL;
    gdxUelIndex_t gdx_uel_index;
    gdxValues_t gdx_values;
    int sizes_int[GLOBAL_MAX_INDEX_DIM];
    mwIndex idx;
    mwIndex mx_idx[GLOBAL_MAX_INDEX_DIM];
    mwIndex* mx_rows[GMS_VAL_MAX] = {NULL};
    mwIndex* mx_cols[GMS_VAL_MAX] = {NULL};
    size_t* idx_sorted = NULL;
    size_t* col_nnz[GMS_VAL_MAX] = {NULL};
    size_t sizes[GLOBAL_MAX_INDEX_DIM];
#ifdef WITH_R2018A_OR_NEWER
    mxInt32** mx_domains = NULL;
    mxDouble* mx_values[GMS_VAL_MAX] = {NULL};
#else
    INT32_T** mx_domains = NULL;
    double* mx_values[GMS_VAL_MAX] = {NULL};
#endif
    mxLogical* mx_enable = NULL;
    mxArray* mx_arr_symbol = NULL;
    mxArray* mx_arr_symbol_data = NULL;
    mxArray* mx_arr_symbol_def = NULL;
    mxArray* mx_arr_records = NULL;
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};
    mxArray** mx_arr_domains = NULL;
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[2] = {NULL};

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 6, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_struct(prhs, 2);
    gt_mex_check_argument_bool(prhs, 4, 1, &issorted);
    gt_mex_check_argument_bool(prhs, 5, 1, &support_table);

    /* create output data */
    plhs = NULL;

    /* start GDX */
    gt_idx_init_write(&gdx, sysdir, gdx_filename);

#ifdef WITH_R2018A_OR_NEWER
    mx_enable = mxGetLogicals(prhs[3]);
#else
    mx_enable = (mxLogical*) mxGetData(prhs[3]);
#endif
    for (int i = 0; i < mxGetNumberOfFields(prhs[2]); i++)
    {
        if (!mx_enable[i])
            continue;

        /* reset pointers */
        for (size_t j = 0; j < GMS_VAL_MAX; j++)
        {
            mx_rows[j] = NULL;
            mx_cols[j] = NULL;
            col_nnz[j] = NULL;
            mx_values[j] = NULL;
            mx_arr_values[j] = NULL;
        }

        /* get data field */
        mx_arr_symbol = mxGetFieldByNumber(prhs[2], 0, i);
        data_name = (char*) mxGetFieldNameByNumber(prhs[2], i);

        if (!mxIsClass(mx_arr_symbol, "gams.transfer.symbol.Parameter"))
            mexErrMsgIdAndTxt(ERRID"type", "Symbol '%s' has invalid type.", data_name);
        mx_arr_symbol_def = mxGetProperty(mx_arr_symbol, 0, "def_");
        mx_arr_symbol_data = mxGetProperty(mx_arr_symbol, 0, "data_");

        for (size_t j = 0; j < GLOBAL_MAX_INDEX_DIM; j++)
            sizes[j] = 1;

        /* get records format (ignore unsupported formats) */
        if (mxIsClass(mx_arr_symbol_data, "gams.transfer.symbol.data.Table"))
            format = GT_FORMAT_TABLE;
        else if (mxIsClass(mx_arr_symbol_data, "gams.transfer.symbol.data.Struct"))
            format = GT_FORMAT_STRUCT;
        else if (mxIsClass(mx_arr_symbol_data, "gams.transfer.symbol.data.DenseMatrix"))
            format = GT_FORMAT_DENSEMAT;
        else if (mxIsClass(mx_arr_symbol_data, "gams.transfer.symbol.data.SparseMatrix"))
            format = GT_FORMAT_SPARSEMAT;
        else
            continue;

        /* get fields */
        gt_mex_getfield_str(mx_arr_symbol, data_name, "name_", "", true, name, GMS_SSSIZE);
        gt_mex_getfield_str(mx_arr_symbol, data_name, "description_", "", false, text, GMS_SSSIZE);

        dim = mxGetNumberOfElements(mxGetProperty(mx_arr_symbol_def, 0, "domains_"));
        for (size_t j = 0; j < dim; j++)
        {
            call_prhs[0] = mx_arr_symbol;
            call_prhs[1] = mxCreateDoubleScalar(j+1);
            if (mexCallMATLAB(1, call_plhs, 2, call_prhs, "getAxis"))
                mexErrMsgIdAndTxt(ERRID"number_records", "Calling 'getAxis' failed.");
            call_prhs[0] = mxGetProperty(call_plhs[0], 0, "unique_labels_");
            if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "count"))
                mexErrMsgIdAndTxt(ERRID"number_records", "Calling 'count' failed.");
            sizes[j] = mxGetScalar(call_plhs[0]);
        }

        mx_arr_domains = (mxArray**) mxCalloc(dim, sizeof(*mx_arr_domains));
#ifdef WITH_R2018A_OR_NEWER
        mx_domains = (mxInt32**) mxCalloc(dim, sizeof(*mx_domains));
#else
        mx_domains = (INT32_T**) mxCalloc(dim, sizeof(*mx_domains));
#endif

        /* get optional fields that are format dependent */
        if (format != GT_FORMAT_EMPTY)
        {
            if (support_table)
                gt_mex_getfield_table2struct(mx_arr_symbol_data, data_name, "records_", false, &mx_arr_records, &was_table);
            else
            {
                gt_mex_getfield_struct(mx_arr_symbol_data, data_name, "records_", false, &mx_arr_records);
                was_table = false;
            }
        }

        for (size_t j = 0; j < dim; j++)
            sizes_int[j] = (int) sizes[j];
        if (!idxDataWriteStart(gdx, name, text, (int) dim, sizes_int, buf, GMS_SSSIZE))
            mexErrMsgIdAndTxt(ERRID"idxDataWriteStart", "GDX error (idxDataWriteStart): %s", buf);

        /* only go on to writing records if records are available */
        if (!mx_arr_records || format == GT_FORMAT_UNKNOWN || format == GT_FORMAT_EMPTY ||
            format == GT_FORMAT_NOT_READ)
        {
            if (!idxDataWriteDone(gdx))
                mexErrMsgIdAndTxt(ERRID"idxDataWriteDone", "GDX error (idxDataWriteDone)");
            mxFree(mx_arr_domains);
            mxFree(mx_domains);
            continue;
        }

        /* get domain and value fields of record field */
        gt_mex_get_records(data_name, dim, false, mx_arr_records, mx_arr_values,
            mx_values, mx_arr_domains, mx_domains, NULL);
        gt_utils_type_default_values(GMS_DT_PAR, 0, false, def_values);

        /* get number of records */
        nrecs = 0;
        have_nrecs = false;
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                for (size_t j = 0; j < dim; j++)
                    if (mx_arr_domains[j])
                    {
                        nrecs = mxGetNumberOfElements(mx_arr_domains[j]);
                        have_nrecs = true;
                        break;
                    }
            case GT_FORMAT_DENSEMAT:
                if (have_nrecs)
                    break;
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (mx_arr_values[j])
                    {
                        nrecs = mxGetNumberOfElements(mx_arr_values[j]);
                        have_nrecs = true;
                        break;
                    }
                break;
        }
        if (have_nrecs && nrecs == 0)
        {
            if (!idxDataWriteDone(gdx))
                mexErrMsgIdAndTxt(ERRID"idxDataWriteDone", "GDX error (idxDataWriteDone)");
            mxFree(mx_arr_domains);
            mxFree(mx_domains);
            continue;
        }

        /* write values */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                mxAssert(have_nrecs, "Number of records not available");

                /* sort data if needed */
                if (!issorted)
                {
                    idx_sorted = (size_t*) mxMalloc(nrecs * sizeof(size_t));
                    for (size_t j = 0; j < nrecs; j++)
                        idx_sorted[j] = j;
                    gt_utils_sort_domains(name, nrecs, dim, mx_domains, NULL, NULL, idx_sorted);
                }

                for (size_t j_unsorted = 0, j; j_unsorted < nrecs; j_unsorted++)
                {
                    j = (issorted) ? j_unsorted : idx_sorted[j_unsorted];

                    for (size_t k = 0; k < dim; k++)
                        gdx_uel_index[k] = mx_domains[k][j];
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                    {
                        if (mx_arr_values[k])
                            gdx_values[k] = mx_values[k][j];
                        else
                            gdx_values[k] = def_values[k];
                    }

                    if (!idxDataWrite(gdx, gdx_uel_index, gdx_values[GMS_VAL_LEVEL]))
                        gt_idx_write_record_error(gdx, name, dim, gdx_uel_index);
                }
                break;

            case GT_FORMAT_DENSEMAT:
                mxAssert(have_nrecs, "Number of records not available");

                for (size_t j = 0; j < nrecs; j++)
                {
                    bool is_default_rec = true, found_index;

                    /* calculate row-major index */
                    idx = 0;
                    found_index = (dim == 0);
                    for (size_t k1 = dim, d = 1, k; k1 > 0; k1--)
                    {
                        k = k1 - 1;
                        mx_idx[k] = ((int) floor((double) j / (double) d)) % sizes[k];
                        gdx_uel_index[k] = mx_idx[k] + 1;
                        d *= sizes[k];
                    }
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (mx_arr_values[k])
                        {
                            idx = (dim > 0) ? mxCalcSingleSubscript(mx_arr_values[k], dim, mx_idx) : 0;
                            found_index = true;
                            break;
                        }
                    if (!found_index)
                        continue;

                    /* write values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                    {
                        if (mx_arr_values[k])
                            gdx_values[k] = mx_values[k][idx];
                        else
                            gdx_values[k] = def_values[k];
                        is_default_rec = (gdx_values[k] != def_values[k]) ? false : is_default_rec;
                    }
                    if (is_default_rec)
                        continue;
                    if (!idxDataWrite(gdx, gdx_uel_index, gdx_values[GMS_VAL_LEVEL]))
                        gt_idx_write_record_error(gdx, name, dim, gdx_uel_index);
                }
                break;

            case GT_FORMAT_SPARSEMAT:
                mxAssert(dim <= 2, "Invalid sparse dimension");

                /* row / col data access */
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                {
                    if (!mx_arr_values[j])
                        continue;
                    col_nnz[j] = (size_t*) mxCalloc(sizes[1], sizeof(size_t));
                    mx_rows[j] = mxGetIr(mx_arr_values[j]);
                    mx_cols[j] = mxGetJc(mx_arr_values[j]);
                }

                for (int j = 0; j < sizes[0]; j++)
                {
                    for (int k = 0; k < sizes[1]; k++)
                    {
                        /* set domains */
                        if (dim >= 1)
                            gdx_uel_index[0] = j+1;
                        if (dim >= 2)
                            gdx_uel_index[1] = k+1;

                        /* check if element (j,k) is nonzero and get index in value array */
                        for (size_t kk = 0; kk < GMS_VAL_MAX; kk++)
                        {
                            gdx_values[kk] = def_values[kk];
                            if (!mx_arr_values[kk])
                                continue;
                            idx = mx_cols[kk][k] + col_nnz[kk][k];
                            if (idx >= mx_cols[kk][k+1] || mx_rows[kk][idx] != j)
                            {
                                gdx_values[kk] = 0;
                                continue;
                            }
                            col_nnz[kk][k]++;
                            gdx_values[kk] = mx_values[kk][idx];
                        }

                        /* write values */
                        if (!idxDataWrite(gdx, gdx_uel_index, gdx_values[GMS_VAL_LEVEL]))
                            gt_idx_write_record_error(gdx, name, dim, gdx_uel_index);
                    }
                }

                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (mx_arr_values[j])
                        mxFree(col_nnz[j]);
                break;

            default:
                mexErrMsgIdAndTxt(ERRID"check_format", "Invalid records format.");
                break;
        }

        if (!idxDataWriteDone(gdx))
            mexErrMsgIdAndTxt(ERRID"idxDataWriteDone", "GDX error (idxDataWriteDone)");

        mxFree(mx_arr_domains);
        mxFree(mx_domains);
    }

    idxClose(gdx);
    idxFree(&gdx);
}
