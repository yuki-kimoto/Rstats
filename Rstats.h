/* C++ library */
#include <vector>
#include <iostream>
#include <complex>
#include <cmath>
#include <map>
#include <limits>

/* Fix std::isnan problem in Windows */
#ifndef _isnan
#define _isnan isnan
#endif

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* suppress error - Cent OS(symbol collisions) */
#undef init_tm
#undef do_open
#undef do_close
#ifdef ENTER
#undef ENTER
#endif

/* suppress error - Mac OS X(error: declaration of 'Perl___notused' has a different language linkage) */
#ifdef __cplusplus
#  define dNOOP (void)0
#else
#  define dNOOP extern int Perl___notused(void)
#endif

namespace Rstats {
  
  // Rstats::PerlAPI
  namespace PerlAPI {
    
    REGEXP* mpregcomp (SV* sv_re, IV flag) {
      return (REGEXP*)sv_2mortal((SV*)pregcomp(sv_re, flag));
    }
    
    SV* new_mRV_inc(SV* sv) {
      return sv_2mortal(newRV_inc(sv));
    }

    SV* new_mSVsv(SV* sv) {
      return sv_2mortal(newSVsv(sv));
    }

    SV* new_mSVpv_nolen(const char* pv) {
      return sv_2mortal(newSVpvn(pv, strlen(pv)));
    }
        
    SV* new_mSViv(IV iv) {
      return sv_2mortal(newSViv(iv));
    }
    
    SV* new_mSVnv(NV nv) {
      return sv_2mortal(newSVnv(nv));
    }
    
    AV* new_mAV() {
      return (AV*)sv_2mortal((SV*)newAV());
    }
    
    SV* new_mAVRV() {
      return sv_2mortal(newRV_inc((SV*)new_mAV()));
    }
    
    HV* new_mHV() {
      return (HV*)sv_2mortal((SV*)newHV());
    }

    SV* new_mHVRV() {
      return sv_2mortal(newRV_inc((SV*)new_mHV()));
    }

    SV* SvRV_safe(SV* ref) {
      if (SvROK(ref)) {
        return SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    IV av_len_fix (AV* av) {
      return av_len(av) + 1;
    }

    IV avrv_len_fix (SV* av_ref) {
      return av_len((AV*)SvRV_safe(av_ref)) + 1;
    }
    
    SV* av_fetch_simple(AV* av, IV pos) {
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }
    
    SV* avrv_fetch_simple(SV* av_ref, IV pos) {
      AV* av = (AV*)SvRV_safe(av_ref);
      return av_fetch_simple(av, pos);
    }
    
    bool hv_exists_simple(HV* hv_hash, char* key) {
      return hv_exists(hv_hash, key, strlen(key));
    }

    bool hvrv_exists_simple(SV* sv_hash_ref, char* key) {
      return hv_exists((HV*)SvRV_safe(sv_hash_ref), key, strlen(key));
    }

    SV* hv_delete_simple(HV* hv_hash, char* key) {
      return hv_delete(hv_hash, key, strlen(key), 0);
    }
    
    SV* hvrv_delete_simple(SV* sv_hash_ref, char* key) {
      return hv_delete((HV*)SvRV_safe(sv_hash_ref), key, strlen(key), 0);
    }
    
    SV* hv_fetch_simple(HV* hv, const char* key) {
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* hvrv_fetch_simple(SV* hv_ref, const char* key) {
      HV* hv = (HV*)SvRV_safe(hv_ref);
      return hv_fetch_simple(hv, key);
    }
    
    void av_store_inc(AV* av, IV pos, SV* element) {
      av_store(av, pos, SvREFCNT_inc(element));
    }
    
    void avrv_store_inc(SV* av_ref, IV pos, SV* element) {
      AV* av = (AV*)SvRV_safe(av_ref);
      av_store_inc(av, pos, element);
    }

    SV* copy_av(SV* sv_av_ref) {
      SV* sv_new_av_ref = new_mAVRV();
      
      for (IV i = 0; i < avrv_len_fix(sv_av_ref); i++) {
        avrv_store_inc(sv_new_av_ref, i, new_mSVsv(avrv_fetch_simple(sv_av_ref, i)));
      }
      
      return sv_new_av_ref;
    }
    
    void hv_store_nolen_inc(HV* hv, const char* key, SV* element) {
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }

    void hvrv_store_nolen_inc(SV* hv_ref, const char* key, SV* element) {
      HV* hv = (HV*)SvRV_safe(hv_ref);
      return hv_store_nolen_inc(hv, key, element);
    }
    
    void av_push_inc(AV* av, SV* sv) {
      av_push(av, SvREFCNT_inc(sv));
    }
    
    void avrv_push_inc(SV* av_ref, SV* sv) {
      return av_push_inc((AV*)SvRV_safe(av_ref), sv);
    }

    SV* avrv_pop(SV* sv_array_ref) {
      return av_pop((AV*)SvRV_safe(sv_array_ref));
    }

    void av_unshift_real_inc(AV* av, SV* sv) {
      av_unshift(av, 1);
      av_store_inc(av, (IV)0, SvREFCNT_inc(sv));
    }
    
    void avrv_unshift_real_inc(SV* av_ref, SV* sv) {
      av_unshift((AV*)SvRV_safe(av_ref), 1);
      av_store_inc((AV*)SvRV_safe(av_ref), 0, SvREFCNT_inc(sv));
    }

    template <class X> X to_c_obj(SV* perl_obj_ref) {
      SV* perl_obj = SvROK(perl_obj_ref) ? SvRV(perl_obj_ref) : perl_obj_ref;
      IV obj_addr = SvIV(perl_obj);
      X c_obj = INT2PTR(X, obj_addr);
      
      return c_obj;
    }

    template <class X> SV* to_perl_obj(X c_obj, const char* class_name) {
      IV obj_addr = PTR2IV(c_obj);
      SV* sv_obj_addr = new_mSViv(obj_addr);
      SV* sv_obj_addr_ref = new_mRV_inc(sv_obj_addr);
      SV* perl_obj = sv_bless(sv_obj_addr_ref, gv_stashpv(class_name, 1));
      
      return perl_obj;
    }

    IV pregexec_simple (SV* sv_str, REGEXP* sv_re) {
      char* str = SvPV_nolen(sv_str);
      
      IV ret = pregexec(
        sv_re,
        str,
        str + strlen(str),
        str,
        0,
        sv_str,
        1
      );
      
      return ret;
    }
  };

  // Rstats::VectorType
  namespace VectorType {
    enum Enum {
      LOGICAL = 0,
      INTEGER = 1 ,
      DOUBLE = 2,
      COMPLEX = 3,
      CHARACTER = 4
    };
  }
  
  // Rstats::Util header
  namespace Util {
    SV* looks_like_na(SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double(SV*);
    SV* looks_like_logical(SV*);
    SV* looks_like_complex(SV*);
    IV is_perl_number(SV*);
  }
  
  namespace ElementFunc {

    // add
    std::complex<NV> add(std::complex<NV> e1, std::complex<NV> e2) { return e1 + e2; }
    NV add(NV e1, NV e2) { return e1 + e2; }
    IV add(IV e1, IV e2) { return e1 + e2; }

    // subtract
    std::complex<NV> subtract(std::complex<NV> e1, std::complex<NV> e2) { return e1 - e2; }
    NV subtract(NV e1, NV e2) { return e1 - e2; }
    IV subtract(IV e1, IV e2) { return e1 - e2; }

    // multiply
    std::complex<NV> multiply(std::complex<NV> e1, std::complex<NV> e2) { return e1 * e2; }
    NV multiply(NV e1, NV e2) { return e1 * e2; }
    IV multiply(IV e1, IV e2) { return e1 * e2; }

    // divide
    std::complex<NV> divide(std::complex<NV> e1, std::complex<NV> e2) { return e1 / e2; }
    NV divide(NV e1, NV e2) { return e1 / e2; }
    NV divide(IV e1, IV e2) { return e1 / e2; }

    // pow
    std::complex<NV> pow(std::complex<NV> e1, std::complex<NV> e2) { return std::pow(e1, e2); }
    NV pow(NV e1, NV e2) { return ::pow(e1, e2); }
    NV pow(IV e1, IV e2) { return pow((NV)e1, (NV)e2); }

    // reminder
    std::complex<NV> reminder(std::complex<NV> e1, std::complex<NV> e2) {
      croak("unimplemented complex operation(Rstats::VectorFunc::reminder())");
    }
    NV reminder(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2) || e2 == 0) {
        return std::numeric_limits<NV>::signaling_NaN();
      }
      else {
        return e1 - std::floor(e1 / e2) * e2;
      }
    }
    IV reminder(IV e1, IV e2) {
      if (e2 == 0) {
        throw "0 divide exception\n";
      }
      return e1 % e2;
    }

    // Re
    NV Re(std::complex<NV> e1) { return e1.real(); }
    NV Re(NV e1) { return e1; }
    NV Re(IV e1) { return e1; }

    // Im
    NV Im(std::complex<NV> e1) { return e1.imag(); }
    NV Im(NV e1) { return 0; }
    NV Im(IV e1) { return 0; }

    // Conj
    std::complex<NV> Conj(std::complex<NV> e1) { return std::complex<NV>(e1.real(), -e1.imag()); }
    NV Conj(NV e1) { return e1; }
    NV Conj(IV e1) { return e1; }

    // sin
    std::complex<NV> sin(std::complex<NV> e1) { return std::sin(e1); }
    NV sin(NV e1) { return std::sin(e1); }
    NV sin(IV e1) { return sin((NV)e1); }
    
    // cos
    std::complex<NV> cos(std::complex<NV> e1) { return std::cos(e1); }
    NV cos(NV e1) { return std::cos(e1); }
    NV cos(IV e1) { return cos((NV)e1); }

    // tan
    std::complex<NV> tan(std::complex<NV> e1) { return std::tan(e1); }
    NV tan(NV e1) { return std::tan(e1); }
    NV tan(IV e1) { return tan((NV)e1); }

    // sinh
    std::complex<NV> sinh(std::complex<NV> e1) { return std::sinh(e1); }
    NV sinh(NV e1) { return std::sinh(e1); }
    NV sinh(IV e1) { return sinh((NV)e1); }

    // cosh
    std::complex<NV> cosh(std::complex<NV> e1) { return std::cosh(e1); }
    NV cosh(NV e1) { return std::cosh(e1); }
    NV cosh(IV e1) { return cosh((NV)e1); }

    // tanh
    std::complex<NV> tanh (std::complex<NV> z) {
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
    NV tanh(NV e1) { return std::tanh(e1); }
    NV tanh(IV e1) { return tanh((NV)e1); }

    // abs
    NV abs(std::complex<NV> e1) { return std::abs(e1); }
    NV abs(NV e1) { return std::abs(e1); }
    NV abs(IV e1) { return abs((NV)e1); }

    // abs
    NV Mod(std::complex<NV> e1) { return abs(e1); }
    NV Mod(NV e1) { return abs(e1); }
    NV Mod(IV e1) { return abs((NV)e1); }

    // log
    std::complex<NV> log(std::complex<NV> e1) { return std::log(e1); }
    NV log(NV e1) { return std::log(e1); }
    NV log(IV e1) { return log((NV)e1); }

    // logb
    std::complex<NV> logb(std::complex<NV> e1) { return log(e1); }
    NV logb(NV e1) { return log(e1); }
    NV logb(IV e1) { return log((NV)e1); }

    // log10
    std::complex<NV> log10(std::complex<NV> e1) { return std::log10(e1); }
    NV log10(NV e1) { return std::log10(e1); }
    NV log10(IV e1) { return std::log10((NV)e1); }

    // log2
    std::complex<NV> log2(std::complex<NV> e1) {
      return std::log(e1) / std::log(std::complex<NV>(2, 0));
    }
    NV log2(NV e1) {
      return std::log(e1) / std::log(2);
    }
    NV log2(IV e1) { return log2((NV)e1); }
    
    // expm1
    std::complex<NV> expm1(std::complex<NV> e1) { croak("Error in expm1 : unimplemented complex function"); }
    NV expm1(NV e1) { return ::expm1(e1); }
    NV expm1(IV e1) { return expm1((NV)e1); }

    // Arg
    NV Arg(std::complex<NV> e1) {
      NV re = e1.real();
      NV im = e1.imag();
      
      if (re == 0 && im == 0) {
        return 0;
      }
      else {
        return ::atan2(im, re);
      }
    }
    NV Arg(NV e1) { croak("Error in expm1 : unimplemented double function"); }
    NV Arg(IV e1) { return Arg((NV)e1); }

    // exp
    std::complex<NV> exp(std::complex<NV> e1) { return std::exp(e1); }
    NV exp(NV e1) { return std::exp(e1); }
    NV exp(IV e1) { return exp((NV)e1); }

    // sqrt
    std::complex<NV> sqrt(std::complex<NV> e1) {
      // Fix bug that clang sqrt can't right value of perfect squeres
      if (e1.imag() == 0 && e1.real() < 0) {
        return std::complex<NV>(0, std::sqrt(-e1.real()));
      }
      else {
        return std::sqrt(e1);
      }
    }
    NV sqrt(NV e1) { return std::sqrt(e1); }
    NV sqrt(IV e1) { return sqrt((NV)e1); }

    // atan
    std::complex<NV> atan(std::complex<NV> e1) {
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
    NV atan(NV e1) { return ::atan2(e1, 1); }
    NV atan(IV e1) { return atan2((NV)e1, (NV)1); }

    // asin
    std::complex<NV> asin(std::complex<NV> e1) {
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
    NV asin(NV e1) { return std::asin(e1); }
    NV asin(IV e1) { return asin((NV)e1); }

    // acos
    std::complex<NV> acos(std::complex<NV> e1) {
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
    NV acos(NV e1) { return std::acos(e1); }
    NV acos(IV e1) { return acos((NV)e1); }

    // asinh
    std::complex<NV> asinh(std::complex<NV> e1) {
      std::complex<NV> e2_t = (
        std::sqrt((e1 * e1) + std::complex<NV>(1, 0))
        +
        e1
      );
      
      return std::log(e2_t);
    }
    NV asinh(NV e1) {
      NV e2_t = (
        e1
        +
        std::sqrt((e1 * e1) + 1)
      );
      
      return std::log(e2_t);
    }
    NV asinh(IV e1) { return asinh((NV)e1); }

    // acosh
    std::complex<NV> acosh(std::complex<NV> e1) {
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
    NV acosh(NV e1) {
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
    NV acosh(IV e1) { return acosh((NV)e1); }

    // atanh
    std::complex<NV> atanh(std::complex<NV> e1) {
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
    NV atanh(NV e1) {
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
    NV atanh(IV e1) { return atanh((NV)e1); }
    
    // negation
    std::complex<NV> negation(std::complex<NV> e1) { return -e1; }
    NV negation(NV e1) { return -e1; }
    IV negation(IV e1) { return -e1; }

    // atan2
    std::complex<NV> atan2(std::complex<NV> e1, std::complex<NV> e2) {
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
    NV atan2(NV e1, NV e2) { ::atan2(e1, e2); }
    NV atan2(IV e1, IV e2) { return atan2((NV)e1, (NV)e2); }

    // And
    IV And(SV* e1, SV* e2) { croak("operations are possible only for numeric, logical or complex types"); }
    IV And(std::complex<NV> e1, std::complex<NV> e2) {
      if (e1 != std::complex<NV>(0, 0) && e2 != std::complex<NV>(0, 0)) { return 1; }
      else { return 0; }
    }
    IV And(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
      else { return e1 && e2 ? 1 : 0; }
    }
    IV And(IV e1, IV e2) { return e1 && e2 ? 1 : 0; }

    // Or
    IV Or(SV* e1, SV* e2) { croak("operations are possible only for numeric, logical or complex types"); }
    IV Or(std::complex<NV> e1, std::complex<NV> e2) {
      if (e1 != std::complex<NV>(0, 0) || e2 != std::complex<NV>(0, 0)) { return 1; }
      else { return 0; }
    }
    IV Or(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Na exception"; }
      else { return e1 || e2 ? 1 : 0; }
    }
    IV Or(IV e1, IV e2) { return e1 || e2 ? 1 : 0; }
    
    // equal
    IV equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) == 0 ? 1 : 0; }
    IV equal(std::complex<NV> e1, std::complex<NV> e2) { return e1 == e2 ? 1 : 0; }
    IV equal(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 == e2 ? 1 : 0; }
    }
    IV equal(IV e1, IV e2) { return e1 == e2 ? 1 : 0; }

    // not equal
    IV not_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) != 0 ? 1 : 0; }
    IV not_equal(std::complex<NV> e1, std::complex<NV> e2) { return e1 != e2 ? 1 : 0; }
    IV not_equal(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 != e2 ? 1 : 0; }
    }
    IV not_equal(IV e1, IV e2) { return e1 != e2 ? 1 : 0; }

    // more_than
    IV more_than(SV* e1, SV* e2) { return sv_cmp(e1, e2) > 0 ? 1 : 0; }
    IV more_than(std::complex<NV> e1, std::complex<NV> e2) {
      croak("invalid comparison with complex values(more_than())");
    }
    IV more_than(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 > e2 ? 1 : 0; }
    }
    IV more_than(IV e1, IV e2) { return e1 > e2 ? 1 : 0; }

    // less_than
    IV less_than(SV* e1, SV* e2) { return sv_cmp(e1, e2) < 0 ? 1 : 0; }
    IV less_than(std::complex<NV> e1, std::complex<NV> e2) {
      croak("invalid comparison with complex values(less_than())");
    }
    IV less_than(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 < e2 ? 1 : 0; }
    }
    IV less_than(IV e1, IV e2) { return e1 < e2 ? 1 : 0; }

    // more_than_or_equal
    IV more_than_or_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) >= 0 ? 1 : 0; }
    IV more_than_or_equal(std::complex<NV> e1, std::complex<NV> e2) {
      croak("invalid comparison with complex values(more_than_or_equal())");
    }
    IV more_than_or_equal(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 >= e2 ? 1 : 0; }
    }
    IV more_than_or_equal(IV e1, IV e2) { return e1 >= e2 ? 1 : 0; }

    // less_than_or_equal
    IV less_than_or_equal(SV* e1, SV* e2) { return sv_cmp(e1, e2) <= 0 ? 1 : 0; }
    IV less_than_or_equal(std::complex<NV> e1, std::complex<NV> e2) {
      croak("invalid comparison with complex values(less_than_or_equal())");
    }
    IV less_than_or_equal(NV e1, NV e2) {
      if (std::isnan(e1) || std::isnan(e2)) { throw "Can't compare NaN"; }
      else { return e1 <= e2 ? 1 : 0; }
    }
    IV less_than_or_equal(IV e1, IV e2) { return e1 <= e2 ? 1 : 0; }

    // is_infinite
    IV is_infinite(SV* e1) { return 0; }
    IV is_infinite(std::complex<NV> e1) {
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
    IV is_infinite(NV e1) { return std::isinf(e1); }
    IV is_infinite(IV e1) { return 0; }

    // is_finite
    IV is_finite(SV* e1) { return 0; }
    IV is_finite(std::complex<NV> e1) {
      if (std::isfinite(e1.real()) && std::isfinite(e1.imag())) {
        return 1;
      }
      else {
        return 0;
      }
    }
    IV is_finite(NV e1) { return std::isfinite(e1) ? 1 : 0; }
    IV is_finite(IV e1) { return 1; }

    // is_nan
    IV is_nan(SV* e1) { return 0; }
    IV is_nan(std::complex<NV> e1) {
      if (std::isnan(e1.real()) && std::isnan(e1.imag())) {
        return 1;
      }
      else {
        return 0;
      }
    }
    IV is_nan(NV e1) { return std::isnan(e1) ? 1 : 0; }
    IV is_nan(IV e1) { return 1; }
  }
  
  // Macro for Rstats::Vector
# define RSTATS_DEF_VECTOR_FUNC_UN_IS(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1) { \
      IV length = e1->get_length(); \
      Rstats::Vector* e2 = Rstats::Vector::new_logical(length); \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            e2->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_character_value(i))); \
          } \
          break; \
        case Rstats::VectorType::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            e2->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            e2->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            e2->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : invalid argument to %s()", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      for (IV i = 0; i < length; i++) { \
        if (e1->exists_na_position(i)) { \
          e2->set_integer_value(i, 0); \
        } \
      } \
      return e2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_UN_MATH(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1) { \
      IV length = e1->get_length(); \
      Rstats::Vector* e2; \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          e2 = Rstats::Vector::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_complex_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          e2 = Rstats::Vector::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : invalid argument to %s()", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      e2->merge_na_positions(e1); \
      return e2; \
    }
    
# define RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1) { \
      IV length = e1->get_length(); \
      Rstats::Vector* e2; \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          e2 = Rstats::Vector::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_complex_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to Rstats::Vector::%s", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      e2->merge_na_positions(e1); \
      return e2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1) { \
      IV length = e1->get_length(); \
      Rstats::Vector* e2; \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          e2 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e2->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to Rstats::Vector::%s", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      e2->merge_na_positions(e1); \
      return e2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
      if (e1->get_type() != e2->get_type()) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (e1->get_length() != e2->get_length()) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = e1->get_length(); \
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length); \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            e3->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_character_value(i), e2->get_character_value(i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::VectorType::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            e3->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i), e2->get_complex_value(i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            try {\
              e3->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i), e2->get_double_value(i)) ? 1 : 0); \
            } catch (const char* e) {\
              e3->add_na_position(i);\
            }\
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            try {\
              e3->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i), e2->get_integer_value(i)) ? 1 : 0); \
            }\
            catch (const char* e) {\
              e3->add_na_position(i);\
            }\
          } \
          break; \
        default: \
          croak("Error in %s() : non-comparable argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      e3->merge_na_positions(e1); \
      e3->merge_na_positions(e2); \
      return e3; \
    }
    
# define RSTATS_DEF_VECTOR_FUNC_BIN_MATH(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
      if (e1->get_type() != e2->get_type()) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (e1->get_length() != e2->get_length()) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = e1->get_length(); \
      Rstats::Vector* e3; \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          e3 = Rstats::Vector::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            e3->set_complex_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i), e2->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          e3 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e3->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i), e2->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          e3 = Rstats::Vector::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            try {\
              e3->set_integer_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i), e2->get_integer_value(i))); \
            }\
            catch (const char* e) {\
              e3->add_na_position(i);\
            }\
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      e3->merge_na_positions(e1); \
      e3->merge_na_positions(e2); \
      return e3; \
    }

# define RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
      if (e1->get_type() != e2->get_type()) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (e1->get_length() != e2->get_length()) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = e1->get_length(); \
      Rstats::Vector* e3; \
      Rstats::VectorType::Enum type = e1->get_type(); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          e3 = Rstats::Vector::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            e3->set_complex_value(i, ELEMENT_FUNC_NAME(e1->get_complex_value(i), e2->get_complex_value(i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          e3 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e3->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_double_value(i), e2->get_double_value(i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          e3 = Rstats::Vector::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            e3->set_double_value(i, ELEMENT_FUNC_NAME(e1->get_integer_value(i), e2->get_integer_value(i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      e3->merge_na_positions(e1); \
      e3->merge_na_positions(e2); \
      return e3; \
    }
  
  // Rstats::Vector
  class Vector {
    private:
    Rstats::VectorType::Enum type;
    std::map<IV, IV> na_positions;
    void* values;
    
    public:
    
    ~Vector () {
      IV length = this->get_length();
      
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER : {
          std::vector<SV*>* values = this->get_character_values();
          for (IV i = 0; i < length; i++) {
            if ((*values)[i] != NULL) {
              SvREFCNT_dec((*values)[i]);
            }
          }
          delete values;
          break;
        }
        case Rstats::VectorType::COMPLEX : {
          std::vector<std::complex<NV> >* values = this->get_complex_values();
          delete values;
          break;
        }
        case Rstats::VectorType::DOUBLE : {
          std::vector<NV>* values = this->get_double_values();
          delete values;
          break;
        }
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL : {
          std::vector<IV>* values = this->get_integer_values();
          delete values;
        }
      }
    }

    SV* get_value(IV pos) {

      SV* sv_value;
      
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          if (this->exists_na_position(pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            sv_value = this->get_character_value(pos);
          }
          break;
        case Rstats::VectorType::COMPLEX :
          if (this->exists_na_position(pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            std::complex<NV> z = this->get_complex_value(pos);
            
            NV re = z.real();
            SV* sv_re;
            if (std::isnan(re)) {
              sv_re = Rstats::PerlAPI::new_mSVpv_nolen("NaN");
            }
            else if (std::isinf(re) && re > 0) {
              sv_re = Rstats::PerlAPI::new_mSVpv_nolen("Inf");
            }
            else if (std::isinf(re) && re < 0) {
              sv_re = Rstats::PerlAPI::new_mSVpv_nolen("-Inf");
            }
            else {
              sv_re = Rstats::PerlAPI::new_mSVnv(re);
            }
            
            NV im = z.imag();
            SV* sv_im;
            if (std::isnan(im)) {
              sv_im = Rstats::PerlAPI::new_mSVpv_nolen("NaN");
            }
            else if (std::isinf(im) && im > 0) {
              sv_im = Rstats::PerlAPI::new_mSVpv_nolen("Inf");
            }
            else if (std::isinf(im) && im < 0) {
              sv_im = Rstats::PerlAPI::new_mSVpv_nolen("-Inf");
            }
            else {
              sv_im = Rstats::PerlAPI::new_mSVnv(im);
            }

            sv_value = Rstats::PerlAPI::new_mHVRV();
            Rstats::PerlAPI::hvrv_store_nolen_inc(sv_value, "re", sv_re);
            Rstats::PerlAPI::hvrv_store_nolen_inc(sv_value, "im", sv_im);
          }
          break;
        case Rstats::VectorType::DOUBLE :
          if (this->exists_na_position(pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            NV value = this->get_double_value(pos);
            if (std::isnan(value)) {
              sv_value = Rstats::PerlAPI::new_mSVpv_nolen("NaN");
            }
            else if (std::isinf(value) && value > 0) {
              sv_value = Rstats::PerlAPI::new_mSVpv_nolen("Inf");
            }
            else if (std::isinf(value) && value < 0) {
              sv_value = Rstats::PerlAPI::new_mSVpv_nolen("-Inf");
            }
            else {
              sv_value = Rstats::PerlAPI::new_mSVnv(value);
            }
          }
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          if (this->exists_na_position(pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            IV value = this->get_integer_value(pos);
            sv_value = Rstats::PerlAPI::new_mSViv(value);
          }
          break;
        default:
          sv_value = &PL_sv_undef;
      }
      
      return sv_value;
    }
    
    SV* get_values() {
      
      IV length = this->get_length();
      SV* sv_values = Rstats::PerlAPI::new_mAVRV();
      for (IV i = 0; i < length; i++) {
        Rstats::PerlAPI::avrv_push_inc(sv_values, this->get_value(i));
      }
      
      return sv_values;
    }
    
    bool is_character () { return this->get_type() == Rstats::VectorType::CHARACTER; }
    bool is_complex () { return this->get_type() == Rstats::VectorType::COMPLEX; }
    bool is_double () { return this->get_type() == Rstats::VectorType::DOUBLE; }
    bool is_integer () { return this->get_type() == Rstats::VectorType::INTEGER; }
    bool is_numeric () {
      return this->get_type() == Rstats::VectorType::DOUBLE || this->get_type() == Rstats::VectorType::INTEGER;
    }
    bool is_logical () { return this->get_type() == Rstats::VectorType::LOGICAL; }
    
    std::vector<SV*>* get_character_values() {
      return (std::vector<SV*>*)this->values;
    }
    
    std::vector<std::complex<NV> >* get_complex_values() {
      return (std::vector<std::complex<NV> >*)this->values;
    }
    
    std::vector<NV>* get_double_values() {
      return (std::vector<NV>*)this->values;
    }
    
    std::vector<IV>* get_integer_values() {
      return (std::vector<IV>*)this->values;
    }
    
    Rstats::VectorType::Enum get_type() {
      return this->type;
    }
    
    void add_na_position(IV position) {
      this->na_positions[position] = 1;
    }

    bool exists_na_position(IV position) {
      return this->na_positions.count(position);
    }
    
    void merge_na_positions(Rstats::Vector* elements) {
      for(std::map<IV, IV>::iterator it = elements->na_positions.begin(); it != elements->na_positions.end(); ++it) {
        this->add_na_position(it->first);
      }
    }
    
    std::map<IV, IV> get_na_positions() { return this->na_positions; }
    
    IV get_length () {
      if (this->values == NULL) {
        return 0;
      }
      
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          return this->get_character_values()->size();
          break;
        case Rstats::VectorType::COMPLEX :
          return this->get_complex_values()->size();
          break;
        case Rstats::VectorType::DOUBLE :
          return this->get_double_values()->size();
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          return this->get_integer_values()->size();
          break;
      }
    }

    static Rstats::Vector* new_character(IV length, SV* sv_str) {

      Rstats::Vector* elements = Rstats::Vector::new_character(length);
      for (IV i = 0; i < length; i++) {
        elements->set_character_value(i, sv_str);
      }
      elements->type = Rstats::VectorType::CHARACTER;
      
      return elements;
    }

    static Rstats::Vector* new_character(IV length) {

      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<SV*>(length);
      elements->type = Rstats::VectorType::CHARACTER;
      
      return elements;
    }

    SV* get_character_value(IV pos) {
      SV* value = (*this->get_character_values())[pos];
      if (value == NULL) {
        return NULL;
      }
      else {
        return Rstats::PerlAPI::new_mSVsv(value);
      }
    }
    
    void set_character_value(IV pos, SV* value) {
      if (value != NULL) {
        SvREFCNT_dec((*this->get_character_values())[pos]);
      }
      
      SV* new_value = Rstats::PerlAPI::new_mSVsv(value);
      (*this->get_character_values())[pos] = SvREFCNT_inc(new_value);
    }

    static Rstats::Vector* new_complex(IV length) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<std::complex<NV> >(length, std::complex<NV>(0, 0));
      elements->type = Rstats::VectorType::COMPLEX;
      
      return elements;
    }
        
    static Rstats::Vector* new_complex(IV length, std::complex<NV> z) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<std::complex<NV> >(length, z);
      elements->type = Rstats::VectorType::COMPLEX;
      
      return elements;
    }

    std::complex<NV> get_complex_value(IV pos) {
      return (*this->get_complex_values())[pos];
    }
    
    void set_complex_value(IV pos, std::complex<NV> value) {
      (*this->get_complex_values())[pos] = value;
    }
    
    static Rstats::Vector* new_double(IV length) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<NV>(length);
      elements->type = Rstats::VectorType::DOUBLE;
      
      return elements;
    }

    static Rstats::Vector* new_double(IV length, NV value) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<NV>(length, value);
      elements->type = Rstats::VectorType::DOUBLE;
      
      return elements;
    }
    
    NV get_double_value(IV pos) {
      return (*this->get_double_values())[pos];
    }
    
    void set_double_value(IV pos, NV value) {
      (*this->get_double_values())[pos] = value;
    }

    static Rstats::Vector* new_integer(IV length) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<IV>(length);
      elements->type = Rstats::VectorType::INTEGER;
      
      return elements;
    }

    static Rstats::Vector* new_integer(IV length, IV value) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<IV>(length, value);
      elements->type = Rstats::VectorType::INTEGER;
      
      return elements;
    }

    IV get_integer_value(IV pos) {
      return (*this->get_integer_values())[pos];
    }
    
    void set_integer_value(IV pos, IV value) {
      (*this->get_integer_values())[pos] = value;
    }
    
    static Rstats::Vector* new_logical(IV length) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<IV>(length);
      elements->type = Rstats::VectorType::LOGICAL;
      
      return elements;
    }

    static Rstats::Vector* new_logical(IV length, IV value) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<IV>(length, value);
      elements->type = Rstats::VectorType::LOGICAL;
      
      return elements;
    }
    
    static Rstats::Vector* new_true() {
      return new_logical(1, 1);
    }

    static Rstats::Vector* new_false() {
      return new_logical(1, 0);
    }
    
    static Rstats::Vector* new_nan() {
      return  Rstats::Vector::new_double(1, NAN);
    }

    static Rstats::Vector* new_negative_inf() {
      return Rstats::Vector::new_double(1, -(INFINITY));
    }
    
    static Rstats::Vector* new_inf() {
      return Rstats::Vector::new_double(1, INFINITY);
    }
    
    static Rstats::Vector* new_na() {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new std::vector<IV>(1, 0);
      elements->type = Rstats::VectorType::LOGICAL;
      elements->add_na_position(0);
      
      return elements;
    }
    
    static Rstats::Vector* new_null() {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = NULL;
      elements->type = Rstats::VectorType::LOGICAL;
      return elements;
    }

    Rstats::Vector* as (SV* sv_type) {
      Rstats::Vector* e2;
      if (SvOK(sv_type)) {
        char* type = SvPV_nolen(sv_type);
        if (strEQ(type, "character")) {
          e2 = this->as_character();
        }
        else if (strEQ(type, "complex")) {
          e2 = this->as_complex();
        }
        else if (strEQ(type, "double")) {
          e2 = this->as_double();
        }
        else if (strEQ(type, "numeric")) {
          e2 = this->as_numeric();
        }
        else if (strEQ(type, "integer")) {
          e2 = this->as_integer();
        }
        else if (strEQ(type, "logical")) {
          e2 = this->as_logical();
        }
        else {
          croak("Invalid mode is passed(Rstats::Vector::as())");
        }
      }
      else {
        croak("Invalid mode is passed(Rstats::Vector::as())");
      }
      
      return e2;
    }
    
    SV* to_string_pos(IV pos) {
      Rstats::VectorType::Enum type = this->get_type();
      SV* sv_str;
      if (this->exists_na_position(pos)) {
        sv_str = Rstats::PerlAPI::new_mSVpv_nolen("NA");
      }
      else {
        switch (type) {
          case Rstats::VectorType::CHARACTER :
            sv_str = this->get_character_value(pos);
            break;
          case Rstats::VectorType::COMPLEX : {
            std::complex<NV> z = this->get_complex_value(pos);
            NV re = z.real();
            NV im = z.imag();
            
            sv_str = Rstats::PerlAPI::new_mSVpv_nolen("");
           if (std::isinf(re) && re > 0) {
              sv_catpv(sv_str, "Inf");
            }
            else if (std::isinf(re) && re < 0) {
              sv_catpv(sv_str, "-Inf");
            }
            else if (std::isnan(re)) {
              sv_catpv(sv_str, "NaN");
            }
            else {
              sv_catpv(sv_str, SvPV_nolen(Rstats::PerlAPI::new_mSVnv(re)));
            }

            if (std::isinf(im) && im > 0) {
              sv_catpv(sv_str, "+Inf");
            }
            else if (std::isinf(im) && im < 0) {
              sv_catpv(sv_str, "-Inf");
            }
            else if (std::isnan(im)) {
              sv_catpv(sv_str, "+NaN");
            }
            else {
              if (im >= 0) {
                sv_catpv(sv_str, "+");
              }
              sv_catpv(sv_str, SvPV_nolen(Rstats::PerlAPI::new_mSVnv(im)));
            }
            
            sv_catpv(sv_str, "i");
            break;
          }
          case Rstats::VectorType::DOUBLE : {
            NV value = this->get_double_value(pos);
            if (std::isinf(value) && value > 0) {
              sv_str = Rstats::PerlAPI::new_mSVpv_nolen("Inf");
            }
            else if (std::isinf(value) && value < 0) {
              sv_str = Rstats::PerlAPI::new_mSVpv_nolen("-Inf");
            }
            else if (std::isnan(value)) {
              sv_str = Rstats::PerlAPI::new_mSVpv_nolen("NaN");
            }
            else {
              sv_str = Rstats::PerlAPI::new_mSVnv(value);
              sv_catpv(sv_str, "");
            }
            break;
          }
          case Rstats::VectorType::INTEGER :
            sv_str = Rstats::PerlAPI::new_mSViv(this->get_integer_value(pos));
            sv_catpv(sv_str, "");
            break;
          case Rstats::VectorType::LOGICAL :
            sv_str = this->get_integer_value(pos)
              ? Rstats::PerlAPI::new_mSVpv_nolen("TRUE") : Rstats::PerlAPI::new_mSVpv_nolen("FALSE");
            break;
          default:
            croak("Invalid type");
        }
      }
      
      return sv_str;
    }
    
    SV* to_string() {
      
      SV* sv_strs = PerlAPI::new_mAVRV();
      for (IV i = 0; i < this->get_length(); i++) {
        SV* sv_str = this->to_string_pos(i);
        Rstats::PerlAPI::avrv_push_inc(sv_strs, sv_str);
      }

      SV* sv_str_all = Rstats::PerlAPI::new_mSVpv_nolen("");
      IV sv_strs_length = Rstats::PerlAPI::avrv_len_fix(sv_strs);
      for (IV i = 0; i < sv_strs_length; i++) {
        SV* sv_str = Rstats::PerlAPI::avrv_fetch_simple(sv_strs, i);
        sv_catpv(sv_str_all, SvPV_nolen(sv_str));
        if (i != sv_strs_length - 1) {
          sv_catpv(sv_str_all, ",");
        }
      }
      
      return sv_str_all;
    }
    
    Rstats::Vector* as_character () {
      IV length = this->get_length();
      Rstats::Vector* e2 = new_character(length);
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          for (IV i = 0; i < length; i++) {
            SV* sv_value = this->get_character_value(i);
            e2->set_character_value(i, sv_value);
          }
          break;
        case Rstats::VectorType::COMPLEX :
          for (IV i = 0; i < length; i++) {
            std::complex<NV> z = this->get_complex_value(i);
            NV re = z.real();
            NV im = z.imag();
            
            SV* sv_re = Rstats::PerlAPI::new_mSVnv(re);
            SV* sv_im = Rstats::PerlAPI::new_mSVnv(im);
            SV* sv_str = Rstats::PerlAPI::new_mSVpv_nolen("");
            
            sv_catpv(sv_str, SvPV_nolen(sv_re));
            if (im >= 0) {
              sv_catpv(sv_str, "+");
            }
            sv_catpv(sv_str, SvPV_nolen(sv_im));
            sv_catpv(sv_str, "i");

            e2->set_character_value(i, sv_str);
          }
          break;
        case Rstats::VectorType::DOUBLE :
          for (IV i = 0; i < length; i++) {
            NV value = this->get_double_value(i);
            SV* sv_str = Rstats::PerlAPI::new_mSVpv_nolen("");
            if (std::isinf(value) && value > 0) {
              sv_catpv(sv_str, "Inf");
            }
            else if (std::isinf(value) && value < 0) {
              sv_catpv(sv_str, "-Inf");
            }
            else if (std::isnan(value)) {
              sv_catpv(sv_str, "NaN");
            }
            else {
              sv_catpv(sv_str, SvPV_nolen(Rstats::PerlAPI::new_mSVnv(value)));
            }
            e2->set_character_value(i, sv_str);
          }
          break;
        case Rstats::VectorType::INTEGER :
          for (IV i = 0; i < length; i++) {
            e2->set_character_value(
              i,
              Rstats::PerlAPI::new_mSViv(this->get_integer_value(i))
            );
          }
          break;
        case Rstats::VectorType::LOGICAL :
          for (IV i = 0; i < length; i++) {
            if (this->get_integer_value(i)) {
              e2->set_character_value(i, Rstats::PerlAPI::new_mSVpv_nolen("TRUE"));
            }
            else {
              e2->set_character_value(i, Rstats::PerlAPI::new_mSVpv_nolen("FALSE"));
            }
          }
          break;
        default:
          croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
    
    Rstats::Vector* as_double() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_double(length);
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          for (IV i = 0; i < length; i++) {
            SV* sv_value = this->get_character_value(i);
            SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
            if (SvOK(sv_value_fix)) {
              NV value = SvNV(sv_value_fix);
              e2->set_double_value(i, value);
            }
            else {
              warn("NAs introduced by coercion");
              e2->add_na_position(i);
            }
          }
          break;
        case Rstats::VectorType::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (IV i = 0; i < length; i++) {
            e2->set_double_value(i, this->get_complex_value(i).real());
          }
          break;
        case Rstats::VectorType::DOUBLE :
          for (IV i = 0; i < length; i++) {
            e2->set_double_value(i, this->get_double_value(i));
          }
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          for (IV i = 0; i < length; i++) {
            e2->set_double_value(i, this->get_integer_value(i));
          }
          break;
        default:
          croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Vector* as_numeric() {
      return this->as_double();
    }

    Rstats::Vector* as_integer() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_integer(length);
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          for (IV i = 0; i < length; i++) {
            SV* sv_value = this->get_character_value(i);
            SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
            if (SvOK(sv_value_fix)) {
              IV value = SvIV(sv_value_fix);
              e2->set_integer_value(i, value);
            }
            else {
              warn("NAs introduced by coercion");
              e2->add_na_position(i);
            }
          }
          break;
        case Rstats::VectorType::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
          }
          break;
        case Rstats::VectorType::DOUBLE :
          NV value;
          for (IV i = 0; i < length; i++) {
            value = this->get_double_value(i);
            if (std::isnan(value) || std::isinf(value)) {
              e2->add_na_position(i);
            }
            else {
              e2->set_integer_value(i, (IV)value);
            }
          }
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, this->get_integer_value(i));
          }
          break;
        default:
          croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Vector* as_complex() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_complex(length);
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          for (IV i = 0; i < length; i++) {
            SV* sv_value = this->get_character_value(i);
            SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
            
            if (SvOK(sv_z)) {
              SV* sv_re = Rstats::PerlAPI::hvrv_fetch_simple(sv_z, "re");
              SV* sv_im = Rstats::PerlAPI::hvrv_fetch_simple(sv_z, "im");
              NV re = SvNV(sv_re);
              NV im = SvNV(sv_im);
              e2->set_complex_value(i, std::complex<NV>(re, im));
            }
            else {
              warn("NAs introduced by coercion");
              e2->add_na_position(i);
            }
          }
          break;
        case Rstats::VectorType::COMPLEX :
          for (IV i = 0; i < length; i++) {
            e2->set_complex_value(i, this->get_complex_value(i));
          }
          break;
        case Rstats::VectorType::DOUBLE :
          for (IV i = 0; i < length; i++) {
            NV value = this->get_double_value(i);
            if (std::isnan(value)) {
              e2->add_na_position(i);
            }
            else {
              e2->set_complex_value(i, std::complex<NV>(this->get_double_value(i), 0));
            }
          }
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          for (IV i = 0; i < length; i++) {
            e2->set_complex_value(i, std::complex<NV>(this->get_integer_value(i), 0));
          }
          break;
        default:
          croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
    
    Rstats::Vector* as_logical() {
      IV length = this->get_length();
      Rstats::Vector* e2 = new_logical(length);
      Rstats::VectorType::Enum type = this->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          for (IV i = 0; i < length; i++) {
            SV* sv_value = this->get_character_value(i);
            SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
            if (SvOK(sv_logical)) {
              if (SvTRUE(sv_logical)) {
                e2->set_integer_value(i, 1);
              }
              else {
                e2->set_integer_value(i, 0);
              }
            }
            else {
              warn("NAs introduced by coercion");
              e2->add_na_position(i);
            }
          }
          break;
        case Rstats::VectorType::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, this->get_complex_value(i).real() ? 1 : 0);
          }
          break;
        case Rstats::VectorType::DOUBLE :
          for (IV i = 0; i < length; i++) {
            NV value = this->get_double_value(i);
            if (std::isnan(value)) {
              e2->add_na_position(i);
            }
            else if (std::isinf(value)) {
              e2->set_integer_value(i, 1);
            }
            else {
              e2->set_integer_value(i, value ? 1 : 0);
            }
          }
          break;
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL :
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, this->get_integer_value(i) ? 1 : 0);
          }
          break;
        default:
          croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
  };

  // Rstats::VectorFunc
  namespace VectorFunc {
    RSTATS_DEF_VECTOR_FUNC_UN_IS(is_infinite, Rstats::ElementFunc::is_infinite)
    RSTATS_DEF_VECTOR_FUNC_UN_IS(is_finite, Rstats::ElementFunc::is_finite)
    RSTATS_DEF_VECTOR_FUNC_UN_IS(is_nan, Rstats::ElementFunc::is_nan)
    
    RSTATS_DEF_VECTOR_FUNC_UN_MATH(negation, Rstats::ElementFunc::negation)

    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sin, Rstats::ElementFunc::sin)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(cos, Rstats::ElementFunc::cos)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(tan, Rstats::ElementFunc::tan)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sinh, Rstats::ElementFunc::sinh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(cosh, Rstats::ElementFunc::cosh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(tanh, Rstats::ElementFunc::tanh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log, Rstats::ElementFunc::log)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(logb, Rstats::ElementFunc::logb)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log10, Rstats::ElementFunc::log10)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log2, Rstats::ElementFunc::log2)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(expm1, Rstats::ElementFunc::expm1)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(exp, Rstats::ElementFunc::exp)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sqrt, Rstats::ElementFunc::sqrt)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(atan, Rstats::ElementFunc::atan)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(asin, Rstats::ElementFunc::asin)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(acos, Rstats::ElementFunc::acos)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(asinh, Rstats::ElementFunc::asinh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(acosh, Rstats::ElementFunc::acosh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(atanh, Rstats::ElementFunc::atanh)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Conj, Rstats::ElementFunc::Conj)

    RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Arg, Rstats::ElementFunc::Arg)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(abs, Rstats::ElementFunc::abs)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Mod, Rstats::ElementFunc::Mod)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Re, Rstats::ElementFunc::Re)
    RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Im, Rstats::ElementFunc::Im)

    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(equal, Rstats::ElementFunc::equal);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(not_equal, Rstats::ElementFunc::not_equal);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(more_than, Rstats::ElementFunc::more_than);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(less_than, Rstats::ElementFunc::less_than);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(more_than_or_equal, Rstats::ElementFunc::more_than_or_equal);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(less_than_or_equal, Rstats::ElementFunc::less_than_or_equal);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(And, Rstats::ElementFunc::And);
    RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Or, Rstats::ElementFunc::Or);

    RSTATS_DEF_VECTOR_FUNC_BIN_MATH(add, Rstats::ElementFunc::add)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH(subtract, Rstats::ElementFunc::subtract)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH(multiply, Rstats::ElementFunc::multiply)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH(reminder, Rstats::ElementFunc::reminder)

    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(divide, Rstats::ElementFunc::divide)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(atan2, Rstats::ElementFunc::atan2)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(pow, Rstats::ElementFunc::pow)
    
    Rstats::Vector* cumprod(Rstats::Vector* e1) {
      IV length = e1->get_length();
      Rstats::Vector* e2;
      Rstats::VectorType::Enum type = e1->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          croak("Error in cumprod() : non-numeric argument to binary operator");
          break;
        case Rstats::VectorType::COMPLEX : {
          e2 = Rstats::Vector::new_complex(length);
          std::complex<NV> e2_total(1, 0);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_complex_value(i);
            e2->set_complex_value(i, e2_total);
          }
          break;
        }
        case Rstats::VectorType::DOUBLE : {
          e2 = Rstats::Vector::new_double(length);
          NV e2_total(1);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_double_value(i);
            e2->set_double_value(i, e2_total);
          }
          break;
        }
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL : {
          e2 = Rstats::Vector::new_integer(length);
          IV e2_total(1);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_integer_value(i);
            e2->set_integer_value(i, e2_total);
          }
          break;
        }
        default:
          croak("Invalid type");

      }

      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* cumsum(Rstats::Vector* e1) {
      IV length = e1->get_length();
      Rstats::Vector* e2;
      Rstats::VectorType::Enum type = e1->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          croak("Error in cumsum() : non-numeric argument to binary operator");
          break;
        case Rstats::VectorType::COMPLEX : {
          e2 = Rstats::Vector::new_complex(length);
          std::complex<NV> e2_total(0, 0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_complex_value(i);
            e2->set_complex_value(i, e2_total);
          }
          break;
        }
        case Rstats::VectorType::DOUBLE : {
          e2 = Rstats::Vector::new_double(length);
          NV e2_total(0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_double_value(i);
            e2->set_double_value(i, e2_total);
          }
          break;
        }
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL : {
          e2 = Rstats::Vector::new_integer(length);
          IV e2_total(0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_integer_value(i);
            e2->set_integer_value(i, e2_total);
          }
          break;
        }
        default:
          croak("Invalid type");

        e2->merge_na_positions(e1);
      }
      
      return e2;
    }

    Rstats::Vector* prod(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      Rstats::VectorType::Enum type = e1->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          croak("Error in prod() : non-numeric argument to prod()");
          break;
        case Rstats::VectorType::COMPLEX : {
          e2 = Rstats::Vector::new_complex(1);
          std::complex<NV> e2_total(1, 0);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_complex_value(i);
          }
          e2->set_complex_value(0, e2_total);
          break;
        }
        case Rstats::VectorType::DOUBLE : {
          e2 = Rstats::Vector::new_double(1);
          NV e2_total(1);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_double_value(i);
          }
          e2->set_double_value(0, e2_total);
          break;
        }
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL : {
          e2 = Rstats::Vector::new_integer(1);
          IV e2_total(1);
          for (IV i = 0; i < length; i++) {
            e2_total *= e1->get_integer_value(i);
          }
          e2->set_integer_value(0, e2_total);
          break;
        }
        default:
          croak("Invalid type");

      }

      for (IV i = 0; i < length; i++) {
        if (e1->exists_na_position(i)) {
          e2->add_na_position(0);
          break;
        }
      }
            
      return e2;
    }
    
    Rstats::Vector* sum(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      Rstats::VectorType::Enum type = e1->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          croak("Error in a - b : non-numeric argument to binary operator");
          break;
        case Rstats::VectorType::COMPLEX : {
          e2 = Rstats::Vector::new_complex(1);
          std::complex<NV> e2_total(0, 0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_complex_value(i);
          }
          e2->set_complex_value(0, e2_total);
          break;
        }
        case Rstats::VectorType::DOUBLE : {
          e2 = Rstats::Vector::new_double(1);
          NV e2_total(0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_double_value(i);
          }
          e2->set_double_value(0, e2_total);
          break;
        }
        case Rstats::VectorType::INTEGER :
        case Rstats::VectorType::LOGICAL : {
          e2 = Rstats::Vector::new_integer(1);
          IV e2_total(0);
          for (IV i = 0; i < length; i++) {
            e2_total += e1->get_integer_value(i);
          }
          e2->set_integer_value(0, e2_total);
          break;
        }
        default:
          croak("Invalid type");

      }
      
      for (IV i = 0; i < length; i++) {
        if (e1->exists_na_position(i)) {
          e2->add_na_position(0);
          break;
        }
      }
      
      return e2;
    }

    Rstats::Vector* clone(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      Rstats::VectorType::Enum type = e1->get_type();
      switch (type) {
        case Rstats::VectorType::CHARACTER :
          e2 = Rstats::Vector::new_character(length);
          for (IV i = 0; i < length; i++) {
            e2->set_character_value(i, e1->get_character_value(i));
          }
          break;
        case Rstats::VectorType::COMPLEX :
          e2 = Rstats::Vector::new_complex(length);
          for (IV i = 0; i < length; i++) {
            e2->set_complex_value(i, e1->get_complex_value(i));
          }
          break;
        case Rstats::VectorType::DOUBLE :
          e2 = Rstats::Vector::new_double(length);
          for (IV i = 0; i < length; i++) {
            e2->set_double_value(i, e1->get_double_value(i));
          }
          break;
        case Rstats::VectorType::INTEGER :
          e2 = Rstats::Vector::new_integer(length);
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, e1->get_integer_value(i));
          }
          break;
        case Rstats::VectorType::LOGICAL :
          e2 = Rstats::Vector::new_logical(length);
          for (IV i = 0; i < length; i++) {
            e2->set_integer_value(i, e1->get_integer_value(i));
          }
          break;
        default:
          croak("Invalid type");

      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
  }

  // Rstats::ArrayFunc
  namespace ArrayFunc {
    SV* new_array() {
      
      SV* sv_self = Rstats::PerlAPI::new_mHVRV();
      sv_bless(sv_self, gv_stashpv("Rstats::Array", 1));
      
      return sv_self;
    }
    
    void set_vector(SV* sv_a1, Rstats::Vector* v1) {
      SV* sv_vector = Rstats::PerlAPI::to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
      Rstats::PerlAPI::hvrv_store_nolen_inc(sv_a1, "vector", sv_vector);
    }
    
    Rstats::Vector* get_vector(SV* sv_a1) {
      SV* sv_vector = Rstats::PerlAPI::hvrv_fetch_simple(sv_a1, "vector");
      Rstats::Vector* vector = Rstats::PerlAPI::to_c_obj<Rstats::Vector*>(sv_vector);
      return vector;
    }

    void set_dim(SV* sv_a1, Rstats::Vector* v1) {
      SV* sv_dim = Rstats::PerlAPI::to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
      Rstats::PerlAPI::hvrv_store_nolen_inc(sv_a1, "dim", sv_dim);
    }
    
    Rstats::Vector* get_dim(SV* sv_a1) {
      SV* sv_dim = Rstats::PerlAPI::hvrv_fetch_simple(sv_a1, "dim");
      Rstats::Vector* dim = Rstats::PerlAPI::to_c_obj<Rstats::Vector*>(sv_dim);
      return dim;
    }

    SV* c(SV* sv_elements) {

      IV element_length = Rstats::PerlAPI::avrv_len_fix(sv_elements);
      // Check type and length
      std::map<Rstats::VectorType::Enum, IV> type_h;
      IV length = 0;
      for (IV i = 0; i < element_length; i++) {
        Rstats::VectorType::Enum type;
        SV* sv_element = Rstats::PerlAPI::avrv_fetch_simple(sv_elements, i);
        if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Array")) {
          length += Rstats::ArrayFunc::get_vector(sv_element)->get_length();
          type = Rstats::ArrayFunc::get_vector(sv_element)->get_type();
          type_h[type] = 1;
        }
        else if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Vector")) {
          length += Rstats::PerlAPI::to_c_obj<Rstats::Vector*>(sv_element)->get_length();
          type = Rstats::PerlAPI::to_c_obj<Rstats::Vector*>(sv_element)->get_type();
          type_h[type] = 1;
        }
        else {
          if (SvOK(sv_element)) {
            if (Rstats::Util::is_perl_number(sv_element)) {
              type_h[Rstats::VectorType::DOUBLE] = 1;
            }
            else {
              type_h[Rstats::VectorType::CHARACTER] = 1;
            }
          }
          else {
            type_h[Rstats::VectorType::LOGICAL] = 1;
          }
          length += 1;
        }
      }

      // Decide type
      Rstats::Vector* v2;
      if (type_h[Rstats::VectorType::CHARACTER]) {
        v2 = Rstats::Vector::new_character(length);
      }
      else if (type_h[Rstats::VectorType::COMPLEX]) {
        v2 = Rstats::Vector::new_complex(length);
      }
      else if (type_h[Rstats::VectorType::DOUBLE]) {
        v2 = Rstats::Vector::new_double(length);
      }
      else if (type_h[Rstats::VectorType::INTEGER]) {
        v2 = Rstats::Vector::new_integer(length);
      }
      else {
        v2 = Rstats::Vector::new_logical(length);
      }
      
      Rstats::VectorType::Enum type = v2->get_type();
      
      IV pos = 0;
      for (IV i = 0; i < element_length; i++) {
        SV* sv_element = Rstats::PerlAPI::avrv_fetch_simple(sv_elements, i);
        if (sv_derived_from(sv_element, "Rstats::Array") || sv_derived_from(sv_element, "Rstats::Vector")) {
          
          Rstats::Vector* v1;
          if (sv_derived_from(sv_element, "Rstats::Array")) {
            v1 = Rstats::ArrayFunc::get_vector(sv_element);
          }
          else {
            v1 = Rstats::PerlAPI::to_c_obj<Rstats::Vector*>(sv_element);
          }
          
          Rstats::Vector* v_tmp;
          if (v1->get_type() == type) {
            v_tmp = v1;
          }
          else {
            if (type == Rstats::VectorType::CHARACTER) {
              v_tmp = v1->as_character();
            }
            else if (type == Rstats::VectorType::COMPLEX) {
              v_tmp = v1->as_complex();
            }
            else if (type == Rstats::VectorType::DOUBLE) {
              v_tmp = v1->as_double();
            }
            else if (type == Rstats::VectorType::INTEGER) {
              v_tmp = v1->as_integer();
            }
            else {
              v_tmp = v1->as_logical();
            }
          }
          
          for (IV k = 0; k < v_tmp->get_length(); k++) {
            if (v_tmp->exists_na_position(k)) {
              v2->add_na_position(pos);
            }
            else {
              if (type == Rstats::VectorType::CHARACTER) {
                v2->set_character_value(pos, v_tmp->get_character_value(k));
              }
              else if (type == Rstats::VectorType::COMPLEX) {
                v2->set_complex_value(pos, v_tmp->get_complex_value(k));
              }
              else if (type == Rstats::VectorType::DOUBLE) {
                v2->set_double_value(pos, v_tmp->get_double_value(k));
              }
              else if (type == Rstats::VectorType::INTEGER) {
                v2->set_integer_value(pos, v_tmp->get_integer_value(k));
              }
              else {
                v2->set_integer_value(pos, v_tmp->get_integer_value(k));
              }
            }
            
            pos++;
          }
          
          if (v_tmp != v1) {
            delete v_tmp;
          }
        }
        else {
          if (SvOK(sv_element)) {
            if (type == Rstats::VectorType::CHARACTER) {
              v2->set_character_value(pos, sv_element);
            }
            else if (type == Rstats::VectorType::COMPLEX) {
              v2->set_complex_value(pos, std::complex<NV>(SvNV(sv_element), 0));
            }
            else if (type == Rstats::VectorType::DOUBLE) {
              v2->set_double_value(pos, SvNV(sv_element));
            }
            else if (type == Rstats::VectorType::INTEGER) {
              v2->set_integer_value(pos, SvIV(sv_element));
            }
            else {
              v2->set_integer_value(pos, SvIV(sv_element));
            }
          }
          else {
            v2->add_na_position(pos);
          }
          pos++;
        }
      }
      
      // Array
      SV* sv_x1 = Rstats::ArrayFunc::new_array();
      Rstats::ArrayFunc::set_vector(sv_x1, v2);

      return sv_x1;
    }

    SV* to_c(SV* sv_x) {

      IV is_container = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Container");
      
      SV* sv_x1;
      if (is_container) {
        sv_x1 = sv_x;
      }
      else {
        SV* sv_tmp = Rstats::PerlAPI::new_mAVRV();
        Rstats::PerlAPI::avrv_push_inc(sv_tmp, sv_x);
        sv_x1 = Rstats::ArrayFunc::c(sv_tmp);
      }
      
      return sv_x1;
    }
  }
  
  // Rstats::Util body
  namespace Util {
    REGEXP* LOGICAL_RE = pregcomp(newSVpv("^ *(T|TRUE|F|FALSE) *$", 0), 0);
    REGEXP* LOGICAL_TRUE_RE = pregcomp(newSVpv("T", 0), 0);
    REGEXP* INTEGER_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+) *$", 0), 0);
    REGEXP* DOUBLE_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+(?:\\.[0-9]+)?) *$", 0), 0);
    REGEXP* COMPLEX_IMAGE_ONLY_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)i *$", 0), 0);
    REGEXP* COMPLEX_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)(?:([\\+\\-][0-9]+(?:\\.[0-9]+)?)i)? *$", 0), 0);

    SV* args(SV* sv_names, SV* sv_args) {
      
      IV args_length = Rstats::PerlAPI::avrv_len_fix(sv_args);
      SV* sv_opt;
      SV* sv_arg_last = Rstats::PerlAPI::avrv_fetch_simple(sv_args, args_length - 1);
      if (!sv_isobject(sv_arg_last) && sv_derived_from(sv_arg_last, "HASH")) {
        sv_opt = Rstats::PerlAPI::avrv_pop(sv_args);
      }
      else {
        sv_opt = Rstats::PerlAPI::new_mHVRV();
      }
      
      SV* sv_new_opt = Rstats::PerlAPI::new_mHVRV();
      IV names_length = Rstats::PerlAPI::avrv_len_fix(sv_names);
      for (IV i = 0; i < names_length; i++) {
        SV* sv_name = Rstats::PerlAPI::avrv_fetch_simple(sv_names, i);
        if (Rstats::PerlAPI::hvrv_exists_simple(sv_opt, SvPV_nolen(sv_name))) {
          Rstats::PerlAPI::hvrv_store_nolen_inc(
            sv_new_opt,
            SvPV_nolen(sv_name),
            Rstats::ArrayFunc::to_c(Rstats::PerlAPI::hvrv_delete_simple(sv_opt, SvPV_nolen(sv_name)))
          );
        }
        else if (i < names_length) {
          SV* sv_name = Rstats::PerlAPI::avrv_fetch_simple(sv_names, i);
          SV* sv_arg = Rstats::PerlAPI::avrv_fetch_simple(sv_args, i);
          if (SvOK(sv_arg)) {
            Rstats::PerlAPI::hvrv_store_nolen_inc(
              sv_new_opt,
              SvPV_nolen(sv_name),
              Rstats::ArrayFunc::to_c(sv_arg)
            );
          }
        }
      }

      // SV* sv_key;
      // while ((sv_key = hv_iterkeysv(hv_iternext((HV*)Rstats::PerlAPI::SvRV_safe(sv_opt)))) != NULL) {
        // croak("unused argument (%s)", SvPV_nolen(sv_key));
      // }
      
      return sv_new_opt;
    }

    IV is_perl_number(SV* sv_str) {
      if (!SvOK(sv_str)) {
        return 0;
      }
      
      if ((SvIOKp(sv_str) || SvNOKp(sv_str)) && 0 + sv_cmp(sv_str, sv_str) == 0 && SvIV(sv_str) * 0 == 0) {
        return 1;
      }
      else {
        return 0;
      }
    }
    
    SV* cross_product(SV* sv_values) {
      
      IV values_length = Rstats::PerlAPI::avrv_len_fix(sv_values);
      SV* sv_idxs = Rstats::PerlAPI::new_mAVRV();
      for (IV i = 0; i < values_length; i++) {
        Rstats::PerlAPI::avrv_push_inc(sv_idxs, Rstats::PerlAPI::new_mSViv(0)); 
      }
      
      SV* sv_idx_idx = Rstats::PerlAPI::new_mAVRV();
      for (IV i = 0; i < values_length; i++) {
        Rstats::PerlAPI::avrv_push_inc(sv_idx_idx, Rstats::PerlAPI::new_mSViv(i));
      }
      
      SV* sv_x1 = Rstats::PerlAPI::new_mAVRV();
      for (IV i = 0; i < values_length; i++) {
        SV* sv_value = Rstats::PerlAPI::avrv_fetch_simple(sv_values, i);
        Rstats::PerlAPI::avrv_push_inc(sv_x1, Rstats::PerlAPI::avrv_fetch_simple(sv_value, 0));
      }

      SV* sv_result = Rstats::PerlAPI::new_mAVRV();
      Rstats::PerlAPI::avrv_push_inc(sv_result, Rstats::PerlAPI::copy_av(sv_x1));
      IV end_loop = 0;
      while (1) {
        for (IV i = 0; i < values_length; i++) {
          
          if (SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_idxs, i)) < Rstats::PerlAPI::avrv_len_fix(Rstats::PerlAPI::avrv_fetch_simple(sv_values, i)) - 1) {
            
            SV* sv_idxs_tmp = Rstats::PerlAPI::avrv_fetch_simple(sv_idxs, i);
            sv_inc(sv_idxs_tmp);
            Rstats::PerlAPI::avrv_store_inc(sv_x1, i, Rstats::PerlAPI::avrv_fetch_simple(Rstats::PerlAPI::avrv_fetch_simple(sv_values, i), SvIV(sv_idxs_tmp)));
            
            Rstats::PerlAPI::avrv_push_inc(sv_result, Rstats::PerlAPI::copy_av(sv_x1));
            
            break;
          }
          
          if (i == SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_idx_idx, values_length - 1))) {
            end_loop = 1;
            break;
          }
          
          Rstats::PerlAPI::avrv_store_inc(sv_idxs, i, Rstats::PerlAPI::new_mSViv(0));
          Rstats::PerlAPI::avrv_store_inc(sv_x1, i, Rstats::PerlAPI::avrv_fetch_simple(Rstats::PerlAPI::avrv_fetch_simple(sv_values, i), 0));
        }
        if (end_loop) {
          break;
        }
      }

      return sv_result;
    }

    SV* pos_to_index(SV* sv_pos, SV* sv_dim) {
      
      SV* sv_index = Rstats::PerlAPI::new_mAVRV();
      IV pos = SvIV(sv_pos);
      IV before_dim_product = 1;
      for (IV i = 0; i < Rstats::PerlAPI::avrv_len_fix(sv_dim); i++) {
        before_dim_product *= SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_dim, i));
      }
      
      for (IV i = Rstats::PerlAPI::avrv_len_fix(sv_dim) - 1; i >= 0; i--) {
        IV dim_product = 1;
        for (IV k = 0; k < i; k++) {
          dim_product *= SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_dim, k));
        }
        
        IV reminder = pos % before_dim_product;
        IV quotient = (IV)(reminder / dim_product);
        
        Rstats::PerlAPI::avrv_unshift_real_inc(sv_index, Rstats::PerlAPI::new_mSViv(quotient + 1));
        before_dim_product = dim_product;
      }
      
      return sv_index;
    }

    SV* index_to_pos(SV* sv_index, SV* sv_dim_values) {
      
      IV pos = 0;
      for (IV i = 0; i < Rstats::PerlAPI::avrv_len_fix(sv_dim_values); i++) {
        if (i > 0) {
          IV tmp = 1;
          for (IV k = 0; k < i; k++) {
            tmp *= SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_dim_values, k));
          }
          pos += tmp * (SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_index, i)) - 1);
        }
        else {
          pos += SvIV(Rstats::PerlAPI::avrv_fetch_simple(sv_index, i));
        }
      }
      
      SV* sv_pos = Rstats::PerlAPI::new_mSViv(pos - 1);
      
      return sv_pos;
    }

    SV* looks_like_complex (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_re;
        SV* sv_im;
        if (Rstats::PerlAPI::pregexec_simple(sv_value, COMPLEX_IMAGE_ONLY_RE)) {
          sv_re = Rstats::PerlAPI::new_mSVnv(0);
          SV* sv_im_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_IMAGE_ONLY_RE, 1, sv_im_str);
          sv_im = Rstats::PerlAPI::new_mSVnv(SvNV(sv_im_str));
          
          sv_ret = Rstats::PerlAPI::new_mHVRV();
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "re", sv_re);
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "im", sv_im);
        }
        else if(Rstats::PerlAPI::pregexec_simple(sv_value, COMPLEX_RE)) {
          SV* sv_re_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 1, sv_re_str);
          sv_re = Rstats::PerlAPI::new_mSVnv(SvNV(sv_re_str));

          SV* sv_im_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 2, sv_im_str);
          if (SvOK(sv_im_str)) {
            sv_im = Rstats::PerlAPI::new_mSVnv(SvNV(sv_im_str));
          }
          else {
            sv_im = Rstats::PerlAPI::new_mSVnv(0);
          }

          sv_ret = Rstats::PerlAPI::new_mHVRV();
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "re", sv_re);
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "im", sv_im);
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
    
    SV* looks_like_logical (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        if (Rstats::PerlAPI::pregexec_simple(sv_value, LOGICAL_RE)) {
          if (Rstats::PerlAPI::pregexec_simple(sv_value, LOGICAL_TRUE_RE)) {
            sv_ret = Rstats::PerlAPI::new_mSViv(1);
          }
          else {
            sv_ret = Rstats::PerlAPI::new_mSViv(0);
          }
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      return sv_ret;
    }

    SV* looks_like_na (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_na = Rstats::PerlAPI::new_mSVpv_nolen("NA");
        if (sv_cmp(sv_value, sv_na) == 0) {
          sv_ret = Rstats::PerlAPI::to_perl_obj(Rstats::Vector::new_na(), "Rstats::Vector");
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
    
    SV* looks_like_integer(SV* sv_str) {
      
      SV* sv_ret;
      if (!SvOK(sv_str) || sv_len(sv_str) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        IV ret = Rstats::PerlAPI::pregexec_simple(sv_str, INTEGER_RE);
        if (ret) {
          SV* match1 = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ INTEGER_RE, 1, match1);
          sv_ret = Rstats::PerlAPI::new_mSViv(SvIV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }

    SV* looks_like_double (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret =  &PL_sv_undef;
      }
      else {
        IV ret = Rstats::PerlAPI::pregexec_simple(sv_value, DOUBLE_RE);
        if (ret) {
          SV* match1 = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ DOUBLE_RE, 1, match1);
          sv_ret = Rstats::PerlAPI::new_mSVnv(SvNV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
  }
}
