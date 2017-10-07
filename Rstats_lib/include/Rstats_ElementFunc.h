#ifndef PERL_RSTATS_ELEMENTFUNC_H
#define PERL_RSTATS_ELEMENTFUNC_H

#include <cmath>

#include "Rstats_Util.h"

namespace Rstats {
  namespace ElementFunc {

    Rstats::Double add(Rstats::Double, Rstats::Double);
    int32_t add(int32_t, int32_t);

    Rstats::Double subtract(Rstats::Double, Rstats::Double);
    int32_t subtract(int32_t, int32_t);

    Rstats::Double multiply(Rstats::Double, Rstats::Double);
    int32_t multiply(int32_t, int32_t);

    Rstats::Double divide(Rstats::Double, Rstats::Double);
    Rstats::Double divide(int32_t, int32_t);

    Rstats::Double pow(Rstats::Double, Rstats::Double);
    Rstats::Double pow(int32_t, int32_t);

    Rstats::Double remainder(Rstats::Double, Rstats::Double);
    Rstats::Double remainder(int32_t, int32_t);

    Rstats::Double Re(Rstats::Double);
    Rstats::Double Re(int32_t);

    Rstats::Double Im(Rstats::Double);
    Rstats::Double Im(int32_t);

    Rstats::Double Conj(Rstats::Double);
    Rstats::Double Conj(int32_t);

    Rstats::Double sin(Rstats::Double);
    Rstats::Double sin(int32_t);
    
    Rstats::Double cos(Rstats::Double);
    Rstats::Double cos(int32_t);
    Rstats::Double cos(int32_t);

    Rstats::Double tan(Rstats::Double);
    Rstats::Double tan(int32_t);

    Rstats::Double sinh(Rstats::Double);
    Rstats::Double sinh(int32_t);
    Rstats::Double sinh(int32_t);

    Rstats::Double cosh(Rstats::Double);
    Rstats::Double cosh(int32_t);

    Rstats::Double tanh(Rstats::Double);
    Rstats::Double tanh(int32_t);
    Rstats::Double tanh(int32_t);

    Rstats::Double abs(Rstats::Double);
    Rstats::Double abs(int32_t);
    Rstats::Double abs(int32_t);

    Rstats::Double Mod(Rstats::Double);
    Rstats::Double Mod(int32_t);

    Rstats::Double log(Rstats::Double);
    Rstats::Double log(int32_t);
    Rstats::Double log(int32_t);

    Rstats::Double logb(Rstats::Double);
    Rstats::Double logb(int32_t);

    Rstats::Double log10(Rstats::Double);
    Rstats::Double log10(int32_t);
    Rstats::Double log10(int32_t);

    Rstats::Double log2(Rstats::Double);
    Rstats::Double log2(int32_t);
    
    Rstats::Double expm1(Rstats::Double);
    Rstats::Double expm1(int32_t);

    Rstats::Double Arg(Rstats::Double);
    Rstats::Double Arg(int32_t);
    Rstats::Double Arg(int32_t);

    Rstats::Double exp(Rstats::Double);
    Rstats::Double exp(int32_t);

    Rstats::Double sqrt(Rstats::Double);
    Rstats::Double sqrt(int32_t);

    Rstats::Double atan(Rstats::Double);
    Rstats::Double atan(int32_t);

    Rstats::Double asin(Rstats::Double);
    Rstats::Double asin(int32_t);

    Rstats::Double acos(Rstats::Double);
    Rstats::Double acos(int32_t);
    Rstats::Double acos(int32_t);

    Rstats::Double asinh(Rstats::Double);
    Rstats::Double asinh(int32_t);

    Rstats::Double acosh(Rstats::Double);
    Rstats::Double acosh(int32_t);

    Rstats::Double atanh(Rstats::Double);
    Rstats::Double atanh(int32_t);
    
    Rstats::Double negate(Rstats::Double);
    int32_t negate(int32_t);

    Rstats::Double atan2(Rstats::Double, Rstats::Double);
    Rstats::Double atan2(int32_t, int32_t);
    Rstats::Double atan2(int32_t, int32_t);

    int32_t And(Rstats::Double, Rstats::Double);
    int32_t And(int32_t, int32_t);

    int32_t Or(Rstats::Double, Rstats::Double);
    int32_t Or(int32_t, int32_t);
    
    int32_t equal(Rstats::Double, Rstats::Double);
    int32_t equal(int32_t, int32_t);

    int32_t not_equal(Rstats::Double, Rstats::Double);
    int32_t not_equal(int32_t, int32_t);

    int32_t more_than(Rstats::Double, Rstats::Double);
    int32_t more_than(int32_t, int32_t);

    int32_t less_than(Rstats::Double, Rstats::Double);
    int32_t less_than(int32_t, int32_t);

    int32_t more_than_or_equal(Rstats::Double, Rstats::Double);
    int32_t more_than_or_equal(int32_t, int32_t);

    int32_t less_than_or_equal(Rstats::Double, Rstats::Double);
    int32_t less_than_or_equal(int32_t, int32_t);

    int32_t is_infinite(Rstats::Double);
    int32_t is_infinite(int32_t);

    int32_t is_finite(Rstats::Double);
    int32_t is_finite(int32_t);

    int32_t is_nan(Rstats::Double);
    int32_t is_nan(int32_t);

    Rstats::Double as_double(Rstats::Double);
    Rstats::Double as_double(int32_t);

    int32_t as_integer(Rstats::Double);
    int32_t as_integer(int32_t);
  }
}

#endif
