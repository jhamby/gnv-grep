#ifndef __VMS_GREP_HACKS_H__
#define __VMS_GREP_HACKS_H__

#ifdef GNULIB_CLOSE_STREAM
#undef GNULIB_CLOSE_STREAM
#endif
#define GNULIB_CLOSE_STREAM 1

#ifdef GNULIB_DIRENT_SAFER
#undef GNULIB_DIRENT_SAFER
#endif
#define GNULIB_DIRENT_SAFER 1

#ifdef GNULIB_FDOPENDIR
#undef GNULIB_FDOPENDIR
#endif
#define GNULIB_FDOPENDIR 1

#ifdef GNULIB_FSCANF
#undef GNULIB_FSCANF
#endif
#define GNULIB_FD_SAFER_FLAG IN_GREP_GNULIB_TESTS

#ifdef GNULIB_FSCANF
#undef GNULIB_FSCANF
#endif
#define GNULIB_FSCANF 1

#ifdef GNULIB_LOCK
#undef GNULIB_LOCK
#endif
#define GNULIB_LOCK 1

#ifndef GNULIB_MALLOC_GNU
#define GNULIB_MALLOC_GNU 1
#endif

#ifndef GNULIB_OPENAT_SAFER
#define GNULIB_OPENAT_SAFER 1
#endif

#ifdef GNULIB_REALLOC_GNU
#undef GNULIB_REALLOC_GNU
#endif
#define GNULIB_REALLOC_GNU 1

#ifdef GNULIB_SCANF
#undef GNULIB_SCANF
#endif
#define GNULIB_SCANF 1

#ifdef GNULIB_SNPRINTF
#undef GNULIB_SNPRINTF
#endif
#define GNULIB_SNPRINTF IN_GREP_GNULIB_TESTS

#ifdef GNULIB_STRERROR
#undef GNULIB_STRERROR
#endif
#define GNULIB_STRERROR 1

#define GNULIB_TEST_BTOWC 1
#define GNULIB_TEST_CHDIR 1
#define GNULIB_TEST_CLOEXEC 1
#define GNULIB_TEST_CLOSE 1
#define GNULIB_TEST_CLOSEDIR 1
#define GNULIB_TEST_DIRFD 1
#define GNULIB_TEST_DUP 1
#define GNULIB_TEST_DUP2 1
#define GNULIB_TEST_ENVIRON 1
#define GNULIB_TEST_FCHDIR 1
#define GNULIB_TEST_FCNTL 1
#define GNULIB_TEST_FDOPEN 1
#define GNULIB_TEST_FDOPENDIR 1
#define GNULIB_TEST_FSTAT 1
#define GNULIB_TEST_FSTATAT 1
#define GNULIB_TEST_GETCWD 1
#define GNULIB_TEST_GETDTABLESIZE 1
#define GNULIB_TEST_GETOPT_GNU 1
#define GNULIB_TEST_GETPAGESIZE 1
#define GNULIB_TEST_GETTIMEOFDAY 1
#define GNULIB_TEST_ISATTY 1
#define GNULIB_TEST_ISWBLANK 1
#define GNULIB_TEST_ISWCTYPE 1
#define GNULIB_TEST_LOCALECONV 1
#define GNULIB_TEST_LSEEK 1
#define GNULIB_TEST_LSTAT 1
#define GNULIB_TEST_MALLOC_POSIX 1
#define GNULIB_TEST_MBRLEN 1
#define GNULIB_TEST_MBRTOWC 1
#define GNULIB_TEST_MBSCASECMP 1
#define GNULIB_TEST_MBSINIT 1
#define GNULIB_TEST_MBSLEN 1
#define GNULIB_TEST_MBSRTOWCS 1
#define GNULIB_TEST_MBSSTR 1
#define GNULIB_TEST_MBTOWC 1
#define GNULIB_TEST_MEMCHR 1
#define GNULIB_TEST_MEMPCPY 1
#define GNULIB_TEST_MEMRCHR 1
#define GNULIB_TEST_NL_LANGINFO 1
#define GNULIB_TEST_OPEN 1
#define GNULIB_TEST_OPENAT 1
#define GNULIB_TEST_OPENDIR 1
#define GNULIB_TEST_PIPE 1
#define GNULIB_TEST_PUTENV 1
#define GNULIB_TEST_READ 1
#define GNULIB_TEST_READDIR 1
#define GNULIB_TEST_REALLOC_POSIX 1
#define GNULIB_TEST_SETENV 1
#define GNULIB_TEST_SETLOCALE 1
#define GNULIB_TEST_SNPRINTF 1
#define GNULIB_TEST_STAT 1
#define GNULIB_TEST_STPCPY 1
#define GNULIB_TEST_STRDUP 1
#define GNULIB_TEST_STRERROR 1
#define GNULIB_TEST_STRNLEN 1
#define GNULIB_TEST_STRTOLL 1
#define GNULIB_TEST_STRTOULL 1
#define GNULIB_TEST_SYMLINK 1
#define GNULIB_TEST_UNSETENV 1
#define GNULIB_TEST_WCRTOMB 1
#define GNULIB_TEST_WCTOB 1
#define GNULIB_TEST_WCTOMB 1
#define GNULIB_TEST_WCWIDTH 1

#define __GETOPT_PREFIX rpl_

#define re_comp rpl_re_comp
#define re_compile_fastmap rpl_re_compile_fastmap
#define re_compile_pattern rpl_re_compile_pattern
#define re_exec rpl_re_exec
#define re_match rpl_re_match
#define re_match_2 rpl_re_match_2
#define re_search rpl_re_search
#define re_search_2 rpl_re_search_2
#define re_set_registers rpl_re_set_registers
#define re_set_syntax rpl_re_set_syntax
#define re_syntax_options rpl_re_syntax_options

#define _REGEX_INCLUDE_LIMITS_H 1
#define _REGEX_LARGE_OFFSETS 1
#define _GNU_SOURCE 1
#define _POSIX_PTHREAD_SEMANTICS 1

#define HAVE_WORKING_O_NOATIME 1
#define HAVE_WORKING_O_NOFOLLOW 1

#ifndef HAVE_DECL_STRERROR_R
#define HAVE_DECL_STRERROR_R (0)
#endif

#define gl_va_copy(a,b) ((a) = (b))
#define va_copy gl_va_copy

/* from lib/stdio.in.h */
#define _GL_ATTRIBUTE_FORMAT_PRINTF(formatstring_parameter, first_argument) \
   _GL_ATTRIBUTE_FORMAT ((__printf__, formatstring_parameter, first_argument))

#ifndef uintmax_t
#ifdef __VAX
#define uintmax_t unsigned long
#else
#define uintmax_t unsigned long long
#endif
#endif

#ifndef PROMOTED_MODE_T
#define PROMOTED_MODE_T int
#endif

#define _GL_ARG_NONNULL(params)
#define _GL_UNUSED_PARAMETER
#ifdef _GL_INLINE
#undef _GL_INLINE
#endif
#define _GL_INLINE static inline

#ifndef S_TYPEISSHM
#define S_TYPEISSHM(p) (0)
#endif

#ifndef S_TYPEISTMO
#define S_TYPEISTMO(p) (0)
#endif

#ifndef S_TYPEISMQ
#define S_TYPEISMQ(p) (0)
#endif

#ifndef S_TYPEISSEM
#define S_TYPEISSEM(p) (0)
#endif

#ifdef PRI_MACROS_BROKEN
#undef PRI_MACROS_BROKEN
#endif
#define PRI_MACROS_BROKEN 0

#define PRIuMAX "llu"
#define PRIdMAX "lld"
#define PRIoMAX "llo"
#define PRIxMAX "llx"

#include <types.h>
void * memrchr (void const *s, int c_in, size_t n);
size_t mbslen (const char *string);
char * mbsstr (const char *haystack, const char *needle);
int mbscasecmp (const char *s1, const char *s2);
#pragma message disable notincrtl
long long strtoimax (char const *ptr, char **endptr, int base);

#define __UNIX_PUTC

/* #pragma message disable promotmatchw */

/* #pragma message disable questcompare */

/* #pragma message disable ptrmismatch1 */

#include <stat.h>
int fstatat(int fd, char const *file, struct stat *st, int flag);

/* Needed for openat-safer.c */
int openat (int fd, char const *file, int flags, ...);

void *
mempcpy (void *dest, const void *src, size_t n);

#ifdef __VAX
/* #pragma message disable longdoublenyi */
#define lstat stat
#endif

static int isblank(int ch) {
    return ((ch == ' ') || (ch == '\t'));
}

#include <dirent.h>
int vms_open(const char *file_spec, int flags, ...);
DIR * vms_fdopendir(int fd);
int vms_close(int fd);
int vms_dirfd(DIR * dirp);
int vms_dup(int fd1);
int vms_dup2(int fd1, int fd2);
int vms_closedir(DIR * dirp);
int vms_fstat(int __fd, struct stat * stbuf);
int vms_fchdir(int fd);

DIR * vms_opendir(const char * name);

#define opendir vms_opendir
#define opendir_safer vms_opendir

#define open vms_open
#define open_safer vms_open
#define fdopendir(__fd) vms_fdopendir(__fd)
#define dirfd(__dirp) vms_dirfd(__dirp)
#define close(__fd) vms_close(__fd)
#define dup(__fd1) vms_dup(__fd1)
#define dup_safer(__fd1) vms_dup(__fd1)
#define dup2(__fd1, __fd2) vms_dup2(__fd1, __fd2)
#define closedir(__dirp) vms_closedir(__dirp)
#define fstat(__fd, __stbuf) vms_fstat(__fd, __stbuf)
#define fchdir(__fd) vms_fchdir(__fd)
#define fdopendir(__fd) vms_fdopendir(__fd)
#define fchdir(__fd) vms_fchdir(__fd)

#include <stdio.h>
#if 0
static _Bool vms_fwriting(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    return (stream->_flag & _IOWRT) != 0;
}
#define fwriting vms_fwriting
#endif

/* fpending.c needs this */
/* fpending.m4 suggests '{*fp)->_ptr - (*fp)->_base' for VMS. */
#ifdef PENDING_OUTPUT_N_BYTES
#undef PENDING_OUTPUT_N_BYTES
#endif
#define PENDING_OUTPUT_N_BYTES vms_pending_output_n_bytes(fp)

static int vms_pending_output_n_bytes(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    return stream->_ptr - stream->_base;
}

/* same-inode.h has VMS specific hack that is now wrong. */
/* Disable the header file if it is not needed. */
#ifdef _USE_STD_STAT
#define SAME_INODE_H 1
#  define SAME_INODE(a, b)    \
    ((a).st_ino == (b).st_ino \
     && (a).st_dev == (b).st_dev)
#endif

/* VAX/VMS 7.3 does not have EOVERFLOW */
#include <errno.h>
#ifndef EOVERFLOW
#define EOVERFLOW EIO
#endif

/* Missing from fcntl.h */
#include "vms_fcntl_hacks.h"

#include "vms_pwd_hack.h"

/* Fix up the argv[0] program name to be like Unix */
#ifdef MOD_MAIN
#include "vms_main_wrapper.c"

/* main() in main.c missing the return. */
#pragma message disable missingreturn
#endif


#ifndef INTMAX_MAX
#ifndef __VAX
#define INTMAX_MAX __INT64_MAX
#else
#define INTMAX_MAX __INT32_MAX
#endif
#endif
#ifndef INTMAX_MIN
#ifndef __VAX
#define INTMAX_MIN __INT64_MIN
#else
#define INTMAX_MIN __INT32_MIN
#endif
#endif
#ifndef SIZE_MAX
#define SIZE_MAX __INT32_MAX
#endif

#endif /* __VMS_GREP_HACKS_H__ */
