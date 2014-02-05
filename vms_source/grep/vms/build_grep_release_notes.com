$! File: build_grep_release_notes.com
$!
$! Build the release note file from the three components:
$!    1. The grep_release_note_start.txt
$!    2. readme. file from the Grep distribution.
$!    3. The grep_build_steps.txt.
$!
$! Set the name of the release notes from the GNV_PCSI_FILENAME_BASE
$! logical name.
$!
$!
$! 02-Feb-2014  J. Malmberg
$!
$!===========================================================================
$!
$ base_file = f$trnlnm("GNV_PCSI_FILENAME_BASE")
$ if base_file .eqs. ""
$ then
$   write sys$output "@make_pcsi_grep_kit_name.com has not been run."
$   goto all_exit
$ endif
$!
$!
$ grep_readme = f$search("sys$disk:[]readme.")
$ if grep_readme .eqs. ""
$ then
$   grep_readme = f$search("sys$disk:[]$README.")
$ endif
$ if grep_readme .eqs. ""
$ then
$   write sys$output "Can not find grep readme file."
$   goto all_exit
$ endif
$!
$ grep_copying = f$search("sys$disk:[]copying.")
$ if grep_copying .eqs. ""
$ then
$   grep_copying = f$search("sys$disk:[]$COPYING.")
$ endif
$ if grep_copying .eqs. ""
$ then
$   write sys$output "Can not find grep copying file."
$   goto all_exit
$ endif
$!
$ type/noheader sys$disk:[.vms]grep_release_note_start.txt,-
        'grep_readme',-
        'grep_copying', -
        sys$disk:[.vms]grep_build_steps.txt -
        /out='base_file'.release_notes
$!
$ purge 'base_file'.release_notes
$ rename 'base_file.release_notes ;1
$!
$all_exit:
$   exit
