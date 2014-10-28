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

MODULE = Rstats::Elements PACKAGE = Rstats::Elements

SV* as_double(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = self->as_double();
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV* as_integer(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = self->as_integer();
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Elements* elements = Rstats::Elements::new_null();
  
  SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
  
  return_sv(elements_sv);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  IV length = self->get_length();
  
  return_sv(my::new_sv_iv(length));
}

SV* length(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  IV length = self->get_length();
  Rstats::Elements* length_elements = Rstats::Elements::new_double(1, length);
  SV* length_elements_sv = my::to_perl_obj(length_elements, "Rstats::Elements");
  
  return_sv(length_elements_sv);
}

SV*
is_na(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  IV length = self->get_length();
  Rstats::Elements* rets = Rstats::Elements::new_logical(length);
  
  for (IV i = 0; i < length; i++) {
    if (self->exists_na_position(i)) {
      rets->set_integer_value(i, 1);
    }
    else {
      rets->set_integer_value(i, 0);
    }
  }
  
  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  SV* av_ref = my::new_av_ref();
  my::extend_av(av_ref, 3);
  
  return_sv(rets_sv);
}

SV*
compose(...)
  PPCODE:
{
  SV* mode_sv = ST(1);
  SV* elements_sv = ST(2);
  IV len = my::length_av(elements_sv);
  
  Rstats::Elements* compose_elements;
  std::vector<IV> na_positions;
  if (sv_cmp(mode_sv, my::new_sv("character")) == 0) {
    compose_elements = Rstats::Elements::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* element_sv = my::fetch_av(elements_sv, i);
      if (element_sv == &PL_sv_undef) {
        element = Rstats::Elements::new_na();
      }
      else {
        element = my::to_c_obj<Rstats::Elements*>(element_sv);
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_character_value(i, element->get_character_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_sv("complex")) == 0) {
    compose_elements = Rstats::Elements::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* element_sv = my::fetch_av(elements_sv, i);
      if (element_sv == &PL_sv_undef) {
        element = Rstats::Elements::new_na();
      }
      else {
        element = my::to_c_obj<Rstats::Elements*>(element_sv);
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
       compose_elements->set_complex_value(i, element->get_complex_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_sv("double")) == 0) {
    compose_elements = Rstats::Elements::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* element_sv = my::fetch_av(elements_sv, i);
      if (element_sv == &PL_sv_undef) {
        element = Rstats::Elements::new_na();
      }
      else {
        element = my::to_c_obj<Rstats::Elements*>(element_sv);
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_double_value(i, element->get_double_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_sv("integer")) == 0) {
    compose_elements = Rstats::Elements::new_integer(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* element_sv = my::fetch_av(elements_sv, i);
      if (element_sv == &PL_sv_undef) {
        element = Rstats::Elements::new_na();
      }
      else {
        element = my::to_c_obj<Rstats::Elements*>(element_sv);
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_sv("logical")) == 0) {
    compose_elements = Rstats::Elements::new_logical(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* element_sv = my::fetch_av(elements_sv, i);
      if (element_sv == &PL_sv_undef) {
        element = Rstats::Elements::new_na();
      }
      else {
        element = my::to_c_obj<Rstats::Elements*>(element_sv);
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
    croak("Unknown type(Rstats::Elements::compose)");
  }
  
  for (IV i = 0; i < na_positions.size(); i++) {
    compose_elements->add_na_position(na_positions[i]);
  }
  
  SV* compose_elements_sv = my::to_perl_obj(compose_elements, "Rstats::Elements");
  
  return_sv(compose_elements_sv);
}

SV*
decompose(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* decompose_elements_sv = my::new_av_ref();
  
  IV length = self->get_length();
  
  if (length > 0) {
    my::extend_av(decompose_elements_sv, length);

    if (self->is_character_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_character(1, self->get_character_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(decompose_elements_sv, elements_sv);
      }
    }
    else if (self->is_complex_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_complex(1, self->get_complex_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(decompose_elements_sv, elements_sv);
      }
    }
    else if (self->is_double_type()) {

      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_double(1, self->get_double_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
       SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(decompose_elements_sv, elements_sv);
      }
    }
    else if (self->is_integer_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_integer(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(decompose_elements_sv, elements_sv);
      }
    }
    else if (self->is_logical_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_logical(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(decompose_elements_sv, elements_sv);
      }
    }
  }
  
  return_sv(decompose_elements_sv);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_finite(self);

  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_infinite(self);
  
  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));

  Rstats::Elements* rets = Rstats::ElementsFunc::is_nan(self);

  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* type_sv;

  if (self->is_logical_type()) {
    type_sv = my::new_sv("logical");
  }
  else if (self->is_integer_type()) {
    type_sv = my::new_sv("integer");
  }
  else if (self->is_double_type()) {
    type_sv = my::new_sv("double");
  }
  else if (self->is_complex_type()) {
    type_sv = my::new_sv("complex");
  }
  else if (self->is_character_type()) {
    type_sv = my::new_sv("character");
  }
  
  return_sv(type_sv);
}

SV*
iv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  IV iv;
  if (self->get_type() == Rstats::ElementsType::INTEGER || self->get_type() == Rstats::ElementsType::LOGICAL) {
    iv = self->get_integer_value(0);
  }
  else {
    iv = 0;
  }
  
  return_sv(my::new_sv_iv(iv));
}

SV*
dv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  NV dv;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    dv = self->get_double_value(0);
  }
  else {
    dv = 0;
  }
  
  return_sv(my::new_sv_nv(dv));
}

SV*
cv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* str_sv;
  if (self->is_character_type()) {
    str_sv = self->get_character_value(0);
  }
  else {
    str_sv = my::new_sv("");
  }
  
  return_sv(str_sv);
}

SV*
re(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  
  NV re = self->get_complex_value(0).real();
  
  Rstats::Elements* re_element = Rstats::Elements::new_double(1, re);
  SV* re_element_sv = my::to_perl_obj(re_element, "Rstats::Elements");

  return_sv(re_element_sv);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  NV im = self->get_complex_value(0).imag();
  
  Rstats::Elements* im_element = Rstats::Elements::new_double(1, im);
  SV* im_element_sv = my::to_perl_obj(im_element, "Rstats::Elements");

  return_sv(im_element_sv);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* flag_sv;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    if (Rstats::ElementsFunc::is_infinite(self)) {
      NV dv = self->get_double_value(0);
      if (dv > 0) {
        flag_sv = my::new_sv("inf");
      }
      else {
        flag_sv = my::new_sv("-inf");
      }
    }
    else if(Rstats::ElementsFunc::is_nan(self)) {
      flag_sv = my::new_sv("nan");
    }
    else {
      flag_sv = my::new_sv("normal");
    }
  }
  else {
    flag_sv = my::new_sv("normal");
  }
  
  return_sv(flag_sv);
}

SV*
DESTROY(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));

  delete self;
}

MODULE = Rstats::ElementsFunc PACKAGE = Rstats::ElementsFunc


SV*
add(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::add(e1, e2);
  
  SV* e3_sv = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(e3_sv);
}

SV*
subtract(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::subtract(e1, e2);
  
  SV* e3_sv = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(e3_sv);
}

SV*
multiply(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::multiply(e1, e2);
  
  SV* e3_sv = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(e3_sv);
}

SV*
divide(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::divide(e1, e2);
  
  SV* e3_sv = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(e3_sv);
}

SV*
raise(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::raise(e1, e2);
  
  SV* e3_sv = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(e3_sv);
}

SV*
sqrt(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sqrt(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
sin(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sin(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
cos(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::cos(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
tan(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::tan(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
sinh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sinh(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
cosh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::cosh(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
tanh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::tanh(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
abs(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::abs(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
log(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
logb(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::logb(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
log10(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log10(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
log2(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log2(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
exp(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::exp(e1);
  
  SV* e2_sv = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(e2_sv);
}

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Elements* re = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* im = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* z = Rstats::Elements::new_complex(
    1,
    std::complex<NV>(re->get_double_value(0), im->get_double_value(0))
  );
  
  SV* z_sv = my::to_perl_obj(z, "Rstats::Elements");
  
  return_sv(z_sv);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_negative_inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_nan();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_na();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_null();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Elements* element = Rstats::Elements::new_character(1, str_sv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_complex(...)
  PPCODE:
{
  SV* re_sv = ST(0);
  SV* im_sv = ST(1);

  NV re = SvNV(re_sv);
  NV im = SvNV(im_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_complex(1, std::complex<NV>(re, im));
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  IV iv = SvIV(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_logical(1, iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_true();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_false();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_double(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  NV dv = SvNV(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_double(1, dv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  IV iv = SvIV(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_integer(1, iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
cross_product(...)
  PPCODE:
{
  SV* values_sv = ST(0);
  
  IV values_length = my::length_av(values_sv);
  SV* idxs_sv = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    my::push_av(idxs_sv, my::new_sv_iv(0)); 
  }
  
  SV* idx_idx_sv = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    my::push_av(idx_idx_sv, my::new_sv_iv(i));
  }
  
  SV* x1_sv = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    SV* value_sv = my::fetch_av(values_sv, i);
    my::push_av(x1_sv, my::fetch_av(value_sv, 0));
  }

  SV* result_sv = my::new_av_ref();
  my::push_av(result_sv, my::copy_av(x1_sv));
  IV end_loop = 0;
  while (1) {
    for (IV i = 0; i < values_length; i++) {
      
      if (SvIV(my::fetch_av(idxs_sv, i)) < my::length_av(my::fetch_av(values_sv, i)) - 1) {
        
        SV* idxs_tmp_sv = my::fetch_av(idxs_sv, i);
        sv_inc(idxs_tmp_sv);
        my::store_av(x1_sv, i, my::fetch_av(my::fetch_av(values_sv, i), SvIV(idxs_tmp_sv)));
        
        my::push_av(result_sv, my::copy_av(x1_sv));
        
        break;
      }
      
      if (i == SvIV(my::fetch_av(idx_idx_sv, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      my::store_av(idxs_sv, i, my::new_sv_iv(0));
      my::store_av(x1_sv, i, my::fetch_av(my::fetch_av(values_sv, i), 0));
    }
    if (end_loop) {
      break;
    }
  }

  return_sv(result_sv);
}

SV*
pos_to_index(...)
  PPCODE:
{
  SV* pos_sv = ST(0);
  SV* dim_sv = ST(1);
  
  SV* index_sv = my::new_av_ref();
  IV pos = SvIV(pos_sv);
  IV before_dim_product = 1;
  for (IV i = 0; i < my::length_av(my::deref_av(dim_sv)); i++) {
    before_dim_product *= SvIV(my::fetch_av(dim_sv, i));
  }
  
  for (IV i = my::length_av(my::deref_av(dim_sv)) - 1; i >= 0; i--) {
    IV dim_product = 1;
    for (IV k = 0; k < i; k++) {
      dim_product *= SvIV(my::fetch_av(dim_sv, k));
    }
    
    IV reminder = pos % before_dim_product;
    IV quotient = (IV)(reminder / dim_product);
    
    my::unshit_av(index_sv, my::new_sv_iv(quotient + 1));
    before_dim_product = dim_product;
  }
  
  return_sv(index_sv);
}

SV*
index_to_pos(...)
  PPCODE :
{
  SV* index_sv = ST(0);
  SV* dim_values_sv = ST(1);
  
  IV pos = 0;
  for (IV i = 0; i < my::length_av(my::deref_av(dim_values_sv)); i++) {
    if (i > 0) {
      IV tmp = 1;
      for (IV k = 0; k < i; k++) {
        tmp *= SvIV(my::fetch_av(dim_values_sv, k));
      }
      pos += tmp * (SvIV(my::fetch_av(index_sv, i)) - 1);
    }
    else {
      pos += SvIV(my::fetch_av(index_sv, i));
    }
  }
  
  SV* pos_sv = my::new_sv_iv(pos - 1);
  
  return_sv(pos_sv);
}

MODULE = Rstats PACKAGE = Rstats
