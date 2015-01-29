#include "Rstats.h"

RSTATS_DEF_VECTOR_FUNC_UN_IS(Rstats::Func::Vector::is_infinite, Rstats::ElementFunc::is_infinite)
RSTATS_DEF_VECTOR_FUNC_UN_IS(Rstats::Func::Vector::is_finite, Rstats::ElementFunc::is_finite)
RSTATS_DEF_VECTOR_FUNC_UN_IS(Rstats::Func::Vector::is_nan, Rstats::ElementFunc::is_nan)

RSTATS_DEF_VECTOR_FUNC_UN_MATH(Rstats::Func::Vector::negation, Rstats::ElementFunc::negation)

// sin2
void Rstats::Func::Vector::sin2(Rstats::Vector2<SV*>* v1) {
  croak("Error in sin() : invalid argument to sin()");
}
Rstats::Vector2<std::complex<NV> >* Rstats::Func::Vector::sin2(Rstats::Vector2<std::complex<NV> >* v1) {
  return Rstats::Func::Vector::operate_un_math<
      std::complex<NV>  (*)(std::complex<NV> ), std::complex<NV> , std::complex<NV>
    >(&Rstats::ElementFunc::sin, v1);
}
Rstats::Vector2<NV>* Rstats::Func::Vector::sin2(Rstats::Vector2<NV>* v1) {
  return Rstats::Func::Vector::operate_un_math<NV (*)(NV), NV, NV>(&Rstats::ElementFunc::sin, v1);
}
Rstats::Vector2<NV>* Rstats::Func::Vector::sin2(Rstats::Vector2<IV>* v1) {
  return Rstats::Func::Vector::operate_un_math<NV (*)(IV), NV, IV>(&Rstats::ElementFunc::sin, v1);
}

RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::sin, Rstats::ElementFunc::sin)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::cos, Rstats::ElementFunc::cos)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::tan, Rstats::ElementFunc::tan)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::sinh, Rstats::ElementFunc::sinh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::cosh, Rstats::ElementFunc::cosh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::tanh, Rstats::ElementFunc::tanh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::log, Rstats::ElementFunc::log)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::logb, Rstats::ElementFunc::logb)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::log10, Rstats::ElementFunc::log10)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::log2, Rstats::ElementFunc::log2)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::expm1, Rstats::ElementFunc::expm1)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::exp, Rstats::ElementFunc::exp)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::sqrt, Rstats::ElementFunc::sqrt)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::atan, Rstats::ElementFunc::atan)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::asin, Rstats::ElementFunc::asin)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::acos, Rstats::ElementFunc::acos)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::asinh, Rstats::ElementFunc::asinh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::acosh, Rstats::ElementFunc::acosh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::atanh, Rstats::ElementFunc::atanh)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::Conj, Rstats::ElementFunc::Conj)

RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Rstats::Func::Vector::Arg, Rstats::ElementFunc::Arg)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Rstats::Func::Vector::abs, Rstats::ElementFunc::abs)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Rstats::Func::Vector::Mod, Rstats::ElementFunc::Mod)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Rstats::Func::Vector::Re, Rstats::ElementFunc::Re)
RSTATS_DEF_VECTOR_FUNC_UN_MATH_COMPLEX_INTEGER_TO_DOUBLE(Rstats::Func::Vector::Im, Rstats::ElementFunc::Im)

RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::equal, Rstats::ElementFunc::equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::not_equal, Rstats::ElementFunc::not_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::more_than, Rstats::ElementFunc::more_than);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::less_than, Rstats::ElementFunc::less_than);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::more_than_or_equal, Rstats::ElementFunc::more_than_or_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::less_than_or_equal, Rstats::ElementFunc::less_than_or_equal);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::And, Rstats::ElementFunc::And);
RSTATS_DEF_VECTOR_FUNC_BIN_TO_LOGICAL(Rstats::Func::Vector::Or, Rstats::ElementFunc::Or);

RSTATS_DEF_VECTOR_FUNC_BIN_MATH(Rstats::Func::Vector::add, Rstats::ElementFunc::add)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(Rstats::Func::Vector::subtract, Rstats::ElementFunc::subtract)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(Rstats::Func::Vector::multiply, Rstats::ElementFunc::multiply)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH(Rstats::Func::Vector::reminder, Rstats::ElementFunc::reminder)

RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::divide, Rstats::ElementFunc::divide)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::atan2, Rstats::ElementFunc::atan2)
RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(Rstats::Func::Vector::pow, Rstats::ElementFunc::pow)


SV* Rstats::Func::Vector::get_values(Rstats::Vector* v1) {
  
  IV length = Rstats::Func::Vector::get_length(v1);
  SV* sv_values = Rstats::pl_new_av_ref();
  for (IV i = 0; i < length; i++) {
    Rstats::pl_av_push(sv_values, Rstats::Func::Vector::get_value(v1, i));
  }
  
  return sv_values;
}

bool Rstats::Func::Vector::is_character (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::CHARACTER;
}

bool Rstats::Func::Vector::is_complex (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::COMPLEX;
}

bool Rstats::Func::Vector::is_double (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::DOUBLE;
}

bool Rstats::Func::Vector::is_integer (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::INTEGER;
}

bool Rstats::Func::Vector::is_numeric (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::DOUBLE || Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::INTEGER;
}

bool Rstats::Func::Vector::is_logical (Rstats::Vector* v1) {
  return Rstats::Func::Vector::get_type(v1) == Rstats::VectorType::LOGICAL;
}

std::vector<SV*>* Rstats::Func::Vector::get_character_values(Rstats::Vector* v1) {
  return (std::vector<SV*>*)v1->values;
}

std::vector<std::complex<NV> >* Rstats::Func::Vector::get_complex_values(Rstats::Vector* v1) {
  return (std::vector<std::complex<NV> >*)v1->values;
}

std::vector<NV>* Rstats::Func::Vector::get_double_values(Rstats::Vector* v1) {
  return (std::vector<NV>*)v1->values;
}

std::vector<IV>* Rstats::Func::Vector::get_integer_values(Rstats::Vector* v1) {
  return (std::vector<IV>*)v1->values;
}

Rstats::VectorType::Enum Rstats::Func::Vector::get_type(Rstats::Vector* v1) {
  return v1->type;
}

void Rstats::Func::Vector::add_na_position(Rstats::Vector* v1, IV position) {
  (*v1->na_positions)[position] = 1;
}

bool Rstats::Func::Vector::exists_na_position(Rstats::Vector* v1, IV position) {
  return v1->na_positions->count(position);
}

void Rstats::Func::Vector::merge_na_positions(Rstats::Vector* v2, Rstats::Vector* v1) {
  for(std::map<IV, IV>::iterator it = v1->na_positions->begin(); it != v1->na_positions->end(); ++it) {
    Rstats::Func::Vector::add_na_position(v2, it->first);
  }
}

std::map<IV, IV>* Rstats::Func::Vector::get_na_positions(Rstats::Vector* v1) {
  return v1->na_positions;
}

IV Rstats::Func::Vector::get_length (Rstats::Vector* v1) {
  if (v1->values == NULL) {
    return 0;
  }
  
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      return Rstats::Func::Vector::get_character_values(v1)->size();
      break;
    case Rstats::VectorType::COMPLEX :
      return Rstats::Func::Vector::get_complex_values(v1)->size();
      break;
    case Rstats::VectorType::DOUBLE :
      return Rstats::Func::Vector::get_double_values(v1)->size();
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      return Rstats::Func::Vector::get_integer_values(v1)->size();
      break;
  }
}

Rstats::Vector* Rstats::Func::Vector::new_vector() {
  Rstats::Vector* v1 = new Rstats::Vector;
  v1->na_positions = new std::map<IV, IV>;
  
  return v1;
}

void Rstats::Func::Vector::delete_vector (Rstats::Vector* v1) {
  IV length = Rstats::Func::Vector::get_length(v1);
  
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER : {
      std::vector<SV*>* values = Rstats::Func::Vector::get_character_values(v1);
      for (IV i = 0; i < length; i++) {
        if ((*values)[i] != NULL) {
          SvREFCNT_dec((*values)[i]);
        }
      }
      delete values;
      break;
    }
    case Rstats::VectorType::COMPLEX : {
      std::vector<std::complex<NV> >* values = Rstats::Func::Vector::get_complex_values(v1);
      delete values;
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      std::vector<NV>* values = Rstats::Func::Vector::get_double_values(v1);
      delete values;
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      std::vector<IV>* values = Rstats::Func::Vector::get_integer_values(v1);
      delete values;
    }
  }
  delete v1->na_positions;
}

Rstats::Vector* Rstats::Func::Vector::new_character(IV length) {

  Rstats::Vector* v1 = new_vector();
  v1->values = new std::vector<SV*>(length);
  v1->type = Rstats::VectorType::CHARACTER;
  
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_character(IV length, SV* sv_str) {

  Rstats::Vector* v1 = Rstats::Func::Vector::new_character(length);
  for (IV i = 0; i < length; i++) {
    Rstats::Func::Vector::set_character_value(v1, i, sv_str);
  }
  
  return v1;
}

SV* Rstats::Func::Vector::get_character_value(Rstats::Vector* v1, IV pos) {
  SV* value = (*Rstats::Func::Vector::get_character_values(v1))[pos];
  if (value == NULL) {
    return NULL;
  }
  else {
    return Rstats::pl_new_sv_sv(value);
  }
}

void Rstats::Func::Vector::set_character_value(Rstats::Vector* v1, IV pos, SV* value) {
  if (value != NULL) {
    SvREFCNT_dec((*Rstats::Func::Vector::get_character_values(v1))[pos]);
  }
  
  SV* new_value = Rstats::pl_new_sv_sv(value);
  (*Rstats::Func::Vector::get_character_values(v1))[pos] = SvREFCNT_inc(new_value);
}

Rstats::Vector* Rstats::Func::Vector::new_complex(IV length) {
  
  Rstats::Vector* v1 = new_vector();
  v1->values = new std::vector<std::complex<NV> >(length, std::complex<NV>(0, 0));
  v1->type = Rstats::VectorType::COMPLEX;
  
  return v1;
}
    
Rstats::Vector* Rstats::Func::Vector::new_complex(IV length, std::complex<NV> z) {
  
  Rstats::Vector* v1 = new_complex(length);
  for (IV i = 0; i < length; i++) {
    Rstats::Func::Vector::set_complex_value(v1, i, z);
  }
  return v1;
}

std::complex<NV> Rstats::Func::Vector::get_complex_value(Rstats::Vector* v1, IV pos) {
  return (*Rstats::Func::Vector::get_complex_values(v1))[pos];
}

void Rstats::Func::Vector::set_complex_value(Rstats::Vector* v1, IV pos, std::complex<NV> value) {
  (*Rstats::Func::Vector::get_complex_values(v1))[pos] = value;
}

Rstats::Vector* Rstats::Func::Vector::new_double(IV length) {
  Rstats::Vector* v1 = new_vector();
  v1->values = new std::vector<NV>(length);
  v1->type = Rstats::VectorType::DOUBLE;
  
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_double(IV length, NV value) {
  Rstats::Vector* v1 = new_double(length);
  for (IV i = 0; i < length; i++) {
    Rstats::Func::Vector::set_double_value(v1, i, value);
  }
  return v1;
}

NV Rstats::Func::Vector::get_double_value(Rstats::Vector* v1, IV pos) {
  return (*Rstats::Func::Vector::get_double_values(v1))[pos];
}

void Rstats::Func::Vector::set_double_value(Rstats::Vector* v1, IV pos, NV value) {
  (*Rstats::Func::Vector::get_double_values(v1))[pos] = value;
}

Rstats::Vector* Rstats::Func::Vector::new_integer(IV length) {
  
  Rstats::Vector* v1 = new_vector();
  v1->values = new std::vector<IV>(length);
  v1->type = Rstats::VectorType::INTEGER;
  
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_integer(IV length, IV value) {
  
  Rstats::Vector* v1 = new_integer(length);;
  for (IV i = 0; i < length; i++) {
    Rstats::Func::Vector::set_integer_value(v1, i, value);
  }
  return v1;
}

IV Rstats::Func::Vector::get_integer_value(Rstats::Vector* v1, IV pos) {
  return (*Rstats::Func::Vector::get_integer_values(v1))[pos];
}

void Rstats::Func::Vector::set_integer_value(Rstats::Vector* v1, IV pos, IV value) {
  (*Rstats::Func::Vector::get_integer_values(v1))[pos] = value;
}

Rstats::Vector* Rstats::Func::Vector::new_logical(IV length) {
  Rstats::Vector* v1 = new_vector();

  v1->values = new std::vector<IV>(length);
  v1->type = Rstats::VectorType::LOGICAL;
  
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_logical(IV length, IV value) {
  Rstats::Vector* v1 = new_logical(length);
  for (IV i = 0; i < length; i++) {
    Rstats::Func::Vector::set_integer_value(v1, i, value);
  }
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_true() {
  return new_logical(1, 1);
}

Rstats::Vector* Rstats::Func::Vector::new_false() {
  return new_logical(1, 0);
}

Rstats::Vector* Rstats::Func::Vector::new_nan() {
  return  Rstats::Func::Vector::new_double(1, NAN);
}

Rstats::Vector* Rstats::Func::Vector::new_negative_inf() {
  return Rstats::Func::Vector::new_double(1, -(INFINITY));
}

Rstats::Vector* Rstats::Func::Vector::new_inf() {
  return Rstats::Func::Vector::new_double(1, INFINITY);
}

Rstats::Vector* Rstats::Func::Vector::new_na() {
  Rstats::Vector* v1 = new_logical(1);
  Rstats::Func::Vector::add_na_position(v1, 0);
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::new_null() {
  Rstats::Vector* v1 = new_vector();
  v1->values = NULL;
  v1->type = Rstats::VectorType::LOGICAL;
  return v1;
}

Rstats::Vector* Rstats::Func::Vector::as (Rstats::Vector* v1, SV* sv_type) {
  Rstats::Vector* v2;
  if (SvOK(sv_type)) {
    char* type = SvPV_nolen(sv_type);
    if (strEQ(type, "character")) {
      v2 = Rstats::Func::Vector::as_character(v1);
    }
    else if (strEQ(type, "complex")) {
      v2 = Rstats::Func::Vector::as_complex(v1);
    }
    else if (strEQ(type, "double")) {
      v2 = Rstats::Func::Vector::as_double(v1);
    }
    else if (strEQ(type, "numeric")) {
      v2 = Rstats::Func::Vector::as_numeric(v1);
    }
    else if (strEQ(type, "integer")) {
      v2 = Rstats::Func::Vector::as_integer(v1);
    }
    else if (strEQ(type, "logical")) {
      v2 = Rstats::Func::Vector::as_logical(v1);
    }
    else {
      croak("Invalid mode is passed(Rstats::Func::Vector::as())");
    }
  }
  else {
    croak("Invalid mode is passed(Rstats::Func::Vector::as())");
  }
  
  return v2;
}

SV* Rstats::Func::Vector::to_string_pos(Rstats::Vector* v1, IV pos) {
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  SV* sv_str;
  if (Rstats::Func::Vector::exists_na_position(v1, pos)) {
    sv_str = Rstats::pl_new_sv_pv("NA");
  }
  else {
    switch (type) {
      case Rstats::VectorType::CHARACTER :
        sv_str = Rstats::Func::Vector::get_character_value(v1, pos);
        break;
      case Rstats::VectorType::COMPLEX : {
        std::complex<NV> z = Rstats::Func::Vector::get_complex_value(v1, pos);
        NV re = z.real();
        NV im = z.imag();
        
        sv_str = Rstats::pl_new_sv_pv("");
       if (std::isinf(re) && re > 0) {
          sv_catpv(sv_str, "Inf");
        }
        else if (std::isinf(re) && re < 0) {
          sv_catpv(sv_str, "-Inf");
        }
        else if (std::isnan(re)) {
          sv_catpv(sv_str, "NaN");
        }
        else {
          sv_catpv(sv_str, SvPV_nolen(Rstats::pl_new_sv_nv(re)));
        }

        if (std::isinf(im) && im > 0) {
          sv_catpv(sv_str, "+Inf");
        }
        else if (std::isinf(im) && im < 0) {
          sv_catpv(sv_str, "-Inf");
        }
        else if (std::isnan(im)) {
          sv_catpv(sv_str, "+NaN");
        }
        else {
          if (im >= 0) {
            sv_catpv(sv_str, "+");
          }
          sv_catpv(sv_str, SvPV_nolen(Rstats::pl_new_sv_nv(im)));
        }
        
        sv_catpv(sv_str, "i");
        break;
      }
      case Rstats::VectorType::DOUBLE : {
        NV value = Rstats::Func::Vector::get_double_value(v1, pos);
        if (std::isinf(value) && value > 0) {
          sv_str = Rstats::pl_new_sv_pv("Inf");
        }
        else if (std::isinf(value) && value < 0) {
          sv_str = Rstats::pl_new_sv_pv("-Inf");
        }
        else if (std::isnan(value)) {
          sv_str = Rstats::pl_new_sv_pv("NaN");
        }
        else {
          sv_str = Rstats::pl_new_sv_nv(value);
          sv_catpv(sv_str, "");
        }
        break;
      }
      case Rstats::VectorType::INTEGER :
        sv_str = Rstats::pl_new_sv_iv(Rstats::Func::Vector::get_integer_value(v1, pos));
        sv_catpv(sv_str, "");
        break;
      case Rstats::VectorType::LOGICAL :
        sv_str = Rstats::Func::Vector::get_integer_value(v1, pos)
          ? Rstats::pl_new_sv_pv("TRUE") : Rstats::pl_new_sv_pv("FALSE");
        break;
      default:
        croak("Invalid type");
    }
  }
  
  return sv_str;
}

SV* Rstats::Func::Vector::to_string(Rstats::Vector* v1) {
  
  SV* sv_strs = Rstats::pl_new_av_ref();
  for (IV i = 0; i < Rstats::Func::Vector::get_length(v1); i++) {
    SV* sv_str = Rstats::Func::Vector::to_string_pos(v1, i);
    Rstats::pl_av_push(sv_strs, sv_str);
  }

  SV* sv_str_all = Rstats::pl_new_sv_pv("");
  IV sv_strs_length = Rstats::pl_av_len(sv_strs);
  for (IV i = 0; i < sv_strs_length; i++) {
    SV* sv_str = Rstats::pl_av_fetch(sv_strs, i);
    sv_catpv(sv_str_all, SvPV_nolen(sv_str));
    if (i != sv_strs_length - 1) {
      sv_catpv(sv_str_all, ",");
    }
  }
  
  return sv_str_all;
}

Rstats::Vector* Rstats::Func::Vector::as_character (Rstats::Vector* v1) {
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2 = new_character(length);
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::Func::Vector::get_character_value(v1, i);
        Rstats::Func::Vector::set_character_value(v2, i, sv_value);
      }
      break;
    case Rstats::VectorType::COMPLEX :
      for (IV i = 0; i < length; i++) {
        std::complex<NV> z = Rstats::Func::Vector::get_complex_value(v1, i);
        NV re = z.real();
        NV im = z.imag();
        
        SV* sv_re = Rstats::pl_new_sv_nv(re);
        SV* sv_im = Rstats::pl_new_sv_nv(im);
        SV* sv_str = Rstats::pl_new_sv_pv("");
        
        sv_catpv(sv_str, SvPV_nolen(sv_re));
        if (im >= 0) {
          sv_catpv(sv_str, "+");
        }
        sv_catpv(sv_str, SvPV_nolen(sv_im));
        sv_catpv(sv_str, "i");

        Rstats::Func::Vector::set_character_value(v2, i, sv_str);
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = Rstats::Func::Vector::get_double_value(v1, i);
        SV* sv_str = Rstats::pl_new_sv_pv("");
        if (std::isinf(value) && value > 0) {
          sv_catpv(sv_str, "Inf");
        }
        else if (std::isinf(value) && value < 0) {
          sv_catpv(sv_str, "-Inf");
        }
        else if (std::isnan(value)) {
          sv_catpv(sv_str, "NaN");
        }
        else {
          sv_catpv(sv_str, SvPV_nolen(Rstats::pl_new_sv_nv(value)));
        }
        Rstats::Func::Vector::set_character_value(v2, i, sv_str);
      }
      break;
    case Rstats::VectorType::INTEGER :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_character_value(
          v2, 
          i,
          Rstats::pl_new_sv_iv(Rstats::Func::Vector::get_integer_value(v1, i))
        );
      }
      break;
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        if (Rstats::Func::Vector::get_integer_value(v1, i)) {
          Rstats::Func::Vector::set_character_value(v2, i, Rstats::pl_new_sv_pv("TRUE"));
        }
        else {
          Rstats::Func::Vector::set_character_value(v2, i, Rstats::pl_new_sv_pv("FALSE"));
        }
      }
      break;
    default:
      croak("unexpected type");
  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::as_double(Rstats::Vector* v1) {

  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2 = new_double(length);
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::Func::Vector::get_character_value(v1, i);
        SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
        if (SvOK(sv_value_fix)) {
          NV value = SvNV(sv_value_fix);
          Rstats::Func::Vector::set_double_value(v2, i, value);
        }
        else {
          warn("NAs introduced by coercion");
          Rstats::Func::Vector::add_na_position(v2, i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_double_value(v2, i, Rstats::Func::Vector::get_complex_value(v1, i).real());
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_double_value(v2, i, Rstats::Func::Vector::get_double_value(v1, i));
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_double_value(v2, i, Rstats::Func::Vector::get_integer_value(v1, i));
      }
      break;
    default:
      croak("unexpected type");
  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::as_numeric(Rstats::Vector* v1) {
  return Rstats::Func::Vector::as_double(v1);
}

Rstats::Vector* Rstats::Func::Vector::as_integer(Rstats::Vector* v1) {

  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2 = new_integer(length);
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::Func::Vector::get_character_value(v1, i);
        SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
        if (SvOK(sv_value_fix)) {
          IV value = SvIV(sv_value_fix);
          Rstats::Func::Vector::set_integer_value(v2, i, value);
        }
        else {
          warn("NAs introduced by coercion");
          Rstats::Func::Vector::add_na_position(v2, i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, (IV)Rstats::Func::Vector::get_complex_value(v1, i).real());
      }
      break;
    case Rstats::VectorType::DOUBLE :
      NV value;
      for (IV i = 0; i < length; i++) {
        value = Rstats::Func::Vector::get_double_value(v1, i);
        if (std::isnan(value) || std::isinf(value)) {
          Rstats::Func::Vector::add_na_position(v2, i);
        }
        else {
          Rstats::Func::Vector::set_integer_value(v2, i, (IV)value);
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, Rstats::Func::Vector::get_integer_value(v1, i));
      }
      break;
    default:
      croak("unexpected type");
  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::as_complex(Rstats::Vector* v1) {

  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2 = new_complex(length);
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::Func::Vector::get_character_value(v1, i);
        SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
        
        if (SvOK(sv_z)) {
          SV* sv_re = Rstats::pl_hv_fetch(sv_z, "re");
          SV* sv_im = Rstats::pl_hv_fetch(sv_z, "im");
          NV re = SvNV(sv_re);
          NV im = SvNV(sv_im);
          Rstats::Func::Vector::set_complex_value(v2, i, std::complex<NV>(re, im));
        }
        else {
          warn("NAs introduced by coercion");
          Rstats::Func::Vector::add_na_position(v2, i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_complex_value(v2, i, Rstats::Func::Vector::get_complex_value(v1, i));
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = Rstats::Func::Vector::get_double_value(v1, i);
        if (std::isnan(value)) {
          Rstats::Func::Vector::add_na_position(v2, i);
        }
        else {
          Rstats::Func::Vector::set_complex_value(v2, i, std::complex<NV>(Rstats::Func::Vector::get_double_value(v1, i), 0));
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_complex_value(v2, i, std::complex<NV>(Rstats::Func::Vector::get_integer_value(v1, i), 0));
      }
      break;
    default:
      croak("unexpected type");
  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::as_logical(Rstats::Vector* v1) {
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2 = new_logical(length);
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::Func::Vector::get_character_value(v1, i);
        SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
        if (SvOK(sv_logical)) {
          if (SvTRUE(sv_logical)) {
            Rstats::Func::Vector::set_integer_value(v2, i, 1);
          }
          else {
            Rstats::Func::Vector::set_integer_value(v2, i, 0);
          }
        }
        else {
          warn("NAs introduced by coercion");
          Rstats::Func::Vector::add_na_position(v2, i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, Rstats::Func::Vector::get_complex_value(v1, i).real() ? 1 : 0);
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = Rstats::Func::Vector::get_double_value(v1, i);
        if (std::isnan(value)) {
          Rstats::Func::Vector::add_na_position(v2, i);
        }
        else if (std::isinf(value)) {
          Rstats::Func::Vector::set_integer_value(v2, i, 1);
        }
        else {
          Rstats::Func::Vector::set_integer_value(v2, i, value ? 1 : 0);
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, Rstats::Func::Vector::get_integer_value(v1, i) ? 1 : 0);
      }
      break;
    default:
      croak("unexpected type");
  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

SV* Rstats::Func::Vector::get_value(Rstats::Vector* v1, IV pos) {

  SV* sv_value;
  
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      if (Rstats::Func::Vector::exists_na_position(v1, pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        sv_value = Rstats::Func::Vector::get_character_value(v1, pos);
      }
      break;
    case Rstats::VectorType::COMPLEX :
      if (Rstats::Func::Vector::exists_na_position(v1, pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        std::complex<NV> z = Rstats::Func::Vector::get_complex_value(v1, pos);
        
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
      if (Rstats::Func::Vector::exists_na_position(v1, pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        NV value = Rstats::Func::Vector::get_double_value(v1, pos);
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
      if (Rstats::Func::Vector::exists_na_position(v1, pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        IV value = Rstats::Func::Vector::get_integer_value(v1, pos);
        sv_value = Rstats::pl_new_sv_iv(value);
      }
      break;
    default:
      sv_value = &PL_sv_undef;
  }
  
  return sv_value;
}

Rstats::Vector* Rstats::Func::Vector::cumprod(Rstats::Vector* v1) {
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2;
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in cumprod() : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      v2 = Rstats::Func::Vector::new_complex(length);
      std::complex<NV> v2_total(1, 0);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_complex_value(v1, i);
        Rstats::Func::Vector::set_complex_value(v2, i, v2_total);
      }
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      v2 = Rstats::Func::Vector::new_double(length);
      NV v2_total(1);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_double_value(v1, i);
        Rstats::Func::Vector::set_double_value(v2, i, v2_total);
      }
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      v2 = Rstats::Func::Vector::new_integer(length);
      IV v2_total(1);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_integer_value(v1, i);
        Rstats::Func::Vector::set_integer_value(v2, i, v2_total);
      }
      break;
    }
    default:
      croak("Invalid type");

  }

  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::cumsum(Rstats::Vector* v1) {
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2;
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in cumsum() : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      v2 = Rstats::Func::Vector::new_complex(length);
      std::complex<NV> v2_total(0, 0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_complex_value(v1, i);
        Rstats::Func::Vector::set_complex_value(v2, i, v2_total);
      }
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      v2 = Rstats::Func::Vector::new_double(length);
      NV v2_total(0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_double_value(v1, i);
        Rstats::Func::Vector::set_double_value(v2, i, v2_total);
      }
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      v2 = Rstats::Func::Vector::new_integer(length);
      IV v2_total(0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_integer_value(v1, i);
        Rstats::Func::Vector::set_integer_value(v2, i, v2_total);
      }
      break;
    }
    default:
      croak("Invalid type");

    Rstats::Func::Vector::merge_na_positions(v2, v1);
  }
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::prod(Rstats::Vector* v1) {
  
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2;
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in prod() : non-numeric argument to prod()");
      break;
    case Rstats::VectorType::COMPLEX : {
      v2 = Rstats::Func::Vector::new_complex(1);
      std::complex<NV> v2_total(1, 0);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_complex_value(v1, i);
      }
      Rstats::Func::Vector::set_complex_value(v2, 0, v2_total);
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      v2 = Rstats::Func::Vector::new_double(1);
      NV v2_total(1);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_double_value(v1, i);
      }
      Rstats::Func::Vector::set_double_value(v2, 0, v2_total);
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      v2 = Rstats::Func::Vector::new_integer(1);
      IV v2_total(1);
      for (IV i = 0; i < length; i++) {
        v2_total *= Rstats::Func::Vector::get_integer_value(v1, i);
      }
      Rstats::Func::Vector::set_integer_value(v2, 0, v2_total);
      break;
    }
    default:
      croak("Invalid type");

  }

  for (IV i = 0; i < length; i++) {
    if (Rstats::Func::Vector::exists_na_position(v1, i)) {
      Rstats::Func::Vector::add_na_position(v2, 0);
      break;
    }
  }
        
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::sum(Rstats::Vector* v1) {
  
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2;
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      croak("Error in a - b : non-numeric argument to binary operator");
      break;
    case Rstats::VectorType::COMPLEX : {
      v2 = Rstats::Func::Vector::new_complex(1);
      std::complex<NV> v2_total(0, 0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_complex_value(v1, i);
      }
      Rstats::Func::Vector::set_complex_value(v2, 0, v2_total);
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      v2 = Rstats::Func::Vector::new_double(1);
      NV v2_total(0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_double_value(v1, i);
      }
      Rstats::Func::Vector::set_double_value(v2, 0, v2_total);
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      v2 = Rstats::Func::Vector::new_integer(1);
      IV v2_total(0);
      for (IV i = 0; i < length; i++) {
        v2_total += Rstats::Func::Vector::get_integer_value(v1, i);
      }
      Rstats::Func::Vector::set_integer_value(v2, 0, v2_total);
      break;
    }
    default:
      croak("Invalid type");

  }
  
  for (IV i = 0; i < length; i++) {
    if (Rstats::Func::Vector::exists_na_position(v1, i)) {
      Rstats::Func::Vector::add_na_position(v2, 0);
      break;
    }
  }
  
  return v2;
}

Rstats::Vector* Rstats::Func::Vector::clone(Rstats::Vector* v1) {
  
  IV length = Rstats::Func::Vector::get_length(v1);
  Rstats::Vector* v2;
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v1);
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      v2 = Rstats::Func::Vector::new_character(length);
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_character_value(v2, i, Rstats::Func::Vector::get_character_value(v1, i));
      }
      break;
    case Rstats::VectorType::COMPLEX :
      v2 = Rstats::Func::Vector::new_complex(length);
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_complex_value(v2, i, Rstats::Func::Vector::get_complex_value(v1, i));
      }
      break;
    case Rstats::VectorType::DOUBLE :
      v2 = Rstats::Func::Vector::new_double(length);
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_double_value(v2, i, Rstats::Func::Vector::get_double_value(v1, i));
      }
      break;
    case Rstats::VectorType::INTEGER :
      v2 = Rstats::Func::Vector::new_integer(length);
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, Rstats::Func::Vector::get_integer_value(v1, i));
      }
      break;
    case Rstats::VectorType::LOGICAL :
      v2 = Rstats::Func::Vector::new_logical(length);
      for (IV i = 0; i < length; i++) {
        Rstats::Func::Vector::set_integer_value(v2, i, Rstats::Func::Vector::get_integer_value(v1, i));
      }
      break;
    default:
      croak("Invalid type");

  }
  
  Rstats::Func::Vector::merge_na_positions(v2, v1);
  
  return v2;
}