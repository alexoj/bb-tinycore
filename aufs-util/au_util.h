/*
 * Copyright (C) 2005-2015 Junjiro R. Okajima
 *
 * This program, aufs is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef __AUFS_UTIL_H__
#define __AUFS_UTIL_H__

#include <errno.h>

#ifdef __GNU_LIBRARY__
#include <error.h>
#endif

#define AuRelease	"20150928"
#ifdef AUFHSM
#define AuFhsmStr " with FHSM"
#else
#define AuFhsmStr ""
#endif
#define AuVersionGitBranch "aufs3.14 and later"
#define AuVersion "aufs-util for " AuVersionGitBranch AuFhsmStr " " AuRelease

/*
 * error_at_line() is decleared with (__printf__, 5, 6) attribute,
 * and our compiler produces a warning unless args is not given.
 * __VA_ARGS__ does not help the attribute.
 */
#define AuFin(fmt, ...) \
	error_at_line(errno, errno, __FILE__, __LINE__, fmt, ##__VA_ARGS__)

#ifdef DEBUG
#define MTab "/tmp/mtab"
#else
#define MTab "/etc/mtab"
#endif

/* perror.c */
extern int au_errno;
extern const char *au_errlist[];
void au_perror(const char *s);
#ifndef __GNU_LIBRARY__
/* musl libc has 'program_invocation_name', but doesn't have error_at_line() */
void error_at_line(int status, int errnum, const char *filename,
		   unsigned int linenum, const char *format, ...)
#endif

/* proc_mounts.c */
struct mntent;
int au_proc_getmntent(char *mntpnt, struct mntent *rent);

/* br.c */
union aufs_brinfo;
int au_br(union aufs_brinfo **brinfo, int *nbr, char *root);
#ifdef AUFHSM
int au_nfhsm(int nbr, union aufs_brinfo *brinfo);
int au_br_qsort_path(const void *_a, const void *_b);
void au_br_sort_path(int nbr, union aufs_brinfo *brinfo);
int au_br_bsearch_path(const void *_path, const void *_brinfo);
union aufs_brinfo *au_br_search_path(char *path, int nbr,
				     union aufs_brinfo *brinfo);
#endif

/* plink.c */
enum {
	AuPlink_FLUSH,
	AuPlink_CPUP,
	AuPlink_LIST
};
#define AuPlinkFlag_OPEN	1UL
#define AuPlinkFlag_CLOEXEC	(1UL << 1)
#define AuPlinkFlag_CLOSE	(1UL << 2)
int au_plink(char cwd[], int cmd, unsigned int flags, int *fd);

/* mtab.c */
void au_print_ent(struct mntent *ent);
int au_update_mtab(char *mntpnt, int do_remount, int do_verbose);

/* fhsm/fhsm.c */
#ifdef AUFHSM
void mng_fhsm(char *cwd, int unmount);
#else
static inline void mng_fhsm(char *cwd, int unmount)
{
	/* empty */
}
#endif

#define _Dpri(fmt, ...)		printf("%s:%d:" fmt, \
				       __func__, __LINE__, ##__VA_ARGS__)
#ifdef DEBUG
#define Dpri(fmt, ...)		_Dpri(fmt, ##__VA_ARGS__)
#else
#define Dpri(fmt, ...)		do { } while(0)
#endif

#endif /* __AUFS_UTIL_H__ */
