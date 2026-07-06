#
# spec file for package ggplot2
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


%global packname ggplot2
%global rlibdir %{_libdir}/R/library

Name:           R-ggplot2
Version:        3.4.0
Release:        0
Summary:        Create Elegant Data Visualisations Using the Grammar of Graphics
License:        MIT + file LICENSE
Group:          Development/Libraries/Other
URL:            https://ggplot2.tidyverse.org
Source0:        https://cran.r-project.org/src/contrib/ggplot2_%{version}.tar.gz

BuildRequires:  R-base
BuildRequires:  R-cli >= 3.1.0
BuildRequires:  R-gtable >= 0.1.1
BuildRequires:  R-rlang >= 1.0.0
BuildRequires:  R-scales >= 1.2.0
BuildRequires:  R-tibble
BuildRequires:  R-vctrs >= 0.5.0
BuildRequires:  R-withr >= 2.5.0

%description
A system for 'declaratively' creating graphics, based on "The Grammar of Graphics".
You provide the data, tell 'ggplot2' how to map variables to aesthetics, what
graphical primitives to use, and it takes care of the details.

%prep
%setup -q -n %{packname}-%{version}

%build
# nothing to build — R packages are byte-compiled during install

%install
R CMD INSTALL -l %{buildroot}%{rlibdir} --no-multiarch .
rm -f %{buildroot}%{rlibdir}/R.css
rm -f *.o *.so

%check
_R_CHECK_FORCE_SUGGESTS=0 \
  _R_CHECK_COMPILATION_FLAGS_="%{?_test_cflags}" \
  R CMD check --no-manual --no-vignettes --no-tests .

%files
%defattr(-, root, root)
%dir %{rlibdir}/%{packname}
%{rlibdir}/%{packname}/DESCRIPTION
%{rlibdir}/%{packname}/INDEX
%{rlibdir}/%{packname}/NAMESPACE
%{rlibdir}/%{packname}/Meta
%{rlibdir}/%{packname}/R
%{rlibdir}/%{packname}/data
%{rlibdir}/%{packname}/doc
%{rlibdir}/%{packname}/help

%fdupes %{rlibdir}/%{packname}

%changelog
