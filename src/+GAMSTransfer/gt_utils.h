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

#ifndef _GT_UTILS_H_
#define _GT_UTILS_H_

#include <stdbool.h>

#include "mex.h"

typedef enum
{
    GT_FORMAT_UNKNOWN = -1,
    GT_FORMAT_NOT_READ = 0,
    GT_FORMAT_EMPTY = 1,
    GT_FORMAT_STRUCT = 2,
    GT_FORMAT_DENSEMAT = 3,
    GT_FORMAT_SPARSEMAT = 4,
    GT_FORMAT_TABLE = 5,
} GT_FORMAT;

typedef enum
{
    GT_FILTER_NONE,
    GT_FILTER_NONNEGATIVE,
    GT_FILTER_BOOL,
} GT_FILTER;

/* min of two values */
#define MIN(a,b) (((a) > (b)) ? (b) : (a))
/* max of two values */
#define MAX(a,b) (((a) > (b)) ? (a) : (b))

#ifdef __cplusplus
extern "C" {
#endif

/** get nan value for GAMS NA special value */
double gt_utils_getna(void);

/** check if value is nan value that represents GAMS NA special value */
bool gt_utils_isna(
    double          x               /** value to be checked for NA */
);

/** get value for GAMS EPS special value */
double gt_utils_geteps(void);

/** check if value is value that represents GAMS EPS special value */
bool gt_utils_iseps(
    double          x               /** value to be checked for EPS */
);

/** translates GAMS double values to Matlab double values */
double gt_utils_sv_gams2matlab(
    double          gams_value      /** original GAMS value */
);

/** translates Matlab double values to GAMS double values */
double gt_utils_sv_matlab2gams(
    double          gams_value      /** original GAMS value */
);

/** returns the default GDX values for the given (type,subtype) tuple */
void gt_utils_type_default_values(
    int             type,           /** GDX symbol type */
    int             subtype,        /** GDX symbol subtype */
    double*         def_values      /** array of default values (size: GMS_VAL_MAX) */
);

/** counts column nnz in sparse 2d matrix in row major order (call for each entry)
 *  for all value fields. Does not include count for current recod. */
void gt_utils_count_2d_rowmajor_nnz(
    size_t          dim,            /** symbol dimension */
    mwIndex*        mx_idx,         /** current index pair (row,col) */
    mwIndex*        mx_idx_last,    /** last index pair (row,col) */
    size_t          n_rows,         /** number of rows */
    size_t          n_cols,         /** number of columns */
    bool            first_call,     /** true if first call */
    bool            last_call,      /** true if last call */
    bool*           values_flag,    /** indicates which values to be read (length: GMS_VAL_MAX) */
    double*         def_values,     /** default values (length: GMS_VAL_MAX) */
    double*         values,         /** read in values (length: GMS_VAL_MAX) */
    mwIndex**       col_nnz,        /** nnz counts between indices (doesn't init to zero) */
    mwIndex**       cols,           /** if not NULL, provides column starts */
    mwIndex**       rows,           /** if not NULL, row indices based on cols and current col_nnz will be stored */
    mwIndex*        flat_idx        /** flat one-dim index of this (row,col) index in matlab matrix structure */
);

/** counts column nnz between two indices in sparse 2d matrix in row major order */
void gt_utils_count_2d_rowmajor_nnz_between(
    size_t          n_cols,         /** number of sparse matrix columns */
    size_t          idx_row1,       /** row index of smaller index in row major order */
    size_t          idx_col1,       /** col index of smaller index in row major order */
    size_t          idx_row2,       /** row index of larger index in row major order */
    size_t          idx_col2,       /** col index of larger index in col major order */
    mwIndex*        col_nnz,        /** nnz counts between indices (doesn't init to zero) */
    mwIndex*        cols,           /** if not NULL, provides column starts */
    mwIndex*        rows            /** if not NULL, row indices based on cols and current col_nnz will be stored */
);

/** sort index by domains in GDX style */
#ifdef WITH_R2018A_OR_NEWER
void gt_utils_sort_domains(
    const char*     symname,        /** name of symbol */
    size_t          nrecs,          /** number of records */
    size_t          dim,            /** dimension of symbol */
    mxInt32**       mx_domains,     /** domains points into dom_uel_ids (first length: dim; second length: nrecs) */
    size_t*         n_dom_uels,     /** lengths of uel fields (length: dim) */
    int**           dom_uel_ids,    /** domain uel ids (first length: dim; second length: n_dom_uels[dim]) */
    size_t*         idx             /** index (length: nrecs; assumed to hold initial indexing) */
);
#else
void gt_utils_sort_domains(
    const char*     symname,        /** name of symbol */
    size_t          nrecs,          /** number of records */
    size_t          dim,            /** dimension of symbol */
    INT32_T**       mx_domains,     /** domains points into dom_uel_ids (first length: dim; second length: nrecs) */
    size_t*         n_dom_uels,     /** lengths of uel fields (length: dim) */
    int**           dom_uel_ids,    /** domain uel ids (first length: dim; second length: n_dom_uels[dim]) */
    size_t*         idx             /** index (length: nrecs; assumed to hold initial indexing) */
);
#endif

#ifdef __cplusplus
}
#endif

#endif
