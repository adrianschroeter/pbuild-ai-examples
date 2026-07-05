#
# spec file for package gawk (Version 5.4.0)
#
# Copyright (c) 2006 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           gawk
URL:            http://www.gnu.org/software/gawk/
License:        GPL, Other License(s), see package
Group:          Productivity/Text/Utilities
Provides:       awk
Autoreqprov:    on
PreReq:         %{install_info_prereq}
Version:        5.4.0
Release:        24
Summary:        GNU awk
Source:         gawk-%{version}.tar.xz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
GNU awk is upwardly compatible with the System V Release 4 awk.  It is
almost completely POSIX 1003.2 compliant.



Authors:
--------
    David Trueman <david@cs.dal.ca>
    Arnold Robbins <arnold@skeeve.com>
    Michal Jaegermann <michal@gorte.phys.ualberta.ca>
    Scott Deifik <scottd@amgen.com>
    Darrel Hankerson <hankedr@mail.auburn.edu>
    Kai Uwe Rommel <rommel@ars.de>
    Pat Rankin <rankin@eql.caltech.edu>

%prep
%autosetup

%build
%{suse_update_config -f}
autoreconf --force --install
export CFLAGS=$RPM_OPT_FLAGS
./configure --prefix=/usr --libexecdir=%{_libdir} \
	    --mandir=%{_mandir} --infodir=%{_infodir}
%if %do_profiling
  make %{?jobs:-j%jobs} CFLAGS="$CFLAGS %cflags_profile_generate"
  make check
  make clean
  make %{?jobs:-j%jobs} CFLAGS="$CFLAGS %cflags_profile_feedback"
%else
  make %{?jobs:-j%jobs}
%endif
make check

%install
make install DESTDIR=$RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/bin
mv -f $RPM_BUILD_ROOT/usr/bin/awk $RPM_BUILD_ROOT/usr/bin/gawk \
      $RPM_BUILD_ROOT/bin
ln -sf ../../bin/awk ../../bin/gawk $RPM_BUILD_ROOT/usr/bin
ln -sf gawk.1 $RPM_BUILD_ROOT%{_mandir}/man1/awk.1
rm -f $RPM_BUILD_ROOT/usr/bin/*-%{version}

%clean
rm -rf $RPM_BUILD_ROOT

%post
%install_info --info-dir=%{_infodir} %{_infodir}/gawk.info.gz
%install_info --info-dir=%{_infodir} %{_infodir}/gawkinet.info.gz

%postun
%install_info_delete --info-dir=%{_infodir} %{_infodir}/gawk.info.gz
%install_info_delete --info-dir=%{_infodir} %{_infodir}/gawkinet.info.gz

%files
%defattr(-,root,root)
%doc AUTHORS COPYING FUTURES LIMITATIONS NEWS POSIX.STD PROBLEMS
%doc README README_d
/bin/awk
/bin/gawk
/usr/bin/awk
/usr/bin/gawk
/usr/bin/igawk
/usr/bin/pgawk
%dir %{_libdir}/awk
%{_libdir}/awk/grcat
%{_libdir}/awk/pwcat
%dir /usr/share/awk
/usr/share/awk/*.awk
/usr/share/locale/*/LC_MESSAGES/*.mo
%doc %{_infodir}/*.info.gz
%doc %{_mandir}/man1/*.1.gz

%changelog -n gawk
* Fri Sep 01 2006 - schwab@suse.de
- Drop doc subpackage.
* Mon Jul 24 2006 - schwab@suse.de
- Add multibyte patch.
* Wed Jul 05 2006 - schwab@suse.de
- Fix conversion error.
* Tue Jul 04 2006 - schwab@suse.de
- New version of last change.
* Sun Jun 18 2006 - schwab@suse.de
- Properly handle /dev/fd.
* Sat Mar 04 2006 - schwab@suse.de
- Add two wide string bug fixes.
* Thu Feb 09 2006 - schwab@suse.de
- Fix dfa generation of interval expressions [#148453].
* Thu Jan 26 2006 - schwab@suse.de
- Use %%jobs.
* Wed Jan 25 2006 - mls@suse.de
- converted neededforbuild to BuildRequires
* Wed Nov 30 2005 - schwab@suse.de
- Fix length on strings with embedded NUL.
* Fri Oct 07 2005 - schwab@suse.de
- Fix off-by-one when processing FIELDWIDTHS.
* Fri Sep 02 2005 - schwab@suse.de
- Update to gaw 3.1.5.
* Wed May 25 2005 - schwab@suse.de
- Update flonum parsing patch.
* Sat Feb 12 2005 - schwab@suse.de
- Add libpng to neededforbuild.
* Wed Feb 02 2005 - schwab@suse.de
- Ignore exit code from pipes.
* Tue Sep 28 2004 - schwab@suse.de
- Fix parsing of floating point number that start with more than one
  zero.
* Sun Sep 19 2004 - schwab@suse.de
- Disable invalid shortcut in dfaexec [#44512].
- Fix reading past EOF.
* Mon Aug 23 2004 - schwab@suse.de
- Update to gawk 3.1.4.
* Fri Aug 06 2004 - schwab@suse.de
- Use random from glibc [#43568].
* Thu Aug 05 2004 - schwab@suse.de
- Update to gawk 3.1.3l.
* Thu Jul 22 2004 - schwab@suse.de
- Fix int/long mismatch.
* Mon Apr 05 2004 - schwab@suse.de
- Disable non-POSIX strtod replacement [#38332].
* Fri Mar 12 2004 - schwab@suse.de
- Fix doc bug.
* Sat Jan 10 2004 - adrian@suse.de
- do not strip during install, let rpm do it
* Wed Jul 09 2003 - schwab@suse.de
- Update to gawk 3.1.3.
* Thu Jun 05 2003 - jh@suse.de
- Enable profile feedback
* Tue May 13 2003 - schwab@suse.de
- Add %%defattr.
- Fix file list.
* Thu Apr 24 2003 - ro@suse.de
- fix install_info --delete call and move from preun to postun
* Mon Apr 07 2003 - schwab@suse.de
- Only delete info entries when removing last version.
* Thu Mar 27 2003 - schwab@suse.de
- Update to gawk 3.1.2.
* Fri Feb 07 2003 - schwab@suse.de
- Fix spec file.
* Thu Feb 06 2003 - schwab@suse.de
- Use %%install_info.
* Mon Nov 18 2002 - schwab@suse.de
- Add AM_GNU_GETTEXT_VERSION.
* Tue Sep 17 2002 - ro@suse.de
- removed bogus self-provides
* Mon Aug 05 2002 - schwab@suse.de
- Add fix for gsub.
* Mon Jul 29 2002 - schwab@suse.de
- Fix broken patch.
* Thu Jul 18 2002 - schwab@suse.de
- Add lint check for delete.
* Tue May 14 2002 - schwab@suse.de
- Add fix for memory leak in loops.
- Add fix for side effects in split().
* Fri May 10 2002 - schwab@suse.de
- Update to gawk-3.1.1 (bugfix release).
* Tue Apr 09 2002 - schwab@suse.de
- Fix default AWKPATH.
* Sat Mar 30 2002 - schwab@suse.de
- Fix for new gettext.
* Sun Mar 17 2002 - schwab@suse.de
- Fix buffer overflow.
* Mon Feb 18 2002 - schwab@suse.de
- Workaround spurious limitation in regex matcher.
- Fix bogus assertion in strtonum.
* Mon Jan 28 2002 - schwab@suse.de
- Add i18n patch.
* Fri Jan 11 2002 - schwab@suse.de
- Two more patches from the author:
  * Fix use of getgroups
  * Fix grammer in for statement.
* Fri Nov 30 2001 - schwab@suse.de
- Replace overrun patch with a better one.
- Fix provides.
* Mon Nov 26 2001 - schwab@suse.de
- Use regex from libc again.
* Wed Nov 07 2001 - schwab@suse.de
- Fix memory overrun.
* Mon Nov 05 2001 - schwab@suse.de
- Fix lint checking and off-by-one error for printf.
* Fri Oct 05 2001 - schwab@suse.de
- Fix for memory corruption bug from author.
* Tue Sep 25 2001 - schwab@suse.de
- Don't set close-on-exec on standard fd (from author).
* Thu Aug 23 2001 - schwab@suse.de
- Fix for unary minus operator from author.
* Wed Aug 08 2001 - schwab@suse.de
- Fix for memory leak from author.
* Wed Jul 25 2001 - schwab@suse.de
- Fix for empty RS and and blank input from author.
* Mon Jul 16 2001 - schwab@suse.de
- Fix for index(foo, "") from author.
* Wed Jun 13 2001 - schwab@suse.de
- Include fix for allocation bug from author.
* Mon Jun 04 2001 - schwab@suse.de
- Update to 3.1.0.
* Sun May 13 2001 - schwab@suse.de
- Use included regex.c (#7953).
* Wed May 09 2001 - cstein@suse.de
- repacked sources with bzip2.
* Thu Apr 12 2001 - schwab@suse.de
- Add patch for \<\> from author.
* Tue Mar 20 2001 - schwab@suse.de
- Add parser patch from author.
* Thu Mar 08 2001 - schwab@suse.de
- Add two patches from author.
* Tue Oct 24 2000 - schwab@suse.de
- Rename subpackage gawkdoc to gawk-doc.
* Thu Sep 14 2000 - schwab@suse.de
- Add FIELDWIDTHS bug fix from arnold@skeeve.com.
* Tue Aug 08 2000 - schwab@suse.de
- Update to 3.0.6.
* Fri Jun 30 2000 - schwab@suse.de
- Fix handling of array indexes.
* Tue Jun 27 2000 - schwab@suse.de
- Update to 3.0.5.
* Tue May 09 2000 - schwab@suse.de
- Fix symlinks.
* Mon May 08 2000 - schwab@suse.de
- Switch to BuildRoot.
- Move /usr/bin/{,g}awk to /bin.
* Fri Apr 07 2000 - bk@suse.de
- added suse autoconf update macro
* Tue Apr 04 2000 - schwab@suse.de
- Fix IGNORECASE bug.
* Fri Mar 31 2000 - schwab@suse.de
- Include more docs.
* Tue Feb 15 2000 - schwab@suse.de
- Fix parser bug.
* Tue Feb 15 2000 - schwab@suse.de
- Update config{guess,sub} to latest version.
* Tue Jan 18 2000 - schwab@suse.de
- /usr/{info,man} -> /usr/share/{info,man}
* Mon Sep 13 1999 - bs@suse.de
- ran old prepare_spec on spec file to switch to new prepare_spec.
* Fri Aug 27 1999 - schwab@suse.de
- specfile cleanup
- run "make check"
- use regex from libc
* Mon Jul 19 1999 - florian@suse.de
- update to gawk 3.0.4
* Thu Dec 10 1998 - florian@suse.de
- egcs miscompiles gawk, use gcc instead
* Fri Jul 17 1998 - werner@suse.de
- Use mktemp for igawk
* Wed May 13 1998 - ro@suse.de
- used dif from jurix-mirror (date Mar 7 1998)
- some of the patches from gnu.utils.bug are still buggy. applied some new
  patches from the author Aharon Robbins to field.c.
* Mon Mar 02 1998 - florian@suse.de
- use a complete new patchkit from various bug-reports
  to gnu.utils.bug
* Wed Feb 04 1998 - ro@suse.de
- build gawkdoc from same specfile
* Thu Oct 09 1997 - florian@suse.de
- prepare for autobuild
* Fri Jul 18 1997 - florian@suse.de
- add bug-fixes from gnu.utils.bug
- add several patches from gnu.utils.bug
- gawk should work with c-news again
* Tue May 20 1997 - florian@suse.de
- update to version 3.0.3
* Sun Apr 13 1997 - florian@suse.de
- add bug-fixes from gnu.utils.bugs
- do not use /usr/libexec anymore
* Wed Jan 22 1997 - florian@suse.de
- update to version 3.0.2
