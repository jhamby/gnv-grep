/* File: vms_ttyname_hack.h
 *
 * ttyname fixup implemented for coreutils.
 *
 * The VMS ttyname() returns a VMS format path instead of Unix.
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
 */

#define __POSIX_TTYNAME 1
#include <unistd.h>

static char vms_ttyname_device[64];

static char * vms_ttyname(int fd) {

    char * retname;
    int ret_len;
    retname = ttyname(fd);

    /* If this failed were done */
    if (retname == NULL) {
        return retname;
    }
    /* If the bug is not present, we are done */
    if (retname[0] == '/') {
        return retname;
    }
    ret_len = strlen(retname);
    vms_ttyname_device[0] = '/';
    strcpy(&vms_ttyname_device[1], retname);
    if (vms_ttyname_device[ret_len] = ':') {
        vms_ttyname_device[ret_len] = 0;
    }
    return vms_ttyname_device;
}

#define ttyname vms_ttyname
