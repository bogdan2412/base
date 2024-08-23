//Provides: Base_clear_caml_backtrace_pos const
function Base_clear_caml_backtrace_pos(x) {
  return 0;
}

//Provides: Base_caml_exn_is_most_recent_exn const
function Base_caml_exn_is_most_recent_exn(x) {
  return 1;
}

//Provides: Base_int_math_int_pow_stub const
function Base_int_math_int_pow_stub(base, exponent) {
  var one = 1;
  var mul = [one, base, one, one];
  var res = one;
  while (!exponent == 0) {
    mul[1] = (mul[1] * mul[3]) | 0;
    mul[2] = (mul[1] * mul[1]) | 0;
    mul[3] = (mul[2] * mul[1]) | 0;
    res = (res * mul[exponent & 3]) | 0;
    exponent = exponent >> 2;
  }
  return res;
}

//Provides: Base_int_math_int64_pow_stub const
//Requires: caml_int64_mul, caml_int64_is_zero, caml_int64_shift_right_unsigned
//Requires: caml_int64_create_lo_hi, caml_int64_lo32
function Base_int_math_int64_pow_stub(base, exponent) {
  var one = caml_int64_create_lo_hi(1, 0);
  var mul = [one, base, one, one];
  var res = one;
  while (!caml_int64_is_zero(exponent)) {
    mul[1] = caml_int64_mul(mul[1], mul[3]);
    mul[2] = caml_int64_mul(mul[1], mul[1]);
    mul[3] = caml_int64_mul(mul[2], mul[1]);
    res = caml_int64_mul(res, mul[caml_int64_lo32(exponent) & 3]);
    exponent = caml_int64_shift_right_unsigned(exponent, 2);
  }
  return res;
}

//Provides: Base_hash_string mutable
//Requires: caml_hash_exn
function Base_hash_string(s) {
  return caml_hash_exn(1, 1, 0, s)
}
//Provides: Base_hash_double const
//Requires: caml_hash_exn
function Base_hash_double(d) {
  return caml_hash_exn(1, 1, 0, d);
}

//Provides: Base_am_testing const
//Weakdef
function Base_am_testing(x) {
  return 0;
}

//Provides: Base_unsafe_create_local_bytes
//Requires: caml_create_bytes
function Base_unsafe_create_local_bytes(v_len) {
  // This does a redundant bounds check and (since this is
  // javascript) doesn't allocate locally, but that's fine.
  return caml_create_bytes(v_len);
}

//Provides: caml_make_local_vect
//Requires: caml_make_vect
function caml_make_local_vect(v_len, v_elt) {
  // In javascript there's no local allocation.
  return caml_make_vect(v_len, v_elt);
}

//Provides: caml_dummy_obj_is_stack
function caml_dummy_obj_is_stack(x) {
  throw new Error(`BUG: this function should be unreachable; please report to compiler or base devs.`);
}

//Provides: caml_obj_is_stack
function caml_obj_is_stack(x) {
  throw new Error(`BUG: this function should be unreachable; please report to compiler or base devs.`);
}

//Provides: Base_caml_modf_positive_float_unboxed_exn
//Requires: caml_invalid_argument
function Base_caml_modf_positive_float_unboxed_exn(a, b) {
  if (b < 0) {
    caml_invalid_argument(`${a} % ${b} in float.ml: modulus should be positive`)
  }
  let m = a % b;
  return m < 0 ? m + b : m;
}

//Provides: Base_caml_modf_positive_float_exn
//Requires: Base_caml_modf_positive_float_unboxed_exn
function Base_caml_modf_positive_float_exn(a, b) {
  return Base_caml_modf_positive_float_unboxed_exn(a, b);
}
