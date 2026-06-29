#
# spec file for package python-pyowm
#
# Copyright (c) 2019 SUSE LINUX GmbH, Nuernberg, Germany.
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

Name:           python-adb-shell
Version:        0.4.3
Release:        0
Summary:        A Python wrapper for adb shell
License:        Apache-2.0
Group:          SomeGroup
URL:            https://pypi.org/project/adb-shell
Source:         adb_shell-%{version}.tar.gz
BuildRequires:  fdupes
BuildRequires:  python-rpm-macros
BuildRoot: /tmp/old
Requires:  python-aiofiles >= 0.4.0
Requires:  python-cryptography
Requires:  python-pyasn1
Requires:  python-rsa
BuildArch:      noarch
%python_subpackages

%description
python adb-shell, it originates from

 https://github.com/google/python-adb/tree/master/adb

%prep
%setup -q -n adb-shell-%{version}

%build
%python_build

%install
%python_install
%python_expand %fdupes %{buildroot}%{$python_sitelib}

%files %{python_files}
%doc README.rst
/does/not/exist

