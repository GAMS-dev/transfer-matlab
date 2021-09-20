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

#ifndef _GT_GDX_IDX_H_
#define _GT_GDX_IDX_H_

#include "gdxcc.h"
#include "idxcc.h"
#include "mex.h"

#ifdef __cplusplus
extern "C" {
#endif

/** creates GDX handle and opens GDX file for reading */
void gt_gdx_init_read(
    gdxHandle_t*    gdx,            /** GDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
);

/** creates GDX handle and opens GDX file for writing */
void gt_gdx_init_write(
    gdxHandle_t*    gdx,            /** GDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename,       /** GDX filename */
    bool            compress        /** enable compression for write */
);

/** creates IDX handle and opens GDX file for reading */
void gt_idx_init_read(
    idxHandle_t*    gdx,            /** IDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
);

/** creates IDX handle and opens GDX file for writing */
void gt_idx_init_write(
    idxHandle_t*    gdx,            /** IDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
);

/** registers uels given as a Matlab cell of strings */
void gt_gdx_register_uels(
    gdxHandle_t     gdx,            /** GDX handle */
    mxArray*        mx_cell_uels,   /** cell of strings with uels */
    int*            uel_ids         /** array of uel ids returned by GDX */
);

/** adds an alias to GDX */
void gt_gdx_addalias(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     name,           /** name of alias symbol */
    const char*     alias_with      /** name of aliased symbol */
);

/** adds an explanatory text to GDX */
void gt_gdx_addsettext(
    gdxHandle_t     gdx,            /** GDX handle */
    mxArray*        mx_arr_text,    /** explanatory texts as matlab cell array */
    double*         text_ids        /** determined text ids (0 if no text) */
);

/** adds domain information to symbol (call within write mode) */
void gt_gdx_setdomain(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     mode,           /** relaxed or regular */
    int             symbol_nr,      /** symbol number */
    const char**    domains         /** domains */
);

/** creates record name from symbol name and UEL indices */
void gt_gdx_get_record_name(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     sym_name,       /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    bool            use_uel_label,  /** true if uel ids should be converted to uel label */
    int*            uel_indices,    /** uel indices for each domain (length dim) */
    char*           rec_name        /** full record name */
);

/** raises an error and writes record name plus gdx error message */
void gt_gdx_write_record_error(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    int*            uel_indices     /** uel indices for each domain (length dim) */
);

/** raises an error and writes record name plus gdx error message */
void gt_idx_write_record_error(
    idxHandle_t     gdx,            /** IDX handle */
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    int*            uel_indices     /** uel indices for each domain (length dim) */
);

#ifdef __cplusplus
}
#endif

#endif
