/* Rstats headers */
#include "Rstats.h"

/* Shortcut of return sv */
#define return_sv(x) XPUSHs(x); XSRETURN(1);

MODULE = Rstats::Vector PACKAGE = Rstats::Vector

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

SV* first_value(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  Rstats::Vector* self = Rstats::Func::get_vector(sv_r, ST(1));;
  
  IV pos = 0;
  
  SV* sv_value = Rstats::VectorFunc::get_value(self, 0);
  
  return_sv(sv_value);
}

SV* tanh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::tanh, sv_x1);
  
  return_sv(sv_x2);
}

SV* Mod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::Mod, sv_x1);
  
  return_sv(sv_x2);
}

SV* Arg(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::Arg, sv_x1);
  
  return_sv(sv_x2);
}

SV* Conj(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::Conj, sv_x1);
  
  return_sv(sv_x2);
}

SV* acosh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::acosh, sv_x1);
  
  return_sv(sv_x2);
}

SV* Re(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::Re, sv_x1);
  
  return_sv(sv_x2);
}

SV* Im(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::Im, sv_x1);
  
  return_sv(sv_x2);
}

SV* abs(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::abs, sv_x1);
  
  return_sv(sv_x2);
}

SV* acos(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::acos, sv_x1);
  
  return_sv(sv_x2);
}

SV* asin(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::asin, sv_x1);
  
  return_sv(sv_x2);
}

SV* asinh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::asinh, sv_x1);
  
  return_sv(sv_x2);
}

SV* atan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::atan, sv_x1);
  
  return_sv(sv_x2);
}

SV* atanh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::atanh, sv_x1);
  
  return_sv(sv_x2);
}

SV* cos(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::cos, sv_x1);
  
  return_sv(sv_x2);
}

SV* cosh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::cosh, sv_x1);
  
  return_sv(sv_x2);
}

SV* cumsum(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::cumsum, sv_x1);
  
  return_sv(sv_x2);
}

SV* cumprod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::cumprod, sv_x1);
  
  return_sv(sv_x2);
}

SV* exp(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::exp, sv_x1);
  
  return_sv(sv_x2);
}

SV* expm1(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::expm1, sv_x1);
  
  return_sv(sv_x2);
}

SV* log(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::log, sv_x1);
  
  return_sv(sv_x2);
}

SV* logb(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::logb, sv_x1);
  
  return_sv(sv_x2);
}

SV* log2(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::log2, sv_x1);
  
  return_sv(sv_x2);
}

SV* log10(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::log10, sv_x1);
  
  return_sv(sv_x2);
}

SV* prod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::prod, sv_x1);
  
  return_sv(sv_x2);
}

SV* sinh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::sinh, sv_x1);
  
  return_sv(sv_x2);
}

SV* sqrt(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::sqrt, sv_x1);
  
  return_sv(sv_x2);
}

SV* tan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::tan, sv_x1);
  
  return_sv(sv_x2);
}

SV* sin(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::sin, sv_x1);
  
  return_sv(sv_x2);
}

SV* sum(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::sum, sv_x1);
  
  return_sv(sv_x2);
}

SV* negation(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = Rstats::Func::to_c(sv_r, ST(1));
  SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::negation, sv_x1);
  
  return_sv(sv_x2);
}


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
    Rstats::Func::dim(sv_r, sv_x1, sv_x_dim);
    return_sv(sv_r);
  }
  else {
    SV* sv_x_dim = Rstats::Func::dim(sv_r, sv_x1);
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

SV* F_(...)
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

SV* T_(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = Rstats::Func::new_true(sv_r);
  
  return_sv(sv_x1);
}

SV* args_h(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_names = ST(1);
  SV* sv_args_h = Rstats::pl_new_av_ref();
  
  for (IV i = 2; i < items; i++) {
    Rstats::pl_av_push(sv_args_h, ST(i));
  }
  
  SV* sv_opt = Rstats::Func::args_h(sv_r, sv_names, sv_args_h);
  
  return_sv(sv_opt);
}

SV* to_c(...)
  PPCODE:
{
  SV* sv_x = Rstats::Func::to_c(ST(0), ST(1));
  
  return_sv(sv_x);
}

SV* c_(...)
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
    Rstats::Func::Class(sv_r, sv_x1, sv_x2);
    return_sv(sv_r);
  }
  else {
    SV* sv_x2 = Rstats::Func::Class(sv_r, sv_x1);
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

SV* decompose(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* x1 = ST(1);
  SV* sv_decomposed = Rstats::Func::decompose(sv_r, x1);
  return_sv(sv_decomposed);
}

SV* compose(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_type = ST(1);
  SV* sv_x1 = ST(2);

  SV* sv_composed = Rstats::Func::compose(sv_r, sv_type, sv_x1);
  return_sv(sv_composed);
}

SV* array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  // Args
  SV* sv_args = Rstats::pl_new_av_ref();
  for (IV i = 1; i < items; i++) {
    Rstats::pl_av_push(sv_args, ST(i));
  }
  SV* sv_names = Rstats::pl_new_av_ref();
  Rstats::pl_av_push(sv_names, Rstats::pl_new_sv_pv("x"));
  Rstats::pl_av_push(sv_names, Rstats::pl_new_sv_pv("dim"));
  SV* sv_args_h = Rstats::Func::args_h(sv_r, sv_names, sv_args);
  
  SV* sv_result = Rstats::Func::array_with_opt(sv_r, sv_args_h);
  return_sv(sv_result);
}

SV* as_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x2 = Rstats::Func::as_array(sv_r, sv_x1);
  return_sv(sv_x2);
}

SV* levels(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  if (items > 2) {
    SV* sv_x2 = ST(2);
    Rstats::Func::levels(sv_r, sv_x1, sv_x2);
    return_sv(sv_r);
  }
  else {
    SV* sv_x2 = Rstats::Func::levels(sv_r, sv_x1);
    return_sv(sv_x2);
  }
}

SV* as_character(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x2 = Rstats::Func::as_character(sv_r, sv_x1);
  return_sv(sv_x2);
}

SV* mode(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  if (items > 2) {
    SV* sv_x_mode = ST(2);
    Rstats::Func::mode(sv_r, sv_x1, sv_x_mode);
      
    return_sv(sv_r);
  }
  else {
    SV* sv_x_mode = Rstats::Func::mode(sv_r, sv_x1);
    return_sv(sv_x_mode);
  }
}

SV* as(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_type = ST(1);
  SV* sv_x1 = ST(2);
  
  SV* sv_x2 = Rstats::Func::as(sv_r, sv_type, sv_x1);
  
  return_sv(sv_x2);
}

SV* length(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x2 = Rstats::Func::length(sv_r, sv_x1);
  
  return_sv(sv_x2);
}

SV* names(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  if (items > 2) {
    SV* sv_x_names = ST(2);
    Rstats::Func::names(sv_r, sv_x1, sv_x_names);
      
    return_sv(sv_r);
  }
  else {
    SV* sv_x_names = Rstats::Func::names(sv_r, sv_x1);
    return_sv(sv_x_names);
  }
}

SV* upgrade_type(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_xs = ST(1);
  
  // Check elements
  std::map<Rstats::Type::Enum, IV> type_h;
  
  IV xs_length = Rstats::pl_av_len(sv_xs);
  for (IV i = 0; i < xs_length; i++) {
    SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
    Rstats::Vector* x1 = Rstats::Func::get_vector(sv_r, sv_x1);
    Rstats::Type::Enum type = Rstats::VectorFunc::get_type(x1);
    
    if (type == Rstats::Type::CHARACTER) {
      type_h[Rstats::Type::CHARACTER] = 1;
    }
    else if (type == Rstats::Type::COMPLEX) {
      type_h[Rstats::Type::COMPLEX] = 1;
    }
    else if (type == Rstats::Type::DOUBLE) {
      type_h[Rstats::Type::DOUBLE] = 1;
    }
    else if (type == Rstats::Type::INTEGER) {
      type_h[Rstats::Type::INTEGER] = 1;
    }
    else if (type == Rstats::Type::LOGICAL) {
      type_h[Rstats::Type::LOGICAL] = 1;
    }
    else {
      croak("Invalid type(Rstats::Func::upgrade_type()");
    }
  }

  // Upgrade elements and type if type is different
  SV* sv_new_xs = Rstats::pl_new_av_ref();;
  IV type_length = type_h.size();

  if (type_length > 1) {
    SV* sv_to_type;
    if (type_h.count(Rstats::Type::CHARACTER)) {
      sv_to_type = Rstats::pl_new_sv_pv("character");
    }
    else if (type_h.count(Rstats::Type::COMPLEX)) {
      sv_to_type = Rstats::pl_new_sv_pv("complex");
    }
    else if (type_h.count(Rstats::Type::DOUBLE)) {
      sv_to_type = Rstats::pl_new_sv_pv("double");
    }
    else if (type_h.count(Rstats::Type::INTEGER)) {
      sv_to_type = Rstats::pl_new_sv_pv("integer");
    }
    else if (type_h.count(Rstats::Type::LOGICAL)) {
      sv_to_type = Rstats::pl_new_sv_pv("logical");
    }
    
    for (IV i = 0; i < xs_length; i++) {
      SV* sv_x = Rstats::pl_av_fetch(sv_xs, i);
      Rstats::pl_av_push(sv_new_xs, Rstats::Func::as(sv_r, sv_to_type, sv_x));
    }
  }
  
  return_sv(sv_new_xs);
}


MODULE = Rstats PACKAGE = Rstats
