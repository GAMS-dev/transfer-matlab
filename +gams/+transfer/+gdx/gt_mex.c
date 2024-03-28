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

#include "gt_mex.h"
#include "gclgms.h"

#include <math.h>
#include <string.h>
#include <stdio.h>

#define ERRID "gams:transfer:cmex:gt_mex:"

void gt_mex_check_arguments_num(
    int             n_out_required,/** number of required output arguments */
    int             n_out_given,   /** number of given output arguments */
    int             n_in_required, /** number of required input arguments */
    int             n_in_given     /** number of given input arguments */
)
{
    if (n_out_required != n_out_given)
        mexErrMsgIdAndTxt(ERRID"check_arguments", "Incorrect number of outputs (%d). %d required.", n_out_given, n_out_required);
    if (n_in_required != n_in_given)
        mexErrMsgIdAndTxt(ERRID"check_arguments", "Incorrect number of inputs (%d). %d required.", n_in_given, n_in_required);
}

void gt_mex_check_argument_str(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    char*           value           /** values */
)
{
    if (!mxIsChar(mx_arr_values[arg_position]))
        mexErrMsgIdAndTxt(ERRID"check_argument_str", "Argument #%d must be of type char.", arg_position);

    mxGetString(mx_arr_values[arg_position], value, 1 + mxGetNumberOfElements(mx_arr_values[arg_position]));
}

void gt_mex_check_argument_int(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    GT_FILTER       filter,         /** filter to be checked for (e.g. GT_FILTER_NONNEGATIVE) */
    size_t          dim,            /** dimension of values array */
    int*            values          /** values */
)
{
#ifdef WITH_R2018A_OR_NEWER
    mxInt32* mx_values;
#else
    INT32_T* mx_values;
#endif

    if (mxGetNumberOfElements(mx_arr_values[arg_position]) != dim)
        mexErrMsgIdAndTxt(ERRID"check_argument_int", "Argument #%d has invalid number of elements: %d", arg_position, dim);

    if (!mxIsInt32(mx_arr_values[arg_position]))
        mexErrMsgIdAndTxt(ERRID"check_argument_int", "Argument #%d has invalid type: need int32", arg_position);

#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetInt32s(mx_arr_values[arg_position]);
#else
    mx_values = (INT32_T*) mxGetData(mx_arr_values[arg_position]);
#endif

    for (size_t i = 0; i < dim; i++)
    {
        values[i] = mx_values[i];

        switch (filter)
        {
            case GT_FILTER_NONE:
                break;

            case GT_FILTER_NONNEGATIVE:
                if (values[i] < 0)
                    mexErrMsgIdAndTxt(ERRID"check_argument_int", "Argument #%d must be non-negative.", arg_position);
                break;

            case GT_FILTER_BOOL:
                if (values[i] != 0 && values[i] != 1)
                    mexErrMsgIdAndTxt(ERRID"check_argument_int", "Argument #%d must be in {0,1}.", arg_position);
                break;

            default:
                mexErrMsgIdAndTxt(ERRID"check_argument_int", "Invalid filter.");
                break;
        }
    }
}

void gt_mex_check_argument_bool(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    size_t          dim,            /** dimension of values array */
    bool*           values          /** values */
)
{
    mxLogical* mx_values;

    if (mxGetNumberOfElements(mx_arr_values[arg_position]) != dim)
        mexErrMsgIdAndTxt(ERRID"check_argument_bool", "Argument #%d has invalid number of elements: %d", arg_position, dim);

    if (!mxIsLogical(mx_arr_values[arg_position]))
        mexErrMsgIdAndTxt(ERRID"check_argument_bool", "Argument #%d has invalid type: need logical", arg_position);

#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetLogicals(mx_arr_values[arg_position]);
#else
    mx_values = (mxLogical*) mxGetData(mx_arr_values[arg_position]);
#endif

    for (size_t i = 0; i < dim; i++)
        values[i] = mx_values[i];
}

void gt_mex_check_argument_struct(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
)
{
    if (!mxIsStruct(mx_arr_values[arg_position]))
        mexErrMsgIdAndTxt(ERRID"gt_mex_check_argument_struct", "Argument #%d must be of type struct.", arg_position);
}

void gt_mex_check_argument_cell(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
)
{
    if (!mxIsCell(mx_arr_values[arg_position]))
        mexErrMsgIdAndTxt(ERRID"gt_mex_check_argument_cell", "Argument #%d must be of type cell.", arg_position);
}

void gt_mex_check_argument_symbol_obj(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
)
{
    if (!mxIsClass(mx_arr_values[arg_position], "gams.transfer.symbol.Set") &&
        !mxIsClass(mx_arr_values[arg_position], "gams.transfer.alias.Set") &&
        !mxIsClass(mx_arr_values[arg_position], "gams.transfer.symbol.Parameter") &&
        !mxIsClass(mx_arr_values[arg_position], "gams.transfer.symbol.Variable") &&
        !mxIsClass(mx_arr_values[arg_position], "gams.transfer.symbol.Equation"))
        mexErrMsgIdAndTxt(ERRID"gt_mex_check_argument_symbol_obj",
            "Argument #%d must be of type Set, Alias, Parameter, Variable or Equation.", arg_position);
}

void gt_mex_addsymbol(
    mxArray*        mx_struct,      /** Matlab struct to add symbol to */
    const char*     name,           /** name of symbol */
    const char*     descr,          /** description of symbol */
    int             type,           /** GAMS type of symbol */
    int             subtype,        /** GAMS subtype of symbol */
    int             format,         /** record format */
    size_t          dim,            /** dimension of symbol */
    double*         sizes,          /** sizes of domains (length = dim) */
    const char**    domains,        /** domains of symbol (length = dim) */
    const char**    domain_labels,  /** domain labels of symbol (length = dim) */
    int             domain_type,    /** domain type (e.g. 3: regular or 2: relaxed) */
    size_t          nrecs,          /** number of records */
    size_t          nvals,          /** number of values */
    mxArray*        mx_arr_records, /** records structure */
    mxArray*        mx_arr_uels     /** list of uels to be stored */
)
{
    size_t card, n_val_fields;
    double sparsity;
    mxArray* mx_arr_sym_struct = NULL;

    /* adapt subtype */
    if (type == GMS_DT_EQU)
        subtype -= GMS_EQU_USERINFO_BASE;

    /* create symbol structure */
    mx_arr_sym_struct = mxCreateStructMatrix(1, 1, 0, NULL);

    /* add structrure fields */
    gt_mex_addfield_str(mx_arr_sym_struct, "name", name);
    gt_mex_addfield_str(mx_arr_sym_struct, "description", descr);
    gt_mex_addfield_int(mx_arr_sym_struct, "symbol_type", 1, &type);
    switch (type)
    {
        case GMS_DT_ALIAS:
            gt_mex_addfield_str(mx_arr_sym_struct, "alias_with", descr + 13);
            mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, name), mx_arr_sym_struct);
            return;
        case GMS_DT_PAR:
            n_val_fields = 1;
            break;
        case GMS_DT_SET:
        {
            bool is_singleton = subtype == 1;
            n_val_fields = 0;
            gt_mex_addfield_bool(mx_arr_sym_struct, "is_singleton", 1, &is_singleton);
            break;
        }
        case GMS_DT_VAR:
        case GMS_DT_EQU:
            n_val_fields = 5;
            gt_mex_addfield_int(mx_arr_sym_struct, "type", 1, &subtype);
            break;
        default:
            n_val_fields = 0;
    }
    gt_mex_addfield_sizet(mx_arr_sym_struct, "dimension", 1, &dim);
    if (sizes)
        gt_mex_addfield_dbl(mx_arr_sym_struct, "size", dim, sizes);
    else
        gt_mex_addfield_dbl(mx_arr_sym_struct, "size", dim, NULL);
    gt_mex_addfield_cell_str(mx_arr_sym_struct, "domain", dim, domains);
    switch (format)
    {
        case GT_FORMAT_TABLE:
        case GT_FORMAT_STRUCT:
            gt_mex_addfield_cell_str(mx_arr_sym_struct, "domain_labels", dim, domain_labels);
            break;
        default:
            gt_mex_addfield_cell_str(mx_arr_sym_struct, "domain_labels", 0, NULL);
            break;
    }
    gt_mex_addfield_int(mx_arr_sym_struct, "domain_type", 1, &domain_type);
    if (mx_arr_records)
        mxSetFieldByNumber(mx_arr_sym_struct, 0, mxAddField(mx_arr_sym_struct, "records"), mx_arr_records);
    else
        mxAddField(mx_arr_sym_struct, "records");
    gt_mex_addfield_int(mx_arr_sym_struct, "format", 1, &format);
    gt_mex_addfield_sizet(mx_arr_sym_struct, "number_records", 1, &nrecs);
    if (n_val_fields == 0)
        nvals = 0;
    gt_mex_addfield_sizet(mx_arr_sym_struct, "number_values", 1, &nvals);
    card = 1;
    if (sizes)
        for (size_t i = 0; i < dim; i++)
            card *= (size_t) sizes[i];
    card *= n_val_fields;
    sparsity = (card > 0) ? 1.0 - (double) nvals / card : mxGetNaN();
    gt_mex_addfield_dbl(mx_arr_sym_struct, "sparsity", 1, &sparsity);
    if (mx_arr_uels)
        mxSetFieldByNumber(mx_arr_sym_struct, 0, mxAddField(mx_arr_sym_struct, "uels"), mx_arr_uels);

    /* add symbol structure to data structure */
    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, name), mx_arr_sym_struct);
}

void gt_mex_addfield_str(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    const char*     value           /** value of field */
)
{
    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mxCreateString(value));
}

void gt_mex_addfield_cell_str(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of string array */
    const char**    values          /** value of field */
)
{
    mxArray* mx_arr_values;

    mx_arr_values = mxCreateCellMatrix(1, dim);
    for (size_t i = 0; i < dim; i++)
        mxSetCell(mx_arr_values, i, mxCreateString(values[i]));

    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mx_arr_values);
}

void gt_mex_addfield_int(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    int*            values          /** values of field */
)
{
    mxArray* mx_arr_values;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_values;
#else
    double* mx_values;
#endif

    mx_arr_values = mxCreateNumericMatrix(1, dim, mxDOUBLE_CLASS, mxREAL);
#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetDoubles(mx_arr_values);
#else
    mx_values = mxGetPr(mx_arr_values);
#endif
    if (values)
        for (size_t i = 0; i < dim; i++)
            mx_values[i] = values[i];

    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mx_arr_values);
}

void gt_mex_addfield_sizet(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    size_t*         values          /** values of field */
)
{
    mxArray* mx_arr_values;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_values;
#else
    double* mx_values;
#endif

    mx_arr_values = mxCreateNumericMatrix(1, dim, mxDOUBLE_CLASS, mxREAL);
#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetDoubles(mx_arr_values);
#else
    mx_values = mxGetPr(mx_arr_values);
#endif
    if (values)
        for (size_t i = 0; i < dim; i++)
            mx_values[i] = (double) values[i];

    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mx_arr_values);
}

void gt_mex_addfield_bool(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    bool*           values          /** values of field */
)
{
    mxArray* mx_arr_values;
    mxLogical* mx_values;

    mx_arr_values = mxCreateLogicalMatrix(1, dim);
#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetLogicals(mx_arr_values);
#else
    mx_values = (mxLogical*) mxGetData(mx_arr_values);
#endif
    if (values)
        for (size_t i = 0; i < dim; i++)
            mx_values[i] = values[i];

    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mx_arr_values);
}

void gt_mex_addfield_dbl(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    double*         values          /** values of field */
)
{
    mxArray* mx_arr_values;
#ifdef WITH_R2018A_OR_NEWER
    mxDouble* mx_values;
#else
    double* mx_values;
#endif

    mx_arr_values = mxCreateNumericMatrix(1, dim, mxDOUBLE_CLASS, mxREAL);
#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetDoubles(mx_arr_values);
#else
    mx_values = mxGetPr(mx_arr_values);
#endif
    if (values)
        for (size_t i = 0; i < dim; i++)
            mx_values[i] = values[i];

    mxSetFieldByNumber(mx_struct, 0, mxAddField(mx_struct, fieldname), mx_arr_values);
}

void gt_mex_getfield_str(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    const char*     defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    char*           value,          /** value of field */
    size_t          strsize         /** size of value string */
)
{
    mxArray* mx_field = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_str", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        strncpy(value, defvalue, strsize);
        return;
    }

    /* check field */
    if (mxIsClass(mx_field, "gams.transfer.symbol.Set") || mxIsClass(mx_field, "gams.transfer.alias.Set") ||
        mxIsClass(mx_field, "gams.transfer.symbol.Parameter") || mxIsClass(mx_field, "gams.transfer.symbol.Variable") ||
        mxIsClass(mx_field, "gams.transfer.symbol.Equation") || mxIsClass(mx_field, "gams.transfer.alias.Universe"))
        mxGetString(mxGetProperty(mx_field, 0, "name_"), value, strsize);
    else if (mxIsChar(mx_field))
        mxGetString(mx_field, value, strsize);
    else
        mexErrMsgIdAndTxt(ERRID"getfield_cell_str", "Structure '%s' has invalid field '%s': not cell of strings", structname, fieldname);
}

void gt_mex_getfield_cell_str(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    const char*     defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** length of 1dim cell array */
    char*           value[],        /** value of field */
    size_t          strsize         /** size of value string */
)
{
    mxArray* mx_field = NULL;
    mxArray* mx_entry = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_cell_str", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        for (size_t i = 0; i < dim; i++)
            strncpy(value[i], defvalue, strsize);
        return;
    }

    /* check field */
    if (!mxIsCell(mx_field))
        mexErrMsgIdAndTxt(ERRID"getfield_cell_str", "Structure '%s' has invalid field '%s': not cell", structname, fieldname);
    for (size_t i = 0; i < dim; i++)
    {
        mx_entry = mxGetCell(mx_field, i);
        if (mxIsClass(mx_entry, "gams.transfer.symbol.Set") || mxIsClass(mx_entry, "gams.transfer.alias.Set") ||
            mxIsClass(mx_entry, "gams.transfer.symbol.Parameter") || mxIsClass(mx_entry, "gams.transfer.symbol.Variable") ||
            mxIsClass(mx_entry, "gams.transfer.symbol.Equation") || mxIsClass(mx_entry, "gams.transfer.alias.Universe"))
            mxGetString(mxGetProperty(mx_entry, 0, "name_"), value[i], strsize);
        else if (mxIsChar(mx_entry))
            mxGetString(mx_entry, value[i], strsize);
        else
            mexErrMsgIdAndTxt(ERRID"getfield_cell_str", "Structure '%s' has invalid field '%s': not cell of strings", structname, fieldname);
    }
}

void gt_mex_getfield_int(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    int             defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    GT_FILTER       filter,         /** set a predefined filter, e.g. GT_FILTER_NONNEGATIVE */
    size_t          dim,            /** size of value array */
    int*            values          /** values of field */
)
{
    mxArray* mx_field = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        for (size_t i = 0; i < dim; i++)
            values[i] = defvalue;
        return;
    }

    /* check field */
    if (!mxIsNumeric(mx_field))
        mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': not numeric", structname, fieldname);
    if (mxGetNumberOfElements(mx_field) != dim)
        mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': invalid shape", structname, fieldname);
    if (mxIsInt32(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxInt32* mx_values = mxGetInt32s(mx_field);
#else
        INT32_T* mx_values = (INT32_T*) mxGetData(mx_field);
#endif
        for (size_t i = 0; i < dim; i ++)
            values[i] = mx_values[i];
    }
    else if (mxIsUint8(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxUint8* mx_values = mxGetUint8s(mx_field);
#else
        UINT8_T* mx_values = (UINT8_T*) mxGetData(mx_field);
#endif
        for (size_t i = 0; i < dim; i ++)
            values[i] = mx_values[i];
    }
    else if (mxIsDouble(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxDouble* mx_values = mxGetDoubles(mx_field);
#else
        double* mx_values = mxGetPr(mx_field);
#endif
        for (size_t i = 0; i < dim; i++)
        {
            if (round(mx_values[i]) != mx_values[i])
                mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': not integer: %g", structname, fieldname, mx_values[i]);
            values[i] = (int) round(mx_values[i]);
        }
    }
    else
        mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': invalid type", structname, fieldname);

    /* check field (filter) */
    for (size_t i = 0; i < dim; i++)
    {
        switch (filter)
        {
            case GT_FILTER_NONE:
                break;
            case GT_FILTER_NONNEGATIVE:
                if (values[i] < 0)
                    mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': not non-negative: %d", structname, fieldname, values[i]);
                break;
            case GT_FILTER_BOOL:
                if (values[i] != 0 && values[i] != 1)
                    mexErrMsgIdAndTxt(ERRID"getfield_int", "Structure '%s' has invalid field '%s': not boolean: %d", structname, fieldname, values[i]);
                break;
        }
    }
}

void gt_mex_getfield_dbl(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    double          defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** size of value array */
    double*         values          /** values of field */
)
{
        mxArray* mx_field = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_dbl", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        for (size_t i = 0; i < dim; i++)
            values[i] = defvalue;
        return;
    }

    /* check field */
    if (!mxIsNumeric(mx_field))
        mexErrMsgIdAndTxt(ERRID"getfield_dbl", "Structure '%s' has invalid field '%s': not numeric", structname, fieldname);
    if (mxGetNumberOfElements(mx_field) != dim)
        mexErrMsgIdAndTxt(ERRID"getfield_dbl", "Structure '%s' has invalid field '%s': invalid shape", structname, fieldname);
    if (mxIsDouble(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxDouble* mx_values = mxGetDoubles(mx_field);
#else
        double* mx_values = mxGetPr(mx_field);
#endif
        for (size_t i = 0; i < dim; i++)
            values[i] = mx_values[i];
    }
    else
        mexErrMsgIdAndTxt(ERRID"getfield_dbl", "Structure '%s' has invalid field '%s': invalid type", structname, fieldname);
}

void gt_mex_getfield_sizet(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    size_t          defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    GT_FILTER       filter,         /** set a predefined filter, e.g. GT_FILTER_NONNEGATIVE */
    size_t          dim,            /** size of value array */
    size_t*         values          /** values of field */
)
{
    mxArray* mx_field = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        for (size_t i = 0; i < dim; i++)
            values[i] = defvalue;
        return;
    }

    /* check field */
    if (!mxIsNumeric(mx_field))
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': not numeric", structname, fieldname);
    if (mxGetNumberOfElements(mx_field) != dim)
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': invalid shape", structname, fieldname);
    if (mxIsUint64(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxUint64* mx_values = mxGetUint64s(mx_field);
#else
        UINT64_T* mx_values = (UINT64_T*) mxGetData(mx_field);
#endif
        for (size_t i = 0; i < dim; i ++)
            values[i] = mx_values[i];
    }
    else if (mxIsDouble(mx_field))
    {
#ifdef WITH_R2018A_OR_NEWER
        mxDouble* mx_values = mxGetDoubles(mx_field);
#else
        double* mx_values = mxGetPr(mx_field);
#endif
        for (size_t i = 0; i < dim; i++)
        {
            if (round(mx_values[i]) != mx_values[i])
                mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': not integer: %g", structname, fieldname, mx_values[i]);
            values[i] = (int) round(mx_values[i]);
        }
    }
    else
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': invalid type", structname, fieldname);

    /* check field (filter) */
    for (size_t i = 0; i < dim; i++)
    {
        switch (filter)
        {
            case GT_FILTER_NONE:
            case GT_FILTER_NONNEGATIVE:
                break;
            case GT_FILTER_BOOL:
                if (values[i] != 0 && values[i] != 1)
                    mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': not boolean: %d", structname, fieldname, values[i]);
                break;
        }
    }
}

void gt_mex_getfield_bool(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** size of value array */
    bool*           values          /** values of field */
)
{
    mxArray* mx_field = NULL;
    mxLogical* mx_values = NULL;

    /* get field */
    if (mxIsStruct(mx_struct))
        mx_field = mxGetField(mx_struct, 0, fieldname);
    else
        mx_field = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !mx_field)
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!mx_field)
    {
        for (size_t i = 0; i < dim; i++)
            values[i] = defvalue;
        return;
    }

    /* check field */
    if (!mxIsLogical(mx_field))
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': not logical", structname, fieldname);
    if (mxGetNumberOfElements(mx_field) != dim)
        mexErrMsgIdAndTxt(ERRID"getfield_intvec", "Structure '%s' has invalid field '%s': invalid shape", structname, fieldname);
#ifdef WITH_R2018A_OR_NEWER
    mx_values = mxGetLogicals(mx_field);
#else
    mx_values = (mxLogical*) mxGetData(mx_field);
#endif
    for (size_t i = 0; i < dim; i ++)
        values[i] = mx_values[i];
}

void gt_mex_getfield_struct(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value           /** value of field */
)
{
    /* get field */
    if (mxIsStruct(mx_struct))
        *value = mxGetField(mx_struct, 0, fieldname);
    else
        *value = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !*value)
        mexErrMsgIdAndTxt(ERRID"getfield_struct", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!*value)
        return;

    /* check field */
    if (!mxIsStruct(*value))
        mexErrMsgIdAndTxt(ERRID"getfield_struct", "Structure '%s' has invalid field '%s': not struct", structname, fieldname);
}

void gt_mex_getfield_cell(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value           /** value of field */
)
{
    /* get field */
    if (mxIsStruct(mx_struct))
        *value = mxGetField(mx_struct, 0, fieldname);
    else
        *value = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !*value)
        mexErrMsgIdAndTxt(ERRID"getfield_cell", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!*value)
        return;

    /* check field */
    if (!mxIsCell(*value))
        mexErrMsgIdAndTxt(ERRID"getfield_cell", "Structure '%s' has invalid field '%s': not struct", structname, fieldname);
}

void gt_mex_getfield_table2struct(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value,          /** value of field */
    bool*           was_table       /** true if field was table before conversion */
)
{
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[3] = {NULL};

    *was_table = false;

    /* get field */
    if (mxIsStruct(mx_struct))
        *value = mxGetField(mx_struct, 0, fieldname);
    else
        *value = mxGetProperty(mx_struct, 0, fieldname);
    if (required && !*value)
        mexErrMsgIdAndTxt(ERRID"getfield_table2struct", "Structure '%s' has no field '%s'.", structname, fieldname);
    else if (!*value)
        return;

    /* check field type */
    if (mxIsStruct(*value))
        return;
    if (!gt_mex_istable(*value))
        mexErrMsgIdAndTxt(ERRID"getfield_table2struct", "Structure '%s' has invalid field '%s': not struct and not table", structname, fieldname);

    call_prhs[0] = *value;
    call_prhs[1] = mxCreateString("ToScalar");
    call_prhs[2] = mxCreateLogicalScalar(true);
    if (mexCallMATLAB(1, call_plhs, 3, call_prhs, "table2struct"))
        mexErrMsgIdAndTxt(ERRID"getfield_table2struct", "Calling 'table2struct' failed.");
    *value = call_plhs[0];
    *was_table = true;
}

#ifdef WITH_R2018A_OR_NEWER
void gt_mex_get_records(
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    bool            support_categorical, /** true if categoricals are supported */
    mxArray*        mx_arr_records, /** Matlab records array */
    mxArray**       mx_arr_values,  /** Matlab values array */
    mxDouble**      mx_values,      /** values */
    mxArray**       mx_arr_domains, /** Matlab domains array */
    mxInt32**       mx_domains,     /** domains */
    mxArray**       mx_arr_text     /** explanatory text */
)
#else
void gt_mex_get_records(
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    bool            support_categorical, /** true if categoricals are supported */
    mxArray*        mx_arr_records, /** Matlab records array */
    mxArray**       mx_arr_values,  /** Matlab values array */
    double**        mx_values,      /** values */
    mxArray**       mx_arr_domains, /** Matlab domains array */
    INT32_T**       mx_domains,     /** domains */
    mxArray**       mx_arr_text     /** explanatory text */
)
#endif
{
    int num_domain_fields = 0;
    mxArray* mx_arr_field = NULL;
    const char* field_name = NULL;

    for (int i = 0; i < mxGetNumberOfFields(mx_arr_records); i++)
    {
        mx_arr_field = mxGetFieldByNumber(mx_arr_records, 0, i);
        field_name = mxGetFieldNameByNumber(mx_arr_records, i);

        /* get value fields */
        if (!strcmp(field_name, "level") || !strcmp(field_name, "value"))
            mx_arr_values[GMS_VAL_LEVEL] = mx_arr_field;
        else if (!strcmp(field_name, "element_text"))
        {
            *mx_arr_text = mx_arr_field;

            if (support_categorical && gt_mex_iscategorical(mx_arr_field))
                gt_mex_categorical2cellstr(mx_arr_text);
            else if (!gt_mex_iscellstr(mx_arr_field))
                mexErrMsgIdAndTxt(ERRID"get_records", "Structure '%s' has invalid field "
                    "'%s' in field 'records': Data type must be categorical or cellstr.",
                    name, field_name);

            /* create value array to later hold GDX explanatory text ids */
            mx_arr_values[GMS_VAL_LEVEL] = mxCreateDoubleMatrix(
                mxGetNumberOfElements(*mx_arr_text), 1, mxREAL);
        }
        else if (!strcmp(field_name, "marginal"))
            mx_arr_values[GMS_VAL_MARGINAL] = mx_arr_field;
        else if (!strcmp(field_name, "lower"))
            mx_arr_values[GMS_VAL_LOWER] = mx_arr_field;
        else if (!strcmp(field_name, "upper"))
            mx_arr_values[GMS_VAL_UPPER] = mx_arr_field;
        else if (!strcmp(field_name, "scale"))
            mx_arr_values[GMS_VAL_SCALE] = mx_arr_field;

        /* get domain fields */
        else
        {
            if (num_domain_fields >= dim)
                mexErrMsgIdAndTxt(ERRID"get_records", "Structure '%s' has more domain fields than "
                    "dimension (%d) in field 'records'.", name, dim);
            mx_arr_domains[num_domain_fields] = mx_arr_field;
            gt_mex_int32(&mx_arr_domains[num_domain_fields]);
            num_domain_fields++;
        }
    }

    /* access data */
#ifdef WITH_R2018A_OR_NEWER
    for (size_t i = 0; i < dim; i++)
        if (mx_arr_domains[i])
            mx_domains[i] = mxGetInt32s(mx_arr_domains[i]);
    for (size_t i = 0; i < GMS_VAL_MAX; i++)
        if (mx_arr_values[i])
            mx_values[i] = mxGetDoubles(mx_arr_values[i]);
#else
    for (size_t i = 0; i < dim; i++)
        if (mx_arr_domains[i])
            mx_domains[i] = (INT32_T*) mxGetData(mx_arr_domains[i]);
    for (size_t i = 0; i < GMS_VAL_MAX; i++)
        if (mx_arr_values[i])
            mx_values[i] = mxGetPr(mx_arr_values[i]);
#endif
}

void gt_mex_readdata_addfields(
    int             type,           /** symbol type */
    size_t          dim,            /** symbol dimension */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: 5) */
    char**          domains_ptr,    /** labels of domain fields */
    mxArray*        mx_arr_records, /** matlab records structure (will be modified) */
    size_t*         n_dom_fields    /** number of domain fields added */
)
{
    /* add domain fields */
    *n_dom_fields = 0;
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            for (size_t i = 0; i < dim; i++)
                mxAddField(mx_arr_records, domains_ptr[i]);
            *n_dom_fields = dim;
            break;
    }

    /* add value fields */
    if (values_flag[GMS_VAL_LEVEL])
    {
        switch (type)
        {
            case GMS_DT_PAR:
                mxAddField(mx_arr_records, "value");
                break;
            case GMS_DT_SET:
                mxAddField(mx_arr_records, "element_text");
                break;
            default:
                mxAddField(mx_arr_records, "level");
                break;
        }
    }
    if (values_flag[GMS_VAL_MARGINAL])
        mxAddField(mx_arr_records, "marginal");
    if (values_flag[GMS_VAL_LOWER])
        mxAddField(mx_arr_records, "lower");
    if (values_flag[GMS_VAL_UPPER])
        mxAddField(mx_arr_records, "upper");
    if (values_flag[GMS_VAL_SCALE])
        mxAddField(mx_arr_records, "scale");
}

#ifdef WITH_R2018A_OR_NEWER
void gt_mex_readdata_create(
    size_t          dim,            /** symbol dimension */
    size_t          nrecs,          /** symbol number of records to be read */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: GMS_VAL_MAX) */
    double*         def_values,     /** default values (length: GMS_VAL_MAX) */
    mwSize*         mx_dom_nrecs,   /** number of records of domain symbols */
    size_t*         nvals,          /** number of values created */
    mwIndex**       col_nnz,        /** sparse format only: number of non-zeros for each value field */
    mxArray**       mx_arr_dom_idx, /** matlab struct containing domain indices */
    mxUint64**      mx_dom_idx,     /** matlab struct containing domain indices */
    mxArray**       mx_arr_values,  /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mxDouble**      mx_values,      /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mwIndex**       mx_rows,        /** sparse format only: matlab struct containing record values sparse rows (length: GMS_VAL_MAX) */
    mwIndex**       mx_cols         /** sparse format only: matlab struct containing record values sparse cols (length: GMS_VAL_MAX) */
)
#else
void gt_mex_readdata_create(
    size_t          dim,            /** symbol dimension */
    size_t          nrecs,          /** symbol number of records to be read */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: GMS_VAL_MAX) */
    double*         def_values,     /** default values (length: GMS_VAL_MAX) */
    mwSize*         mx_dom_nrecs,   /** number of records of domain symbols */
    size_t*         nvals,          /** number of values created */
    mwIndex**       col_nnz,        /** sparse format only: number of non-zeros for each value field */
    mxArray**       mx_arr_dom_idx, /** matlab struct containing domain indices */
    UINT64_T**      mx_dom_idx,     /** matlab struct containing domain indices */
    mxArray**       mx_arr_values,  /** matlab struct containing record values (length: GMS_VAL_MAX) */
    double**        mx_values,      /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mwIndex**       mx_rows,        /** sparse format only: matlab struct containing record values sparse rows (length: GMS_VAL_MAX) */
    mwIndex**       mx_cols         /** sparse format only: matlab struct containing record values sparse cols (length: GMS_VAL_MAX) */
)
#endif
{
    /* create domain fields */
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            for (size_t i = 0; i < dim; i++)
            {
                mx_arr_dom_idx[i] = mxCreateNumericMatrix(nrecs, 1, mxUINT64_CLASS, mxREAL);
#ifdef WITH_R2018A_OR_NEWER
                mx_dom_idx[i] = mxGetUint64s(mx_arr_dom_idx[i]);
#else
                mx_dom_idx[i] = (UINT64_T*) mxGetData(mx_arr_dom_idx[i]);
#endif
            }
            break;
    }

    /* create record data structures */
    *nvals = 0;
    switch (format)
    {
        case GT_FORMAT_STRUCT:
        case GT_FORMAT_TABLE:
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i])
                {
                    *nvals += nrecs;
                    mx_arr_values[i] = mxCreateDoubleMatrix(nrecs, 1, mxREAL);
                }
            break;

        case GT_FORMAT_DENSEMAT:
            if (dim == 0)
                mx_dom_nrecs[0] = 1;
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i])
                {
                    mx_arr_values[i] = mxCreateNumericArray(MAX(dim, 1), mx_dom_nrecs, mxDOUBLE_CLASS, mxREAL);
                    *nvals += mxGetNumberOfElements(mx_arr_values[i]);
                }
            break;

        case GT_FORMAT_SPARSEMAT:
            /* create sparse matrices */
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i])
                {
                    size_t nnz = 0;
                    for (size_t j = 0; j < mx_dom_nrecs[1]; j++)
                        nnz += col_nnz[i][j];
                    *nvals += nnz;
                    mx_arr_values[i] = mxCreateSparse(mx_dom_nrecs[0], mx_dom_nrecs[1], nnz, mxREAL);
                }
            break;
    }

    /* data access */
    for (size_t i = 0; i < GMS_VAL_MAX; i++)
        if (values_flag[i])
#ifdef WITH_R2018A_OR_NEWER
            mx_values[i] = mxGetDoubles(mx_arr_values[i]);
#else
            mx_values[i] = mxGetPr(mx_arr_values[i]);
#endif
    switch (format)
    {
        case GT_FORMAT_SPARSEMAT:
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i])
                {
                    mx_rows[i] = mxGetIr(mx_arr_values[i]);
                    mx_cols[i] = mxGetJc(mx_arr_values[i]);
                }
            break;
    }

    /* default values */
    switch (format)
    {
        case GT_FORMAT_DENSEMAT:
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i] && def_values[i] != 0.0)
                {
                    mwIndex nnz = 1;
                    for (size_t j = 0; j < MAX(dim, 1); j++)
                        nnz *= mx_dom_nrecs[j];
                    for (size_t j = 0; j < nnz; j++)
                        mx_values[i][j] = def_values[i];
                }
            break;

        case GT_FORMAT_SPARSEMAT:
            for (size_t i = 0; i < GMS_VAL_MAX; i++)
                if (values_flag[i] && def_values[i] != 0.0)
                {
                    mwIndex nnz = 0;
                    for (size_t j = 0; j < mx_dom_nrecs[1]; j++)
                        nnz += col_nnz[i][j];
                    for (size_t j = 0; j < nnz; j++)
                        mx_values[i][j] = def_values[i];
                }
            break;
    }
}

void gt_mex_domain2categorical(
    mxArray**       mx_arr_domains, /** Matlab domain array */
    const mxArray*  mx_arr_uels     /** cell of uel strings */
)
{
    size_t n;
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[5] = {NULL};
#ifdef WITH_R2018A_OR_NEWER
    mxUint64* mx_uel_ids = NULL;
#else
    UINT64_T* mx_uel_ids = NULL;
#endif

    n = mxGetNumberOfElements(mx_arr_uels);

    call_prhs[0] = *mx_arr_domains;
    call_prhs[1] = mxCreateNumericMatrix(1, n, mxUINT64_CLASS, mxREAL);
    call_prhs[2] = (mxArray*) mx_arr_uels;
    call_prhs[3] = mxCreateString("Ordinal");
    call_prhs[4] = mxCreateLogicalScalar(true);

#ifdef WITH_R2018A_OR_NEWER
    mx_uel_ids = mxGetUint64s(call_prhs[1]);
#else
    mx_uel_ids = (UINT64_T*) mxGetData(call_prhs[1]);
#endif
    for (size_t i = 0; i < n; i++)
        mx_uel_ids[i] = i+1;

    if (mexCallMATLAB(1, call_plhs, 5, call_prhs, "categorical"))
        mexErrMsgIdAndTxt(ERRID"domain2categorical", "Calling 'categorical' failed.");

    *mx_arr_domains = call_plhs[0];
}

void gt_mex_categorical(
    mxArray**       mx_arr_cell     /** cell to be converted into categorical */
)
{
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = *mx_arr_cell;

    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "categorical"))
        mexErrMsgIdAndTxt(ERRID"categorical", "Calling 'categorical' failed.");

    *mx_arr_cell = call_plhs[0];
}

bool gt_mex_istable(
    mxArray*        mx_array        /** Matlab data to be checked if table */
)
{
    mxLogical* mx_istable = NULL;
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = mx_array;
    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "istable"))
        mexErrMsgIdAndTxt(ERRID"istable", "Calling 'istable' failed.");
    mx_istable = mxGetLogicals(call_plhs[0]);

    return mx_istable[0] == true;
}

bool gt_mex_iscellstr(
    mxArray*        mx_array        /** Matlab data to be checked if cellstr */
)
{
    mxLogical* mx_iscellstr = NULL;
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = mx_array;
    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "iscellstr"))
        mexErrMsgIdAndTxt(ERRID"iscellstr", "Calling 'iscellstr' failed.");
    mx_iscellstr = mxGetLogicals(call_plhs[0]);

    return mx_iscellstr[0] == true;
}

bool gt_mex_iscategorical(
    mxArray*        mx_array        /** Matlab data to be checked if categorical */
)
{
    mxLogical* mx_iscategorical = NULL;
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = mx_array;
    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "iscategorical"))
        mexErrMsgIdAndTxt(ERRID"iscategorical", "Calling 'iscategorical' failed.");
    mx_iscategorical = mxGetLogicals(call_plhs[0]);

    return mx_iscategorical[0] == true;
}

void gt_mex_struct2table(
    mxArray**       mx_arr_struct   /** Matlab struct to be converted into table */
)
{
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = *mx_arr_struct;
    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "struct2table"))
        mexErrMsgIdAndTxt(ERRID"struct2table", "Calling 'struct2table' failed.");
    *mx_arr_struct = call_plhs[0];
}

void gt_mex_categorical2cellstr(
    mxArray**       mx_array        /** categorical array to be converted to cellstr */
)
{
    size_t n;
    mxArray* mx_arr_catnames = NULL;
    mxArray* mx_arr_cellstr = NULL;
#ifdef WITH_R2018A_OR_NEWER
    mxInt32* mx_catvals = NULL;
#else
    INT32_T* mx_catvals = NULL;
#endif

    /* get category ids and category names */
    gt_mex_categories(*mx_array, &mx_arr_catnames);
    gt_mex_int32(mx_array);

#ifdef WITH_R2018A_OR_NEWER
    mx_catvals = mxGetInt32s(*mx_array);
#else
    mx_catvals = (INT32_T*) mxGetData(*mx_array);
#endif

    n = mxGetNumberOfElements(*mx_array);
    mx_arr_cellstr = mxCreateCellMatrix(n, 1);

    for (size_t i = 0; i < n; i++)
    {
        mxAssert(mx_catvals[i] >= 0 && mx_catvals[i] <= mxGetNumberOfElements(mx_arr_catnames),
            "Invalid categorical array id");
        if (mx_catvals[i] == 0)
            mxSetCell(mx_arr_cellstr, i, mxCreateString(""));
        else
            mxSetCell(mx_arr_cellstr, i, mxDuplicateArray(mxGetCell(mx_arr_catnames, mx_catvals[i]-1)));
    }

    *mx_array = mx_arr_cellstr;
}

void gt_mex_int32(
    mxArray**       mx_array        /** array to be converted into int32 */
)
{
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = *mx_array;

    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "int32"))
        mexErrMsgIdAndTxt(ERRID"int32", "Calling 'int32' failed.");

    *mx_array = call_plhs[0];
}

void gt_mex_categories(
    mxArray*        mx_arr_catvals, /** categorical array */
    mxArray**       mx_arr_catnames /** categories of categorical array */
)
{
    mxArray* call_plhs[1] = {NULL};
    mxArray* call_prhs[1] = {NULL};

    call_prhs[0] = mx_arr_catvals;

    if (mexCallMATLAB(1, call_plhs, 1, call_prhs, "categories"))
        mexErrMsgIdAndTxt(ERRID"categories", "Calling 'categories' failed.");

    *mx_arr_catnames = call_plhs[0];
}

