# Update to Latest Upstream

## Description

This example demonstrates pbuild-ai's ability to automatically update a package
to the latest upstream version. It fetches the new version, updates package files,
builds the updated package, and fixes any compatibility issues.

In this case it has also fto find the current location of the upstream
project. The old sources didn't specify it.

## Command

```bash
pbuild-ai --update <source-directory>
```

When run by the test script, this becomes:
```bash
pbuild-ai --update /path/to/sources/cowsay
```

## Expected Behavior

pbuild-ai will:
1. Check for the latest upstream version of the package
2. Download the new source tarball
3. Update the spec file with the new version
4. Update checksums and dependencies if needed
5. Update the changelog (.changes file)

## Notes

- This operation significantly modifies package files - always review changes
- The AI researches upstream sources via web fetch
- May ask clarifying questions about version selection
- Typical run time: 2-5 minutes depending on upstream investigation time
- The changelog entry is automatically generated based on upstream changes
- Use git to review all changes before committing
