/*
 * API header for indexed parameters in GDX
 * $Id$
 */

#if ! defined(_IDX_H_)
#     define  _IDX_H_

#ifdef HAS_GDX_SOURCE
#define NO_SET_LOAD_PATH_DEF
#include "gdxcwrap.hpp"
#else
#include "gdxcc.h"
#endif
#include "gclgms.h"

struct idxRec;
typedef struct idxRec *idxHandle_t;
typedef struct idxRec idxRec_t;

#if defined(__cplusplus)
extern "C" {
#endif

  /* return of 1 is good, 0 bad */
  int
  idxCreate (idxHandle_t *ih, char msgBuf[], int msgBufSize);

  int
  idxFree (idxHandle_t *ih);

  int
  idxGetLastError (idxHandle_t ih);

  void
  idxErrorStr (idxHandle_t ih, int lastError, char errMsg[], int errMsgSize);

  /* idxOpenRead: open GDX file for reading
   * return: 0 on failure to open
   *         1 on successful open
   */
  int
  idxOpenRead (idxHandle_t ih, const char fileName[], int *errNum);

  int
  idxOpenWrite (idxHandle_t ih, const char fileName[],
                const char producer[], int *errNum);
  int
  idxClose (idxHandle_t ih);

  /* return 1 on success, 0 on failure */
  int
  idxGetSymCount (idxHandle_t ih, int *symCount);

  /* idxGetSymbolInfo: get information for indexed symbols in GDX
   * return 1 on success, 0 on failure
   */
  int
  idxGetSymbolInfo (idxHandle_t ih, int iSym, char symName[], int symNameSiz,
                    int *symDim, int dims[GMS_MAX_INDEX_DIM],
                    int *nNZ, char explText[], int explTextSiz);

  /* idxGetSymbolInfoByName: get information for indexed symbols in GDX
   * return 1 on success, 0 on failure
   */
  int
  idxGetSymbolInfoByName (idxHandle_t ih, const char symName[], int *iSym,
                    int *symDim, int dims[GMS_MAX_INDEX_DIM],
                    int *nNZ, char explText[], int explTextSiz);

  /* return the indexBase (0 or 1) used, or -1 on error */
  int
  idxGetIndexBase (idxHandle_t ih);

  /* set the indexBase (0 or 1) used.  Return: 1 if OK, 0 if error */
  int
  idxSetIndexBase (idxHandle_t ih, int indexBase);

  /* return: 1 if OK, 0 if error */
  int
  idxDataReadStart (idxHandle_t ih, const char symName[], int *symDim,
                    int dims[GMS_MAX_INDEX_DIM], int *nRecs,
                    char errMsg[], int errMsgSize);

  /* return: 1 is good, 0 is bad  */
  int
  idxDataRead (idxHandle_t ih, int keys[GMS_MAX_INDEX_DIM], double *val,
               int *changeIdx);

  int
  idxDataReadDone (idxHandle_t ih);

  int
  idxDataReadSparseColMajor (idxHandle_t ih, int idxBase,
                             int colPtr[], int rowIdx[], double vals[]);

  int
  idxDataReadSparseRowMajor (idxHandle_t ih, int idxBase,
                             int rowPtr[], int colIdx[], double vals[]);

  /* return: 1 for OK, 0 for error */
  int
  idxDataReadDenseColMajor (idxHandle_t ih, double vals[]);

  /* return: 1 for OK, 0 for error */
  int
  idxDataReadDenseRowMajor (idxHandle_t ih, double vals[]);

  /* return: 1 is good, 0 is bad  */
  int
  idxDataWriteStart (idxHandle_t ih, const char symName[], const char explTxt[],
                     int symDim, const int dims[GMS_MAX_INDEX_DIM],
                     char errMsg[], int errMsgSize);

  int
  idxDataWrite (idxHandle_t ih, const int keys[GMS_MAX_INDEX_DIM], double val);

  int
  idxDataWriteDone (idxHandle_t ih);

  /* return: 1 if OK, 0 if error */
  int
  idxDataWriteSparseColMajor (idxHandle_t ih, const int colPtr[],
                              const int rowIdx[], const double vals[]);

  /* return: 1 if OK, 0 if error */
  int
  idxDataWriteSparseRowMajor (idxHandle_t ih, const int rowPtr[],
                              const int colIdx[], const double vals[]);

  /* return: 1 for OK, 0 for error */
  int
  idxDataWriteDenseColMajor (idxHandle_t ih, int dataDim, const double vals[]);

  /* return: 1 for OK, 0 for error */
  int
  idxDataWriteDenseRowMajor (idxHandle_t ih, int dataDim, const double vals[]);

#if defined(__cplusplus)
}
#endif

#endif /* #if ! defined(_IDX_H_) */
