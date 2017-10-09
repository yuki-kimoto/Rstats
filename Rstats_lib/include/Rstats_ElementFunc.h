#ifndef PERL_RSTATS_ELEMENTFUNC_H
#define PERL_RSTATS_ELEMENTFUNC_H

#include <cmath>

#include "Rstats_Util.h"

namespace Rstats {
  namespace ElementFunc {

    double add(double, double);
    int32_t add(int32_t, int32_t);

    double subtract(double, double);
    int32_t subtract(int32_t, int32_t);

    double multiply(double, double);
    int32_t multiply(int32_t, int32_t);

    double divide(double, double);
    double divide(int32_t, int32_t);

    double pow(double, double);
    double pow(int32_t, int32_t);

    double remainder(double, double);
    double remainder(int32_t, int32_t);

    double Re(double);
    double Re(int32_t);

    double Im(double);
    double Im(int32_t);

    double Conj(double);
    double Conj(int32_t);

    double sin(double);
    double sin(int32_t);
    
    double cos(double);
    double cos(int32_t);
    double cos(int32_t);

    double tan(double);
    double tan(int32_t);

    double sinh(double);
    double sinh(int32_t);
    double sinh(int32_t);

    double cosh(double);
    double cosh(int32_t);

    double tanh(double);
    double tanh(int32_t);
    double tanh(int32_t);

    double abs(double);
    double abs(int32_t);
    double abs(int32_t);

    double Mod(double);
    double Mod(int32_t);

    double log(double);
    double log(int32_t);
    double log(int32_t);

    double logb(double);
    double logb(int32_t);

    double log10(double);
    double log10(int32_t);
    double log10(int32_t);

    double log2(double);
    double log2(int32_t);
    
    double expm1(double);
    double expm1(int32_t);

    double Arg(double);
    double Arg(int32_t);
    double Arg(int32_t);

    double exp(double);
    double exp(int32_t);

    double sqrt(double);
    double sqrt(int32_t);

    double atan(double);
    double atan(int32_t);

    double asin(double);
    double asin(int32_t);

    double acos(double);
    double acos(int32_t);
    double acos(int32_t);

    double asinh(double);
    double asinh(int32_t);

    double acosh(double);
    double acosh(int32_t);

    double atanh(double);
    double atanh(int32_t);
    
    double neg(double);
    int32_t neg(int32_t);

    double atan2(double, double);
    double atan2(int32_t, int32_t);
    double atan2(int32_t, int32_t);

    int32_t And(double, double);
    int32_t And(int32_t, int32_t);

    int32_t Or(double, double);
    int32_t Or(int32_t, int32_t);
    
    int32_t equal(double, double);
    int32_t equal(int32_t, int32_t);

    int32_t not_equal(double, double);
    int32_t not_equal(int32_t, int32_t);

    int32_t more_than(double, double);
    int32_t more_than(int32_t, int32_t);

    int32_t less_than(double, double);
    int32_t less_than(int32_t, int32_t);

    int32_t more_than_or_equal(double, double);
    int32_t more_than_or_equal(int32_t, int32_t);

    int32_t less_than_or_equal(double, double);
    int32_t less_than_or_equal(int32_t, int32_t);

    int32_t is_infinite(double);
    int32_t is_infinite(int32_t);

    int32_t is_finite(double);
    int32_t is_finite(int32_t);

    int32_t is_nan(double);
    int32_t is_nan(int32_t);

    double as_double(double);
    double as_double(int32_t);

    int32_t as_int(double);
    int32_t as_int(int32_t);
  }
}

#endif
