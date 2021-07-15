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

#include <string.h>
#include <math.h>

#include "mex.h"

#include "gdxcc.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#define ERRID "GAMSTransfer:gt_gdx_read_records:"

#define GET_DOM_MAP(dim,idx) ((dom_symid[dim] <= 0) ? idx-1 : dom_uel_dim_maps[dom_symid[dim]][idx])

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int sym_id, format, orig_format, type, subtype, lastdim, ival, sym_count, uel_count;
    double dval;
    size_t dim, nrecs, n_dom_fields;
    bool support_categorical;
    bool orig_values_flag[GMS_VAL_MAX], values_flag[GMS_VAL_MAX];
    char buf[GMS_SSSIZE], gdx_filename[GMS_SSSIZE], sysdir[GMS_SSSIZE];
    double def_values[GMS_VAL_MAX];
    gdxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;
    gdxUelIndex_t gdx_uel_index;
    gdxUelIndex_t dom_symid;
    gdxValues_t gdx_values;
    int** dom_uel_dim_maps = NULL;
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
    mxArray* mx_arr_symbol_name = NULL;
    mxArray* mx_arr_symbol = NULL;
    mxArray* mx_arr_records = NULL;
    mxArray* mx_arr_uels = NULL;
    mxArray* mx_arr_dom_uels[GLOBAL_MAX_INDEX_DIM] = {NULL};
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};
    mxArray** mx_arr_dom_idx = NULL;

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 7, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_struct(prhs, 2);
    gt_mex_check_argument_cell(prhs, 3);
    gt_mex_check_argument_int(prhs, 4, GT_FILTER_NONE, 1, &orig_format);
    gt_mex_check_argument_bool(prhs, 5, 5, orig_values_flag);
    gt_mex_check_argument_bool(prhs, 6, 1, &support_categorical);
    if (orig_format != GT_FORMAT_STRUCT && orig_format != GT_FORMAT_DENSEMAT &&
        orig_format != GT_FORMAT_SPARSEMAT && orig_format != GT_FORMAT_TABLE)
        mexErrMsgIdAndTxt(ERRID"prhs3", "Invalid record format.");

    /* create output data */
    plhs = NULL;

    /* start GDX */
    gt_gdx_init_read(&gdx, sysdir, gdx_filename);
    if (!gdxSystemInfo(gdx, &sym_count, &uel_count))
        mexErrMsgIdAndTxt(ERRID"gdxSystemInfo", "GDX error (gdxSystemInfo)");

    dom_uel_dim_maps = (int**) mxCalloc(sym_count+1, sizeof(int*));

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
            values_flag[j] = orig_values_flag[j];
        }
        for (size_t j = 0; j < GLOBAL_MAX_INDEX_DIM; j++)
        {
            dom_uels_used[j] = NULL;
            mx_arr_dom_uels[j] = NULL;
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

        /* check format: sets can be read as table and struct only */
        if (mxIsClass(mx_arr_symbol, "GAMSTransfer.Set") &&
            (format == GT_FORMAT_DENSEMAT || format == GT_FORMAT_SPARSEMAT))
            format = GT_FORMAT_STRUCT;
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                break;
            case GT_FORMAT_DENSEMAT:
            case GT_FORMAT_SPARSEMAT:
                if (mxIsClass(mx_arr_symbol, "GAMSTransfer.Set"))
                    format = GT_FORMAT_STRUCT;
                break;
            default:
                mexErrMsgIdAndTxt(ERRID"format", "Invalid records format");
        }

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

        /* records struct */
        mx_arr_records = mxCreateStructMatrix(1, 1, 0, NULL);

        /* get domain information */
        for (size_t j = 0; j < GLOBAL_MAX_INDEX_DIM; j++)
            mx_dom_nrecs[j] = 1;
        for (size_t j = 0; j < dim; j++)
        {
            int dom_nrecs, dom_dim, dom_type;

            /* get domain info */
            if (!gdxSymbolInfo(gdx, dom_symid[j], buf, &dom_dim, &dom_type))
                mexErrMsgIdAndTxt(ERRID"gdxSymbolInfo", "GDX error (gdxSymbolInfo)");
            mxAssert(dom_type == GMS_DT_SET, "Invalid domain data type.");
            mxAssert(dom_dim == 1, "Invalid domain dimension.");

            /* get number of records in domain and start reading */
            if (!gdxDataReadRawStart(gdx, dom_symid[j], &dom_nrecs))
                mexErrMsgIdAndTxt(ERRID"gdxDataReadRawStart", "GDX error (gdxDataReadRawStart)");
            mxAssert(dom_nrecs >= 0, "Invalid number of symbol records.");
            mx_dom_nrecs[j] = (mwSize) dom_nrecs;

            /* create storage for tracking domain uels usage */
            dom_uels_used[j] = (int*) mxCalloc(mx_dom_nrecs[j], sizeof(int));

            /* check if we have domain information already; otherwise cache map */
            if (dom_symid[j] > 0 || !dom_uel_dim_maps[dom_symid[j]])
            {
                /* create storage for domain uels map (domain into universe) */
                dom_uel_dim_maps[dom_symid[j]] = (int*) mxCalloc(uel_count+1, sizeof(int));
                for (int k = 0; k < uel_count+1; k++)
                    dom_uel_dim_maps[dom_symid[j]][k] = -1;

                /* read domain records */
                for (size_t k = 0; k < mx_dom_nrecs[j]; k++)
                {
                    if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");
                    dom_uel_dim_maps[dom_symid[j]][gdx_uel_index[0]] = (int) k;
                }
            }

            if (!gdxDataReadDone(gdx))
                mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");
        }

        /* load domains and transform to domain_label */
        if (!gdxSymbolGetDomainX(gdx, sym_id, domains_ptr))
            mexErrMsgIdAndTxt(ERRID"gdxSymbolGetDomainX", "GDX error (gdxSymbolGetDomainX)");
        for (size_t j = 0; j < dim; j++)
        {
            if (!strcmp(domains_ptr[j], "*"))
                strcpy(domains_ptr[j], "uni");
            sprintf(buf, "_%d", (int) j+1);
            strcat(domains_ptr[j], buf);
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
                for (size_t j = 0; j < GMS_VAL_MAX; j++)
                    if (values_flag[j])
                        col_nnz[j] = (mwIndex*) mxCalloc(mx_dom_nrecs[1], sizeof(mwIndex));

                if (!gdxDataReadRawStart(gdx, sym_id, &ival))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadRawStart", "GDX error (gdxDataReadRawStart)");

                /* nonzero counts depent on data, thus we need to loop through it */
                for (size_t j = 0; j < nrecs; j++)
                {
                    if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &ival))
                        mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                    /* get row and column index */
                    memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM);
                    for (size_t k = 0; k < dim; k++)
                        mx_idx[k] = GET_DOM_MAP(k, gdx_uel_index[k]);

                    /* non-zero counts for values except current one */
                    gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                        mx_dom_nrecs[1], j <= 0, j >= nrecs-1, values_flag, def_values,
                        gdx_values, col_nnz, NULL, NULL, NULL);
                }

                if (!gdxDataReadDone(gdx))
                    mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");
                break;
        }

        /* add fields to records / uels and create record data structure */
        gt_mex_readdata_addfields(type, dim, format, values_flag, domains_ptr,
            mx_arr_records, &n_dom_fields);
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
                for (size_t j = 0; j < nrecs; j++)
                {
                    /* read values */
                    if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                    /* store domain labels */
                    for (size_t k = 0; k < dim; k++)
                    {
                        idx = GET_DOM_MAP(k, gdx_uel_index[k]);
                        mx_dom_idx[k][j] = idx + 1;
                        dom_uels_used[k][idx] = true;
                    }

                    /* parse values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (values_flag[k])
                            mx_values[k][j] = gt_utils_sv_gams2matlab(gdx_values[k]);
                }
                break;

            case GT_FORMAT_DENSEMAT:
                for (size_t j = 0; j < nrecs; j++)
                {
                    /* read values */
                    if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                    /* get indices in matrix and store domain labels */
                    for (size_t k = 0; k < dim; k++)
                    {
                        idx = GET_DOM_MAP(k, gdx_uel_index[k]);
                        mx_idx[k] = idx;
                        dom_uels_used[k][idx] = true;
                    }

                    /* parse values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                    {
                        if (values_flag[k])
                        {
                            idx = (dim > 0) ? mxCalcSingleSubscript(mx_arr_values[k], dim, mx_idx) : 0;
                            mx_values[k][idx] = gt_utils_sv_gams2matlab(gdx_values[k]);
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
                    if (!gdxDataReadRaw(gdx, gdx_uel_index, gdx_values, &lastdim))
                        mexErrMsgIdAndTxt(ERRID"gdxDataReadRaw", "GDX error (gdxDataReadRaw)");

                    /* get indices in matrix (row: mx_idx[0]; col: mx_idx[1]) and store domain labels */
                    memset(mx_idx, 0, GLOBAL_MAX_INDEX_DIM * sizeof(mwIndex));
                    for (size_t k = 0; k < dim; k++)
                    {
                        idx = GET_DOM_MAP(k, gdx_uel_index[k]);
                        mx_idx[k] = idx;
                        dom_uels_used[k][idx] = true;
                    }

                    /* update non-zero counts and row indices for values in between and currrent non-zero */
                    gt_utils_count_2d_rowmajor_nnz(dim, mx_idx, mx_idx_last, mx_dom_nrecs[0],
                        mx_dom_nrecs[1], j <= 0, j >= nrecs-1, values_flag, def_values,
                        gdx_values, col_nnz, mx_cols, mx_rows, mx_flat_idx);

                    /* store values */
                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (values_flag[k] && gdx_values[k] != 0.0)
                            mx_values[k][mx_flat_idx[k]] = gt_utils_sv_gams2matlab(gdx_values[k]);
                }
                break;
        }

        if (!gdxDataReadDone(gdx))
            mexErrMsgIdAndTxt(ERRID"gdxDataReadDone", "GDX error (gdxDataReadDone)");

        /* convert set text ids to explanatory text */
        if (type == GMS_DT_SET && values_flag[GMS_VAL_LEVEL])
        {
            mxArray* mx_arr_text = mxCreateCellMatrix(nrecs, 1);

            /* get set element explanatory text */
            for (size_t j = 0; j < mxGetNumberOfElements(mx_arr_values[GMS_VAL_LEVEL]); j++)
            {
                int text_id, node;
                text_id = (int) round(mx_values[GMS_VAL_LEVEL][j]);
                if (text_id <= 0)
                    strcpy(buf, "");
                else if (!gdxGetElemText(gdx, text_id, buf, &node))
                    strcpy(buf, "");
                mxSetCell(mx_arr_text, j, mxCreateString(buf));
            }

            /* convert text into categorical */
            if (support_categorical)
                gt_mex_categorical(&mx_arr_text);

            /* replace value field by text field */
            mx_arr_values[GMS_VAL_LEVEL] = mx_arr_text;
        }

        /* collect uels (only used UELs) */
        for (size_t j = 0; j < dim; j++)
        {
            size_t num_used = 0;

            /* get number of used uels */
            for (size_t k = 0; k < mx_dom_nrecs[j]; k++)
                if (dom_uels_used[j][k] > 0)
                    dom_uels_used[j][k] = (int) num_used++;
                else
                    dom_uels_used[j][k] = -1;

            mx_arr_dom_uels[j] = mxCreateCellMatrix(num_used, 1);

            /* get used uels list */
            for (int k = 1, kk = 0; k < uel_count+1; k++)
            {
                int uel_idx = GET_DOM_MAP(j, k);
                if (uel_idx < 0)
                    continue;
                if (dom_uels_used[j][uel_idx] < 0)
                    continue;
                if (!gdxUMUelGet(gdx, k, buf, &ival))
                    mexErrMsgIdAndTxt(ERRID"gdxUMUelGet", "GDX error (gdxUMUelGet)");
                mxSetCell(mx_arr_dom_uels[j], kk++, mxCreateString(buf));
            }

            /* adapt domain indices */
            if (format == GT_FORMAT_STRUCT || format == GT_FORMAT_TABLE)
                for (size_t k = 0; k < nrecs; k++)
                    mx_dom_idx[j][k] = dom_uels_used[j][mx_dom_idx[j][k]-1] + 1;
        }

        /* set domain fields */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                if (support_categorical)
                    for (size_t j = 0; j < dim; j++)
                        gt_mex_domain2categorical(&mx_arr_dom_idx[j], mx_arr_dom_uels[j]);
                for (size_t j = 0; j < dim; j++)
                    mxSetFieldByNumber(mx_arr_records, 0, (int) j, mx_arr_dom_idx[j]);
                break;
        }

        /* set value fields */
        for (size_t j = 0, k = 0; j < GMS_VAL_MAX; j++)
            if (values_flag[j])
                mxSetFieldByNumber(mx_arr_records, 0, (int) (n_dom_fields + k++), mx_arr_values[j]);

        /* set uel fields (only needed if categorical is not used) */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                if (support_categorical)
                    break;
                mx_arr_uels = mxCreateCellMatrix(1, dim);
                for (size_t j = 0; j < dim; j++)
                    mxSetCell(mx_arr_uels, j, mx_arr_dom_uels[j]);
                mxSetProperty(mx_arr_symbol, 0, "uels_", mx_arr_uels);
                break;
        }

        /* convert struct to table */
        if (format == GT_FORMAT_TABLE)
            gt_mex_struct2table(&mx_arr_records);

        /* store records in symbol */
        mxSetProperty(mx_arr_symbol, 0, "records", mx_arr_records);
        mxSetProperty(mx_arr_symbol, 0, "number_records_", mxCreateDoubleScalar(mxGetNaN()));
        mxSetProperty(mx_arr_symbol, 0, "format_", mxCreateDoubleScalar(format));

        /* free */
        for (size_t j = 0; j < dim; j++)
            mxFree(dom_uels_used[j]);
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                mxFree(mx_arr_dom_idx);
                mxFree(mx_dom_idx);
                break;
            case GT_FORMAT_SPARSEMAT:
                for (size_t j = 0; j < dim; j++)
                    if (values_flag[j])
                        mxFree(col_nnz[j]);
                break;
        }
    }

    gdxClose(gdx);
    gdxFree(&gdx);

    for (int i = 0; i < sym_count; i++)
        if (dom_uel_dim_maps[i])
            mxFree(dom_uel_dim_maps[i]);
    mxFree(dom_uel_dim_maps);
}