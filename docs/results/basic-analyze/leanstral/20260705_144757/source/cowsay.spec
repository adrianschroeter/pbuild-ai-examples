#
# spec file for package cowsay
#
# Copyright (c) 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           cowsay
Version:        3.0.3
Release:        0
License:       	GPL-1.0+ or Artistic-1.0
Group:          Amusements/Toys/Other
Summary:        Configurable talking cow (and some other creatures)
Url:            http://nog.net/~tony/warez/
Source:         %{name}-%{version}.tar.gz

Requires:       perl
BuildRequires:  bash
BuildArch:      noarch

%description
cowsay is a configurable talking cow, written in Perl.  It operates
much as the figlet program does, and it written in the same spirit
of silliness.

%prep
%setup -q
sed -i "s|,\$%{nil}PREFIX,|,%{_prefix},|" install.sh

%build
# Nothing to build.

%install
bash ./install.sh %{buildroot}%{_prefix}
mv -T %{buildroot}%{_prefix}/man/ %{buildroot}%{_mandir}
rm -f %{buildroot}%{_datadir}/cows/mech-and-cow

%files
%defattr(-,root,root)
%doc ChangeLog LICENSE MANIFEST README
%{_bindir}/%{name}
%{_bindir}/cowthink
%{_datadir}/cows
%{_mandir}/man1/*

%changelog
