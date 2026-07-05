#
# spec file for package python3-ollama
#
# Copyright (c) 2026 SUSE LLC and contributors
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


Name:           python3-ollama
Version:        0.3.3
Release:        0
Summary:        Official Python client for Ollama AI
License:        MIT
URL:            https://github.com/jmorganca/ollama-python
Source0:        https://pypi.io/packages/source/o/ollama/ollama-0.3.3.tar.gz
BuildArch:      noarch

BuildRequires:  python3-httpx-devel
BuildRequires:  python3-packaging
BuildRequires:  python3-poetry-core
BuildRequires:  python3-setuptools

Requires:       python3-httpx

%description
The Ollama Python library provides the easiest way to integrate Python 3.8+
projects with Ollama, a local LLM runner. It supports chat, generate, embed,
and other operations through a simple API.

%package -n     python3-ollama-docs
Summary:        Documentation for the Ollama Python client
License:        MIT
BuildArch:      noarch

%description -n python3-ollama-docs
Documentation files for the Ollama Python client library.

%prep
%autosetup

%build
PYTHONHASHSEED=0 \
  %{__python3} -m poetry build --no-interaction

%install
# Install using pip to handle poetry-core properly
%{__python3} -m pip install --root=%{buildroot} --no-deps --no-build-isolation .

# Create documentation directory
mkdir -p %{buildroot}%{_docdir}/%{name}

# Copy README for documentation
install -Dm644 README.md %{buildroot}%{_docdir}/%{name}/README.md

%check
# Run basic import test to verify installation
%{__python3} -c "import ollama; print('Import successful')" || exit 1

%files -n python3-ollama
%license LICENSE
%doc README.md
%{py3_files}

%files -n python3-ollama-docs
%{_docdir}/%{name}/README.md

%changelog
