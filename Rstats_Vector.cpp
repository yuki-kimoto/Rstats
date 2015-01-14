#include "Rstats.h"

Rstats::Vector::~Vector () {
  IV length = this->get_length();
  
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER : {
      std::vector<SV*>* values = this->get_character_values();
      for (IV i = 0; i < length; i++) {
        if ((*values)[i] != NULL) {
          SvREFCNT_dec((*values)[i]);
        }
      }
      delete values;
      break;
    }
    case Rstats::VectorType::COMPLEX : {
      std::vector<std::complex<NV> >* values = this->get_complex_values();
      delete values;
      break;
    }
    case Rstats::VectorType::DOUBLE : {
      std::vector<NV>* values = this->get_double_values();
      delete values;
      break;
    }
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL : {
      std::vector<IV>* values = this->get_integer_values();
      delete values;
    }
  }
}

SV* Rstats::Vector::get_value(IV pos) {

  SV* sv_value;
  
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      if (this->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        sv_value = this->get_character_value(pos);
      }
      break;
    case Rstats::VectorType::COMPLEX :
      if (this->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        std::complex<NV> z = this->get_complex_value(pos);
        
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
      if (this->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        NV value = this->get_double_value(pos);
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
      if (this->exists_na_position(pos)) {
        sv_value = &PL_sv_undef;
      }
      else {
        IV value = this->get_integer_value(pos);
        sv_value = Rstats::pl_new_sv_iv(value);
      }
      break;
    default:
      sv_value = &PL_sv_undef;
  }
  
  return sv_value;
}

SV* Rstats::Vector::get_values() {
  
  IV length = this->get_length();
  SV* sv_values = Rstats::pl_new_av_ref();
  for (IV i = 0; i < length; i++) {
    Rstats::pl_av_push(sv_values, this->get_value(i));
  }
  
  return sv_values;
}

bool Rstats::Vector::is_character () {
  return this->get_type() == Rstats::VectorType::CHARACTER;
}

bool Rstats::Vector::is_complex () {
  return this->get_type() == Rstats::VectorType::COMPLEX;
}

bool Rstats::Vector::is_double () {
  return this->get_type() == Rstats::VectorType::DOUBLE;
}

bool Rstats::Vector::is_integer () {
  return this->get_type() == Rstats::VectorType::INTEGER;
}

bool Rstats::Vector::is_numeric () {
  return this->get_type() == Rstats::VectorType::DOUBLE || this->get_type() == Rstats::VectorType::INTEGER;
}

bool Rstats::Vector::is_logical () {
  return this->get_type() == Rstats::VectorType::LOGICAL;
}

std::vector<SV*>* Rstats::Vector::get_character_values() {
  return (std::vector<SV*>*)this->values;
}

std::vector<std::complex<NV> >* Rstats::Vector::get_complex_values() {
  return (std::vector<std::complex<NV> >*)this->values;
}

std::vector<NV>* Rstats::Vector::get_double_values() {
  return (std::vector<NV>*)this->values;
}

std::vector<IV>* Rstats::Vector::get_integer_values() {
  return (std::vector<IV>*)this->values;
}

Rstats::VectorType::Enum Rstats::Vector::get_type() {
  return this->type;
}

void Rstats::Vector::add_na_position(IV position) {
  this->na_positions[position] = 1;
}

bool Rstats::Vector::exists_na_position(IV position) {
  return this->na_positions.count(position);
}

void Rstats::Vector::merge_na_positions(Rstats::Vector* elements) {
  for(std::map<IV, IV>::iterator it = elements->na_positions.begin(); it != elements->na_positions.end(); ++it) {
    this->add_na_position(it->first);
  }
}

std::map<IV, IV> Rstats::Vector::get_na_positions() {
  return this->na_positions;
}

IV Rstats::Vector::get_length () {
  if (this->values == NULL) {
    return 0;
  }
  
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      return this->get_character_values()->size();
      break;
    case Rstats::VectorType::COMPLEX :
      return this->get_complex_values()->size();
      break;
    case Rstats::VectorType::DOUBLE :
      return this->get_double_values()->size();
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      return this->get_integer_values()->size();
      break;
  }
}

Rstats::Vector* Rstats::Vector::new_character(IV length, SV* sv_str) {

  Rstats::Vector* elements = Rstats::Vector::new_character(length);
  for (IV i = 0; i < length; i++) {
    elements->set_character_value(i, sv_str);
  }
  elements->type = Rstats::VectorType::CHARACTER;
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_character(IV length) {

  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<SV*>(length);
  elements->type = Rstats::VectorType::CHARACTER;
  
  return elements;
}

SV* Rstats::Vector::get_character_value(IV pos) {
  SV* value = (*this->get_character_values())[pos];
  if (value == NULL) {
    return NULL;
  }
  else {
    return Rstats::pl_new_sv_sv(value);
  }
}

void Rstats::Vector::set_character_value(IV pos, SV* value) {
  if (value != NULL) {
    SvREFCNT_dec((*this->get_character_values())[pos]);
  }
  
  SV* new_value = Rstats::pl_new_sv_sv(value);
  (*this->get_character_values())[pos] = SvREFCNT_inc(new_value);
}

Rstats::Vector* Rstats::Vector::new_complex(IV length) {
  
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<std::complex<NV> >(length, std::complex<NV>(0, 0));
  elements->type = Rstats::VectorType::COMPLEX;
  
  return elements;
}
    
Rstats::Vector* Rstats::Vector::new_complex(IV length, std::complex<NV> z) {
  
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<std::complex<NV> >(length, z);
  elements->type = Rstats::VectorType::COMPLEX;
  
  return elements;
}

std::complex<NV> Rstats::Vector::get_complex_value(IV pos) {
  return (*this->get_complex_values())[pos];
}

void Rstats::Vector::set_complex_value(IV pos, std::complex<NV> value) {
  (*this->get_complex_values())[pos] = value;
}

Rstats::Vector* Rstats::Vector::new_double(IV length) {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<NV>(length);
  elements->type = Rstats::VectorType::DOUBLE;
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_double(IV length, NV value) {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<NV>(length, value);
  elements->type = Rstats::VectorType::DOUBLE;
  
  return elements;
}

NV Rstats::Vector::get_double_value(IV pos) {
  return (*this->get_double_values())[pos];
}

void Rstats::Vector::set_double_value(IV pos, NV value) {
  (*this->get_double_values())[pos] = value;
}

Rstats::Vector* Rstats::Vector::new_integer(IV length) {
  
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<IV>(length);
  elements->type = Rstats::VectorType::INTEGER;
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_integer(IV length, IV value) {
  
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<IV>(length, value);
  elements->type = Rstats::VectorType::INTEGER;
  
  return elements;
}

IV Rstats::Vector::get_integer_value(IV pos) {
  return (*this->get_integer_values())[pos];
}

void Rstats::Vector::set_integer_value(IV pos, IV value) {
  (*this->get_integer_values())[pos] = value;
}

Rstats::Vector* Rstats::Vector::new_logical(IV length) {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<IV>(length);
  elements->type = Rstats::VectorType::LOGICAL;
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_logical(IV length, IV value) {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<IV>(length, value);
  elements->type = Rstats::VectorType::LOGICAL;
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_true() {
  return new_logical(1, 1);
}

Rstats::Vector* Rstats::Vector::new_false() {
  return new_logical(1, 0);
}

Rstats::Vector* Rstats::Vector::new_nan() {
  return  Rstats::Vector::new_double(1, NAN);
}

Rstats::Vector* Rstats::Vector::new_negative_inf() {
  return Rstats::Vector::new_double(1, -(INFINITY));
}

Rstats::Vector* Rstats::Vector::new_inf() {
  return Rstats::Vector::new_double(1, INFINITY);
}

Rstats::Vector* Rstats::Vector::new_na() {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = new std::vector<IV>(1, 0);
  elements->type = Rstats::VectorType::LOGICAL;
  elements->add_na_position(0);
  
  return elements;
}

Rstats::Vector* Rstats::Vector::new_null() {
  Rstats::Vector* elements = new Rstats::Vector;
  elements->values = NULL;
  elements->type = Rstats::VectorType::LOGICAL;
  return elements;
}

Rstats::Vector* Rstats::Vector::as (SV* sv_type) {
  Rstats::Vector* e2;
  if (SvOK(sv_type)) {
    char* type = SvPV_nolen(sv_type);
    if (strEQ(type, "character")) {
      e2 = this->as_character();
    }
    else if (strEQ(type, "complex")) {
      e2 = this->as_complex();
    }
    else if (strEQ(type, "double")) {
      e2 = this->as_double();
    }
    else if (strEQ(type, "numeric")) {
      e2 = this->as_numeric();
    }
    else if (strEQ(type, "integer")) {
      e2 = this->as_integer();
    }
    else if (strEQ(type, "logical")) {
      e2 = this->as_logical();
    }
    else {
      croak("Invalid mode is passed(Rstats::Vector::as())");
    }
  }
  else {
    croak("Invalid mode is passed(Rstats::Vector::as())");
  }
  
  return e2;
}

SV* Rstats::Vector::to_string_pos(IV pos) {
  Rstats::VectorType::Enum type = this->get_type();
  SV* sv_str;
  if (this->exists_na_position(pos)) {
    sv_str = Rstats::pl_new_sv_pv("NA");
  }
  else {
    switch (type) {
      case Rstats::VectorType::CHARACTER :
        sv_str = this->get_character_value(pos);
        break;
      case Rstats::VectorType::COMPLEX : {
        std::complex<NV> z = this->get_complex_value(pos);
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
        NV value = this->get_double_value(pos);
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
        sv_str = Rstats::pl_new_sv_iv(this->get_integer_value(pos));
        sv_catpv(sv_str, "");
        break;
      case Rstats::VectorType::LOGICAL :
        sv_str = this->get_integer_value(pos)
          ? Rstats::pl_new_sv_pv("TRUE") : Rstats::pl_new_sv_pv("FALSE");
        break;
      default:
        croak("Invalid type");
    }
  }
  
  return sv_str;
}

SV* Rstats::Vector::to_string() {
  
  SV* sv_strs = Rstats::pl_new_av_ref();
  for (IV i = 0; i < this->get_length(); i++) {
    SV* sv_str = this->to_string_pos(i);
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

Rstats::Vector* Rstats::Vector::as_character () {
  IV length = this->get_length();
  Rstats::Vector* e2 = new_character(length);
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = this->get_character_value(i);
        e2->set_character_value(i, sv_value);
      }
      break;
    case Rstats::VectorType::COMPLEX :
      for (IV i = 0; i < length; i++) {
        std::complex<NV> z = this->get_complex_value(i);
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

        e2->set_character_value(i, sv_str);
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = this->get_double_value(i);
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
        e2->set_character_value(i, sv_str);
      }
      break;
    case Rstats::VectorType::INTEGER :
      for (IV i = 0; i < length; i++) {
        e2->set_character_value(
          i,
          Rstats::pl_new_sv_iv(this->get_integer_value(i))
        );
      }
      break;
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        if (this->get_integer_value(i)) {
          e2->set_character_value(i, Rstats::pl_new_sv_pv("TRUE"));
        }
        else {
          e2->set_character_value(i, Rstats::pl_new_sv_pv("FALSE"));
        }
      }
      break;
    default:
      croak("unexpected type");
  }

  e2->merge_na_positions(this);
  
  return e2;
}

Rstats::Vector* Rstats::Vector::as_double() {

  IV length = this->get_length();
  Rstats::Vector* e2 = new_double(length);
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = this->get_character_value(i);
        SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
        if (SvOK(sv_value_fix)) {
          NV value = SvNV(sv_value_fix);
          e2->set_double_value(i, value);
        }
        else {
          warn("NAs introduced by coercion");
          e2->add_na_position(i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        e2->set_double_value(i, this->get_complex_value(i).real());
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        e2->set_double_value(i, this->get_double_value(i));
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        e2->set_double_value(i, this->get_integer_value(i));
      }
      break;
    default:
      croak("unexpected type");
  }

  e2->merge_na_positions(this);
  
  return e2;
}

Rstats::Vector* Rstats::Vector::as_numeric() {
  return this->as_double();
}

Rstats::Vector* Rstats::Vector::as_integer() {

  IV length = this->get_length();
  Rstats::Vector* e2 = new_integer(length);
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = this->get_character_value(i);
        SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
        if (SvOK(sv_value_fix)) {
          IV value = SvIV(sv_value_fix);
          e2->set_integer_value(i, value);
        }
        else {
          warn("NAs introduced by coercion");
          e2->add_na_position(i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
      }
      break;
    case Rstats::VectorType::DOUBLE :
      NV value;
      for (IV i = 0; i < length; i++) {
        value = this->get_double_value(i);
        if (std::isnan(value) || std::isinf(value)) {
          e2->add_na_position(i);
        }
        else {
          e2->set_integer_value(i, (IV)value);
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, this->get_integer_value(i));
      }
      break;
    default:
      croak("unexpected type");
  }

  e2->merge_na_positions(this);
  
  return e2;
}

Rstats::Vector* Rstats::Vector::as_complex() {

  IV length = this->get_length();
  Rstats::Vector* e2 = new_complex(length);
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = this->get_character_value(i);
        SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
        
        if (SvOK(sv_z)) {
          SV* sv_re = Rstats::pl_hv_fetch(sv_z, "re");
          SV* sv_im = Rstats::pl_hv_fetch(sv_z, "im");
          NV re = SvNV(sv_re);
          NV im = SvNV(sv_im);
          e2->set_complex_value(i, std::complex<NV>(re, im));
        }
        else {
          warn("NAs introduced by coercion");
          e2->add_na_position(i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      for (IV i = 0; i < length; i++) {
        e2->set_complex_value(i, this->get_complex_value(i));
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = this->get_double_value(i);
        if (std::isnan(value)) {
          e2->add_na_position(i);
        }
        else {
          e2->set_complex_value(i, std::complex<NV>(this->get_double_value(i), 0));
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        e2->set_complex_value(i, std::complex<NV>(this->get_integer_value(i), 0));
      }
      break;
    default:
      croak("unexpected type");
  }

  e2->merge_na_positions(this);
  
  return e2;
}

Rstats::Vector* Rstats::Vector::as_logical() {
  IV length = this->get_length();
  Rstats::Vector* e2 = new_logical(length);
  Rstats::VectorType::Enum type = this->get_type();
  switch (type) {
    case Rstats::VectorType::CHARACTER :
      for (IV i = 0; i < length; i++) {
        SV* sv_value = this->get_character_value(i);
        SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
        if (SvOK(sv_logical)) {
          if (SvTRUE(sv_logical)) {
            e2->set_integer_value(i, 1);
          }
          else {
            e2->set_integer_value(i, 0);
          }
        }
        else {
          warn("NAs introduced by coercion");
          e2->add_na_position(i);
        }
      }
      break;
    case Rstats::VectorType::COMPLEX :
      warn("imaginary parts discarded in coercion");
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, this->get_complex_value(i).real() ? 1 : 0);
      }
      break;
    case Rstats::VectorType::DOUBLE :
      for (IV i = 0; i < length; i++) {
        NV value = this->get_double_value(i);
        if (std::isnan(value)) {
          e2->add_na_position(i);
        }
        else if (std::isinf(value)) {
          e2->set_integer_value(i, 1);
        }
        else {
          e2->set_integer_value(i, value ? 1 : 0);
        }
      }
      break;
    case Rstats::VectorType::INTEGER :
    case Rstats::VectorType::LOGICAL :
      for (IV i = 0; i < length; i++) {
        e2->set_integer_value(i, this->get_integer_value(i) ? 1 : 0);
      }
      break;
    default:
      croak("unexpected type");
  }

  e2->merge_na_positions(this);
  
  return e2;
}
