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
  SV* pl_new_ref(SV*);
  SV* pl_new_sv_sv(SV*);
  SV* pl_new_sv_pv(const char*);
  SV* pl_new_sv_iv(IV);
  SV* pl_new_sv_nv(NV);
  AV* pl_new_av();
  SV* pl_new_av_ref();
  HV* pl_new_hv();
  SV* pl_new_hv_ref();
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
    SV* sv_obj_addr_ref = pl_new_ref(sv_obj_addr);
    SV* perl_obj = sv_bless(sv_obj_addr_ref, gv_stashpv(class_name, 1));
    
    return perl_obj;
  }
  IV pl_pregexec(SV*, REGEXP*);

  namespace VectorType {
    enum Enum {
      LOGICAL = 0,
      INTEGER = 1 ,
      DOUBLE = 2,
      COMPLEX = 3,
      CHARACTER = 4
    };
  }

  namespace Util {
    SV* args(SV*, SV*, SV*);
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

    std::complex<NV> add(std::complex<NV>, std::complex<NV>);
    NV add(NV, NV);
    IV add(IV, IV);

    std::complex<NV> subtract(std::complex<NV>, std::complex<NV>);
    NV subtract(NV, NV);
    IV subtract(IV, IV);

    std::complex<NV> multiply(std::complex<NV>, std::complex<NV>);
    NV multiply(NV, NV);
    IV multiply(IV, IV);

    std::complex<NV> divide(std::complex<NV>, std::complex<NV>);
    NV divide(NV, NV);
    NV divide(IV, IV);

    std::complex<NV> pow(std::complex<NV>, std::complex<NV>);
    NV pow(NV, NV);
    NV pow(IV, IV);

    std::complex<NV> reminder(std::complex<NV>, std::complex<NV>);
    NV reminder(NV, NV);
    IV reminder(IV, IV);

    NV Re(std::complex<NV>);
    NV Re(NV);
    NV Re(IV);

    NV Im(std::complex<NV>);
    NV Im(NV);
    NV Im(IV);

    std::complex<NV> Conj(std::complex<NV>);
    NV Conj(NV);
    NV Conj(IV);

    std::complex<NV> sin(std::complex<NV>);
    NV sin(NV);
    NV sin(IV);
    
    std::complex<NV> cos(std::complex<NV>);
    NV cos(NV);
    NV cos(IV);

    std::complex<NV> tan(std::complex<NV>);
    NV tan(NV);
    NV tan(IV);

    std::complex<NV> sinh(std::complex<NV>);
    NV sinh(NV);
    NV sinh(IV);

    std::complex<NV> cosh(std::complex<NV>);
    NV cosh(NV);
    NV cosh(IV);

    std::complex<NV> tanh (std::complex<NV> z);
    NV tanh(NV);
    NV tanh(IV);

    NV abs(std::complex<NV>);
    NV abs(NV);
    NV abs(IV);

    NV Mod(std::complex<NV>);
    NV Mod(NV);
    NV Mod(IV);

    std::complex<NV> log(std::complex<NV>);
    NV log(NV);
    NV log(IV);

    std::complex<NV> logb(std::complex<NV>);
    NV logb(NV);
    NV logb(IV);

    std::complex<NV> log10(std::complex<NV>);
    NV log10(NV);
    NV log10(IV);

    std::complex<NV> log2(std::complex<NV>);
    NV log2(NV);
    NV log2(IV);
    
    std::complex<NV> expm1(std::complex<NV>);
    NV expm1(NV);
    NV expm1(IV);

    NV Arg(std::complex<NV>);
    NV Arg(NV);
    NV Arg(IV);

    std::complex<NV> exp(std::complex<NV>);
    NV exp(NV);
    NV exp(IV);

    std::complex<NV> sqrt(std::complex<NV>);
    NV sqrt(NV);
    NV sqrt(IV);

    std::complex<NV> atan(std::complex<NV>);
    NV atan(NV);
    NV atan(IV);

    std::complex<NV> asin(std::complex<NV>);
    NV asin(NV);
    NV asin(IV);

    std::complex<NV> acos(std::complex<NV>);
    NV acos(NV);
    NV acos(IV);

    std::complex<NV> asinh(std::complex<NV>);
    NV asinh(NV);
    NV asinh(IV);

    std::complex<NV> acosh(std::complex<NV>);
    NV acosh(NV);
    NV acosh(IV);

    std::complex<NV> atanh(std::complex<NV>);
    NV atanh(NV);
    NV atanh(IV);
    
    std::complex<NV> negation(std::complex<NV>);
    NV negation(NV);
    IV negation(IV);

    std::complex<NV> atan2(std::complex<NV>, std::complex<NV>);
    NV atan2(NV, NV);
    NV atan2(IV, IV);

    IV And(SV*, SV*);
    IV And(std::complex<NV>, std::complex<NV>);
    IV And(NV, NV);
    IV And(IV, IV);

    IV Or(SV*, SV*);
    IV Or(std::complex<NV>, std::complex<NV>);
    IV Or(NV, NV);
    IV Or(IV, IV);
    
    IV equal(SV*, SV*);
    IV equal(std::complex<NV>, std::complex<NV>);
    IV equal(NV, NV);
    IV equal(IV, IV);

    IV not_equal(SV*, SV*);
    IV not_equal(std::complex<NV>, std::complex<NV>);
    IV not_equal(NV, NV);
    IV not_equal(IV, IV);

    IV more_than(SV*, SV*);
    IV more_than(std::complex<NV>, std::complex<NV>);
    IV more_than(NV, NV);
    IV more_than(IV, IV);

    IV less_than(SV*, SV*);
    IV less_than(std::complex<NV>, std::complex<NV>);
    IV less_than(NV, NV);
    IV less_than(IV, IV);

    IV more_than_or_equal(SV*, SV*);
    IV more_than_or_equal(std::complex<NV>, std::complex<NV>);
    IV more_than_or_equal(NV, NV);
    IV more_than_or_equal(IV, IV);

    IV less_than_or_equal(SV*, SV*);
    IV less_than_or_equal(std::complex<NV>, std::complex<NV>);
    IV less_than_or_equal(NV, NV);
    IV less_than_or_equal(IV, IV);

    IV is_infinite(SV*);
    IV is_infinite(std::complex<NV>);
    IV is_infinite(NV);
    IV is_infinite(IV);

    IV is_finite(SV*);
    IV is_finite(std::complex<NV>);
    IV is_finite(NV);
    IV is_finite(IV);

    IV is_nan(SV*);
    IV is_nan(std::complex<NV>);
    IV is_nan(NV);
    IV is_nan(IV);
  }

  struct Vector {
    Rstats::VectorType::Enum type;
    std::map<IV, IV>* na_positions;
    void* values;
  };
  
  template <typename T>
  struct Vector2 {
    std::vector<T>* values;
    std::map<IV, IV>* na_positions;
  };

  // Macro for Rstats::Vector
# define RSTATS_DEF_VECTOR_FUNC_UN_IS(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2 = Rstats::VectorFunc::new_logical(length); \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_character_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : invalid argument to %s()", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      for (IV i = 0; i < length; i++) { \
        if (Rstats::VectorFunc::exists_na_position(v1, i)) { \
          Rstats::VectorFunc::set_integer_value(v2, i, 0); \
        } \
      } \
      return v2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_UN_MATH(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2; \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          v2 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_complex_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          v2 = Rstats::VectorFunc::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : invalid argument to %s()", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      Rstats::VectorFunc::merge_na_positions(v2, v1); \
      return v2; \
    }
    
# define RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2; \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          v2 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_complex_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to Rstats::VectorFunc::%s", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      Rstats::VectorFunc::merge_na_positions(v2, v1); \
      return v2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2; \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          v2 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to Rstats::VectorFunc::%s", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      Rstats::VectorFunc::merge_na_positions(v2, v1); \
      return v2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1, Rstats::Vector* v2) { \
      if (Rstats::VectorFunc::get_type(v1) != Rstats::VectorFunc::get_type(v2)) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (Rstats::VectorFunc::get_length(v1) != Rstats::VectorFunc::get_length(v2)) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v3 = Rstats::VectorFunc::new_logical(length); \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_character_value(v1, i), Rstats::VectorFunc::get_character_value(v2, i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::VectorType::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_integer_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i), Rstats::VectorFunc::get_complex_value(v2, i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_integer_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i), Rstats::VectorFunc::get_double_value(v2, i)) ? 1 : 0); \
            } catch (const char* e) {\
              Rstats::VectorFunc::add_na_position(v3, i);\
            }\
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_integer_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i), Rstats::VectorFunc::get_integer_value(v2, i)) ? 1 : 0); \
            }\
            catch (const char* e) {\
              Rstats::VectorFunc::add_na_position(v3, i);\
            }\
          } \
          break; \
        default: \
          croak("Error in %s() : non-comparable argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      Rstats::VectorFunc::merge_na_positions(v3, v1); \
      Rstats::VectorFunc::merge_na_positions(v3, v2); \
      return v3; \
    }
    
# define RSTATS_DEF_VECTOR_FUNC_BIN_MATH(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1, Rstats::Vector* v2) { \
      if (Rstats::VectorFunc::get_type(v1) != Rstats::VectorFunc::get_type(v2)) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (Rstats::VectorFunc::get_length(v1) != Rstats::VectorFunc::get_length(v2)) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v3; \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          v3 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_complex_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i), Rstats::VectorFunc::get_complex_value(v2, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          v3 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i), Rstats::VectorFunc::get_double_value(v2, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          v3 = Rstats::VectorFunc::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_integer_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i), Rstats::VectorFunc::get_integer_value(v2, i))); \
            }\
            catch (const char* e) {\
              Rstats::VectorFunc::add_na_position(v3, i);\
            }\
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      Rstats::VectorFunc::merge_na_positions(v3, v1); \
      Rstats::VectorFunc::merge_na_positions(v3, v2); \
      return v3; \
    }

# define RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1, Rstats::Vector* v2) { \
      if (Rstats::VectorFunc::get_type(v1) != Rstats::VectorFunc::get_type(v2)) { \
        croak("Can't add different type(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      if (Rstats::VectorFunc::get_length(v1) != Rstats::VectorFunc::get_length(v2)) { \
        croak("Can't add different length(Rstats::VectorFunc::%s())", #FUNC_NAME); \
      } \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v3; \
      Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::VectorType::COMPLEX : \
          v3 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_complex_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_complex_value(v1, i), Rstats::VectorFunc::get_complex_value(v2, i))); \
          } \
          break; \
        case Rstats::VectorType::DOUBLE : \
          v3 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_double_value(v1, i), Rstats::VectorFunc::get_double_value(v2, i))); \
          } \
          break; \
        case Rstats::VectorType::INTEGER : \
        case Rstats::VectorType::LOGICAL : \
          v3 = Rstats::VectorFunc::new_double(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_double_value(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_integer_value(v1, i), Rstats::VectorFunc::get_integer_value(v2, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : non-numeric argument to %s()", #FUNC_NAME, #FUNC_NAME); \
      } \
      Rstats::VectorFunc::merge_na_positions(v3, v1); \
      Rstats::VectorFunc::merge_na_positions(v3, v2); \
      return v3; \
    }

  // Rstats::VectorFunc
  namespace VectorFunc {
    Rstats::Vector* new_vector();
    void delete_vector(Rstats::Vector*);
    SV* get_value(Rstats::Vector*, IV);
    SV* get_values(Rstats::Vector*);
    
    bool is_character (Rstats::Vector*);
    bool is_complex (Rstats::Vector*);
    bool is_double (Rstats::Vector*);
    bool is_integer (Rstats::Vector*);
    bool is_numeric (Rstats::Vector*);
    bool is_logical (Rstats::Vector*);
    
    template <typename T>
    Rstats::Vector2<T>* new_vector2 (IV length) {
      Rstats::Vector2<T>* v1 = new Rstats::Vector2<T>;
      v1->values = new std::vector<T>(length);
      v1->na_positions = new std::map<IV, IV>;
      
      return v1;
    }
    
    template <typename T>
    std::vector<T>* get_values2(Rstats::Vector2<T>* v1) {
      return (std::vector<T>*)v1->values;
    }
    
    template <typename T>
    IV get_length2 (Rstats::Vector2<T>* v1) {
      if (v1->values == NULL) {
        return 0;
      }
      
      return Rstats::VectorFunc::get_values2(v1)->size();
    }
    
    template <typename T>
    void set_value2(Rstats::Vector2<T>* v1, IV pos, T value) {
      (*Rstats::VectorFunc::get_values2(v1))[pos] = value;
    }
    
    template <typename T>
    void add_na_position2(Rstats::Vector2<T>* v1, IV position) {
      (*v1->na_positions)[position] = 1;
    }
    
    template <typename T2, typename T1>
    void merge_na_positions2(Rstats::Vector2<T2>* v2, Rstats::Vector2<T1>* v1) {
      for(std::map<IV, IV>::iterator it = v1->na_positions->begin(); it != v1->na_positions->end(); ++it) {
        Rstats::VectorFunc::add_na_position2(v2, it->first);
      }
    }
    
    template <typename T>
    T get_value2(Rstats::Vector2<T>* v1, IV pos) {
      return (*Rstats::VectorFunc::get_values2(v1))[pos];
    }
    
    template <typename T_func, typename T_out, typename T_in>
    Rstats::Vector2<T_out>* operate_un_math(T_func func, Rstats::Vector2<T_in>* v1) {
      IV length = Rstats::VectorFunc::get_length2(v1);
      Rstats::Vector2<T_out>* v2 = Rstats::VectorFunc::new_vector2<T_out>(length);
      for (IV i = 0; i < length; i++) {
        Rstats::VectorFunc::set_value2(v2, i, func(Rstats::VectorFunc::get_value2(v1, i)));
      }
      Rstats::VectorFunc::merge_na_positions2(v2, v1);
      return v2;
    }
    
    void sin2(Rstats::Vector2<SV*>* v1);
    Rstats::Vector2<std::complex<NV> >* sin2(Rstats::Vector2<std::complex<NV> >* v1);
    Rstats::Vector2<NV>* sin2(Rstats::Vector2<NV>* v1);
    Rstats::Vector2<NV>* sin2(Rstats::Vector2<IV>* v1);
        
    std::vector<SV*>* get_character_values(Rstats::Vector*);
    std::vector<std::complex<NV> >* get_complex_values(Rstats::Vector*);
    std::vector<NV>* get_double_values(Rstats::Vector*);
    std::vector<IV>* get_integer_values(Rstats::Vector*);
    
    Rstats::VectorType::Enum get_type(Rstats::Vector*);
    void add_na_position(Rstats::Vector*, IV);
    bool exists_na_position(Rstats::Vector*, IV position);
    void merge_na_positions(Rstats::Vector*, Rstats::Vector*);
    std::map<IV, IV>* get_na_positions(Rstats::Vector*);
    IV get_length (Rstats::Vector*);
    
    Rstats::Vector* new_character(IV, SV*);
    Rstats::Vector* new_character(IV);
    SV* get_character_value(Rstats::Vector*, IV);
    void set_character_value(Rstats::Vector*, IV, SV*);
    Rstats::Vector* new_complex(IV);
    Rstats::Vector* new_complex(IV, std::complex<NV>);
    std::complex<NV> get_complex_value(Rstats::Vector*, IV);
    void set_complex_value(Rstats::Vector*, IV, std::complex<NV>);
    Rstats::Vector* new_double(IV);
    Rstats::Vector* new_double(IV, NV);
    NV get_double_value(Rstats::Vector*, IV);
    void set_double_value(Rstats::Vector*, IV, NV);

    Rstats::Vector* new_integer(IV);
    Rstats::Vector* new_integer(IV, IV);
    
    IV get_integer_value(Rstats::Vector*, IV);
    void set_integer_value(Rstats::Vector*, IV, IV);
    
    Rstats::Vector* new_logical(IV);
    Rstats::Vector* new_logical(IV, IV);
    Rstats::Vector* new_true();
    Rstats::Vector* new_false();
    Rstats::Vector* new_nan();
    Rstats::Vector* new_negative_inf();
    Rstats::Vector* new_inf();
    Rstats::Vector* new_na();
    Rstats::Vector* new_null();
    
    Rstats::Vector* as (Rstats::Vector*, SV*);
    SV* to_string_pos(Rstats::Vector*, IV);
    SV* to_string(Rstats::Vector*);
    Rstats::Vector* as_character(Rstats::Vector*);
    Rstats::Vector* as_double(Rstats::Vector*);
    Rstats::Vector* as_numeric(Rstats::Vector*);
    Rstats::Vector* as_integer(Rstats::Vector*);
    Rstats::Vector* as_complex(Rstats::Vector*);
    Rstats::Vector* as_logical(Rstats::Vector*);

    Rstats::Vector* is_infinite(Rstats::Vector*);
    Rstats::Vector* is_finite(Rstats::Vector*);
    Rstats::Vector* is_nan(Rstats::Vector*);
    
    Rstats::Vector* negation(Rstats::Vector*);

    Rstats::Vector* sin(Rstats::Vector*);
    Rstats::Vector* cos(Rstats::Vector*);
    Rstats::Vector* tan(Rstats::Vector*);
    Rstats::Vector* sinh(Rstats::Vector*);
    Rstats::Vector* cosh(Rstats::Vector*);
    Rstats::Vector* tanh(Rstats::Vector*);
    Rstats::Vector* log(Rstats::Vector*);
    Rstats::Vector* logb(Rstats::Vector*);
    Rstats::Vector* log10(Rstats::Vector*);
    Rstats::Vector* log2(Rstats::Vector*);
    Rstats::Vector* expm1(Rstats::Vector*);
    Rstats::Vector* exp(Rstats::Vector*);
    Rstats::Vector* sqrt(Rstats::Vector*);
    Rstats::Vector* atan(Rstats::Vector*);
    Rstats::Vector* asin(Rstats::Vector*);
    Rstats::Vector* acos(Rstats::Vector*);
    Rstats::Vector* asinh(Rstats::Vector*);
    Rstats::Vector* acosh(Rstats::Vector*);
    Rstats::Vector* atanh(Rstats::Vector*);
    Rstats::Vector* Conj(Rstats::Vector*);

    Rstats::Vector* Arg(Rstats::Vector*);
    Rstats::Vector* abs(Rstats::Vector*);
    Rstats::Vector* Mod(Rstats::Vector*);
    Rstats::Vector* Re(Rstats::Vector*);
    Rstats::Vector* Im(Rstats::Vector*);

    Rstats::Vector* equal(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* not_equal(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* more_than(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* less_than(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* more_than_or_equal(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* less_than_or_equal(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* And(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* Or(Rstats::Vector*, Rstats::Vector*);

    Rstats::Vector* add(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* subtract(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* multiply(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* reminder(Rstats::Vector*, Rstats::Vector*);

    Rstats::Vector* divide(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* atan2(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* pow(Rstats::Vector*, Rstats::Vector*);
    
    Rstats::Vector* cumprod(Rstats::Vector*);
    Rstats::Vector* cumsum(Rstats::Vector*);
    Rstats::Vector* prod(Rstats::Vector*);
    Rstats::Vector* sum(Rstats::Vector*);
    Rstats::Vector* clone(Rstats::Vector*);
  }
  
  namespace Func {
    SV* new_array(SV*);
    void set_vector(SV*, SV*, Rstats::Vector*);
    Rstats::Vector* get_vector(SV*, SV*);
    SV* c(SV*, SV*);
    SV* to_c(SV*, SV*);
    SV* new_null(SV*); /* NULL */
    SV* new_na(SV*); /* NA */
    SV* new_nan(SV*); /* NaN */
    SV* new_inf(SV*); /* Inf */
    SV* new_false(SV*); /* FALSE */
    SV* new_true(SV*); /* TRUE */
    SV* new_character(SV*, SV*);
    SV* new_double(SV*, SV*);
    SV* new_complex(SV*, SV*);
    SV* new_integer(SV*, SV*);
    SV* new_logical(SV*, SV*);
    SV* pi(SV*);
    SV* is_vector(SV*, SV*);
    SV* length_value(SV*, SV*);
    SV* values(SV*, SV*);
    SV* set_dim(SV*, SV*, SV*);
    SV* get_dim(SV*, SV*);
    SV* is_matrix(SV*, SV*);
    SV* is_array(SV*, SV*);
    SV* is_numeric(SV*, SV*);
    SV* type(SV*, SV*);
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
  }
}

#endif
