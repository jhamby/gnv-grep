$! File: grep_alias_setup.com
$!
$! The PCSI procedure needs a helper script to set up and remove aliases.
$!
$! If p1 starts with "R" then remove instead of install.
$!
$!
$! 02-Feb-2014  J. Malmberg - Grep Version
$!
$!===========================================================================
$!
$ mode = "install"
$ code = f$extract(0, 1, p1)
$ if code .eqs. "R" .or. code .eqs. "r" then mode = "remove"
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ arch_code = f$extract(0, 1, arch_type)
$!
$ if arch_code .nes. "V"
$ then
$   set proc/parse=extended
$ endif
$!
$!
$ call do_alias "grep" "[bin]"
$ call do_alias "grep" "[bin]" "egrep"
$ call do_alias "grep" "[bin]" "fgrep"
$!
$ exit
$!!
$!
$do_alias: subroutine
$ if mode .eqs. "install"
$ then
$   call add_alias "''p1'" "''p2'" "''p3'" "''p4'"
$ else
$   call remove_alias "''p1'" "''p2'" "''p3'" "''p4'"
$ endif
$ exit
$ENDSUBROUTINE ! do_alias
$!
$!
$! P1 is the filename, p2 is the directory prefix,
$! p3 is the alias name if different than p1
$! p4 is the alias directory if different than p2
$add_alias: subroutine
$ if p3 .eqs. "" then p3 = p1
$ if p4 .eqs. "" then p4 = p2
$ ftype = f$element(1, ".", p1)
$ if ftype .eqs. "."
$ then
$    file = "gnv$gnu:''p2'gnv$''p1'.EXE"
$    alias = "gnv$gnu:''p4'''p3'."
$ else
$    file = "gnv$gnu:''p2'''p1'"
$    alias = "gnv$gnu:''p4'''p3'"
$ endif
$ if f$search(file) .nes. ""
$ then
$   if f$search(alias) .eqs. ""
$   then
$       set file/enter='alias' 'file'
$   endif
$   alias1 = alias + "exe"
$   if (ftype .eqs. ".") .and. (f$search(alias1) .eqs. "")
$   then
$       set file/enter='alias1' 'file'
$   endif
$ endif
$ exit
$ENDSUBROUTINE ! add_alias
$!
$remove_alias: subroutine
$ if p3 .eqs. "" then p3 = p1
$ if p4 .eqs. "" then p4 = p2
$ ftype = f$element(1, ".", p1)
$ if ftype .eqs. "."
$ then
$   file = "gnv$gnu:''p2'gnv$''p1'.EXE"
$   alias = "gnv$gnu:''p4'''p3'."
$ else
$   file = "gnv$gnu:''p2'''p1'"
$   alias = "gnv$gnu:''p4'''p3'"
$ endif
$ file_fid = "No_file_fid"
$ if f$search(file) .nes. ""
$ then
$   fid = f$file_attributes(file, "FID")
$   if f$search(alias) .nes. ""
$   then
$       afid = f$file_attributes(alias, "FID")
$       if (afid .eqs. fid)
$       then
$           set file/remove 'alias';
$       endif
$   endif
$   alias1 = alias + "exe"
$   if (ftype .eqs. ".") .and. (f$search(alias1) .nes. "")
$   then
$       afid = f$file_attributes(alias1, "FID")
$       if (afid .eqs. fid)
$       then
$           set file/remove 'alias1';
$       endif
$   endif
$ endif
$ exit
$ENDSUBROUTINE ! remove_alias
