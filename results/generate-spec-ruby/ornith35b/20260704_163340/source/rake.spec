#
# spec file for package rake
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
# Copyright (c) 2025 openSUSE maintainers and contributors


Name:           rubygem-rake
Version:        13.0.6
Release:        0
Summary:        Ruby implementation of the make program
License:        MIT
URL:            https://github.com/ruby/rake
Source0:        https://rubygems.org/downloads/%{name}-%{version}.gem
BuildArch:      noarch

%description
Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax. Rake has the following features: Easy task
definition without special syntax, special rakefile naming, automatic
prerelease checking, file tasks, built-in parallel make, flexible
manipulation of Ruby arrays, strings, files, and directories, Flexible task
arguments with out-of-the-box support for inline environment variables.

%package doc
Summary:        Documentation for %{name}
License:        MIT
Requires:       %{name} = %{version}

%description doc
This package contains documentation for rake.

%prep
%gem_unpack %{SOURCE0}

%build
# nothing to build for ruby gems

%install
cd %{name}-%{version}
%gem_install -f

%check
# Tests require network access to external hosts; disabled in build environment.

%files doc
%license LICENSE.md
%doc History.md README.md
%{_librubyvendordir}/gems/%{name}-%{version}/RDoc/*

%files
%license LICENSE.md
%doc History.md README.md
%{_bindir}/rake
%dir %{_librubyvendordir}/gems/%{name}-%{version}
%{_librubyvendordir}/gems/%{name}-%{version}/**

%changelog
