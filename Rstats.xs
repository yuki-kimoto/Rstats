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
  SV* sv_values = Rstats::Func::Vector::get_values(self);
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
  if (pos >= 0 && pos < Rstats::Func::Vector::get_length(self)) {
    sv_value = Rstats::Func::Vector::get_value(self, pos);
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
  bool is = Rstats::Func::Vector::is_character(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_complex(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = Rstats::Func::Vector::is_complex(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = Rstats::Func::Vector::is_numeric(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_double(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = Rstats::Func::Vector::is_double(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_integer(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = Rstats::Func::Vector::is_integer(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* is_logical(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  bool is = Rstats::Func::Vector::is_logical(self);
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  return_sv(sv_is);
}

SV* as(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_type = ST(1);
  Rstats::Vector* e2 = Rstats::Func::Vector::as(self, sv_type);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* to_string_pos(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV pos = SvIV(ST(1));
  SV* sv_str = Rstats::Func::Vector::to_string_pos(self, pos);
  return_sv(sv_str);
}

SV* to_string(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_str = Rstats::Func::Vector::to_string(self);
  return_sv(sv_str);
}

SV* as_character(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_character(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_complex(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_complex(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_logical(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_logical(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_numeric(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_numeric(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_double(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_double(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* as_integer(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::as_integer(self);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Vector* elements = Rstats::Func::Vector::new_null();
  SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
  return_sv(sv_elements);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV length = Rstats::Func::Vector::get_length(self);
  return_sv(Rstats::pl_new_sv_iv(length));
}

SV* length(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV length = Rstats::Func::Vector::get_length(self);
  Rstats::Vector* length_elements = Rstats::Func::Vector::new_double(1, length);
  SV* sv_length_elements = Rstats::pl_to_perl_obj(length_elements, "Rstats::Vector");
  return_sv(sv_length_elements);
}

SV*
is_na(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  IV length = Rstats::Func::Vector::get_length(self);
  Rstats::Vector* rets = Rstats::Func::Vector::new_logical(length);
  
  for (IV i = 0; i < length; i++) {
    if (Rstats::Func::Vector::exists_na_position(self, i)) {
      Rstats::Func::Vector::set_integer_value(rets, i, 1);
    }
    else {
      Rstats::Func::Vector::set_integer_value(rets, i, 0);
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
    compose_elements = Rstats::Func::Vector::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Func::Vector::new_na();
      }
      if (Rstats::Func::Vector::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::Func::Vector::set_character_value(compose_elements, i, Rstats::Func::Vector::get_character_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "complex")) {
    compose_elements = Rstats::Func::Vector::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Func::Vector::new_na();
      }
      if (Rstats::Func::Vector::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
       Rstats::Func::Vector::set_complex_value(compose_elements, i, Rstats::Func::Vector::get_complex_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "double")) {
    compose_elements = Rstats::Func::Vector::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Func::Vector::new_na();
      }
      if (Rstats::Func::Vector::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::Func::Vector::set_double_value(compose_elements, i, Rstats::Func::Vector::get_double_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "integer")) {
    compose_elements = Rstats::Func::Vector::new_integer(len);
    std::vector<IV>* values = Rstats::Func::Vector::get_integer_values(compose_elements);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Func::Vector::new_na();
      }
      if (Rstats::Func::Vector::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::Func::Vector::set_integer_value(compose_elements, i, Rstats::Func::Vector::get_integer_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "logical")) {
    compose_elements = Rstats::Func::Vector::new_logical(len);
    std::vector<IV>* values = Rstats::Func::Vector::get_integer_values(compose_elements);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::Func::Vector::new_na();
      }
      if (Rstats::Func::Vector::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::Func::Vector::set_integer_value(compose_elements, i, Rstats::Func::Vector::get_integer_value(element, 0));
      }
    }
  }
  else {
    croak("Unknown type(Rstats::Func::Vector::compose)");
  }
  
  for (IV i = 0; i < na_positions.size(); i++) {
    Rstats::Func::Vector::add_na_position(compose_elements, na_positions[i]);
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
  
  IV length = Rstats::Func::Vector::get_length(self);
  
  if (length > 0) {
    av_extend(Rstats::pl_av_deref(sv_decompose_elements), length);

    if (Rstats::Func::Vector::is_character(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Func::Vector::new_character(1, Rstats::Func::Vector::get_character_value(self, i));
        if (Rstats::Func::Vector::exists_na_position(self, i)) {
          Rstats::Func::Vector::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::Func::Vector::is_complex(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Func::Vector::new_complex(1, Rstats::Func::Vector::get_complex_value(self, i));
        if (Rstats::Func::Vector::exists_na_position(self, i)) {
          Rstats::Func::Vector::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::Func::Vector::is_double(self)) {

      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Func::Vector::new_double(1, Rstats::Func::Vector::get_double_value(self, i));
        if (Rstats::Func::Vector::exists_na_position(self, i)) {
          Rstats::Func::Vector::add_na_position(elements, 0);
        }
       SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::Func::Vector::is_integer(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Func::Vector::new_integer(1, Rstats::Func::Vector::get_integer_value(self, i));
        if (Rstats::Func::Vector::exists_na_position(self, i)) {
          Rstats::Func::Vector::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::Func::Vector::is_logical(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::Func::Vector::new_logical(1, Rstats::Func::Vector::get_integer_value(self, i));
        if (Rstats::Func::Vector::exists_na_position(self, i)) {
          Rstats::Func::Vector::add_na_position(elements, 0);
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
  
  Rstats::Vector* rets = Rstats::Func::Vector::is_finite(self);

  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
clone(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* e2 = Rstats::Func::Vector::clone(self);

  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  
  return_sv(sv_e2);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  Rstats::Vector* rets = Rstats::Func::Vector::is_infinite(self);
  
  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));

  Rstats::Vector* rets = Rstats::Func::Vector::is_nan(self);

  SV* sv_rets = Rstats::pl_to_perl_obj(rets, "Rstats::Vector");
  
  return_sv(sv_rets);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_type;

  if (Rstats::Func::Vector::is_logical(self)) {
    sv_type = Rstats::pl_new_sv_pv("logical");
  }
  else if (Rstats::Func::Vector::is_integer(self)) {
    sv_type = Rstats::pl_new_sv_pv("integer");
  }
  else if (Rstats::Func::Vector::is_double(self)) {
    sv_type = Rstats::pl_new_sv_pv("double");
  }
  else if (Rstats::Func::Vector::is_complex(self)) {
    sv_type = Rstats::pl_new_sv_pv("complex");
  }
  else if (Rstats::Func::Vector::is_character(self)) {
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
  if (Rstats::Func::Vector::get_type(self) == Rstats::VectorType::DOUBLE) {
    if (Rstats::Func::Vector::is_infinite(self)) {
      NV value = Rstats::Func::Vector::get_double_value(self, 0);
      if (value > 0) {
        sv_flag = Rstats::pl_new_sv_pv("inf");
      }
      else {
        sv_flag = Rstats::pl_new_sv_pv("-inf");
      }
    }
    else if(Rstats::Func::Vector::is_nan(self)) {
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

  Rstats::Func::Vector::delete_vector(self);
}

MODULE = Rstats::Func::Vector PACKAGE = Rstats::Func::Vector

SV*
negation(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::negation(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
remainder(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::reminder(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
and(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::And(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
or(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::Or(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* Conj(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::Conj(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Re(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::Re(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Im(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::Im(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
less_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::less_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::more_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
less_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::less_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
more_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::more_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
not_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::not_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
sum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::sum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
prod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::prod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cumsum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::cumsum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cumprod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::cumprod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
add(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::add(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
atan2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::atan2(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
subtract(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::subtract(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
multiply(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::multiply(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
divide(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::divide(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
pow(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::Func::Vector::pow(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV*
sqrt(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::sqrt(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::sin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
asinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::asinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
acosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::acosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
atanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::atanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
asin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::asin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
acos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::acos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
atan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::atan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::cos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::tan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
sinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::sinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
cosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::cosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
tanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::tanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
abs(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::abs(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::log(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
logb(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::logb(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log10(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::log10(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
log2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::log2(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
Arg(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::Arg(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
Mod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::Mod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
exp(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::exp(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
expm1(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::Func::Vector::expm1(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Vector* re = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* im = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* z = Rstats::Func::Vector::new_complex(
    1,
    std::complex<NV>(Rstats::Func::Vector::get_double_value(re, 0), Rstats::Func::Vector::get_double_value(im, 0))
  );
  SV* sv_z = Rstats::pl_to_perl_obj(z, "Rstats::Vector");
  return_sv(sv_z);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_negative_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_nan();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_na();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_null();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_character(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_character(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      Rstats::Func::Vector::set_character_value(element, i, sv_value);
    }
    else {
      Rstats::Func::Vector::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");

  return_sv(sv_element);
}

SV*
new_complex(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_complex(items);
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
      
      Rstats::Func::Vector::set_complex_value(element, i, std::complex<NV>(value_re, value_im));
    }
    else {
      Rstats::Func::Vector::add_na_position(element, i);
    }
  }

  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_logical(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_logical(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      Rstats::Func::Vector::set_integer_value(element, i, value ? 1 : 0);
    }
    else {
      Rstats::Func::Vector::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_true();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_false();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_double(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_double(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      char* sv_value_str = SvPV_nolen(sv_value);
      if (strEQ(sv_value_str, "NaN")) {
        Rstats::Func::Vector::set_double_value(element, i, NAN);
      }
      else if (strEQ(sv_value_str, "Inf")) {
        Rstats::Func::Vector::set_double_value(element, i, INFINITY);
      }
      else if (strEQ(sv_value_str, "-Inf")) {
        Rstats::Func::Vector::set_double_value(element, i, -(INFINITY));
      }
      else {
        NV value = SvNV(sv_value);
        Rstats::Func::Vector::set_double_value(element, i, value);
      }
    }
    else {
      Rstats::Func::Vector::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV*
new_integer(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::Func::Vector::new_integer(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      Rstats::Func::Vector::set_integer_value(element, i, value);
    }
    else {
      Rstats::Func::Vector::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
pi(...)
  PPCODE:
{
  NV pi = Rstats::Util::pi();
  SV* sv_pi = Rstats::pl_new_sv_nv(pi);
  
  return_sv(sv_pi);
}

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

MODULE = Rstats::Func::Array PACKAGE = Rstats::Func::Array

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
  SV* sv_x = Rstats::Func::Array::to_c(ST(0), ST(1));
  
  return_sv(sv_x);
}

SV* c(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_values;
  if (sv_derived_from(ST(1), "ARRAY")) {
    sv_values = ST(1);
  }
  else {
    sv_values = Rstats::pl_new_av_ref();
    for (IV i = 1; i < items; i++) {
      Rstats::pl_av_push(sv_values, ST(i));
    }
  }
  
  SV* sv_x1 = Rstats::Func::Array::c(sv_r, sv_values);
  
  return_sv(sv_x1);
}

MODULE = Rstats::Func PACKAGE = Rstats::Func

MODULE = Rstats PACKAGE = Rstats
