# File: grep.mms
#
# Quick and dirty Make file for building Grep on VMS
#
# This build procedure requires the following concealed rooted
# logical names to be set up.
# LCL_ROOT: This is a read/write directory for the build output.
# VMS_ROOT: This is a read only directory for VMS specific changes
#           that have not been checked into the official repository.
# SRC_ROOT: This is a read only directory containing the files in the
#           Offical repository.
# PRJ_ROOT: This is a search list of LCL_ROOT:,VMS_ROOT:,SRC_ROOT:
#
# Copyright 2014, John Malmberg
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
# OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# 29-Jan-2014   J. Malmberg	First pass for grep
##############################################################################
crepository = /repo=sys$disk:[grep.cxx_repository]
cnames = /name=(as_i,shor)$(crepository)
cshow = /show=(EXPA,INC)
.ifdef __IA64__
clist = /list$(cshow)
.else
clist = /list/mach$(cshow)
.endif
.ifdef __VAX__
cprefix = /pref=all
.else
cprefix = /prefix=(all,exce=(strtoimax,strtoumax))
cfloat = /FLOAT=IEEE_FLOAT/IEEE_MODE=DENORM_RESULTS
.endif
#cnowarn1 = noparmlist,questcompare2,unusedtop,unknownmacro
#cnowarn2 = intconcastsgn,controlassign,exprnotused,unreachcode
#cnowarn = $(cnowarn1),$(cnowarn2)
#cwarn = /warnings=(disable=($(cnowarn)))
#cinc1 = prj_root:[],prj_root:[.include],prj_root:[.lib.intl],prj_root:[.lib.sh]
cinc2 = /nested=none
cinc = $(cinc2)
#cdefs = /define=(_USE_STD_STAT=1,_POSIX_EXIT=1,\
#	HAVE_STRING_H=1,HAVE_STDLIB_H=1,HAVE_CONFIG_H=1,SHELL=1)
.ifdef __VAX__
cdefs1 = _POSIX_EXIT=1,HAVE_CONFIG_H=1
cdefs2 = _POSIX_EXIT=1,MSDOS,MOD_MAIN
cmain =
.else
cdefs1 = _USE_STD_STAT,_POSIX_EXIT=1,HAVE_CONFIG_H=1
cdefs2 = _USE_STD_STAT,_POSIX_EXIT=1,MSDOS,MOD_MAIN
cmain = /MAIN=POSIX_EXIT
.endif
cdefs = /define=($(cdefs1))$(cmain)
main_defs = /define=($(cdefs2))$(cmain)
cflags = $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(cdefs)$(cfloat)
cflagsx = $(cnames)/debu$(clist)$(cwarn)$(cinc2)$(cfloat)$(cmain)
cflags_main = \
    $(cnames)/debu$(clist)$(cprefix)$(cwarn)$(cinc)$(main_defs)$(cfloat)

#
# TPU symbols
#===================

UNIX_2_VMS = /COMM=prj_root:[.vms]unix_c_to_vms_c.tpu

EVE = EDIT/TPU/SECT=EVE$SECTION/NODISP

.SUFFIXES
.SUFFIXES .exe .olb .obj .c .def

#.SUFFIXES .1 .c .dvi .html .log .o .obj .pl .pl.exe \
#	.ps .sed .sh .sh.exe .sin .x .xpl .xpl.exe .y

.obj.exe
   $(LINK)$(LFLAGS)/NODEBUG/EXE=$(MMS$TARGET)/DSF=$(MMS$TARGET_NAME)\
     /MAP=$(MMS$TARGET_NAME) $(MMS$SOURCE_LIST)

.c.obj
#   $define/user selinux sys$disk:[.lib.selinux]
   $define/user glthread sys$disk:[.lib.glthread]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms],sys$disk:[.build-aux.snippet]
   $(CC)$(CFLAGS)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

.obj.olb
   @ if f$search("$(MMS$TARGET)") .eqs. "" then \
	librarian/create/object $(MMS$TARGET)
   $ librarian/replace $(MMS$TARGET) $(MMS$SOURCE_LIST)

config_h = config.h config_vms.h [.vms]vms_grep_hacks.h [.vms]vms_fcntl_hacks.h

argmatch_h = [.lib]argmatch.h [.lib]verify.h

bitrotate_h = [.lib]bitrotate.h [.lib]stdint.h

c_strcaseeq_h = [.lib]c-strcaseeq.h [.lib]c-strcase.h [.lib]c-ctype.h

chdir_long_h = [.lib]chdir-long.h [.lib]pathmax.h

cycle_check_h = [.lib]cycle-check.h [.lib]dev-ino.h [.lib]same-inode.h \
		[.lib]stdint.h

dirent__h = [.lib]dirent--.h [.lib]dirent-safer.h

dirname_h = [.lib]dirname.h [.lib]dosname.h

fcntl__h = [.lib]fcntl--.h [.lib]fcntl-safer.h

i_ring_h = [.lib]i-ring.h [.lib]verify.h

fts__h = [.lib]fts_.h $(i_ring_h)

getopt_int_h = [.lib]getopt_int.h [.lib]getopt.h

kwset_h = [.src]kwset.h [.build-aux.snippet]arg-nonnull.h

malloca_h = [.lib]malloca.h [.lib]alloca.h

mbiter_h = [.lib]mbiter.h [.lib]mbchar.h

mbuiter_h = [.lib]mbuiter.h [.lib]mbchar.h [.lib]strlen1.h

regex_internal_h = [.lib]regex_internal.h [.lib.glthread]lock.h \
		[.lib]stdint.h [.lib]alloca.h

system_h = [.src]system.h [.lib]binary-io.h [.lib]minmax.h \
	[.lib]same-inode.h [.lib]unlocked-io.h [.lib]configmake.h

search_h = [.src]search.h [.src]mbsupport.h $(system_h) [.lib]error.h \
	[.src]grep.h $(kwset_h) [.lib]xalloc.h [.lib]stdint.h

unistd__h = [.lib]unistd--.h [.lib]unistd-safer.h

xalloc_h = [.lib]xalloc.h [.lib]xalloc-oversized.h

xstrtol_h = [.lib]xstrtol.h [.lib]getopt.h

safe_read_c = [.lib]safe-read.c $(config_h) [.lib]safe-read.h

strtoimax_c = [.lib]strtoimax.c $(config_h) [.lib]verify.h

libgrep_objects = "quickset"=[.src]kwset.obj, \
		"dfa"=[.src]dfa.obj, \
		"searchutils"=[.src]searchutils.obj, \
		"dfasearch"=[.src]dfasearch.obj, \
		"kwsearch"=[.src]kwsearch.obj, \
		"pcresearch"=[.src]pcresearch.obj

gnulib_objects = "argmatch"=[.lib]argmatch.obj,\
		"c-ctype"=[.lib]c-ctype.obj,\
		"c-strcasecmp"=[.lib]c-strcasecmp.obj,\
		"chdir-long"=[.lib]chdir-long.obj,\
		"cloexec"=[.lib]cloexec.obj,\
		"close-stream"=[.lib]close-stream.obj,\
		"closeout"=[.lib]closeout.obj,\
		"colorize-posix"=[.lib]colorize-posix.obj,\
		"cycle-check"=[.lib]cycle-check.obj,\
		"error"=[.lib]error.obj,\
		"exclude"=[.lib]exclude.obj,\
		"exitfail"=[.lib]exitfail.obj,\
		"fcntl"=[.lib]fcntl.obj,\
		"fd-safer"=[.lib]fd-safer.obj,\
		"fnmatch"=[.lib]fnmatch.obj,\
		"fpending"=[.lib]fpending.obj,\
		"fstatat"=[.lib]fstatat.obj,\
		"fts"=[.lib]fts.obj,\
		"getopt"=[.lib]getopt.obj,\
		"getopt1"=[.lib]getopt1.obj,\
		"hash"=[.lib]hash.obj,\
		"i-ring"=[.lib]i-ring.obj,\
		"localcharset"=[.lib]localcharset.obj,\
		"malloca"=[.lib]malloca.obj,\
		"mbchar"=[.lib]mbchar.obj,\
		"mbscasecmp"=[.lib]mbscasecmp.obj,\
		"mbslen"=[.lib]mbslen.obj,\
		"mbsstr"=[.lib]mbsstr.obj,\
		"memrchr"=[.lib]memrchr.obj,\
		"obstack"=[.lib]obstack.obj,\
		"openat"=[.lib]openat.obj,\
		"openat-die"=[.lib]openat-die.obj,\
		"openat-proc"=[.lib]openat-proc.obj,\
		"openat-safer"=[.lib]openat-safer.obj,\
		"progname"=[.lib]progname.obj,\
		"propername"=[.lib]propername.obj,\
		"quotearg"=[.lib]quotearg.obj,\
		"regex"=[.lib]regex.obj,\
		"safe-read"=[.lib]safe-read.obj,\
		"save-cwd"=[.lib]save-cwd.obj,\
		"striconv"=[.lib]striconv.obj,\
		"strnlen1"=[.lib]strnlen1.obj,\
		"strtoimax"=[.lib]strtoimax.obj,\
		"trim"=[.lib]trim.obj,\
		"version-etc"=[.lib]version-etc.obj,\
		"version-etc-fsf"=[.lib]version-etc-fsf.obj,\
		"xmalloc"=[.lib]xmalloc.obj,\
		"xalloc-die"=[.lib]xalloc-die.obj, \
		"xstriconv"=[.lib]xstriconv.obj,\
		"xtrtoimax"=[.lib]xstrtoimax.obj,\
		"vms_terminal_io"=[.lib]vms_terminal_io.obj,\
		"vms_term"=[.lib]vms_term.obj


all : programs manpages

programs : gnv$grep.exe grep_debug.exe \
		gnv$egrep.exe egrep_debug.exe \
		gnv$fgrep.exe fgrep_debug.exe

gnv$grep.exe : [.src]grep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.src]main.obj, [.src]grep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

grep_debug.exe : [.src]grep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb  vms_crtl_init.obj
	link/debug/exe=$(MMS$TARGET) [.src]main.obj, [.src]grep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

gnv$egrep.exe : [.src]egrep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.src]main.obj, [.src]egrep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

egrep_debug.exe : [.src]egrep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb vms_crtl_init.obj
	link/debug/exe=$(MMS$TARGET) [.src]main.obj, [.src]egrep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

gnv$fgrep.exe : [.src]fgrep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb vms_crtl_init.obj
	link/exe=$(MMS$TARGET) [.src]main.obj, [.src]fgrep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

fgrep_debug.exe : [.src]fgrep.obj [.src]main.obj [.src]libgrep.olb \
		[.lib]gnulib.olb vms_crtl_init.obj
	link/debug/exe=$(MMS$TARGET) [.src]main.obj, [.src]fgrep.obj, \
		sys$disk:[.src]libgrep.olb/lib, \
		sys$disk:[.lib]gnulib.olb/lib, sys$disk:[]vms_crtl_init.obj

[.src]libgrep.olb : [.src]libgrep($(libgrep_objects))
    @ write sys$output "libgrep is up to date"

[.lib]gnulib.olb : [.lib]gnulib($(gnulib_objects))
    @ write sys$output "gnulib is up to date"

config.h : [.vms]config_h.com config_vms.h config.hin configure.
	@[.vms]config_h.com
	write sys$output "[.lib]config.h target built."

config_vms.h : [.vms]generate_config_vms_h_grep.com
	$ @[.vms]generate_config_vms_h_grep.com

[.lib]configmake.h : [.vms]configmake_h.com
        @ $write sys$output "[.lib]configmake.h target"
        @[.vms]configmake_h.com

[.lib]alloca.h : [.vms]vms_alloca.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

[.lib]fnmatch.h : [.lib]fnmatch.in.h
	type/noheader $(MMS$SOURCE) /output=sys$disk:$(MMS$TARGET)

.ifdef __VAX__
getopt_in_h = [.lib]getopt.in$5nh
.else
getopt_in_h = [.lib]getopt.in.h
.endif
[.lib]getopt.h : $(getopt_in_h) [.vms]lib_getopt_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

.ifdef __VAX__
stdint_in_h = [.lib]stdint.in$5nh
.else
stdint_in_h = [.lib]stdint^.in.h
.endif
[.lib]stdint.h : $(stdint_in_h) [.vms]lib_stdint_h.tpu
    $(EVE) $(UNIX_2_VMS) $(MMS$SOURCE)/OUT=$(MMS$TARGET)\
	    /init='f$element(1, ",", "$(MMS$SOURCE_LIST)")'

[.src]grep.obj : [.src]grep.c $(config_h) $(search_h)

[.src]egrep.obj : [.src]egrep.c $(config_h) $(search_h)

[.src]fgrep.obj : [.src]fgrep.c $(config_h) $(search_h)

[.src]main.obj : [.src]main.c [.src]mbsupport.h $(system_h) $(argmatch_h) \
		[.lib]c-ctype.h [.lib]closeout.h [.lib]colorize.h \
		[.lib]error.h [.lib]exclude.h [.lib]exitfail.h \
		[.lib]fcntl-safer.h $(fts__h) [.lib]getopt.h [.src]grep.h \
		[.lib]intprops.h [.lib]progname.h [.lib]propername.h \
		[.lib]quote.h [.lib]safe-read.h [.lib]version-etc.h \
		[.lib]xalloc.h [.lib]xstrtol.h [.vms]vms_main_wrapper.c
   $!define/user selinux sys$disk:[.lib.selinux]
   $define/user decc$user_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.tests]
   $define/user decc$system_include sys$disk:[],sys$disk:[.lib],\
	sys$disk:[.src],sys$disk:[.vms],sys$disk:[.build-aux.snippet]
   $(CC)$(CFLAGS_MAIN)/OBJ=$(MMS$TARGET) $(MMS$SOURCE)

[.src]dfa.obj : [.src]dfa.c $(config_h) [.src]dfa.h [.lib]gettext.h \
		[.src]mbsupport.h $(xalloc_h)

[.src]dfasearch.obj : [.src]dfasearch.c $(config_h) [.lib]intprops.h \
		$(search_h) [.src]dfa.h

[.src]kwsearch.obj : [.src]kwsearch.c $(config_h) $(search_h)

[.src]kwset.obj : [.src]kwset.c $(config_h) $(system_h) $(argmatch_h) \
		$(kwset_h) [.lib]xalloc.h

[.src]pcresearch.obj : [.src]pcresearch.c $(config_h) $(search_h)

[.src]searchutils.obj : [.src]searchutils.c $(config_h) $(search_h)

vms_crtl_init.obj : [.vms]vms_crtl_init.c
	$(CC)$(cflagsx)/define="GNV_UNIX_TOOL=1" \
	/object=$(MMS$TARGET) $(MMS$SOURCE)


[.lib]argmatch.obj : [.lib]argmatch.c $(config_h) $(argmatch_h) \
	[.lib]gettext.h [.lib]error.h [.lib]quotearg.h [.lib]quote.h \
	[.lib]unlocked-io.h [.lib]exitfail.h

[.lib]c-ctype.obj : [.lib]c-ctype.c $(config_h) [.lib]c-ctype.h

[.lib]c-strcasecmp.obj : [.lib]c-strcasecmp.c $(config_h) \
	[.lib]c-strcase.h [.lib]c-ctype.h

[.lib]chdir-long.obj : [.lib]chdir-long.c $(config_h) $(chdir_long_h) \
	[.lib]closeout.h [.lib]error.h

[.lib]cloexec.obj : [.lib]cloexec.c $(config_h) [.lib]cloexec.h

[.lib]close-stream.obj : [.lib]close-stream.c $(config_h) \
	[.lib]close-stream.h $(fpending_h) [.lib]unlocked-io.h

[.lib]closeout.obj : [.lib]closeout.c $(config_h) [.lib]closeout.h \
	[.lib]gettext.h [.lib]close-stream.h [.lib]error.h \
	[.lib]exitfail.h [.lib]quotearg.h

[.lib]colorize-posix.obj : [.lib]colorize-posix.c $(config_h) \
	[.lib]colorize.h

[.lib]cycle-check.obj : [.lib]cycle-check.c $(config_h) $(cycle_check_h)

[.lib]error.obj : [.lib]error.c $(config_h) [.lib]error.h \
	[.lib]gettext.h [.lib]unlocked-io.h [.lib]msvc-nothrow.h \
	[.lib]stdint.h

[.lib]exclude.obj : [.lib]exclude.c $(config_h) [.lib]exclude.h \
	[.lib]hash.h [.lib]mbuiter.h [.lib]fnmatch.h [.lib]xalloc.h \
	[.lib]verify.h [.lib]unlocked-io.h

[.lib]exitfail.obj : [.lib]exitfail.c $(config_h) [.lib]exitfail.h

[.lib]fcntl.obj : $(config_h) [.lib]msvc-nothrow.h

[.lib]fd-safer.obj : [.lib]fd-safer.c $(config_h) [.lib]unistd-safer.h

[.lib]fnmatch.obj : [.lib]fnmatch.c $(config_h) [.lib]fnmatch_loop.c \
	[.lib]fnmatch.h [.lib]alloca.h

[.lib]fstatat.obj : [.lib]fstatat.c $(config_h) $(at_func_c)

[.lib]fts.obj : [.lib]fts.c $(config_h) [.lib]fts_.h \
	$(fcntl___h) $(dirent___h) $(unistd___h) \
	[.lib]cloexec.h [.lib]openat.h [.lib]same-inode.h \
	$(fts_cycle_c) [.vms]vms_pwd_hack.h

[.lib]fpending.obj : [.lib]fpending.c $(config_h) $(fpending_h)

[.lib]getopt.obj : [.lib]getopt.c $(config_h) [.lib]getopt.h \
	[.lib]gettext.h $(getopt_int_h)

[.lib]getopt1.obj : [.lib]getopt1.c $(config_h) $(getopt_int_h)

[.lib]hash.obj : [.lib]hash.c $(config_h) [.lib]hash.h \
	$(bitrotate_h) [.lib]xalloc-oversized.h [.lib]obstack.h

[.lib]i-ring.obj : [.lib]i-ring.c $(config_h) $(i_ring_h)

#  [.lib]relocatable.h not currently used in localcharset.c
[.lib]localcharset.obj : [.lib]localcharset.c $(config_h) \
	[.lib]localcharset.h [.lib]configmake.h

[.lib]malloca.obj : [.lib]malloca.c $(config_h) $(malloca_h) \
	[.lib]verify.h [.lib]stdint.h

[.lib]mbchar.obj : [.lib]mbchar.c $(config_h) [.lib]mbchar.h

[.lib]mbscasecmp.obj : [.lib]mbscasecmp.c $(config_h) [.lib]mbuiter.h

[.lib]mbslen.obj : [.lib]mbslen.c $(config_h) [.lib]mbuiter.h

[.lib]mbsstr.obj : [.lib]mbsstr.c $(config_h) $(malloca_h) \
	[.lib]mbuiter.h [.lib]str-kmp.h

[.lib]memrchr.obj : [.lib]memrchr.c $(config_h)

[.lib]obstack.obj : [.lib]obstack.c $(config_h) [.lib]obstack.h \
	[.lib]gettext.h [.lib]stdint.h

[.lib]openat-die.obj : [.lib]openat-die.c $(config_h) [.lib]openat.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]openat-proc.obj : [.lib]openat-proc.c $(config_h) \
	[.lib]openat-priv.h [.lib]intprops.h

[.lib]openat-safer.obj : [.lib]openat-safer.c $(config_h) \
	[.lib]fcntl-safer.h [.lib]unistd-safer.h

[.lib]progname.obj : [.lib]progname.c [.lib]progname.h

[.lib]propername.obj : [.lib]propername.c $(config_h) \
	[.lib]propername.h [.lib]trim.h [.lib]mbchar.h [.lib]mbuiter.h \
	[.lib]localcharset.h [.lib]c-strcase.h [.lib]xstriconv.h \
	[.lib]xalloc.h [.lib]gettext.h

[.lib]quotearg.obj : [.lib]quotearg.c $(config_h) [.lib]quotearg.h \
	[.lib]quote.h [.lib]xalloc.h $(c_strcaseeq_h) \
	[.lib]localcharset.h [.lib]gettext.h

[.lib]regex.obj : [.lib]regex.c $(config_h) $(regex_internal_h) \
	[.lib]regex_internal.c [.lib]regcomp.c [.lib]regexec.c

[.lib]safe-read.obj : $(safe_read_c)

[.lib]save-cwd.obj : [.lib]save-cwd.c $(config_h) [.lib]save-cwd.h \
	$(chdir_long_h) $(unistd___h) [.lib]cloexec.h $(fcntl___h) \
	[.vms]vms_pwd_hack.h

[.lib]strtoimax.obj : $(strtoimax_c)

[.lib]striconv.obj : [.lib]striconv.c $(config_h) [.lib]striconv.h \
	[.lib]c-strcase.h

[.lib]strnlen1.obj : [.lib]strnlen1.c $(config_h) [.lib]strnlen1.h

[.lib]trim.obj : [.lib]trim.c $(config_h) [.lib]trim.h \
	[.lib]mbchar.h [.lib]mbuiter.h [.lib]xalloc.h

[.lib]version-etc-fsf.obj : [.lib]version-etc-fsf.c $(config_h) \
	[.lib]version-etc.h

[.lib]version-etc.obj : [.lib]version-etc.c $(config_h) \
	[.lib]version-etc.h [.lib]unlocked-io.h [.lib]gettext.h

[.lib]xalloc-die.obj : [.lib]xalloc-die.c $(config_h) [.lib]xalloc.h \
	[.lib]error.h [.lib]exitfail.h [.lib]gettext.h

[.lib]xmalloc.obj : [.lib]xmalloc.c $(config_h) [.lib]xalloc.h

[.lib]xstriconv.obj : [.lib]xstriconv.c $(config_h) [.lib]xstriconv.h \
	[.lib]striconv.h [.lib]xalloc.h

[.lib]xstrtoimax.obj : [.lib]xstrtoimax.c $(xstrtol_c)

[.lib]vms_term.obj : [.vms]vms_term.c [.vms]vms_term.h

[.lib]vms_terminal_io.obj : [.vms]vms_terminal_io.c [.vms]vms_terminal_io.h \
	[.vms]vms_lstat_hack.h

manpages : [.doc]grep.1

.ifdef __VAX__
grep_in_1 = [.doc]grep.in$5n1
.else
grep_in_1 = [.doc]grep^.in.1
.endif

[.doc]grep.1 : $(grep_in_1)
    $ @[.vms]build_grep_manpages.com

realclean : clean
    @ if f$search("config.h") .nes. "" then delete config.h;*
    @ if f$search("config_vms.h") .nes. "" then delete config_vms.h;*
    @ if f$search("gnv$grep.exe") .nes. "" then delete gnv$grep.exe;*
    @ if f$search("gnv$grep.dsf") .nes. "" then delete gnv$grep.dsf;*
    @ if f$search("gnv$grep.map") .nes. "" then delete gnv$grep.map;*
    @ if f$search("grep_debug.exe") .nes. "" then delete grep_debug.exe;*
    @ if f$search("grep_debug.dsf") .nes. "" then delete grep_debug.dsf;*
    @ if f$search("grep_debug.map") .nes. "" then delete grep_debug.map;*
    @ if f$search("gnv$egrep.exe") .nes. "" then delete gnv$egrep.exe;*
    @ if f$search("gnv$egrep.dsf") .nes. "" then delete gnv$egrep.dsf;*
    @ if f$search("gnv$egrep.map") .nes. "" then delete gnv$egrep.map;*
    @ if f$search("egrep_debug.exe") .nes. "" then delete egrep_debug.exe;*
    @ if f$search("egrep_debug.dsf") .nes. "" then delete egrep_debug.dsf;*
    @ if f$search("egrep_debug.map") .nes. "" then delete egrep_debug.map;*
    @ if f$search("gnv$fgrep.exe") .nes. "" then delete gnv$fgrep.exe;*
    @ if f$search("gnv$fgrep.dsf") .nes. "" then delete gnv$fgrep.dsf;*
    @ if f$search("gnv$fgrep.map") .nes. "" then delete gnv$fgrep.map;*
    @ if f$search("fgrep_debug.exe") .nes. "" then delete fgrep_debug.exe;*
    @ if f$search("fgrep_debug.dsf") .nes. "" then delete fgrep_debug.dsf;*
    @ if f$search("fgrep_debug.map") .nes. "" then delete fgrep_debug.map;*
    @ if f$search("[.lib]configmake.h") .nes. "" then \
	delete [.lib]configmake.h;*
    @ if f$search("[.lib]stdint.h") .nes. "" then delete [.lib]stdint.h;*
    @ if f$search("[.lib]getopt.h") .nes. "" then delete [.lib]getopt.h;*
    @ if f$search("[.lib]alloca.h") .nes. "" then delete [.lib]alloca.h;*
    @ if f$search("[.lib]fnmatch.h") .nes. "" then delete [.lib]fnmatch.h;*
    @ if f$search("[.cxx_repository]cxx$demangler_db.") .nes. "" then \
	delete [.cxx_repository]cxx$demangler_db.;*

clean :
    @ if f$search("[.src]libgrep.olb") .nes. "" then \
	delete [.src]libgrep.olb;*
    @ if f$search("[.lib]gnulib.olb") .nes. "" then \
	delete [.lib]gnulib.olb;*
    @ if f$search("[]*.obj") .nes. "" then delete []*.obj;*
    @ if f$search("[]grep-*.release_notes") .nes. "" then \
	delete []grep-*.release_notes;*
    @ if f$search("[]*.pcsi$desc") .nes. "" then delete []*.pcsi$desc;*
    @ if f$search("[]*.pcsi$text") .nes. "" then delete []*.pcsi$text;*
    @ if f$search("[.src]*.obj") .nes. "" then delete [.src]*.obj;*
    @ if f$search("*.lis") .nes. "" then delete *.lis;*
    @ if f$search("[.lib]*.obj") .nes. "" then delete [.lib]*.obj;*
    @ if f$search("[.doc]grep.1") .nes. "" then delete [.doc]grep.1;*
    @ if f$search("[.doc]egrep.1") .nes. "" then delete [.doc]egrep.1;*
    @ if f$search("[.doc]fgrep.1") .nes. "" then delete [.doc]fgrep.1;*
