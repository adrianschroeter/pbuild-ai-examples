#
# spec file for package phpstan
#
# Copyright (c) 2026 SUSE LLC and contributors
# See LICENSE file in the source distribution for details
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


Name:           phpstan
Version:        1.10.0
Release:        0
Summary:        PHP Static Analysis Tool
License:        MIT
URL:            https://phpstan.org/
Source0:        https://github.com/phpstan/phpstan/archive/refs/tags/%{version}.tar.gz

BuildArch:      noarch

Requires:       php >= 7.2

%description
PHPStan focuses on finding errors in your code without actually running it. It catches whole classes of bugs
even before you write tests for the code. It moves PHP closer to compiled languages in the sense that the correctness of each line of the code
can be checked before you run the actual line.

%prep
%setup -q -n %{name}-%{version}

%build
# No build required for PHAR-based distribution

%install
# Install the phpstan.phar as executable binary
install -Dpm 0755 %{name}.phar %{buildroot}%{_bindir}/phpstan

%files
%defattr(-, root, root)
%doc LICENSE README.md
%{_bindir}/phpstan

%changelog
