#ifndef PERL_RSTATS_UTIL_H
#define PERL_RSTATS_UTIL_H

#include <limits>
#include "Rstats_Main.h"

namespace Rstats {
  namespace Util {
    Rstats::Integer is_perl_number(SV*);
    SV* cross_product(SV*);
    SV* pos_to_index(SV*, SV*);
    SV* index_to_pos(SV*, SV*);
    SV* looks_like_logical(SV*);
    SV* looks_like_na(SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double(SV*);
    Rstats::Double pi();
    Rstats::Double Inf();
    Rstats::Double NaN();
    Rstats::Integer is_Inf(Rstats::Double);
    Rstats::Integer is_NaN(Rstats::Double);
  }
}

#endif
