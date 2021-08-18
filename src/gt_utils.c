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

#include "gt_utils.h"
#include "gclgms.h"

#include <string.h>
#include <math.h>
#include <stdlib.h>

#define ERRID "GAMSTransfer:gt_utils:"

#if defined(_WIN32)
#include <windows.h>
typedef DWORD64 UINT64;
#else
typedef unsigned long long int UINT64;
#endif

#if defined(_WIN32)
typedef __int64 INT64;
#elif defined(__LP64__) || defined(__axu__) || defined(_FCGLU_LP64_)
typedef signed long int INT64;
#else
typedef signed long long int INT64;
#endif

#if _XOPEN_SOURCE >= 600 || defined(_ISOC99_SOURCE) || _POSIX_C_SOURCE >= 200112L || defined(__APPLE__)
#define GT_IS_NAN isnan
#elif defined(_BSD_SOURCE)
#define GT_IS_NAN isnan
#elif defined(_MSC_VER)
#define GT_IS_NAN _isnan
#else
#define GT_IS_NAN(x) (!((x) == (x)))
#endif

typedef union rec64 {
  INT64 i64;
  double x;
} rec64_t;

typedef struct gt_type_default
{
    int type;
    int subtype;
    double level;
    double marginal;
    double lower;
    double upper;
    double scale;
} gt_type_default_t;

typedef struct gt_domain_sort
{
    size_t dim;
    size_t idx;
    int* domain_uels;
} gt_domain_sort_t;

const gt_type_default_t GT_TYPE_DEFAULT[] =
{
    {GMS_DT_SET,   -1,                                    0, GMS_SV_NA, GMS_SV_NA,   GMS_SV_NA,   GMS_SV_NA},
    {GMS_DT_PAR,   -1,                                    0, GMS_SV_NA, GMS_SV_NA,   GMS_SV_NA,   GMS_SV_NA},
    {GMS_DT_VAR,   GMS_VARTYPE_BINARY,                    0, 0,         0,           1,           1},
    {GMS_DT_VAR,   GMS_VARTYPE_INTEGER,                   0, 0,         0,           GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_POSITIVE,                  0, 0,         0,           GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_NEGATIVE,                  0, 0,         GMS_SV_MINF, 0,           1},
    {GMS_DT_VAR,   GMS_VARTYPE_FREE,                      0, 0,         GMS_SV_MINF, GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_SOS1,                      0, 0,         0,           GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_SOS2,                      0, 0,         0,           GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_SEMICONT,                  0, 0,         1,           GMS_SV_PINF, 1},
    {GMS_DT_VAR,   GMS_VARTYPE_SEMIINT,                   0, 0,         1,           GMS_SV_PINF, 1},
    {GMS_DT_EQU,   GMS_EQUTYPE_E + GMS_EQU_USERINFO_BASE, 0, 0,         0,           0,           1},
    {GMS_DT_EQU,   GMS_EQUTYPE_L + GMS_EQU_USERINFO_BASE, 0, 0,         GMS_SV_MINF, 0,           1},
    {GMS_DT_EQU,   GMS_EQUTYPE_G + GMS_EQU_USERINFO_BASE, 0, 0,         0,           GMS_SV_PINF, 1},
    {GMS_DT_EQU,   GMS_EQUTYPE_N + GMS_EQU_USERINFO_BASE, 0, 0,         GMS_SV_MINF, GMS_SV_PINF, 1},
    {GMS_DT_EQU,   GMS_EQUTYPE_X + GMS_EQU_USERINFO_BASE, 0, 0,         GMS_SV_MINF, GMS_SV_PINF, 1},
    {GMS_DT_EQU,   GMS_EQUTYPE_B + GMS_EQU_USERINFO_BASE, 0, 0,         GMS_SV_MINF, GMS_SV_PINF, 1},
    {GMS_DT_EQU,   GMS_EQUTYPE_C + GMS_EQU_USERINFO_BASE, 0, 0,         GMS_SV_MINF, GMS_SV_PINF, 1},
};

/** comparison function for sorting gt_domain_sort_t */
static int gt_utils_domain_sort_comp(
    const void*     a,
    const void*     b
);

double gt_utils_getna(void)
{
    rec64_t na;
    na.i64 = 0xffffffff;
    na.i64 = na.i64 << 32;
    na.i64 |= 0xfffffffe;
    return na.x;
}

bool gt_utils_isna(
    double          x               /** value to be checked for NA */
)
{
    rec64_t r64, na;
    if (!GT_IS_NAN(x))
        return false;
    r64.x = x;
    na.i64 = 0xffffffff;
    na.i64 = na.i64 << 32;
    na.i64 |= 0xfffffffe;
    return na.i64 == r64.i64;
}

double gt_utils_geteps(void)
{
    return -1.0 * 0;
}

bool gt_utils_iseps(
    double          x               /** value to be checked for EPS */
)
{
    UINT64 u;
    mxAssert(sizeof(x) == sizeof(u), "Invalid double size");
    mxAssert(sizeof(u) == 8, "Invalid double size");
    if (x != 0.0)
        return false;
    memcpy(&u, &x, sizeof(u));
    u >>= 63;
    if (u)
        return true;
    return false;
}

double gt_utils_sv_gams2matlab(
    double          value,          /** original value */
    int             n_acronyms,     /** number of acronyms */
    int*            acronyms        /** acronyms to be converted to GAMS NA */
)
{
    if (value == GMS_SV_UNDEF)
        return mxGetNaN();
    if (value == GMS_SV_NA)
        return gt_utils_getna();
    if (value == GMS_SV_PINF)
        return mxGetInf();
    if (value == GMS_SV_MINF)
        return -mxGetInf();
    if (value == GMS_SV_EPS)
        return gt_utils_geteps();
    for (int i = 0; i < n_acronyms; i++)
        if (value == acronyms[i] * GMS_SV_ACR)
            return gt_utils_getna();
    return value;
}

double gt_utils_sv_matlab2gams(
    double          value           /** original value */
)
{
    if (gt_utils_isna(value))
        return GMS_SV_NA;
    if (mxIsNaN(value))
        return GMS_SV_UNDEF;
    if (mxIsInf(value) && value > 0)
        return GMS_SV_PINF;
    if (mxIsInf(value) && value < 0)
        return GMS_SV_MINF;
    if (gt_utils_iseps(value))
        return GMS_SV_EPS;
    return value;
}

void gt_utils_type_default_values(
    int             type,           /** GDX symbol type */
    int             subtype,        /** GDX symbol subtype */
    bool            sv_matlab,      /** special values in Matlab form? */
    double*         def_values      /** array of default values (size: GMS_VAL_MAX) */
)
{
    int i = 0;

    def_values[GMS_VAL_LEVEL] = 0;
    def_values[GMS_VAL_MARGINAL] = 0;
    def_values[GMS_VAL_LOWER] = GMS_SV_MINF;
    def_values[GMS_VAL_UPPER] = GMS_SV_PINF;
    def_values[GMS_VAL_SCALE] = 1;
    while (GT_TYPE_DEFAULT[i].type >= 0)
    {
        if (GT_TYPE_DEFAULT[i].type == type && (GT_TYPE_DEFAULT[i].subtype <= 0 || GT_TYPE_DEFAULT[i].subtype == subtype))
        {
            def_values[GMS_VAL_LEVEL] = GT_TYPE_DEFAULT[i].level;
            def_values[GMS_VAL_MARGINAL] = GT_TYPE_DEFAULT[i].marginal;
            def_values[GMS_VAL_LOWER] = GT_TYPE_DEFAULT[i].lower;
            def_values[GMS_VAL_UPPER] = GT_TYPE_DEFAULT[i].upper;
            def_values[GMS_VAL_SCALE] = GT_TYPE_DEFAULT[i].scale;
            break;
        }
        i++;
    }

    if (sv_matlab)
        for (size_t i = 0; i < GMS_VAL_MAX; i++)
            def_values[i] = gt_utils_sv_gams2matlab(def_values[i], 0, NULL);
}

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
)
{
    if (first_call)
    {
        mx_idx_last[0] = 0;
        mx_idx_last[1] = 0;
    }
    if (flat_idx)
        memset(flat_idx, 0, GMS_VAL_MAX * sizeof(mwIndex));

    /* count number of nonzero elements */
    for (size_t i = 0; i < GMS_VAL_MAX; i++)
    {
        mwIndex* cols_i = NULL;
        mwIndex* rows_i = NULL;

        if (!values_flag[i])
            continue;

        if (cols && rows)
        {
            cols_i = cols[i];
            rows_i = rows[i];
        }

        /* contribution from nonzero default values that are not stored in GDX */
        if (def_values[i] != 0.0)
            gt_utils_count_2d_rowmajor_nnz_between(n_cols, mx_idx_last[0], mx_idx_last[1],
                mx_idx[0], mx_idx[1], col_nnz[i], cols_i, rows_i);

        /* contribution of this non-zero */
        if (values[i] != 0.0)
        {
            if (cols_i && rows_i && flat_idx)
            {
                flat_idx[i] = cols_i[mx_idx[1]] + col_nnz[i][mx_idx[1]];
                rows_i[flat_idx[i]] = mx_idx[0];
            }
            col_nnz[i][mx_idx[1]]++;
        }
    }

    /* get index after current in row-major order */
    if (mx_idx[1] < n_cols)
    {
        mx_idx_last[0] = mx_idx[0];
        mx_idx_last[1] = mx_idx[1]+1;
    }
    else
    {
        mx_idx_last[0] = mx_idx[0]+1;
        mx_idx_last[1] = 0;
    }

    if (last_call)
    {
        /* count number of nonzero elements (contribution from nonzero
         * default values that are not stored in GDX) */
        for (size_t i = 0; i < GMS_VAL_MAX; i++)
            if (values_flag[i] && def_values[i] != 0.0)
            {
                mwIndex* cols_i = NULL;
                mwIndex* rows_i = NULL;
                if (cols && rows)
                {
                    cols_i = cols[i];
                    rows_i = rows[i];
                }
                gt_utils_count_2d_rowmajor_nnz_between(n_cols, mx_idx_last[0],
                    mx_idx_last[1], n_rows-1, n_cols, col_nnz[i], cols_i, rows_i);
            }
    }
}

void gt_utils_count_2d_rowmajor_nnz_between(
    size_t          n_cols,         /** number of sparse matrix columns */
    size_t          idx_row1,       /** row index of smaller index in row major order */
    size_t          idx_col1,       /** col index of smaller index in row major order */
    size_t          idx_row2,       /** row index of larger index in row major order */
    size_t          idx_col2,       /** col index of larger index in col major order */
    mwIndex*        col_nnz,        /** nnz counts between indices (doesn't init to zero) */
    mwIndex*        cols,           /** if not NULL, provides column starts */
    mwIndex*        rows            /** if not NULL, row indices based on cols and current col_nnz will be stored */
)
{
    size_t idx;

    mxAssert(idx_row1 <= idx_row2, "Invalid matrix index");
    mxAssert(idx_row1 < idx_row2 || idx_col1 <= idx_col2, "Invalid matrix index");

    if (cols && rows)
    {
        if (idx_row1 == idx_row2)
        {
            for (size_t i = idx_col1; i < idx_col2; i++)
            {
                idx = cols[i] + col_nnz[i];
                rows[idx] = idx_row1;
                col_nnz[i]++;
            }
        }
        else
        {
            for (size_t i = idx_col1; i < n_cols; i++)
            {
                idx = cols[i] + col_nnz[i];
                rows[idx] = idx_row1;
                col_nnz[i]++;
            }
            for (size_t j = idx_row1 + 1; j < idx_row2; j++)
                for (size_t i = 0; i < n_cols; i++)
                {
                    idx = cols[i] + col_nnz[i];
                    rows[idx] = j;
                    col_nnz[i]++;
                }
            for (size_t i = 0; i < idx_col2; i++)
            {
                idx = cols[i] + col_nnz[i];
                rows[idx] = idx_row2;
                col_nnz[i]++;
            }
        }
    }
    else
    {
        if (idx_row1 == idx_row2)
            for (size_t i = idx_col1; i < idx_col2; i++)
                col_nnz[i]++;
        else
        {
            for (size_t i = idx_col1; i < n_cols; i++)
                col_nnz[i]++;
            if (idx_row2 - idx_row1 > 1)
                for (size_t i = 0; i < n_cols; i++)
                    col_nnz[i] += idx_row2 - idx_row1 - 1;
            for (size_t i = 0; i < idx_col2; i++)
                col_nnz[i]++;
        }
    }
}

#ifdef WITH_R2018A_OR_NEWER
void gt_utils_sort_domains(
    const char*     symname,        /** name of symbol */
    size_t          nrecs,          /** number of records */
    size_t          dim,            /** dimension of symbol */
    mxInt32**       mx_domains,     /** domains points into dom_uel_ids (first length: dim; second length: nrecs) */
    size_t*         n_dom_uels,     /** lengths of uel fields (length: dim) */
    int**           dom_uel_ids,    /** domain uel ids (first length: dim; second length: n_dom_uels[dim]) */
    size_t*         idx             /** index (length: nrecs; assumed to hold initial indexing) */
)
#else
void gt_utils_sort_domains(
    const char*     symname,        /** name of symbol */
    size_t          nrecs,          /** number of records */
    size_t          dim,            /** dimension of symbol */
    INT32_T**       mx_domains,     /** domains points into dom_uel_ids (first length: dim; second length: nrecs) */
    size_t*         n_dom_uels,     /** lengths of uel fields (length: dim) */
    int**           dom_uel_ids,    /** domain uel ids (first length: dim; second length: n_dom_uels[dim]) */
    size_t*         idx             /** index (length: nrecs; assumed to hold initial indexing) */
)
#endif
{
    gt_domain_sort_t* sortrecs = NULL;

    sortrecs = (gt_domain_sort_t*) mxMalloc(nrecs * sizeof(gt_domain_sort_t));

    /* init sort records */
    for (size_t i = 0; i < nrecs; i++)
    {
        sortrecs[i].dim = dim;
        sortrecs[i].idx = idx[i];
        sortrecs[i].domain_uels = (int*) mxMalloc(dim * sizeof(int));
        if (n_dom_uels && dom_uel_ids)
            for (size_t j = 0; j < dim; j++)
            {
                size_t rel_idx = mx_domains[j][i];
                if (rel_idx <= 0)
                    mexErrMsgIdAndTxt(ERRID"sort_domains", "Symbol '%s' has "
                        "invalid domain index: %d. Missing UEL?", symname, rel_idx);
                if (rel_idx > n_dom_uels[j])
                    mexErrMsgIdAndTxt(ERRID"sort_domains", "Symbol '%s' has "
                        "unregistered UEL.", symname);
                sortrecs[i].domain_uels[j] = dom_uel_ids[j][rel_idx-1];
            }
        else
            for (size_t j = 0; j < dim; j++)
                sortrecs[i].domain_uels[j] = mx_domains[j][i];
    }

    /* sort */
    qsort(sortrecs, nrecs, sizeof(gt_domain_sort_t), gt_utils_domain_sort_comp);

    /* get sorted indices */
    for (size_t i = 0; i < nrecs; i++)
        idx[i] = sortrecs[i].idx;

    /* free memory */
    for (size_t i = 0; i < nrecs; i++)
        mxFree(sortrecs[i].domain_uels);
    mxFree(sortrecs);
}

static int gt_utils_domain_sort_comp(
    const void*     a,
    const void*     b
)
{
    gt_domain_sort_t* x = (gt_domain_sort_t*) a;
    gt_domain_sort_t* y = (gt_domain_sort_t*) b;

    if (x->dim < y->dim)
        return -1;
    if (x->dim > y->dim)
        return 1;

    for (size_t i = 0; i < x->dim; i++)
    {
        if (x->domain_uels[i] < y->domain_uels[i])
            return -1;
        if (x->domain_uels[i] > y->domain_uels[i])
            return 1;
    }

    return 0;
}
