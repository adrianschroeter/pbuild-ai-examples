# Update to Latest Upstream

## Description

This example demonstrates pbuild-ai's ability to automatically update a package
to the latest upstream version. It fetches the new version, updates package files,
builds the updated package, and fixes any compatibility issues.

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
6. Perform a test build
7. Fix any build failures due to the update
8. Verify the updated package builds successfully

## Source Package

**cowsay** is a fun package with a stable GitHub upstream, making it suitable
for demonstrating the update workflow. The package:
- Has a clear upstream source (GitHub: cowsay-org/cowsay)
- Reliable server availability (no GNU downtime issues)
- Very fast to download and build
- Simple structure makes updates easy to verify
- Good for testing update automation

## Notes

- This operation significantly modifies package files - always review changes
- The AI researches upstream sources via web fetch
- May ask clarifying questions about version selection
- Typical run time: 3-7 minutes depending on upstream investigation time
- The changelog entry is automatically generated based on upstream changes
- Build verification ensures the update doesn't break functionality
- Use git to review all changes before committing
