#include "Rstats.h"

// Rstats::Util
namespace Rstats {
  namespace Util {

    static REGEXP* LOGICAL_RE = pregcomp(newSVpv("^ *(T|TRUE|F|FALSE) *$", 0), 0);
    static REGEXP* LOGICAL_TRUE_RE = pregcomp(newSVpv("T", 0), 0);
    static REGEXP* INTEGER_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+) *$", 0), 0);
    static REGEXP* DOUBLE_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+(?:\\.[0-9]+)?) *$", 0), 0);
    static REGEXP* COMPLEX_IMAGE_ONLY_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)i *$", 0), 0);
    static REGEXP* COMPLEX_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)(?:([\\+\\-][0-9]+(?:\\.[0-9]+)?)i)? *$", 0), 0);

    NV pi () { return M_PI; }

    Rstats::Logical is_perl_number(SV* sv_str) {
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
      
      IV values_length = Rstats::pl_av_len(sv_values);
      SV* sv_idxs = Rstats::pl_new_avrv();
      for (IV i = 0; i < values_length; i++) {
        Rstats::pl_av_push(sv_idxs, Rstats::pl_new_sv_iv(0)); 
      }
      
      SV* sv_idx_idx = Rstats::pl_new_avrv();
      for (IV i = 0; i < values_length; i++) {
        Rstats::pl_av_push(sv_idx_idx, Rstats::pl_new_sv_iv(i));
      }
      
      SV* sv_x1 = Rstats::pl_new_avrv();
      for (IV i = 0; i < values_length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        Rstats::pl_av_push(sv_x1, Rstats::pl_av_fetch(sv_value, 0));
      }

      SV* sv_result = Rstats::pl_new_avrv();
      Rstats::pl_av_push(sv_result, Rstats::pl_av_copy(sv_x1));
      IV end_loop = 0;
      while (1) {
        for (IV i = 0; i < values_length; i++) {
          
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
      IV pos = SvIV(sv_pos);
      IV before_dim_product = 1;
      for (IV i = 0; i < Rstats::pl_av_len(sv_dim); i++) {
        before_dim_product *= SvIV(Rstats::pl_av_fetch(sv_dim, i));
      }
      
      for (IV i = Rstats::pl_av_len(sv_dim) - 1; i >= 0; i--) {
        IV dim_product = 1;
        for (IV k = 0; k < i; k++) {
          dim_product *= SvIV(Rstats::pl_av_fetch(sv_dim, k));
        }
        
        IV reminder = pos % before_dim_product;
        IV quotient = (IV)(reminder / dim_product);
        
        Rstats::pl_av_unshift(sv_index, Rstats::pl_new_sv_iv(quotient + 1));
        before_dim_product = dim_product;
      }
      
      return sv_index;
    }

    SV* index_to_pos(SV* sv_index, SV* sv_dim_values) {
      
      IV pos = 0;
      for (IV i = 0; i < Rstats::pl_av_len(sv_dim_values); i++) {
        if (i > 0) {
          IV tmp = 1;
          for (IV k = 0; k < i; k++) {
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

    SV* looks_like_complex (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_re;
        SV* sv_im;
        if (Rstats::pl_pregexec(sv_value, COMPLEX_IMAGE_ONLY_RE)) {
          sv_re = Rstats::pl_new_sv_nv(0);
          SV* sv_im_str = Rstats::pl_new_sv_pv("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_IMAGE_ONLY_RE, 1, sv_im_str);
          sv_im = Rstats::pl_new_sv_nv(SvNV(sv_im_str));
          
          sv_ret = Rstats::pl_new_hvrv();
          Rstats::pl_hv_store(sv_ret, "re", sv_re);
          Rstats::pl_hv_store(sv_ret, "im", sv_im);
        }
        else if(Rstats::pl_pregexec(sv_value, COMPLEX_RE)) {
          SV* sv_re_str = Rstats::pl_new_sv_pv("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 1, sv_re_str);
          sv_re = Rstats::pl_new_sv_nv(SvNV(sv_re_str));

          SV* sv_im_str = Rstats::pl_new_sv_pv("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 2, sv_im_str);
          if (SvOK(sv_im_str)) {
            sv_im = Rstats::pl_new_sv_nv(SvNV(sv_im_str));
          }
          else {
            sv_im = Rstats::pl_new_sv_nv(0);
          }

          sv_ret = Rstats::pl_new_hvrv();
          Rstats::pl_hv_store(sv_ret, "re", sv_re);
          Rstats::pl_hv_store(sv_ret, "im", sv_im);
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }

    SV* looks_like_logical (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        if (Rstats::pl_pregexec(sv_value, LOGICAL_RE)) {
          if (Rstats::pl_pregexec(sv_value, LOGICAL_TRUE_RE)) {
            sv_ret = Rstats::pl_new_sv_iv(1);
          }
          else {
            sv_ret = Rstats::pl_new_sv_iv(0);
          }
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      return sv_ret;
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
        IV ret = Rstats::pl_pregexec(sv_str, INTEGER_RE);
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
        IV ret = Rstats::pl_pregexec(sv_value, DOUBLE_RE);
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
