#include "Rstats_ElementFunc.h"

// Rstats::ElementFunc
namespace Rstats {
  namespace ElementFunc {
    
    /* Note:
      In ElementFunction, croak method should't be called.
      If you want to tell warnings, use Rstats::add_warn function.
      Rstats::clear_warn function should't be called.
      If you want to tell NA introduced, throw Rstats::NaException.
    */
    
    // add
    double add(double e1, double e2) { return e1 + e2; }
    int32_t add(int32_t e1, int32_t e2) { return e1 + e2; }
    
    // subtract
    double subtract(double e1, double e2) { return e1 - e2; }
    int32_t subtract(int32_t e1, int32_t e2) { return e1 - e2; }
    
    // multiply
    double multiply(double e1, double e2) { return e1 * e2; }
    int32_t multiply(int32_t e1, int32_t e2) { return e1 * e2; }

    // divide
    double divide(double e1, double e2) { return e1 / e2; }
    double divide(int32_t e1, int32_t e2) {
      return Rstats::ElementFunc::divide((double)e1, (double)e2);
    }
    
    // pow
    double pow(double e1, double e2) { return ::pow(e1, e2); }
    double pow(int32_t e1, int32_t e2) {
      return Rstats::ElementFunc::pow((double)e1, (double)e2);
    }

    // remainder
    double remainder(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2) || e2 == 0) {
        return Rstats::Util::NaN();
      }
      else {
        return fmod(e1, e2);;
      }
    }
    double remainder(int32_t e1, int32_t e2) {
      return Rstats::ElementFunc::remainder((double) e1, (double) e2);
    }

    // Re
    double Re(double e1) { return e1; }
    double Re(int32_t e1) { return Rstats::ElementFunc::Re((double)e1); }

    // Im
    double Im(double e1) { return 0; }
    double Im(int32_t e1) { return Rstats::ElementFunc::Im((double)e1); }

    // Conj
    double Conj(double e1) { return e1; }
    double Conj(int32_t e1) { return Rstats::ElementFunc::Conj((double)e1); }

    // sin
    double sin(double e1) { return std::sin(e1); }
    double sin(int32_t e1) { return Rstats::ElementFunc::sin((double)e1); }

    // cos
    double cos(double e1) { return std::cos(e1); }
    double cos(int32_t e1) { return Rstats::ElementFunc::cos((double)e1); }

    // tan
    double tan(double e1) { return std::tan(e1); }
    double tan(int32_t e1) { return Rstats::ElementFunc::tan((double)e1); }

    // sinh
    double sinh(double e1) { return std::sinh(e1); }
    double sinh(int32_t e1) { return Rstats::ElementFunc::sinh((double)e1); }

    // cosh
    double cosh(double e1) { return std::cosh(e1); }
    double cosh(int32_t e1) { return Rstats::ElementFunc::cosh((double)e1); }

    double tanh(double e1) { return std::tanh(e1); }
    double tanh(int32_t e1) { return Rstats::ElementFunc::tanh((double)e1); }

    // abs
    double abs(double e1) { return std::abs(e1); }
    double abs(int32_t e1) { return Rstats::ElementFunc::abs((double)e1); }

    // abs
    double Mod(double e1) { return abs(e1); }
    double Mod(int32_t e1) { return Rstats::ElementFunc::abs((double)e1); }

    // log
    double log(double e1) { return std::log(e1); }
    double log(int32_t e1) { return Rstats::ElementFunc::log((double)e1); }

    // logb
    double logb(double e1) { return log(e1); }
    double logb(int32_t e1) { return Rstats::ElementFunc::log((double)e1); }

    // log10
    double log10(double e1) { return std::log10(e1); }
    double log10(int32_t e1) { return Rstats::ElementFunc::log10((double)e1); }

    // log2
    double log2(double e1) {
      return std::log(e1) / std::log((double)2);
    }
    double log2(int32_t e1) { return Rstats::ElementFunc::log2((double)e1); }
    
    // expm1
    double expm1(double e1) { return ::expm1(e1); }
    double expm1(int32_t e1) { return Rstats::ElementFunc::expm1((double)e1); }

    // Arg
    double Arg(double e1) {
      if (Rstats::Util::is_NaN(e1)) {
        return Rstats::Util::NaN();
      }
      else if (e1 >= 0) {
        return 0;
      }
      else {
        return Rstats::Util::pi();
      }
    }
    double Arg(int32_t e1) { return Rstats::ElementFunc::Arg((double)e1); }
    
    // exp
    double exp(double e1) { return std::exp(e1); }
    double exp(int32_t e1) { return Rstats::ElementFunc::exp((double)e1); }

    // sqrt
    double sqrt(double e1) { return std::sqrt(e1); }
    double sqrt(int32_t e1) { return Rstats::ElementFunc::sqrt((double)e1); }

    // atan
    double atan(double e1) { return ::atan2(e1, 1); }
    double atan(int32_t e1) { return Rstats::ElementFunc::atan2((double)e1, (double)1); }

    // asin
    double asin(double e1) { return std::asin(e1); }
    double asin(int32_t e1) { return Rstats::ElementFunc::asin((double)e1); }

    // acos
    double acos(double e1) { return std::acos(e1); }
    double acos(int32_t e1) { return Rstats::ElementFunc::acos((double)e1); }

    // asinh
    double asinh(double e1) {
      double e2_t = (
        e1
        +
        std::sqrt((e1 * e1) + 1)
      );
      
      return std::log(e2_t);
    }
    double asinh(int32_t e1) { return Rstats::ElementFunc::asinh((double)e1); }

    // acosh

    double acosh(double e1) {
      if (e1 >= 1) {
        if (Rstats::Util::is_Inf(e1)) {
          Rstats::add_warn(Rstats::WARN_NAN_PRODUCED);
          return Rstats::Util::NaN();
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
        Rstats::add_warn(Rstats::WARN_NAN_PRODUCED);
        return Rstats::Util::NaN();
      }
    }
    double acosh(int32_t e1) { return Rstats::ElementFunc::acosh((double)e1); }

    // atanh
    double atanh(double e1) {
      if (Rstats::Util::is_Inf(e1)) {
        Rstats::add_warn(Rstats::WARN_NAN_PRODUCED);
        return Rstats::Util::NaN();
      }
      else {
        if (e1 == 1) {
          return Rstats::Util::Inf();
        }
        else if (e1 == -1) {
          return -Rstats::Util::Inf();
        }
        else if (std::abs(e1) < 1) {
          return std::log((1 + e1) / (1 - e1)) / 2;
        }
        else {
          Rstats::add_warn(Rstats::WARN_NAN_PRODUCED);
          return Rstats::Util::NaN();
        }
      }
    }
    double atanh(int32_t e1) { return Rstats::ElementFunc::atanh((double)e1); }

    // neg
    double neg(double e1) { return -e1; }
    int32_t neg(int32_t e1) { return -e1; }

    // atan2
    double atan2(double e1, double e2) {
      if (Rstats::Util::is_Inf(e1) && Rstats::Util::is_Inf(e2)) {
        if (e1 > 0 && e2 > 0) {
          return (Rstats::Util::pi() / 4);
        }
        else if (e1 > 0 && e2 < 0) {
          return ((3 * Rstats::Util::pi()) / 4);
        }
        else if (e1 < 0 && e2 > 0) {
          return -(Rstats::Util::pi() / 4);
        }
        else {
          return -((3 * Rstats::Util::pi()) / 4);
        }
      }
      else {
        return ::atan2(e1, e2);
      }
    }
    double atan2(int32_t e1, int32_t e2) {
      return Rstats::ElementFunc::atan2((double)e1, (double)e2);
    }

    // And
    int32_t And(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 && e2 ? 1 : 0; }
    }
    int32_t And(int32_t e1, int32_t e2) { return e1 && e2 ? 1 : 0; }

    // Or
    int32_t Or(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 || e2 ? 1 : 0; }
    }
    int32_t Or(int32_t e1, int32_t e2) { return e1 || e2 ? 1 : 0; }
    
    // equal
    int32_t equal(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 == e2 ? 1 : 0; }
    }
    int32_t equal(int32_t e1, int32_t e2) { return e1 == e2 ? 1 : 0; }

    // not equal
    int32_t not_equal(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 != e2 ? 1 : 0; }
    }
    int32_t not_equal(int32_t e1, int32_t e2) { return e1 != e2 ? 1 : 0; }

    // more_than
    int32_t more_than(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 > e2 ? 1 : 0; }
    }
    int32_t more_than(int32_t e1, int32_t e2) { return e1 > e2 ? 1 : 0; }

    // less_than
    int32_t less_than(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 < e2 ? 1 : 0; }
    }
    int32_t less_than(int32_t e1, int32_t e2) { return e1 < e2 ? 1 : 0; }

    // more_than_or_equal
    int32_t more_than_or_equal(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 >= e2 ? 1 : 0; }
    }
    int32_t more_than_or_equal(int32_t e1, int32_t e2) { return e1 >= e2 ? 1 : 0; }
    
    // less_than_or_equal
    int32_t less_than_or_equal(double e1, double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 <= e2 ? 1 : 0; }
    }
    int32_t less_than_or_equal(int32_t e1, int32_t e2) { return e1 <= e2 ? 1 : 0; }

    // is_infinite
    int32_t is_infinite(double e1) { return Rstats::Util::is_Inf(e1) ? 1 : 0; }
    int32_t is_infinite(int32_t e1) { return 0; }

    // is_finite
    int32_t is_finite(double e1) { return std::isfinite(e1) ? 1 : 0; }
    int32_t is_finite(int32_t e1) { return 1; }

    // is_nan
    int32_t is_nan(double e1) { return Rstats::Util::is_NaN(e1) ? 1 : 0; }
    int32_t is_nan(int32_t e1) { return 0; }

    // as_double
    double as_double(double e1) { return e1; }
    double as_double(int32_t e1) { return (double)e1; }

    // as_int
    int32_t as_int(double e1) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_Inf(e1)) {
        Rstats::add_warn(WARN_NA_INTRODUCED);
        throw Rstats::NaException;
      }
      else {
        return (int32_t)e1;
      }
    }
    int32_t as_int(int32_t e1) { return e1; }
  }
}
