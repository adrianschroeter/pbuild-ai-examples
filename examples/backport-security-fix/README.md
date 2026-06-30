# Backport Security Fix Example

## Description

This example demonstrates how to use `pbuild-ai` to backport a security fix from an upstream repository into an openSUSE package using AI-guided patching.

## Use Case

Security vulnerabilities are often fixed upstream before distributions can incorporate them. This example shows how pbuild-ai can:

1. **Understand the upstream fix** from a GitHub commit URL
2. **Analyze the current package** state in openSUSE
3. **Create an appropriate patch** or modify the spec file
4. **Verify the build** succeeds with the fix applied

## The Security Fix

This example applies a security fix from libarchive:
- **Upstream commit**: https://github.com/libarchive/libarchive/commit/020c40df9e31ec727201a8e3ddf1f94093f8fc02
- **Package**: libarchive (openSUSE Tumbleweed)
- **Vulnerability type**: Security issue in archive handling

## Command

```bash
pbuild-ai --prompt "Apply the security fix from here https://github.com/libarchive/libarchive/commit/020c40df9e31ec727201a8e3ddf1f94093f8fc02" --fix --dist tumbleweed sources/libarchive
```

### Command Breakdown

- `--prompt "..."` - Provides AI with specific instructions about the security fix URL
- `--fix` - Enables AI to modify the package sources (spec file, patches, etc.)
- `--dist tumbleweed` - Targets openSUSE Tumbleweed distribution
- `sources/libarchive` - Path to the package source directory

## What pbuild-ai Does

1. **Fetches the upstream commit** and analyzes the security fix
2. **Examines the current package** sources and version
3. **Determines the best approach**:
   - Create a new patch file
   - Modify existing patches
   - Update the spec file to apply the patch
4. **Tests the build** to ensure the fix doesn't break compilation
5. **Iterates if needed** to resolve any build failures

## Expected Output

The AI should:
- Create or modify patch files with the security fix
- Update `libarchive.spec` to include the new patch
- Successfully build the package with the fix applied
- Report the changes made

## Running This Example

```bash
# From the repository root
./scripts/run-example.sh examples/backport-security-fix

# View results
cat results/backport-security-fix/*/output.log
```

## Use Cases

This pattern is useful for:
- **Security backporting**: Applying CVE fixes from upstream to stable packages
- **Bug fixes**: Backporting critical bug fixes before the next version bump
- **Emergency patches**: Quickly applying urgent fixes with AI assistance
- **Patch management**: Maintaining patches across package updates

## Real-World Application

In a production workflow:
1. Security team identifies a CVE with an upstream fix
2. Package maintainer runs pbuild-ai with the fix URL
3. AI creates appropriate patches and updates the spec
4. Maintainer reviews the changes
5. Package is submitted to openSUSE Build Service
6. Security update is released to users

## Requirements

- Network access to fetch upstream commits
- AI model with code understanding capabilities
- pbuild and build dependencies for libarchive

## Expected Benchmark

Typical runtime: 2-5 minutes depending on:
- AI model speed
- Build time for libarchive
- Number of fix iterations needed

## Tags

- `security` - Security vulnerability fixes
- `fix` - Package fixing workflow
- `backport` - Backporting upstream changes
- `advanced` - Requires AI reasoning and code modification
