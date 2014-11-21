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

namespace Rstats {
  namespace Util {
    REGEXP* INTEGER_RE = pregcomp(newSVpvs("^ *([-+]?[0-9]+) *$"), 0);
  }
}

MODULE = Rstats::Elements PACKAGE = Rstats::Elements

SV* as_double(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = self->as_double();
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV* as_integer(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = self->as_integer();
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Elements* elements = Rstats::Elements::new_null();
  
  SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
  
  return_sv(sv_elements);
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
  SV* sv_length_elements = my::to_perl_obj(length_elements, "Rstats::Elements");
  
  return_sv(sv_length_elements);
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
  
  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Elements");
  
  SV* av_ref = my::new_av_ref();
  my::extend_av(av_ref, 3);
  
  return_sv(sv_rets);
}

SV*
compose(...)
  PPCODE:
{
  SV* sv_mode = ST(1);
  SV* sv_elements = ST(2);
  IV len = my::length_av(sv_elements);
  
  Rstats::Elements* compose_elements;
  std::vector<IV> na_positions;
  if (sv_cmp(sv_mode, my::new_sv("character")) == 0) {
    compose_elements = Rstats::Elements::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* sv_element = my::fetch_av(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Elements*>(sv_element);
      }
      else {
        element = Rstats::Elements::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_character_value(i, element->get_character_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_sv("complex")) == 0) {
    compose_elements = Rstats::Elements::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* sv_element = my::fetch_av(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Elements*>(sv_element);
      }
      else {
        element = Rstats::Elements::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
       compose_elements->set_complex_value(i, element->get_complex_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_sv("double")) == 0) {
    compose_elements = Rstats::Elements::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* sv_element = my::fetch_av(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Elements*>(sv_element);
      }
      else {
        element = Rstats::Elements::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_double_value(i, element->get_double_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_sv("integer")) == 0) {
    compose_elements = Rstats::Elements::new_integer(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* sv_element = my::fetch_av(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Elements*>(sv_element);
      }
      else {
        element = Rstats::Elements::new_na();
      }
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
  }
  else if (sv_cmp(sv_mode, my::new_sv("logical")) == 0) {
    compose_elements = Rstats::Elements::new_logical(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Elements* element;
      SV* sv_element = my::fetch_av(sv_elements, i);
      if (SvOK(sv_element)) {
        element = my::to_c_obj<Rstats::Elements*>(sv_element);
      }
      else {
        element = Rstats::Elements::new_na();
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
  
  SV* sv_compose_elements = my::to_perl_obj(compose_elements, "Rstats::Elements");
  
  return_sv(sv_compose_elements);
}

SV*
decompose(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* sv_decompose_elements = my::new_av_ref();
  
  IV length = self->get_length();
  
  if (length > 0) {
    my::extend_av(sv_decompose_elements, length);

    if (self->is_character_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_character(1, self->get_character_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_complex_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_complex(1, self->get_complex_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_double_type()) {

      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_double(1, self->get_double_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
       SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_integer_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_integer(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_logical_type()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Elements* elements
          = Rstats::Elements::new_logical(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = my::to_perl_obj(elements, "Rstats::Elements");
        my::push_av(sv_decompose_elements, sv_elements);
      }
    }
  }
  
  return_sv(sv_decompose_elements);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_finite(self);

  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(sv_rets);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_infinite(self);
  
  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(sv_rets);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));

  Rstats::Elements* rets = Rstats::ElementsFunc::is_nan(self);

  SV* sv_rets = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(sv_rets);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* sv_type;

  if (self->is_logical_type()) {
    sv_type = my::new_sv("logical");
  }
  else if (self->is_integer_type()) {
    sv_type = my::new_sv("integer");
  }
  else if (self->is_double_type()) {
    sv_type = my::new_sv("double");
  }
  else if (self->is_complex_type()) {
    sv_type = my::new_sv("complex");
  }
  else if (self->is_character_type()) {
    sv_type = my::new_sv("character");
  }
  
  return_sv(sv_type);
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
  
  SV* sv_str;
  if (self->is_character_type()) {
    sv_str = self->get_character_value(0);
  }
  else {
    sv_str = my::new_sv("");
  }
  
  return_sv(sv_str);
}

SV*
re(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  NV re = self->get_complex_value(0).real();
  
  Rstats::Elements* re_element = Rstats::Elements::new_double(1, re);
  SV* sv_re_element = my::to_perl_obj(re_element, "Rstats::Elements");

  return_sv(sv_re_element);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  NV im = self->get_complex_value(0).imag();
  
  Rstats::Elements* im_element = Rstats::Elements::new_double(1, im);
  SV* sv_im_element = my::to_perl_obj(im_element, "Rstats::Elements");

  return_sv(sv_im_element);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* sv_flag;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    if (Rstats::ElementsFunc::is_infinite(self)) {
      NV dv = self->get_double_value(0);
      if (dv > 0) {
        sv_flag = my::new_sv("inf");
      }
      else {
        sv_flag = my::new_sv("-inf");
      }
    }
    else if(Rstats::ElementsFunc::is_nan(self)) {
      sv_flag = my::new_sv("nan");
    }
    else {
      sv_flag = my::new_sv("normal");
    }
  }
  else {
    sv_flag = my::new_sv("normal");
  }
  
  return_sv(sv_flag);
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
  
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(sv_e3);
}

SV*
subtract(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::subtract(e1, e2);
  
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(sv_e3);
}

SV*
multiply(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::multiply(e1, e2);
  
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(sv_e3);
}

SV*
divide(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::divide(e1, e2);
  
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(sv_e3);
}

SV*
raise(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* e2 = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* e3 = Rstats::ElementsFunc::raise(e1, e2);
  
  SV* sv_e3 = my::to_perl_obj(e3, "Rstats::Elements");
  
  return_sv(sv_e3);
}

SV*
sqrt(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sqrt(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
sin(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sin(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
cos(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::cos(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
tan(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::tan(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
sinh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::sinh(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
cosh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::cosh(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
tanh(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::tanh(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
abs(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::abs(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
log(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
logb(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::logb(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
log10(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log10(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
log2(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::log2(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
}

SV*
exp(...)
  PPCODE:
{
  Rstats::Elements* e1 = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* e2 = Rstats::ElementsFunc::exp(e1);
  
  SV* sv_e2 = my::to_perl_obj(e2, "Rstats::Elements");
  
  return_sv(sv_e2);
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
  
  SV* sv_z = my::to_perl_obj(z, "Rstats::Elements");
  
  return_sv(sv_z);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_negative_inf();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_inf();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_nan();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_na();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_null();
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_character(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  
  Rstats::Elements* element = Rstats::Elements::new_character(1, sv_str);
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
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
  
  Rstats::Elements* element = Rstats::Elements::new_complex(1, std::complex<NV>(re, im));
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  IV iv = SvIV(sv_value);
  
  Rstats::Elements* element = Rstats::Elements::new_logical(1, iv);
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_true();
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_false();
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_double(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  NV dv = SvNV(sv_value);
  
  Rstats::Elements* element = Rstats::Elements::new_double(1, dv);
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* sv_value = ST(0);
  IV iv = SvIV(sv_value);
  
  Rstats::Elements* element = Rstats::Elements::new_integer(1, iv);
  
  SV* sv_element = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(sv_element);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
looks_like_integer(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  
  SV* sv_ret;
  if (!SvOK(sv_str) || sv_len(sv_str) == 0) {
    sv_ret = &PL_sv_undef;
  }
  else {
    IV ret = my::pregexec_simple(sv_str, Rstats::Util::INTEGER_RE);
    
    if (ret) {
      SV* match_sv = get_sv("1", 0);
      sv_ret = my::new_sv_iv(SvIV(match_sv));
    }
    else {
      sv_ret = &PL_sv_undef;
    }
  }
  
  return_sv(sv_ret);
}

SV*
cross_product(...)
  PPCODE:
{
  SV* sv_values = ST(0);
  
  IV values_length = my::length_av(sv_values);
  SV* sv_idxs = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    my::push_av(sv_idxs, my::new_sv_iv(0)); 
  }
  
  SV* sv_idx_idx = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    my::push_av(sv_idx_idx, my::new_sv_iv(i));
  }
  
  SV* sv_x1 = my::new_av_ref();
  for (IV i = 0; i < values_length; i++) {
    SV* sv_value = my::fetch_av(sv_values, i);
    my::push_av(sv_x1, my::fetch_av(sv_value, 0));
  }

  SV* sv_result = my::new_av_ref();
  my::push_av(sv_result, my::copy_av(sv_x1));
  IV end_loop = 0;
  while (1) {
    for (IV i = 0; i < values_length; i++) {
      
      if (SvIV(my::fetch_av(sv_idxs, i)) < my::length_av(my::fetch_av(sv_values, i)) - 1) {
        
        SV* sv_idxs_tmp = my::fetch_av(sv_idxs, i);
        sv_inc(sv_idxs_tmp);
        my::store_av(sv_x1, i, my::fetch_av(my::fetch_av(sv_values, i), SvIV(sv_idxs_tmp)));
        
        my::push_av(sv_result, my::copy_av(sv_x1));
        
        break;
      }
      
      if (i == SvIV(my::fetch_av(sv_idx_idx, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      my::store_av(sv_idxs, i, my::new_sv_iv(0));
      my::store_av(sv_x1, i, my::fetch_av(my::fetch_av(sv_values, i), 0));
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
  
  SV* sv_index = my::new_av_ref();
  IV pos = SvIV(sv_pos);
  IV before_dim_product = 1;
  for (IV i = 0; i < my::length_av(my::deref_av(sv_dim)); i++) {
    before_dim_product *= SvIV(my::fetch_av(sv_dim, i));
  }
  
  for (IV i = my::length_av(my::deref_av(sv_dim)) - 1; i >= 0; i--) {
    IV dim_product = 1;
    for (IV k = 0; k < i; k++) {
      dim_product *= SvIV(my::fetch_av(sv_dim, k));
    }
    
    IV reminder = pos % before_dim_product;
    IV quotient = (IV)(reminder / dim_product);
    
    my::unshit_av(sv_index, my::new_sv_iv(quotient + 1));
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
  for (IV i = 0; i < my::length_av(my::deref_av(sv_dim_values)); i++) {
    if (i > 0) {
      IV tmp = 1;
      for (IV k = 0; k < i; k++) {
        tmp *= SvIV(my::fetch_av(sv_dim_values, k));
      }
      pos += tmp * (SvIV(my::fetch_av(sv_index, i)) - 1);
    }
    else {
      pos += SvIV(my::fetch_av(sv_index, i));
    }
  }
  
  SV* sv_pos = my::new_sv_iv(pos - 1);
  
  return_sv(sv_pos);
}

MODULE = Rstats PACKAGE = Rstats
