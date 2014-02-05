$! File build_grep_manpages.com
$!
$! Copyright 2014, John Malmberg
$!
$! Permission to use, copy, modify, and/or distribute this software for any
$! purpose with or without fee is hereby granted, provided that the above
$! copyright notice and this permission notice appear in all copies.
$!
$! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
$! WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
$! MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
$! ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
$! WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
$! ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
$! OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
$!
$!
$ create [.doc]egrep.1/fdl=[.vms]man_grep.fdl
$ open/append man_out [.doc]egrep.1
$ write man_out ".so man1/grep.1"
$ close man_out
$!
$ create [.doc]fgrep.1/fdl=[.vms]man_grep.fdl
$ open/append man_out [.doc]fgrep.1
$ write man_out ".so man1/fgrep.1"
$ close man_out
$!
$! We need to get the version from config.h.  It will have a lines like
$! #define VERSION "4.1.0a"
$!
$!
$ open/read/error=version_loop_end verf config.h
$ version_loop:
$   read/end=version_loop_end verf line_in
$   if line_in .eqs. "" then goto version_loop
$   if f$locate("#define VERSION", line_in) .ne. 0
$   then
$       goto version_loop
$   endif
$   tag = f$element(1, " ", line_in)
$   value = f$element(2, " ", line_in) - """" - """"
$   if tag .eqs. "VERSION"
$   then
$       distversion = value
$       goto version_loop_end
$   endif
$   goto version_loop
$ version_loop_end:
$ close verf
$ if distversion .eqs. ""
$ then
$   write sys$output "Could not find VERSION in config.h file."
$   exit 44
$ endif
$!
$ man_page_file = "[.doc]grep.1"
$ create 'man_page_file'/fdl=[.vms]man_grep.fdl
$!
$ man_page_in_file = f$search("[.doc]grep^.in.1")
$ if man_page_in_file .eqs. ""
$ then
$   man_page_in_file = f$search("[.doc]grep.in$5n1")
$ endif
$ if man_page_in_file .eqs. ""
$ then
$   write sys$output "Can not find the [.doc]grep.in*1 file!"
$   exit 44
$ endif
$!
$ open/read man_in 'man_page_in_file'
$ open/append man_out 'man_page_file'
$ man_grep_loop:
$   read man_in/end=man_grep_loop_end line_in
$   line_in_len = f$length(line_in)
$   version_start = f$locate("@VERSION@", line_in)
$   if version_start .lt. line_in_len
$   then
$!      Replace @VERSION@ with actual version.
$       line_out = f$extract(0, version_start, line_in)
$	line_out = line_out + distversion
$	line_end_len = line_in_len - version_start - 9
$       line_end = f$extract(version_start + 9, line_end_len, line_in)
$       line_out = line_out + line_end
$       write man_out line_out
$       goto man_grep_loop
$   endif
$   write man_out line_in
$   goto man_grep_loop
$ man_grep_loop_end:
$ close man_out
$ close man_in
$!
$all_exit:
$  exit
