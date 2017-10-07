#include "Rstats_Util.h"

// Rstats::Util
namespace Rstats {
  namespace Util {

    static REGEXP* LOGICAL_RE = pregcomp(newSVpv("^ *(T|TRUE|F|FALSE) *$", 0), 0);
    static REGEXP* LOGICAL_TRUE_RE = pregcomp(newSVpv("T", 0), 0);
    static REGEXP* INTEGER_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+) *$", 0), 0);
    static REGEXP* DOUBLE_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+(?:\\.[0-9]+)?) *$", 0), 0);
    static REGEXP* COMPLEX_IMAGE_ONLY_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)i *$", 0), 0);
    static REGEXP* COMPLEX_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)(?:([\\+\\-][0-9]+(?:\\.[0-9]+)?)i)? *$", 0), 0);

    Rstats::Double pi() { return M_PI; }
    Rstats::Double Inf() { return INFINITY; }
    Rstats::Double NaN() { return std::numeric_limits<Rstats::Double>::signaling_NaN(); }
    int32_t is_Inf(Rstats::Double e1) { return std::isinf(e1); }
    int32_t is_NaN(Rstats::Double e1) { return std::isnan(e1); }
    
    int32_t is_perl_number(SV* sv_str) {
      if (!SvOK(sv_str)) {
        return 0;
      }
      
      if ((SvIOKp(sv_str) || SvNOKp(sv_str)) && 0 + sv_cmp(sv_str, sv_str) == 0 && SvIV(sv_str) * 0 == 0) {
        return 1;
      }
      else {
        return 0;
      }
    }

    SV* cross_product(SV* sv_values) {
      
      int32_t values_length = Rstats::pl_av_len(sv_values);
      SV* sv_idxs = Rstats::pl_new_avrv();
      for (int32_t i = 0; i < values_length; i++) {
        Rstats::pl_av_push(sv_idxs, Rstats::pl_new_sv_iv(0)); 
      }
      
      SV* sv_idx_idx = Rstats::pl_new_avrv();
      for (int32_t i = 0; i < values_length; i++) {
        Rstats::pl_av_push(sv_idx_idx, Rstats::pl_new_sv_iv(i));
      }
      
      SV* sv_x1 = Rstats::pl_new_avrv();
      for (int32_t i = 0; i < values_length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        Rstats::pl_av_push(sv_x1, Rstats::pl_av_fetch(sv_value, 0));
      }

      SV* sv_result = Rstats::pl_new_avrv();
      Rstats::pl_av_push(sv_result, Rstats::pl_av_copy(sv_x1));
      int32_t end_loop = 0;
      while (1) {
        for (int32_t i = 0; i < values_length; i++) {
          
          if (SvIV(Rstats::pl_av_fetch(sv_idxs, i)) < Rstats::pl_av_len(Rstats::pl_av_fetch(sv_values, i)) - 1) {
            
            SV* sv_idxs_tmp = Rstats::pl_av_fetch(sv_idxs, i);
            sv_inc(sv_idxs_tmp);
            Rstats::pl_av_store(sv_x1, i, Rstats::pl_av_fetch(Rstats::pl_av_fetch(sv_values, i), SvIV(sv_idxs_tmp)));
            
            Rstats::pl_av_push(sv_result, Rstats::pl_av_copy(sv_x1));
            
            break;
          }
          
          if (i == SvIV(Rstats::pl_av_fetch(sv_idx_idx, values_length - 1))) {
            end_loop = 1;
            break;
          }
          
          Rstats::pl_av_store(sv_idxs, i, Rstats::pl_new_sv_iv(0));
          Rstats::pl_av_store(sv_x1, i, Rstats::pl_av_fetch(Rstats::pl_av_fetch(sv_values, i), 0));
        }
        if (end_loop) {
          break;
        }
      }

      return sv_result;
    }

    SV* pos_to_index(SV* sv_pos, SV* sv_dim) {
      
      SV* sv_index = Rstats::pl_new_avrv();
      int32_t pos = SvIV(sv_pos);
      int32_t before_dim_product = 1;
      for (int32_t i = 0; i < Rstats::pl_av_len(sv_dim); i++) {
        before_dim_product *= SvIV(Rstats::pl_av_fetch(sv_dim, i));
      }
      
      for (int32_t i = Rstats::pl_av_len(sv_dim) - 1; i >= 0; i--) {
        int32_t dim_product = 1;
        for (int32_t k = 0; k < i; k++) {
          dim_product *= SvIV(Rstats::pl_av_fetch(sv_dim, k));
        }
        
        int32_t reminder = pos % before_dim_product;
        int32_t quotient = (int32_t)(reminder / dim_product);
        
        Rstats::pl_av_unshift(sv_index, Rstats::pl_new_sv_iv(quotient + 1));
        before_dim_product = dim_product;
      }
      
      return sv_index;
    }

    SV* index_to_pos(SV* sv_index, SV* sv_dim_values) {
      
      int32_t pos = 0;
      for (int32_t i = 0; i < Rstats::pl_av_len(sv_dim_values); i++) {
        if (i > 0) {
          int32_t tmp = 1;
          for (int32_t k = 0; k < i; k++) {
            tmp *= SvIV(Rstats::pl_av_fetch(sv_dim_values, k));
          }
          pos += tmp * (SvIV(Rstats::pl_av_fetch(sv_index, i)) - 1);
        }
        else {
          pos += SvIV(Rstats::pl_av_fetch(sv_index, i));
        }
      }
      
      SV* sv_pos = Rstats::pl_new_sv_iv(pos - 1);
      
      return sv_pos;
    }

    SV* looks_like_na (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_na = Rstats::pl_new_sv_pv("NA");
        if (sv_cmp(sv_value, sv_na) == 0) {
          sv_ret = Rstats::pl_new_sv_iv(1);
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }

    SV* looks_like_integer(SV* sv_str) {
      
      SV* sv_ret;
      if (!SvOK(sv_str) || sv_len(sv_str) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        int32_t ret = Rstats::pl_pregexec(sv_str, INTEGER_RE);
        if (ret) {
          SV* match1 = Rstats::pl_new_sv_pv("");
          Perl_reg_numbered_buff_fetch(aTHX_ INTEGER_RE, 1, match1);
          sv_ret = Rstats::pl_new_sv_iv(SvIV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }

    SV* looks_like_double (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret =  &PL_sv_undef;
      }
      else {
        int32_t ret = Rstats::pl_pregexec(sv_value, DOUBLE_RE);
        if (ret) {
          SV* match1 = Rstats::pl_new_sv_pv("");
          Perl_reg_numbered_buff_fetch(aTHX_ DOUBLE_RE, 1, match1);
          sv_ret = Rstats::pl_new_sv_nv(SvNV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
  }
}
