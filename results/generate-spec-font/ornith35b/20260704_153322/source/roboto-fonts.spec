#
# spec file for package roboto-fonts
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

Name:           roboto-fonts
Version:        2.138
Release:        0
Summary:        The Roboto font family by Google
License:        Apache-2.0
Group:          System/X11/Fonts
BuildArch:      noarch
BuildRequires:  fontpackages-devel
%reconfigure_fonts_prereq
Source0:        https://github.com/googlefonts/roboto/releases/download/v%{version}/roboto-unhinted.zip

%description
Roboto is a neo-grotesque sans-serif typeface designed by Google. It was
designed with a friendlier, more humanist design than the typical
neo-grotesques of the past. This package contains the unhinted version
of Roboto (regular weights only).

Designer: Christian Robertson

%prep
%setup -q -n roboto-unhinted

%build
# Nothing to do for font packages

%install
install -d '%{buildroot}%{_ttfontsdir}'
install -t '%{buildroot}%{_ttfontsdir}' -m 644 *.ttf

%reconfigure_fonts_scriptlets

%check
# Nothing to check for font packages

%files
%license LICENSE
%doc README*
%{_ttfontsdir}
