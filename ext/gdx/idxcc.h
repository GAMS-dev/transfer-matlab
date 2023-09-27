/* idxcc.h
 * Header file for C-style interface to the IDX library
 * generated by apiwrapper for GAMS Version 44.2.0
 *
 * GAMS - Loading mechanism for GAMS Expert-Level APIs
 *
 * Copyright (c) 2016-2023 GAMS Software GmbH <support@gams.com>
 * Copyright (c) 2016-2023 GAMS Development Corp. <support@gams.com>
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


#if ! defined(_IDXCC_H_)
#     define  _IDXCC_H_

#define IDXAPIVERSION 1

#include "gclgms.h"

#if defined(_WIN32)
# define IDX_CALLCONV __stdcall
#else
# define IDX_CALLCONV
#endif

#if defined(__cplusplus)
extern "C" {
#endif

struct idxRec;
typedef struct idxRec *idxHandle_t;

typedef int (*idxErrorCallback_t) (int ErrCount, const char *msg);

/* headers for "wrapper" routines implemented in C */
/** idxGetReady: load library
 *  @return false on failure to load library, true on success 
 */
int idxGetReady  (char *msgBuf, int msgBufLen);

/** idxGetReadyD: load library from the speicified directory
 * @return false on failure to load library, true on success 
 */
int idxGetReadyD (const char *dirName, char *msgBuf, int msgBufLen);

/** idxGetReadyL: load library from the specified library name
 *  @return false on failure to load library, true on success 
 */
int idxGetReadyL (const char *libName, char *msgBuf, int msgBufLen);

/** idxCreate: load library and create idx object handle 
 *  @return false on failure to load library, true on success 
 */
int idxCreate    (idxHandle_t *pidx, char *msgBuf, int msgBufLen);

/** idxCreateD: load library from the specified directory and create idx object handle
 * @return false on failure to load library, true on success 
 */
int idxCreateD   (idxHandle_t *pidx, const char *dirName, char *msgBuf, int msgBufLen);

/** idxCreate: load library from the specified library name and create idx object handle
 * @return false on failure to load library, true on success 
 */
int idxCreateL   (idxHandle_t *pidx, const char *libName, char *msgBuf, int msgBufLen);

/** idxFree: free idx object handle 
 * @return false on failure, true on success 
 */
int idxFree      (idxHandle_t *pidx);

/** Check if library has been loaded
 * @return false on failure, true on success 
 */
int idxLibraryLoaded(void);

/** Check if library has been unloaded
 * @return false on failure, true on success 
 */
int idxLibraryUnload(void);

/** Check if API and library have the same version, Library needs to be initialized before calling this.
 * @return true  (1) on success,
 *         false (0) on failure.
 */
int  idxCorrectLibraryVersion(char *msgBuf, int msgBufLen);

int  idxGetScreenIndicator   (void);
void idxSetScreenIndicator   (int scrind);
int  idxGetExceptionIndicator(void);
void idxSetExceptionIndicator(int excind);
int  idxGetExitIndicator     (void);
void idxSetExitIndicator     (int extind);
idxErrorCallback_t idxGetErrorCallback(void);
void idxSetErrorCallback(idxErrorCallback_t func);
int  idxGetAPIErrorCount     (void);
void idxSetAPIErrorCount     (int ecnt);

void idxErrorHandling(const char *msg);
void idxInitMutexes(void);
void idxFiniMutexes(void);

#if defined(IDX_MAIN)    /* we must define some things only once */
# define IDX_FUNCPTR(NAME)  NAME##_t NAME = NULL
#else
# define IDX_FUNCPTR(NAME)  extern NAME##_t NAME
#endif

/* Prototypes for Dummy Functions */
int  IDX_CALLCONV d_idxGetLastError (idxHandle_t pidx);
void  IDX_CALLCONV d_idxErrorStr (idxHandle_t pidx, int ErrNr, char *ErrMsg, int ErrMsg_i);
int  IDX_CALLCONV d_idxOpenRead (idxHandle_t pidx, const char *FileName, int *ErrNr);
int  IDX_CALLCONV d_idxOpenWrite (idxHandle_t pidx, const char *FileName, const char *Producer, int *ErrNr);
int  IDX_CALLCONV d_idxClose (idxHandle_t pidx);
int  IDX_CALLCONV d_idxGetSymCount (idxHandle_t pidx, int *symCount);
int  IDX_CALLCONV d_idxGetSymbolInfo (idxHandle_t pidx, int iSym, char *symName, int symName_i, int *symDim, int dims[], int *nNZ, char *explText, int explText_i);
int  IDX_CALLCONV d_idxGetSymbolInfoByName (idxHandle_t pidx, const char *symName, int *iSym, int *symDim, int dims[], int *nNZ, char *explText, int explText_i);
int  IDX_CALLCONV d_idxGetIndexBase (idxHandle_t pidx);
int  IDX_CALLCONV d_idxSetIndexBase (idxHandle_t pidx, int idxBase);
int  IDX_CALLCONV d_idxDataReadStart (idxHandle_t pidx, const char *symName, int *symDim, int dims[], int *nRecs, char *ErrMsg, int ErrMsg_i);
int  IDX_CALLCONV d_idxDataRead (idxHandle_t pidx, int keys[], double *val, int *changeIdx);
int  IDX_CALLCONV d_idxDataReadDone (idxHandle_t pidx);
int  IDX_CALLCONV d_idxDataReadSparseColMajor (idxHandle_t pidx, int idxBase, int colPtr[], int rowIdx[], double vals[]);
int  IDX_CALLCONV d_idxDataReadSparseRowMajor (idxHandle_t pidx, int idxBase, int rowPtr[], int colIdx[], double vals[]);
int  IDX_CALLCONV d_idxDataReadDenseColMajor (idxHandle_t pidx, double vals[]);
int  IDX_CALLCONV d_idxDataReadDenseRowMajor (idxHandle_t pidx, double vals[]);
int  IDX_CALLCONV d_idxDataWriteStart (idxHandle_t pidx, const char *symName, const char *explTxt, int symDim, const int dims[], char *ErrMsg, int ErrMsg_i);
int  IDX_CALLCONV d_idxDataWrite (idxHandle_t pidx, const int keys[], double val);
int  IDX_CALLCONV d_idxDataWriteDone (idxHandle_t pidx);
int  IDX_CALLCONV d_idxDataWriteSparseColMajor (idxHandle_t pidx, const int colPtr[], const int rowIdx[], const double vals[]);
int  IDX_CALLCONV d_idxDataWriteSparseRowMajor (idxHandle_t pidx, const int rowPtr[], const int colIdx[], const double vals[]);
int  IDX_CALLCONV d_idxDataWriteDenseColMajor (idxHandle_t pidx, int dataDim, const double vals[]);
int  IDX_CALLCONV d_idxDataWriteDenseRowMajor (idxHandle_t pidx, int dataDim, const double vals[]);


typedef int  (IDX_CALLCONV *idxGetLastError_t) (idxHandle_t pidx);
/** Returns the last error number or 0 if there was no error. Calling this function will clear the last error stored.
 *
 * @param pidx idx object handle
 */
IDX_FUNCPTR(idxGetLastError);

typedef void  (IDX_CALLCONV *idxErrorStr_t) (idxHandle_t pidx, int ErrNr, char *ErrMsg, int ErrMsg_i);
/** Returns the text for a given error number. Always nonzero.
 *
 * @param pidx idx object handle
 * @param ErrNr Error number (gdxErrorStr)/Error code or zero if there is no error
 * @param ErrMsg Error text
 */
IDX_FUNCPTR(idxErrorStr);

typedef int  (IDX_CALLCONV *idxOpenRead_t) (idxHandle_t pidx, const char *FileName, int *ErrNr);
/** Open an existing gdx file for input. Nonzero if the file can be opened, 0 otherwise.
 *
 * @param pidx idx object handle
 * @param FileName File name of the gdx file to be opened
 * @param ErrNr Error number (gdxErrorStr)/Error code or zero if there is no error
 */
IDX_FUNCPTR(idxOpenRead);

typedef int  (IDX_CALLCONV *idxOpenWrite_t) (idxHandle_t pidx, const char *FileName, const char *Producer, int *ErrNr);
/** Open a new gdx file for output. Nonzero if the file can be opened, 0 otherwise.
 *
 * @param pidx idx object handle
 * @param FileName File name of the gdx file to be opened
 * @param Producer Name of program that appends to/creates the gdx file
 * @param ErrNr Error number (gdxErrorStr)/Error code or zero if there is no error
 */
IDX_FUNCPTR(idxOpenWrite);

typedef int  (IDX_CALLCONV *idxClose_t) (idxHandle_t pidx);
/** Close a gdx file that was previously opened for reading or writing. Any pending write operations will be finished before closing
 *
 * @param pidx idx object handle
 */
IDX_FUNCPTR(idxClose);

typedef int  (IDX_CALLCONV *idxGetSymCount_t) (idxHandle_t pidx, int *symCount);
/** Returns the number of indexed symbols in GDX
 *
 * @param pidx idx object handle
 * @param symCount 
 * @return 1 on success, 0 on failure
 */
IDX_FUNCPTR(idxGetSymCount);

typedef int  (IDX_CALLCONV *idxGetSymbolInfo_t) (idxHandle_t pidx, int iSym, char *symName, int symName_i, int *symDim, int dims[], int *nNZ, char *explText, int explText_i);
/** Get information for indexed symbols in GDX. Returns 1 on success, 0 on failure
 *
 * @param pidx idx object handle
 * @param iSym 
 * @param symName 
 * @param symDim 
 * @param dims 
 * @param nNZ 
 * @param explText Explanatory text for the symbol
 */
IDX_FUNCPTR(idxGetSymbolInfo);

typedef int  (IDX_CALLCONV *idxGetSymbolInfoByName_t) (idxHandle_t pidx, const char *symName, int *iSym, int *symDim, int dims[], int *nNZ, char *explText, int explText_i);
/** Get information for indexed symbols in GDX.
 *
 * @param pidx idx object handle
 * @param symName 
 * @param iSym 
 * @param symDim 
 * @param dims 
 * @param nNZ 
 * @param explText Explanatory text for the symbol
 * @return 1 on success, 0 on failure
 */
IDX_FUNCPTR(idxGetSymbolInfoByName);

typedef int  (IDX_CALLCONV *idxGetIndexBase_t) (idxHandle_t pidx);
/** the index base 0 or 1
 *
 * @param pidx idx object handle
 */
IDX_FUNCPTR(idxGetIndexBase);

typedef int  (IDX_CALLCONV *idxSetIndexBase_t) (idxHandle_t pidx, int idxBase);
/** Sets the index base 0 or 1.
 *
 * @param pidx idx object handle
 * @param idxBase 
 * @return 1 on success, 0 on failure
 */
IDX_FUNCPTR(idxSetIndexBase);

typedef int  (IDX_CALLCONV *idxDataReadStart_t) (idxHandle_t pidx, const char *symName, int *symDim, int dims[], int *nRecs, char *ErrMsg, int ErrMsg_i);
/** Initialize the reading of a symbol.
 *
 * @param pidx idx object handle
 * @param symName 
 * @param symDim 
 * @param dims 
 * @param nRecs 
 * @param ErrMsg Error text
 * @return 0 if the operation is not possible.
 */
IDX_FUNCPTR(idxDataReadStart);

typedef int  (IDX_CALLCONV *idxDataRead_t) (idxHandle_t pidx, int keys[], double *val, int *changeIdx);
/** Read the next record.
 *
 * @param pidx idx object handle
 * @param keys 
 * @param val 
 * @param changeIdx 
 * @return 0 if the operation is not possible.
 */
IDX_FUNCPTR(idxDataRead);

typedef int  (IDX_CALLCONV *idxDataReadDone_t) (idxHandle_t pidx);
/** Finish reading of a symbol.
 *
 * @param pidx idx object handle
 * @return 0 if the operation is not possible.
 */
IDX_FUNCPTR(idxDataReadDone);

typedef int  (IDX_CALLCONV *idxDataReadSparseColMajor_t) (idxHandle_t pidx, int idxBase, int colPtr[], int rowIdx[], double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param idxBase 
 * @param colPtr 
 * @param rowIdx 
 * @param vals 
 */
IDX_FUNCPTR(idxDataReadSparseColMajor);

typedef int  (IDX_CALLCONV *idxDataReadSparseRowMajor_t) (idxHandle_t pidx, int idxBase, int rowPtr[], int colIdx[], double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param idxBase 
 * @param rowPtr 
 * @param colIdx 
 * @param vals 
 */
IDX_FUNCPTR(idxDataReadSparseRowMajor);

typedef int  (IDX_CALLCONV *idxDataReadDenseColMajor_t) (idxHandle_t pidx, double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param vals 
 */
IDX_FUNCPTR(idxDataReadDenseColMajor);

typedef int  (IDX_CALLCONV *idxDataReadDenseRowMajor_t) (idxHandle_t pidx, double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param vals 
 */
IDX_FUNCPTR(idxDataReadDenseRowMajor);

typedef int  (IDX_CALLCONV *idxDataWriteStart_t) (idxHandle_t pidx, const char *symName, const char *explTxt, int symDim, const int dims[], char *ErrMsg, int ErrMsg_i);
/** Start writing a new symbol.
 *
 * @param pidx idx object handle
 * @param symName 
 * @param explTxt 
 * @param symDim 
 * @param dims 
 * @param ErrMsg Error text
 * @return 0 if the operation is not possible.
 */
IDX_FUNCPTR(idxDataWriteStart);

typedef int  (IDX_CALLCONV *idxDataWrite_t) (idxHandle_t pidx, const int keys[], double val);
/** Write a data element in raw mode. 0 if the operation is not possible.
 *
 * @param pidx idx object handle
 * @param keys 
 * @param val 
 */
IDX_FUNCPTR(idxDataWrite);

typedef int  (IDX_CALLCONV *idxDataWriteDone_t) (idxHandle_t pidx);
IDX_FUNCPTR(idxDataWriteDone);

typedef int  (IDX_CALLCONV *idxDataWriteSparseColMajor_t) (idxHandle_t pidx, const int colPtr[], const int rowIdx[], const double vals[]);
/** Returns 1 if OK, 0 if error
 *
 * @param pidx idx object handle
 * @param colPtr 
 * @param rowIdx 
 * @param vals 
 */
IDX_FUNCPTR(idxDataWriteSparseColMajor);

typedef int  (IDX_CALLCONV *idxDataWriteSparseRowMajor_t) (idxHandle_t pidx, const int rowPtr[], const int colIdx[], const double vals[]);
/** Returns 1 if OK, 0 if error
 *
 * @param pidx idx object handle
 * @param rowPtr 
 * @param colIdx 
 * @param vals 
 */
IDX_FUNCPTR(idxDataWriteSparseRowMajor);

typedef int  (IDX_CALLCONV *idxDataWriteDenseColMajor_t) (idxHandle_t pidx, int dataDim, const double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param dataDim 
 * @param vals 
 */
IDX_FUNCPTR(idxDataWriteDenseColMajor);

typedef int  (IDX_CALLCONV *idxDataWriteDenseRowMajor_t) (idxHandle_t pidx, int dataDim, const double vals[]);
/** Returns 1 for OK, 0 for error
 *
 * @param pidx idx object handle
 * @param dataDim 
 * @param vals 
 */
IDX_FUNCPTR(idxDataWriteDenseRowMajor);

#if defined(__cplusplus)
}
#endif
#endif /* #if ! defined(_IDXCC_H_) */

