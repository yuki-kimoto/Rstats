#include "Rstats.h"

RSTATS_DEF_VECTOR_FUNC_UN_IS(is_infinite, Rstats::ElementFunc::is_infinite)
RSTATS_DEF_VECTOR_FUNC_UN_IS(is_finite, Rstats::ElementFunc::is_finite)
RSTATS_DEF_VECTOR_FUNC_UN_IS(is_nan, Rstats::ElementFunc::is_nan)

RSTATS_DEF_VECTOR_FUNC_UN_MATH(negation, Rstats::ElementFunc::negation)

RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sin, Rstats::ElementFunc::sin)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(cos, Rstats::ElementFunc::cos)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(tan, Rstats::ElementFunc::tan)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sinh, Rstats::ElementFunc::sinh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(cosh, Rstats::ElementFunc::cosh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(tanh, Rstats::ElementFunc::tanh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log, Rstats::ElementFunc::log)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(logb, Rstats::ElementFunc::logb)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log10, Rstats::ElementFunc::log10)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(log2, Rstats::ElementFunc::log2)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(expm1, Rstats::ElementFunc::expm1)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(exp, Rstats::ElementFunc::exp)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(sqrt, Rstats::ElementFunc::sqrt)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(atan, Rstats::ElementFunc::atan)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(asin, Rstats::ElementFunc::asin)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(acos, Rstats::ElementFunc::acos)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(asinh, Rstats::ElementFunc::asinh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(acosh, Rstats::ElementFunc::acosh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(atanh, Rstats::ElementFunc::atanh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Conj, Rstats::ElementFunc::Conj)

RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Arg, Rstats::ElementFunc::Arg)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(abs, Rstats::ElementFunc::abs)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Mod, Rstats::ElementFunc::Mod)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Re, Rstats::ElementFunc::Re)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Im, Rstats::ElementFunc::Im)

RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(equal, Rstats::ElementFunc::equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(not_equal, Rstats::ElementFunc::not_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(more_than, Rstats::ElementFunc::more_than);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(less_than, Rstats::ElementFunc::less_than);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(more_than_or_equal, Rstats::ElementFunc::more_than_or_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(less_than_or_equal, Rstats::ElementFunc::less_than_or_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(And, Rstats::ElementFunc::And);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Or, Rstats::ElementFunc::Or);

RSTATS_DEF_VECTOR_FUNC_BIN_MATH(add, Rstats::ElementFunc::add)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(subtract, Rstats::ElementFunc::subtract)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(multiply, Rstats::ElementFunc::multiply)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(reminder, Rstats::ElementFunc::reminder)

RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(divide, Rstats::ElementFunc::divide)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(atan2, Rstats::ElementFunc::atan2)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(pow, Rstats::ElementFunc::pow)

SV* Rstats::VectorFunc::get_value(Rstats::Vector* v1, IV pos) {

  SV* sv_value;
  
  Rstats::VectorType::Enum type = v1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      if (v1->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        sv_value = v1->get_character_value(pos);
      }
      break;
    case Rstats::VectorType::COMPLEX :
      if (v1->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        std::complex<NV> z = v1->get_complex_value(pos);
        
        NV re = z.real();
        SV* sv_re;
        if (std::isnan(re)) {
          sv_re = Rstats::pl_new_sv_pv("NaN");
        }
        else if (std::isinf(re) && re > 0) {
          sv_re = Rstats::pl_new_sv_pv("Inf");
        }
        else if (std::isinf(re) && re < 0) {
          sv_re = Rstats::pl_new_sv_pv("-Inf");
        }
        else {
          sv_re = Rstats::pl_new_sv_nv(re);
        }
        
        NV im = z.imag();
        SV* sv_im;
        if (std::isnan(im)) {
          sv_im = Rstats::pl_new_sv_pv("NaN");
        }
        else if (std::isinf(im) && im > 0) {
          sv_im = Rstats::pl_new_sv_pv("Inf");
        }
        else if (std::isinf(im) && im < 0) {
          sv_im = Rstats::pl_new_sv_pv("-Inf");
        }
        else {
          sv_im = Rstats::pl_new_sv_nv(im);
        }

        sv_value = Rstats::pl_new_hv_ref();
        Rstats::pl_hv_store(sv_value, "re", sv_re);
        Rstats::pl_hv_store(sv_value, "im", sv_im);
      }
      break;
    case Rstats::VectorType::DOUBLE :
      if (v1->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        NV value = v1->get_double_value(pos);
        if (std::isnan(value)) {
          sv_value = Rstats::pl_new_sv_pv("NaN");
        }
        else if (std::isinf(value) && value > 0) {
          sv_value = Rstats::pl_new_sv_pv("Inf");
        }
        else if (std::isinf(value) && value < 0) {
          sv_value = Rstats::pl_new_sv_pv("-Inf");
        }
        else {
          sv_value = Rstats::pl_new_sv_nv(value);
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      if (v1->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        IV value = v1->get_integer_value(pos);
        sv_value = Rstats::pl_new_sv_iv(value);
      }
      break;
    default:
      sv_value = &PL_sv_undef;
  }
  
  return sv_value;
}

Rstats::Vector* Rstats::VectorFunc::cumprod(Rstats::Vector* e1) {
  IV length = e1->get_length();
  Rstats::Vector* e2;
  Rstats::VectorType::Enum type = e1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in cumprod() : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      e2 = Rstats::Vector::new_complex(length);
      std::complex<NV> e2_total(1, 0);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_complex_value(i);
        e2->set_complex_value(i, e2_total);
      }
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      e2 = Rstats::Vector::new_double(length);
      NV e2_total(1);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_double_value(i);
        e2->set_double_value(i, e2_total);
      }
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      e2 = Rstats::Vector::new_integer(length);
      IV e2_total(1);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_integer_value(i);
        e2->set_integer_value(i, e2_total);
      }
      break;
    }
    default:
      croak("Invalid type");

  }

  e2->merge_na_positions(e1);
  
  return e2;
}

Rstats::Vector* Rstats::VectorFunc::cumsum(Rstats::Vector* e1) {
  IV length = e1->get_length();
  Rstats::Vector* e2;
  Rstats::VectorType::Enum type = e1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in cumsum() : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      e2 = Rstats::Vector::new_complex(length);
      std::complex<NV> e2_total(0, 0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_complex_value(i);
        e2->set_complex_value(i, e2_total);
      }
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      e2 = Rstats::Vector::new_double(length);
      NV e2_total(0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_double_value(i);
        e2->set_double_value(i, e2_total);
      }
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      e2 = Rstats::Vector::new_integer(length);
      IV e2_total(0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_integer_value(i);
        e2->set_integer_value(i, e2_total);
      }
      break;
    }
    default:
      croak("Invalid type");

    e2->merge_na_positions(e1);
  }
  
  return e2;
}

Rstats::Vector* Rstats::VectorFunc::prod(Rstats::Vector* e1) {
  
  IV length = e1->get_length();
  Rstats::Vector* e2;
  Rstats::VectorType::Enum type = e1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in prod() : non-numeric argument to prod()");
      break;
    case Rstats::VectorType::COMPLEX : {
      e2 = Rstats::Vector::new_complex(1);
      std::complex<NV> e2_total(1, 0);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_complex_value(i);
      }
      e2->set_complex_value(0, e2_total);
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      e2 = Rstats::Vector::new_double(1);
      NV e2_total(1);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_double_value(i);
      }
      e2->set_double_value(0, e2_total);
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      e2 = Rstats::Vector::new_integer(1);
      IV e2_total(1);
      for (IV i = 0; i < length; i++) {
        e2_total *= e1->get_integer_value(i);
      }
      e2->set_integer_value(0, e2_total);
      break;
    }
    default:
      croak("Invalid type");

  }

  for (IV i = 0; i < length; i++) {
    if (e1->exists_na_position(i)) {
      e2->add_na_position(0);
      break;
    }
  }
        
  return e2;
}

Rstats::Vector* Rstats::VectorFunc::sum(Rstats::Vector* e1) {
  
  IV length = e1->get_length();
  Rstats::Vector* e2;
  Rstats::VectorType::Enum type = e1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in a - b : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      e2 = Rstats::Vector::new_complex(1);
      std::complex<NV> e2_total(0, 0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_complex_value(i);
      }
      e2->set_complex_value(0, e2_total);
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      e2 = Rstats::Vector::new_double(1);
      NV e2_total(0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_double_value(i);
      }
      e2->set_double_value(0, e2_total);
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      e2 = Rstats::Vector::new_integer(1);
      IV e2_total(0);
      for (IV i = 0; i < length; i++) {
        e2_total += e1->get_integer_value(i);
      }
      e2->set_integer_value(0, e2_total);
      break;
    }
    default:
      croak("Invalid type");

  }
  
  for (IV i = 0; i < length; i++) {
    if (e1->exists_na_position(i)) {
      e2->add_na_position(0);
      break;
    }
  }
  
  return e2;
}

Rstats::Vector* Rstats::VectorFunc::clone(Rstats::Vector* e1) {
  
  IV length = e1->get_length();
  Rstats::Vector* e2;
  Rstats::VectorType::Enum type = e1->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      e2 = Rstats::Vector::new_character(length);
      for (IV i = 0; i < length; i++) {
        e2->set_character_value(i, e1->get_character_value(i));
      }
      break;
    case Rstats::VectorType::COMPLEX :
      e2 = Rstats::Vector::new_complex(length);
      for (IV i = 0; i < length; i++) {
        e2->set_complex_value(i, e1->get_complex_value(i));
      }
      break;
    case Rstats::VectorType::DOUBLE :
      e2 = Rstats::Vector::new_double(length);
      for (IV i = 0; i < length; i++) {
        e2->set_double_value(i, e1->get_double_value(i));
      }
      break;
    case Rstats::VectorType::INTEGER :
      e2 = Rstats::Vector::new_integer(length);
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, e1->get_integer_value(i));
      }
      break;
    case Rstats::VectorType::LOGICAL :
      e2 = Rstats::Vector::new_logical(length);
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, e1->get_integer_value(i));
      }
      break;
    default:
      croak("Invalid type");

  }
  
  e2->merge_na_positions(e1);
  
  return e2;
}