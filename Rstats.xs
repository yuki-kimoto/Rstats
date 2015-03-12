/* Rstats headers */
#include "Rstats.h"

/* Shortcut of return sv */
#define return_sv(x) XPUSHs(x); XSRETURN(1);

MODULE = Rstats::Vector PACKAGE = Rstats::Vector

SV* compose(...)
  PPCODE:
{
  SV* sv_mode = ST(1);
  SV* sv_elements = ST(2);
  IV len = Rstats::pl_av_len(sv_elements);
  
  Rstats::Vector* compose_elements;
  std::vector<IV> na_positions;
  char* mode = SvPV_nolen(sv_mode);
  if (strEQ(mode, "character")) {
    compose_elements = Rstats::VectorFunc::new_character(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::VectorFunc::new_na();
      }
      if (Rstats::VectorFunc::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::VectorFunc::set_character_value(compose_elements, i, Rstats::VectorFunc::get_character_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "complex")) {
    compose_elements = Rstats::VectorFunc::new_complex(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::VectorFunc::new_na();
      }
      if (Rstats::VectorFunc::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
       Rstats::VectorFunc::set_complex_value(compose_elements, i, Rstats::VectorFunc::get_complex_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "double")) {
    compose_elements = Rstats::VectorFunc::new_double(len);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::VectorFunc::new_na();
      }
      if (Rstats::VectorFunc::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::VectorFunc::set_double_value(compose_elements, i, Rstats::VectorFunc::get_double_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "integer")) {
    compose_elements = Rstats::VectorFunc::new_integer(len);
    std::vector<IV>* values = Rstats::VectorFunc::get_integer_values(compose_elements);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::VectorFunc::new_na();
      }
      if (Rstats::VectorFunc::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::VectorFunc::set_integer_value(compose_elements, i, Rstats::VectorFunc::get_integer_value(element, 0));
      }
    }
  }
  else if (strEQ(mode, "logical")) {
    compose_elements = Rstats::VectorFunc::new_logical(len);
    std::vector<IV>* values = Rstats::VectorFunc::get_integer_values(compose_elements);
    for (IV i = 0; i < len; i++) {
      Rstats::Vector* element;
      SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
      if (SvOK(sv_element)) {
        element = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      else {
        element = Rstats::VectorFunc::new_na();
      }
      if (Rstats::VectorFunc::exists_na_position(element, 0)) {
        na_positions.push_back(i);
      }
      else {
        Rstats::VectorFunc::set_integer_value(compose_elements, i, Rstats::VectorFunc::get_integer_value(element, 0));
      }
    }
  }
  else {
    croak("Unknown type(Rstats::VectorFunc::compose)");
  }
  
  for (IV i = 0; i < na_positions.size(); i++) {
    Rstats::VectorFunc::add_na_position(compose_elements, na_positions[i]);
  }
  
  SV* sv_compose_elements = Rstats::pl_to_perl_obj(compose_elements, "Rstats::Vector");
  
  return_sv(sv_compose_elements);
}

SV* decompose(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_decompose_elements = Rstats::pl_new_av_ref();
  
  IV length = Rstats::VectorFunc::get_length(self);
  
  if (length > 0) {
    av_extend(Rstats::pl_av_deref(sv_decompose_elements), length);

    if (Rstats::VectorFunc::is_character(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::VectorFunc::new_character(1, Rstats::VectorFunc::get_character_value(self, i));
        if (Rstats::VectorFunc::exists_na_position(self, i)) {
          Rstats::VectorFunc::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::VectorFunc::is_complex(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::VectorFunc::new_complex(1, Rstats::VectorFunc::get_complex_value(self, i));
        if (Rstats::VectorFunc::exists_na_position(self, i)) {
          Rstats::VectorFunc::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::VectorFunc::is_double(self)) {

      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::VectorFunc::new_double(1, Rstats::VectorFunc::get_double_value(self, i));
        if (Rstats::VectorFunc::exists_na_position(self, i)) {
          Rstats::VectorFunc::add_na_position(elements, 0);
        }
       SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::VectorFunc::is_integer(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::VectorFunc::new_integer(1, Rstats::VectorFunc::get_integer_value(self, i));
        if (Rstats::VectorFunc::exists_na_position(self, i)) {
          Rstats::VectorFunc::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
    else if (Rstats::VectorFunc::is_logical(self)) {
      for (IV i = 0; i < length; i++) {
        Rstats::Vector* elements
          = Rstats::VectorFunc::new_logical(1, Rstats::VectorFunc::get_integer_value(self, i));
        if (Rstats::VectorFunc::exists_na_position(self, i)) {
          Rstats::VectorFunc::add_na_position(elements, 0);
        }
        SV* sv_elements = Rstats::pl_to_perl_obj(elements, "Rstats::Vector");
        Rstats::pl_av_push(sv_decompose_elements, sv_elements);
      }
    }
  }
  
  return_sv(sv_decompose_elements);
}

SV* type(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_type;

  if (Rstats::VectorFunc::is_logical(self)) {
    sv_type = Rstats::pl_new_sv_pv("logical");
  }
  else if (Rstats::VectorFunc::is_integer(self)) {
    sv_type = Rstats::pl_new_sv_pv("integer");
  }
  else if (Rstats::VectorFunc::is_double(self)) {
    sv_type = Rstats::pl_new_sv_pv("double");
  }
  else if (Rstats::VectorFunc::is_complex(self)) {
    sv_type = Rstats::pl_new_sv_pv("complex");
  }
  else if (Rstats::VectorFunc::is_character(self)) {
    sv_type = Rstats::pl_new_sv_pv("character");
  }
  
  return_sv(sv_type);
}

SV* flag(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  
  SV* sv_flag;
  if (Rstats::VectorFunc::get_type(self) == Rstats::Type::DOUBLE) {
    if (Rstats::VectorFunc::is_infinite(self)) {
      NV value = Rstats::VectorFunc::get_double_value(self, 0);
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

SV* DESTROY(...)
  PPCODE:
{
  Rstats::Vector* self = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));

  Rstats::VectorFunc::delete_vector(self);
}

MODULE = Rstats::VectorFunc PACKAGE = Rstats::VectorFunc

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
  if (pos >= 0 && pos < Rstats::VectorFunc::get_length(self)) {
    sv_value = Rstats::VectorFunc::get_value(self, pos);
  }
  else {
    sv_value = &PL_sv_undef;
  }
  
  return_sv(sv_value);
}

SV* as_character(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::as_character(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  IV length = Rstats::VectorFunc::get_length(e1);
  return_sv(Rstats::pl_new_sv_iv(length));
}

SV* to_string(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  SV* sv_str = Rstats::VectorFunc::to_string(e1);
  return_sv(sv_str);
}

SV* negation(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::negation(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* remainder(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::reminder(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* and(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::And(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* or(...)
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

SV* less_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* more_than_or_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than_or_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* less_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::less_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* more_than(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::more_than(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* not_equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::not_equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* equal(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::equal(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* sum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* prod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::prod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* cumsum(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cumsum(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* cumprod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cumprod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* add(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::add(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* atan2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::atan2(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* subtract(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::subtract(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* multiply(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::multiply(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* divide(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::divide(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* pow(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* e3 = Rstats::VectorFunc::pow(e1, e2);
  SV* sv_e3 = Rstats::pl_to_perl_obj(e3, "Rstats::Vector");
  return_sv(sv_e3);
}

SV* sqrt(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sqrt(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* sin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* asinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::asinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* acosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::acosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* atanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::atanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* asin(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::asin(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* acos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::acos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* atan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::atan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* cos(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cos(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* tan(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tan(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* sinh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::sinh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* cosh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::cosh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* tanh(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::tanh(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* abs(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::abs(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* log(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* logb(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::logb(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* log10(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log10(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* log2(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::log2(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Arg(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Arg(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* Mod(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::Mod(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* exp(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::exp(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* expm1(...)
  PPCODE:
{
  Rstats::Vector* e1 = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* e2 = Rstats::VectorFunc::expm1(e1);
  SV* sv_e2 = Rstats::pl_to_perl_obj(e2, "Rstats::Vector");
  return_sv(sv_e2);
}

SV* complex_double (...)
  PPCODE:
{
  Rstats::Vector* re = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(0));
  Rstats::Vector* im = Rstats::pl_to_c_obj<Rstats::Vector*>(ST(1));
  Rstats::Vector* z = Rstats::VectorFunc::new_complex(
    1,
    std::complex<NV>(Rstats::VectorFunc::get_double_value(re, 0), Rstats::VectorFunc::get_double_value(im, 0))
  );
  SV* sv_z = Rstats::pl_to_perl_obj(z, "Rstats::Vector");
  return_sv(sv_z);
}

SV* new_negative_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_negative_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_inf(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_inf();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_nan(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_nan();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_na(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_na();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_null(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_null();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_character(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_character(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      Rstats::VectorFunc::set_character_value(element, i, sv_value);
    }
    else {
      Rstats::VectorFunc::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");

  return_sv(sv_element);
}

SV* new_complex(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_complex(items);
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
      
      Rstats::VectorFunc::set_complex_value(element, i, std::complex<NV>(value_re, value_im));
    }
    else {
      Rstats::VectorFunc::add_na_position(element, i);
    }
  }

  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_logical(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_logical(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      Rstats::VectorFunc::set_integer_value(element, i, value ? 1 : 0);
    }
    else {
      Rstats::VectorFunc::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_true(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_true();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_false(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_false();
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_double(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_double(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      char* sv_value_str = SvPV_nolen(sv_value);
      if (strEQ(sv_value_str, "NaN")) {
        Rstats::VectorFunc::set_double_value(element, i, NAN);
      }
      else if (strEQ(sv_value_str, "Inf")) {
        Rstats::VectorFunc::set_double_value(element, i, INFINITY);
      }
      else if (strEQ(sv_value_str, "-Inf")) {
        Rstats::VectorFunc::set_double_value(element, i, -(INFINITY));
      }
      else {
        NV value = SvNV(sv_value);
        Rstats::VectorFunc::set_double_value(element, i, value);
      }
    }
    else {
      Rstats::VectorFunc::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

SV* new_integer(...)
  PPCODE:
{
  Rstats::Vector* element = Rstats::VectorFunc::new_integer(items);
  for (int i = 0; i < items; i++) {
    SV* sv_value = ST(i);
    if (SvOK(sv_value)) {
      IV value = SvIV(sv_value);
      Rstats::VectorFunc::set_integer_value(element, i, value);
    }
    else {
      Rstats::VectorFunc::add_na_position(element, i);
    }
  }
  SV* sv_element = Rstats::pl_to_perl_obj(element, "Rstats::Vector");
  return_sv(sv_element);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV* pi(...)
  PPCODE:
{
  NV pi = Rstats::Util::pi();
  SV* sv_pi = Rstats::pl_new_sv_nv(pi);
  
  return_sv(sv_pi);
}

SV* is_perl_number(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  IV ret = Rstats::Util::is_perl_number(sv_str);
  SV* sv_ret = ret ? Rstats::pl_new_sv_iv(1) : &PL_sv_undef;
  return_sv(sv_ret);
}

SV* looks_like_integer(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_integer(sv_str);
  return_sv(sv_ret);
}

SV* looks_like_double(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_double(sv_str);
  return_sv(sv_ret);
}

SV* looks_like_na(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_na(sv_str);
  return_sv(sv_ret);
}

SV* looks_like_logical(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_logical(sv_str);
  return_sv(sv_ret);
}

SV* looks_like_complex(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_complex(sv_str);
  return_sv(sv_ret);
}

SV* cross_product(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::cross_product(ST(0));
  return_sv(sv_ret);
}

SV* pos_to_index(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::pos_to_index(ST(0), ST(1));
  return_sv(sv_ret);
}

SV* index_to_pos(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::index_to_pos(ST(0), ST(1));
  return_sv(sv_ret);
}

MODULE = Rstats::Func PACKAGE = Rstats::Func

SV* type(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::type(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_numeric(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_numeric(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_array(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_matrix(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_matrix(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* dim(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  if (items > 2) {
    SV* sv_x_dim = ST(2);
    Rstats::Func::set_dim(sv_r, sv_x1, sv_x_dim);
    return_sv(sv_r);
  }
  else {
    SV* sv_x_dim = Rstats::Func::get_dim(sv_r, sv_x1);
    return_sv(sv_x_dim);
  }
}

SV* values(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::values(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* length_value(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::length_value(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_vector(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_vector(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* pi(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::pi(sv_r);
  
  return_sv(sv_x1);
}

SV* NULL(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_null(sv_r);
  
  return_sv(sv_x1);
}

SV* NA(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_na(sv_r);
  
  return_sv(sv_x1);
}

SV* NaN(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_nan(sv_r);
  
  return_sv(sv_x1);
}

SV* Inf(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_inf(sv_r);
  
  return_sv(sv_x1);
}

SV* FALSE(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_false(sv_r);
  
  return_sv(sv_x1);
}

SV* F(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_false(sv_r);
  
  return_sv(sv_x1);
}

SV* TRUE(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_true(sv_r);
  
  return_sv(sv_x1);
}

SV* T(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_true(sv_r);
  
  return_sv(sv_x1);
}

SV* args(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_names = ST(1);
  SV* sv_args = Rstats::pl_new_av_ref();
  
  for (IV i = 2; i < items; i++) {
    Rstats::pl_av_push(sv_args, ST(i));
  }
  
  SV* sv_opt = Rstats::Util::args(sv_r, sv_names, sv_args);
  
  return_sv(sv_opt);
}

SV* to_c(...)
  PPCODE:
{
  SV* sv_x = Rstats::Func::to_c(ST(0), ST(1));
  
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
  
  SV* sv_x1 = Rstats::Func::c(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_character(...)
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

  SV* sv_x1 = Rstats::Func::new_character(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_double(...)
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

  SV* sv_x1 = Rstats::Func::new_double(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_complex(...)
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

  SV* sv_x1 = Rstats::Func::new_complex(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_integer(...)
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

  SV* sv_x1 = Rstats::Func::new_integer(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_logical(...)
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

  SV* sv_x1 = Rstats::Func::new_logical(sv_r, sv_values);
  
  return_sv(sv_x1);
}

SV* new_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_array = Rstats::Func::new_array(sv_r);
  
  return_sv(sv_array);
}

SV* is_double(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_double(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_integer(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_integer(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_complex(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_complex(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_character(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_character(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_logical(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_logical(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_data_frame(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_data_frame(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_list(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_list(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* as_vector(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_vector(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* new_data_frame(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_data_frame(sv_r);
  
  return_sv(sv_x1);
}

SV* new_list(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_list(sv_r);
  
  return_sv(sv_x1);
}

SV* new_vector(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_type = ST(1);
  SV* sv_values = ST(2);
  SV* sv_x1 = Rstats::Func::new_vector(sv_r, sv_type, sv_values);
  
  return_sv(sv_x1);
}

SV* copy_attrs_to(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  SV* sv_opt = items > 3 ? ST(3) : &PL_sv_undef;
  
  Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2, sv_opt);
  
  return_sv(sv_r);
}

SV* as_integer(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_integer(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* as_logical(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_logical(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* as_complex(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_complex(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* as_double(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_double(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* as_numeric(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::as_numeric(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_finite(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_finite(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_infinite(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_infinite(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_nan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_nan(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_na(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_na(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* class(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  if (items > 2) {
    SV* sv_x2 = ST(2);
    Rstats::Func::set_class(sv_r, sv_x1, sv_x2);
    return_sv(sv_r);
  }
  else {
    SV* sv_x2 = Rstats::Func::get_class(sv_r, sv_x1);
    return_sv(sv_x2);
  }
}

SV* is_factor(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_factor(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* is_ordered(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::is_ordered(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* clone(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::clone(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* dim_as_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = Rstats::Func::dim_as_array(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

MODULE = Rstats PACKAGE = Rstats
