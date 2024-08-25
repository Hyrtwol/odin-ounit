package ounit

import "base:intrinsics"
import "core:log"
import "core:math"
import "core:reflect"
import "core:testing"

EPSILON :: math.F32_EPSILON
T :: testing.T
expectf :: testing.expectf
expect_value :: testing.expect_value

should_be_v :: "%v (should be: %v)"
should_be_d :: "%d (should be: %d)"
should_be_f :: "%f (should be: %f)"
should_be_b :: "0b%b (should be: 0b%b)"
should_be_b8 :: "0b%8b (should be: 0b%8b)"
should_be_b16 :: "0b%16b (should be: 0b%16b)"
should_be_b32 :: "0b%32b (should be: 0b%32b)"
should_be_x :: "0x%X (should be: 0x%X)"
should_be_x2 :: "0x%2X (should be: 0x%2X)"
should_be_x4 :: "0x%4X (should be: 0x%4X)"
should_be_x8 :: "0x%8X (should be: 0x%8X)"
should_be_x16 :: "0x%16X (should be: 0x%16X)"
should_be_size_of :: "size_of(%v)=" + should_be_d

expect_u8 :: proc(t: ^testing.T, act, exp: u8, loc := #caller_location) {
	expectf(t, act == exp, should_be_x8, act, exp, loc = loc)
}

expect_u32 :: proc(t: ^testing.T, act, exp: u32, loc := #caller_location) {
	expectf(t, act == exp, should_be_x8, act, exp, loc = loc)
}

expect_i32 :: proc(t: ^testing.T, act, exp: i32, loc := #caller_location) {
	expectf(t, act == exp, should_be_x8, act, exp, loc = loc)
}

expect_size :: proc(t: ^testing.T, $act: typeid, exp: int, loc := #caller_location) {
	expectf(t, size_of(act) == exp, should_be_size_of, typeid_of(act), size_of(act), exp, loc = loc)
}

expect_any_int :: proc(t: ^testing.T, #any_int act: u64, #any_int exp: u64, loc := #caller_location) {
	expectf(t, act == exp, should_be_x16, act, exp, loc = loc)
}

expect_int :: proc(t: ^testing.T, act, exp: int, loc := #caller_location) {
	expectf(t, act == exp, should_be_d, act, exp, loc = loc)
}

expect_float :: proc(t: ^testing.T, act, exp, delta: f32, loc := #caller_location) {
	expectf(t, abs(act - exp) <= delta, should_be_f + " %f", act, exp, abs(act - exp), loc = loc)
}

expect_bits :: proc(t: ^testing.T, act, exp: $T, loc := #caller_location) where intrinsics.type_is_comparable(T) && intrinsics.type_is_unsigned(T) {
	when size_of(T) == 1 {
		format: string = should_be_b8
	} else when size_of(T) == 2 {
		format: string = should_be_b16
	} else when size_of(T) == 4 {
		format: string = should_be_b32
	} else {
		format: string = should_be_b
	}
	expectf(t, act == exp, format, act, exp, loc = loc)
}

expect_value_uintptr :: proc(t: ^testing.T, act: uintptr, exp: int, loc := #caller_location) {
	expectf(t, act == uintptr(exp), should_be_x8, act, uintptr(exp), loc = loc)
}

expect_value_str :: proc(t: ^testing.T, act, exp: string, loc := #caller_location) {
	expectf(t, act == exp, should_be_d, act, exp, loc = loc)
}

expect_flags :: proc(t: ^testing.T, bs: $T, #any_int exp: uint, loc := #caller_location) where intrinsics.type_is_bit_set(T) {
	when size_of(T) == 1 {
		act: u8 = transmute(u8)transmute(T)bs
		expectf(t, act == u8(exp), should_be_x8, act, u8(exp), loc = loc)
	} else when size_of(T) == 2 {
		act: u16 = transmute(u16)transmute(T)bs
		expectf(t, act == u16(exp), should_be_x8, act, u32(exp), loc = loc)
	} else when size_of(T) == 4 {
		act: u32 = transmute(u32)transmute(T)bs
		expectf(t, act == u32(exp), should_be_x8, act, u32(exp), loc = loc)
	} else when size_of(T) == 8 {
		act: u64 = transmute(u64)transmute(T)bs
		expectf(t, act == u64(exp), should_be_x16, act, u64(exp), loc = loc)
	} else {
		#panic("Unhandled expect_flags bit_set size")
	}
}

expect_scalar :: proc(t: ^T, value, expected: $T, loc := #caller_location) -> bool where intrinsics.type_is_comparable(T) {
	when intrinsics.type_is_float(T) {
		format: string = should_be_f
	} else when intrinsics.type_is_unsigned(T) {
		when size_of(T) == 1 {
			format: string = should_be_x2
		} else when size_of(T) == 2 {
			format: string = should_be_x4
		} else when size_of(T) == 4 {
			format: string = should_be_x8
		} else when size_of(T) == 8 {
			format: string = should_be_x16
		} else {
			format: string = should_be_x
		}
	} else {
		format: string = should_be_d
	}

	ok := value == expected || reflect.is_nil(value) && reflect.is_nil(expected)
	if !ok {
		log.errorf(format, value, expected, location = loc)
		return false
	}
	return expectf(t, ok, format, value, expected, loc = loc)
}

expect_vector :: proc(t: ^testing.T, value, expected: $A/[$N]$T, delta: T, loc := #caller_location) {
	when intrinsics.type_is_float(T) {
		format:: should_be_f
	} else {
		format:: should_be_v
	}
	for i in 0 ..< N {
		act, exp := value[i], expected[i]
		expectf(t, abs(act - exp) <= delta, "vector[%d] " + format + " %v", i, act, exp, value, loc = loc)
	}
}

expect_matrix :: proc(t: ^testing.T, value, expected: $A/matrix[$M, $N]$T, delta: T, loc := #caller_location) {
	when intrinsics.type_is_float(T) {
		format:: should_be_f
	} else {
		format:: should_be_v
	}
	for j in 0 ..< N {
		for i in 0 ..< M {
			act, exp := value[i, j], expected[i, j]
			expectf(t, abs(act - exp) <= delta, "matrix[%d,%d] " + format + " %v", i, j, act, exp, value, loc = loc)
		}
	}
}
