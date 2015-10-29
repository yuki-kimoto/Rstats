#ifndef PERL_RSTATS_VECTORFUNC_H
#define PERL_RSTATS_VECTORFUNC_H

#include "Rstats_Vector.h"

namespace Rstats {
  namespace VectorFunc {

    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_unary_math(T_OUT (*func)(T_IN), Rstats::Vector* v1);
    
    template <class T_IN>
    Rstats::Vector* operate_unary_is(Rstats::Logical (*func)(T_IN), Rstats::Vector* v1);
    
    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_unary_as(T_OUT (*func)(T_IN), Rstats::Vector* v1);
    
    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_binary_math(T_OUT (*func)(T_IN, T_IN), Rstats::Vector* v1, Rstats::Vector* v2);

    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_binary_compare(T_OUT (*func)(T_IN, T_IN), Rstats::Vector* v1, Rstats::Vector* v2);

    template <class T_IN>
    Rstats::Vector* equal(Rstats::Vector* v1, Rstats::Vector* v2);

    template <class T_IN, class T_OUT>
    Rstats::Vector* add(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* subtract(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* multiply(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* divide(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* pow(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* atan2(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* remainder(Rstats::Vector* v1, Rstats::Vector* v2);
    template <class T_IN, class T_OUT>
    Rstats::Vector* as_character(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* as_double(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* as_complex(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* as_integer(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* as_logical(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* sin(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* tanh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* cos(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* tan(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* sinh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* cosh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* log(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* logb(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* log10(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* log2(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* acos(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* acosh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* asinh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* atanh(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* Conj(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* asin(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* atan(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* sqrt(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* expm1(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* exp(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* negate(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* Arg(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* abs(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* Mod(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* Re(Rstats::Vector* v1);
    template <class T_IN, class T_OUT>
    Rstats::Vector* Im(Rstats::Vector* v1);
    
    template <class T_IN>
    Rstats::Vector* is_na(Rstats::Vector* v1);
    template <class T_IN>
    Rstats::Vector* is_infinite(Rstats::Vector* v1);
    template <class T_IN>
    Rstats::Vector* is_nan(Rstats::Vector* v1);
    template <class T_IN>
    Rstats::Vector* is_finite(Rstats::Vector* v1);
    
  }
}
#include "Rstats_VectorFunc_impl.h"

#endif
