Name:           hello-example
Version:        1.0
Release:        1
Summary:        Hello world example package
License:        MIT
Group:          Invalid
URL:            https://example.com

%description
A minimal hello world package for demonstrating inline sources
in pbuild-ai examples.

%prep
# No source to extract

%build
echo "Hello from pbuild-ai inline example"

%install
# Minimal install

%files
%doc

%changelog
* Mon Jun 29 2026 pbuild-ai examples
- Initial inline example package
