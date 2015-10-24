#include "Rstats.h"

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
  }
}
