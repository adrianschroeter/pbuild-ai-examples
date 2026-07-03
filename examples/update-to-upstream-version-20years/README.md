# Update to Latest Upstream 20 years edition

## Description

This example demonstrates pbuild-ai's ability to automatically update a package
to the latest upstream version. It fetches the new version, adds a changelog, 
updates package files, builds the updated package, and fixes any compatibility issues.

In this case it has also fto find the current location of the upstream
project. The old sources didn't specify it.

This is the hardcore example, where we need to deal with 20 years
of changes in upstream and also in our distribution policies.

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
4. Update some spec file syntax which is not to be used anymore
5. Update checksums and dependencies if needed
6. Update the changelog (.changes file)
7. Perform a test build
8. Fix any build failures due to the update
9. Verify the updated package builds successfully

## Notes

- This operation significantly modifies package files - always review changes
- The AI researches upstream sources via web fetch
- May ask clarifying questions about version selection
- Typical run time: 3-30 minutes depending on AI performance
- The changelog entry is automatically generated based on upstream changes
- Build verification ensures the update doesn't break functionality
- Use git to review all changes before committing
