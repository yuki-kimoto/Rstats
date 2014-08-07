#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef PERL_API_INCLUDE
#define PERL_API_INCLUDE

class api {
  public:
  static void print();
  
  inline static I32 to_iv (SV* sv) {
    return SvIV(sv);
  }
  
  inline static U32 to_uv(SV* sv) {
    return SvUV(sv);
  }

  inline static double to_nv(SV* sv) {
    return SvNV(sv);
  }
    
  inline static char* to_pv(SV* sv) {
    return SvPV_nolen(sv);
  }

  inline static SV* sv(int iv) {
    return sv_2mortal(newSViv(iv));
  }
    
  inline static SV* sv(I32 iv) {
    return sv_2mortal(newSViv(iv));
  }

  inline static SV* sv(unsigned int uv) {
    return sv_2mortal(newSVuv(uv));
  }
  
  inline static SV* sv(U32 uv) {
    return sv_2mortal(newSVuv(uv));
  }

  inline static SV* sv(char* pv) {
    return sv_2mortal(newSVpvn(pv, strlen(pv)));
  }
  
  inline static AV* array() {
    return (AV*)sv_2mortal((SV*)newAV());
  }
  
  inline static SV* array_ref() {
    return sv_2mortal(newRV_inc((SV*)api::array()));
  }
  
  inline static HV* hash() {
    return (HV*)sv_2mortal((SV*)newHV());
  }

  inline static SV* hash_ref() {
    return sv_2mortal(newRV_inc((SV*)api::hash()));
  }
  
  inline static SV* get(AV* array, I32 pos) {
    SV** const element_ptr = av_fetch(array, pos, FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }

  inline static SV* get(SV* array_ref, I32 pos) {
    AV* array = (AV*)api::deref(array_ref);
    SV** const element_ptr = av_fetch(array, pos, FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }
  
  inline static SV* get(HV* hash, char* key) {
    SV** const element_ptr = hv_fetch(hash, key, strlen(key), FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }

  inline static SV* get(SV* hash_ref, char* key) {
    HV* hash = (HV*)api::deref(hash_ref);
    SV** const element_ptr = hv_fetch(hash, key, strlen(key), FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }
  
  inline static SV* deref(SV* ref) {
    if (SvROK(ref)) {
      return SvRV(ref);
    }
    else {
      croak("Can't derefernce");
    }
  }

  inline static void set(AV* array, I32 pos, SV* element) {
    av_store(array, pos, SvREFCNT_inc(element));
  }
  
  inline static void set(SV* array_ref, I32 pos, SV* element) {
    AV* array = (AV*)api::deref(array_ref);
    av_store(array, pos, element);
  }
  
  inline static void set(HV* hash, char* key, SV* element) {
    hv_store(hash, key, strlen(key), SvREFCNT_inc(element), FALSE);
  }

  inline static void set(SV* hash_ref, char* key, SV* element) {
    HV* hash = (HV*)api::deref(hash_ref);
    hv_store(hash, key, strlen(key), SvREFCNT_inc(element), FALSE);
  }
};

#endif
