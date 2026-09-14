#
# spec file for package python-oterm
#
# Copyright (c) 2017 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/


%{?!python_module:%define python_module() python-%{**} python3-%{**}}
%define         pythons %primary_python
Name:           oterm
Version:        0.13.0
Release:        0
License:        MIT
Summary:        Another terminal client for Ollama
Group:          Development/Languages/Python
Url:            https://github.com/ggozad/oterm
Source:         https://pypi.python.org/packages/source/o/oterm/oterm-%{version}.tar.gz
BuildRequires:  %{python_module poetry-core}
BuildRequires:  %{python_module pipper}
BuildRequires:  %{python_module wheel}
BuildRequires:  %{python_module hatchling}

Requires: %primary_python-textual >= 3.2.0
Requires: %primary_python-typer >= 0.15.2
Requires: %primary_python-python-dotenv >= 1.0.1
Requires: %primary_python-aiosql >= 13.4
Requires: %primary_python-aiosqlite >= 0.21.0
Requires: %primary_python-packaging >= 25.0
Requires: %primary_python-pillow >= 11.2.1
Requires: %primary_python-ollama >= 0.5.0
Requires: %primary_python-textualeffects >= 0.1.4
Requires: %primary_python-pydantic >= 2.11.3
Requires: %primary_python-textual-image >= 0.8.2
Requires: %primary_python-fastmcp >= 2.5.2

BuildRequires:  fdupes
BuildRequires:  python-rpm-macros
BuildArch:      noarch

%description
Another terminal client for Ollama

%prep
%setup -q -n oterm_%{version}

%build
%pyton_wheel

%install
%pyproject_install
%fdupes %{buildroot}%{python_sitelib}


%files
%license LICENSE
%doc README.md CHANGES.txt
%{python_sitelib}/%name
%{python_sitelib}/%name-%version.dist-info

