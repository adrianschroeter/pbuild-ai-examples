#
# spec file for package cargo
#
# Copyright (c) 2026 SUSE LLC and contributors
# Author(s): Adam Goode <adam@opengnu.org>, Andreas Stieger <andreas.stieger@gmx.de>,
#            Fabian Vogt <fabian@ritter-vogt.de>
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


Name:           cargo
Version:        0.75.0
Release:        0
Summary:        Package manager for Rust
License:        Apache-2.0 OR MIT
URL:            https://crates.io
Source0:        %{name}-%{version}.tar.zst
Source1:        registry.tar.zst
ExclusiveArch:  %{rust_tier1_arches}

BuildRequires:  cargo
BuildRequires:  cargo-packaging
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  libcurl-devel
BuildRequires:  libgit2-devel
BuildRequires:  libopenssl-devel
BuildRequires:  pkg-config

%description
Cargo is a package manager for Rust. It handles building your project,
managing dependencies, and publishing to crates.io.

%package -n     cargo-doc
Summary:        Documentation for the Cargo package manager
License:        Apache-2.0 OR MIT

%description -n cargo-doc
This package contains documentation for the Cargo package manager.

%prep
%autosetup -p1 -a1

%build
export CARGO_HOME=$PWD/.cargo
# Disable network access during build - use vendored dependencies only
export CARGO_NET_OFFLINE=true
%{cargo_build}

%install
export CARGO_HOME=$PWD/.cargo
%{cargo_install} --destdir %{buildroot}%{_bindir}

%check
export CARGO_HOME=$PWD/.cargo
# Skip tests that require network access
export CARGO_NET_OFFLINE=true
%{cargo_test}

%files
%license LICENSE-APACHE LICENSE-MIT
%doc README.md
%bindir/cargo
%{_libdir}/cargo/bin/*

%files -n cargo-doc
%license LICENSE-APACHE LICENSE-MIT
%doc README.md
%{_mandir}/man1/cargo.1.gz

%changelog
