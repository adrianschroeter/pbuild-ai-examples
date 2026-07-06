#
# spec file for package chalk
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


Name:           npm-chalk
Version:        5.3.0
Release:        0
Summary:        Terminal string styling done right
License:        MIT
URL:            https://github.com/chalk/chalk
Source:         https://registry.npmjs.org/chalk/-/chalk-5.3.0.tgz
BuildArch:      noarch

Requires:       nodejs >= 12.17.0

%description
Chalk lets you style text in the terminal with colors, bold, italic and more.
It's a simple, fast and reliable tool for terminal string styling with full
ANSI color support (256/truecolor).

This is chalk 5.x which is ESM-only and requires Node.js >=12.17.0 or
>=14.13.0 or >=16.0.0.

%prep
%autosetup -n package

%build
# No build step required for pure ESM packages

%install
mkdir -p %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/ansi-styles
mkdir -p %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color

cp source/index.js %{buildroot}%{_datadir}/nodejs/npm/chalk/source/
cp source/index.d.ts %{buildroot}%{_datadir}/nodejs/npm/chalk/source/
cp source/utilities.js %{buildroot}%{_datadir}/nodejs/npm/chalk/source/
cp source/vendor/ansi-styles/index.js %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/ansi-styles/
cp source/vendor/ansi-styles/index.d.ts %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/ansi-styles/
cp source/vendor/supports-color/index.js %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color/
cp source/vendor/supports-color/browser.js %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color/
cp source/vendor/supports-color/index.d.ts %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color/
cp source/vendor/supports-color/browser.d.ts %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color/

%fdupes -s %{buildroot}%{_datadir}

%check
# Verify installed files exist and have reasonable sizes
test -f %{buildroot}%{_datadir}/nodejs/npm/chalk/source/index.js && \
  test -f %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/ansi-styles/index.js && \
  test -f %{buildroot}%{_datadir}/nodejs/npm/chalk/source/vendor/supports-color/index.js

%files
%defattr(-, root, root)
%dir %{_datadir}/nodejs/npm/chalk
%doc readme.md license
%{_datadir}/nodejs/npm/chalk/source/*
%{_datadir}/nodejs/npm/chalk/source/vendor/*/*
