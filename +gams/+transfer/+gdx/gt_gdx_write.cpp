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

#ifdef HAS_GDX_SOURCE
#define NO_SET_LOAD_PATH_DEF
#include "gdxcwrap.hpp"
#else
#include "gdxcc.h"
#endif
#include "mex.h"
#include "gt_utils.h"
#include "gt_mex.h"
#include "gt_gdx_idx.h"

#include <stdbool.h>
#include <string.h>
#include <math.h>

#define ERRID "gams:transfer:cmex:gt_gdx_write:"

void mexFunction(
    int             nlhs,
    mxArray*        plhs[],
    int             nrhs,
    const mxArray*  prhs[]
)
{
    int type, subtype, format, sym_nr;
    size_t dim, nrecs;
    char gdx_filename[GMS_SSSIZE], buf[GMS_SSSIZE], name[GMS_SSSIZE];
    char text[GMS_SSSIZE], dominfo[10];
    double def_values[GMS_VAL_MAX];
    bool was_table, support_table, support_categorical, compress, issorted, singleton, eps_to_zero;
    bool have_nrecs, can_skip_default_recs;
    char* data_name = NULL;
    gdxHandle_t gdx = NULL;
    gdxStrIndexPtrs_t domains_ptr;
    gdxStrIndex_t domains;
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
    mxLogical* mx_enable = NULL;
    mxArray* mx_arr_symbol = NULL;
    mxArray* mx_arr_symbol_def = NULL;
    mxArray* mx_arr_symbol_data = NULL;
    mxArray* mx_arr_records = NULL;
    mxArray* mx_arr_text = NULL;
    mxArray* mx_arr_uels = NULL;
    mxArray* mx_arr_values[GMS_VAL_MAX] = {NULL};
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[2] = {NULL};
    mxArray** mx_arr_domains = NULL;

    GDXSTRINDEXPTRS_INIT(domains, domains_ptr);

    /* check input / outputs */
    gt_mex_check_arguments_num(0, nlhs, 9, nrhs);
    gt_mex_check_argument_str(prhs, 0, gdx_filename);
    gt_mex_check_argument_struct(prhs, 1);
    gt_mex_check_argument_cell(prhs, 3);
    gt_mex_check_argument_bool(prhs, 4, 1, &compress);
    gt_mex_check_argument_bool(prhs, 5, 1, &issorted);
    gt_mex_check_argument_bool(prhs, 6, 1, &eps_to_zero);
    gt_mex_check_argument_bool(prhs, 7, 1, &support_table);
    gt_mex_check_argument_bool(prhs, 8, 1, &support_categorical);

    /* create output data */
    plhs = NULL;

    /* start GDX */
    gt_gdx_init_write(&gdx, gdx_filename, compress);

    /* register priority UELs */
    gt_gdx_register_uels(gdx, (mxArray*) prhs[3], NULL);


#ifdef WITH_R2018A_OR_NEWER
    mx_enable = mxGetLogicals(prhs[2]);
#else
    mx_enable = (mxLogical*) mxGetData(prhs[2]);
#endif
    sym_nr = 0;
    for (int i = 0; i < mxGetNumberOfFields(prhs[1]); i++)
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

        sym_nr++;

        /* get data field */
        mx_arr_symbol = mxGetFieldByNumber(prhs[1], 0, i);
        data_name = (char*) mxGetFieldNameByNumber(prhs[1], i);

        /* get symbol type */
        if (mxIsClass(mx_arr_symbol, "gams.transfer.alias.Set"))
        {
            gt_mex_getfield_str(mx_arr_symbol, data_name, "name_", "", true, name, GMS_SSSIZE);
            gt_mex_getfield_str(mx_arr_symbol, data_name, "alias_with_", "", true, buf, GMS_SSSIZE);
            gt_gdx_addalias(gdx, name, buf);
            continue;
        }
        else if (mxIsClass(mx_arr_symbol, "gams.transfer.alias.Universe"))
        {
            gt_mex_getfield_str(mx_arr_symbol, data_name, "name_", "", true, name, GMS_SSSIZE);
            gt_gdx_addalias(gdx, name, "*");
            continue;
        }

        mx_arr_symbol_def = mxGetProperty(mx_arr_symbol, 0, "def_");
        mx_arr_symbol_data = mxGetProperty(mx_arr_symbol, 0, "data_");
        if (mxIsClass(mx_arr_symbol, "gams.transfer.symbol.Set"))
        {
            gt_mex_getfield_bool(mx_arr_symbol_def, data_name, "is_singleton_", false, true, 1, &singleton);
            type = GMS_DT_SET;
            subtype = (singleton) ? GMS_SETTYPE_SINGLETON : GMS_SETTYPE_DEFAULT;
        }
        else if (mxIsClass(mx_arr_symbol, "gams.transfer.symbol.Parameter"))
        {
            type = GMS_DT_PAR;
            subtype = 0;
        }
        else if (mxIsClass(mx_arr_symbol, "gams.transfer.symbol.Variable"))
        {
            gt_mex_getfield_int(mxGetProperty(mx_arr_symbol_def, 0, "type_"), data_name, "value_", 0, true, GT_FILTER_NONE, 1, &subtype);
            type = GMS_DT_VAR;
        }
        else if (mxIsClass(mx_arr_symbol, "gams.transfer.symbol.Equation"))
        {
            gt_mex_getfield_int(mxGetProperty(mx_arr_symbol_def, 0, "type_"), data_name, "value_", 0, true, GT_FILTER_NONE, 1, &subtype);
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

        /* get domain */
        {
            bool is_none, is_regular;
            mxArray* mx_arr_symbol_domains = mxGetProperty(mx_arr_symbol_def, 0, "domains_");
            dim = mxGetNumberOfElements(mx_arr_symbol_domains);
            is_none = true;
            is_regular = dim > 0;
            for (size_t j = 0; j < dim; j++)
            {
                mxArray* mx_arr_domain = mxGetCell(mx_arr_symbol_domains, j);
                if (mxIsClass(mx_arr_domain, "gams.transfer.symbol.domain.Regular"))
                {
                    mxGetString(mxGetProperty(mxGetProperty(mx_arr_domain, 0, "symbol_"), 0, "name_"), domains_ptr[j], GMS_SSSIZE);
                    is_none = false;
                }
                else if (mxIsClass(mx_arr_domain, "gams.transfer.symbol.domain.Relaxed"))
                {
                    mxGetString(mxGetProperty(mx_arr_domain, 0, "name_"), domains_ptr[j], GMS_SSSIZE);
                    if (strcmp(domains_ptr[j], "*"))
                    {
                        is_none = false;
                        is_regular = false;
                    }
                }
                else
                    mexErrMsgIdAndTxt(ERRID"domain", "Symbol '%s' has unknown domain type.", data_name);
            }
            if (is_none)
                strcpy(dominfo, "none");
            else if (is_regular)
                strcpy(dominfo, "regular");
            else
                strcpy(dominfo, "relaxed");
        }

        /* get UELs */
        mx_arr_uels = mxCreateCellMatrix(1, dim);
        for (size_t j = 0; j < dim; j++)
        {
            call_prhs[0] = mx_arr_symbol;
            call_prhs[1] = mxCreateDoubleScalar(j+1);
            if (mexCallMATLAB(1, call_plhs, 2, call_prhs, "getAxisLabels"))
                mexErrMsgIdAndTxt(ERRID"number_records", "Calling 'getAxisLabels' failed.");
            mxSetCell(mx_arr_uels, j, call_plhs[0]);
            sizes[j] = mxGetNumberOfElements(call_plhs[0]);
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
                gt_mex_getfield_table2struct(mx_arr_symbol_data, data_name, "records_", false, &mx_arr_records, &was_table);
            else
            {
                gt_mex_getfield_struct(mx_arr_symbol_data, data_name, "records_", false, &mx_arr_records);
                was_table = false;
            }
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
            {
                gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteRawStart", "GDX error (gdxDataWriteRawStart): %s", buf);
            }
        }
        else
        {
            if (!gdxDataWriteMapStart(gdx, name, text, (int) dim, type, subtype))
            {
                gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteMapStart", "GDX error (gdxDataWriteMapStart): %s", buf);
            }
        }

        /* write domain information */
        if (dim > 0)
            gt_gdx_setdomain(gdx, dominfo, sym_nr, (const char**) domains_ptr);

        /* only go on to writing records if records are available */
        if (!mx_arr_records || format == GT_FORMAT_UNKNOWN || format == GT_FORMAT_EMPTY ||
            format == GT_FORMAT_NOT_READ)
        {
            if (!gdxDataWriteDone(gdx))
            {
                gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone): %s", buf);
            }
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
            mx_arr_values, mx_values, mx_arr_domains, mx_domains, &mx_arr_text);
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
                have_nrecs = true; // number of records: 0
                break;
        }
        if (have_nrecs && nrecs == 0)
        {
            if (!gdxDataWriteDone(gdx))
            {
                gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
                mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone): %s", buf);
            }
            mxFree(mx_arr_domains);
            mxFree(mx_domains);
            for (size_t j = 0; j < dim; j++)
                mxFree(domain_uel_ids[j]);
            mxFree(domain_uel_size);
            mxFree(domain_uel_ids);
            continue;
        }

        /* check if default records can be skipped */
        can_skip_default_recs = !strcmp(dominfo, "regular") && type != GMS_DT_SET;

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
                    {
                        if (mx_arr_values[k])
                            gdx_values[k] = gt_utils_sv_matlab2gams(mx_values[k][j], eps_to_zero);
                        else
                            gdx_values[k] = def_values[k];
                    }

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
                    bool is_default_rec = true, found_index;

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
                            gdx_values[k] = gt_utils_sv_matlab2gams(mx_values[k][idx], eps_to_zero);
                        else
                            gdx_values[k] = def_values[k];
                        is_default_rec = (gdx_values[k] != def_values[k]) ? false : is_default_rec;
                    }
                    if (can_skip_default_recs && is_default_rec)
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
                        bool is_default_rec = true;

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
                                gdx_values[kk] = 0;
                            else
                            {
                                col_nnz[kk][k]++;
                                gdx_values[kk] = gt_utils_sv_matlab2gams(mx_values[kk][idx], eps_to_zero);
                            }
                            is_default_rec = (gdx_values[kk] != def_values[kk]) ? false : is_default_rec;
                        }
                        if (can_skip_default_recs && is_default_rec)
                            continue;

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
        {
            gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
            mexErrMsgIdAndTxt(ERRID"gdxDataWriteDone", "GDX error (gdxDataWriteDone): %s", buf);
        }

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

    gdxClose(gdx);
    gdxFree(&gdx);
}
