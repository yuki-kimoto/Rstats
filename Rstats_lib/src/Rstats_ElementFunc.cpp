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
    Rstats::Double add(Rstats::Double e1, Rstats::Double e2) { return e1 + e2; }
    Rstats::Integer add(Rstats::Integer e1, Rstats::Integer e2) { return e1 + e2; }
    
    // subtract
    Rstats::Double subtract(Rstats::Double e1, Rstats::Double e2) { return e1 - e2; }
    Rstats::Integer subtract(Rstats::Integer e1, Rstats::Integer e2) { return e1 - e2; }
    
    // multiply
    Rstats::Double multiply(Rstats::Double e1, Rstats::Double e2) { return e1 * e2; }
    Rstats::Integer multiply(Rstats::Integer e1, Rstats::Integer e2) { return e1 * e2; }

    // divide
    Rstats::Double divide(Rstats::Double e1, Rstats::Double e2) { return e1 / e2; }
    Rstats::Double divide(Rstats::Integer e1, Rstats::Integer e2) {
      return Rstats::ElementFunc::divide((Rstats::Double)e1, (Rstats::Double)e2);
    }
    
    // pow
    Rstats::Double pow(Rstats::Double e1, Rstats::Double e2) { return ::pow(e1, e2); }
    Rstats::Double pow(Rstats::Integer e1, Rstats::Integer e2) {
      return Rstats::ElementFunc::pow((Rstats::Double)e1, (Rstats::Double)e2);
    }

    // remainder
    Rstats::Double remainder(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2) || e2 == 0) {
        return Rstats::Util::NaN();
      }
      else {
        return fmod(e1, e2);;
      }
    }
    Rstats::Double remainder(Rstats::Integer e1, Rstats::Integer e2) {
      return Rstats::ElementFunc::remainder((Rstats::Double) e1, (Rstats::Double) e2);
    }

    // Re
    Rstats::Double Re(Rstats::Double e1) { return e1; }
    Rstats::Double Re(Rstats::Integer e1) { return Rstats::ElementFunc::Re((Rstats::Double)e1); }

    // Im
    Rstats::Double Im(Rstats::Double e1) { return 0; }
    Rstats::Double Im(Rstats::Integer e1) { return Rstats::ElementFunc::Im((Rstats::Double)e1); }

    // Conj
    Rstats::Double Conj(Rstats::Double e1) { return e1; }
    Rstats::Double Conj(Rstats::Integer e1) { return Rstats::ElementFunc::Conj((Rstats::Double)e1); }

    // sin
    Rstats::Double sin(Rstats::Double e1) { return std::sin(e1); }
    Rstats::Double sin(Rstats::Integer e1) { return Rstats::ElementFunc::sin((Rstats::Double)e1); }

    // cos
    Rstats::Double cos(Rstats::Double e1) { return std::cos(e1); }
    Rstats::Double cos(Rstats::Integer e1) { return Rstats::ElementFunc::cos((Rstats::Double)e1); }

    // tan
    Rstats::Double tan(Rstats::Double e1) { return std::tan(e1); }
    Rstats::Double tan(Rstats::Integer e1) { return Rstats::ElementFunc::tan((Rstats::Double)e1); }

    // sinh
    Rstats::Double sinh(Rstats::Double e1) { return std::sinh(e1); }
    Rstats::Double sinh(Rstats::Integer e1) { return Rstats::ElementFunc::sinh((Rstats::Double)e1); }

    // cosh
    Rstats::Double cosh(Rstats::Double e1) { return std::cosh(e1); }
    Rstats::Double cosh(Rstats::Integer e1) { return Rstats::ElementFunc::cosh((Rstats::Double)e1); }

    Rstats::Double tanh(Rstats::Double e1) { return std::tanh(e1); }
    Rstats::Double tanh(Rstats::Integer e1) { return Rstats::ElementFunc::tanh((Rstats::Double)e1); }

    // abs
    Rstats::Double abs(Rstats::Double e1) { return std::abs(e1); }
    Rstats::Double abs(Rstats::Integer e1) { return Rstats::ElementFunc::abs((Rstats::Double)e1); }

    // abs
    Rstats::Double Mod(Rstats::Double e1) { return abs(e1); }
    Rstats::Double Mod(Rstats::Integer e1) { return Rstats::ElementFunc::abs((Rstats::Double)e1); }

    // log
    Rstats::Double log(Rstats::Double e1) { return std::log(e1); }
    Rstats::Double log(Rstats::Integer e1) { return Rstats::ElementFunc::log((Rstats::Double)e1); }

    // logb
    Rstats::Double logb(Rstats::Double e1) { return log(e1); }
    Rstats::Double logb(Rstats::Integer e1) { return Rstats::ElementFunc::log((Rstats::Double)e1); }

    // log10
    Rstats::Double log10(Rstats::Double e1) { return std::log10(e1); }
    Rstats::Double log10(Rstats::Integer e1) { return Rstats::ElementFunc::log10((Rstats::Double)e1); }

    // log2
    Rstats::Double log2(Rstats::Double e1) {
      return std::log(e1) / std::log((Rstats::Double)2);
    }
    Rstats::Double log2(Rstats::Integer e1) { return Rstats::ElementFunc::log2((Rstats::Double)e1); }
    
    // expm1
    Rstats::Double expm1(Rstats::Double e1) { return ::expm1(e1); }
    Rstats::Double expm1(Rstats::Integer e1) { return Rstats::ElementFunc::expm1((Rstats::Double)e1); }

    // Arg
    Rstats::Double Arg(Rstats::Double e1) {
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
    Rstats::Double Arg(Rstats::Integer e1) { return Rstats::ElementFunc::Arg((Rstats::Double)e1); }
    
    // exp
    Rstats::Double exp(Rstats::Double e1) { return std::exp(e1); }
    Rstats::Double exp(Rstats::Integer e1) { return Rstats::ElementFunc::exp((Rstats::Double)e1); }

    // sqrt
    Rstats::Double sqrt(Rstats::Double e1) { return std::sqrt(e1); }
    Rstats::Double sqrt(Rstats::Integer e1) { return Rstats::ElementFunc::sqrt((Rstats::Double)e1); }

    // atan
    Rstats::Double atan(Rstats::Double e1) { return ::atan2(e1, 1); }
    Rstats::Double atan(Rstats::Integer e1) { return Rstats::ElementFunc::atan2((Rstats::Double)e1, (Rstats::Double)1); }

    // asin
    Rstats::Double asin(Rstats::Double e1) { return std::asin(e1); }
    Rstats::Double asin(Rstats::Integer e1) { return Rstats::ElementFunc::asin((Rstats::Double)e1); }

    // acos
    Rstats::Double acos(Rstats::Double e1) { return std::acos(e1); }
    Rstats::Double acos(Rstats::Integer e1) { return Rstats::ElementFunc::acos((Rstats::Double)e1); }

    // asinh
    Rstats::Double asinh(Rstats::Double e1) {
      Rstats::Double e2_t = (
        e1
        +
        std::sqrt((e1 * e1) + 1)
      );
      
      return std::log(e2_t);
    }
    Rstats::Double asinh(Rstats::Integer e1) { return Rstats::ElementFunc::asinh((Rstats::Double)e1); }

    // acosh

    Rstats::Double acosh(Rstats::Double e1) {
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
    Rstats::Double acosh(Rstats::Integer e1) { return Rstats::ElementFunc::acosh((Rstats::Double)e1); }

    // atanh
    Rstats::Double atanh(Rstats::Double e1) {
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
    Rstats::Double atanh(Rstats::Integer e1) { return Rstats::ElementFunc::atanh((Rstats::Double)e1); }

    // negate
    Rstats::Double negate(Rstats::Double e1) { return -e1; }
    Rstats::Integer negate(Rstats::Integer e1) { return -e1; }

    // atan2
    Rstats::Double atan2(Rstats::Double e1, Rstats::Double e2) {
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
    Rstats::Double atan2(Rstats::Integer e1, Rstats::Integer e2) {
      return Rstats::ElementFunc::atan2((Rstats::Double)e1, (Rstats::Double)e2);
    }

    // And
    Rstats::Integer And(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 && e2 ? 1 : 0; }
    }
    Rstats::Integer And(Rstats::Integer e1, Rstats::Integer e2) { return e1 && e2 ? 1 : 0; }

    // Or
    Rstats::Integer Or(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 || e2 ? 1 : 0; }
    }
    Rstats::Integer Or(Rstats::Integer e1, Rstats::Integer e2) { return e1 || e2 ? 1 : 0; }
    
    // equal
    Rstats::Integer equal(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 == e2 ? 1 : 0; }
    }
    Rstats::Integer equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 == e2 ? 1 : 0; }

    // not equal
    Rstats::Integer not_equal(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 != e2 ? 1 : 0; }
    }
    Rstats::Integer not_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 != e2 ? 1 : 0; }

    // more_than
    Rstats::Integer more_than(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 > e2 ? 1 : 0; }
    }
    Rstats::Integer more_than(Rstats::Integer e1, Rstats::Integer e2) { return e1 > e2 ? 1 : 0; }

    // less_than
    Rstats::Integer less_than(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 < e2 ? 1 : 0; }
    }
    Rstats::Integer less_than(Rstats::Integer e1, Rstats::Integer e2) { return e1 < e2 ? 1 : 0; }

    // more_than_or_equal
    Rstats::Integer more_than_or_equal(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 >= e2 ? 1 : 0; }
    }
    Rstats::Integer more_than_or_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 >= e2 ? 1 : 0; }
    
    // less_than_or_equal
    Rstats::Integer less_than_or_equal(Rstats::Double e1, Rstats::Double e2) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_NaN(e2)) { throw Rstats::NaException; }
      else { return e1 <= e2 ? 1 : 0; }
    }
    Rstats::Integer less_than_or_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 <= e2 ? 1 : 0; }

    // is_infinite
    Rstats::Integer is_infinite(Rstats::Double e1) { return Rstats::Util::is_Inf(e1) ? 1 : 0; }
    Rstats::Integer is_infinite(Rstats::Integer e1) { return 0; }

    // is_finite
    Rstats::Integer is_finite(Rstats::Double e1) { return std::isfinite(e1) ? 1 : 0; }
    Rstats::Integer is_finite(Rstats::Integer e1) { return 1; }

    // is_nan
    Rstats::Integer is_nan(Rstats::Double e1) { return Rstats::Util::is_NaN(e1) ? 1 : 0; }
    Rstats::Integer is_nan(Rstats::Integer e1) { return 0; }

    // as_double
    Rstats::Double as_double(Rstats::Double e1) { return e1; }
    Rstats::Double as_double(Rstats::Integer e1) { return (Rstats::Double)e1; }

    // as_integer
    Rstats::Integer as_integer(Rstats::Double e1) {
      if (Rstats::Util::is_NaN(e1) || Rstats::Util::is_Inf(e1)) {
        Rstats::add_warn(WARN_NA_INTRODUCED);
        throw Rstats::NaException;
      }
      else {
        return (Rstats::Integer)e1;
      }
    }
    Rstats::Integer as_integer(Rstats::Integer e1) { return e1; }
  }
}
