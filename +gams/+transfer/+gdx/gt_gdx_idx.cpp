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

#include "gt_gdx_idx.h"
#include "gt_mex.h"

#include <string.h>
#include <stdio.h>

#define ERRID "gams:transfer:cmex:gt_gdx_idx:"

void gt_gdx_init_read(
    gdxHandle_t*    gdx,            /** GDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
)
{
    int status;
    char buf[GMS_SSSIZE];

    /* start gdx */
    if (!gdxCreateD(gdx, sysdir, buf, sizeof(buf)))
        mexErrMsgIdAndTxt(ERRID"gdxCreateD", "GDX init failed: %s", buf);
    mxAssert(*gdx, "GDX init failed!");

    /* open gdx file */
    if (!gdxOpenRead(*gdx, filename, &status))
    {
        gdxErrorStr(*gdx, status, buf);
        mexErrMsgIdAndTxt(ERRID"gdxOpenRead", buf);
    }
}

void gt_gdx_init_write(
    gdxHandle_t*    gdx,            /** GDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename,       /** GDX filename */
    bool            compress        /** enable compression for write */
)
{
    int status;
    char buf[GMS_SSSIZE];

    /* start gdx */
    if (!gdxCreateD(gdx, sysdir, buf, sizeof(buf)))
        mexErrMsgIdAndTxt(ERRID"gdxCreateD", "GDX init failed: %s", buf);
    mxAssert(*gdx, "GDX init failed!");

    /* open gdx file */
    if (!gdxOpenWriteEx(*gdx, filename, "GAMS Matlab API: GAMS Transfer", compress, &status))
    {
        gdxErrorStr(*gdx, status, buf);
        mexErrMsgIdAndTxt(ERRID"gdxOpenWrite", buf);
    }
}

void gt_idx_init_read(
    idxHandle_t*    gdx,            /** IDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
)
{
    int status;
    char buf[GMS_SSSIZE];

    /* start gdx */
    idxLibraryUnload();
    if (!idxCreateD(gdx, sysdir, buf, sizeof(buf)))
        mexErrMsgIdAndTxt(ERRID"idxCreateD", "GDX init failed: %s", buf);
    mxAssert(*gdx, "GDX init failed!");

    /* open gdx file */
    if (!idxOpenRead(*gdx, filename, &status))
    {
        idxErrorStr(*gdx, status, buf, GMS_SSSIZE);
        mexErrMsgIdAndTxt(ERRID"idxOpenRead", buf);
    }
}

void gt_idx_init_write(
    idxHandle_t*    gdx,            /** IDX handle */
    const char*     sysdir,         /** GAMS system directory */
    const char*     filename        /** GDX filename */
)
{
    int status;
    char buf[GMS_SSSIZE];

    /* start gdx */
    idxLibraryUnload();
    if (!idxCreateD(gdx, sysdir, buf, sizeof(buf)))
        mexErrMsgIdAndTxt(ERRID"idxCreateD", "GDX init failed: %s", buf);
    mxAssert(*gdx, "GDX init failed!");

    /* open gdx file */
    if (!idxOpenWrite(*gdx, filename, "GAMS Matlab API: GAMS Transfer", &status))
    {
        idxErrorStr(*gdx, status, buf, GMS_SSSIZE);
        mexErrMsgIdAndTxt(ERRID"idxOpenWrite", buf);
    }
}

void gt_gdx_register_uels(
    gdxHandle_t     gdx,            /** GDX handle */
    mxArray*        mx_cell_uels,   /** cell of strings with uels */
    int*            uel_ids         /** array of uel ids returned by GDX */
)
{
    int uel_id;
    char buf[GMS_SSSIZE];

    if (!mxIsCell(mx_cell_uels))
        mexErrMsgIdAndTxt(ERRID"register_uels", "UEL array must be of type cell of string.");

    if (!gdxUELRegisterStrStart(gdx))
        mexErrMsgIdAndTxt(ERRID"gdxUELRegisterRawStart", "GDX error (gdxUELRegisterRawStart)");

    /* register uels */
    for (size_t i = 0; i < mxGetNumberOfElements(mx_cell_uels); i++)
    {
        mxArray* mx_arr_uel = mxGetCell(mx_cell_uels, i);
        if (!mxIsChar(mx_arr_uel))
            mexErrMsgIdAndTxt(ERRID"register_uels", "UEL array must be of type cell of string.");
        mxGetString(mx_arr_uel, buf, GMS_SSSIZE);

        if (!gdxUELRegisterStr(gdx, buf, &uel_id))
            mexErrMsgIdAndTxt(ERRID"gdxUELRegisterRaw", "GDX error (gdxUELRegisterRaw)");
        if (uel_ids)
            uel_ids[i] = uel_id;
    }

    if (!gdxUELRegisterDone(gdx))
        mexErrMsgIdAndTxt(ERRID"gdxUELRegisterDone", "GDX error (gdxUELRegisterDone)");
}

void gt_gdx_addalias(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     name,           /** name of alias symbol */
    const char*     alias_with      /** text of alias symbol */
)
{
    if (!gdxAddAlias(gdx, name, alias_with))
        mexErrMsgIdAndTxt(ERRID"addalias", "Symbol '%s' can't add alias: %s", name, alias_with);
}

void gt_gdx_addsettext(
    gdxHandle_t     gdx,            /** GDX handle */
    mxArray*        mx_arr_text,    /** explanatory texts as matlab cell array */
    double*         text_ids        /** determined text ids (0 if no text) */
)
{
    int text_id;
    char buf[GMS_SSSIZE];
    mxArray* mx_text;

    /* check input */
    if (!mxIsCell(mx_arr_text))
        mexErrMsgIdAndTxt(ERRID"addsettext", "element_text data must be of type 'cell' of 'char'.");

    for (size_t i = 0; i < mxGetNumberOfElements(mx_arr_text); i++)
    {
        /* get explanatory element_text */
        mx_text = mxGetCell(mx_arr_text, i);
        if (!mxIsChar(mx_text))
            mexErrMsgIdAndTxt(ERRID"addsettext", "element_text data must be of type 'cell' of 'char'.");
        mxGetString(mx_text, buf, GMS_SSSIZE);

        /* in case we got this from a categorical we may have "<undefined>"
         * instead of empty strings */
        if (!strcmp(buf, ""))
        {
            text_ids[i] = 0;
            continue;
        }

        /* register element_text */
        if (!gdxAddSetText(gdx, buf, &text_id))
            mexErrMsgIdAndTxt(ERRID"addsettext", "GDX error (gdxAddSetText)");
        text_ids[i] = text_id;
    }
}

void gt_gdx_setdomain(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     mode,           /** relaxed or regular */
    int             symbol_nr,      /** symbol number */
    const char**    domains         /** domains */
)
{
    char buf[GMS_SSSIZE];

    if (!strcmp(mode, "regular") || !strcmp(mode, "none"))
    {
        if (!gdxSymbolSetDomain(gdx, (const char**) domains))
        {
            gdxGetLastError(gdx); // clears last error
            if (!gdxSymbolSetDomainX(gdx, symbol_nr, (const char**) domains))
            {
                gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
                mexErrMsgIdAndTxt(ERRID"setdomain", "GDX error: %s", buf);
            }
        }
    }
    else if (!strcmp(mode, "relaxed"))
    {
        if (!gdxSymbolSetDomainX(gdx, symbol_nr, (const char**) domains))
        {
            gdxErrorStr(gdx, gdxGetLastError(gdx), buf);
            mexErrMsgIdAndTxt(ERRID"setdomain", "GDX error: %s", buf);
        }
    }
    else
        mexErrMsgIdAndTxt(ERRID"setdomain", "Invalid GDX domain mode.");
}

void gt_gdx_get_record_name(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     sym_name,       /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    bool            use_uel_label,  /** true if uel ids should be converted to uel label */
    int*            uel_indices,    /** uel indices for each domain (length dim) */
    char*           rec_name        /** full record name */
)
{
    char uel_name[GMS_SSSIZE];

    strcpy(rec_name, sym_name);
    strcat(rec_name, "(");
    for (size_t i = 0; i < dim; i++)
    {
        if (use_uel_label)
            gdxGetUEL(gdx, uel_indices[i], uel_name);
        else
            sprintf(uel_name, "%d", uel_indices[i]);
        if (i > 0)
            strcat(rec_name, ",");
        strcat(rec_name, uel_name);
    }
    strcat(rec_name, ")");
}

void gt_gdx_write_record_error(
    gdxHandle_t     gdx,            /** GDX handle */
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    int*            uel_indices     /** uel indices for each domain (length dim) */
)
{
    char gdx_err_msg[GMS_SSSIZE], rec_name[GMS_SSSIZE];

    gdxErrorStr(gdx, gdxGetLastError(gdx), gdx_err_msg);
    gt_gdx_get_record_name(gdx, name, dim, true, uel_indices, rec_name);
    mexErrMsgIdAndTxt(ERRID"gdxDataWriteRaw", "GDX error in record %s: %s", rec_name, gdx_err_msg);
}

void gt_idx_write_record_error(
    idxHandle_t     gdx,            /** IDX handle */
    const char*     name,           /** name of symbol */
    size_t          dim,            /** dimension of symbol */
    int*            uel_indices     /** uel indices for each domain (length dim) */
)
{
    char gdx_err_msg[GMS_SSSIZE], rec_name[GMS_SSSIZE];

    idxErrorStr(gdx, idxGetLastError(gdx), gdx_err_msg, GMS_SSSIZE);
    gt_gdx_get_record_name(NULL, name, dim, false, uel_indices, rec_name);
    mexErrMsgIdAndTxt(ERRID"idxDataWriteRaw", "GDX error in record %s: %s", rec_name, gdx_err_msg);
}
