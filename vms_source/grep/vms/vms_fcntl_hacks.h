/* File: vms_fcntl_hacks.h
 *
 * GNU Fcntl features missing on VMS
 *
 * Copyright 2013, John Malmberg
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
 * OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * 19-Oct-2013	J. Malmberg	Original
 *
 ***************************************************************************/

#include <fcntl.h>

#ifdef AT_FDCWD
#undef AT_FDCWD
#endif
#define AT_FDCWD (-3041965)

#ifdef AT_SYMLINK_NOFOLLOW
#undef AT_SYMLINK_NOFOLLOW
#endif
#define AT_SYMLINK_NOFOLLOW 4096

#ifdef AT_REMOVEDIR
#undef AT_REMOVEDIR
#endif
#define AT_REMOVEDIR 1

#ifdef AT_SYMLINK_FOLLOW
#undef AT_SYMLINK_FOLLOW
#endif
#define AT_SYMLINK_FOLLOW 2

#ifdef AT_EACCESS
#undef AT_EACCESS
#endif
#define AT_EACCESS 4

#ifdef O_BINARY
#undef O_BINARY
#endif
#define O_BINARY 0

#ifdef O_CLOEXEC
#undef O_CLOEXEC
#endif
#define O_CLOEXEC 0

#ifdef O_DIRECT
#undef O_DIRECT
#endif
#define O_DIRECT 0

#ifdef O_DIRECTORY
#undef O_DIRECTORY
#endif
#define O_DIRECTORY 0

#ifdef O_NOATIME
#undef O_NOATIME
#endif
#define O_NOATIME 0

#ifdef O_NOFOLLOW
#undef O_NOFOLLOW
#endif
#define O_NOFOLLOW 0

#ifdef O_NOLINKS
#undef O_NOLINKS
#endif
#define O_NOLINKS 0

#ifdef O_RSYNC
#undef O_RSYNC
#endif
#define O_RSYNC 0

#ifdef HAVE_WORKING_O_NOFOLLOW
#undef HAVE_WORKING_O_NOFOLLOW
#endif
#define HAVE_WORKING_O_NOFOLLOW 0

#ifdef GNULIB_defined_F_DUPFD_CLOEXEC
#undef GNULIB_defined_F_DUPFD_CLOEXEC
#endif
#define GNULIB_defined_F_DUPFD_CLOEXEC 0

#ifdef O_TEXT
#undef O_TEXT
#endif
#define O_TEXT 0

#ifdef O_SEARCH
#undef O_SEARCH
#endif
#define O_SEARCH O_RDONLY

#ifdef F_DUPFD_CLOEXEC
#undef F_DUPFD_CLOEXEC
#endif
#define F_DUPFD_CLOEXEC 0x40000000

/* O_DSYNC added with VMS 8.4 */
#ifndef O_DSYNC
#define O_DSYNC 0
#endif
#if __CRTL_VER <= 80300000
/* disable non-functional definition */
#ifdef O_SYNC
#undef O_SYNC
#define O_SYNC 0
#endif
#endif

#define fcntl rpl_fcntl
int rpl_fcntl (int fd, int action, /* arg */...);
