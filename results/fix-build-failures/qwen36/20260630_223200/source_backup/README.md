# Example Package for fix-build-failures

This directory contains a minimal example package that can be used with the fix-build-failures example.

## What's Here

- `example.spec` - A simple RPM spec file template
- This README

## Using Your Own Package

To test pbuild-ai with your own package, replace these files with:

1. Your `.spec` file
2. Your source tarballs
3. Any patch files
4. Other package files

## Structure

```
package/
├── yourpackage.spec       (required)
├── yourpackage-1.0.tar.gz (source tarball)
├── *.patch                (any patches)
└── other files...
```

## How It Works

When you run the example:

1. The contents of this `package/` directory are copied to `sources/fix-build-example/`
2. pbuild-ai runs on the copy in `sources/`
3. AI modifications stay in `sources/` (gitignored)
4. Your original files in this `package/` directory remain untouched

This allows you to:
- ✅ Commit your test package to git
- ✅ Share test cases with others
- ✅ Keep AI changes separate from your source package
- ✅ Run the same test repeatedly with a clean state

## Gitignore Note

The `sources/` directory is gitignored, so AI changes won't be committed.
Only the files in this `package/` directory are tracked by git.
