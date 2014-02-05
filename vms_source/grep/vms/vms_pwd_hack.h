/* File: vms_pwd_hack.h
 *
 * This module puts wrappers around the pwd.h related routines to add
 * the missing pw_passwd and pw_gecos members, and to have the shell
 * report correctly under GNV Bash
 *
 * The pw_gecos member corresponds to the owner UAF field.
 *
 * The pw_passwd member is set to a fake string as documented below.
 *
 * Copyright 2012, John Malmberg
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

/* First we have to hide the VMS supplied passwd structure
 * with a define, and pull in the original header.
 * This sets other defines to prevent the header from being loaded again.
 */
#pragma message save
#pragma message disable dollarid
#pragma message disable valuepres
#define passwd hide_passwd
#include <pwd.h>
#include <stdlib.h>
#undef passwd
#include <string.h>
#include <descrip.h>
#include <stsdef.h>
#include <lnmdef.h>
#include <unixlib.h>
#include <uaidef.h>
#include <efndef.h>

#ifdef __VAX
#define __passwd struct hide_passwd

#endif


/* Need a new struct passwd that has the pw_gecos and pw_passwd members */
#pragma member_alignment save
#pragma member_alignment
#if __INITIAL_POINTER_SIZE
#  pragma __pointer_size __save
#endif

#if __INITIAL_POINTER_SIZE
#  pragma __pointer_size 32
#endif

typedef struct vms_passwd {
   char *pw_name;
   __uid_t pw_uid;
   __gid_t pw_gid;
   char *pw_dir;
   char *pw_shell;
   char *pw_gecos;
   char *pw_passwd;
} VMS_PASSWD;

#pragma nomember_alignment longword
struct itmlst_3 {
  unsigned short int buflen;
  unsigned short int itmcode;
  void *bufadr;
  unsigned short int *retlen;
};

int   SYS$TRNLNM(
	const unsigned long * attr,
	const struct dsc$descriptor_s * table_dsc,
	struct dsc$descriptor_s * name_dsc,
	const unsigned char * acmode,
	const struct itmlst_3 * item_list);

#pragma message save
#pragma message disable noparmlist

int SYS$GETUAI
       (unsigned long efn,
        unsigned long * context,
        const struct dsc$descriptor_s * username,
        const struct itmlst_3 * itmlst,
        void * iosb,
        void (* astadr)(__unknown_params),
        void * astprm);

#pragma message restore


/* The getpw*() routine return a pointer to static storage */
static VMS_PASSWD vms__internal_passwd = {0};

/* We always set the pw_passwd member to a bad password.
 * The pw_passwed member needs to be a null terminated string.
 * More work is needed to support a fake crypt() function
 * based on the pw_name in the static storage.
 * In that case, the password would be initialize to a printable
 * hash that is unique for this account.
 * The fake crypt() function would return the same unique string
 * if the password given validates and the account is also valid.
 */
static const char vms__bad_password[] = "BAD PASSWORD$$$";

/* Need to cache what shell to report if we are overriding it */
static int vms__internal_passwd_shell_valid = -1;
static char vms__internal_passwd_shell[256] = {0};
#ifdef __VAX
static char vms__internal_passwd_dir[256] = {0};
#endif
/* First byte of internal owner is a count field */
static char vms__internal_owner[33] = {0};

/* Take all the fun out of simply looking up a logical name */
static int sys_trnlnm(const char * logname,
		      char * value,
		      int value_len) {
    const $DESCRIPTOR(table_dsc, "LNM$FILE_DEV");
    const unsigned long attr = LNM$M_CASE_BLIND;
    struct dsc$descriptor_s name_dsc;
    int status;
    unsigned short result;
    struct itmlst_3 itlst[2];

    itlst[0].buflen = value_len;
    itlst[0].itmcode = LNM$_STRING;
    itlst[0].bufadr = value;
    itlst[0].retlen = &result;

    itlst[1].buflen = 0;
    itlst[1].itmcode = 0;

    name_dsc.dsc$w_length = strlen(logname);
    name_dsc.dsc$a_pointer = (char *)logname;
    name_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
    name_dsc.dsc$b_class = DSC$K_CLASS_S;

    status = SYS$TRNLNM(&attr, &table_dsc, &name_dsc, 0, itlst);

    if ($VMS_STATUS_SUCCESS(status)) {

	 /* Null terminate and return the string */
	/*--------------------------------------*/
	value[result] = '\0';
    }

    return status;
}

/* Initialize if we are to replace the shell */
static void vms_init_passwd_shell_replace(void) {
int status;
    if (vms__internal_passwd_shell_valid == -1) {
	status = sys_trnlnm("GNV$UNIX_SHELL", vms__internal_passwd_shell, 255);
	if ($VMS_STATUS_SUCCESS(status)) {
	    vms__internal_passwd_shell_valid = 1;
	} else {
	    vms__internal_passwd_shell_valid = 0;
	}
    }
}

static void vms_get_uaf_owner(const char * name) {
    int status;
    struct dsc$descriptor_s name_dsc;
    struct itmlst_3 itlst[2];
    unsigned short owner_len;
    unsigned short uai_iosb[4];

    itlst[0].buflen = 32;
    itlst[0].itmcode = UAI$_OWNER;
    itlst[0].bufadr = vms__internal_owner;
    itlst[0].retlen = &owner_len;

    itlst[1].buflen = 0;
    itlst[1].itmcode = 0;

    name_dsc.dsc$w_length = strlen(name);
    name_dsc.dsc$a_pointer = (char *)name;
    name_dsc.dsc$b_dtype = DSC$K_DTYPE_T;
    name_dsc.dsc$b_class = DSC$K_CLASS_S;

    status = SYS$GETUAI(EFN$C_ENF, 0, &name_dsc, itlst, uai_iosb, NULL, 0);
    if ($VMS_STATUS_SUCCESS(status)) {
        vms__internal_owner[vms__internal_owner[0] + 1] = 0;
        return;
    }
    vms__internal_owner[0] = 0;
    vms__internal_owner[1] = 0;
}

/* Replacement routines, set up as static routines so that the compiler
 * can optimize inline when possible.
 */
static VMS_PASSWD * vms_getpwnam(const char * nam) {
__passwd * result;

   result = getpwnam(nam);
   if (result != NULL) {
	int status;
	vms_init_passwd_shell_replace();
	vms__internal_passwd.pw_name = result->pw_name;
	vms__internal_passwd.pw_uid = result->pw_uid;
	vms__internal_passwd.pw_gid = result->pw_gid;
	vms__internal_passwd.pw_dir = result->pw_dir;
#ifdef __VAX
	/* Home directory must be an absolute path */
	if (result->pw_dir[0] != '/') {
	    /* VMS file specification found */
	    char * new_path;
	    new_path = decc$translate_vms(result->pw_dir);
	    strncpy(vms__internal_passwd_dir, new_path, 255);
	    vms__internal_passwd_dir[255] = 0;
	    vms__internal_passwd.pw_dir = vms__internal_passwd_dir;
	}
#endif
	if (vms__internal_passwd_shell_valid == 1) {
	    vms__internal_passwd.pw_shell = vms__internal_passwd_shell;
	} else {
	    vms__internal_passwd.pw_shell = result->pw_shell;
	}

	/* set pw_gecos to the owner field of the SYSUAF record */
	vms_get_uaf_owner(result->pw_name);
	vms__internal_passwd.pw_gecos = &vms__internal_owner[1];
	vms__internal_passwd.pw_passwd = (char *)vms__bad_password;
	return &vms__internal_passwd;
   }
   else {
	return NULL;
   }
}

#ifndef __VAX
static int vms_getpwnam_r
   (const char * nam,
    struct vms_passwd * pwd,
    char * buffer,
    size_t bufsize,
    struct vms_passwd ** result)
{
int retval;
VMS_PASSWD * rslt;

   retval = getpwnam_r
	(nam, (__passwd *)pwd, buffer, bufsize, (__passwd**)result);
   if ((retval == 0) && (result != NULL)) {
	rslt = *result;
	rslt->pw_gecos = rslt->pw_name;
	rslt->pw_passwd = (char *)vms__bad_password;
	return 0;
   }
   else {
	return -1;
   }
}
#endif

static VMS_PASSWD * vms_getpwuid
   (uid_t id)
{
__passwd * result;
   result = getpwuid(id);
   if (result != NULL) {
	vms_init_passwd_shell_replace();
	vms__internal_passwd.pw_name = result->pw_name;
	vms__internal_passwd.pw_uid = result->pw_uid;
	vms__internal_passwd.pw_gid = result->pw_gid;
	vms__internal_passwd.pw_dir = result->pw_dir;
#ifdef __VAX
	/* Home directory must be an absolute path */
	if (result->pw_dir[0] != '/') {
	    /* VMS file specification found */
	    char * new_path;
	    new_path = decc$translate_vms(result->pw_dir);
	    strncpy(vms__internal_passwd_dir, new_path, 255);
	    vms__internal_passwd_dir[255] = 0;
	    vms__internal_passwd.pw_dir = vms__internal_passwd_dir;
	}
#endif
	if (vms__internal_passwd_shell_valid == 1) {
	    vms__internal_passwd.pw_shell = vms__internal_passwd_shell;
	} else {
	    vms__internal_passwd.pw_shell = result->pw_shell;
	}
	/* set pw_gecos to the owner field of the SYSUAF record */
	vms_get_uaf_owner(result->pw_name);
	vms__internal_passwd.pw_gecos = &vms__internal_owner[1];
	vms__internal_passwd.pw_passwd = (char *)vms__bad_password;
	return &vms__internal_passwd;
   }
   else {
	return NULL;
   }
}

#ifndef __VAX
static int vms_getpwuid_r
   (uid_t id, VMS_PASSWD *pwd, char * buffer,
    size_t bufsize, VMS_PASSWD **result)
{
int retval;
VMS_PASSWD *rslt;

   retval = getpwuid_r
     (id, (__passwd*)pwd, buffer, bufsize, (__passwd**)result);
   if ((retval == 0) && (result != NULL)) {
	rslt = *result;
	rslt->pw_gecos = rslt->pw_name;
	rslt->pw_passwd = (char *)vms__bad_password;
	return 0;
   }
   else {
	return -1;
   }
}
#endif

#ifdef __VAX
static void vms_endpwent(void) {}
#define endpwent vms_endpwent
#endif

#ifndef __VAX
static VMS_PASSWD * vms_getpwent
   (uid_t id)
{
__passwd * result;
   result = getpwent();
   if (result != NULL) {
	vms_init_passwd_shell_replace();
	vms__internal_passwd.pw_name = result->pw_name;
	vms__internal_passwd.pw_uid = result->pw_uid;
	vms__internal_passwd.pw_gid = result->pw_gid;
	vms__internal_passwd.pw_dir = result->pw_dir;
	if (vms__internal_passwd_shell_valid == 1) {
	    vms__internal_passwd.pw_shell = vms__internal_passwd_shell;
	} else {
	    vms__internal_passwd.pw_shell = result->pw_shell;
	}
	/* set pw_gecos to the owner field of the SYSUAF record */
	vms_get_uaf_owner(result->pw_name);
	vms__internal_passwd.pw_gecos = &vms__internal_owner[1];
	vms__internal_passwd.pw_passwd = (char *)vms__bad_password;
	return &vms__internal_passwd;
   }
   else {
	return NULL;
   }
}
#endif

#pragma member_alignment restore
#if __INITIAL_POINTER_SIZE
#  pragma __pointer_size __restore
#endif
#pragma message restore

/* Now make the replacement routines and structures visible */

#define passwd vms_passwd
#define getpwnam vms_getpwnam
#define getpwuid vms_getpwuid
#define getpwent vms_getpwent
#define getpwuid_r vms_getpwuid_r
#define getpwnam_r vms_getpwnam_r
