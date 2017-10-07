#ifndef PERL_RSTATS_ELEMENTFUNC_H
#define PERL_RSTATS_ELEMENTFUNC_H

#include <cmath>

#include "Rstats_Util.h"

namespace Rstats {
  namespace ElementFunc {

    Rstats::Double add(Rstats::Double, Rstats::Double);
    Rstats::Integer add(Rstats::Integer, Rstats::Integer);

    Rstats::Double subtract(Rstats::Double, Rstats::Double);
    Rstats::Integer subtract(Rstats::Integer, Rstats::Integer);

    Rstats::Double multiply(Rstats::Double, Rstats::Double);
    Rstats::Integer multiply(Rstats::Integer, Rstats::Integer);

    Rstats::Double divide(Rstats::Double, Rstats::Double);
    Rstats::Double divide(Rstats::Integer, Rstats::Integer);

    Rstats::Double pow(Rstats::Double, Rstats::Double);
    Rstats::Double pow(Rstats::Integer, Rstats::Integer);

    Rstats::Double remainder(Rstats::Double, Rstats::Double);
    Rstats::Double remainder(Rstats::Integer, Rstats::Integer);

    Rstats::Double Re(Rstats::Double);
    Rstats::Double Re(Rstats::Integer);

    Rstats::Double Im(Rstats::Double);
    Rstats::Double Im(Rstats::Integer);

    Rstats::Double Conj(Rstats::Double);
    Rstats::Double Conj(Rstats::Integer);

    Rstats::Double sin(Rstats::Double);
    Rstats::Double sin(Rstats::Integer);
    
    Rstats::Double cos(Rstats::Double);
    Rstats::Double cos(Rstats::Integer);
    Rstats::Double cos(Rstats::Integer);

    Rstats::Double tan(Rstats::Double);
    Rstats::Double tan(Rstats::Integer);

    Rstats::Double sinh(Rstats::Double);
    Rstats::Double sinh(Rstats::Integer);
    Rstats::Double sinh(Rstats::Integer);

    Rstats::Double cosh(Rstats::Double);
    Rstats::Double cosh(Rstats::Integer);

    Rstats::Double tanh(Rstats::Double);
    Rstats::Double tanh(Rstats::Integer);
    Rstats::Double tanh(Rstats::Integer);

    Rstats::Double abs(Rstats::Double);
    Rstats::Double abs(Rstats::Integer);
    Rstats::Double abs(Rstats::Integer);

    Rstats::Double Mod(Rstats::Double);
    Rstats::Double Mod(Rstats::Integer);

    Rstats::Double log(Rstats::Double);
    Rstats::Double log(Rstats::Integer);
    Rstats::Double log(Rstats::Integer);

    Rstats::Double logb(Rstats::Double);
    Rstats::Double logb(Rstats::Integer);

    Rstats::Double log10(Rstats::Double);
    Rstats::Double log10(Rstats::Integer);
    Rstats::Double log10(Rstats::Integer);

    Rstats::Double log2(Rstats::Double);
    Rstats::Double log2(Rstats::Integer);
    
    Rstats::Double expm1(Rstats::Double);
    Rstats::Double expm1(Rstats::Integer);

    Rstats::Double Arg(Rstats::Double);
    Rstats::Double Arg(Rstats::Integer);
    Rstats::Double Arg(Rstats::Integer);

    Rstats::Double exp(Rstats::Double);
    Rstats::Double exp(Rstats::Integer);

    Rstats::Double sqrt(Rstats::Double);
    Rstats::Double sqrt(Rstats::Integer);

    Rstats::Double atan(Rstats::Double);
    Rstats::Double atan(Rstats::Integer);

    Rstats::Double asin(Rstats::Double);
    Rstats::Double asin(Rstats::Integer);

    Rstats::Double acos(Rstats::Double);
    Rstats::Double acos(Rstats::Integer);
    Rstats::Double acos(Rstats::Integer);

    Rstats::Double asinh(Rstats::Double);
    Rstats::Double asinh(Rstats::Integer);

    Rstats::Double acosh(Rstats::Double);
    Rstats::Double acosh(Rstats::Integer);

    Rstats::Double atanh(Rstats::Double);
    Rstats::Double atanh(Rstats::Integer);
    
    Rstats::Double negate(Rstats::Double);
    Rstats::Integer negate(Rstats::Integer);

    Rstats::Double atan2(Rstats::Double, Rstats::Double);
    Rstats::Double atan2(Rstats::Integer, Rstats::Integer);
    Rstats::Double atan2(Rstats::Integer, Rstats::Integer);

    Rstats::Integer And(Rstats::Character, Rstats::Character);
    Rstats::Integer And(Rstats::Double, Rstats::Double);
    Rstats::Integer And(Rstats::Integer, Rstats::Integer);

    Rstats::Integer Or(Rstats::Character, Rstats::Character);
    Rstats::Integer Or(Rstats::Double, Rstats::Double);
    Rstats::Integer Or(Rstats::Integer, Rstats::Integer);
    
    Rstats::Integer equal(Rstats::Character, Rstats::Character);
    Rstats::Integer equal(Rstats::Double, Rstats::Double);
    Rstats::Integer equal(Rstats::Integer, Rstats::Integer);

    Rstats::Integer not_equal(Rstats::Character, Rstats::Character);
    Rstats::Integer not_equal(Rstats::Double, Rstats::Double);
    Rstats::Integer not_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Integer more_than(Rstats::Character, Rstats::Character);
    Rstats::Integer more_than(Rstats::Double, Rstats::Double);
    Rstats::Integer more_than(Rstats::Integer, Rstats::Integer);

    Rstats::Integer less_than(Rstats::Character, Rstats::Character);
    Rstats::Integer less_than(Rstats::Double, Rstats::Double);
    Rstats::Integer less_than(Rstats::Integer, Rstats::Integer);

    Rstats::Integer more_than_or_equal(Rstats::Character, Rstats::Character);
    Rstats::Integer more_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Integer more_than_or_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Integer less_than_or_equal(Rstats::Character, Rstats::Character);
    Rstats::Integer less_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Integer less_than_or_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Integer is_infinite(Rstats::Character);
    Rstats::Integer is_infinite(Rstats::Double);
    Rstats::Integer is_infinite(Rstats::Integer);

    Rstats::Integer is_finite(Rstats::Character);
    Rstats::Integer is_finite(Rstats::Double);
    Rstats::Integer is_finite(Rstats::Integer);

    Rstats::Integer is_nan(Rstats::Character);
    Rstats::Integer is_nan(Rstats::Double);
    Rstats::Integer is_nan(Rstats::Integer);

    Rstats::Character as_character(Rstats::Character);
    Rstats::Character as_character(Rstats::Double);
    Rstats::Character as_character(Rstats::Integer);

    Rstats::Double as_double(Rstats::Character);
    Rstats::Double as_double(Rstats::Double);
    Rstats::Double as_double(Rstats::Integer);

    Rstats::Integer as_integer(Rstats::Character);
    Rstats::Integer as_integer(Rstats::Double);
    Rstats::Integer as_integer(Rstats::Integer);

    Rstats::Integer as_logical(Rstats::Character);
    Rstats::Integer as_logical(Rstats::Double);
    Rstats::Integer as_logical(Rstats::Integer);
  }
}

#endif
