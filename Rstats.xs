/* Libraries */
#include "Rstats_include.h"

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* Rstats headers */
#include "Rstats.h"

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

/* Shortcut of return sv */
#define return_sv(x) XPUSHs(x); XSRETURN(1)

namespace my = Rstats::PerlAPI;

MODULE = Rstats::Vector PACKAGE = Rstats::Vector

SV* values(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  IV length = self->get_length();
  SV* sv_values = my::new_mAVRV();
  if (self->is_character()) {
    for (IV i = 0; i < length; i++) {
      if (self->exists_na_position(i)) {
        my::avrv_push_inc(sv_values, &PL_sv_undef);
      }
      else {
        my::avrv_push_inc(sv_values, self->get_character_value(i));
      }
    }
  }
  else if (self->is_complex()) {
    for (IV i = 0; i < length; i++) {
      if (self->exists_na_position(i)) {
        my::avrv_push_inc(sv_values, &PL_sv_undef);
      }
      else {
        SV* sv_z = my::new_mHVRV();
        std::complex<NV> z = self->get_complex_value(i);
        
        NV re = z.real();
        SV* sv_re;
        if (std::isnan(re)) {
          sv_re = my::new_mSVpv_nolen("NaN");
        }
        else if (std::isinf(re) && re > 0) {
          sv_re = my::new_mSVpv_nolen("Inf");
        }
        else if (std::isinf(re) && re < 0) {
          sv_re = my::new_mSVpv_nolen("-Inf");
        }
        else {
          sv_re = my::new_mSVnv(re);
        }
        
        NV im = z.imag();
        SV* sv_im;
        if (std::isnan(im)) {
          sv_im = my::new_mSVpv_nolen("NaN");
        }
        else if (std::isinf(im) && im > 0) {
          sv_im = my::new_mSVpv_nolen("Inf");
        }
        else if (std::isinf(im) && im < 0) {
          sv_im = my::new_mSVpv_nolen("-Inf");
        }
        else {
          sv_im = my::new_mSVnv(im);
        }

        my::hvrv_store_nolen_inc(sv_z, "re", sv_re);
        my::hvrv_store_nolen_inc(sv_z, "im", sv_im);
        
        my::avrv_push_inc(sv_values, sv_z);
      }
    }
  }
  else if (self->is_double()) {
    for (IV i = 0; i < length; i++) {
      if (self->exists_na_position(i)) {
        my::avrv_push_inc(sv_values, &PL_sv_undef);
      }
      else {
        NV value = self->get_double_value(i);
        SV* sv_value;
        if (std::isnan(value)) {
          sv_value = my::new_mSVpv_nolen("NaN");
        }
        else if (std::isinf(value) && value > 0) {
          sv_value = my::new_mSVpv_nolen("Inf");
        }
        else if (std::isinf(value) && value < 0) {
          sv_value = my::new_mSVpv_nolen("-Inf");
        }
        else {
          sv_value = my::new_mSVnv(value);
        }
        my::avrv_push_inc(sv_values, sv_value);
      }
    }
  }
  else if (self->is_integer() || self->is_logical()) {
    for (IV i = 0; i < length; i++) {
      if (self->exists_na_position(i)) {
        my::avrv_push_inc(sv_values, &PL_sv_undef);
      }
      else {
        IV value = self->get_integer_value(i);
        SV* sv_value = my::new_mSViv(value);
        my::avrv_push_inc(sv_values, sv_value);
      }
    }
  }
  else {
    sv_values = &PL_sv_undef;
  }
  
  return_sv(sv_values);
}

SV* is_character(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_character();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* is_complex(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_complex();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* is_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_numeric();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* is_double(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_double();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* is_integer(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_integer();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* is_logical(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_logical();
  SV* sv_is = is ? my::new_mSViv(1) : my::new_mSViv(0);
  return_sv(sv_is);
}

SV* as(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_type = ST(1);
  Rstats::Vector* e2 = self->as(sv_type);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_character(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_character();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_complex(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_complex();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_logical(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_logical();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_numeric();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_double(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_double();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_integer(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_integer();
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Vector* elements = Rstats::Vector::new_null();
  SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
  return_sv(sv_elements);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  IV length = self->get_length();
  return_sv(my::new_mSViv(length));
}

SV* length(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  IV length = self->get_length();
  Rstats::Vector* length_elements = Rstats::Vector::new_double(1, length);
  SV* sv_length_elements = my::to_perl_obj(length_elements, "Rstats::Vector");
  return_sv(sv_length_elements);
}

SV*
is_na(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  IV length = self->get_length();
  Rstats::Vector* rets = Rstats::Vector::new_logical(length);
  
  for (IV i = 0; i < length; i++) {
    if (self->exists_na_position(i)) {
      rets->set_integer_value(i, 1);
    }
    else {
      rets->set_integer_value(i, 0);
    }
  }
  
  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
compose(...)
  PPCODE:
{
  SV* sv_mode = ST(1);
  SV* sv_elements = ST(2);
  IV len = my::avrv_len_fix(sv_elements);
  
  Rstats::Vector* compose_elements;
  std::vector<IV> na_positions;
  if (sv_cmp(sv_mode, my::new_mSVpv_nolen("character")) == 0) {
    compose_elements = Rstats::Vector::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = my::avrv_fetch_simple(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Vector::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_character_value(i, element->get_character_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_mSVpv_nolen("complex")) == 0) {
    compose_elements = Rstats::Vector::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = my::avrv_fetch_simple(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Vector::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
       compose_elements->set_complex_value(i, element->get_complex_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_mSVpv_nolen("double")) == 0) {
    compose_elements = Rstats::Vector::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = my::avrv_fetch_simple(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Vector::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_double_value(i, element->get_double_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_mSVpv_nolen("integer")) == 0) {
    compose_elements = Rstats::Vector::new_integer(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = my::avrv_fetch_simple(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Vector::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_mSVpv_nolen("logical")) == 0) {
    compose_elements = Rstats::Vector::new_logical(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = my::avrv_fetch_simple(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Vector::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
  }
  else {
    croak("Unknown type(Rstats::Vector::compose)");
  }
  
  for (IV i = 0; i < na_positions.size(); i++) {
    compose_elements->add_na_position(na_positions[i]);
  }
  
  SV* sv_compose_elements = my::to_perl_obj(compose_elements, "Rstats::Vector");
  
  return_sv(sv_compose_elements);
}

SV*
decompose(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_decompose_elements = my::new_mAVRV();
  
  IV length = self->get_length();
  
  if (length > 0) {
    av_extend((AV*)my::SvRV_safe(sv_decompose_elements), length);

    if (self->is_character()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_character(1, self->get_character_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
        my::avrv_push_inc(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_complex()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_complex(1, self->get_complex_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
        my::avrv_push_inc(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_double()) {

      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_double(1, self->get_double_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
       SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
        my::avrv_push_inc(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_integer()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_integer(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
        my::avrv_push_inc(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_logical()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_logical(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Vector");
        my::avrv_push_inc(sv_decompose_elements, sv_elements);
      }
    }
  }
  
  return_sv(sv_decompose_elements);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* rets = Rstats::VectorFunc::is_finite(self);

  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* rets = Rstats::VectorFunc::is_infinite(self);
  
  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));

  Rstats::Vector* rets = Rstats::VectorFunc::is_nan(self);

  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_type;

  if (self->is_logical()) {
    sv_type = my::new_mSVpv_nolen("logical");
  }
  else if (self->is_integer()) {
    sv_type = my::new_mSVpv_nolen("integer");
  }
  else if (self->is_double()) {
    sv_type = my::new_mSVpv_nolen("double");
  }
  else if (self->is_complex()) {
    sv_type = my::new_mSVpv_nolen("complex");
  }
  else if (self->is_character()) {
    sv_type = my::new_mSVpv_nolen("character");
  }
  
  return_sv(sv_type);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_flag;
  if (self->get_type() == Rstats::VectorType::DOUBLE) {
    if (Rstats::VectorFunc::is_infinite(self)) {
      NV value = self->get_double_value(0);
      if (value > 0) {
        sv_flag = my::new_mSVpv_nolen("inf");
      }
      else {
        sv_flag = my::new_mSVpv_nolen("-inf");
      }
    }
    else if(Rstats::VectorFunc::is_nan(self)) {
      sv_flag = my::new_mSVpv_nolen("nan");
    }
    else {
      sv_flag = my::new_mSVpv_nolen("normal");
    }
  }
  else {
    sv_flag = my::new_mSVpv_nolen("normal");
  }
  
  return_sv(sv_flag);
}

SV*
DESTROY(...)
  PPCODE:
{
  Rstats::Vector* self = my::to_c_obj<Rstats::Vector*>(ST(0));

  delete self;
}

MODULE = Rstats::VectorFunc PACKAGE = Rstats::VectorFunc

SV*
and(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::And(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
or(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::Or(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* Conj(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Conj(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Re(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Re(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Im(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Im(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
less_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than_or_equal(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than_or_equal(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
less_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
not_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::not_equal(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::equal(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
add(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::add(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
subtract(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::subtract(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
multiply(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::multiply(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
divide(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::divide(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
pow(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::pow(e1, e2);
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
sqrt(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sqrt(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sin(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sin(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cos(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cos(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tan(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tan(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sinh(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cosh(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tanh(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
abs(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::abs(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
logb(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::logb(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log10(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log10(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log2(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log2(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
exp(...)
  PPCODE:
{
  Rstats::Vector* e1 = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::exp(e1);
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Vector* re = my::to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* im = my::to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* z = Rstats::Vector::new_complex(
    1,
    std::complex<NV>(re->get_double_value(0), im->get_double_value(0))
  );
  SV* sv_z = my::to_perl_obj(z, "Rstats::Vector");
  return_sv(sv_z);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_negative_inf();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_inf();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_nan();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_na();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_null();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_character(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  Rstats::Vector* element = Rstats::Vector::new_character(1, sv_str);
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_complex(...)
  PPCODE:
{
  SV* sv_re = ST(0);
  SV* sv_im = ST(1);
  NV re = SvNV(sv_re);
  NV im = SvNV(sv_im);
  Rstats::Vector* element = Rstats::Vector::new_complex(1, std::complex<NV>(re, im));
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  IV iv = SvIV(sv_value);
  Rstats::Vector* element = Rstats::Vector::new_logical(1, iv);
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_true();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_false();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_double(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  NV value = SvNV(sv_value);
  Rstats::Vector* element = Rstats::Vector::new_double(1, value);
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  IV iv = SvIV(sv_value);
  Rstats::Vector* element = Rstats::Vector::new_integer(1, iv);
  SV* sv_element = my::to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
looks_like_integer(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_integer(sv_str);
  return_sv(sv_ret);
}

SV*
looks_like_double(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_double(sv_str);
  return_sv(sv_ret);
}

SV*
looks_like_na(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_na(sv_str);
  return_sv(sv_ret);
}

SV*
looks_like_logical(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_logical(sv_str);
  return_sv(sv_ret);
}

SV*
looks_like_complex(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_complex(sv_str);
  return_sv(sv_ret);
}

SV*
cross_product(...)
  PPCODE:
{
  SV* sv_values = ST(0);
  
  IV values_length = my::avrv_len_fix(sv_values);
  SV* sv_idxs = my::new_mAVRV();
  for (IV i = 0; i < values_length; i++) {
    my::avrv_push_inc(sv_idxs, my::new_mSViv(0)); 
  }
  
  SV* sv_idx_idx = my::new_mAVRV();
  for (IV i = 0; i < values_length; i++) {
    my::avrv_push_inc(sv_idx_idx, my::new_mSViv(i));
  }
  
  SV* sv_x1 = my::new_mAVRV();
  for (IV i = 0; i < values_length; i++) {
    SV* sv_value = my::avrv_fetch_simple(sv_values, i);
    my::avrv_push_inc(sv_x1, my::avrv_fetch_simple(sv_value, 0));
  }

  SV* sv_result = my::new_mAVRV();
  my::avrv_push_inc(sv_result, my::copy_av(sv_x1));
  IV end_loop = 0;
  while (1) {
    for (IV i = 0; i < values_length; i++) {
      
      if (SvIV(my::avrv_fetch_simple(sv_idxs, i)) < my::avrv_len_fix(my::avrv_fetch_simple(sv_values, i)) - 1) {
        
        SV* sv_idxs_tmp = my::avrv_fetch_simple(sv_idxs, i);
        sv_inc(sv_idxs_tmp);
        my::avrv_store_inc(sv_x1, i, my::avrv_fetch_simple(my::avrv_fetch_simple(sv_values, i), SvIV(sv_idxs_tmp)));
        
        my::avrv_push_inc(sv_result, my::copy_av(sv_x1));
        
        break;
      }
      
      if (i == SvIV(my::avrv_fetch_simple(sv_idx_idx, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      my::avrv_store_inc(sv_idxs, i, my::new_mSViv(0));
      my::avrv_store_inc(sv_x1, i, my::avrv_fetch_simple(my::avrv_fetch_simple(sv_values, i), 0));
    }
    if (end_loop) {
      break;
    }
  }

  return_sv(sv_result);
}

SV*
pos_to_index(...)
  PPCODE:
{
  SV* sv_pos = ST(0);
  SV* sv_dim = ST(1);
  
  SV* sv_index = my::new_mAVRV();
  IV pos = SvIV(sv_pos);
  IV before_dim_product = 1;
  for (IV i = 0; i < my::avrv_len_fix(sv_dim); i++) {
    before_dim_product *= SvIV(my::avrv_fetch_simple(sv_dim, i));
  }
  
  for (IV i = my::avrv_len_fix(sv_dim) - 1; i >= 0; i--) {
    IV dim_product = 1;
    for (IV k = 0; k < i; k++) {
      dim_product *= SvIV(my::avrv_fetch_simple(sv_dim, k));
    }
    
    IV reminder = pos % before_dim_product;
    IV quotient = (IV)(reminder / dim_product);
    
    my::avrv_unshift_real_inc(sv_index, my::new_mSViv(quotient + 1));
    before_dim_product = dim_product;
  }
  
  return_sv(sv_index);
}

SV*
index_to_pos(...)
  PPCODE :
{
  SV* sv_index = ST(0);
  SV* sv_dim_values = ST(1);
  
  IV pos = 0;
  for (IV i = 0; i < my::avrv_len_fix(sv_dim_values); i++) {
    if (i > 0) {
      IV tmp = 1;
      for (IV k = 0; k < i; k++) {
        tmp *= SvIV(my::avrv_fetch_simple(sv_dim_values, k));
      }
      pos += tmp * (SvIV(my::avrv_fetch_simple(sv_index, i)) - 1);
    }
    else {
      pos += SvIV(my::avrv_fetch_simple(sv_index, i));
    }
  }
  
  SV* sv_pos = my::new_mSViv(pos - 1);
  
  return_sv(sv_pos);
}

MODULE = Rstats PACKAGE = Rstats
