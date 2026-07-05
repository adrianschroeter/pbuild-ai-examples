#
# spec file for package erlang-cowboy
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


Name:           erlang-cowboy
Version:        2.10.0
Release:        0
Summary:        Erlang HTTP server for Cowboy
License:        ISC
URL:            https://github.com/ninenines/cowboy
Source0:        https://github.com/ninenines/cowboy/archive/refs/tags/%{version}.tar.gz#/%{name}-%{version}.tar.gz
Source1:        https://github.com/ninenines/cowlib/archive/2.12.1.tar.gz#cowlib-2.12.1.tar.gz
Source2:        https://github.com/ninenines/ranch/archive/1.8.0.tar.gz#ranch-1.8.0.tar.gz

BuildRequires:  erlang-devel

%description
Cowboy is a small, fast and modern HTTP server for Erlang/OTP. It provides routing capabilities, selectively dispatching requests to handlers written in Erlang. Because it uses Ranch for managing connections, Cowboy can easily be embedded in any other application.

%package doc
Summary:        Documentation for Cowboy
License:        ISC
Requires:       %{name} = %{version}

%description doc
This package contains the documentation for the Cowboy HTTP server.

%prep
%autosetup -n %{name}-%{version}

# Vendor dependencies (no network access in build environment)
mkdir -p deps
tar xzf %{SOURCE1} --strip-components=1 -C deps/cowlib
tar xzf %{SOURCE2} --strip-components=1 -C deps/ranch

# Patch Makefile to not fetch deps from git/hex at build time
sed -i '/^DEPS/s/^/# /' Makefile
sed -i '/^dep_cowlib/s/^/# /' Makefile
sed -i '/^dep_ranch/s/^/# /' Makefile

%build
make all

%install
mkdir -p %{buildroot}%{erlang_dir}
cp ebin/*.beam %{buildroot}%{erlang_dir}/
cp ebin/%{name}.app %{buildroot}%{erlang_dir}/

mkdir -p %{buildroot}%{_datadir}/cowboy-%{version}
cp -r src doc examples LICENSE %{buildroot}%{_datadir}/cowboy-%{version}/

%files
%{erlang_dir}/ebin/
%{erlang_dir}/%.app

%files doc
%{_datadir}/cowboy-%{version}

%changelog
