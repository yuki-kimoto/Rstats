/* C++ library */
#include <vector>
#include <iostream>
#include <complex>
#include <map>
#include <limits>

/* Fix std::isnan problem in Windows */
#ifndef _isnan
#define _isnan isnan
#endif

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* suppress error - Cent OS(symbol collisions) */
#undef init_tm
#undef do_open
#undef do_close
#ifdef ENTER
#undef ENTER
#endif

/* suppress error - Mac OS X(error: declaration of 'Perl___notused' has a different language linkage) */
#ifdef __cplusplus
#  define dNOOP (void)0
#else
#  define dNOOP extern int Perl___notused(void)
#endif

#include "Rstats.h"
