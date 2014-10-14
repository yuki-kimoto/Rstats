#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef PERL_API_INCLUDE
#define PERL_API_INCLUDE

class PerlAPI {
  public:
  
  I32 length (AV* av) {
    return av_len(av) + 1;
  }

  I32 length (SV* av_ref) {
    return av_len(av_deref(av_ref)) + 1;
  }
  
  I32 to_iv (SV* sv) {
    return SvIV(sv);
  }
  
  U32 to_uv(SV* sv) {
    return SvUV(sv);
  }

  double to_nv(SV* sv) {
    return SvNV(sv);
  }
    
  char* to_pv(SV* sv) {
    return SvPV_nolen(sv);
  }
  
  SV* new_sv (SV* sv) {
    return sv_2mortal(newSVsv(sv));
  }
  
  SV* to_sv(I32 iv) {
    return sv_2mortal(newSViv(iv));
  }

  SV* to_sv(U32 uv) {
    return sv_2mortal(newSVuv(uv));
  }

  SV* to_sv(double nv) {
    return sv_2mortal(newSVnv(nv));
  }
  
  SV* to_sv(char* pv) {
    return sv_2mortal(newSVpvn(pv, strlen(pv)));
  }
  
  SV* copy_av(SV* av_ref) {
    SV* new_av_ref = this->new_av_ref();
    
    for (I32 i = 0; i < this->length(av_ref); i++) {
      this->av_set(new_av_ref, i, this->new_sv(this->av_get(av_ref, i)));
    }
    
    return new_av_ref;
  }
  
  AV* new_av() {
    return (AV*)sv_2mortal((SV*)newAV());
  }
  
  SV* new_av_ref() {
    return sv_2mortal(newRV_inc((SV*)new_av()));
  }
  
  HV* new_hv() {
    return (HV*)sv_2mortal((SV*)newHV());
  }

  SV* new_hv_ref() {
    return sv_2mortal(newRV_inc((SV*)new_hv()));
  }
  
  SV* av_get(AV* av, I32 pos) {
    SV** const element_ptr = av_fetch(av, pos, FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }

  SV* av_get(SV* av_ref, I32 pos) {
    AV* av = av_deref(av_ref);
    SV** const element_ptr = av_fetch(av, pos, FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }
  
  SV* hv_get(HV* hv, char* key) {
    SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }

  SV* hv_get(SV* hv_ref, char* key) {
    HV* hv = hv_deref(hv_ref);
    SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
    SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
    
    return element;
  }
  
  SV* sv_deref(SV* ref) {
    if (SvROK(ref)) {
      return SvRV(ref);
    }
    else {
      croak("Can't derefernce");
    }
  }

  AV* av_deref(SV* ref) {
    if (SvROK(ref)) {
      return (AV*)SvRV(ref);
    }
    else {
      croak("Can't derefernce");
    }
  }

  HV* hv_deref(SV* ref) {
    if (SvROK(ref)) {
      return (HV*)SvRV(ref);
    }
    else {
      croak("Can't derefernce");
    }
  }
  
  void av_set(AV* av, I32 pos, SV* element) {
    av_store(av, pos, SvREFCNT_inc(element));
  }
  
  void av_set(SV* av_ref, I32 pos, SV* element) {
    AV* av = av_deref(av_ref);
    av_store(av, pos, SvREFCNT_inc(element));
  }
  
  void hv_set(HV* hv, char* key, SV* element) {
    hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
  }

  void hv_set(SV* hv_ref, char* key, SV* element) {
    HV* hv = hv_deref(hv_ref);
    hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
  }
  
  void push(AV* av, SV* sv) {
    av_push(av, SvREFCNT_inc(sv));
  }
  
  void push(SV* av_ref, SV* sv) {
    av_push(av_deref(av_ref), SvREFCNT_inc(sv));
  }

  void unshift(AV* av, SV* sv) {
    av_unshift(av, 1);
    av_set(av, 0, sv);
  }
  
  void unshift(SV* av_ref, SV* sv) {
    av_unshift(av_deref(av_ref), 1);
    av_set(av_deref(av_ref), 0, sv);
  }
};

#endif
