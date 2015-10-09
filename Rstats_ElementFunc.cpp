#include "Rstats.h"

// Rstats::ElementFunc
namespace Rstats {
  namespace ElementFunc {

    // add
    Rstats::Complex add(Rstats::Complex e1, Rstats::Complex e2) { return e1 + e2; }
    Rstats::Double add(Rstats::Double e1, Rstats::Double e2) { return e1 + e2; }
    Rstats::Integer add(Rstats::Integer e1, Rstats::Integer e2) { return e1 + e2; }

    // subtract
    Rstats::Complex subtract(Rstats::Complex e1, Rstats::Complex e2) { return e1 - e2; }
    Rstats::Double subtract(Rstats::Double e1, Rstats::Double e2) { return e1 - e2; }
    Rstats::Integer subtract(Rstats::Integer e1, Rstats::Integer e2) { return e1 - e2; }

    // multiply
    Rstats::Complex multiply(Rstats::Complex e1, Rstats::Complex e2) { return e1 * e2; }
    Rstats::Double multiply(Rstats::Double e1, Rstats::Double e2) { return e1 * e2; }
    Rstats::Integer multiply(Rstats::Integer e1, Rstats::Integer e2) { return e1 * e2; }

    // divide
    Rstats::Complex divide(Rstats::Complex e1, Rstats::Complex e2) { return e1 / e2; }
    Rstats::Double divide(Rstats::Double e1, Rstats::Double e2) { return e1 / e2; }
    Rstats::Double divide(Rstats::Integer e1, Rstats::Integer e2) { return e1 / e2; }

    // pow
    Rstats::Complex pow(Rstats::Complex e1, Rstats::Complex e2) { return std::pow(e1, e2); }
    Rstats::Double pow(Rstats::Double e1, Rstats::Double e2) { return ::pow(e1, e2); }
    Rstats::Double pow(Rstats::Integer e1, Rstats::Integer e2) { return pow((Rstats::Double)e1, (Rstats::Double)e2); }

    // remainder
    Rstats::Complex remainder(Rstats::Complex e1, Rstats::Complex e2) {
      croak("unimplemented complex operation(Rstats::VectorFunc::remainder())");
    }
    Rstats::Double remainder(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2) || e2 == 0) {
        return std::numeric_limits<Rstats::Double>::signaling_NaN();
      }
      else {
        return e1 - std::floor(e1 / e2) * e2;
      }
    }
    Rstats::Integer remainder(Rstats::Integer e1, Rstats::Integer e2) {
      if (e2 == 0) {
        throw "0 divide exception\n";
      }
      return e1 % e2;
    }

    // Re
    Rstats::Double Re(Rstats::Complex e1) { return e1.real(); }
    Rstats::Double Re(Rstats::Double e1) { return e1; }
    Rstats::Double Re(Rstats::Integer e1) { return e1; }

    // Im
    Rstats::Double Im(Rstats::Complex e1) { return e1.imag(); }
    Rstats::Double Im(Rstats::Double e1) { return 0; }
    Rstats::Double Im(Rstats::Integer e1) { return 0; }

    // Conj
    Rstats::Complex Conj(Rstats::Complex e1) { return Rstats::Complex(e1.real(), -e1.imag()); }
    Rstats::Double Conj(Rstats::Double e1) { return e1; }
    Rstats::Double Conj(Rstats::Integer e1) { return e1; }

    // sin
    Rstats::Complex sin(Rstats::Complex e1) { return std::sin(e1); }
    Rstats::Double sin(Rstats::Double e1) { return std::sin(e1); }
    Rstats::Double sin(Rstats::Integer e1) { return sin((Rstats::Double)e1); }

    // cos
    Rstats::Complex cos(Rstats::Complex e1) { return std::cos(e1); }
    Rstats::Double cos(Rstats::Double e1) { return std::cos(e1); }
    Rstats::Double cos(Rstats::Integer e1) { return cos((Rstats::Double)e1); }

    // tan
    Rstats::Complex tan(Rstats::Complex e1) { return std::tan(e1); }
    Rstats::Double tan(Rstats::Double e1) { return std::tan(e1); }
    Rstats::Double tan(Rstats::Integer e1) { return tan((Rstats::Double)e1); }

    // sinh
    Rstats::Complex sinh(Rstats::Complex e1) { return std::sinh(e1); }
    Rstats::Double sinh(Rstats::Double e1) { return std::sinh(e1); }
    Rstats::Double sinh(Rstats::Integer e1) { return sinh((Rstats::Double)e1); }

    // cosh
    Rstats::Complex cosh(Rstats::Complex e1) { return std::cosh(e1); }
    Rstats::Double cosh(Rstats::Double e1) { return std::cosh(e1); }
    Rstats::Double cosh(Rstats::Integer e1) { return cosh((Rstats::Double)e1); }

    // tanh
    Rstats::Complex tanh (Rstats::Complex z) {
      Rstats::Double re = z.real();
      
      // For fix FreeBSD bug
      // FreeBAD return (NaN + NaNi) when real value is negative infinite
      if (std::isinf(re) && re < 0) {
        return Rstats::Complex(-1, 0);
      }
      else {
        return std::tanh(z);
      }
    }
    Rstats::Double tanh(Rstats::Double e1) { return std::tanh(e1); }
    Rstats::Double tanh(Rstats::Integer e1) { return tanh((Rstats::Double)e1); }

    // abs
    Rstats::Double abs(Rstats::Complex e1) { return std::abs(e1); }
    Rstats::Double abs(Rstats::Double e1) { return std::abs(e1); }
    Rstats::Double abs(Rstats::Integer e1) { return abs((Rstats::Double)e1); }

    // abs
    Rstats::Double Mod(Rstats::Complex e1) { return abs(e1); }
    Rstats::Double Mod(Rstats::Double e1) { return abs(e1); }
    Rstats::Double Mod(Rstats::Integer e1) { return abs((Rstats::Double)e1); }

    // log
    Rstats::Complex log(Rstats::Complex e1) { return std::log(e1); }
    Rstats::Double log(Rstats::Double e1) { return std::log(e1); }
    Rstats::Double log(Rstats::Integer e1) { return log((Rstats::Double)e1); }

    // logb
    Rstats::Complex logb(Rstats::Complex e1) { return log(e1); }
    Rstats::Double logb(Rstats::Double e1) { return log(e1); }
    Rstats::Double logb(Rstats::Integer e1) { return log((Rstats::Double)e1); }

    // log10
    Rstats::Complex log10(Rstats::Complex e1) { return std::log10(e1); }
    Rstats::Double log10(Rstats::Double e1) { return std::log10(e1); }
    Rstats::Double log10(Rstats::Integer e1) { return std::log10((Rstats::Double)e1); }

    // log2
    Rstats::Complex log2(Rstats::Complex e1) {
      return std::log(e1) / std::log(Rstats::Complex(2, 0));
    }
    Rstats::Double log2(Rstats::Double e1) {
      return std::log(e1) / std::log((Rstats::Double)2);
    }
    Rstats::Double log2(Rstats::Integer e1) { return log2((Rstats::Double)e1); }

    Rstats::Complex expm1(Rstats::Complex e1) { croak("Error in expm1 : unimplemented complex function"); }
    Rstats::Double expm1(Rstats::Double e1) { return ::expm1(e1); }
    Rstats::Double expm1(Rstats::Integer e1) { return expm1((Rstats::Double)e1); }

    // Arg
    Rstats::Double Arg(Rstats::Complex e1) {
      Rstats::Double re = e1.real();
      Rstats::Double im = e1.imag();
      
      if (re == 0 && im == 0) {
        return 0;
      }
      else {
        return Rstats::ElementFunc::atan2(im, re);
      }
    }
    Rstats::Double Arg(Rstats::Double e1) { croak("Error in Arg : unimplemented double function"); }
    Rstats::Double Arg(Rstats::Integer e1) { return Arg((Rstats::Double)e1); }

    // exp
    Rstats::Complex exp(Rstats::Complex e1) { return std::exp(e1); }
    Rstats::Double exp(Rstats::Double e1) { return std::exp(e1); }
    Rstats::Double exp(Rstats::Integer e1) { return exp((Rstats::Double)e1); }

    // sqrt
    Rstats::Complex sqrt(Rstats::Complex e1) {
      // Fix bug that clang sqrt can't right value of perfect squeres
      if (e1.imag() == 0 && e1.real() < 0) {
        return Rstats::Complex(0, std::sqrt(-e1.real()));
      }
      else {
        return std::sqrt(e1);
      }
    }
    Rstats::Double sqrt(Rstats::Double e1) { return std::sqrt(e1); }
    Rstats::Double sqrt(Rstats::Integer e1) { return sqrt((Rstats::Double)e1); }

    // atan
    Rstats::Complex atan(Rstats::Complex e1) {
      if (e1 == Rstats::Complex(0, 0)) {
        return Rstats::Complex(0, 0);
      }
      else if (e1 == Rstats::Complex(0, 1)) {
        return Rstats::Complex(0, INFINITY);
      }
      else if (e1 == Rstats::Complex(0, -1)) {
        return Rstats::Complex(0, -INFINITY);
      }
      else {  
        Rstats::Complex e2_i = Rstats::Complex(0, 1);
        Rstats::Complex e2_log = std::log((e2_i + e1) / (e2_i - e1));
        return (e2_i / Rstats::Complex(2, 0)) * e2_log;
      }
    }
    Rstats::Double atan(Rstats::Double e1) { return ::atan2(e1, 1); }
    Rstats::Double atan(Rstats::Integer e1) { return atan2((Rstats::Double)e1, (Rstats::Double)1); }

    // asin
    Rstats::Complex asin(Rstats::Complex e1) {
      Rstats::Double e1_re = e1.real();
      Rstats::Double e1_im = e1.imag();
      
      if (e1_re == 0 && e1_im == 0) {
        return Rstats::Complex(0, 0);
      }
      else {
        Rstats::Double e2_t1 = std::sqrt(
          ((e1_re + 1) * (e1_re + 1))
          +
          (e1_im * e1_im)
        );
        Rstats::Double e2_t2 = std::sqrt(
          ((e1_re - 1) * (e1_re - 1))
          +
          (e1_im * e1_im)
        );
        
        Rstats::Double e2_alpha = (e2_t1 + e2_t2) / 2;
        Rstats::Double e2_beta  = (e2_t1 - e2_t2) / 2;
        
        if (e2_alpha < 1) {
          e2_alpha = 1;
        }
        
        if (e2_beta > 1) {
          e2_beta = 1;
        }
        else if (e2_beta < -1) {
          e2_beta = -1;
        }
        
        Rstats::Double e2_u = Rstats::ElementFunc::atan2(
          e2_beta,
          std::sqrt(1 - (e2_beta * e2_beta))
        );
        
        Rstats::Double e2_v = -std::log(
          e2_alpha
          +
          std::sqrt((e2_alpha * e2_alpha) - 1)
        );
        
        if (e1_im > 0 || ((e1_im == 0) && (e1_re < -1))) {
          e2_v = -e2_v;
        }
        
        return Rstats::Complex(e2_u, e2_v);
      }
    }
    Rstats::Double asin(Rstats::Double e1) { return std::asin(e1); }
    Rstats::Double asin(Rstats::Integer e1) { return asin((Rstats::Double)e1); }

    // acos
    Rstats::Complex acos(Rstats::Complex e1) {
      Rstats::Double e1_re = e1.real();
      Rstats::Double e1_im = e1.imag();
      
      if (e1_re == 1 && e1_im == 0) {
        return Rstats::Complex(0, 0);
      }
      else {
        Rstats::Double e2_t1 = std::sqrt(
          ((e1_re + 1) * (e1_re + 1))
          +
          (e1_im * e1_im)
        );
        Rstats::Double e2_t2 = std::sqrt(
          ((e1_re - 1) * (e1_re - 1))
          +
          (e1_im * e1_im)
        );
        
        Rstats::Double e2_alpha = (e2_t1 + e2_t2) / 2;
        Rstats::Double e2_beta  = (e2_t1 - e2_t2) / 2;
        
        if (e2_alpha < 1) {
          e2_alpha = 1;
        }
        
        if (e2_beta > 1) {
          e2_beta = 1;
        }
        else if (e2_beta < -1) {
          e2_beta = -1;
        }
        
        Rstats::Double e2_u = Rstats::ElementFunc::atan2(
          std::sqrt(1 - (e2_beta * e2_beta)),
          e2_beta
        );
        
        Rstats::Double e2_v = std::log(
          e2_alpha
          +
          std::sqrt((e2_alpha * e2_alpha) - 1)
        );
        
        if (e1_im > 0 || (e1_im == 0 && e1_re < -1)) {
          e2_v = -e2_v;
        }
        
        return Rstats::Complex(e2_u, e2_v);
      }
    }
    Rstats::Double acos(Rstats::Double e1) { return std::acos(e1); }
    Rstats::Double acos(Rstats::Integer e1) { return acos((Rstats::Double)e1); }

    // asinh
    Rstats::Complex asinh(Rstats::Complex e1) {
      Rstats::Complex e2_t = (
        std::sqrt((e1 * e1) + Rstats::Complex(1, 0))
        +
        e1
      );
      
      return std::log(e2_t);
    }
    Rstats::Double asinh(Rstats::Double e1) {
      Rstats::Double e2_t = (
        e1
        +
        std::sqrt((e1 * e1) + 1)
      );
      
      return std::log(e2_t);
    }
    Rstats::Double asinh(Rstats::Integer e1) { return asinh((Rstats::Double)e1); }

    // acosh
    Rstats::Complex acosh(Rstats::Complex e1) {
      Rstats::Double e1_re = e1.real();
      Rstats::Double e1_im = e1.imag();

      Rstats::Complex e2_t = (
        std::sqrt(
          (e1 * e1)
          -
          Rstats::Complex(1, 0)
        )
        +
        e1
      );
      Rstats::Complex e2_u = std::log(e2_t);
      Rstats::Double e2_re = e2_u.real();
      Rstats::Double e2_im = e2_u.imag();
      
      Rstats::Complex e2;
      if (e1_re < 0 && e1_im == 0) {
        e2 = Rstats::Complex(e2_re, -e2_im);
      }
      else {
        e2 = Rstats::Complex(e2_re, e2_im);
      }
      
      if (e1_re < 0) {
        return -e2;
      }
      else {
        return e2;
      }
    }
    Rstats::Double acosh(Rstats::Double e1) {
      if (e1 >= 1) {
        if (std::isinf(e1)) {
          warn("In acosh() : NaNs produced");
          return std::numeric_limits<Rstats::Double>::signaling_NaN();
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
        return std::numeric_limits<Rstats::Double>::signaling_NaN();
      }
    }
    Rstats::Double acosh(Rstats::Integer e1) { return acosh((Rstats::Double)e1); }

    // atanh
    Rstats::Complex atanh(Rstats::Complex e1) {
      if (e1 == Rstats::Complex(1, 0)) {
        warn("In atanh() : NaNs produced");
        return Rstats::Complex(INFINITY, std::numeric_limits<Rstats::Double>::signaling_NaN());
      }
      else if (e1 == Rstats::Complex(-1, 0)) {
        warn("In atanh() : NaNs produced");
        return Rstats::Complex(-INFINITY, std::numeric_limits<Rstats::Double>::signaling_NaN());
      }
      else {
        return Rstats::Complex(0.5, 0)
          *
          std::log(
            (Rstats::Complex(1, 0) + e1)
            /
            (Rstats::Complex(1, 0) - e1)
          );
      }
    }
    Rstats::Double atanh(Rstats::Double e1) {
      if (std::isinf(e1)) {
        warn("In acosh() : NaNs produced");
        return std::numeric_limits<Rstats::Double>::signaling_NaN();
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
          return std::numeric_limits<Rstats::Double>::signaling_NaN();
        }
      }
    }
    Rstats::Double atanh(Rstats::Integer e1) { return atanh((Rstats::Double)e1); }

    // negation
    Rstats::Complex negation(Rstats::Complex e1) { return -e1; }
    Rstats::Double negation(Rstats::Double e1) { return -e1; }
    Rstats::Integer negation(Rstats::Integer e1) { return -e1; }

    // atan2
    Rstats::Complex atan2(Rstats::Complex e1, Rstats::Complex e2) {
      Rstats::Complex e3_s = (e1 * e1) + (e2 * e2);
      if (e3_s == Rstats::Complex(0, 0)) {
        return Rstats::Complex(0, 0);
      }
      else {
        Rstats::Complex e3_i = Rstats::Complex(0, 1);
        Rstats::Complex e3_r = e2 + (e1 * e3_i);
        return -e3_i * std::log(e3_r / std::sqrt(e3_s));
      }
    }
    Rstats::Double atan2(Rstats::Double e1, Rstats::Double e2) {
      if (std::isinf(e1) && std::isinf(e2)) {
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
    Rstats::Double atan2(Rstats::Integer e1, Rstats::Integer e2) { return atan2((Rstats::Double)e1, (Rstats::Double)e2); }

    // And
    Rstats::Integer And(Rstats::Character e1, Rstats::Character e2) { croak("operations are possible only for numeric, logical or complex types"); }
    Rstats::Integer And(Rstats::Complex e1, Rstats::Complex e2) {
      if (e1 != Rstats::Complex(0, 0) && e2 != Rstats::Complex(0, 0)) { return 1; }
      else { return 0; }
    }
    Rstats::Integer And(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
      else { return e1 && e2 ? 1 : 0; }
    }
    Rstats::Integer And(Rstats::Integer e1, Rstats::Integer e2) { return e1 && e2 ? 1 : 0; }

    // Or
    Rstats::Integer Or(Rstats::Character e1, Rstats::Character e2) { croak("operations are possible only for numeric, logical or complex types"); }
    Rstats::Integer Or(Rstats::Complex e1, Rstats::Complex e2) {
      if (e1 != Rstats::Complex(0, 0) || e2 != Rstats::Complex(0, 0)) { return 1; }
      else { return 0; }
    }
    Rstats::Integer Or(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
      else { return e1 || e2 ? 1 : 0; }
    }
    Rstats::Integer Or(Rstats::Integer e1, Rstats::Integer e2) { return e1 || e2 ? 1 : 0; }

    // equal
    Rstats::Integer equal(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) == 0 ? 1 : 0; }
    Rstats::Integer equal(Rstats::Complex e1, Rstats::Complex e2) { return e1 == e2 ? 1 : 0; }
    Rstats::Integer equal(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 == e2 ? 1 : 0; }
    }
    Rstats::Integer equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 == e2 ? 1 : 0; }

    // not equal
    Rstats::Integer not_equal(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) != 0 ? 1 : 0; }
    Rstats::Integer not_equal(Rstats::Complex e1, Rstats::Complex e2) { return e1 != e2 ? 1 : 0; }
    Rstats::Integer not_equal(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 != e2 ? 1 : 0; }
    }
    Rstats::Integer not_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 != e2 ? 1 : 0; }

    // more_than
    Rstats::Integer more_than(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) > 0 ? 1 : 0; }
    Rstats::Integer more_than(Rstats::Complex e1, Rstats::Complex e2) {
      croak("invalid comparison with complex values(more_than())");
    }
    Rstats::Integer more_than(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 > e2 ? 1 : 0; }
    }
    Rstats::Integer more_than(Rstats::Integer e1, Rstats::Integer e2) { return e1 > e2 ? 1 : 0; }

    // less_than
    Rstats::Integer less_than(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) < 0 ? 1 : 0; }
    Rstats::Integer less_than(Rstats::Complex e1, Rstats::Complex e2) {
      croak("invalid comparison with complex values(less_than())");
    }
    Rstats::Integer less_than(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 < e2 ? 1 : 0; }
    }
    Rstats::Integer less_than(Rstats::Integer e1, Rstats::Integer e2) { return e1 < e2 ? 1 : 0; }

    // more_than_or_equal
    Rstats::Integer more_than_or_equal(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) >= 0 ? 1 : 0; }
    Rstats::Integer more_than_or_equal(Rstats::Complex e1, Rstats::Complex e2) {
      croak("invalid comparison with complex values(more_than_or_equal())");
    }
    Rstats::Integer more_than_or_equal(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 >= e2 ? 1 : 0; }
    }
    Rstats::Integer more_than_or_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 >= e2 ? 1 : 0; }

    // less_than_or_equal
    Rstats::Integer less_than_or_equal(Rstats::Character e1, Rstats::Character e2) { return sv_cmp(e1, e2) <= 0 ? 1 : 0; }
    Rstats::Integer less_than_or_equal(Rstats::Complex e1, Rstats::Complex e2) {
      croak("invalid comparison with complex values(less_than_or_equal())");
    }
    Rstats::Integer less_than_or_equal(Rstats::Double e1, Rstats::Double e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 <= e2 ? 1 : 0; }
    }
    Rstats::Integer less_than_or_equal(Rstats::Integer e1, Rstats::Integer e2) { return e1 <= e2 ? 1 : 0; }

    // is_infinite
    Rstats::Integer is_infinite(Rstats::Character e1) { return 0; }
    Rstats::Integer is_infinite(Rstats::Complex e1) {
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
    Rstats::Integer is_infinite(Rstats::Double e1) { return std::isinf(e1); }
    Rstats::Integer is_infinite(Rstats::Integer e1) { return 0; }

    // is_finite
    Rstats::Integer is_finite(Rstats::Character e1) { return 0; }
    Rstats::Integer is_finite(Rstats::Complex e1) {
      if (std::isfinite(e1.real()) && std::isfinite(e1.imag())) {
        return 1;
      }
      else {
        return 0;
      }
    }
    Rstats::Integer is_finite(Rstats::Double e1) { return std::isfinite(e1) ? 1 : 0; }
    Rstats::Integer is_finite(Rstats::Integer e1) { return 1; }

    // is_nan
    Rstats::Integer is_nan(Rstats::Character e1) { return 0; }
    Rstats::Integer is_nan(Rstats::Complex e1) {
      if (std::isnan(e1.real()) && std::isnan(e1.imag())) {
        return 1;
      }
      else {
        return 0;
      }
    }
    Rstats::Integer is_nan(Rstats::Double e1) { return std::isnan(e1) ? 1 : 0; }
    Rstats::Integer is_nan(Rstats::Integer e1) { return 1; }
  }
}
