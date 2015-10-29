#ifndef PERL_RSTATS_VECTOR_H
#define PERL_RSTATS_VECTOR_H

#include "Rstats_ElementFunc.h"

namespace Rstats {
  class Vector {
    private:
    
    Rstats::Type::Enum type;
    Rstats::NaPosition* na_positions;
    void* values;
    Rstats::Integer length;
    
    public:

    Rstats::Integer get_length();
    void init_na_positions();
    void add_na_position(Rstats::Integer);
    Rstats::Logical exists_na_position(Rstats::Integer position);
    void merge_na_positions(Rstats::NaPosition*);
    Rstats::NaPosition* get_na_positions();
    Rstats::Integer get_na_positions_length();
    
    ~Vector();

    template<class T> // Specialized
    static Rstats::Vector* new_vector(Rstats::Integer);
    template <class T>
    static Rstats::Vector* new_vector(Rstats::Integer length, T value);
    
    template<class T>
    T* get_values();
    template<class T> // Rstats::Character is specialized
    void set_value(Rstats::Integer pos, T value); 
    template <class T>
    T get_value(Rstats::Integer pos);
    
    template <class T> // Rstats::Character is specialized
    void delete_vector();
  };
  template <>
  void Vector::set_value<Rstats::Character>(Rstats::Integer pos, Rstats::Character value);
  template <>
  void Vector::delete_vector<Rstats::Character>();

  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Double>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Integer>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Complex>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Character>(Rstats::Integer);
  template<>
  Rstats::Vector* Vector::new_vector<Rstats::Logical>(Rstats::Integer);

}
#include "Rstats_Vector_impl.h"

#endif
