#
# spec file for package python-Glances
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


%{?!python_module:%define python_module() python-%{**} python3-%{**}}
Name:           python-Glances
Version:        3.1.0
Release:        0
Summary:        A cross-platform curses-based monitoring tool
License:        LGPL-3.0-only
Group:          Development/Languages/Python
URL:            https://github.com/nicolargo/glances
Source: v3.1.0.tar.gz
Source2:        glances-server.service
Patch0:         adjust-data-files.patch
Patch1:         remove-shebang.patch
BuildRequires:  %{python_module bottle}
BuildRequires:  %{python_module psutil >= 5.3.0}
BuildRequires:  %{python_module requests}
BuildRequires:  %{python_module setuptools}
BuildRequires:  fdupes
BuildRequires:  python-rpm-macros
BuildRequires:  systemd-rpm-macros
Requires:       python-bottle
Requires:       python-curses
Requires:       python-psutil >= 5.3.0
Requires:       python-requests
Provides:       python-glances = %{version}
Obsoletes:      python-glances
%ifpython3
Provides:       glances
%endif
BuildArch:      noarch
%python_subpackages

# Glances server systemd service
%service_add_pre glances-server.service

%description
Glances is a cross-platform monitoring tool which presents a
large amount of monitoring information through a curses or Web
based interface. The information dynamically adapts depending on the
size of the user interface.

%package common
Summary:        Glances server systemd service
Group:          System/Daemon
Requires:       %{name} = %{version}
Requires:       systemd

%description common
This package contains the systemd service file for glances-server,
allowing it to be run as a system daemon.

%install
%python_install
%python_expand %fdupes %{buildroot}%{$python_sitelib}

# Install glances-server.service
install -D -m 644 %{SOURCE2} %{buildroot}%{_unitdir}/glances-server.service

%post common
%service_add_post glances-server.service

%preun common
%service_del_preun glances-server.service

%postun common
%service_del_postun glances-server.service

%files common
%{_unitdir}/glances-server.service

%files %{python_files}
%license COPYING
%doc NEWS README.rst
%python3_only %{_bindir}/glances
%python3_only %{_mandir}/man1/glances.1.gz
%{python_sitelib}/*

%changelog
