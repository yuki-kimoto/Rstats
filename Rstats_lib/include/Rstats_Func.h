#ifndef PERL_RSTATS_FUNC_H
#define PERL_RSTATS_FUNC_H

#include <vector>
#include "Rstats_Vector.h"
#include "Rstats_VectorFunc.h"

namespace Rstats {
  namespace Func {

    SV* to_object(SV*, SV*);

    SV* new_NA(SV*); /* $r->NA */
    SV* new_NaN(SV*); /* $r->NaN */
    SV* new_Inf(SV*); /* $r->Inf */
    SV* new_FALSE(SV*); /* $r->FALSE */
    SV* new_TRUE(SV*); /* $r->TRUE */

    SV* c(SV*, SV*);
    SV* c_double(SV*, SV*);
    SV* c_int(SV*, SV*);

    SV* pi(SV*);
    SV* is_vector(SV*, SV*);
    SV* values(SV*, SV*);
    SV* type(SV*, SV*);
    int32_t to_bool(SV*, SV*);
    SV* is_double(SV*, SV*);
    SV* is_int(SV*, SV*);
    SV* is_finite(SV*, SV*);
    SV* is_infinite(SV*, SV*);
    SV* is_nan(SV*, SV*);

    SV* copy_attrs_to(SV*, SV*, SV*);
    SV* copy_attrs_to(SV*, SV*, SV*, SV*);

    SV* as_vector(SV*, SV*);
    SV* as_int(SV*, SV*);
    SV* as_double(SV*, SV*);

    SV* clone(SV*, SV*);
    SV* dim_as_array(SV*, SV*);
    SV* decompose(SV*, SV*);
    SV* compose(SV*, SV*, SV*);
    SV* array(SV*, SV*);
    SV* array(SV*, SV*, SV*);
    SV* array_with_opt(SV*, SV*);
    SV* args_h(SV*, SV*, SV*);
    SV* as_array(SV*, SV*);
    
    int32_t get_length(SV*, SV*);
    
    // dim
    SV* dim(SV*, SV*, SV*);
    SV* dim(SV*, SV*);
    
    SV* length(SV*, SV*);
    
    SV* tanh(SV*, SV*);
    SV* Mod(SV*, SV*);
    SV* Arg(SV*, SV*);
    SV* abs(SV*, SV*);
    SV* acos(SV*, SV*);
    SV* acosh(SV*, SV*);
    SV* asin(SV*, SV*);
    SV* asinh(SV*, SV*);
    SV* atan(SV*, SV*);
    SV* atanh(SV*, SV*);
    SV* cos(SV*, SV*);
    SV* cosh(SV*, SV*);
    SV* cumsum(SV*, SV*);
    SV* cumprod(SV*, SV*);
    SV* exp(SV*, SV*);
    SV* expm1(SV*, SV*);
    SV* log(SV*, SV*);
    SV* logb(SV*, SV*);
    SV* log2(SV*, SV*);
    SV* log10(SV*, SV*);
    SV* prod(SV*, SV*);
    SV* sin(SV*, SV*);
    SV* sinh(SV*, SV*);
    SV* sqrt(SV*, SV*);
    SV* tan(SV*, SV*);
    SV* sin(SV*, SV*);
    SV* sum(SV*, SV*);
    SV* neg(SV*, SV*);
    
    char* get_type(SV*, SV*);
    SV* get_type_sv(SV*, SV*);

    SV* add(SV*, SV*, SV*);
    SV* subtract(SV*, SV*, SV*);
    SV* multiply(SV*, SV*, SV*);
    SV* divide(SV*, SV*, SV*);
    SV* remainder(SV*, SV*, SV*);
    SV* pow(SV*, SV*, SV*);
    SV* atan2(SV*, SV*, SV*);
    
    SV* less_than(SV*, SV*, SV*);
    SV* less_than_or_equal(SV*, SV*, SV*);
    SV* more_than(SV*, SV*, SV*);
    SV* more_than_or_equal(SV*, SV*, SV*);
    SV* equal(SV*, SV*, SV*);
    SV* not_equal(SV*, SV*, SV*);
    SV* And(SV*, SV*, SV*);
    SV* Or(SV*, SV*, SV*);

    SV* create_sv_value(SV*, SV*, int32_t);
    SV* create_sv_values(SV*, SV*);
    
    template <class T>
    void set_vector(SV*, SV*, Rstats::Vector<T>*);
    template <>
    void set_vector<double>(SV*, SV*, Rstats::Vector<double>*);
    template <>
    void set_vector<int32_t>(SV*, SV*, Rstats::Vector<int32_t>*);
    
    template <class T>
    Rstats::Vector<T>* get_vector(SV*, SV*);
    template <>
    Rstats::Vector<double>* get_vector<double>(SV*, SV*);
    template <>
    Rstats::Vector<int32_t>* get_vector<int32_t>(SV*, SV*);

    template <class T>
    SV* new_vector(SV*);
    template <> 
    SV* new_vector<double>(SV*);
    template <>
    SV* new_vector<int32_t>(SV*);
    
    template <class T>
    SV* new_vector(SV*, Rstats::Vector<T>* v1);
  }
}
#include "Rstats_Func_impl.h"

#endif
