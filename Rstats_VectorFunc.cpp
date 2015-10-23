#include "Rstats.h"

extern Rstats::Integer Rstats::WARN;

// Rstats::VectorFunc
namespace Rstats {
  namespace VectorFunc {

    template <>
    Rstats::Vector* as_double<Rstats::Character, Rstats::Double>(Rstats::Vector* v1) {
      Rstats::Double (*func)(Rstats::Character) = &Rstats::ElementFunc::as_double;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }

    template <>
    Rstats::Vector* as_complex<Rstats::Character, Rstats::Complex>(Rstats::Vector* v1) {
      Rstats::Complex (*func)(Rstats::Character) = &Rstats::ElementFunc::as_complex;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
    
    template <>
    Rstats::Vector* as_integer<Rstats::Character, Rstats::Integer>(Rstats::Vector* v1) {
      Rstats::Integer (*func)(Rstats::Character) = &Rstats::ElementFunc::as_integer;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
    template <>
    Rstats::Vector* as_integer<Rstats::Complex, Rstats::Integer>(Rstats::Vector* v1) {
      Rstats::Integer (*func)(Rstats::Complex) = &Rstats::ElementFunc::as_integer;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
    template <>
    Rstats::Vector* as_integer<Rstats::Double, Rstats::Integer>(Rstats::Vector* v1) {
      Rstats::Integer (*func)(Rstats::Double) = &Rstats::ElementFunc::as_integer;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }

    template <>
    Rstats::Vector* as_logical<Rstats::Character, Rstats::Logical>(Rstats::Vector* v1) {
      Rstats::Logical (*func)(Rstats::Character) = &Rstats::ElementFunc::as_logical;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
    template <>
    Rstats::Vector* as_logical<Rstats::Complex, Rstats::Logical>(Rstats::Vector* v1) {
      Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::as_logical;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
    template <>
    Rstats::Vector* as_logical<Rstats::Double, Rstats::Logical>(Rstats::Vector* v1) {
      Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::as_logical;
      
      Rstats::Vector* v_out = Rstats::VectorFunc::operate_unary_as(func, v1, 1);
      
      return v_out;
    }
        
    template <>
    Rstats::Vector* new_vector<Rstats::Double>(Rstats::Integer length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Double>(length);
      v1->type = Rstats::Type::DOUBLE;
      
      return v1;
    };

    template <>
    Rstats::Vector* new_vector<Rstats::Integer>(Rstats::Integer length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Integer>(length);
      v1->type = Rstats::Type::INTEGER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Complex>(Rstats::Integer length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Complex>(length);
      v1->type = Rstats::Type::COMPLEX;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Character>(Rstats::Integer length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Character>(length, &PL_sv_undef);
      v1->type = Rstats::Type::CHARACTER;
      
      return v1;
    }

    template <>
    Rstats::Vector* new_vector<Rstats::Logical>(Rstats::Integer length) {
      Rstats::Vector* v1 = new Rstats::Vector;
      v1->na_positions = new std::map<Rstats::Integer, Rstats::Integer>;
      v1->values = new std::vector<Rstats::Logical>(length);
      v1->type = Rstats::Type::LOGICAL;
      
      return v1;
    }
  }
}
