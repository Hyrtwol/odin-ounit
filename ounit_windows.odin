//+build windows
package ounit

import "base:runtime"
import win32 "core:sys/windows"
import "core:testing"

@(private)
expect_value_wstr :: proc(t: ^testing.T, wact, wexp: win32.wstring, loc := #caller_location) {
	act, exp: string
	err: runtime.Allocator_Error
	act, err = win32.wstring_to_utf8(wact, 16)
	expectf(t, err == .None, should_be_x8, err, 0, loc = loc)
	exp, err = win32.wstring_to_utf8(wexp, 16)
	expectf(t, err == .None, should_be_x8, err, 0, loc = loc)
	expectf(t, act == exp, should_be_x8, act, exp, loc = loc)
}
