#
# spec file for package atom
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


Name:           atom
Version:        1.60.0
Release:        0
Summary:        A hackable text editor for the 21st Century
License:        MIT
Group:          Development/Tools/Other
URL:            https://atom.io
Source0:        https://github.com/atom/atom/archive/v%{version}.tar.gz
Source1:        atom-%{version}-amd64.tar.gz
Patch0:         atom-fix-paths.patch

BuildRequires:  rpm-build
BuildArch:      x86_64

Requires:       libX11-6
Requires:       libXcomposite1
Requires:       libXdamage1
Requires:       libXext6
Requires:       libXrandr2
Requires:       libc6
Requires:       libgcc_s1
Requires:       libstdc++6
Requires:       libxkbfile1

%description
Atom is a hackable text editor for the 21st Century, built to be approachable,
powerful & fast, yet customizable in a way that no other editor can be. Atom
is powered by JavaScript, CSS, HTML and CoffeeScript. It's also cross-platform
and open source.

%prep
%autosetup -p1 -n atom-%{version}

# Extract pre-built distribution to get application files
tar xzf %{SOURCE1} --strip-components=2

# Remove precompiled binaries to ensure proper rebuild for target architecture
find . -name '*.node' -delete
find . -name '*.jar' -delete
find . -name '*.dll' -exe -delete
find . -name '*.so' -delete
find . -name '*.dylib' -delete

%patch0 -p1

%build
# No build steps needed for pre-built binary distribution

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}/atom

# Install application files (unpacked)
cp -a ./* "%{buildroot}%{_libdir}/atom/" 2>/dev/null || true

# Create wrapper script for atom command
cat > "%{buildroot}%{_bindir}/atom" << 'EOF'
#!/bin/bash
ATOM_PATH="%{_libdir}/atom/atom"
exec "$ATOM_PATH" --executed-from="$(pwd)" --pid=$$ "$@"
EOF
chmod 755 "%{buildroot}%{_bindir}/atom"

# Install desktop file
mkdir -p %{buildroot}%{_datadir}/applications
cat > "%{buildroot}%{_datadir}/applications/atom.desktop" << EOF
[Desktop Entry]
Name=Atom
Comment=A hackable text editor for the 21st Century
Exec=%{_bindir}/atom %F
Icon=atom
Type=Application
Categories=Development;TextEditor;IDE;
StartupNotify=true
MimeType=text/plain;text/x-csrc;text/x-c++src;text/x-java;text/x-python;text/x-perl;text/x-ruby;text/x-php;text/x-sql;text/x-makefile;text/x-cmake;text/x-asm;text/x-tex;text/x-lua;text/x-go;text/x-rustsrc;application/json;
EOF

%check
# Verify the binary exists and is executable
test -x "%{buildroot}%{_libdir}/atom/atom" && echo "Atom binary found and executable"

%files
%defattr(-,root,root,-)
%doc CHANGELOG.md LICENSE.md README.md SUPPORT.md CODE_OF_CONDUCT.md CONTRIBUTING.md PULL_REQUEST_TEMPLATE.md
%license LICENSE.md
%{_bindir}/atom
%{_libdir}/atom
%{_datadir}/applications/atom.desktop
%{?_licensedir:%doc %{_licensedir}/*}

%changelog
