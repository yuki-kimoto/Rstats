#include "Rstats.h"

REGEXP* Rstats::pl_pregcomp (SV* sv_re, IV flag) {
  return (REGEXP*)sv_2mortal((SV*)pregcomp(sv_re, flag));
}

SV* Rstats::pl_new_ref(SV* sv) {
  return sv_2mortal(newRV_inc(sv));
}

SV* Rstats::pl_new_sv_sv(SV* sv) {
  return sv_2mortal(newSVsv(sv));
}

SV* Rstats::pl_new_sv_pv(const char* pv) {
  return sv_2mortal(newSVpvn(pv, strlen(pv)));
}
    
SV* Rstats::pl_new_sv_iv(IV iv) {
  return sv_2mortal(newSViv(iv));
}

SV* Rstats::pl_new_sv_nv(NV nv) {
  return sv_2mortal(newSVnv(nv));
}

AV* Rstats::pl_new_av() {
  return (AV*)sv_2mortal((SV*)newAV());
}

SV* Rstats::pl_new_av_ref() {
  return sv_2mortal(newRV_inc((SV*)pl_new_av()));
}

HV* Rstats::pl_new_hv() {
  return (HV*)sv_2mortal((SV*)newHV());
}

SV* Rstats::pl_new_hv_ref() {
  return sv_2mortal(newRV_inc((SV*)pl_new_hv()));
}

SV* Rstats::pl_deref(SV* ref) {
  if (SvROK(ref)) {
    return SvRV(ref);
  }
  else {
    croak("Can't derefernce");
  }
}

AV* Rstats::pl_av_deref(SV* ref) {
  return (AV*)pl_deref(ref);
}

HV* Rstats::pl_hv_deref(SV* ref) {
  return (HV*)pl_deref(ref);
}

IV Rstats::pl_av_len (AV* av) {
  return av_len(av) + 1;
}

IV Rstats::pl_av_len (SV* av_ref) {
  return av_len((AV*)pl_deref(av_ref)) + 1;
}

SV* Rstats::pl_av_fetch(AV* av, IV pos) {
  SV** const element_ptr = av_fetch(av, pos, FALSE);
  SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
  
  return element;
}

SV* Rstats::pl_av_fetch(SV* av_ref, IV pos) {
  AV* av = (AV*)pl_deref(av_ref);
  return pl_av_fetch(av, pos);
}

bool Rstats::pl_hv_exists(HV* hv_hash, char* key) {
  return hv_exists(hv_hash, key, strlen(key));
}

bool Rstats::pl_hv_exists(SV* sv_hash_ref, char* key) {
  return hv_exists(pl_hv_deref(sv_hash_ref), key, strlen(key));
}

SV* Rstats::pl_hv_delete(HV* hv_hash, char* key) {
  return hv_delete(hv_hash, key, strlen(key), 0);
}

SV* Rstats::pl_hv_delete(SV* sv_hash_ref, char* key) {
  return hv_delete(pl_hv_deref(sv_hash_ref), key, strlen(key), 0);
}

SV* Rstats::pl_hv_fetch(HV* hv, const char* key) {
  SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
  SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
  
  return element;
}

SV* Rstats::pl_hv_fetch(SV* hv_ref, const char* key) {
  HV* hv = pl_hv_deref(hv_ref);
  return pl_hv_fetch(hv, key);
}

void Rstats::pl_av_store(AV* av, IV pos, SV* element) {
  av_store(av, pos, SvREFCNT_inc(element));
}

void Rstats::pl_av_store(SV* av_ref, IV pos, SV* element) {
  AV* av = pl_av_deref(av_ref);
  pl_av_store(av, pos, element);
}

SV* Rstats::pl_av_copy(SV* sv_av_ref) {
  SV* sv_new_av_ref = pl_new_av_ref();
  
  for (IV i = 0; i < pl_av_len(sv_av_ref); i++) {
    pl_av_store(sv_new_av_ref, i, pl_new_sv_sv(pl_av_fetch(sv_av_ref, i)));
  }
  
  return sv_new_av_ref;
}

void Rstats::pl_hv_store(HV* hv, const char* key, SV* element) {
  hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
}

void Rstats::pl_hv_store(SV* hv_ref, const char* key, SV* element) {
  HV* hv = pl_hv_deref(hv_ref);
  return pl_hv_store(hv, key, element);
}

void Rstats::pl_av_push(AV* av, SV* sv) {
  av_push(av, SvREFCNT_inc(sv));
}

void Rstats::pl_av_push(SV* av_ref, SV* sv) {
  return pl_av_push(pl_av_deref(av_ref), sv);
}

SV* Rstats::pl_av_pop(AV* av_array) {
  return av_pop(av_array);
}

SV* Rstats::pl_av_pop(SV* sv_array_ref) {
  return av_pop(pl_av_deref(sv_array_ref));
}

void Rstats::pl_av_unshift(AV* av, SV* sv) {
  av_unshift(av, 1);
  pl_av_store(av, (IV)0, SvREFCNT_inc(sv));
}

void Rstats::pl_av_unshift(SV* av_ref, SV* sv) {
  av_unshift((AV*)pl_deref(av_ref), 1);
  pl_av_store((AV*)pl_deref(av_ref), 0, SvREFCNT_inc(sv));
}

IV Rstats::pl_pregexec(SV* sv_str, REGEXP* sv_re) {
  char* str = SvPV_nolen(sv_str);
  
  IV ret = pregexec(
    sv_re,
    str,
    str + strlen(str),
    str,
    0,
    sv_str,
    1
  );
  
  return ret;
}
