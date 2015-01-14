#ifndef PERL_RSTATS_ELEMENT_FUNC_H
#define PERL_RSTATS_ELEMENT_FUNC_H

// Rstats::ElementFunc header
namespace Rstats {
  namespace ElementFunc {

    std::complex<NV> add(std::complex<NV>, std::complex<NV>);
    NV add(NV, NV);
    IV add(IV, IV);

    std::complex<NV> subtract(std::complex<NV>, std::complex<NV>);
    NV subtract(NV, NV);
    IV subtract(IV, IV);

    std::complex<NV> multiply(std::complex<NV>, std::complex<NV>);
    NV multiply(NV, NV);
    IV multiply(IV, IV);

    std::complex<NV> divide(std::complex<NV>, std::complex<NV>);
    NV divide(NV, NV);
    NV divide(IV, IV);

    std::complex<NV> pow(std::complex<NV>, std::complex<NV>);
    NV pow(NV, NV);
    NV pow(IV, IV);

    std::complex<NV> reminder(std::complex<NV>, std::complex<NV>);
    NV reminder(NV, NV);
    IV reminder(IV, IV);

    NV Re(std::complex<NV>);
    NV Re(NV);
    NV Re(IV);

    NV Im(std::complex<NV>);
    NV Im(NV);
    NV Im(IV);

    std::complex<NV> Conj(std::complex<NV>);
    NV Conj(NV);
    NV Conj(IV);

    std::complex<NV> sin(std::complex<NV>);
    NV sin(NV);
    NV sin(IV);
    
    std::complex<NV> cos(std::complex<NV>);
    NV cos(NV);
    NV cos(IV);

    std::complex<NV> tan(std::complex<NV>);
    NV tan(NV);
    NV tan(IV);

    std::complex<NV> sinh(std::complex<NV>);
    NV sinh(NV);
    NV sinh(IV);

    std::complex<NV> cosh(std::complex<NV>);
    NV cosh(NV);
    NV cosh(IV);

    std::complex<NV> tanh (std::complex<NV> z);
    NV tanh(NV);
    NV tanh(IV);

    NV abs(std::complex<NV>);
    NV abs(NV);
    NV abs(IV);

    NV Mod(std::complex<NV>);
    NV Mod(NV);
    NV Mod(IV);

    std::complex<NV> log(std::complex<NV>);
    NV log(NV);
    NV log(IV);

    std::complex<NV> logb(std::complex<NV>);
    NV logb(NV);
    NV logb(IV);

    std::complex<NV> log10(std::complex<NV>);
    NV log10(NV);
    NV log10(IV);

    std::complex<NV> log2(std::complex<NV>);
    NV log2(NV);
    NV log2(IV);
    
    // expm1 (Can't separate body. I don't know the reason)
    std::complex<NV> expm1(std::complex<NV>);
    NV expm1(NV);
    NV expm1(IV);

    NV Arg(std::complex<NV>);
    NV Arg(NV);
    NV Arg(IV);

    std::complex<NV> exp(std::complex<NV>);
    NV exp(NV);
    NV exp(IV);

    std::complex<NV> sqrt(std::complex<NV>);
    NV sqrt(NV);
    NV sqrt(IV);

    std::complex<NV> atan(std::complex<NV>);
    NV atan(NV);
    NV atan(IV);

    std::complex<NV> asin(std::complex<NV>);
    NV asin(NV);
    NV asin(IV);

    std::complex<NV> acos(std::complex<NV>);
    NV acos(NV);
    NV acos(IV);

    std::complex<NV> asinh(std::complex<NV>);
    NV asinh(NV);
    NV asinh(IV);

    std::complex<NV> acosh(std::complex<NV>);
    NV acosh(NV);
    NV acosh(IV);

    std::complex<NV> atanh(std::complex<NV>);
    NV atanh(NV);
    NV atanh(IV);
    
    std::complex<NV> negation(std::complex<NV>);
    NV negation(NV);
    IV negation(IV);

    std::complex<NV> atan2(std::complex<NV>, std::complex<NV>);
    NV atan2(NV, NV);
    NV atan2(IV, IV);

    IV And(SV*, SV*);
    IV And(std::complex<NV>, std::complex<NV>);
    IV And(NV, NV);
    IV And(IV, IV);

    IV Or(SV*, SV*);
    IV Or(std::complex<NV>, std::complex<NV>);
    IV Or(NV, NV);
    IV Or(IV, IV);
    
    IV equal(SV*, SV*);
    IV equal(std::complex<NV>, std::complex<NV>);
    IV equal(NV, NV);
    IV equal(IV, IV);

    IV not_equal(SV*, SV*);
    IV not_equal(std::complex<NV>, std::complex<NV>);
    IV not_equal(NV, NV);
    IV not_equal(IV, IV);

    IV more_than(SV*, SV*);
    IV more_than(std::complex<NV>, std::complex<NV>);
    IV more_than(NV, NV);
    IV more_than(IV, IV);

    IV less_than(SV*, SV*);
    IV less_than(std::complex<NV>, std::complex<NV>);
    IV less_than(NV, NV);
    IV less_than(IV, IV);

    IV more_than_or_equal(SV*, SV*);
    IV more_than_or_equal(std::complex<NV>, std::complex<NV>);
    IV more_than_or_equal(NV, NV);
    IV more_than_or_equal(IV, IV);

    IV less_than_or_equal(SV*, SV*);
    IV less_than_or_equal(std::complex<NV>, std::complex<NV>);
    IV less_than_or_equal(NV, NV);
    IV less_than_or_equal(IV, IV);

    IV is_infinite(SV*);
    IV is_infinite(std::complex<NV>);
    IV is_infinite(NV);
    IV is_infinite(IV);

    IV is_finite(SV*);
    IV is_finite(std::complex<NV>);
    IV is_finite(NV);
    IV is_finite(IV);

    IV is_nan(SV*);
    IV is_nan(std::complex<NV>);
    IV is_nan(NV);
    IV is_nan(IV);
  }
}

#endif
