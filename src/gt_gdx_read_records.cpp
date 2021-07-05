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

#include <unordered_map>
#include <cstring>
#include <math.h>

#include "mex.h"

#include "gdxcc.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#define ERRID "GAMSTransfer:gt_gdx_read_records:"

using namespace std;

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_id, format, type, subtype, lastdim, uel_map, ival;
    size_t dim, nrecs, n_dom_fields;
    bool support_categorical;
    bool values_flag[GMS_VAL_MAX];
    char buf[GMS_SSSIZE], gdx_filename[GMS_SSSIZE], sysdir[GMS_SSSIZE];
    double def_values[GMS_VAL_MAX];
    gdxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;
    gdxUelIndex_t gdx_uel_index;
    gdxUelIndex_t dom_symid;
    gdxValues_t gdx_values;
    unordered_map<int, size_t>* dom_uel_dim_maps[GLOBAL_MAX_INDEX_DIM];
    int* dom_uels_used[GLOBAL_MAX_INDEX_DIM] = {NULL};
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
    mxArray* mx_arr_dom_uels[GLOBAL_MAX_INDEX_DIM] = {NULL};
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};
    mxArray** mx_arr_dom_idx = NULL;

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 6, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_symbol_obj(prhs, 2);
    gt_mex_check_argument_int(prhs, 3, GT_FILTER_NONE, 1, &format);
    gt_mex_check_argument_bool(prhs, 4, 5, values_flag);
    gt_mex_check_argument_bool(prhs, 5, 1, &support_categorical);
    if (format != GT_FORMAT_STRUCT && format != GT_FORMAT_DENSEMAT &&
        format != GT_FORMAT_SPARSEMAT && format != GT_FORMAT_TABLE)
        mexErrMsgIdAndTxt(ERRID"prhs3", "Invalid record format.");

    /* create output data */
    plhs = NULL;

    /* get symbol id */
    gt_mex_getfield_int(prhs[2], "symbol", "read_entry", 0, true, GT_FILTER_NONNEGATIVE, 1, &sym_id);

    /* start GDX */
    gt_gdx_init_read(&gdx, sysdir, gdx_filename);

    /* read symbol gdx data */
    if (!gdxSymbolInfo(gdx, sym_id, buf, &ival, &type))
        mexErrMsgIdAndTxt(ERRID"gdxSymbolInfo", "GDX error (gdxSymbolInfo)");
    mxAssert(ival >= 0 && ival <= GLOBAL_MAX_INDEX_DIM, "Invalid dimension of symbol.");
    dim = (size_t) ival;
    if (format == GT_FORMAT_SPARSEMAT && dim > 2)
        mexErrMsgIdAndTxt(ERRID"prhs3", "Sparse format only supported with dimension <= 2.");
    if (type == GMS_DT_SET && format != GT_FORMAT_STRUCT && format != GT_FORMAT_TABLE)
        mexErrMsgIdAndTxt(ERRID"prhs3", "GAMS Sets only supported with format 'struct' or 'table'.");
    if (!gdxSymbolInfoX(gdx, sym_id, &ival, &subtype, buf))
        mexErrMsgIdAndTxt(ERRID"gdxSymbolInfoX", "GDX error (gdxSymbolInfoX)");
    mxAssert(ival >= 0, "Invalid number of records");
    nrecs = (size_t) ival;
    if (!gdxSymbolGetDomain(gdx, sym_id, dom_symid))
        mexErrMsgIdAndTxt(ERRID"gdxSymbolGetDomain", "GDX error (gdxSymbolGetDomain)");

    /* prefer struct instead of dense_matrix for scalars */
    if (format == GT_FORMAT_DENSEMAT && dim == 0)
        format = GT_FORMAT_STRUCT;

    /* modify value fields based on type */
    switch (type)
    {
        case GMS_DT_SET:
            values_flag[GMS_VAL_MARGINAL] = false;
            values_flag[GMS_VAL_LOWER] = false;
            values_flag[GMS_VAL_UPPER] = false;
            values_flag[GMS_VAL_SCALE] = false;
            break;
        case GMS_DT_PAR:
            values_flag[GMS_VAL_MARGINAL] = false;
            values_flag[GMS_VAL_LOWER] = false;
            values_flag[GMS_VAL_UPPER] = false;
            values_flag[GMS_VAL_SCALE] = false;
            break;
        case GMS_DT_ALIAS:
            gdxClose(gdx);
            gdxFree(&gdx);
            return;
    }

    /* records / uels struct */
    mx_arr_records = mxCreateStructMatrix(1, 1, 0, NULL);
    mx_arr_uels = mxCreateStructMatrix(1, 1, 0, NULL);

    /* get domain information */
    for (size_t i = 0; i < GLOBAL_MAX_INDEX_DIM; i++)
        mx_dom_nrecs[i] = 1;
    for (size_t i = 0; i < dim; i++)
    {
        int dom_nrecs, dom_dim, dom_type;

        /* get domain info */
        if (!gdxSymbolInfo(gdx, dom_symid[i], buf, &dom_dim, &dom_type))
            mexErrMsgIdAndTxt(ERRID"gdxSymbolInfo", "GDX error (gdxSymbolInfo)");
        mxAssert(dom_type == GMS_DT_SET, "Invalid domain data type.");
        mxAssert(dom_dim == 1, "Invalid domain dimension.");

        /* map domain uels and get domain sizes */
        dom_uel_dim_maps[i] = new unordered_map<int, size_t>();

        /* get number of records in domain and start reading */
        if (!gdxDataReadRawStart(gdx, dom_symid[i], &dom_nrecs))
            mexErrMsgIdAndTxt(ERRID"gdxDataReadRawStart", "GDX error (gdxDataReadRawStart)");
        mxAssert(dom_nrecs >= 0, "Invalid number of symbol records.");
        mx_dom_nrecs[i] = (mwSize) dom_nrecs;

        /* create storage for domain uels (these will become categorical categories) */
        mx_arr_dom_uels[i] = mxCreateCellMatrix(mx_dom_nrecs[i], 1);
        dom_uels_used[i] = (int*) mxCalloc(mx_dom_nrecs[i], sizeof(int));

        /* read domain records */
        for (size_t j = 0; j < mx_dom_nrecs[i]; j++)
        {
            if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

            dom_uel_dim_maps[i]->emplace(gdx_uel_index[0], j);

            if (!gdxUMUelGet(gdx, gdx_uel_index[0], buf, &uel_map))
                mexErrMsgIdAndTxt(ERRID"gdxUMUelGet", "GDX error (gdxUMUelGet)");
            mxSetCell(mx_arr_dom_uels[i], j, mxCreateString(buf));
        }

        if (!gdxDataReadDone(gdx))
            mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");
    }

    /* load domains and transform to domain_label */
    if (!gdxSymbolGetDomainX(gdx, sym_id, domains_ptr))
        mexErrMsgIdAndTxt(ERRID"gdxSymbolGetDomainX", "GDX error (gdxSymbolGetDomainX)");
    for (size_t i = 0; i < dim; i++)
    {
        if (!strcmp(domains_ptr[i], "*"))
            strcpy(domains_ptr[i], "uni");
        sprintf(buf, "_%d", (int) i+1);
        strcat(domains_ptr[i], buf);
    }

    /* get default values dependent on type */
    gt_utils_type_default_values(type, subtype, true, def_values);

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

            if (!gdxDataReadRawStart(gdx, sym_id, &ival))
                mexErrMsgIdAndTxt(ERRID"gdxDataReadRawStart", "GDX error (gdxDataReadRawStart)");

            /* nonzero counts depent on data, thus we need to loop through it */
            for (size_t i = 0; i < nrecs; i++)
            {
                if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &ival))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                /* get row and column index */
                memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM);
                for (size_t j = 0; j < dim; j++)
                    mx_idx[j] = dom_uel_dim_maps[j]->at(gdx_uel_index[j]);

                /* non-zero counts for values except current one */
                gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                    mx_dom_nrecs[1], i <= 0, i >= nrecs-1, values_flag, def_values,
                    gdx_values, col_nnz, NULL, NULL, NULL);
            }

            if (!gdxDataReadDone(gdx))
                mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");
            break;
    }

    /* add fields to records / uels and create record data structure */
    gt_mex_readdata_addfields(type, dim, format, values_flag, domains_ptr,
        mx_arr_records, mx_arr_uels, &n_dom_fields);
    gt_mex_readdata_create(dim, nrecs, format, values_flag, def_values,
        mx_dom_nrecs, col_nnz, mx_arr_dom_idx, mx_dom_idx, mx_arr_values,
        mx_values, mx_rows, mx_cols);

    /* start reading records */
    if (!gdxDataReadRawStart(gdx, sym_id, &ival))
        mexErrMsgIdAndTxt(ERRID"gdxDataReadRawStart", "GDX error (gdxDataReadRawStart)");

    /* store record values */
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            for (size_t i = 0; i < nrecs; i++)
            {
                /* read values */
                if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                /* store domain labels */
                for (size_t j = 0; j < dim; j++)
                {
                    idx = dom_uel_dim_maps[j]->at(gdx_uel_index[j]);
                    mx_dom_idx[j][i] = idx + 1;
                    dom_uels_used[j][idx] = true;
                }

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
                if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                /* get indices in matrix and store domain labels */
                for (size_t j = 0; j < dim; j++)
                {
                    idx = dom_uel_dim_maps[j]->at(gdx_uel_index[j]);
                    mx_idx[j] = idx;
                    dom_uels_used[j][idx] = true;
                }

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
                if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                /* get indices in matrix (row: mx_idx[0]; col: mx_idx[1]) and store domain labels */
                memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM * sizeof(mwIndex));
                for (size_t j = 0; j < dim; j++)
                {
                    idx = dom_uel_dim_maps[j]->at(gdx_uel_index[j]);
                    mx_idx[j] = idx;
                    dom_uels_used[j][idx] = true;
                }

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

    /* convert set text ids to explanatory text */
    if (type == GMS_DT_SET && values_flag[GMS_VAL_LEVEL])
    {
        mxArray* mx_arr_text = mxCreateCellMatrix(nrecs, 1);

        /* get set element explanatory text */
        for (size_t i = 0; i < mxGetNumberOfElements(mx_arr_values[GMS_VAL_LEVEL]); i++)
        {
            int text_id, node;
            text_id = (int) round(mx_values[GMS_VAL_LEVEL][i]);
            if (text_id <= 0)
                strcpy(buf, "");
            else if (!gdxGetElemText(gdx, text_id, buf, &node))
                strcpy(buf, "");
            mxSetCell(mx_arr_text, i, mxCreateString(buf));
        }

        /* convert text into categorical */
        if (support_categorical)
            gt_mex_categorical(&mx_arr_text);

        /* replace value field by text field */
        mx_arr_values[GMS_VAL_LEVEL] = mx_arr_text;
    }

    /* close gdx */
    if (!gdxDataReadDone(gdx))
        mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");
    gdxClose(gdx);
    gdxFree(&gdx);

    /* if less uels have actually been used than the domain has uels, we want to
     * only store the actually used once to save some storage in case of domain =
     * universe */
    for (size_t i = 0; i < dim; i++)
    {
        size_t num_used = 0;
        mxArray* mx_arr_dom_uels_used;

        /* only apply for universe */
        if (dom_symid[i] > 0)
            continue;

        /* get number of used uels */
        for (size_t j = 0; j < mx_dom_nrecs[i]; j++)
            if (dom_uels_used[i][j])
                dom_uels_used[i][j] = num_used++;
            else
                dom_uels_used[i][j] = -1;
        if (mx_dom_nrecs[i] == num_used)
            continue;

        /* get actually used uels */
        mx_arr_dom_uels_used = mxCreateCellMatrix(num_used, 1);
        for (size_t j = 0, k = 0; j < mx_dom_nrecs[i]; j++)
            if (dom_uels_used[i][j] >= 0)
                mxSetCell(mx_arr_dom_uels_used, k++, mxDuplicateArray(mxGetCell(mx_arr_dom_uels[i], j)));

        /* adapt domain indices */
        for (size_t j = 0; j < nrecs; j++)
            mx_dom_idx[i][j] = dom_uels_used[i][mx_dom_idx[i][j]-1] + 1;

        /* replace uels */
        mxDestroyArray(mx_arr_dom_uels[i]);
        mx_arr_dom_uels[i] = mx_arr_dom_uels_used;
    }

    /* set domain fields */
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            if (support_categorical)
                for (size_t i = 0; i < dim; i++)
                    gt_mex_domain2categorical(&mx_arr_dom_idx[i], mx_arr_dom_uels[i]);
            for (size_t i = 0; i < dim; i++)
                mxSetFieldByNumber(mx_arr_records, 0, (int) i, mx_arr_dom_idx[i]);
            break;
    }

    /* set value fields */
    for (size_t i = 0, j = 0; i < GMS_VAL_MAX; i++)
        if (values_flag[i])
            mxSetFieldByNumber(mx_arr_records, 0, (int) (n_dom_fields + j++), mx_arr_values[i]);

    /* set uel fields */
    for (size_t i = 0; i < dim; i++)
        mxSetFieldByNumber(mx_arr_uels, 0, (int) i, mx_arr_dom_uels[i]);
    mxSetProperty((mxArray*) prhs[2], 0, "uels_", mx_arr_uels);

    /* convert struct to table */
    if (format == GT_FORMAT_TABLE)
        gt_mex_struct2table(&mx_arr_records);

    /* store records in symbol */
    mxSetProperty((mxArray*) prhs[2], 0, "records", mx_arr_records);
    mxSetProperty((mxArray*) prhs[2], 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
    mxSetProperty((mxArray*) prhs[2], 0, "format_", mxCreateDoubleScalar(format));

    /* empty uel maps and free */
    for (size_t i = 0; i < dim; i++)
    {
        delete dom_uel_dim_maps[i];
        mxFree(dom_uels_used[i]);
    }
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
