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

  typedef std::vector<Rstats::Character> CharacterVector;
  typedef std::vector<Rstats::Complex> ComplexVector;
  typedef std::vector<Rstats::Double> DoubleVector;
  typedef std::vector<Rstats::Integer> IntegerVector;
  
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

    std::complex<NV> remainder(std::complex<NV>, std::complex<NV>);
    NV remainder(NV, NV);
    IV remainder(IV, IV);

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

  typedef struct {
    Rstats::Type::Enum type;
    std::map<IV, IV>* na_positions;
    void* values;
  } Vector;

  // Macro for Rstats::Vector
# define RSTATS_DEF_VECTOR_FUNC_UN_IS(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2 = Rstats::VectorFunc::new_logical(length); \
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Character>(v1, i))); \
          } \
          break; \
        case Rstats::Type::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))); \
          } \
          break; \
        default: \
          croak("Error in %s() : invalid argument to %s()", #FUNC_NAME, #FUNC_NAME); \
          break; \
      } \
      for (IV i = 0; i < length; i++) { \
        if (Rstats::VectorFunc::exists_na_position(v1, i)) { \
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 0); \
        } \
      } \
      return v2; \
    }

# define RSTATS_DEF_VECTOR_FUNC_UN_MATH(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* FUNC_NAME(Rstats::Vector* v1) { \
      IV length = Rstats::VectorFunc::get_length(v1); \
      Rstats::Vector* v2; \
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::COMPLEX : \
          v2 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          v2 = Rstats::VectorFunc::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))); \
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
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::COMPLEX : \
          v2 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))); \
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
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::COMPLEX : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))); \
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
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::CHARACTER : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Character>(v1, i), Rstats::VectorFunc::get_value<Rstats::Character>(v2, i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::Type::COMPLEX : \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Integer>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i), Rstats::VectorFunc::get_value<Rstats::Complex>(v2, i)) ? 1 : 0); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_value<Rstats::Integer>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i), Rstats::VectorFunc::get_value<Rstats::Double>(v2, i)) ? 1 : 0); \
            } catch (const char* e) {\
              Rstats::VectorFunc::add_na_position(v3, i);\
            }\
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_value<Rstats::Integer>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), Rstats::VectorFunc::get_value<Rstats::Integer>(v2, i)) ? 1 : 0); \
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
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::COMPLEX : \
          v3 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Complex>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i), Rstats::VectorFunc::get_value<Rstats::Complex>(v2, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          v3 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i), Rstats::VectorFunc::get_value<Rstats::Double>(v2, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          v3 = Rstats::VectorFunc::new_integer(length); \
          for (IV i = 0; i < length; i++) { \
            try {\
              Rstats::VectorFunc::set_value<Rstats::Integer>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), Rstats::VectorFunc::get_value<Rstats::Integer>(v2, i))); \
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
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1); \
      switch (type) { \
        case Rstats::Type::COMPLEX : \
          v3 = Rstats::VectorFunc::new_complex(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Complex>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i), Rstats::VectorFunc::get_value<Rstats::Complex>(v2, i))); \
          } \
          break; \
        case Rstats::Type::DOUBLE : \
          v3 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i), Rstats::VectorFunc::get_value<Rstats::Double>(v2, i))); \
          } \
          break; \
        case Rstats::Type::INTEGER : \
        case Rstats::Type::LOGICAL : \
          v3 = Rstats::VectorFunc::new_vector<Rstats::Double>(length); \
          for (IV i = 0; i < length; i++) { \
            Rstats::VectorFunc::set_value<Rstats::Double>(v3, i, ELEMENT_FUNC_NAME(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), Rstats::VectorFunc::get_value<Rstats::Integer>(v2, i))); \
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
    Rstats::Vector* new_empty_vector();
    void delete_vector(Rstats::Vector*);
    SV* create_sv_value(Rstats::Vector*, IV);
    SV* create_sv_values(Rstats::Vector*);
    
    bool is_character (Rstats::Vector*);
    bool is_complex (Rstats::Vector*);
    bool is_double (Rstats::Vector*);
    bool is_integer (Rstats::Vector*);
    bool is_numeric (Rstats::Vector*);
    bool is_logical (Rstats::Vector*);
    
    Rstats::Type::Enum get_type(Rstats::Vector*);
    void add_na_position(Rstats::Vector*, IV);
    bool exists_na_position(Rstats::Vector*, IV position);
    void merge_na_positions(Rstats::Vector*, Rstats::Vector*);
    std::map<IV, IV>* get_na_positions(Rstats::Vector*);
    IV get_length (Rstats::Vector*);
    
    Rstats::Vector* new_character(IV, SV*);
    Rstats::Vector* new_character(IV);
    Rstats::Vector* new_complex(IV);
    Rstats::Vector* new_complex(IV, std::complex<NV>);

    Rstats::Vector* new_integer(IV);
    Rstats::Vector* new_integer(IV, IV);
    
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
    Rstats::Vector* remainder(Rstats::Vector*, Rstats::Vector*);

    Rstats::Vector* divide(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* atan2(Rstats::Vector*, Rstats::Vector*);
    Rstats::Vector* pow(Rstats::Vector*, Rstats::Vector*);
    
    Rstats::Vector* cumprod(Rstats::Vector*);
    Rstats::Vector* cumsum(Rstats::Vector*);
    Rstats::Vector* prod(Rstats::Vector*);
    Rstats::Vector* sum(Rstats::Vector*);
    Rstats::Vector* clone(Rstats::Vector*);
    
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
    SV* new_array(SV*);
    void set_vector(SV*, SV*, Rstats::Vector*);
    Rstats::Vector* get_vector(SV*, SV*);
    SV* c(SV*, SV*);
    SV* to_c(SV*, SV*);

    SV* new_null(SV*); /* NULL */
    SV* new_vector(SV*);
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
    SV* is_null (SV*, SV*);
    SV* is_vector(SV*, SV*);
    SV* length_value(SV*, SV*);
    SV* values(SV*, SV*);
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
    SV* operate_unary(SV*, Rstats::Vector* (*func)(Rstats::Vector*), SV*);
    SV* operate_binary(SV*, Rstats::Vector* (*func)(Rstats::Vector*, Rstats::Vector*), SV*, SV*);
    SV* upgrade_type(SV*, SV*);

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
  }
}

#endif
