#ifndef PERL_RSTATS_H
#define PERL_RSTATS_H

/* Fix std::isnan problem in Windows */
#ifndef _isnan
#define _isnan isnan
#endif

#include <vector>
#include <map>
#include <complex>

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
    SV* args(SV*, SV*);
    IV is_perl_number(SV*);
    SV* cross_product(SV*);
    SV* pos_to_index(SV*, SV*);
    SV* index_to_pos(SV*, SV*);
    SV* looks_like_complex (SV*);
    SV* looks_like_logical (SV*);
    SV* looks_like_na (SV*);
    SV* looks_like_integer(SV*);
    SV* looks_like_double (SV*);
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
    
    // expm1 (Can't separate body. I don't know the reason)
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

  class Vector {
    private:
    Rstats::VectorType::Enum type;
    std::map<IV, IV> na_positions;
    void* values;
    
    public:

    ~Vector ();
    
    SV* get_value(IV);
    SV* get_values();
    
    bool is_character ();
    bool is_complex ();
    bool is_double ();
    bool is_integer ();
    bool is_numeric ();
    bool is_logical ();
    
    std::vector<SV*>* get_character_values();
    std::vector<std::complex<NV> >* get_complex_values();
    std::vector<NV>* get_double_values();
    std::vector<IV>* get_integer_values();
    
    Rstats::VectorType::Enum get_type();
    void add_na_position(IV);
    bool exists_na_position(IV position);
    void merge_na_positions(Rstats::Vector* elements);
    std::map<IV, IV> get_na_positions();
    IV get_length ();
    
    static Rstats::Vector* new_character(IV, SV*);
    static Rstats::Vector* new_character(IV);
    SV* get_character_value(IV);
    void set_character_value(IV, SV*);
    static Rstats::Vector* new_complex(IV);
    static Rstats::Vector* new_complex(IV, std::complex<NV>);
    std::complex<NV> get_complex_value(IV);
    void set_complex_value(IV, std::complex<NV>);
    static Rstats::Vector* new_double(IV);
    static Rstats::Vector* new_double(IV, NV);
    NV get_double_value(IV);
    void set_double_value(IV, NV);

    static Rstats::Vector* new_integer(IV);
    static Rstats::Vector* new_integer(IV, IV);
    
    IV get_integer_value(IV);
    void set_integer_value(IV, IV);
    
    static Rstats::Vector* new_logical(IV);
    static Rstats::Vector* new_logical(IV, IV);
    static Rstats::Vector* new_true();
    static Rstats::Vector* new_false();
    static Rstats::Vector* new_nan();
    static Rstats::Vector* new_negative_inf();
    static Rstats::Vector* new_inf();
    static Rstats::Vector* new_na();
    static Rstats::Vector* new_null();
    
    Rstats::Vector* as (SV*);
    SV* to_string_pos(IV);
    SV* to_string();
    Rstats::Vector* as_character();
    Rstats::Vector* as_double();
    Rstats::Vector* as_numeric();
    Rstats::Vector* as_integer();
    Rstats::Vector* as_complex();
    Rstats::Vector* as_logical();
  };

  // Macro for Rstats::Vector
# define RSTATS_DEF_VECTOR_FUNC_UN_IS(FUNC_NAME, ELEMENT_FUNC_NAME) \
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
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
    Rstats::Vector* Rstats::VectorFunc::FUNC_NAME(Rstats::Vector* e1, Rstats::Vector* e2) { \
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

  // Rstats::VectorFunc
  namespace VectorFunc {
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
  
  namespace ArrayFunc {
    SV* new_array();
    void set_vector(SV*, Rstats::Vector*);
    Rstats::Vector* get_vector(SV*);
    void set_dim(SV*, Rstats::Vector*);
    Rstats::Vector* get_dim(SV*);
    SV* c(SV*);
    SV* to_c(SV*);
  }
}

#endif
