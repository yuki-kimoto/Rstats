#ifndef PERL_RSTATS_H
#define PERL_RSTATS_H

/* Fix std::isnan problem in Windows */
#ifndef _isnan
#define _isnan isnan
#endif

#include <vector>
#include <map>
#include <complex>
#include <cmath>
#include <limits>

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

// Rstats::ElementFunc header
namespace Rstats {

  SV* pl_new_rv(SV*);
  SV* pl_new_sv_sv(SV*);
  SV* pl_new_sv_pv(const char*);
  SV* pl_new_sv_iv(IV);
  SV* pl_new_sv_nv(NV);
  AV* pl_new_av();
  SV* pl_new_avrv();
  HV* pl_new_hv();
  SV* pl_new_hvrv();
  SV* pl_deref(SV*);
  AV* pl_av_deref(SV*);
  HV* pl_hv_deref(SV*);
  SSize_t pl_av_len (AV*);
  SSize_t pl_av_len (SV*);
  SV* pl_av_fetch(AV*, SSize_t);
  SV* pl_av_fetch(SV*, SSize_t);
  bool pl_hv_exists(HV*, char*);
  bool pl_hv_exists(SV*, char*);
  SV* pl_hv_delete(HV*, char*);
  SV* pl_hv_delete(SV*, char*);
  SV* pl_hv_fetch(HV*, const char*);
  SV* pl_hv_fetch(SV*, const char*);
  SSize_t pl_hv_key_count(HV* hv);
  SSize_t pl_hv_key_count(SV* hv_ref);
  void pl_av_store(AV*, SSize_t, SV*);
  void pl_av_store(SV*, SSize_t, SV*);
  SV* pl_av_copy(SV*);
  void pl_hv_store(HV*, const char*, SV*);
  void pl_hv_store(SV*, const char* key, SV*);
  void pl_av_push(AV*, SV*);
  void pl_av_push(SV*, SV*);
  SV* pl_av_pop(AV*);
  SV* pl_av_pop(SV*);
  void pl_av_unshift(AV*, SV*);
  void pl_av_unshift(SV*, SV*);
  SV* pl_sv_bless(SV*, const char*);
  REGEXP* pl_pregcomp (SV*, IV);
  IV pl_pregexec(SV*, REGEXP*);
  template <class X> X pl_to_c_obj(SV* perl_obj_ref) {
    SV* perl_obj = SvROK(perl_obj_ref) ? SvRV(perl_obj_ref) : perl_obj_ref;
    IV obj_addr = SvIV(perl_obj);
    X c_obj = INT2PTR(X, obj_addr);
    
    return c_obj;
  }

  template <class X> SV* pl_to_perl_obj(X c_obj, const char* class_name) {
    IV obj_addr = PTR2IV(c_obj);
    SV* sv_obj_addr = pl_new_sv_iv(obj_addr);
    SV* sv_obj_addr_ref = pl_new_rv(sv_obj_addr);
    SV* perl_obj = sv_bless(sv_obj_addr_ref, gv_stashpv(class_name, 1));
    
    return perl_obj;
  }
  
  namespace Type {
    enum Enum {
      LOGICAL = 0,
      INTEGER = 1 ,
      DOUBLE = 2,
      COMPLEX = 3,
      CHARACTER = 4
    };
  }

  typedef SV* Character;
  typedef std::complex<NV> Complex;
  typedef NV Double;
  typedef IV Integer;
  typedef UV Logical;// 0 or 1
  
  namespace Util {
    Rstats::Logical is_perl_number(SV*);
    SV* cross_product(SV*);
    SV* pos_to_index(SV*, SV*);
    SV* index_to_pos(SV*, SV*);
    SV* looks_like_complex(SV*);
    SV* looks_like_logical(SV*);
    SV* looks_like_na(SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double(SV*);
  }

  namespace ElementFunc {

    Rstats::Double pi();
    Rstats::Double Inf();
    Rstats::Double NaN();

    Rstats::Complex add(Rstats::Complex, Rstats::Complex);
    Rstats::Double add(Rstats::Double, Rstats::Double);
    Rstats::Integer add(Rstats::Integer, Rstats::Integer);
    Rstats::Integer add(Rstats::Logical, Rstats::Logical);

    Rstats::Complex subtract(Rstats::Complex, Rstats::Complex);
    Rstats::Double subtract(Rstats::Double, Rstats::Double);
    Rstats::Integer subtract(Rstats::Integer, Rstats::Integer);
    Rstats::Integer subtract(Rstats::Logical, Rstats::Logical);

    Rstats::Complex multiply(Rstats::Complex, Rstats::Complex);
    Rstats::Double multiply(Rstats::Double, Rstats::Double);
    Rstats::Integer multiply(Rstats::Integer, Rstats::Integer);
    Rstats::Integer multiply(Rstats::Logical, Rstats::Logical);

    Rstats::Complex divide(Rstats::Complex, Rstats::Complex);
    Rstats::Double divide(Rstats::Double, Rstats::Double);
    Rstats::Double divide(Rstats::Integer, Rstats::Integer);
    Rstats::Double divide(Rstats::Logical, Rstats::Logical);

    Rstats::Complex pow(Rstats::Complex, Rstats::Complex);
    Rstats::Double pow(Rstats::Double, Rstats::Double);
    Rstats::Double pow(Rstats::Integer, Rstats::Integer);
    Rstats::Double pow(Rstats::Logical, Rstats::Logical);

    Rstats::Complex remainder(Rstats::Complex, Rstats::Complex);
    Rstats::Double remainder(Rstats::Double, Rstats::Double);
    Rstats::Double remainder(Rstats::Integer, Rstats::Integer);
    Rstats::Double remainder(Rstats::Logical, Rstats::Logical);

    Rstats::Double Re(Rstats::Complex);
    Rstats::Double Re(Rstats::Double);
    Rstats::Double Re(Rstats::Integer);
    Rstats::Double Re(Rstats::Logical);

    Rstats::Double Im(Rstats::Complex);
    Rstats::Double Im(Rstats::Double);
    Rstats::Double Im(Rstats::Integer);
    Rstats::Double Im(Rstats::Logical);

    Rstats::Complex Conj(Rstats::Complex);
    Rstats::Double Conj(Rstats::Double);
    Rstats::Double Conj(Rstats::Integer);
    Rstats::Double Conj(Rstats::Logical);

    Rstats::Complex sin(Rstats::Complex);
    Rstats::Double sin(Rstats::Double);
    Rstats::Double sin(Rstats::Integer);
    Rstats::Double sin(Rstats::Logical);
    
    Rstats::Complex cos(Rstats::Complex);
    Rstats::Double cos(Rstats::Double);
    Rstats::Double cos(Rstats::Integer);
    Rstats::Double cos(Rstats::Logical);

    Rstats::Complex tan(Rstats::Complex);
    Rstats::Double tan(Rstats::Double);
    Rstats::Double tan(Rstats::Integer);
    Rstats::Double tan(Rstats::Logical);

    Rstats::Complex sinh(Rstats::Complex);
    Rstats::Double sinh(Rstats::Double);
    Rstats::Double sinh(Rstats::Integer);
    Rstats::Double sinh(Rstats::Logical);

    Rstats::Complex cosh(Rstats::Complex);
    Rstats::Double cosh(Rstats::Double);
    Rstats::Double cosh(Rstats::Integer);
    Rstats::Double cosh(Rstats::Logical);

    Rstats::Complex tanh (Rstats::Complex z);
    Rstats::Double tanh(Rstats::Double);
    Rstats::Double tanh(Rstats::Integer);
    Rstats::Double tanh(Rstats::Logical);

    Rstats::Double abs(Rstats::Complex);
    Rstats::Double abs(Rstats::Double);
    Rstats::Double abs(Rstats::Integer);
    Rstats::Double abs(Rstats::Logical);

    Rstats::Double Mod(Rstats::Complex);
    Rstats::Double Mod(Rstats::Double);
    Rstats::Double Mod(Rstats::Integer);
    Rstats::Double Mod(Rstats::Logical);

    Rstats::Complex log(Rstats::Complex);
    Rstats::Double log(Rstats::Double);
    Rstats::Double log(Rstats::Integer);
    Rstats::Double log(Rstats::Logical);

    Rstats::Complex logb(Rstats::Complex);
    Rstats::Double logb(Rstats::Double);
    Rstats::Double logb(Rstats::Integer);
    Rstats::Double logb(Rstats::Logical);

    Rstats::Complex log10(Rstats::Complex);
    Rstats::Double log10(Rstats::Double);
    Rstats::Double log10(Rstats::Integer);
    Rstats::Double log10(Rstats::Logical);

    Rstats::Complex log2(Rstats::Complex);
    Rstats::Double log2(Rstats::Double);
    Rstats::Double log2(Rstats::Integer);
    Rstats::Double log2(Rstats::Logical);
    
    Rstats::Complex expm1(Rstats::Complex);
    Rstats::Double expm1(Rstats::Double);
    Rstats::Double expm1(Rstats::Integer);
    Rstats::Double expm1(Rstats::Logical);

    Rstats::Double Arg(Rstats::Complex);
    Rstats::Double Arg(Rstats::Double);
    Rstats::Double Arg(Rstats::Integer);
    Rstats::Double Arg(Rstats::Logical);

    Rstats::Complex exp(Rstats::Complex);
    Rstats::Double exp(Rstats::Double);
    Rstats::Double exp(Rstats::Integer);
    Rstats::Double exp(Rstats::Logical);

    Rstats::Complex sqrt(Rstats::Complex);
    Rstats::Double sqrt(Rstats::Double);
    Rstats::Double sqrt(Rstats::Integer);
    Rstats::Double sqrt(Rstats::Logical);

    Rstats::Complex atan(Rstats::Complex);
    Rstats::Double atan(Rstats::Double);
    Rstats::Double atan(Rstats::Integer);
    Rstats::Double atan(Rstats::Logical);

    Rstats::Complex asin(Rstats::Complex);
    Rstats::Double asin(Rstats::Double);
    Rstats::Double asin(Rstats::Integer);
    Rstats::Double asin(Rstats::Logical);

    Rstats::Complex acos(Rstats::Complex);
    Rstats::Double acos(Rstats::Double);
    Rstats::Double acos(Rstats::Integer);
    Rstats::Double acos(Rstats::Logical);

    Rstats::Complex asinh(Rstats::Complex);
    Rstats::Double asinh(Rstats::Double);
    Rstats::Double asinh(Rstats::Integer);
    Rstats::Double asinh(Rstats::Logical);

    Rstats::Complex acosh(Rstats::Complex);
    Rstats::Double acosh(Rstats::Double);
    Rstats::Double acosh(Rstats::Integer);
    Rstats::Double acosh(Rstats::Logical);

    Rstats::Complex atanh(Rstats::Complex);
    Rstats::Double atanh(Rstats::Double);
    Rstats::Double atanh(Rstats::Integer);
    Rstats::Double atanh(Rstats::Logical);
    
    Rstats::Complex negate(Rstats::Complex);
    Rstats::Double negate(Rstats::Double);
    Rstats::Integer negate(Rstats::Integer);
    Rstats::Integer negate(Rstats::Logical);

    Rstats::Complex atan2(Rstats::Complex, Rstats::Complex);
    Rstats::Double atan2(Rstats::Double, Rstats::Double);
    Rstats::Double atan2(Rstats::Integer, Rstats::Integer);
    Rstats::Double atan2(Rstats::Logical, Rstats::Logical);

    Rstats::Logical And(Rstats::Character, Rstats::Character);
    Rstats::Logical And(Rstats::Complex, Rstats::Complex);
    Rstats::Logical And(Rstats::Double, Rstats::Double);
    Rstats::Logical And(Rstats::Integer, Rstats::Integer);
    Rstats::Logical And(Rstats::Logical, Rstats::Logical);

    Rstats::Logical Or(Rstats::Character, Rstats::Character);
    Rstats::Logical Or(Rstats::Complex, Rstats::Complex);
    Rstats::Logical Or(Rstats::Double, Rstats::Double);
    Rstats::Logical Or(Rstats::Integer, Rstats::Integer);
    Rstats::Logical Or(Rstats::Logical, Rstats::Logical);
    
    Rstats::Logical equal(Rstats::Character, Rstats::Character);
    Rstats::Logical equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical equal(Rstats::Double, Rstats::Double);
    Rstats::Logical equal(Rstats::Integer, Rstats::Integer);
    Rstats::Logical equal(Rstats::Logical, Rstats::Logical);

    Rstats::Logical not_equal(Rstats::Character, Rstats::Character);
    Rstats::Logical not_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical not_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical not_equal(Rstats::Integer, Rstats::Integer);
    Rstats::Logical not_equal(Rstats::Logical, Rstats::Logical);

    Rstats::Logical more_than(Rstats::Character, Rstats::Character);
    Rstats::Logical more_than(Rstats::Complex, Rstats::Complex);
    Rstats::Logical more_than(Rstats::Double, Rstats::Double);
    Rstats::Logical more_than(Rstats::Integer, Rstats::Integer);
    Rstats::Logical more_than(Rstats::Logical, Rstats::Logical);

    Rstats::Logical less_than(Rstats::Character, Rstats::Character);
    Rstats::Logical less_than(Rstats::Complex, Rstats::Complex);
    Rstats::Logical less_than(Rstats::Double, Rstats::Double);
    Rstats::Logical less_than(Rstats::Integer, Rstats::Integer);
    Rstats::Logical less_than(Rstats::Logical, Rstats::Logical);

    Rstats::Logical more_than_or_equal(Rstats::Character, Rstats::Character);
    Rstats::Logical more_than_or_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical more_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical more_than_or_equal(Rstats::Integer, Rstats::Integer);
    Rstats::Logical more_than_or_equal(Rstats::Logical, Rstats::Logical);

    Rstats::Logical less_than_or_equal(Rstats::Character, Rstats::Character);
    Rstats::Logical less_than_or_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical less_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical less_than_or_equal(Rstats::Integer, Rstats::Integer);
    Rstats::Logical less_than_or_equal(Rstats::Logical, Rstats::Logical);

    Rstats::Logical is_infinite(Rstats::Character);
    Rstats::Logical is_infinite(Rstats::Complex);
    Rstats::Logical is_infinite(Rstats::Double);
    Rstats::Logical is_infinite(Rstats::Integer);
    Rstats::Logical is_infinite(Rstats::Logical);

    Rstats::Logical is_finite(Rstats::Character);
    Rstats::Logical is_finite(Rstats::Complex);
    Rstats::Logical is_finite(Rstats::Double);
    Rstats::Logical is_finite(Rstats::Integer);
    Rstats::Logical is_finite(Rstats::Logical);

    Rstats::Logical is_nan(Rstats::Character);
    Rstats::Logical is_nan(Rstats::Complex);
    Rstats::Logical is_nan(Rstats::Double);
    Rstats::Logical is_nan(Rstats::Integer);
    Rstats::Logical is_nan(Rstats::Logical);

    Rstats::Character as_character(Rstats::Character);
    Rstats::Character as_character(Rstats::Complex);
    Rstats::Character as_character(Rstats::Double);
    Rstats::Character as_character(Rstats::Integer);
    Rstats::Character as_character(Rstats::Logical);

    Rstats::Double as_double(Rstats::Character);
    Rstats::Double as_double(Rstats::Complex);
    Rstats::Double as_double(Rstats::Double);
    Rstats::Double as_double(Rstats::Integer);
    Rstats::Double as_double(Rstats::Logical);
  }

  class Vector {
    public:
    
    Rstats::Type::Enum type;
    std::map<Rstats::Integer, Rstats::Integer>* na_positions;
    void* values;
    
    Rstats::Integer get_length();
    
    template<class T>
    std::vector<T>* get_values() {
      return (std::vector<T>*)this->values;
    }

    template<class T>
    void set_value(Rstats::Integer pos, T value) {
      (*this->get_values<T>())[pos] = value;
    } // Rstats::Character is specialized

    template <class T>
    T get_value(Rstats::Integer pos) {
      return (*this->get_values<T>())[pos];
    }
    
    Rstats::Type::Enum get_type();

    void add_na_position(Rstats::Integer);
    bool exists_na_position(Rstats::Integer position);
    void merge_na_positions(std::map<Rstats::Integer, Rstats::Integer>*);
    std::map<Rstats::Integer, Rstats::Integer>* get_na_positions();
    
    ~Vector();
  };

  template <>
  void Vector::set_value<Rstats::Character>(Rstats::Integer pos, Rstats::Character value);
  
  // Rstats::VectorFunc
  namespace VectorFunc {
    template<class T>
    Rstats::Vector* new_vector(Rstats::Integer);
    template<>
    Rstats::Vector* new_vector<Rstats::Double>(Rstats::Integer);
    template<>
    Rstats::Vector* new_vector<Rstats::Integer>(Rstats::Integer);
    template<>
    Rstats::Vector* new_vector<Rstats::Complex>(Rstats::Integer);
    template<>
    Rstats::Vector* new_vector<Rstats::Character>(Rstats::Integer);
    template<>
    Rstats::Vector* new_vector<Rstats::Logical>(Rstats::Integer);
    
    template <class T>
    Rstats::Vector* new_vector(Rstats::Integer length, T value) {
      Rstats::Vector* v1 = new_vector<T>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        v1->set_value<T>(i, value);
      }
      return v1;
    };

    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_unary_math(T_OUT (*func)(T_IN), Rstats::Vector* v1) {
      
      Rstats::Integer length = v1->get_length();
      
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<T_OUT>(length);
      
      for (Rstats::Integer i = 0; i < length; i++) {
        v_out->set_value<T_OUT>(i, (*func)(v1->get_value<T_IN>(i)));
      }
      
      v_out->merge_na_positions(v1->get_na_positions());
      
      return v_out;
    }

    template <class T_IN>
    Rstats::Vector* operate_unary_is(Rstats::Logical (*func)(T_IN), Rstats::Vector* v1) {
      
      Rstats::Integer length = v1->get_length();
      
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
      
      for (Rstats::Integer i = 0; i < length; i++) {
        if (v1->exists_na_position(i)) {
          v_out->set_value<Rstats::Logical>(i, 0);
        }
        else {
          v_out->set_value<Rstats::Logical>(i, (*func)(v1->get_value<T_IN>(i)));
        }
      }
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* operate_unary_as(T_OUT (*func)(T_IN), Rstats::Vector* v1) {
      
      Rstats::Integer length = v1->get_length();
      
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<T_OUT>(length);
      
      Rstats::Logical na_produced = 0;
      for (Rstats::Integer i = 0; i < length; i++) {
        try {
          v_out->set_value<T_OUT>(i, (*func)(v1->get_value<T_IN>(i)));
        }
        catch (...) {
          v_out->add_na_position(i);
          na_produced = 1;
        }
      }
      
      if (na_produced) {
        warn("Warning message:\nNAs introduced by coercion");
      }

      v_out->merge_na_positions(v1->get_na_positions());
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* as_character(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::as_character;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* as_double(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::as_double;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1);
      
      return v_out;
    }
    
    template <class T_IN>
    Rstats::Vector* is_na(Rstats::Vector* v1) {
      
      Rstats::Integer length = v1->get_length();
      
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
      
      for (Rstats::Integer i = 0; i < length; i++) {
        if (v1->exists_na_position(i)) {
          v_out->set_value<Rstats::Logical>(i, 1);
        }
        else {
          v_out->set_value<Rstats::Logical>(i, 0);
        }
      }
      
      return v_out;
    }
    
    template <class T_IN, class T_OUT>
    Rstats::Vector* sin(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::sin;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* tanh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::tanh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* cos(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::cos;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* tan(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::tan;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* sinh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::sinh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* cosh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::cosh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* log(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::log;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* logb(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::logb;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* log10(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::log10;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* log2(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::log2;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* acos(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::acos;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* acosh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::acosh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* asinh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::asinh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* atanh(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::atanh;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* Conj(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::Conj;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* asin(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::asin;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* atan(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::atan;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* sqrt(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::sqrt;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* expm1(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::expm1;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* exp(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::exp;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* negate(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::negate;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* Arg(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::Arg;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* abs(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::abs;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* Mod(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::Mod;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* Re(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::Re;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN, class T_OUT>
    Rstats::Vector* Im(Rstats::Vector* v1) {
      T_OUT (*func)(T_IN) = &Rstats::ElementFunc::Im;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_math(func, v1);
      
      return v_out;
    }

    template <class T_IN>
    Rstats::Vector* is_infinite(Rstats::Vector* v1) {
      Rstats::Logical (*func)(T_IN) = &Rstats::ElementFunc::is_infinite;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_is(func, v1);
      
      return v_out;
    }

    template <class T_IN>
    Rstats::Vector* is_nan(Rstats::Vector* v1) {
      Rstats::Logical (*func)(T_IN) = &Rstats::ElementFunc::is_nan;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_is(func, v1);
      
      return v_out;
    }

    template <class T_IN>
    Rstats::Vector* is_finite(Rstats::Vector* v1) {
      Rstats::Logical (*func)(T_IN) = &Rstats::ElementFunc::is_finite;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_is(func, v1);
      
      return v_out;
    }
  }
  // Rstats::Func
  namespace Func {
    SV* fix_length(SV*, SV*, SV*);
    SV* fix_type(SV*, SV*, SV*);
    
    SV* new_array(SV*);
    void set_vector(SV*, SV*, Rstats::Vector*);
    Rstats::Vector* get_vector(SV*, SV*);
    SV* c_(SV*, SV*);
    SV* c_character(SV*, SV*);
    SV* c_double(SV*, SV*);
    SV* c_integer(SV*, SV*);
    SV* c_logical(SV*, SV*);
    SV* c_complex(SV*, SV*);

    SV* new_NULL(SV*); /* r->NULL */
    SV* new_NA(SV*); /* r->NA */
    SV* new_NaN(SV*); /* r->NaN */
    SV* new_Inf(SV*); /* r->Inf */
    SV* new_FALSE(SV*); /* r->FALSE */
    SV* new_TRUE(SV*); /* r->TRUE */

    SV* to_object(SV*, SV*);
    SV* pi(SV*);
    SV* is_null (SV*, SV*);
    SV* is_vector(SV*, SV*);
    SV* values(SV*, SV*);
    SV* is_matrix(SV*, SV*);
    SV* is_array(SV*, SV*);
    SV* is_numeric(SV*, SV*);
    SV* type(SV*, SV*);
    SV* Typeof(SV*, SV*); // r->typeof
    Rstats::Logical to_bool(SV*, SV*);
    SV* is_double(SV*, SV*);
    SV* is_integer(SV*, SV*);
    SV* is_complex(SV*, SV*);
    SV* is_character(SV*, SV*);
    SV* is_logical(SV*, SV*);
    SV* is_data_frame(SV*, SV*);
    SV* is_list(SV*, SV*);
    SV* as_vector(SV*, SV*);
    SV* new_data_frame(SV*);
    SV* new_list(SV*);
    SV* copy_attrs_to(SV*, SV*, SV*);
    SV* copy_attrs_to(SV*, SV*, SV*, SV*);

    SV* as_integer(SV*, SV*);
    SV* as_logical(SV*, SV*);
    SV* as_complex(SV*, SV*);
    SV* as_double(SV*, SV*);
    SV* as_numeric(SV*, SV*);
    SV* as_character(SV*, SV*);
    SV* as(SV*, SV*, SV*);

    SV* is_finite(SV*, SV*);
    SV* is_infinite(SV*, SV*);
    SV* is_nan(SV*, SV*);
    SV* is_na(SV*, SV*);
    SV* is_factor(SV*, SV*);
    SV* is_ordered(SV*, SV*);
    SV* clone(SV*, SV*);
    SV* dim_as_array(SV*, SV*);
    SV* decompose(SV*, SV*);
    SV* compose(SV*, SV*, SV*);
    SV* array(SV*, SV*);
    SV* array(SV*, SV*, SV*);
    SV* array_with_opt(SV*, SV*);
    SV* args_h(SV*, SV*, SV*);
    SV* as_array(SV*, SV*);
    // class
    SV* Class(SV*, SV*);
    SV* Class(SV*, SV*, SV*);
    SV* levels(SV*, SV*);
    SV* levels(SV*, SV*, SV*);
    SV* mode(SV*, SV*);
    SV* mode(SV*, SV*, SV*);
    
    Rstats::Integer get_length(SV*, SV*);
    SV* get_length_sv(SV*, SV*);
    
    // dim
    SV* dim(SV*, SV*, SV*);
    SV* dim(SV*, SV*);
    
    SV* length(SV*, SV*);
    SV* names(SV*, SV*, SV*);
    SV* names(SV*, SV*);
    
    SV* tanh(SV*, SV*);
    SV* Mod(SV*, SV*);
    SV* Arg(SV*, SV*);
    SV* Conj(SV*, SV*);
    SV* Re(SV*, SV*);
    SV* Im(SV*, SV*);
    SV* abs(SV*, SV*);
    SV* acos(SV*, SV*);
    SV* acosh(SV*, SV*);
    SV* asin(SV*, SV*);
    SV* asinh(SV*, SV*);
    SV* atan(SV*, SV*);
    SV* atanh(SV*, SV*);
    SV* cos(SV*, SV*);
    SV* cosh(SV*, SV*);
    SV* cumsum(SV*, SV*);
    SV* cumprod(SV*, SV*);
    SV* exp(SV*, SV*);
    SV* expm1(SV*, SV*);
    SV* log(SV*, SV*);
    SV* logb(SV*, SV*);
    SV* log2(SV*, SV*);
    SV* log10(SV*, SV*);
    SV* prod(SV*, SV*);
    SV* sinh(SV*, SV*);
    SV* sqrt(SV*, SV*);
    SV* tan(SV*, SV*);
    SV* sin(SV*, SV*);
    SV* sum(SV*, SV*);
    SV* negate(SV*, SV*);
    SV* operate_binary(SV*, Rstats::Vector* (*func)(Rstats::Vector*, Rstats::Vector*), SV*, SV*);
    SV* upgrade_type_avrv(SV*, SV*);
    void upgrade_type(SV*, Rstats::Integer, ...);
    SV* upgrade_length_avrv(SV*, SV*);
    void upgrade_length(SV*, Rstats::Integer, ...);
    char* get_type(SV*, SV*);
    SV* get_type_sv(SV*, SV*);
    char* get_object_type(SV*, SV*);
    SV* create_sv_value(SV*, SV*, Rstats::Integer);
    SV* create_sv_values(SV*, SV*);
    
    SV* atan2(SV*, SV*, SV*);
    SV* add(SV*, SV*, SV*);
    SV* subtract(SV*, SV*, SV*);
    SV* multiply(SV*, SV*, SV*);
    SV* divide(SV*, SV*, SV*);
    SV* remainder(SV*, SV*, SV*);
    SV* pow(SV*, SV*, SV*);
    SV* less_than(SV*, SV*, SV*);
    SV* less_than_or_equal(SV*, SV*, SV*);
    SV* more_than(SV*, SV*, SV*);
    SV* more_than_or_equal(SV*, SV*, SV*);
    SV* equal(SV*, SV*, SV*);
    SV* not_equal(SV*, SV*, SV*);
    SV* And(SV*, SV*, SV*);
    SV* Or(SV*, SV*, SV*);

    SV* sin(SV*, SV*);
    
    template <class T>
    SV* new_vector(SV*);
    template <>
    SV* new_vector<Rstats::Character>(SV*);
    template <>
    SV* new_vector<Rstats::Complex>(SV*);
    template <>
    SV* new_vector<Rstats::Double>(SV*);
    template <>
    SV* new_vector<Rstats::Integer>(SV*);
    template <>
    SV* new_vector<Rstats::Logical>(SV*);
    
    template <class T>
    SV* new_vector(SV* sv_r, Rstats::Vector* v1) {
      SV* sv_x_out = Rstats::Func::new_vector<T>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x_out, v1);
      
      return sv_x_out;
    }
    
    template <class T_IN, class T_OUT>
    SV* operate_unary_math(SV* sv_r, T_OUT (*func)(T_IN), SV* sv_x1) {
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<T_OUT>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        try {
          v2->set_value<T_OUT>(i, (*func)(v1->get_value<T_IN>(i)));
        }
        catch (const char* e) {
          v2->add_na_position(i);
        }
      }
      v2->merge_na_positions(v1->get_na_positions());
      
      SV* sv_x2 = Rstats::Func::new_vector<T_OUT>(sv_r);
      set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
    
    template <class T_IN, class T_OUT>
    SV* operate_binary(SV* sv_r, T_OUT (*func)(T_IN, T_IN), SV* sv_x1, SV* sv_x2) {

      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Vector* v2 = Rstats::Func::get_vector(sv_r, sv_x2);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      Rstats::Vector* v3 = Rstats::VectorFunc::new_vector<T_OUT>(length);

      for (Rstats::Integer i = 0; i < length; i++) {
        try {
          v3->set_value<T_OUT>(
            i,
            (*func)(
              v1->get_value<T_IN>(i),
              v2->get_value<T_IN>(i)
            )
          );
        }
        catch (const char* e) {
          v3->add_na_position(i);
        }
      }
      v3->merge_na_positions(v1->get_na_positions());
      v3->merge_na_positions(v2->get_na_positions());
      
      SV* sv_x3 = Rstats::Func::new_vector<T_OUT>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x3, v3);
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x3);
      
      return sv_x3;
    }
  }
}

#endif
