/* Rstats headers */
#include "Rstats.h"

MODULE = Rstats::Func PACKAGE = Rstats::Func

SV* sin(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::sin(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* atan2(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::atan2(sv_r, ST(1), ST(2));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* or(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::Or(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* add(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::add(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* subtract(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::subtract(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* multiply(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::multiply(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* divide(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::divide(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* remainder(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::remainder(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* pow(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::pow(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* less_than(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::less_than(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* less_than_or_equal(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::less_than_or_equal(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* more_than(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::more_than(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* more_than_or_equal(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::more_than_or_equal(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* equal(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::equal(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* not_equal(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::not_equal(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* and(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  
  SV* sv_x_out = Rstats::Func::And(sv_r, sv_x1, sv_x2);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* first_value(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_value = Rstats::Func::create_sv_value(sv_r, ST(1), 0);
  
  XPUSHs(sv_value);
  XSRETURN(1);
}

SV* tanh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::tanh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* Mod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::Mod(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* Arg(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::Arg(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* acosh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::acosh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* abs(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::abs(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* acos(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::acos(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* asin(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::asin(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* asinh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::asinh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* atan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::atan(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* atanh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::atanh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* cos(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::cos(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* cosh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::cosh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* cumsum(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::cumsum(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* cumprod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::cumprod(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* exp(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::exp(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* expm1(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::expm1(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* log(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::log(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* logb(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::logb(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* log2(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::log2(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* log10(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::log10(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* prod(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::prod(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* sinh(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::sinh(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* sqrt(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::sqrt(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* tan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::tan(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* sum(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::sum(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* negate(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::negate(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_numeric(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::is_numeric(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* dim(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  if (items > 2) {
    SV* sv_x_dim = ST(2);
    Rstats::Func::dim(sv_r, sv_x1, sv_x_dim);
    XPUSHs(sv_x_dim);
    XSRETURN(1);
  }
  else {
    SV* sv_x_dim = Rstats::Func::dim(sv_r, sv_x1);
    XPUSHs(sv_x_dim);
    XSRETURN(1);
  }
}

SV* values(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::values(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* get_length(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::get_length_sv(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_vector(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::is_vector(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* pi(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::pi(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* NaN(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_NaN(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* Inf(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_Inf(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* FALSE(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_FALSE(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* F_(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_FALSE(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* TRUE(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_TRUE(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* T_(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x_out = Rstats::Func::new_TRUE(sv_r);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* args_h(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_names = ST(1);
  SV* sv_args_h = Rstats::pl_new_avrv();
  
  for (IV i = 2; i < items; i++) {
    Rstats::pl_av_push(sv_args_h, ST(i));
  }
  
  SV* sv_opt = Rstats::Func::args_h(sv_r, sv_names, sv_args_h);

  XPUSHs(sv_opt);
  XSRETURN(1);
}

SV* to_object(...)
  PPCODE:
{
  SV* sv_x = Rstats::Func::to_object(ST(0), ST(1));

  XPUSHs(sv_x);
  XSRETURN(1);
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
    sv_values = Rstats::pl_new_avrv();
    for (IV i = 1; i < items; i++) {
      Rstats::pl_av_push(sv_values, ST(i));
    }
  }
  
  SV* sv_x_out = Rstats::Func::c(sv_r, sv_values);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* c_double(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_values;
  if (sv_derived_from(ST(1), "ARRAY")) {
    sv_values = ST(1);
  }
  else {
    sv_values = Rstats::pl_new_avrv();
    for (IV i = 1; i < items; i++) {
      Rstats::pl_av_push(sv_values, ST(i));
    }
  }

  SV* sv_x_out = Rstats::Func::c_double(sv_r, sv_values);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* c_integer(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_values;
  if (sv_derived_from(ST(1), "ARRAY")) {
    sv_values = ST(1);
  }
  else {
    sv_values = Rstats::pl_new_avrv();
    for (IV i = 1; i < items; i++) {
      Rstats::pl_av_push(sv_values, ST(i));
    }
  }

  SV* sv_x_out = Rstats::Func::c_integer(sv_r, sv_values);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_double(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::is_double(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_integer(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::is_integer(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* copy_attrs_to(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x2 = ST(2);
  SV* sv_opt = items > 3 ? ST(3) : &PL_sv_undef;
  
  Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2, sv_opt);

  XPUSHs(sv_r);
  XSRETURN(1);
}

SV* as_integer(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::as_integer(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* as_double(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::as_double(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* as_numeric(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::as_numeric(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_finite(...)
  PPCODE:
{
  SV* sv_r = ST(0);

  SV* sv_x_out = Rstats::Func::is_finite(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_infinite(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::is_infinite(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* is_nan(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  SV* sv_x_out = Rstats::Func::is_nan(sv_r, ST(1));
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* clone(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::clone(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* dim_as_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  SV* sv_x_out = Rstats::Func::dim_as_array(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* decompose(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* x1 = ST(1);
  SV* sv_decomposed = Rstats::Func::decompose(sv_r, x1);

  XPUSHs(sv_decomposed);
  XSRETURN(1);
}

SV* compose(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_type = ST(1);
  SV* sv_x1 = ST(2);

  SV* sv_composed = Rstats::Func::compose(sv_r, sv_type, sv_x1);

  XPUSHs(sv_composed);
  XSRETURN(1);
}

SV* array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  
  // Args
  SV* sv_args = Rstats::pl_new_avrv();
  for (IV i = 1; i < items; i++) {
    Rstats::pl_av_push(sv_args, ST(i));
  }
  SV* sv_names = Rstats::pl_new_avrv();
  Rstats::pl_av_push(sv_names, Rstats::pl_new_sv_pv("x"));
  Rstats::pl_av_push(sv_names, Rstats::pl_new_sv_pv("dim"));
  SV* sv_args_h = Rstats::Func::args_h(sv_r, sv_names, sv_args);
  
  SV* sv_result = Rstats::Func::array_with_opt(sv_r, sv_args_h);

  XPUSHs(sv_result);
  XSRETURN(1);
}

SV* as_array(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x_out = Rstats::Func::as_array(sv_r, sv_x1);
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* as(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_type = ST(1);
  SV* sv_x1 = ST(2);
  
  SV* sv_x_out = Rstats::Func::as(sv_r, sv_type, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* length(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x_out = Rstats::Func::length(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

SV* get_type(...)
  PPCODE:
{
  SV* sv_r = ST(0);
  SV* sv_x1 = ST(1);
  
  SV* sv_x_out = Rstats::Func::get_type_sv(sv_r, sv_x1);
  
  XPUSHs(sv_x_out);
  XSRETURN(1);
}

MODULE = Rstats::Vector::Double PACKAGE = Rstats::Vector::Double

SV* DESTROY(...)
  PPCODE:
{
  SV* sv_v = ST(0);
  Rstats::Vector<double>* v
    = Rstats::pl_object_unwrap<Rstats::Vector<double>*>(sv_v, "Rstats::Vector::Double");
  delete v;
}

MODULE = Rstats::Vector::Integer PACKAGE = Rstats::Vector::Integer

SV* DESTROY(...)
  PPCODE:
{
  SV* sv_v = ST(0);
  Rstats::Vector<Rstats::Integer>* v
    = Rstats::pl_object_unwrap<Rstats::Vector<Rstats::Integer>*>(sv_v, "Rstats::Vector::Integer");
  delete v;
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV* is_perl_number(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  IV ret = Rstats::Util::is_perl_number(sv_str);
  SV* sv_ret = ret ? Rstats::pl_new_sv_iv(1) : &PL_sv_undef;
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* looks_like_integer(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_integer(sv_str);
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* looks_like_double(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_double(sv_str);
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* looks_like_na(...)
  PPCODE:
{
  SV* sv_str = ST(0);
  SV* sv_ret = Rstats::Util::looks_like_na(sv_str);
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* cross_product(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::cross_product(ST(0));
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* pos_to_index(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::pos_to_index(ST(0), ST(1));
  XPUSHs(sv_ret);
  XSRETURN(1);
}

SV* index_to_pos(...)
  PPCODE:
{
  SV* sv_ret = Rstats::Util::index_to_pos(ST(0), ST(1));
  XPUSHs(sv_ret);
  XSRETURN(1);
}

MODULE = Rstats PACKAGE = Rstats
