#ifndef PERL_RSTATS_UTIL_H
#define PERL_RSTATS_UTIL_H

#include <limits>
#include "Rstats_Main.h"

namespace Rstats {
  namespace Util {
    int32_t is_perl_number(SV*);
    SV* cross_product(SV*);
    SV* pos_to_index(SV*, SV*);
    SV* index_to_pos(SV*, SV*);
    SV* looks_like_na(SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double(SV*);
    double pi();
    double Inf();
    double NaN();
    int32_t is_Inf(double);
    int32_t is_NaN(double);
  }
}

#endif
