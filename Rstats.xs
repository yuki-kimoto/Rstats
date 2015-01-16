/* Rstats headers */
#include "Rstats.h"

/* Shortcut of return sv */
#define return_sv(x) XPUSHs(x); XSRETURN(1)

MODULE = Rstats::Array PACKAGE = Rstats::Array

MODULE = Rstats::Vector PACKAGE = Rstats::Vector

SV* values(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_values = self->get_values();
  return_sv(sv_values);
}

SV* value(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  IV pos;
  if (items < 2) {
    pos = 0;
  }
  else {
    pos = SvIV(ST(1));
  }
  
  SV* sv_value;
  if (pos >= 0 && pos < self->get_length()) {
    sv_value = Rstats::VectorFunc::get_value(self, pos);
  }
  else {
    sv_value = &PL_sv_undef;
  }
  
  return_sv(sv_value);
}

SV* is_character(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_character();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_complex(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_complex();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_numeric();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_double(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_double();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_integer(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_integer();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_logical(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = self->is_logical();
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* as(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_type = ST(1);
  Rstats::Vector* e2 = self->as(sv_type);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* to_string_pos(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV pos = SvIV(ST(1));
  SV* sv_str = self->to_string_pos(pos);
  return_sv(sv_str);
}

SV* to_string(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_str = self->to_string();
  return_sv(sv_str);
}

SV* as_character(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_character();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_complex(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_complex();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_logical(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_logical();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_numeric();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_double(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_double();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_integer(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = self->as_integer();
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Vector* elements = Rstats::Vector::new_null();
  SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
  return_sv(sv_elements);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV length = self->get_length();
  return_sv(Rstats::pl_new_sv_iv(length));
}

SV* length(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV length = self->get_length();
  Rstats::Vector* length_elements = Rstats::Vector::new_double(1, length);
  SV* sv_length_elements = Rstats::pl_to_perl_obj(length_elements, "Rstats::Vector");
  return_sv(sv_length_elements);
}

SV*
is_na(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
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
  
  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
compose(...)
  PPCODE:
{
  SV* sv_mode = ST(1);
  SV* sv_elements = ST(2);
  IV len = Rstats::pl_av_len(sv_elements);
  
  Rstats::Vector* compose_elements;
  std::vector<IV> na_positions;
  char* mode = SvPV_nolen(sv_mode);
  if (strEQ(mode, "character")) {
    compose_elements = Rstats::Vector::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
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
  else if (strEQ(mode, "complex")) {
    compose_elements = Rstats::Vector::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
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
  else if (strEQ(mode, "double")) {
    compose_elements = Rstats::Vector::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
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
  else if (strEQ(mode, "integer")) {
    compose_elements = Rstats::Vector::new_integer(len);
    std::vector<IV>* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
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
  else if (strEQ(mode, "logical")) {
    compose_elements = Rstats::Vector::new_logical(len);
    std::vector<IV>* values = compose_elements->get_integer_values();
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
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
  
  SV* sv_compose_elements = Rstats::pl_to_perl_obj(compose_elements, "Rstats::Vector");
  
  return_sv(sv_compose_elements);
}

SV*
decompose(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_decompose_elements = Rstats::pl_new_av_ref();
  
  IV length = self->get_length();
  
  if (length > 0) {
    av_extend(Rstats::pl_av_deref(sv_decompose_elements), length);

    if (self->is_character()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_character(1, self->get_character_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_complex()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_complex(1, self->get_complex_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_double()) {

      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_double(1, self->get_double_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
       SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_integer()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_integer(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (self->is_logical()) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Vector::new_logical(1, self->get_integer_value(i));
        if (self->exists_na_position(i)) {
          elements->add_na_position(0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
  }
  
  return_sv(sv_decompose_elements);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* rets = Rstats::VectorFunc::is_finite(self);

  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
clone(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* e2 = Rstats::VectorFunc::clone(self);

  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  
  return_sv(sv_e2);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* rets = Rstats::VectorFunc::is_infinite(self);
  
  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));

  Rstats::Vector* rets = Rstats::VectorFunc::is_nan(self);

  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_type;

  if (self->is_logical()) {
    sv_type = Rstats::pl_new_sv_pv("logical");
  }
  else if (self->is_integer()) {
    sv_type = Rstats::pl_new_sv_pv("integer");
  }
  else if (self->is_double()) {
    sv_type = Rstats::pl_new_sv_pv("double");
  }
  else if (self->is_complex()) {
    sv_type = Rstats::pl_new_sv_pv("complex");
  }
  else if (self->is_character()) {
    sv_type = Rstats::pl_new_sv_pv("character");
  }
  
  return_sv(sv_type);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_flag;
  if (self->get_type() == Rstats::VectorType::DOUBLE) {
    if (Rstats::VectorFunc::is_infinite(self)) {
      NV value = self->get_double_value(0);
      if (value > 0) {
        sv_flag = Rstats::pl_new_sv_pv("inf");
      }
      else {
        sv_flag = Rstats::pl_new_sv_pv("-inf");
      }
    }
    else if(Rstats::VectorFunc::is_nan(self)) {
      sv_flag = Rstats::pl_new_sv_pv("nan");
    }
    else {
      sv_flag = Rstats::pl_new_sv_pv("normal");
    }
  }
  else {
    sv_flag = Rstats::pl_new_sv_pv("normal");
  }
  
  return_sv(sv_flag);
}

SV*
DESTROY(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));

  delete self;
}

MODULE = Rstats::VectorFunc PACKAGE = Rstats::VectorFunc

SV*
negation(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::negation(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
remainder(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::reminder(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
and(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::And(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
or(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::Or(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* Conj(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Conj(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Re(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Re(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Im(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Im(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
less_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
less_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
not_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::not_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
sum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
prod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::prod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cumsum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cumsum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cumprod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cumprod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
add(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::add(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
atan2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::atan2(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
subtract(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::subtract(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
multiply(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::multiply(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
divide(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::divide(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
pow(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::pow(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
sqrt(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sqrt(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
asinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::asinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
acosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::acosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
atanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::atanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
asin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::asin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
acos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::acos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
atan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::atan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
abs(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::abs(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
logb(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::logb(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log10(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log10(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log2(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
Arg(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Arg(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
Mod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Mod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
exp(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::exp(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
expm1(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::expm1(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Vector* re = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* im = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* z = Rstats::Vector::new_complex(
    1,
    std::complex<NV>(re->get_double_value(0), im->get_double_value(0))
  );
  SV* sv_z = Rstats::pl_to_perl_obj(z, "Rstats::Vector");
  return_sv(sv_z);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_negative_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_nan();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_na();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_null();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_character(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_character(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      element->set_character_value(i, sv_value);
    }
    else {
      element->add_na_position(i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");

  return_sv(sv_element);
}

SV*
new_complex(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_complex(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    
    if (SvOK(sv_value)) {
      SV* sv_value_re = Rstats::pl_hv_fetch(sv_value, "re");
      SV* sv_value_im = Rstats::pl_hv_fetch(sv_value, "im");
      
      NV value_re;
      if (SvOK(sv_value_re)) {
        char* sv_value_re_str = SvPV_nolen(sv_value_re);
        if (strEQ(sv_value_re_str, "NaN")) {
          value_re =NAN;
        }
        else if (strEQ(sv_value_re_str, "Inf")) {
          value_re = INFINITY;
        }
        else if (strEQ(sv_value_re_str, "-Inf")) {
          value_re = -(INFINITY);
        }
        else {
          value_re = SvNV(sv_value_re);
        }
      }
      else {
        value_re = 0;
      }

      NV value_im;
      if (SvOK(sv_value_im)) {
        char* sv_value_im_str = SvPV_nolen(sv_value_im);
        if (strEQ(sv_value_im_str, "NaN")) {
          value_im =NAN;
        }
        else if (strEQ(sv_value_im_str, "Inf")) {
          value_im = INFINITY;
        }
        else if (strEQ(sv_value_im_str, "-Inf")) {
          value_im = -(INFINITY);
        }
        else {
          value_im = SvNV(sv_value_im);
        }
      }
      else {
        value_im = 0;
      }
      
      element->set_complex_value(i, std::complex<NV>(value_re, value_im));
    }
    else {
      element->add_na_position(i);
    }
  }

  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_logical(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_logical(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      element->set_integer_value(i, value ? 1 : 0);
    }
    else {
      element->add_na_position(i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_true();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_false();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_double(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_double(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      char* sv_value_str = SvPV_nolen(sv_value);
      if (strEQ(sv_value_str, "NaN")) {
        element->set_double_value(i, NAN);
      }
      else if (strEQ(sv_value_str, "Inf")) {
        element->set_double_value(i, INFINITY);
      }
      else if (strEQ(sv_value_str, "-Inf")) {
        element->set_double_value(i, -(INFINITY));
      }
      else {
        NV value = SvNV(sv_value);
        element->set_double_value(i, value);
      }
    }
    else {
      element->add_na_position(i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_integer(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Vector::new_integer(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      element->set_integer_value(i, value);
    }
    else {
      element->add_na_position(i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
is_perl_number(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  IV ret = Rstats::Util::is_perl_number(sv_str);
  SV* sv_ret = ret ? Rstats::pl_new_sv_iv(1) : &PL_sv_undef;
  return_sv(sv_ret);
}

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
  SV* sv_ret = Rstats::Util::cross_product(ST(0));
  return_sv(sv_ret);
}

SV*
pos_to_index(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::pos_to_index(ST(0), ST(1));
  return_sv(sv_ret);
}

SV*
index_to_pos(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::index_to_pos(ST(0), ST(1));
  return_sv(sv_ret);
}

MODULE = Rstats::ArrayFunc PACKAGE = Rstats::ArrayFunc

SV* args(...)
  PPCODE:
{
  SV* sv_names = ST(0);
  SV* sv_args = Rstats::pl_new_av_ref();
  
  for (IV i = 1; i < items; i++) {
    Rstats::pl_av_push(sv_args, ST(i));
  }
  
  SV* sv_opt = Rstats::Util::args(sv_names, sv_args);
  
  return_sv(sv_opt);
}

SV* to_c(...)
  PPCODE:
{
  SV* sv_x = Rstats::ArrayFunc::to_c(ST(0));
  
  return_sv(sv_x);
}

SV* c(...)
  PPCODE:
{
  SV* sv_values;
  if (sv_derived_from(ST(0), "ARRAY")) {
    sv_values = ST(0);
  }
  else {
    sv_values = Rstats::pl_new_av_ref();
    for (IV i = 0; i < items; i++) {
      Rstats::pl_av_push(sv_values, ST(i));
    }
  }
  
  SV* sv_x1 = Rstats::ArrayFunc::c(sv_values);
  
  return_sv(sv_x1);
}

MODULE = Rstats::Func PACKAGE = Rstats::Func

MODULE = Rstats PACKAGE = Rstats
