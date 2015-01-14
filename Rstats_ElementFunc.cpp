#include <complex>
#include <cmath>
#include <limits>

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "Rstats.h"

// add
std::complex<NV> Rstats::ElementFunc::add(std::complex<NV> e1, std::complex<NV> e2) { return e1 + e2; }
NV Rstats::ElementFunc::add(NV e1, NV e2) { return e1 + e2; }
IV Rstats::ElementFunc::add(IV e1, IV e2) { return e1 + e2; }

// subtract
std::complex<NV> Rstats::ElementFunc::subtract(std::complex<NV> e1, std::complex<NV> e2) { return e1 - e2; }
NV Rstats::ElementFunc::subtract(NV e1, NV e2) { return e1 - e2; }
IV Rstats::ElementFunc::subtract(IV e1, IV e2) { return e1 - e2; }

// multiply
std::complex<NV> Rstats::ElementFunc::multiply(std::complex<NV> e1, std::complex<NV> e2) { return e1 * e2; }
NV Rstats::ElementFunc::multiply(NV e1, NV e2) { return e1 * e2; }
IV Rstats::ElementFunc::multiply(IV e1, IV e2) { return e1 * e2; }

// divide
std::complex<NV> Rstats::ElementFunc::divide(std::complex<NV> e1, std::complex<NV> e2) { return e1 / e2; }
NV Rstats::ElementFunc::divide(NV e1, NV e2) { return e1 / e2; }
NV Rstats::ElementFunc::divide(IV e1, IV e2) { return e1 / e2; }

// pow
std::complex<NV> Rstats::ElementFunc::pow(std::complex<NV> e1, std::complex<NV> e2) { return std::pow(e1, e2); }
NV Rstats::ElementFunc::pow(NV e1, NV e2) { return ::pow(e1, e2); }
NV Rstats::ElementFunc::pow(IV e1, IV e2) { return pow((NV)e1, (NV)e2); }

// reminder
std::complex<NV> Rstats::ElementFunc::reminder(std::complex<NV> e1, std::complex<NV> e2) {
  croak("unimplemented complex operation(Rstats::VectorFunc::reminder())");
}
NV Rstats::ElementFunc::reminder(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2) || e2 == 0) {
    return std::numeric_limits<NV>::signaling_NaN();
  }
  else {
    return e1 - std::floor(e1 / e2) * e2;
  }
}
IV Rstats::ElementFunc::reminder(IV e1, IV e2) {
  if (e2 == 0) {
    throw "0 divide exception\n";
  }
  return e1 % e2;
}

// Re
NV Rstats::ElementFunc::Re(std::complex<NV> e1) { return e1.real(); }
NV Rstats::ElementFunc::Re(NV e1) { return e1; }
NV Rstats::ElementFunc::Re(IV e1) { return e1; }

// Im
NV Rstats::ElementFunc::Im(std::complex<NV> e1) { return e1.imag(); }
NV Rstats::ElementFunc::Im(NV e1) { return 0; }
NV Rstats::ElementFunc::Im(IV e1) { return 0; }

// Conj
std::complex<NV> Rstats::ElementFunc::Conj(std::complex<NV> e1) { return std::complex<NV>(e1.real(), -e1.imag()); }
NV Rstats::ElementFunc::Conj(NV e1) { return e1; }
NV Rstats::ElementFunc::Conj(IV e1) { return e1; }

// sin
std::complex<NV> Rstats::ElementFunc::sin(std::complex<NV> e1) { return std::sin(e1); }
NV Rstats::ElementFunc::sin(NV e1) { return std::sin(e1); }
NV Rstats::ElementFunc::sin(IV e1) { return sin((NV)e1); }

// cos
std::complex<NV> Rstats::ElementFunc::cos(std::complex<NV> e1) { return std::cos(e1); }
NV Rstats::ElementFunc::cos(NV e1) { return std::cos(e1); }
NV Rstats::ElementFunc::cos(IV e1) { return cos((NV)e1); }

// tan
std::complex<NV> Rstats::ElementFunc::tan(std::complex<NV> e1) { return std::tan(e1); }
NV Rstats::ElementFunc::tan(NV e1) { return std::tan(e1); }
NV Rstats::ElementFunc::tan(IV e1) { return tan((NV)e1); }

// sinh
std::complex<NV> Rstats::ElementFunc::sinh(std::complex<NV> e1) { return std::sinh(e1); }
NV Rstats::ElementFunc::sinh(NV e1) { return std::sinh(e1); }
NV Rstats::ElementFunc::sinh(IV e1) { return sinh((NV)e1); }

// cosh
std::complex<NV> Rstats::ElementFunc::cosh(std::complex<NV> e1) { return std::cosh(e1); }
NV Rstats::ElementFunc::cosh(NV e1) { return std::cosh(e1); }
NV Rstats::ElementFunc::cosh(IV e1) { return cosh((NV)e1); }

// tanh
std::complex<NV> Rstats::ElementFunc::tanh (std::complex<NV> z) {
  NV re = z.real();
  
  // For fix FreeBSD bug
  // FreeBAD return (NaN + NaNi) when real value is negative infinite
  if (std::isinf(re) && re < 0) {
    return std::complex<NV>(-1, 0);
  }
  else {
    return std::tanh(z);
  }
}
NV Rstats::ElementFunc::tanh(NV e1) { return std::tanh(e1); }
NV Rstats::ElementFunc::tanh(IV e1) { return tanh((NV)e1); }

// abs
NV Rstats::ElementFunc::abs(std::complex<NV> e1) { return std::abs(e1); }
NV Rstats::ElementFunc::abs(NV e1) { return std::abs(e1); }
NV Rstats::ElementFunc::abs(IV e1) { return abs((NV)e1); }

// abs
NV Rstats::ElementFunc::Mod(std::complex<NV> e1) { return abs(e1); }
NV Rstats::ElementFunc::Mod(NV e1) { return abs(e1); }
NV Rstats::ElementFunc::Mod(IV e1) { return abs((NV)e1); }

// log
std::complex<NV> Rstats::ElementFunc::log(std::complex<NV> e1) { return std::log(e1); }
NV Rstats::ElementFunc::log(NV e1) { return std::log(e1); }
NV Rstats::ElementFunc::log(IV e1) { return log((NV)e1); }

// logb
std::complex<NV> Rstats::ElementFunc::logb(std::complex<NV> e1) { return log(e1); }
NV Rstats::ElementFunc::logb(NV e1) { return log(e1); }
NV Rstats::ElementFunc::logb(IV e1) { return log((NV)e1); }

// log10
std::complex<NV> Rstats::ElementFunc::log10(std::complex<NV> e1) { return std::log10(e1); }
NV Rstats::ElementFunc::log10(NV e1) { return std::log10(e1); }
NV Rstats::ElementFunc::log10(IV e1) { return std::log10((NV)e1); }

// log2
std::complex<NV> Rstats::ElementFunc::log2(std::complex<NV> e1) {
  return std::log(e1) / std::log(std::complex<NV>(2, 0));
}
NV Rstats::ElementFunc::log2(NV e1) {
  return std::log(e1) / std::log(2);
}
NV Rstats::ElementFunc::log2(IV e1) { return log2((NV)e1); }

std::complex<NV> Rstats::ElementFunc::expm1(std::complex<NV> e1) { croak("Error in expm1 : unimplemented complex function"); }
NV Rstats::ElementFunc::expm1(NV e1) { return ::expm1(e1); }
NV Rstats::ElementFunc::expm1(IV e1) { return expm1((NV)e1); }

// Arg
NV Rstats::ElementFunc::Arg(std::complex<NV> e1) {
  NV re = e1.real();
  NV im = e1.imag();
  
  if (re == 0 && im == 0) {
    return 0;
  }
  else {
    return ::atan2(im, re);
  }
}
NV Rstats::ElementFunc::Arg(NV e1) { croak("Error in Arg : unimplemented double function"); }
NV Rstats::ElementFunc::Arg(IV e1) { return Arg((NV)e1); }

// exp
std::complex<NV> Rstats::ElementFunc::exp(std::complex<NV> e1) { return std::exp(e1); }
NV Rstats::ElementFunc::exp(NV e1) { return std::exp(e1); }
NV Rstats::ElementFunc::exp(IV e1) { return exp((NV)e1); }

// sqrt
std::complex<NV> Rstats::ElementFunc::sqrt(std::complex<NV> e1) {
  // Fix bug that clang sqrt can't right value of perfect squeres
  if (e1.imag() == 0 && e1.real() < 0) {
    return std::complex<NV>(0, std::sqrt(-e1.real()));
  }
  else {
    return std::sqrt(e1);
  }
}
NV Rstats::ElementFunc::sqrt(NV e1) { return std::sqrt(e1); }
NV Rstats::ElementFunc::sqrt(IV e1) { return sqrt((NV)e1); }

// atan
std::complex<NV> Rstats::ElementFunc::atan(std::complex<NV> e1) {
  if (e1 == std::complex<NV>(0, 0)) {
    return std::complex<NV>(0, 0);
  }
  else if (e1 == std::complex<NV>(0, 1)) {
    return std::complex<NV>(0, INFINITY);
  }
  else if (e1 == std::complex<NV>(0, -1)) {
    return std::complex<NV>(0, -INFINITY);
  }
  else {  
    std::complex<NV> e2_i = std::complex<NV>(0, 1);
    std::complex<NV> e2_log = std::log((e2_i + e1) / (e2_i - e1));
    return (e2_i / std::complex<NV>(2, 0)) * e2_log;
  }
}
NV Rstats::ElementFunc::atan(NV e1) { return ::atan2(e1, 1); }
NV Rstats::ElementFunc::atan(IV e1) { return atan2((NV)e1, (NV)1); }

// asin
std::complex<NV> Rstats::ElementFunc::asin(std::complex<NV> e1) {
  NV e1_re = e1.real();
  NV e1_im = e1.imag();
  
  if (e1_re == 0 && e1_im == 0) {
    return std::complex<NV>(0, 0);
  }
  else {
    NV e2_t1 = std::sqrt(
      ((e1_re + 1) * (e1_re + 1))
      +
      (e1_im * e1_im)
    );
    NV e2_t2 = std::sqrt(
      ((e1_re - 1) * (e1_re - 1))
      +
      (e1_im * e1_im)
    );
    
    NV e2_alpha = (e2_t1 + e2_t2) / 2;
    NV e2_beta  = (e2_t1 - e2_t2) / 2;
    
    if (e2_alpha < 1) {
      e2_alpha = 1;
    }
    
    if (e2_beta > 1) {
      e2_beta = 1;
    }
    else if (e2_beta < -1) {
      e2_beta = -1;
    }
    
    NV e2_u = ::atan2(
      e2_beta,
      std::sqrt(1 - (e2_beta * e2_beta))
    );
    
    NV e2_v = -std::log(
      e2_alpha
      +
      std::sqrt((e2_alpha * e2_alpha) - 1)
    );
    
    if (e1_im > 0 || ((e1_im == 0) && (e1_re < -1))) {
      e2_v = -e2_v;
    }
    
    return std::complex<NV>(e2_u, e2_v);
  }
}
NV Rstats::ElementFunc::asin(NV e1) { return std::asin(e1); }
NV Rstats::ElementFunc::asin(IV e1) { return asin((NV)e1); }

// acos
std::complex<NV> Rstats::ElementFunc::acos(std::complex<NV> e1) {
  NV e1_re = e1.real();
  NV e1_im = e1.imag();
  
  if (e1_re == 1 && e1_im == 0) {
    return std::complex<NV>(0, 0);
  }
  else {
    NV e2_t1 = std::sqrt(
      ((e1_re + 1) * (e1_re + 1))
      +
      (e1_im * e1_im)
    );
    NV e2_t2 = std::sqrt(
      ((e1_re - 1) * (e1_re - 1))
      +
      (e1_im * e1_im)
    );
    
    NV e2_alpha = (e2_t1 + e2_t2) / 2;
    NV e2_beta  = (e2_t1 - e2_t2) / 2;
    
    if (e2_alpha < 1) {
      e2_alpha = 1;
    }
    
    if (e2_beta > 1) {
      e2_beta = 1;
    }
    else if (e2_beta < -1) {
      e2_beta = -1;
    }
    
    NV e2_u = ::atan2(
      std::sqrt(1 - (e2_beta * e2_beta)),
      e2_beta
    );
    
    NV e2_v = std::log(
      e2_alpha
      +
      std::sqrt((e2_alpha * e2_alpha) - 1)
    );
    
    if (e1_im > 0 || (e1_im == 0 && e1_re < -1)) {
      e2_v = -e2_v;
    }
    
    return std::complex<NV>(e2_u, e2_v);
  }
}
NV Rstats::ElementFunc::acos(NV e1) { return std::acos(e1); }
NV Rstats::ElementFunc::acos(IV e1) { return acos((NV)e1); }

// asinh
std::complex<NV> Rstats::ElementFunc::asinh(std::complex<NV> e1) {
  std::complex<NV> e2_t = (
    std::sqrt((e1 * e1) + std::complex<NV>(1, 0))
    +
    e1
  );
  
  return std::log(e2_t);
}
NV Rstats::ElementFunc::asinh(NV e1) {
  NV e2_t = (
    e1
    +
    std::sqrt((e1 * e1) + 1)
  );
  
  return std::log(e2_t);
}
NV Rstats::ElementFunc::asinh(IV e1) { return asinh((NV)e1); }

// acosh
std::complex<NV> Rstats::ElementFunc::acosh(std::complex<NV> e1) {
  NV e1_re = e1.real();
  NV e1_im = e1.imag();

  std::complex<NV> e2_t = (
    std::sqrt(
      (e1 * e1)
      -
      std::complex<NV>(1, 0)
    )
    +
    e1
  );
  std::complex<NV> e2_u = std::log(e2_t);
  NV e2_re = e2_u.real();
  NV e2_im = e2_u.imag();
  
  std::complex<NV> e2;
  if (e1_re < 0 && e1_im == 0) {
    e2 = std::complex<NV>(e2_re, -e2_im);
  }
  else {
    e2 = std::complex<NV>(e2_re, e2_im);
  }
  
  if (e1_re < 0) {
    return -e2;
  }
  else {
    return e2;
  }
}
NV Rstats::ElementFunc::acosh(NV e1) {
  if (e1 >= 1) {
    if (std::isinf(e1)) {
      warn("In acosh() : NaNs produced");
      return std::numeric_limits<NV>::signaling_NaN();
    }
    else {
      return std::log(
        e1
        +
        std::sqrt((e1 * e1) - 1)
      );
    }
  }
  else {
    warn("In acosh() : NaNs produced");
    return std::numeric_limits<NV>::signaling_NaN();
  }
}
NV Rstats::ElementFunc::acosh(IV e1) { return acosh((NV)e1); }

// atanh
std::complex<NV> Rstats::ElementFunc::atanh(std::complex<NV> e1) {
  if (e1 == std::complex<NV>(1, 0)) {
    warn("In atanh() : NaNs produced");
    return std::complex<NV>(INFINITY, std::numeric_limits<NV>::signaling_NaN());
  }
  else if (e1 == std::complex<NV>(-1, 0)) {
    warn("In atanh() : NaNs produced");
    return std::complex<NV>(-INFINITY, std::numeric_limits<NV>::signaling_NaN());
  }
  else {
    return std::complex<NV>(0.5, 0)
      *
      std::log(
        (std::complex<NV>(1, 0) + e1)
        /
        (std::complex<NV>(1, 0) - e1)
      );
  }
}
NV Rstats::ElementFunc::atanh(NV e1) {
  if (std::isinf(e1)) {
    warn("In acosh() : NaNs produced");
    return std::numeric_limits<NV>::signaling_NaN();
  }
  else {
    if (e1 == 1) {
      return INFINITY;
    }
    else if (e1 == -1) {
      return -INFINITY;
    }
    else if (std::abs(e1) < 1) {
      return std::log((1 + e1) / (1 - e1)) / 2;
    }
    else {
      warn("In acosh() : NaNs produced");
      return std::numeric_limits<NV>::signaling_NaN();
    }
  }
}
NV Rstats::ElementFunc::atanh(IV e1) { return atanh((NV)e1); }

// negation
std::complex<NV> Rstats::ElementFunc::negation(std::complex<NV> e1) { return -e1; }
NV Rstats::ElementFunc::negation(NV e1) { return -e1; }
IV Rstats::ElementFunc::negation(IV e1) { return -e1; }

// atan2
std::complex<NV> Rstats::ElementFunc::atan2(std::complex<NV> e1, std::complex<NV> e2) {
  std::complex<NV> e3_s = (e1 * e1) + (e2 * e2);
  if (e3_s == std::complex<NV>(0, 0)) {
    return std::complex<NV>(0, 0);
  }
  else {
    std::complex<NV> e3_i = std::complex<NV>(0, 1);
    std::complex<NV> e3_r = e2 + (e1 * e3_i);
    return -e3_i * std::log(e3_r / std::sqrt(e3_s));
  }
}
NV Rstats::ElementFunc::atan2(NV e1, NV e2) { ::atan2(e1, e2); }
NV Rstats::ElementFunc::atan2(IV e1, IV e2) { return atan2((NV)e1, (NV)e2); }

// And
IV Rstats::ElementFunc::And(SV* e1, SV* e2) { croak("operations are possible only for numeric, logical or complex types"); }
IV Rstats::ElementFunc::And(std::complex<NV> e1, std::complex<NV> e2) {
  if (e1 != std::complex<NV>(0, 0) && e2 != std::complex<NV>(0, 0)) { return 1; }
  else { return 0; }
}
IV Rstats::ElementFunc::And(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
  else { return e1 && e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::And(IV e1, IV e2) { return e1 && e2 ? 1 : 0; }

// Or
IV Rstats::ElementFunc::Or(SV* e1, SV* e2) { croak("operations are possible only for numeric, logical or complex types"); }
IV Rstats::ElementFunc::Or(std::complex<NV> e1, std::complex<NV> e2) {
  if (e1 != std::complex<NV>(0, 0) || e2 != std::complex<NV>(0, 0)) { return 1; }
  else { return 0; }
}
IV Rstats::ElementFunc::Or(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
  else { return e1 || e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::Or(IV e1, IV e2) { return e1 || e2 ? 1 : 0; }

// equal
IV Rstats::ElementFunc::equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) == 0 ? 1 : 0; }
IV Rstats::ElementFunc::equal(std::complex<NV> e1, std::complex<NV> e2) { return e1 == e2 ? 1 : 0; }
IV Rstats::ElementFunc::equal(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 == e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::equal(IV e1, IV e2) { return e1 == e2 ? 1 : 0; }

// not equal
IV Rstats::ElementFunc::not_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) != 0 ? 1 : 0; }
IV Rstats::ElementFunc::not_equal(std::complex<NV> e1, std::complex<NV> e2) { return e1 != e2 ? 1 : 0; }
IV Rstats::ElementFunc::not_equal(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 != e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::not_equal(IV e1, IV e2) { return e1 != e2 ? 1 : 0; }

// more_than
IV Rstats::ElementFunc::more_than(SV* e1, SV* e2) { return sv_cmp(e1, e2) > 0 ? 1 : 0; }
IV Rstats::ElementFunc::more_than(std::complex<NV> e1, std::complex<NV> e2) {
  croak("invalid comparison with complex values(more_than())");
}
IV Rstats::ElementFunc::more_than(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 > e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::more_than(IV e1, IV e2) { return e1 > e2 ? 1 : 0; }

// less_than
IV Rstats::ElementFunc::less_than(SV* e1, SV* e2) { return sv_cmp(e1, e2) < 0 ? 1 : 0; }
IV Rstats::ElementFunc::less_than(std::complex<NV> e1, std::complex<NV> e2) {
  croak("invalid comparison with complex values(less_than())");
}
IV Rstats::ElementFunc::less_than(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 < e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::less_than(IV e1, IV e2) { return e1 < e2 ? 1 : 0; }

// more_than_or_equal
IV Rstats::ElementFunc::more_than_or_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) >= 0 ? 1 : 0; }
IV Rstats::ElementFunc::more_than_or_equal(std::complex<NV> e1, std::complex<NV> e2) {
  croak("invalid comparison with complex values(more_than_or_equal())");
}
IV Rstats::ElementFunc::more_than_or_equal(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 >= e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::more_than_or_equal(IV e1, IV e2) { return e1 >= e2 ? 1 : 0; }

// less_than_or_equal
IV Rstats::ElementFunc::less_than_or_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) <= 0 ? 1 : 0; }
IV Rstats::ElementFunc::less_than_or_equal(std::complex<NV> e1, std::complex<NV> e2) {
  croak("invalid comparison with complex values(less_than_or_equal())");
}
IV Rstats::ElementFunc::less_than_or_equal(NV e1, NV e2) {
  if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
  else { return e1 <= e2 ? 1 : 0; }
}
IV Rstats::ElementFunc::less_than_or_equal(IV e1, IV e2) { return e1 <= e2 ? 1 : 0; }

// is_infinite
IV Rstats::ElementFunc::is_infinite(SV* e1) { return 0; }
IV Rstats::ElementFunc::is_infinite(std::complex<NV> e1) {
  if (std::isnan(e1.real()) || std::isnan(e1.imag())) {
    return 0;
  }
  else if (std::isinf(e1.real()) || std::isinf(e1.imag())) {
    return 1;
  }
  else {
    return 0;
  }
}
IV Rstats::ElementFunc::is_infinite(NV e1) { return std::isinf(e1); }
IV Rstats::ElementFunc::is_infinite(IV e1) { return 0; }

// is_finite
IV Rstats::ElementFunc::is_finite(SV* e1) { return 0; }
IV Rstats::ElementFunc::is_finite(std::complex<NV> e1) {
  if (std::isfinite(e1.real()) && std::isfinite(e1.imag())) {
    return 1;
  }
  else {
    return 0;
  }
}
IV Rstats::ElementFunc::is_finite(NV e1) { return std::isfinite(e1) ? 1 : 0; }
IV Rstats::ElementFunc::is_finite(IV e1) { return 1; }

// is_nan
IV Rstats::ElementFunc::is_nan(SV* e1) { return 0; }
IV Rstats::ElementFunc::is_nan(std::complex<NV> e1) {
  if (std::isnan(e1.real()) && std::isnan(e1.imag())) {
    return 1;
  }
  else {
    return 0;
  }
}
IV Rstats::ElementFunc::is_nan(NV e1) { return std::isnan(e1) ? 1 : 0; }
IV Rstats::ElementFunc::is_nan(IV e1) { return 1; }
