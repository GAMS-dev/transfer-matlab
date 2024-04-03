/*
 * Main C code for indexed parameters in GDX
 * $Id$
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <float.h>

#include "gt_idx.h"

#if _XOPEN_SOURCE >= 600 || defined(_ISOC99_SOURCE) || _POSIX_C_SOURCE >= 200112L || defined(__APPLE__)
#define MY_IS_FINITE isfinite
#define MY_IS_NAN    isnan
#elif defined(_BSD_SOURCE)
#define MY_IS_FINITE finite
#define MY_IS_NAN    isnan
#elif defined(_MSC_VER)
#define MY_IS_FINITE _finite
#define MY_IS_NAN    _isnan
#define snprintf     _snprintf
#else
#define MY_IS_FINITE(x) ((x) == (x))
#define MY_IS_NAN(x)    (!((x) == (x)))
#endif

/* HACKASSERT means: we should probably do better than an assert here - have them independent on whether NDEBUG is defined */
#define HACKASSERT(x) do if (!(x)) { fprintf(stderr, "Error: " #x " failed in " __FILE__ " line %d\n", __LINE__); abort(); } while (0)
/* GOODASSERT means: we can't do much better */
#define GOODASSERT assert

typedef char shortStringBuf_t[GMS_SSSIZE];
typedef union rec64 {
  INT64 i64;
  double x;
} rec64_t;
rec64_t matnan;                 /* NaN returned by Matlab nan() */
rec64_t pinf;                   /* positive infinity */
rec64_t eps;                    /* GAMS EPS goes to eps.x */
rec64_t signBit;                /* sign bit */
rec64_t NAnan;                  /* unique NaN mapping to NA */

/* about error numbers:
 *  - 0 is "no error"
 *  - >0 is off limits
 *  - [-100000, -100200] or so is used by GDX
 *  - we will use [-500, -600]
 */

#define IDXERR_MAX             -500
#define IDXERR_NOFILE          -500
#define IDXERR_FILENAMETOOLONG -501
#define IDXERR_NOT2D           -502
#define IDXERR_MIN             -599

typedef enum writeState {
  prestart = 0,
  started,
  done
} writeState_t;

struct idxRec {
  gdxHandle_t h;
  double sVals[GMS_SVIDX_MAX];
  int currSymDims[GMS_MAX_INDEX_DIM];
  int *i2gSymMap;
  int *g2iSymMap;
  int currNRecs;
  int currSymDim;
  int currSymIdx;
  int writeState;
  int nSym;                   /* number of _indexed_ symbols in GDX */
  int lastError;
  int indexBase;                /* always 0 or 1 */
  shortStringBuf_t symName;
  shortStringBuf_t explTxt;
  gdxStrIndex_t domNames;
  gdxStrIndexPtrs_t domPtrs;
};


/* check for special values from user, convert to right values for GDX
 * assumed to be called with ih->sVals set up for writing to GDX
 */
static double
specCheck (idxHandle_t ih, double t)
{
  double tAbs;
  rec64_t r64;

  if (MY_IS_FINITE(t)) {
    if (0 == t)
      return 0.0;
    if (t > 0)
      tAbs = t;
    else
      tAbs = -t;
    if (tAbs <= eps.x)
      return eps.x;
    if (tAbs < GMS_SV_UNDEF)
      return t;
    if (t > 0)
      return ih->sVals[GMS_SVIDX_PINF];
    else
      return ih->sVals[GMS_SVIDX_MINF];
  }
  else if (MY_IS_NAN(t)) {
    r64.x = t;
    if (NAnan.i64 == r64.i64)
      return ih->sVals[GMS_SVIDX_NA];    /* NAnan  <--> NA */
    else
      return ih->sVals[GMS_SVIDX_UNDEF]; /* all other NaN <--> UNDEF */
  }
  else if (t > 0) {
    return ih->sVals[GMS_SVIDX_PINF];
  }
  return ih->sVals[GMS_SVIDX_MINF];
} /* specCheck */

/* set special values in ih and reset GDX to use those
 * for reading GDX, more special values get reset, since this is the only
 * translation layer we use.
 * for writing, the gdxSetSpecialValues call is not enough since we
 * want to map multiple values or ranges (e.g. 0 < x < DBL_MIN) into GDX
 */
static int
resetSV (idxHandle_t ih, int readMode)
{
  rec64_t r64;
  int rc;

  matnan.i64 = 0xfff80000;
  matnan.i64 = matnan.i64 << 32;
  pinf.i64 = 0x7ff00000;
  pinf.i64 = pinf.i64 << 32;
  eps.i64 = 0x00000001;           /* smallest denormalized double */
  eps.i64 = eps.i64 << 52;        /* smallest normalized double */
  signBit.i64 = 0x80000000;
  signBit.i64 = signBit.i64 << 32;
  NAnan.i64 = 0xffffffff;
  NAnan.i64 = NAnan.i64 << 32;
  NAnan.i64 |= 0xfffffffe;

  rc = gdxGetSpecialValues (ih->h, ih->sVals);
  if (! rc)
    return 0;
  if (readMode) {
    ih->sVals[GMS_SVIDX_UNDEF] = matnan.x;
    ih->sVals[GMS_SVIDX_NA] = NAnan.x;   /* signaling NaN */
  }
  ih->sVals[GMS_SVIDX_PINF] = pinf.x; /* +Inf */
  r64.i64 = pinf.i64 | signBit.i64;
  ih->sVals[GMS_SVIDX_MINF] = r64.x;  /* -Inf */
  ih->sVals[GMS_SVIDX_EPS] = eps.x;   /* EPS */
#if 0
#define GMS_SVIDX_NORMAL 5
#define GMS_SVIDX_ACR    6
#define GMS_SVIDX_MAX    7
#endif

  rc = gdxSetSpecialValues (ih->h, ih->sVals);
  return rc;
} /* resetSV */

static int
getLastErrorMessage (gdxHandle_t h, char msg[], int msgSize, int rc)
{
  int lastError;
  shortStringBuf_t s;

  lastError = gdxGetLastError (h);
  (void) gdxErrorStr (NULL, lastError, s);
  strncpy (msg, s, msgSize);
  msg[msgSize-1] = '\0';
  return rc;
} /* getLastErrorMessage */

static int
setError (idxHandle_t ih, int e)
{
  if (! ih->lastError) {        /* no error so store this one */
    /* if we could check for GDX error without clearing it we would */
    ih->lastError = e;
  }
  return e;
} /* setError */


/* return of 1 is good, 0 bad */
int
idxCreate (idxHandle_t *ih, char msgBuf[], int msgBufSize)
{
  int rc;

  (void) snprintf (msgBuf, msgBufSize, "idxCreate is not yet implemented: try again later");
  msgBuf[msgBufSize-1] = '\0';
  msgBuf[0] = '\0';
  if (! ih) {
    snprintf (msgBuf, msgBufSize, "Pointer to handle is NULL");
    return 0;
  }
  *ih = (idxHandle_t) malloc (sizeof(**ih));
  if (! *ih) {
    snprintf (msgBuf, msgBufSize, "malloc failure, memory exhausted");
    return 0;
  }
  (void) memset (*ih, 0, sizeof(**ih));
  (*ih)->currNRecs = -1;
  (*ih)->currSymDim = -1;
  (*ih)->currSymIdx = -1;
  (*ih)->nSym = -1;
  (*ih)->indexBase = 1;

  rc = gdxCreate (&((*ih)->h), msgBuf, msgBufSize);
  return rc;
} /* idxCreate */

int
idxFree (idxHandle_t *ih)
{
  int rc;

  rc = gdxFree (&((*ih)->h));
  free (*ih);
  return rc;
} /* idxFree */

/* idxGetLastError: return the most recently stored error
 * works like gdxGetLastError and WinAPI getLastError: the first
 * error encountered after the error state is initialized/reset is stored.
 * Calling this function retrieves that error and resets/clears
 * the error state
 */
int
idxGetLastError (idxHandle_t ih)
{
  int r;

  if (ih->lastError) {
    /* return the error after clearing the error state */
    r = ih->lastError;
    (void) gdxGetLastError (ih->h);
    return r;
  }
  return gdxGetLastError (ih->h);
} /* idxGetLastError */

/* idxErrorStr: convert an IDX error number to a string
 * the handle is not used but we have the arg for API consistency
 */
void
idxErrorStr (idxHandle_t ih, int lastError, char errMsg[], int errMsgSize)
{
  shortStringBuf_t s;

  switch (lastError) {
  case IDXERR_NOFILE:
    strcpy (s, "Empty file name");
    break;
  case IDXERR_FILENAMETOOLONG:
    strcpy (s, "File name too long (> 255 chars)");
    break;
  case IDXERR_NOT2D:
    strcpy (s, "Symbol must be 2-dimensional");
    break;
  default:
    (void) gdxErrorStr (NULL, lastError, s);
  } /* switch */
  strncpy (errMsg, s, errMsgSize);
  errMsg[errMsgSize-1] = '\0';
} /* idxErrorStr */

/* idxOpenRead: open GDX file for reading
 * return: 0 on failure to open
 *         1 on successful open
 */
int
idxOpenRead (idxHandle_t ih, const char fileName[], int *errNum)
{
  int n, rc;

  if (! fileName) {
    *errNum = setError (ih, IDXERR_NOFILE);
    return 0;
  }
  n = strlen(fileName);
  if (n > 255) {
    *errNum = setError (ih, IDXERR_FILENAMETOOLONG);
    return 0;
  }

  *errNum = 0;
  rc = gdxOpenRead (ih->h, fileName, errNum);
  if (! rc)
    return rc;
  if (! resetSV (ih, 1)) {
    *errNum = gdxGetLastError (ih->h);
    return 0;
  }

  GDXSTRINDEXPTRS_INIT (ih->domNames, ih->domPtrs);
  return 1;                     /* success */
} /* idxOpenRead */

/* idxOpenWrite: open GDX file for writing
 * return: 0 on failure to open
 *         1 on successful open
 */
int
idxOpenWrite (idxHandle_t ih, const char fileName[],
              const char producer[], int *errNum)
{
  int n, rc;

  if (! fileName) {
    *errNum = setError (ih, IDXERR_NOFILE);
    return 0;
  }
  n = strlen(fileName);
  if (n > 255) {
    *errNum = setError (ih, IDXERR_FILENAMETOOLONG);
    return 0;
  }

  *errNum = 0;
  rc = gdxOpenWrite (ih->h, fileName, producer, errNum);
  if (! rc)
    return rc;
  gdxStoreDomainSetsSet(ih->h,0);
  if (! resetSV (ih, 0)) {
    *errNum = gdxGetLastError (ih->h);
    return 0;
  }

  return 1;
} /* idxOpenWrite */

int
idxClose (idxHandle_t ih)
{
  int rc;

  rc = gdxClose (ih->h);
  if (ih->lastError) {
    rc = ih->lastError;
    ih->lastError = 0;
  }
  return rc;
} /* idxClose */


/* check if symbol gSym is an indexed parameter
 * gSym in [1..symCount]
 * return 1 on success, 0 on failure
 */
static int
getSymInfo (idxHandle_t ih, int gSym, shortStringBuf_t symName,
            int *symDim, int dims[], int *nNZ, char text[], int textSiz,
            int *isIndexed)
{
  int iDim, symType, rc, i;
  shortStringBuf_t tmpStr;
  char prefix[8];

  *isIndexed = 0;
  if (! gdxSymbolInfo (ih->h, gSym, symName, symDim, &symType))
    return 0;                   /* fail */
  if (GMS_DT_PAR != symType)
    return 1;                   /* success */
  if (*symDim > 0) {             /* check the domains */
    rc = gdxSymbolGetDomainX (ih->h, gSym, ih->domPtrs);
    if (! ((2 == rc) || (3 == rc))) /* no domain info found */
      return 1;
    for (iDim = 0;  iDim < *symDim;  iDim++) {
      strncpy (prefix, ih->domPtrs[iDim], 7);
      prefix[7] = '\0';
      rc = strcmp (prefix, "d_i_m__");
      if (rc)
        return 1;
      strncpy (tmpStr, ih->domPtrs[iDim]+7, GMS_SSSIZE);
      i = strtol (tmpStr, NULL, 10);
      if (i < 0)
        return 1;
      if (dims)
        dims[iDim] = i;
    }
  }
  *isIndexed = 1;

  if (nNZ) {
    *nNZ = -1;
  }
  if ((textSiz > 0) && text) {
    *text = '\0';
  }
  if (nNZ || ((textSiz > 0) && text)) {
    int nRecs, dummy;
    if (! gdxSymbolInfoX (ih->h, gSym, &nRecs, &dummy, tmpStr))
      return 0;                 /* fail */
    if (nNZ) {
      *nNZ = nRecs;
    }
    if ((textSiz > 0) && text) {
      strncpy (text, tmpStr, textSiz);
      text[textSiz-1] = '\0';
    }
  }
  return 1;
} /* getSymInfo */

/* return 1 on success, 0 on failure */
int
idxGetSymCount (idxHandle_t ih, int *symCount)
{
  shortStringBuf_t sName;
  int gSym, nSym, dummy;
  int n, isIndexed;

  if (NULL==ih->i2gSymMap) {
    *symCount = -1;
    (void) gdxSystemInfo (ih->h, &nSym, &dummy);
    ih->i2gSymMap = (int*) malloc((nSym+1)*sizeof(int));
    ih->g2iSymMap = (int*) malloc((nSym+1)*sizeof(int));
    (void) memset (ih->i2gSymMap, 0, (nSym+1)*sizeof(int));
    (void) memset (ih->g2iSymMap, 0, (nSym+1)*sizeof(int));
    for (n = 0, gSym = 1;  gSym <= nSym;  gSym++) {
      if (! getSymInfo (ih, gSym, sName, &dummy,
                        NULL, NULL, NULL, 0, &isIndexed))
        return 0;
      if (isIndexed) {
        ih->i2gSymMap[n++] = gSym; /* 1-based GDX symbol index */
        ih->g2iSymMap[gSym-1] = n; /* 1-based IDX symbol index */
      }
    }
    ih->nSym = *symCount = n;
  }
  else
    *symCount = ih->nSym;
  return 1;
} /* idxGetSymCount */


/* idxGetSymbolInfo: get information for indexed symbols in GDX
 * return 1 on success, 0 on failure
 */
int
idxGetSymbolInfo (idxHandle_t ih, int iSym, char symName[], int symNameSiz,
                  int *symDim, int dims[GMS_MAX_INDEX_DIM],
                  int *nNZ, char explText[], int explTextSiz)
{
  shortStringBuf_t sName;
  int gSym;                     /* index in GDX space */
  int rc, isIndexed, symCount;

  symName[0] = '\0';
  *symDim = -1;
  if (nNZ)
    *nNZ = 0;
  if (explText && explTextSiz > 0)
    explText[0] = '\0';

  if (! idxGetSymCount(ih, &symCount))
    return 0;

  GOODASSERT (ih->nSym >= 0);
  if ((iSym < 0) || (iSym >= ih->nSym))
    return 0;

  gSym = ih->i2gSymMap[iSym];
  GOODASSERT(gSym > 0);
  rc = getSymInfo (ih, gSym, sName, symDim, dims, nNZ, explText, explTextSiz, &isIndexed);
  GOODASSERT(rc);
  GOODASSERT(isIndexed);
  strncpy (symName, sName, symNameSiz);
  symName[symNameSiz-1] = '\0';
  return 1;                     /* success */
} /* idxGetSymbolInfo */

/* idxGetSymbolInfoByName: get information for indexed symbols in GDX
 * return 1 on success, 0 on failure
 */
int
idxGetSymbolInfoByName (idxHandle_t ih, const char symName[], int *iSym,
                  int *symDim, int dims[GMS_MAX_INDEX_DIM],
                  int *nNZ, char explText[], int explTextSiz)
{
  shortStringBuf_t sName;
  int gSym;                     /* index in GDX space */
  int rc, isIndexed, symCount;

  *symDim = -1;
  if (nNZ)
    *nNZ = 0;
  if (explText && explTextSiz > 0)
    explText[0] = '\0';
  *iSym = -1;
  if (! idxGetSymCount(ih, &symCount))
    return 0;

  GOODASSERT (ih->nSym >= 0);
  /* check if the symbol exists */
  rc = gdxFindSymbol (ih->h, symName, &gSym);
  if (!rc || (0==ih->g2iSymMap[gSym-1]))
    return 0;

  *iSym = ih->g2iSymMap[gSym-1];
  GOODASSERT(*iSym > 0);
  rc = getSymInfo (ih, gSym, sName, symDim, dims, nNZ, explText, explTextSiz, &isIndexed);
  GOODASSERT(rc);
  GOODASSERT(isIndexed);
  return 1;                     /* success */
} /* idxGetSymbolInfoByName */

/* return the indexBase (0 or 1) used, or -1 on error */
int
idxGetIndexBase (idxHandle_t ih)
{
  return ih->indexBase;
} /* idxGetIndexBase */

/* set the indexBase (0 or 1) used.  Return: 1 if OK, 0 if error */
int
idxSetIndexBase (idxHandle_t ih, int indexBase)
{
  switch (indexBase) {
  case 0:
  case 1:
    ih->indexBase = indexBase;
    break;
  default:
    return 0;                   /* error */
  }
  return 1;                     /* OK */
} /* idxSetIndexBase */


/* idxDataReadStart:
 * Lots to verify:
 *   - symbol exists
 *   - symbol is a parameter
 *   - relaxed domain info available, and param names are "d_i_m__X"
 * return:  1 is good
 *          0 is bad
 */
int
idxDataReadStart (idxHandle_t ih, const char symName[], int *symDim,
                  int dims[GMS_MAX_INDEX_DIM], int *nRecs,
                  char errMsg[], int errMsgSize)
{
  int rc;
  int symIdx;
  int iDim, symType;
  int i;
  shortStringBuf_t sName;
  shortStringBuf_t intStr;
  char prefix[8];

  for (iDim = 0;  iDim < GLOBAL_MAX_INDEX_DIM;  iDim++)
    strcpy (ih->domPtrs[iDim], "*");
  errMsg[0] = '\0';

  /* check if the symbol exists */
  rc = gdxFindSymbol (ih->h, symName, &symIdx);
  if (! rc) {
    snprintf (errMsg, errMsgSize, "GDX contains no symbol named '%s'", symName);
    return 0;
  }
  rc = gdxSymbolInfo (ih->h, symIdx, sName, symDim, &symType);
  if (!rc)
    return getLastErrorMessage (ih->h, errMsg, errMsgSize, 0);
  if (GMS_DT_PAR != symType) {
    snprintf (errMsg, errMsgSize, "symbol '%s' is not a parameter", symName);
    return 0;
  }
  if (*symDim > 0) {
    rc = gdxSymbolGetDomainX (ih->h, symIdx, ih->domPtrs);
    /* rc=1: no domain info available */
    /* rc=2: relaxed domain info available: typical for indexed GDX */
    /* rc=3: full domain info available */
    if (! ((2 == rc) || (3 == rc))) { /* no domain info found */
      snprintf (errMsg, errMsgSize,
                "symbol '%s' is not an indexed parameter: no domain info", symName);
      return 0;
    }
    for (iDim = 0;  iDim < *symDim;  iDim++) {
      strncpy (prefix, ih->domPtrs[iDim], 7);
      prefix[7] = '\0';
      rc = strcmp (prefix, "d_i_m__");
      if (rc) {
        snprintf (errMsg, errMsgSize,
                  "symbol '%s' is not an indexed parameter: invalid domain info", symName);
        return 0;
      }
      strncpy (intStr, ih->domPtrs[iDim]+7, GMS_SSSIZE);
      i = strtol (intStr, NULL, 10);
      if (i < 0) {
        snprintf (errMsg, errMsgSize,
                  "symbol '%s' is not an indexed parameter: invalid domain info", symName);
        return 0;
      }
      /* printf (" dim %d: %d\n", iDim, i); */
      ih->currSymDims[iDim] = dims[iDim] = i;
    }
  }
  rc = gdxDataReadRawStart (ih->h, symIdx, nRecs);
  if (! rc)
    return getLastErrorMessage (ih->h, errMsg, errMsgSize, 0);
  ih->currNRecs = *nRecs;
  ih->currSymDim = *symDim;
  ih->currSymIdx = symIdx;
  return 1;                     /* OK */
} /* idxDataReadStart */


int
idxDataRead (idxHandle_t ih, int keys[GMS_MAX_INDEX_DIM], double *val, int *changeIdx)
{
  gdxValues_t values;
  int iDim, rc;

  rc = gdxDataReadRaw (ih->h, keys, values, changeIdx);
  *val = values[0];

#if 0
  for (iDim = 0;  iDim < ih->currSymDim;  iDim++)
    GOODASSERT(keys[iDim] <= ih->currSymDims[iDim]);
#endif

  if (0 == ih->indexBase)
    for (iDim = 0;  iDim < ih->currSymDim;  iDim++)
      keys[iDim]--;

  return rc;
} /* idxDataRead */

int
idxDataReadDone (idxHandle_t ih)
{
  int rc;

  ih->currNRecs = -1;
  ih->currSymDim = -1;
  ih->currSymIdx = -1;
  rc = gdxDataReadDone (ih->h);
  return rc;
} /* idxDataReadDone */

/* idxDataReadSparseColMajor: read a 2-d array into
 * sparse column-major storage,
 * returning colPtr[n+1], rowIdx[nnz], vals[nnz]
 * return 1 on success, 0 on failure
 */
int
idxDataReadSparseColMajor (idxHandle_t ih, int idxBase,
                           int colPtr[], int rowIdx[], double vals[])
{
  int *tp;                      /* counts/ptrs to cols */
  gdxValues_t values;
  int n;
  int i, j, k, dummy;
  int iRecs, rc;
  int keys[GMS_MAX_INDEX_DIM];

  if (2!=ih->currSymDim) {
    (void) setError (ih, IDXERR_NOT2D);
    return 0;
  }
  n = ih->currSymDims[1];
  tp = (int *) malloc ( n*sizeof(int));
  HACKASSERT(tp);
  (void) memset (tp, 0, n*sizeof(int));

  /* first trip through: compute col counts */
  for (iRecs = 0;  iRecs < ih->currNRecs;  iRecs++) {
    (void) gdxDataReadRaw (ih->h, keys, values, &dummy);
    j = keys[1]-1;
    tp[j]++;
  } /* counting loop */
  if (! gdxDataReadDone (ih->h))
    return 0;
  if (! gdxDataReadRawStart (ih->h, ih->currSymIdx, &dummy))
    return 0;
  GOODASSERT(dummy==ih->currNRecs);

  for (k = 0, j = 0;  j < n;  j++) {
    colPtr[j] = k;              /* 0-based for now */
    k += tp[j];
    tp[j] = colPtr[j];
  }
  colPtr[j] = k;

  for (iRecs = 0;  iRecs < ih->currNRecs;  iRecs++) {
    (void) gdxDataReadRaw (ih->h, keys, values, &dummy);
    i = keys[0]-1;
    j = keys[1]-1;
    k = tp[j];
    rowIdx[k] = i + idxBase;
    vals[k] = values[0];
    tp[j]++;
  } /* data transfer loop */

  for (j = 0;  j < n;  j++) {
    GOODASSERT(colPtr[j+1] == tp[j]);
    colPtr[j] += idxBase;
  }
  colPtr[j] += idxBase;
  free(tp);
  rc = idxDataReadDone (ih);
  return rc;
} /* idxDataReadSparseColMajor */

/* idxDataReadSparseRowMajor: read a 2-d array into sparse row-major storage,
 * returning rowPtr[m+1], colIdx[nnz], vals[nnz]
 * return: 1 if OK, 0 if error
 */
int
idxDataReadSparseRowMajor (idxHandle_t ih, int idxBase,
                           int rowPtr[], int colIdx[], double vals[])
{
  gdxValues_t values;
  int i, iNext;                 /* both 0-based */
  int j, k, m, n, dummy;
  int iRecs;
  int keys[GMS_MAX_INDEX_DIM];

  if (2!=ih->currSymDim) {
    (void) setError (ih, IDXERR_NOT2D);
    return 0;
  }
  m = ih->currSymDims[0];
  n = ih->currSymDims[1];
  /* printf ("DEBUG readSparseRowMajor:  m=%d  n=%d\n", m, n); */
  k = 0;
  iNext = 0;
  rowPtr[iNext++] = k + idxBase;
  if (0 == m) {
    idxDataReadDone (ih);
    return 1;
  }
  for (iRecs = 0;  iRecs < ih->currNRecs;  iRecs++) {
    gdxDataReadRaw (ih->h, keys, values, &dummy);
    i = keys[0]-1;
    j = keys[1]-1;
    /* printf ("  k=%d  i=%d  j=%d\n", iRecs,i,j); */
    GOODASSERT(i < m);
    GOODASSERT(j < n);
    GOODASSERT((i+1) >= iNext);
    while (iNext <= i)
      rowPtr[iNext++] = k + idxBase;
    colIdx[k] = j + idxBase;
    vals[k] = values[0];
    k++;
  }
  GOODASSERT(k==ih->currNRecs);
  GOODASSERT(iNext <= m);
  for ( ;  iNext <= m;  iNext++)
    rowPtr[iNext] = k + idxBase;

  idxDataReadDone (ih);
  return 1;
} /* idxDataReadSparseRowMajor */

/* idxDataReadDenseColMajor: read an array into dense column-major storage,
 * return: 1 for OK, 0 for error
 */
int
idxDataReadDenseColMajor (idxHandle_t ih, double vals[])
{
  double dNNZ;
  gdxValues_t values;
  int iDim, iRecs, dummy, rc;
  int k;
  int symDim = ih->currSymDim;
  int keys[GMS_MAX_INDEX_DIM];

  if (0 == symDim) {
    if (! gdxDataReadRaw (ih->h, keys, values, &dummy))
      return 0;
    *vals = values[0];
  }
  else {
    for (dNNZ = 1.0, iDim = 0;  iDim < symDim;  iDim++)
      dNNZ *= ih->currSymDims[iDim];
    HACKASSERT (dNNZ <= INT_MAX);

    for (iRecs = 0;  iRecs < ih->currNRecs;  iRecs++) {
      rc = gdxDataReadRaw (ih->h, keys, values, &dummy);
      HACKASSERT(rc);
      for (k = keys[symDim-1]-1, iDim = symDim-2;  iDim >= 0;  iDim--)
        k = k*ih->currSymDims[iDim] + (keys[iDim] - 1);
      /* printf (" %d.%d.%d %2d  %g\n", keys[0], keys[1], keys[2], k, values[0]); */
      vals[k] = values[0];
    }
  }

  rc = idxDataReadDone (ih);
  return rc;
} /* idxDataReadDenseColMajor */

/* idxDataReadDenseRowMajor: read an array into dense row-major storage,
 * return: 1 for OK, 0 for error
 */
int
idxDataReadDenseRowMajor (idxHandle_t ih, double vals[])
{
  double dNNZ;
  gdxValues_t values;
  int iDim, iRecs, dummy, rc;
  int k;
  int symDim = ih->currSymDim;
  int keys[GMS_MAX_INDEX_DIM];

  if (0 == symDim) {
    rc = gdxDataReadRaw (ih->h, keys, values, &dummy);
    HACKASSERT(rc);
    *vals = values[0];
  }
  else {
    for (dNNZ = 1.0, iDim = 0;  iDim < symDim;  iDim++)
      dNNZ *= ih->currSymDims[iDim];
    HACKASSERT (dNNZ <= INT_MAX);

    for (iRecs = 0;  iRecs < ih->currNRecs;  iRecs++) {
      rc = gdxDataReadRaw (ih->h, keys, values, &dummy);
      HACKASSERT(rc);
      for (k = keys[0]-1, iDim = 1;  iDim < symDim;  iDim++)
        k = k*ih->currSymDims[iDim] + keys[iDim] - 1;
      vals[k] = values[0];
    }
  }

  rc = idxDataReadDone (ih);
  return rc;
} /* idxDataReadDenseRowMajor */

/* idxDataWriteStart
 * return: 1 is good, 0 is bad
 */
int
idxDataWriteStart (idxHandle_t ih, const char symName[], const char explTxt[],
                   int symDim, const int dims[GMS_MAX_INDEX_DIM],
                   shortStringBuf_t errMsg, int errMsgSize)
{
  int rc;
  int symIdx;
  int i, iDim;
  int oldMax, newMax, dummy;
  shortStringBuf_t buf;

  i = (int) strlen(symName);
  if (i >= GMS_SSSIZE) {
    snprintf (errMsg, errMsgSize, "input symName has length %d: maximum is %d", i, GMS_SSSIZE-1);
    return 0;
  }
  strcpy (ih->symName, symName);

  strncpy (ih->explTxt, explTxt, GMS_SSSIZE);
  ih->explTxt[GMS_SSSIZE-1] = '\0';

  GDXSTRINDEXPTRS_INIT (ih->domNames, ih->domPtrs);

  /* check if the symbol exists already */
  rc = gdxFindSymbol (ih->h, symName, &symIdx);
  if (rc) {
    snprintf (errMsg, errMsgSize, "Symbol '%s' already written to GDX",
              symName);
    return 0;
  }
  if (symDim > GLOBAL_MAX_INDEX_DIM) {
    snprintf (errMsg, errMsgSize, "Symbol dimension %d exceeds limit of %d",
              symDim, GLOBAL_MAX_INDEX_DIM);
    return 0;
  }
  for (newMax = 0, iDim = 0;  iDim < symDim;  iDim++) {
    if (dims[iDim] < 0) {
      snprintf (errMsg, errMsgSize, "Symbol dim(%d) must be non-negative, was %d",
                iDim+1, dims[iDim]);
      return 0;
    }
    ih->currSymDims[iDim] = dims[iDim];
    if (dims[iDim] > newMax)
      newMax = dims[iDim];
    sprintf (ih->domPtrs[iDim], "d_i_m__%d", dims[iDim]);
  }
  ih->currSymDim = symDim;

  rc = gdxUMUelInfo (ih->h, &oldMax, &dummy);
  HACKASSERT(rc);

  if (newMax > oldMax) {
    rc = gdxUELRegisterRawStart (ih->h);
    if (! rc)
      return gdxGetLastError (ih->h);
    for (i = oldMax+1;  i <= newMax;  i++) {
      sprintf (buf, "%d", i);
      rc = gdxUELRegisterRaw (ih->h, buf);
      HACKASSERT(rc);
      if (! rc)
        return gdxGetLastError (ih->h);
    }
    rc = gdxUELRegisterDone (ih->h);
    if (! rc)
      return gdxGetLastError (ih->h);
  }

  ih->writeState = prestart;
  /* defer DataWriteXxxStart call until we know if Xxx = Raw or Map */
  return 1;
} /* idxDataWriteStart */

int
idxDataWrite (idxHandle_t ih, const int keys[GMS_MAX_INDEX_DIM], double val)
{
  gdxValues_t values;
  int iDim, rc;
  int k2[GMS_MAX_INDEX_DIM];

  if (prestart == ih->writeState) {
    rc = gdxDataWriteRawStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
    HACKASSERT(rc);
    rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
    HACKASSERT(rc);
    rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
    HACKASSERT(rc);
    ih->writeState = started;
  }

  for (iDim = 0;  iDim < ih->currSymDim;  iDim++)
    GOODASSERT(keys[iDim] <= ih->currSymDims[iDim]);
  values[GMS_VAL_LEVEL] = specCheck (ih,  val);

  if (0 == ih->indexBase) {
    for (iDim = 0;  iDim < ih->currSymDim;  iDim++)
      k2[iDim] = keys[iDim]+1;
    rc = gdxDataWriteRaw (ih->h, k2, values);
  }
  else {
    rc = gdxDataWriteRaw (ih->h, keys, values);
  }

  return rc;
} /* idxDataWrite */

int
idxDataWriteDone (idxHandle_t ih)
{
  int rc;

  rc = 0;                       /* error */
  if (prestart == ih->writeState) {
    rc = gdxDataWriteRawStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
    HACKASSERT(rc);
    rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
    HACKASSERT(rc);
    rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
    HACKASSERT(rc);
    ih->writeState = started;
  }

  ih->currNRecs = -1;
  ih->currSymDim = -1;
  ih->currSymIdx = -1;

  if (done != ih->writeState) {
    rc = gdxDataWriteDone (ih->h);
    ih->writeState = done;
  }
  else {
    rc = 1;                     /* OK */
  }
  return rc;
} /* idxDataWriteDone */

/* idxDataWriteSparseColMajor: write a 2-d array from sparse col-major storage
 * colPtr[n+1], rowIdx[nnz], vals[nnz]
 * return: 1 if OK, 0 if error
 */
int
idxDataWriteSparseColMajor (idxHandle_t ih, const int colPtr[],
                            const int rowIdx[], const double vals[])
{
  int idxBase;
  int MM;                       /* max indices we'll see */
  int j, k, m, n, rc;
  int keys[GMS_MAX_INDEX_DIM];
  gdxValues_t values;
  shortStringBuf_t buf;

  HACKASSERT (prestart == ih->writeState);

  idxBase = colPtr[0];
  HACKASSERT((0==idxBase) || (1==idxBase));
#if 0
  HACKASSERT(2==ih->currSymDim);
#else
  /* if currSymDim > 2, we just use 1 for dims following the second */
  /* if you want to write with currSymDim < 2, do not use this call */
  HACKASSERT(ih->currSymDim >= 2);
#endif
  m = ih->currSymDims[0];
  n = ih->currSymDims[1];
  MM = (n > m) ? n : m;
  rc = gdxUELRegisterMapStart (ih->h);
  HACKASSERT(rc);
  for (k = 1;  k <= MM;  k++) {
    sprintf (buf, "%d", k);
    rc = gdxUELRegisterMap (ih->h, k, buf);
    HACKASSERT(rc);
  }
  rc = gdxUELRegisterDone (ih->h);
  HACKASSERT(rc);

  rc = gdxDataWriteMapStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
  HACKASSERT(rc);
  rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
  HACKASSERT(rc);
  rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
  HACKASSERT(rc);

  for (k = 2;  k < ih->currSymDim;  k++)
    keys[k] = 1;

  for (j = 0;  j < n;  j++) {
    keys[1] = j+1;
    for (k = colPtr[j]-idxBase;  k < colPtr[j+1]-idxBase;  k++) {
      keys[0] = rowIdx[k] + 1 - idxBase;
      HACKASSERT(keys[0] <= m);
      values[0] = specCheck (ih,  vals[k]);
      rc = gdxDataWriteMap (ih->h, keys, values);
      HACKASSERT(rc);
    }
  }
  rc = gdxDataWriteDone (ih->h);
  HACKASSERT(rc);
  ih->writeState = done;

  rc = idxDataWriteDone (ih);
  return rc;
} /* idxDataWriteSparseColMajor */

/* idxDataWriteSparseRowMajor: write a 2-d array from sparse row-major storage
 * rowPtr[m+1], colIdx[nnz], vals[nnz]
 * return: 1 if OK, 0 if error
 */
int
idxDataWriteSparseRowMajor (idxHandle_t ih, const int rowPtr[],
                            const int colIdx[], const double vals[])
{
  int idxBase;
  int i, k, m, n, rc;
  int keys[GMS_MAX_INDEX_DIM];
  gdxValues_t values;

  HACKASSERT (prestart == ih->writeState);
  rc = gdxDataWriteRawStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
  HACKASSERT(rc);
  rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
  HACKASSERT(rc);
  rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
  HACKASSERT(rc);

  idxBase = rowPtr[0];
  HACKASSERT((0==idxBase) || (1==idxBase));
#if 0
  HACKASSERT(2==ih->currSymDim);
#else
  /* if currSymDim > 2, we just use 1 for dims following the second */
  /* if you want to write with currSymDim < 2, do not use this call */
  HACKASSERT(ih->currSymDim >= 2);
#endif
  m = ih->currSymDims[0];
  n = ih->currSymDims[1];

  for (k = 2;  k < ih->currSymDim;  k++)
    keys[k] = 1;

  for (i = 0;  i < m;  i++) {
    keys[0] = i+1;
    for (k = rowPtr[i]-idxBase;  k < rowPtr[i+1]-idxBase;  k++) {
      keys[1] = colIdx[k] + 1 - idxBase;
      HACKASSERT(keys[1] <= n);
      values[0] = specCheck (ih,  vals[k]);
      rc = gdxDataWriteRaw (ih->h, keys, values);
      HACKASSERT(rc);
    }
  }
  rc = gdxDataWriteDone (ih->h);
  HACKASSERT(rc);
  ih->writeState = done;

  rc = idxDataWriteDone (ih);
  return rc;
} /* idxDataWriteSparseRowMajor */

/* return: 1 for OK, 0 for error */
int
idxDataWriteDenseColMajor (idxHandle_t ih, int dataDim, const double vals[])
{
  double dNNZ;
  gdxValues_t values;
  const double *v = vals;
  shortStringBuf_t buf;
  int k;
  int iDim, nnz, rc;
  int MM;                       /* max indices we'll see */
  int symDim = ih->currSymDim;
  int keys[GMS_MAX_INDEX_DIM];

  /* if symDim > dataDim,
   *   we use keys=1 for symbol dims following the last data dim
   * else if symDim == dataDim,
   *   usual case, nothing special
   * else if symDim < dataDim
   *   do not use this call
   */
  HACKASSERT(symDim >= dataDim);
  for (iDim = 0;  iDim < symDim;  iDim++)
    keys[iDim] = 1;

  if (0 == dataDim) {
    HACKASSERT (prestart == ih->writeState);
    rc = gdxDataWriteRawStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
    HACKASSERT(rc);
    rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
    HACKASSERT(rc);
    rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
    HACKASSERT(rc);
    values[0] = specCheck (ih,  *vals);
    rc = gdxDataWriteRaw (ih->h, keys, values);
    HACKASSERT(rc);
  }
  else {
    for (dNNZ = 1.0, iDim = 0;  iDim < dataDim;  iDim++)
      dNNZ *= ih->currSymDims[iDim];
    HACKASSERT (dNNZ <= INT_MAX);

    nnz = (int) dNNZ;
    for (MM = 1, iDim = 0;  iDim < dataDim;  iDim++) {
      if (ih->currSymDims[iDim] > MM)
        MM = ih->currSymDims[iDim];
    }
    rc = gdxUELRegisterMapStart (ih->h);
    HACKASSERT(rc);
    for (k = 1;  k <= MM;  k++) {
      sprintf (buf, "%d", k);
      rc = gdxUELRegisterMap (ih->h, k, buf);
      HACKASSERT(rc);
    }
    rc = gdxUELRegisterDone (ih->h);
    HACKASSERT(rc);

    HACKASSERT (prestart == ih->writeState);
    rc = gdxDataWriteMapStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
    HACKASSERT(rc);
    rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
    HACKASSERT(rc);
    rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
    HACKASSERT(rc);

    for (k = 0;  k < nnz;  k++) {
      if (0 != *v) {
        values[0] = specCheck (ih,  *v);
        rc = gdxDataWriteMap (ih->h, keys, values);
        HACKASSERT(rc);
      }
      v++;
      for (iDim = 0;  iDim < dataDim;  iDim++) {
        keys[iDim]++;
        if (keys[iDim] > ih->currSymDims[iDim]) {
          keys[iDim] = 1;
        }
        else {
          break;
        }
      }
    }
    GOODASSERT(nnz==(v-vals));
    for (iDim = 0;  iDim < symDim;  iDim++)
      GOODASSERT(1==keys[iDim]);
  } /* dataDim > 0 */

  rc = gdxDataWriteDone (ih->h);
  HACKASSERT(rc);
  ih->writeState = done;

  rc = idxDataWriteDone (ih);
  return rc;
} /* idxDataWriteDenseColMajor */

/* return: 1 for OK, 0 for error */
int
idxDataWriteDenseRowMajor (idxHandle_t ih, int dataDim, const double vals[])
{
  double dNNZ;
  gdxValues_t values;
  const double *v = vals;
  int k;
  int iDim, nnz, rc;
  int symDim = ih->currSymDim;
  int keys[GMS_MAX_INDEX_DIM];

  /* if symDim > dataDim,
   *   we use keys=1 for symbol dims following the last data dim
   * else if symDim == dataDim,
   *   usual case, nothing special
   * else if symDim < dataDim
   *   do not use this call
   */
  HACKASSERT(symDim >= dataDim);
  for (iDim = 0;  iDim < symDim;  iDim++)
    keys[iDim] = 1;

  HACKASSERT (prestart == ih->writeState);
  rc = gdxDataWriteRawStart (ih->h, ih->symName, ih->explTxt, ih->currSymDim, dt_par, 0);
  HACKASSERT(rc);
  rc = gdxFindSymbol (ih->h, ih->symName, &(ih->currSymIdx));
  HACKASSERT(rc);
  rc = gdxSymbolSetDomainX (ih->h, ih->currSymIdx, (const char **) ih->domPtrs);
  HACKASSERT(rc);

  if (0 == dataDim) {
    values[0] = specCheck (ih,  *vals);
    rc = gdxDataWriteRaw (ih->h, keys, values);
    HACKASSERT(rc);
  }
  else {
    for (dNNZ = 1.0, iDim = 0;  iDim < dataDim;  iDim++)
      dNNZ *= ih->currSymDims[iDim];
    HACKASSERT (dNNZ <= INT_MAX);

    nnz = (int) dNNZ;
    for (k = 0;  k < nnz;  k++) {
      if (0 != *v) {
        values[0] = specCheck (ih,  *v);
        rc = gdxDataWriteRaw (ih->h, keys, values);
        HACKASSERT(rc);
      }
      v++;
      for (iDim = dataDim-1;  iDim >= 0;  iDim--) {
        keys[iDim]++;
        if (keys[iDim] > ih->currSymDims[iDim]) {
          keys[iDim] = 1;
        }
        else {
          break;
        }
      }
    }
    for (iDim = 0;  iDim < symDim;  iDim++)
      GOODASSERT(1==keys[iDim]);
    GOODASSERT(nnz==(v-vals));
  } /* symDim > 0 */

  rc = gdxDataWriteDone (ih->h);
  HACKASSERT(rc);
  ih->writeState = done;

  rc = idxDataWriteDone (ih);
  return rc;
} /* idxDataWriteDenseRowMajor */

