#
# spec file for package gawk
#
# Copyright (c) 2021 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           gawk
Version:        5.4.0
Release:        0
Summary:        Domain-specific language for text processing
License:        GPL-3.0-or-later
Group:          Productivity/Text/Utilities
URL:            https://www.gnu.org/software/gawk/
Source:         http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.xz
Source4:        gawk.rpmlintrc

BuildRequires:  mpfr-devel
BuildRequires:  readline-devel

%description
AWK is a domain-specific language designed for text processing and
typically used as a data extraction and reporting tool.

GNU awk is upwardly compatible with the System V Release 4 awk.  It is
almost completely POSIX 1003.2 compliant.

%prep
%autosetup

%build
%configure
%make_build

%check
%make_build check

%install
%make_install

# remove versioned gawk and create symlink for awk.1
rm -fv %{buildroot}%{_bindir}/*-%{version}
ln -sfv %{_mandir}/man1/gawk.1%{?ext_man} %{buildroot}%{_mandir}/man1/awk.1%{?ext_man}

%find_lang %{name}

%files -f %{name}.lang
%config %{_sysconfdir}/profile.d/gawk.csh
%config %{_sysconfdir}/profile.d/gawk.sh
%{_bindir}/*
%{_mandir}/man1/awk.1%{?ext_man}
%{_mandir}/man1/pm-gawk.1.gz*
%doc AUTHORS NEWS POSIX.STD README ChangeLog*
%{_infodir}/gawk_api-figure1.png
%{_infodir}/gawk_api-figure2.png
%{_infodir}/gawk_api-figure3.png
%{_infodir}/gawk_array-elements.png
%{_infodir}/gawk_general-program.png
%{_infodir}/gawk_process-flow.png
%{_infodir}/gawk_statist.jpg
%{_mandir}/man1/gawkbug.1.gz
%{_libexecdir}/awk
%{_libdir}/gawk
%{_datadir}/awk
%{_includedir}/gawkapi.h
%{_infodir}/*.info%{?ext_info}
%{_mandir}/man1/gawk.1%{?ext_man}
%{_mandir}/man3/*%{?ext_man}
