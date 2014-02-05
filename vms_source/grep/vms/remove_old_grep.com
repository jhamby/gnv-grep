$! File: remove_old_grep.com
$!
$! This is a procedure to remove the old grep images that were installed
$! by the GNV kits and replace them with links to the new image.
$!
$! 24-Jan-2014  J. Malmberg	Grep version
$!
$!==========================================================================
$!
$vax = f$getsyi("HW_MODEL") .lt. 1024
$old_parse = ""
$if .not. VAX
$then
$   old_parse = f$getjpi("", "parse_style_perm")
$   set process/parse=extended
$endif
$!
$old_cutils = "grep"
$!
$!
$ i = 0
$cutils_loop:
$   file = f$element(i, ",", old_cutils)
$   if file .eqs. "" then goto cutils_loop_end
$   if file .eqs. "," then goto cutils_loop_end
$   call update_old_image 'file'
$   i = i + 1
$   goto cutils_loop
$cutils_loop_end:
$!
$!
$if .not. VAX
$then
$   file = "gnv$gnu:[usr.share.man.cat1]grep^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$endif
$!
$!
$if .not. VAX
$then
$   set process/parse='old_parse'
$endif
$!
$all_exit:
$  exit
$!
$! Remove old image or update it if needed.
$!-------------------------------------------
$update_old_image: subroutine
$!
$ file = p1
$! First get the FID of the new grep image.
$! Don't remove anything that matches it.
$ new_grep = f$search("GNV$GNU:[BIN]GNV$''file'.EXE")
$!
$ new_grep_fid = "No_new_grep_fid"
$ if new_grep .nes. ""
$ then
$   new_grep_fid = f$file_attributes(new_grep, "FID")
$ endif
$!
$!
$!
$! Now get check the "''file'." and "''file'.exe"
$! May be links or copies.
$! Ok to delete and replace.
$!
$!
$ old_grep_fid = "No_old_grep_fid"
$ old_grep = f$search("gnv$gnu:[bin]''file'.")
$ old_grep_exe_fid = "No_old_grep_fid"
$ old_grep_exe = f$search("gnv$gnu:[bin]''file'.exe")
$ if old_grep_exe .nes. ""
$ then
$   old_grep_exe_fid = f$file_attributes(old_grep_exe, "FID")
$ endif
$!
$ if old_grep .nes. ""
$ then
$   fid = f$file_attributes(old_grep, "FID")
$   if fid .nes. new_grep_fid
$   then
$       if fid .eqs. old_grep_exe_fid
$       then
$           set file/remove 'old_grep'
$       else
$           delete 'old_grep'
$       endif
$       if new_grep .nes. ""
$       then
$           set file/enter='old_grep' 'new_grep'
$       endif
$   endif
$ endif
$!
$ if old_grep_exe .nes. ""
$ then
$   if old_grep_fid .nes. new_grep_fid
$   then
$       delete 'old_grep_exe'
$       if new_grep .nes. ""
$       then
$           set file/enter='old_grep_exe' 'new_grep'
$       endif
$   endif
$ endif
$!
$ exit
$ENDSUBROUTINE ! Update old image
$! File: remove_old_grep.com
$!
$! This is a procedure to remove the old grep images that were installed
$! by the GNV kits and replace them with links to the new image.
$!
$! 02-Jan-2014  J. Malmberg	Grep version
$!
$!==========================================================================
$!
$vax = f$getsyi("HW_MODEL") .lt. 1024
$old_parse = ""
$if .not. VAX
$then
$   old_parse = f$getjpi("", "parse_style_perm")
$   set process/parse=extended
$endif
$!
$old_cutils = "grep,egrep,fgrep"
$!
$!
$ i = 0
$cutils_loop:
$   file = f$element(i, ",", old_cutils)
$   if file .eqs. "" then goto cutils_loop_end
$   if file .eqs. "," then goto cutils_loop_end
$   call update_old_image 'file'
$   i = i + 1
$   goto cutils_loop
$cutils_loop_end:
$!
$!
$if .not. VAX
$then
$   file = "gnv$gnu:[usr.share.man.cat1]egrep^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gnv$gnu:[usr.share.man.cat1]fgrep^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gnv$gnu:[usr.share.man.cat1]grep^.1.gz"
$   if f$search(file) .nes. "" then delete 'file';*
$endif
$!
$!
$if .not. VAX
$then
$   set process/parse='old_parse'
$endif
$!
$all_exit:
$  exit
$!
$! Remove old image or update it if needed.
$!-------------------------------------------
$update_old_image: subroutine
$!
$ file = p1
$! First get the FID of the new grep image.
$! Don't remove anything that matches it.
$ new_grep = f$search("GNV$GNU:[BIN]GNV$''file'.EXE")
$!
$ new_grep_fid = "No_new_grep_fid"
$ if new_grep .nes. ""
$ then
$   new_grep_fid = f$file_attributes(new_grep, "FID")
$ endif
$!
$!
$!
$! Now get check the "''file'." and "''file'.exe"
$! May be links or copies.
$! Ok to delete and replace.
$!
$!
$ old_grep_fid = "No_old_grep_fid"
$ old_grep = f$search("gnv$gnu:[bin]''file'.")
$ old_grep_exe_fid = "No_old_grep_fid"
$ old_grep_exe = f$search("gnv$gnu:[bin]''file'.exe")
$ if old_grep_exe .nes. ""
$ then
$   old_grep_exe_fid = f$file_attributes(old_grep_exe, "FID")
$ endif
$!
$ if old_grep .nes. ""
$ then
$   fid = f$file_attributes(old_grep, "FID")
$   if fid .nes. new_grep_fid
$   then
$       if fid .eqs. old_grep_exe_fid
$       then
$           set file/remove 'old_grep'
$       else
$           delete 'old_grep'
$       endif
$       if new_grep .nes. ""
$       then
$           set file/enter='old_grep' 'new_grep'
$       endif
$   endif
$ endif
$!
$ if old_grep_exe .nes. ""
$ then
$   if old_grep_fid .nes. new_grep_fid
$   then
$       delete 'old_grep_exe'
$       if new_grep .nes. ""
$       then
$           set file/enter='old_grep_exe' 'new_grep'
$       endif
$   endif
$ endif
$!
$ exit
$ENDSUBROUTINE ! Update old image
