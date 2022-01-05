/*
 * GAMS - General Algebraic Modeling System Matlab API
 *
 * Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
 * Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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

#ifndef _GT_CMEX_MEX_H_
#define _GT_CMEX_MEX_H_

#include "mex.h"
#include "gt_cmex_utils.h"

#ifdef __cplusplus
extern "C" {
#endif

/** checks number of input and output arguments */
void gt_mex_check_arguments_num(
    int             n_out_required,/** number of required output arguments */
    int             n_out_given,   /** number of given output arguments */
    int             n_in_required, /** number of required input arguments */
    int             n_in_given     /** number of given input arguments */
);

/** checks and returns char argument */
void gt_mex_check_argument_str(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    char*           value           /** values */
);

/** checks and returns integer argument (copies data - only use for small data) */
void gt_mex_check_argument_int(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    GT_FILTER       filter,         /** filter to be checked for (e.g. GT_FILTER_NONNEGATIVE) */
    size_t          dim,            /** dimension of values array */
    int*            values          /** values */
);

/** checks and returns boolean argument (copies data - only use for small data) */
void gt_mex_check_argument_bool(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position,   /** array index of requested element */
    size_t          dim,            /** dimension of values array */
    bool*           values          /** values */
);

/** checks struct argument */
void gt_mex_check_argument_struct(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
);

/** checks cell argument */
void gt_mex_check_argument_cell(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
);

/** checks object of symbol type argument */
void gt_mex_check_argument_symbol_obj(
    const mxArray*  mx_arr_values[],/** Matlab values */
    size_t          arg_position    /** array index of requested element */
);

/** adds a gdx symbol with initial data (no records) to a Matlab structure */
void gt_mex_addsymbol(
    mxArray*        mx_struct,      /** Matlab struct to add symbol to */
    const char*     name,           /** name of symbol */
    const char*     descr,          /** description of symbol */
    int             type,           /** GAMS type of symbol */
    int             subtype,        /** GAMS subtype of symbol */
    int             format,         /** record format */
    size_t          dim,            /** dimension of symbol */
    size_t*         sizes,          /** sizes of domains (length = dim) */
    const char**    domains,        /** domains of symbol (length = dim) */
    int             domain_type,    /** domain type (e.g. 3: regular or 2: relaxed) */
    size_t          nrecs,          /** number of records */
    mxArray*        mx_arr_records, /** records structure */
    mxArray*        mx_arr_uels     /** list of uels to be stored */
);

/** adds a field to a structure with string type */
void gt_mex_addfield_str(
    mxArray*  mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    const char*     value           /** value of field */
);

/** adds a field to a structure with cell of strings type */
void gt_mex_addfield_cell_str(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of string array */
    const char**    values          /** value of field */
);

/** adds a field to a structure with integer type */
void gt_mex_addfield_int(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    int*            values          /** values of field */
);

/** adds a field to a structure with size_t type */
void gt_mex_addfield_sizet(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    size_t*         values          /** values of field */
);

/** adds a field to a structure with double type */
void gt_mex_addfield_dbl(
    mxArray*        mx_struct,      /** mex structure */
    const char*     fieldname,      /** field name to be added */
    size_t          dim,            /** dimension of integer array */
    double*         values          /** values of field */
);

/** returns the value of a structure field with string type */
void gt_mex_getfield_str(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    const char*     defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    char*           value,          /** value of field */
    size_t          strsize         /** size of value string */
);

/** returns the values of a structure field with cell/string type */
void gt_mex_getfield_cell_str(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    const char*     defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** length of 1dim cell array */
    char*           value[],        /** value of field */
    size_t          strsize         /** size of value string */
);

/** returns the value of structure field with vector integer type */
void gt_mex_getfield_int(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    int             defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    GT_FILTER       filter,         /** set a predefined filter, e.g. GT_FILTER_NONNEGATIVE */
    size_t          dim,            /** size of value array */
    int*            values          /** values of field */
);

/** returns the value of structure field with vector double type */
void gt_mex_getfield_dbl(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    double          defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** size of value array */
    double*         values          /** values of field */
);

/** returns the value of structure field with vector size_t type */
void gt_mex_getfield_sizet(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    size_t          defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    GT_FILTER       filter,         /** set a predefined filter, e.g. GT_FILTER_NONNEGATIVE */
    size_t          dim,            /** size of value array */
    size_t*         values          /** values of field */
);

/** returns the value of structure field with vector boolean type */
void gt_mex_getfield_bool(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            defvalue,       /** default value if field is not present */
    bool            required,       /** true: field is required */
    size_t          dim,            /** size of value array */
    bool*           values          /** values of field */
);

/** returns the value of structrure field with struct type */
void gt_mex_getfield_struct(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value           /** value of field */
);

/** returns the value of structrure field with cell type */
void gt_mex_getfield_cell(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value           /** value of field */
);

/** returns the value of structure field with struct or table type.
 *  If it is table, the table gets converted to struct. */
void gt_mex_getfield_table2struct(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value,          /** value of field */
    bool*           was_table       /** true if field was table before conversion */
);

/** returns the value of structrure field with symbol class type */
void gt_mex_getfield_symbol_obj(
    const mxArray*  mx_struct,      /** mex structure */
    const char*     structname,     /** structure name */
    const char*     fieldname,      /** field name to be read */
    bool            required,       /** true: field is required */
    mxArray**       value           /** value of field */
);

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
    mxArray**       mx_arr_text,    /** explanatory text */
    const char*     domains[]       /** domains of symbol */
);
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
    mxArray**       mx_arr_text,    /** explanatory text */
    const char*     domains[]       /** domains of symbol */
);
#endif

/** creates record and uel fields when reading in data */
void gt_mex_readdata_addfields(
    int             type,           /** symbol type */
    size_t          dim,            /** symbol dimension */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: 5) */
    char**          domains_ptr,    /** labels of domain fields */
    mxArray*        mx_arr_records, /** matlab records structure (will be modified) */
    size_t*         n_dom_fields    /** number of domain fields added */
);

/** creates data structures for reading records */
#ifdef WITH_R2018A_OR_NEWER
void gt_mex_readdata_create(
    size_t          dim,            /** symbol dimension */
    size_t          nrecs,          /** symbol number of records to be read */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: GMS_VAL_MAX) */
    double*         def_values,     /** default values (length: GMS_VAL_MAX) */
    mwSize*         mx_dom_nrecs,   /** number of records of domain symbols */
    mwIndex**       col_nnz,        /** sparse format only: number of non-zeros for each value field */
    mxArray**       mx_arr_dom_idx, /** matlab struct containing domain indices */
    mxUint64**      mx_dom_idx,     /** matlab struct containing domain indices */
    mxArray**       mx_arr_values,  /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mxDouble**      mx_values,      /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mwIndex**       mx_rows,        /** sparse format only: matlab struct containing record values sparse rows (length: GMS_VAL_MAX) */
    mwIndex**       mx_cols         /** sparse format only: matlab struct containing record values sparse cols (length: GMS_VAL_MAX) */
);
#else
void gt_mex_readdata_create(
    size_t          dim,            /** symbol dimension */
    size_t          nrecs,          /** symbol number of records to be read */
    int             format,         /** records format to be read in */
    bool*           values_flag,    /** indicates which values to be read (length: GMS_VAL_MAX) */
    double*         def_values,     /** default values (length: GMS_VAL_MAX) */
    mwSize*         mx_dom_nrecs,   /** number of records of domain symbols */
    mwIndex**       col_nnz,        /** sparse format only: number of non-zeros for each value field */
    mxArray**       mx_arr_dom_idx, /** matlab struct containing domain indices */
    UINT64_T**      mx_dom_idx,     /** matlab struct containing domain indices */
    mxArray**       mx_arr_values,  /** matlab struct containing record values (length: GMS_VAL_MAX) */
    double**        mx_values,      /** matlab struct containing record values (length: GMS_VAL_MAX) */
    mwIndex**       mx_rows,        /** sparse format only: matlab struct containing record values sparse rows (length: GMS_VAL_MAX) */
    mwIndex**       mx_cols         /** sparse format only: matlab struct containing record values sparse cols (length: GMS_VAL_MAX) */
);
#endif

/** converts an integer domain field to categorical */
void gt_mex_domain2categorical(
    mxArray**       mx_arr_domains, /** Matlab domain array */
    const mxArray*  mx_arr_uels     /** cell of uel strings */
);

/** converts a cell array into categorical */
void gt_mex_categorical(
    mxArray**       mx_arr_cell     /** cell to be converted into categorical */
);

/** checks if data is table */
bool gt_mex_istable(
    mxArray*        mx_array        /** Matlab data to be checked if table */
);

/** checks if data is cell of strings */
bool gt_mex_iscellstr(
    mxArray*        mx_array        /** Matlab data to be checked if cellstr */
);

/** checks if data is categorical */
bool gt_mex_iscategorical(
    mxArray*        mx_array        /** Matlab data to be checked if categorical */
);

/** convert structure to table */
void gt_mex_struct2table(
    mxArray**       mx_arr_struct   /** Matlab struct to be converted into table */
);

/** convert categorical array to cell of strings (undefined value -> empty string) */
void gt_mex_categorical2cellstr(
    mxArray**       mx_array        /** categorical array to be converted to cellstr */
);

/** converts structutre to int32 */
void gt_mex_int32(
    mxArray**       mx_array        /** array to be converted into int32 */
);

/** queries the categories of a categorical array */
void gt_mex_categories(
    mxArray*        mx_arr_catvals, /** categorical array */
    mxArray**       mx_arr_catnames /** categories of categorical array */
);

#ifdef __cplusplus
}
#endif

#endif
