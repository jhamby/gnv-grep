/* File: vms_lstat_hack.h
 *
 * This module puts a wrapper around the lstat() to detect and attempt
 * to work around an issue where lstat() on VMS 8.4 is not handling
 * dangling symbolic links.
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
 */

#define chdir hide_chdir
#define getcwd decc$getcwd
#define delete hide_delete  /* delete() not used but conflicts with tr.c */

#include <stat.h>
#include <stdlib.h>
#include <unixlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <unixio.h>
#undef lstat
#undef unlink
#undef readlink
#undef chdir
#undef getcwd
#undef delete

int decc$chdir(const char *__dir_spec, ...);

static int vms_lstat(const char * name, struct stat * st) {
    int result;
    int pcp_mode;
    int pathlen;
    char * newpath;

    /* First check for ".dir" bug */
    pathlen = strlen(name);
    if (pathlen > 4) {
        int i, cmp;
        i = pathlen - 4;
        cmp = strcasecmp(".dir", &name[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, name);
            strcat(newpath, "/.");
            result = lstat(newpath, st);
            free(newpath);
            if (result == 0) {
                return result;
            }
        }
    }
    /* Then for normal bugs seen */
    /* lstat not handling relative link to self or some directories */
    result = lstat(name, st);
    if ((result >= 0) && (!S_ISDIR(st->st_mode))) {
        return result;
    }
    /* Error?  May be a bug so try again */

    /* Save the PCP mode */
    pcp_mode = decc$feature_get("DECC$POSIX_COMPLIANT_PATHNAMES",
                                __FEATURE_MODE_CURVAL);

    /* Already non-zero, nothing to fix up */
    if (pcp_mode != 0) {
        return result;
    }

    /* Work around for bug in VMS 8.3/8.4 */
    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL, 2);
    result = lstat(name, st);

    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL,
                      pcp_mode);
    return result;
}

static int vms_stat(const char * name, struct stat * st) {
    int result;
    int pathlen;

    /* First check for ".dir" bug */
    pathlen = strlen(name);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &name[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, name);
            strcat(newpath, "/.");
            result = stat(newpath, st);
            free(newpath);
            if (result == 0) {
                return result;
            }
        }
    }

    result = stat(name, st);
    return result;
}

static int vms_unlink(const char * name) {
    int result;
    int pcp_mode;
    int pathlen;

    /* First check for ".dir" bug */
    pathlen = strlen(name);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &name[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, name);
            strcat(newpath, "/.");
            result = unlink(newpath);
            free(newpath);
            if (result == 0) {
                return result;
            }
        }
    }

    result = unlink(name);
    if (result >= 0) {
        return result;
    }
    /* Error?  May be a bug so try again */

    /* Save the PCP mode */
    pcp_mode = decc$feature_get("DECC$POSIX_COMPLIANT_PATHNAMES",
                                __FEATURE_MODE_CURVAL);

    /* Already non-zero, nothing to fix up */
    if (pcp_mode != 0) {
        return result;
    }

    /* Work around for bug in VMS 8.3/8.4 */
    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL, 2);
    result = unlink(name);

    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL,
                      pcp_mode);
    return result;
}

static int vms_readlink(const char * path, char *buf, size_t bufsize) {
    int result;
    int pcp_mode;

    result = readlink(path, buf, bufsize);
    if (result >= 0) {
        return result;
    }
    /* Error?  May be a bug so try again */

    /* Save the PCP mode */
    pcp_mode = decc$feature_get("DECC$POSIX_COMPLIANT_PATHNAMES",
                                __FEATURE_MODE_CURVAL);

    /* Already non-zero, nothing to fix up */
    if (pcp_mode != 0) {
        return result;
    }

    /* Work around for bug in VMS 8.3/8.4 */
    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL, 2);

    result = readlink(path, buf, bufsize);

    decc$feature_set("DECC$POSIX_COMPLIANT_PATHNAMES",
                      __FEATURE_MODE_CURVAL,
                      pcp_mode);
    return result;
}

static int vms_access(const char * file, int mode) {
    int result;
    int pathlen;

    pathlen = strlen(file);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &file[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, file);
            strcat(newpath, "/.");
            result = access(newpath, mode);
            free(newpath);
            if (result == 0) {
                return result;
            }
            if ((result == -1) && (errno != ENOENT)) {
                return result;
            }
        }
    }

    result = access(file, mode);
    return result;
}

static int vms_chdir(const char * file) {
    int result;
    int pathlen;

    pathlen = strlen(file);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &file[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, file);
            strcat(newpath, "/.");
            result = decc$chdir(newpath);
            free(newpath);
            return result;
        }
    }

    result = decc$chdir(file);
    return result;
}

static int vms_mkdir(const char * file, mode_t mode) {
    int result;
    int pathlen;

    pathlen = strlen(file);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &file[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, file);
            strcat(newpath, "/.");
            result = mkdir(newpath, mode);
            free(newpath);
            return result;
        }
    }

    result = mkdir(file, mode);
    return result;
}

static int vms_rmdir(const char * file) {
    int result;
    int pathlen;

    pathlen = strlen(file);
    if (pathlen > 4) {
        int i, cmp;
        char * newpath;

        i = pathlen - 4;
        cmp = strcasecmp(".dir", &file[i]);
        if (cmp == 0) {
            newpath = malloc(pathlen + 2);
            strcpy(newpath, file);
            strcat(newpath, "/.");
            result = rmdir(newpath);
            free(newpath);
            return result;
        }
    }

    result = rmdir(file);
    return result;
}


#define stat(file, buf) vms_stat(file, buf)
#define lstat vms_lstat
#define unlink vms_unlink
#define remove vms_unlink
#define readlink vms_readlink
#define access vms_access
#define chdir vms_chdir
#define mkdir vms_mkdir
#define rmdir vms_rmdir
