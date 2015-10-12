#include "Rstats.h"

// Rstats::VectorFunc
namespace Rstats {
  namespace VectorFunc {
   
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH(remainder, Rstats::ElementFunc::remainder)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(divide, Rstats::ElementFunc::divide)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(atan2, Rstats::ElementFunc::atan2)
    RSTATS_DEF_VECTOR_FUNC_BIN_MATH_INTEGER_TO_DOUBLE(pow, Rstats::ElementFunc::pow)

    template <>
    Rstats::Character get_value<Rstats::Character>(Rstats::Vector* v1, Rstats::Integer pos) {
      Rstats::Character value = (*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos];
      if (value == NULL) {
        return NULL;
      }
      else {
        return Rstats::pl_new_sv_sv(value);
      }
    }
    
    SV* create_sv_values(Rstats::Vector* v1) {
      
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      SV* sv_values = Rstats::pl_new_avrv();
      for (Rstats::Integer i = 0; i < length; i++) {
        Rstats::pl_av_push(sv_values, Rstats::VectorFunc::create_sv_value(v1, i));
      }
      
      return sv_values;
    }

    bool is_character (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::CHARACTER;
    }

    bool is_complex (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::COMPLEX;
    }

    bool is_double (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::DOUBLE;
    }

    bool is_integer (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::INTEGER;
    }

    bool is_numeric (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::DOUBLE || Rstats::VectorFunc::get_type(v1) == Rstats::Type::INTEGER;
    }

    bool is_logical (Rstats::Vector* v1) {
      return Rstats::VectorFunc::get_type(v1) == Rstats::Type::LOGICAL;
    }

    Rstats::Type::Enum get_type(Rstats::Vector* v1) {
      return v1->type;
    }

    void add_na_position(Rstats::Vector* v1, Rstats::Integer position) {
      (*v1->na_positions)[position] = 1;
    }

    bool exists_na_position(Rstats::Vector* v1, Rstats::Integer position) {
      return v1->na_positions->count(position);
    }

    void merge_na_positions(Rstats::Vector* v2, Rstats::Vector* v1) {
      for(std::map<Rstats::Integer, Rstats::Integer>::iterator it = v1->na_positions->begin(); it != v1->na_positions->end(); ++it) {
        Rstats::VectorFunc::add_na_position(v2, it->first);
      }
    }

    std::map<Rstats::Integer, Rstats::Integer>* get_na_positions(Rstats::Vector* v1) {
      return v1->na_positions;
    }

    Rstats::Integer get_length (Rstats::Vector* v1) {
      if (v1->values == NULL) {
        return 0;
      }
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          return Rstats::VectorFunc::get_values<Rstats::Character>(v1)->size();
          break;
        case Rstats::Type::COMPLEX :
          return Rstats::VectorFunc::get_values<Rstats::Complex>(v1)->size();
          break;
        case Rstats::Type::DOUBLE :
          return Rstats::VectorFunc::get_values<Rstats::Double>(v1)->size();
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          return Rstats::VectorFunc::get_values<Rstats::Integer>(v1)->size();
          break;
      }
    }

    Rstats::Vector* new_empty_vector() {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      
      return v1;
    }

    void delete_vector (Rstats::Vector* v1) {
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      
      if (v1->values != NULL){ 
        switch (type) {
          case Rstats::Type::CHARACTER : {
            std::vector<Rstats::Character>* values = Rstats::VectorFunc::get_values<Rstats::Character>(v1);
            for (Rstats::Integer i = 0; i < length; i++) {
              if ((*values)[i] != NULL) {
                SvREFCNT_dec((*values)[i]);
              }
            }
            delete values;
            break;
          }
          case Rstats::Type::COMPLEX : {
            std::vector<Rstats::Complex >* values = Rstats::VectorFunc::get_values<Rstats::Complex>(v1);
            delete values;
            break;
          }
          case Rstats::Type::DOUBLE : {
            std::vector<Rstats::Double>* values = Rstats::VectorFunc::get_values<Rstats::Double>(v1);
            delete values;
            break;
          }
          case Rstats::Type::INTEGER :
          case Rstats::Type::LOGICAL : {
            std::vector<Rstats::Integer>* values = Rstats::VectorFunc::get_values<Rstats::Integer>(v1);
            delete values;
          }
        }
      }
      
      delete v1->na_positions;
    }

    template <>
    void set_value<Rstats::Character>(Rstats::Vector* v1, Rstats::Integer pos, Rstats::Character value) {
      if (value != NULL) {
        SvREFCNT_dec((*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos]);
      }
      
      SV* new_value = Rstats::pl_new_sv_sv(value);
      (*Rstats::VectorFunc::get_values<Rstats::Character>(v1))[pos] = SvREFCNT_inc(new_value);
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Double>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Double>(length);
      v1->type = Rstats::Type::DOUBLE;
      
      return v1;
    };

    template <>
    Rstats::Vector* new_vector<Rstats::Integer>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Integer>(length);
      v1->type = Rstats::Type::INTEGER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Complex>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Complex>(length);
      v1->type = Rstats::Type::COMPLEX;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Character>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Character>(length);
      v1->type = Rstats::Type::CHARACTER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Logical>(Rstats::Integer length) {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = new std::vector<Rstats::Logical>(length);
      v1->type = Rstats::Type::LOGICAL;
      
      return v1;
    }
        
    Rstats::Vector* new_true() {
      return new_vector<Rstats::Logical>(1, 1);
    }

    Rstats::Vector* new_false() {
      return new_vector<Rstats::Logical>(1, 0);
    }

    Rstats::Vector* new_nan() {
      return  Rstats::VectorFunc::new_vector<Rstats::Double>(1, NAN);
    }

    Rstats::Vector* new_negative_inf() {
      return Rstats::VectorFunc::new_vector<Rstats::Double>(1, -(INFINITY));
    }

    Rstats::Vector* new_inf() {
      return Rstats::VectorFunc::new_vector<Rstats::Double>(1, INFINITY);
    }

    Rstats::Vector* new_na() {
      Rstats::Vector* v1 = new_vector<Rstats::Logical>(1);
      Rstats::VectorFunc::add_na_position(v1, 0);
      return v1;
    }

    Rstats::Vector* new_null() {
      Rstats::Vector* v1 = new_empty_vector();
      v1->values = NULL;
      v1->type = Rstats::Type::LOGICAL;
      return v1;
    }

    Rstats::Vector* as (Rstats::Vector* v1, SV* sv_type) {
      Rstats::Vector* v2;
      if (SvOK(sv_type)) {
        char* type = SvPV_nolen(sv_type);
        if (strEQ(type, "character")) {
          v2 = Rstats::VectorFunc::as_character(v1);
        }
        else if (strEQ(type, "complex")) {
          v2 = Rstats::VectorFunc::as_complex(v1);
        }
        else if (strEQ(type, "double")) {
          v2 = Rstats::VectorFunc::as_double(v1);
        }
        else if (strEQ(type, "numeric")) {
          v2 = Rstats::VectorFunc::as_numeric(v1);
        }
        else if (strEQ(type, "integer")) {
          v2 = Rstats::VectorFunc::as_integer(v1);
        }
        else if (strEQ(type, "logical")) {
          v2 = Rstats::VectorFunc::as_logical(v1);
        }
        else {
          croak("Invalid mode is passed(Rstats::VectorFunc::as())");
        }
      }
      else {
        croak("Invalid mode is passed(Rstats::VectorFunc::as())");
      }
      
      return v2;
    }

    SV* to_string_pos(Rstats::Vector* v1, Rstats::Integer pos) {
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      SV* sv_str;
      if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
        sv_str = Rstats::pl_new_sv_pv("NA");
      }
      else {
        switch (type) {
          case Rstats::Type::CHARACTER :
            sv_str = Rstats::VectorFunc::get_value<Rstats::Character>(v1, pos);
            break;
          case Rstats::Type::COMPLEX : {
            Rstats::Complex z = Rstats::VectorFunc::get_value<Rstats::Complex>(v1, pos);
            Rstats::Double re = z.real();
            Rstats::Double im = z.imag();
            
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
          case Rstats::Type::DOUBLE : {
            Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, pos);
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
          case Rstats::Type::INTEGER :
            sv_str = Rstats::pl_new_sv_iv(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, pos));
            sv_catpv(sv_str, "");
            break;
          case Rstats::Type::LOGICAL :
            sv_str = Rstats::VectorFunc::get_value<Rstats::Integer>(v1, pos)
              ? Rstats::pl_new_sv_pv("TRUE") : Rstats::pl_new_sv_pv("FALSE");
            break;
          default:
            croak("Invalid type");
        }
      }
      
      return sv_str;
    }

    SV* to_string(Rstats::Vector* v1) {
      
      SV* sv_strs = Rstats::pl_new_avrv();
      for (Rstats::Integer i = 0; i < Rstats::VectorFunc::get_length(v1); i++) {
        SV* sv_str = Rstats::VectorFunc::to_string_pos(v1, i);
        Rstats::pl_av_push(sv_strs, sv_str);
      }

      SV* sv_str_all = Rstats::pl_new_sv_pv("");
      Rstats::Integer sv_strs_length = Rstats::pl_av_len(sv_strs);
      for (Rstats::Integer i = 0; i < sv_strs_length; i++) {
        SV* sv_str = Rstats::pl_av_fetch(sv_strs, i);
        sv_catpv(sv_str_all, SvPV_nolen(sv_str));
        if (i != sv_strs_length - 1) {
          sv_catpv(sv_str_all, ",");
        }
      }
      
      return sv_str_all;
    }

    Rstats::Vector* as_character (Rstats::Vector* v1) {
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2 = new_vector<Rstats::Character>(length);
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_value);
          }
          break;
        case Rstats::Type::COMPLEX :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Complex z = Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
            Rstats::Double re = z.real();
            Rstats::Double im = z.imag();
            
            SV* sv_re = Rstats::pl_new_sv_nv(re);
            SV* sv_im = Rstats::pl_new_sv_nv(im);
            SV* sv_str = Rstats::pl_new_sv_pv("");
            
            sv_catpv(sv_str, SvPV_nolen(sv_re));
            if (im >= 0) {
              sv_catpv(sv_str, "+");
            }
            sv_catpv(sv_str, SvPV_nolen(sv_im));
            sv_catpv(sv_str, "i");

            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_str);
          }
          break;
        case Rstats::Type::DOUBLE :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
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
            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_str);
          }
          break;
        case Rstats::Type::INTEGER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Character>(
              v2, 
              i,
              Rstats::pl_new_sv_iv(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))
            );
          }
          break;
        case Rstats::Type::LOGICAL :
          for (Rstats::Integer i = 0; i < length; i++) {
            if (Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i)) {
              Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::pl_new_sv_pv("TRUE"));
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::pl_new_sv_pv("FALSE"));
            }
          }
          break;
        default:
          croak("unexpected type");
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    Rstats::Vector* as_double(Rstats::Vector* v1) {

      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2 = new_vector<Rstats::Double>(length);
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
            SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
            if (SvOK(sv_value_fix)) {
              Rstats::Double value = SvNV(sv_value_fix);
              Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, value);
            }
            else {
              warn("NAs introduced by coercion");
              Rstats::VectorFunc::add_na_position(v2, i);
            }
          }
          break;
        case Rstats::Type::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real());
          }
          break;
        case Rstats::Type::DOUBLE :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
          }
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
          }
          break;
        default:
          croak("unexpected type");
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    Rstats::Vector* as_numeric(Rstats::Vector* v1) {
      return Rstats::VectorFunc::as_double(v1);
    }

    Rstats::Vector* as_integer(Rstats::Vector* v1) {

      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2 = new_vector<Rstats::Integer>(length);
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
            SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
            if (SvOK(sv_value_fix)) {
              Rstats::Integer value = SvIV(sv_value_fix);
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, value);
            }
            else {
              warn("NAs introduced by coercion");
              Rstats::VectorFunc::add_na_position(v2, i);
            }
          }
          break;
        case Rstats::Type::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, (Rstats::Integer)Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real());
          }
          break;
        case Rstats::Type::DOUBLE :
          Rstats::Double value;
          for (Rstats::Integer i = 0; i < length; i++) {
            value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
            if (std::isnan(value) || std::isinf(value)) {
              Rstats::VectorFunc::add_na_position(v2, i);
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, (Rstats::Integer)value);
            }
          }
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
          }
          break;
        default:
          croak("unexpected type");
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    Rstats::Vector* as_complex(Rstats::Vector* v1) {

      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2 = new_vector<Rstats::Complex>(length);
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
            SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
            
            if (SvOK(sv_z)) {
              SV* sv_re = Rstats::pl_hv_fetch(sv_z, "re");
              SV* sv_im = Rstats::pl_hv_fetch(sv_z, "im");
              Rstats::Double re = SvNV(sv_re);
              Rstats::Double im = SvNV(sv_im);
              Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(re, im));
            }
            else {
              warn("NAs introduced by coercion");
              Rstats::VectorFunc::add_na_position(v2, i);
            }
          }
          break;
        case Rstats::Type::COMPLEX :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i));
          }
          break;
        case Rstats::Type::DOUBLE :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
            if (std::isnan(value)) {
              Rstats::VectorFunc::add_na_position(v2, i);
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i), 0));
            }
          }
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), 0));
          }
          break;
        default:
          croak("unexpected type");
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    Rstats::Vector* as_logical(Rstats::Vector* v1) {
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2 =new_vector<Rstats::Logical>(length);
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
            SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
            if (SvOK(sv_logical)) {
              if (SvTRUE(sv_logical)) {
                Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 1);
              }
              else {
                Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 0);
              }
            }
            else {
              warn("NAs introduced by coercion");
              Rstats::VectorFunc::add_na_position(v2, i);
            }
          }
          break;
        case Rstats::Type::COMPLEX :
          warn("imaginary parts discarded in coercion");
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real() ? 1 : 0);
          }
          break;
        case Rstats::Type::DOUBLE :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
            if (std::isnan(value)) {
              Rstats::VectorFunc::add_na_position(v2, i);
            }
            else if (std::isinf(value)) {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 1);
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, value ? 1 : 0);
            }
          }
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i) ? 1 : 0);
          }
          break;
        default:
          croak("unexpected type");
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    SV* create_sv_value(Rstats::Vector* v1, Rstats::Integer pos) {

      SV* sv_value;
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, pos);
          }
          break;
        case Rstats::Type::COMPLEX :
          if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            Rstats::Complex z = Rstats::VectorFunc::get_value<Rstats::Complex>(v1, pos);
            
            Rstats::Double re = z.real();
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
            
            Rstats::Double im = z.imag();
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

            sv_value = Rstats::pl_new_hvrv();
            Rstats::pl_hv_store(sv_value, "re", sv_re);
            Rstats::pl_hv_store(sv_value, "im", sv_im);
          }
          break;
        case Rstats::Type::DOUBLE :
          if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, pos);
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
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
            sv_value = &PL_sv_undef;
          }
          else {
            Rstats::Integer value = Rstats::VectorFunc::get_value<Rstats::Integer>(v1, pos);
            sv_value = Rstats::pl_new_sv_iv(value);
          }
          break;
        default:
          sv_value = &PL_sv_undef;
      }
      
      return sv_value;
    }

    Rstats::Vector* cumprod(Rstats::Vector* v1) {
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2;
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          croak("Error in cumprod() : non-numeric argument to binary operator");
          break;
        case Rstats::Type::COMPLEX : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
          Rstats::Complex v2_total(1, 0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, v2_total);
          }
          break;
        }
        case Rstats::Type::DOUBLE : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
          Rstats::Double v2_total(1);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, v2_total);
          }
          break;
        }
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
          Rstats::Integer v2_total(1);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, v2_total);
          }
          break;
        }
        default:
          croak("Invalid type");

      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }

    Rstats::Vector* cumsum(Rstats::Vector* v1) {
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2;
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          croak("Error in cumsum() : non-numeric argument to binary operator");
          break;
        case Rstats::Type::COMPLEX : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
          Rstats::Complex v2_total(0, 0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, v2_total);
          }
          break;
        }
        case Rstats::Type::DOUBLE : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
          Rstats::Double v2_total(0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, v2_total);
          }
          break;
        }
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
          Rstats::Integer v2_total(0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, v2_total);
          }
          break;
        }
        default:
          croak("Invalid type");

        Rstats::VectorFunc::merge_na_positions(v2, v1);
      }
      
      return v2;
    }

    Rstats::Vector* prod(Rstats::Vector* v1) {
      
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2;
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          croak("Error in prod() : non-numeric argument to prod()");
          break;
        case Rstats::Type::COMPLEX : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
          Rstats::Complex v2_total(1, 0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, 0, v2_total);
          break;
        }
        case Rstats::Type::DOUBLE : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
          Rstats::Double v2_total(1);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, 0, v2_total);
          break;
        }
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
          Rstats::Integer v2_total(1);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total *= Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, 0, v2_total);
          break;
        }
        default:
          croak("Invalid type");

      }

      for (Rstats::Integer i = 0; i < length; i++) {
        if (Rstats::VectorFunc::exists_na_position(v1, i)) {
          Rstats::VectorFunc::add_na_position(v2, 0);
          break;
        }
      }
            
      return v2;
    }

    Rstats::Vector* sum(Rstats::Vector* v1) {
      
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2;
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          croak("Error in a - b : non-numeric argument to binary operator");
          break;
        case Rstats::Type::COMPLEX : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
          Rstats::Complex v2_total(0, 0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, 0, v2_total);
          break;
        }
        case Rstats::Type::DOUBLE : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
          Rstats::Double v2_total(0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, 0, v2_total);
          break;
        }
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL : {
          v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
          Rstats::Integer v2_total(0);
          for (Rstats::Integer i = 0; i < length; i++) {
            v2_total += Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
          }
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, 0, v2_total);
          break;
        }
        default:
          croak("Invalid type");

      }
      
      for (Rstats::Integer i = 0; i < length; i++) {
        if (Rstats::VectorFunc::exists_na_position(v1, i)) {
          Rstats::VectorFunc::add_na_position(v2, 0);
          break;
        }
      }
      
      return v2;
    }

    Rstats::Vector* clone(Rstats::Vector* v1) {
      
      Rstats::Integer length = Rstats::VectorFunc::get_length(v1);
      Rstats::Vector* v2;
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::VectorFunc::get_value<Rstats::Character>(v1, i));
          }
          break;
        case Rstats::Type::COMPLEX :
          v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i));
          }
          break;
        case Rstats::Type::DOUBLE :
          v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
          }
          break;
        case Rstats::Type::INTEGER :
          v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
          }
          break;
        case Rstats::Type::LOGICAL :
          v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
          }
          break;
        default:
          croak("Invalid type");

      }
      
      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      return v2;
    }
  }
}
