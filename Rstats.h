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

  REGEXP* pl_pregcomp (SV*, IV);
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
  IV pl_av_len (AV*);
  IV pl_av_len (SV*);
  SV* pl_av_fetch(AV*, IV);
  SV* pl_av_fetch(SV*, IV);
  bool pl_hv_exists(HV*, char*);
  bool pl_hv_exists(SV*, char*);
  SV* pl_hv_delete(HV*, char*);
  SV* pl_hv_delete(SV*, char*);
  SV* pl_hv_fetch(HV*, const char*);
  SV* pl_hv_fetch(SV*, const char*);
  void pl_av_store(AV*, IV, SV*);
  void pl_av_store(SV*, IV, SV*);
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
  IV pl_pregexec(SV*, REGEXP*);
  
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
    IV is_perl_number(SV*);
    SV* cross_product(SV*);
    SV* pos_to_index(SV*, SV*);
    SV* index_to_pos(SV*, SV*);
    SV* looks_like_complex(SV*);
    SV* looks_like_logical(SV*);
    SV* looks_like_na(SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double(SV*);
    NV pi();
  }

  namespace ElementFunc {

    Rstats::Complex add(Rstats::Complex, Rstats::Complex);
    Rstats::Double add(Rstats::Double, Rstats::Double);
    IV add(Rstats::Integer, Rstats::Integer);

    Rstats::Complex subtract(Rstats::Complex, Rstats::Complex);
    Rstats::Double subtract(Rstats::Double, Rstats::Double);
    Rstats::Integer subtract(Rstats::Integer, Rstats::Integer);

    Rstats::Complex multiply(Rstats::Complex, Rstats::Complex);
    Rstats::Double multiply(Rstats::Double, Rstats::Double);
    Rstats::Integer multiply(Rstats::Integer, Rstats::Integer);

    Rstats::Complex divide(Rstats::Complex, Rstats::Complex);
    Rstats::Double divide(Rstats::Double, Rstats::Double);
    Rstats::Double divide(Rstats::Integer, Rstats::Integer);

    Rstats::Complex pow(Rstats::Complex, Rstats::Complex);
    Rstats::Double pow(Rstats::Double, Rstats::Double);
    Rstats::Double pow(Rstats::Integer, Rstats::Integer);

    Rstats::Complex remainder(Rstats::Complex, Rstats::Complex);
    Rstats::Double remainder(Rstats::Double, Rstats::Double);
    Rstats::Double remainder(Rstats::Integer, Rstats::Integer);

    Rstats::Double Re(Rstats::Complex);
    Rstats::Double Re(Rstats::Double);
    Rstats::Double Re(Rstats::Integer);

    Rstats::Double Im(Rstats::Complex);
    Rstats::Double Im(Rstats::Double);
    Rstats::Double Im(Rstats::Integer);

    Rstats::Complex Conj(Rstats::Complex);
    Rstats::Double Conj(Rstats::Double);
    Rstats::Double Conj(Rstats::Integer);

    Rstats::Complex sin(Rstats::Complex);
    Rstats::Double sin(Rstats::Double);
    Rstats::Double sin(Rstats::Integer);
    
    Rstats::Complex cos(Rstats::Complex);
    Rstats::Double cos(Rstats::Double);
    Rstats::Double cos(Rstats::Integer);

    Rstats::Complex tan(Rstats::Complex);
    Rstats::Double tan(Rstats::Double);
    Rstats::Double tan(Rstats::Integer);

    Rstats::Complex sinh(Rstats::Complex);
    Rstats::Double sinh(Rstats::Double);
    Rstats::Double sinh(Rstats::Integer);

    Rstats::Complex cosh(Rstats::Complex);
    Rstats::Double cosh(Rstats::Double);
    Rstats::Double cosh(Rstats::Integer);

    Rstats::Complex tanh (Rstats::Complex z);
    Rstats::Double tanh(Rstats::Double);
    Rstats::Double tanh(Rstats::Integer);

    Rstats::Double abs(Rstats::Complex);
    Rstats::Double abs(Rstats::Double);
    Rstats::Double abs(Rstats::Integer);

    Rstats::Double Mod(Rstats::Complex);
    Rstats::Double Mod(Rstats::Double);
    Rstats::Double Mod(Rstats::Integer);

    Rstats::Complex log(Rstats::Complex);
    Rstats::Double log(Rstats::Double);
    Rstats::Double log(Rstats::Integer);

    Rstats::Complex logb(Rstats::Complex);
    Rstats::Double logb(Rstats::Double);
    Rstats::Double logb(Rstats::Integer);

    Rstats::Complex log10(Rstats::Complex);
    Rstats::Double log10(Rstats::Double);
    Rstats::Double log10(Rstats::Integer);

    Rstats::Complex log2(Rstats::Complex);
    Rstats::Double log2(Rstats::Double);
    Rstats::Double log2(Rstats::Integer);
    
    Rstats::Complex expm1(Rstats::Complex);
    Rstats::Double expm1(Rstats::Double);
    Rstats::Double expm1(Rstats::Integer);

    Rstats::Double Arg(Rstats::Complex);
    Rstats::Double Arg(Rstats::Double);
    Rstats::Double Arg(Rstats::Integer);

    Rstats::Complex exp(Rstats::Complex);
    Rstats::Double exp(Rstats::Double);
    Rstats::Double exp(Rstats::Integer);

    Rstats::Complex sqrt(Rstats::Complex);
    Rstats::Double sqrt(Rstats::Double);
    Rstats::Double sqrt(Rstats::Integer);

    Rstats::Complex atan(Rstats::Complex);
    Rstats::Double atan(Rstats::Double);
    Rstats::Double atan(Rstats::Integer);

    Rstats::Complex asin(Rstats::Complex);
    Rstats::Double asin(Rstats::Double);
    Rstats::Double asin(Rstats::Integer);

    Rstats::Complex acos(Rstats::Complex);
    Rstats::Double acos(Rstats::Double);
    Rstats::Double acos(Rstats::Integer);

    Rstats::Complex asinh(Rstats::Complex);
    Rstats::Double asinh(Rstats::Double);
    Rstats::Double asinh(Rstats::Integer);

    Rstats::Complex acosh(Rstats::Complex);
    Rstats::Double acosh(Rstats::Double);
    Rstats::Double acosh(Rstats::Integer);

    Rstats::Complex atanh(Rstats::Complex);
    Rstats::Double atanh(Rstats::Double);
    Rstats::Double atanh(Rstats::Integer);
    
    Rstats::Complex negation(Rstats::Complex);
    Rstats::Double negation(Rstats::Double);
    Rstats::Integer negation(Rstats::Integer);

    Rstats::Complex atan2(Rstats::Complex, Rstats::Complex);
    Rstats::Double atan2(Rstats::Double, Rstats::Double);
    Rstats::Double atan2(Rstats::Integer, Rstats::Integer);

    Rstats::Logical And(SV*, SV*);
    Rstats::Logical And(Rstats::Complex, Rstats::Complex);
    Rstats::Logical And(Rstats::Double, Rstats::Double);
    Rstats::Logical And(Rstats::Integer, Rstats::Integer);

    Rstats::Logical Or(SV*, SV*);
    Rstats::Logical Or(Rstats::Complex, Rstats::Complex);
    Rstats::Logical Or(Rstats::Double, Rstats::Double);
    Rstats::Logical Or(Rstats::Integer, Rstats::Integer);
    
    Rstats::Logical equal(SV*, SV*);
    Rstats::Logical equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical equal(Rstats::Double, Rstats::Double);
    Rstats::Logical equal(Rstats::Integer, Rstats::Integer);

    Rstats::Logical not_equal(SV*, SV*);
    Rstats::Logical not_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical not_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical not_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Logical more_than(SV*, SV*);
    Rstats::Logical more_than(Rstats::Complex, Rstats::Complex);
    Rstats::Logical more_than(Rstats::Double, Rstats::Double);
    Rstats::Logical more_than(Rstats::Integer, Rstats::Integer);

    Rstats::Logical less_than(SV*, SV*);
    Rstats::Logical less_than(Rstats::Complex, Rstats::Complex);
    Rstats::Logical less_than(Rstats::Double, Rstats::Double);
    Rstats::Logical less_than(Rstats::Integer, Rstats::Integer);

    Rstats::Logical more_than_or_equal(SV*, SV*);
    Rstats::Logical more_than_or_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical more_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical more_than_or_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Logical less_than_or_equal(SV*, SV*);
    Rstats::Logical less_than_or_equal(Rstats::Complex, Rstats::Complex);
    Rstats::Logical less_than_or_equal(Rstats::Double, Rstats::Double);
    Rstats::Logical less_than_or_equal(Rstats::Integer, Rstats::Integer);

    Rstats::Logical is_infinite(SV*);
    Rstats::Logical is_infinite(Rstats::Complex);
    Rstats::Logical is_infinite(Rstats::Double);
    Rstats::Logical is_infinite(Rstats::Integer);

    Rstats::Logical is_finite(SV*);
    Rstats::Logical is_finite(Rstats::Complex);
    Rstats::Logical is_finite(Rstats::Double);
    Rstats::Logical is_finite(Rstats::Integer);

    Rstats::Logical is_nan(SV*);
    Rstats::Logical is_nan(Rstats::Complex);
    Rstats::Logical is_nan(Rstats::Double);
    Rstats::Logical is_nan(Rstats::Integer);
  }

  typedef struct {
    Rstats::Type::Enum type;
    std::map<IV, IV>* na_positions;
    void* values;
  } Vector;

  // Rstats::VectorFunc
  namespace VectorFunc {
    Rstats::Vector* new_empty_vector();
    void delete_vector(Rstats::Vector*);
    
    Rstats::Type::Enum get_type(Rstats::Vector*);
    void add_na_position(Rstats::Vector*, IV);
    bool exists_na_position(Rstats::Vector*, IV position);
    void merge_na_positions(Rstats::Vector*, Rstats::Vector*);
    std::map<IV, IV>* get_na_positions(Rstats::Vector*);
    IV get_length (Rstats::Vector*);
    
    Rstats::Vector* new_na();
    Rstats::Vector* new_null();
    
    Rstats::Vector* as_character(Rstats::Vector*);
    Rstats::Vector* as_double(Rstats::Vector*);
    Rstats::Vector* as_numeric(Rstats::Vector*);
    Rstats::Vector* as_integer(Rstats::Vector*);
    Rstats::Vector* as_complex(Rstats::Vector*);
    Rstats::Vector* as_logical(Rstats::Vector*);

    template<class T>
    std::vector<T>* get_values(Rstats::Vector* v1) {
      return (std::vector<T>*)v1->values;
    }
    template <class T>
    T get_value(Rstats::Vector* v1, IV pos) {
      return (*Rstats::VectorFunc::get_values<T>(v1))[pos];
    }
    template <>
    Rstats::Character get_value<Rstats::Character>(Rstats::Vector* v1, IV pos);
    
    template<class T>
    void set_value(Rstats::Vector* v1, IV pos, T value) {
      (*Rstats::VectorFunc::get_values<T>(v1))[pos] = value;
    }
    template <>
    void set_value<Rstats::Character>(Rstats::Vector* v1, IV pos, Rstats::Character value);

    template<class T>
    Rstats::Vector* new_vector(IV);
    template<>
    Rstats::Vector* new_vector<Rstats::Double>(IV);
    template<>
    Rstats::Vector* new_vector<Rstats::Integer>(IV);
    template<>
    Rstats::Vector* new_vector<Rstats::Complex>(IV);
    template<>
    Rstats::Vector* new_vector<Rstats::Character>(IV);
    template<>
    Rstats::Vector* new_vector<Rstats::Logical>(IV);
    
    template <class T>
    Rstats::Vector* new_vector(IV length, T value) {
      Rstats::Vector* v1 = new_vector<T>(length);
      for (IV i = 0; i < length; i++) {
        Rstats::VectorFunc::set_value<T>(v1, i, value);
      }
      return v1;
    };
  }
  // Rstats::Func
  namespace Func {
    SV* fix_length(SV*, SV*, SV*);
    SV* fix_type(SV*, SV*, SV*);
    
    SV* new_array(SV*);
    void set_vector(SV*, SV*, Rstats::Vector*);
    Rstats::Vector* get_vector(SV*, SV*);
    SV* c(SV*, SV*);
    SV* c_character(SV*, SV*);
    SV* c_double(SV*, SV*);
    SV* c_integer(SV*, SV*);
    SV* c_logical(SV*, SV*);
    SV* c_complex(SV*, SV*);

    SV* new_null(SV*); /* r->NULL */
    SV* new_vector(SV*);
    SV* new_na(SV*); /* r->NA */
    SV* new_nan(SV*); /* r->NaN */
    SV* new_inf(SV*); /* r->Inf */
    SV* new_false(SV*); /* r->FALSE */
    SV* new_true(SV*); /* r->TRUE */

    SV* to_c(SV*, SV*);
    SV* pi(SV*);
    SV* is_null (SV*, SV*);
    SV* is_vector(SV*, SV*);
    SV* length_value(SV*, SV*);
    SV* values(SV*, SV*);
    SV* is_matrix(SV*, SV*);
    SV* is_array(SV*, SV*);
    SV* is_numeric(SV*, SV*);
    SV* type(SV*, SV*);
    SV* Typeof(SV*, SV*); // r->typeof
    IV to_bool(SV*, SV*);
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
    SV* negation(SV*, SV*);
    SV* operate_binary(SV*, Rstats::Vector* (*func)(Rstats::Vector*, Rstats::Vector*), SV*, SV*);
    SV* upgrade_type_avrv(SV*, SV*);
    void upgrade_type(SV*, IV, ...);
    SV* upgrade_length_avrv(SV*, SV*);
    void upgrade_length(SV*, IV, ...);
    char* get_type(SV*, SV*);
    SV* get_type_sv(SV*, SV*);
    char* get_object_type(SV*, SV*);
    SV* create_sv_value(SV*, SV*, IV);
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
    SV* new_empty_vector(SV*);
    template <>
    SV* new_empty_vector<Rstats::Character>(SV*);
    template <>
    SV* new_empty_vector<Rstats::Complex>(SV*);
    template <>
    SV* new_empty_vector<Rstats::Double>(SV*);
    template <>
    SV* new_empty_vector<Rstats::Integer>(SV*);
    template <>
    SV* new_empty_vector<Rstats::Logical>(SV*);

    template <class T_IN, class T_OUT>
    SV* operate_unary(SV* sv_r, T_OUT (*func)(T_IN), SV* sv_x1) {
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<T_OUT>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        try {
          Rstats::VectorFunc::set_value<T_OUT>(v2, i, (*func)(Rstats::VectorFunc::get_value<T_IN>(v1, i)));
        }
        catch (const char* e) {
          Rstats::VectorFunc::add_na_position(v2, i);
        }
      }
      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<T_OUT>(sv_r);
      set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
    
    template <class T_IN, class T_OUT>
    SV* operate_binary(SV* sv_r, T_OUT (*func)(T_IN, T_IN), SV* sv_x1, SV* sv_x2) {

      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Vector* v2 = Rstats::Func::get_vector(sv_r, sv_x2);

      IV length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v3 = Rstats::VectorFunc::new_vector<T_OUT>(length);

      for (IV i = 0; i < length; i++) {
        try {
          Rstats::VectorFunc::set_value<T_OUT>(
            v3,
            i,
            (*func)(
              Rstats::VectorFunc::get_value<T_IN>(v1, i),
              Rstats::VectorFunc::get_value<T_IN>(v2, i)
            )
          );
        }
        catch (const char* e) {
          Rstats::VectorFunc::add_na_position(v3, i);
        }
      }
      Rstats::VectorFunc::merge_na_positions(v3, v1);
      Rstats::VectorFunc::merge_na_positions(v3, v2);
      
      SV* sv_x3 = Rstats::Func::new_empty_vector<T_OUT>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x3, v3);
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x3);
      
      return sv_x3;
    }
  }
}

#endif
