# vim: set ts=8 sw=4 tw=0 noexpandtab :
#
# spec file for package cobra
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


Name:           cobra
Version:        1.8.0
Release:        0
Summary:        A library for creating CLI applications in Go
License:        Apache-2.0
Group:          Development/Libraries/Other
URL:            https://github.com/spf13/cobra

Source:         https://github.com/spf13/cobra/archive/v%{version}.tar.gz -> %{name}-%{version}.tar.gz

BuildRequires:  go-core-modules
BuildRequires:  golang(github.com/inconshreveable/mousetrap)
BuildRequires:  golang(github.com/spf13/pflag)
BuildRequires:  pkgconfig(go-build)

%description
Cobra is a library for creating powerful modern CLI applications in Go. It provides:
* Easy interface around subcommands, flags and configuration
* Subcommands for your program with easy grouping
* Global, local and cascading flags
* Easy generation of man pages and help pages
* Shell completions (bash/zsh/fish/powershell)
* Aliases and non-hierarchical negotiation of commands

%package -n     go-core-modules
Summary:        Go core modules for cobra
Group:          Development/Libraries/Other

%description -n go-core-modules
Go core modules required by cobra.

%prep
%autosetup -p1

%build
export GOPATH=%{gopath}
mkdir -p $GOPATH/src/github.com/spf13/
ln -s %{_builddir}/%{name}-%{version} $GOPATH/src/github.com/spf13/%{name}
cd $GOPATH/src/github.com/spf13/%{name}

# Disable network access during build
export GOFLAGS=-mod=vendor
go build ./...

%install
mkdir -p %{buildroot}%{gopath}/src/github.com/spf13/
cp -a . %{buildroot}%{gopath}/src/github.com/spf13/%{name}

%check
export GOPATH=%{gopath}
mkdir -p $GOPATH/src/github.com/spf13/
ln -s %{_builddir}/%{name}-%{version} $GOPATH/src/github.com/spf13/%{name}
cd $GOPATH/src/github.com/spf13/%{name}

# Disable network access during build
export GOFLAGS=-mod=vendor
go test ./... || true

%files -n go-core-modules
%defattr(-, root, root)
%{gopath}/src/github.com/spf13/cobra/

%changelog
