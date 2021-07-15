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

#include <stdbool.h>
#include <string.h>
#include <math.h>

#define ERRID "GAMSTransfer:gt_gdx_write:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int type, subtype, format, err_count;
    size_t dim, nrecs;
    char gdx_filename[GMS_SSSIZE], buf[GMS_SSSIZE], name[GMS_SSSIZE];
    char text[GMS_SSSIZE], dominfo[10], sysdir[GMS_SSSIZE];
    double def_values[GMS_VAL_MAX];
    bool was_table, support_table, support_categorical, compress, issorted, singleton;
    bool is_valid, have_nrecs;
    char* data_name = NULL;
    gdxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr, domain_labels_ptr;
    gdxStrIndex_t domains, domain_labels;
    gdxUelIndex_t gdx_uel_index;
    gdxValues_t gdx_values;
    mwIndex idx;
    mwIndex mx_idx[GLOBAL_MAX_INDEX_DIM];
    mwIndex* mx_rows[GMS_VAL_MAX] = {NULL};
    mwIndex* mx_cols[GMS_VAL_MAX] = {NULL};
    size_t sizes[GLOBAL_MAX_INDEX_DIM];
    size_t* domain_uel_size = NULL;
    size_t* col_nnz[GMS_VAL_MAX] = {NULL};
    int** domain_uel_ids = NULL;
#ifdef WITH_R2018A_OR_NEWER
    mxInt32** mx_domains = NULL;
    mxDouble* mx_values[GMS_VAL_MAX] = {NULL};
#else
    INT32_T** mx_domains = NULL;
    double* mx_values[GMS_VAL_MAX] = {NULL};
#endif
    mxArray* mx_arr_data = NULL;
    mxArray* mx_arr_records = NULL;
    mxArray* mx_arr_text = NULL;
    mxArray* mx_arr_uels = NULL;
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};
    mxArray** mx_arr_domains = NULL;

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);
    GDXSTRINDEXPTRS_INIT(domain_labels, domain_labels_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 8, nrhs);
    gt_mex_check_argument_str(prhs, 0, sysdir);
    gt_mex_check_argument_str(prhs, 1, gdx_filename);
    gt_mex_check_argument_struct(prhs, 2);
    gt_mex_check_argument_cell(prhs, 3);
    gt_mex_check_argument_bool(prhs, 4, 1, &compress);
    gt_mex_check_argument_bool(prhs, 5, 1, &issorted);
    gt_mex_check_argument_bool(prhs, 6, 1, &support_table);
    gt_mex_check_argument_bool(prhs, 7, 1, &support_categorical);

    /* create output data */
    plhs = NULL;

    /* start GDX */
    gt_gdx_init_write(&gdx, sysdir, gdx_filename, compress);

    /* register priority UELs */
    gt_gdx_register_uels(gdx, prhs[3], NULL);

    for (int i = 0; i < mxGetNumberOfFields(prhs[2]); i++)
    {
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
        mx_arr_data = mxGetFieldByNumber(prhs[2], 0, i);
        data_name = (char*) mxGetFieldNameByNumber(prhs[2], i);

        /* get symbol type */
        if (mxIsClass(mx_arr_data, "GAMSTransfer.Alias"))
        {
            gt_mex_getfield_str(mx_arr_data, data_name, "name", "", true, name, GMS_SSSIZE);
            gt_mex_getfield_str(mx_arr_data, data_name, "aliased_with", "", true, buf, GMS_SSSIZE);
            gt_gdx_addalias(gdx, name, buf);
            continue;
        }
        else if (mxIsClass(mx_arr_data, "GAMSTransfer.Set"))
        {
            gt_mex_getfield_bool(mx_arr_data, data_name, "singleton", false, true, 1, &singleton);
            type = GMS_DT_SET;
            subtype = (singleton) ? GMS_SETTYPE_SINGLETON : GMS_SETTYPE_DEFAULT;
        }
        else if (mxIsClass(mx_arr_data, "GAMSTransfer.Parameter"))
        {
            type = GMS_DT_PAR;
            subtype = 0;
        }
        else if (mxIsClass(mx_arr_data, "GAMSTransfer.Variable"))
        {
            gt_mex_getfield_int(mx_arr_data, data_name, "type_", 0, true, GT_FILTER_NONE, 1, &subtype);
            type = GMS_DT_VAR;
        }
        else if (mxIsClass(mx_arr_data, "GAMSTransfer.Equation"))
        {
            gt_mex_getfield_int(mx_arr_data, data_name, "type_", 0, true, GT_FILTER_NONE, 1, &subtype);
            type = GMS_DT_EQU;
            subtype += GMS_EQU_USERINFO_BASE;
        }
        else
        {
            mexErrMsgIdAndTxt(ERRID"type", "Symbol '%s' has invalid type.", data_name);
            return;
        }

        for (size_t j = 0; j < GLOBAL_MAX_INDEX_DIM; j++)
            sizes[j] = 1;

        /* get fields */
        gt_mex_getfield_str(mx_arr_data, data_name, "name_", "", true, name, GMS_SSSIZE);
        gt_mex_getfield_sizet(mx_arr_data, data_name, "dimension_", 0, true, GT_FILTER_NONNEGATIVE, 1, &dim);
        gt_mex_getfield_cell_str(mx_arr_data, data_name, "domain_", "", true, dim, domains_ptr, GMS_SSSIZE);
        gt_mex_getfield_cell_str(mx_arr_data, data_name, "domain_label_", "", true, dim, domain_labels_ptr, GMS_SSSIZE);
        gt_mex_getfield_cell(mx_arr_data, data_name, "uels_c_", true, &mx_arr_uels);

        /* get optional fields */
        gt_mex_getfield_str(mx_arr_data, data_name, "description_", "", false, text, GMS_SSSIZE);
        gt_mex_getfield_str(mx_arr_data, data_name, "domain_info_", "relaxed", false, dominfo, 10);
        gt_mex_getfield_int(mx_arr_data, data_name, "format_", GT_FORMAT_UNKNOWN, false, GT_FILTER_NONE, 1, &format);
        switch (format)
        {
            case GT_FORMAT_UNKNOWN:
            case GT_FORMAT_NOT_READ:
                mexErrMsgIdAndTxt(ERRID"valid", "Symbol '%s' is marked as invalid.", data_name);
                break;
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_DENSEMAT:
            case GT_FORMAT_SPARSEMAT:
            case GT_FORMAT_TABLE:
                break;
        }

        domain_uel_size = (size_t*) mxCalloc(dim, sizeof(*domain_uel_size));
        domain_uel_ids = (int**) mxCalloc(dim, sizeof(*domain_uel_ids));
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
                gt_mex_getfield_table2struct(mx_arr_data, data_name, "records", false, &mx_arr_records, &was_table);
            else
            {
                gt_mex_getfield_struct(mx_arr_data, data_name, "records", false, &mx_arr_records);
                was_table = false;
            }
        }
        switch (format)
        {
            case GT_FORMAT_DENSEMAT:
            case GT_FORMAT_SPARSEMAT:
                gt_mex_getfield_sizet(mx_arr_data, data_name, "size_", 1, true, GT_FILTER_NONNEGATIVE, dim, sizes);
                break;
        }

        /* register uels */
        for (size_t j = 0; j < dim; j++)
        {
            mxArray* mx_field = mxGetCell(mx_arr_uels, j);
            domain_uel_size[j] = mxGetNumberOfElements(mx_field);

            domain_uel_ids[j] = (int*) mxCalloc(domain_uel_size[j], sizeof(int));

            gt_gdx_register_uels(gdx, mx_field, domain_uel_ids[j]);
        }

        if (issorted)
        {
            if (!gdxDataWriteRawStart(gdx, name, text, (int) dim, type, subtype))
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteRawStart", "GDX error (gdxDataWriteRawStart)");
        }
        else
        {
            if (!gdxDataWriteMapStart(gdx, name, text, (int) dim, type, subtype))
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteMapStart", "GDX error (gdxDataWriteMapStart)");
        }

        /* write domain information */
        if (dim > 0)
            gt_gdx_setdomain(gdx, dominfo, i+1, (const char**) domains_ptr);

        /* only go on to writing records if records are available */
        if (!mx_arr_records || format == GT_FORMAT_UNKNOWN || format == GT_FORMAT_EMPTY ||
            format == GT_FORMAT_NOT_READ)
        {
            if (!gdxDataWriteDone(gdx))
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone)");
            mxFree(mx_arr_domains);
            mxFree(mx_domains);
            for (size_t j = 0; j < dim; j++)
                mxFree(domain_uel_ids[j]);
            mxFree(domain_uel_size);
            mxFree(domain_uel_ids);
            continue;
        }

        /* get domain and value fields of record field */
        gt_mex_get_records(data_name, dim, support_categorical, mx_arr_records,
            mx_arr_values, mx_values, mx_arr_domains, mx_domains, &mx_arr_text,
            (const char**) domain_labels_ptr);
        gt_utils_type_default_values(type, subtype, false, def_values);

        /* register set explanatory texts */
        if (type == GMS_DT_SET && mx_arr_text)
        {
            mxAssert(format == GT_FORMAT_TABLE || format == GT_FORMAT_STRUCT,
                "Invalid format for symbol type 'set'");
            if (mxGetNumberOfElements(mx_arr_text) > 0 && mx_values[GMS_VAL_LEVEL])
                gt_gdx_addsettext(gdx, mx_arr_text, mx_values[GMS_VAL_LEVEL]);
        }

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
            if (!gdxDataWriteDone(gdx))
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone)");
            mxFree(mx_arr_domains);
            mxFree(mx_domains);
            for (size_t j = 0; j < dim; j++)
                mxFree(domain_uel_ids[j]);
            mxFree(domain_uel_size);
            mxFree(domain_uel_ids);
            continue;
        }

        /* write values */
        switch (format)
        {
            case GT_FORMAT_STRUCT:
            case GT_FORMAT_TABLE:
                mxAssert(have_nrecs, "Number of records not available");

                for (size_t j = 0; j < nrecs; j++)
                {
                    for (size_t k = 0; k < dim; k++)
                    {
                        size_t rel_idx = mx_domains[k][j];
                        if (rel_idx <= 0)
                            mexErrMsgIdAndTxt(ERRID"gdxDataWrite", "Symbol '%s' has "
                                "invalid domain index: %d. Missing UEL?", name, rel_idx);
                        if (rel_idx > domain_uel_size[k])
                            mexErrMsgIdAndTxt(ERRID"gdxDataWrite", "Symbol '%s' has "
                                "unregistered UEL.", name);
                        gdx_uel_index[k] = domain_uel_ids[k][rel_idx-1];
                    }

                    for (size_t k = 0; k < GMS_VAL_MAX; k++)
                        if (mx_arr_values[k])
                            gdx_values[k] = gt_utils_sv_matlab2gams(mx_values[k][j]);
                        else
                            gdx_values[k] = def_values[k];

                    if (issorted)
                    {
                        if (!gdxDataWriteRaw(gdx, gdx_uel_index, gdx_values))
                            gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                    }
                    else
                    {
                        if (!gdxDataWriteMap(gdx, gdx_uel_index, gdx_values))
                            gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                    }
                }
                break;

            case GT_FORMAT_DENSEMAT:
                mxAssert(have_nrecs, "Number of records not available");

                for (size_t j = 0; j < nrecs; j++)
                {
                    bool empty_rec = true, found_index;

                    /* calculate row-major index */
                    idx = 0;
                    found_index = (dim == 0);
                    for (size_t k1 = dim, d = 1, k; k1 > 0; k1--)
                    {
                        k = k1 - 1;
                        mx_idx[k] = ((int) floor((double) j / (double) d)) % sizes[k];
                        if (mx_idx[k] >= domain_uel_size[k])
                            mexErrMsgIdAndTxt(ERRID"gdxDataWriteMap", "GDX error: Domain UEL not registered.");
                        else
                            gdx_uel_index[k] = domain_uel_ids[k][mx_idx[k]];
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
                            gdx_values[k] = gt_utils_sv_matlab2gams(mx_values[k][idx]);
                        else
                            gdx_values[k] = def_values[k];
                        empty_rec = (gdx_values[k] != 0) ? false : empty_rec;
                    }
                    if (empty_rec)
                        continue;
                    if (issorted)
                    {
                        if (!gdxDataWriteRaw(gdx, gdx_uel_index, gdx_values))
                            gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                    }
                    else
                    {
                        if (!gdxDataWriteMap(gdx, gdx_uel_index, gdx_values))
                            gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                    }
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

                for (size_t j = 0; j < sizes[0]; j++)
                {
                    for (size_t k = 0; k < sizes[1]; k++)
                    {
                        /* set domains */
                        if (dim >= 1)
                            gdx_uel_index[0] = domain_uel_ids[0][j];
                        if (dim >= 2)
                            gdx_uel_index[1] = domain_uel_ids[1][k];

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
                            gdx_values[kk] = gt_utils_sv_matlab2gams(mx_values[kk][idx]);
                        }

                        /* write values */
                        if (issorted)
                        {
                            if (!gdxDataWriteRaw(gdx, gdx_uel_index, gdx_values))
                                gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                        }
                        else
                        {
                            if (!gdxDataWriteMap(gdx, gdx_uel_index, gdx_values))
                                gt_gdx_write_record_error(gdx, name, dim, gdx_uel_index);
                        }
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

        if (!gdxDataWriteDone(gdx))
            mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone)");

        /* check GDX errors */
        if (gdxDataErrorCount(gdx))
        {
            gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
            mexErrMsgIdAndTxt(ERRID"gdxError", "GDX error for %s: %s", name, buf);
        }

        mxFree(mx_arr_domains);
        mxFree(mx_domains);
        for (size_t j = 0; j < dim; j++)
            mxFree(domain_uel_ids[j]);
        mxFree(domain_uel_size);
        mxFree(domain_uel_ids);
    }

    if (compress)
        gdxAutoConvert(gdx, 0);

    /* close gdx */
    gdxClose(gdx);
    gdxFree(&gdx);
}
