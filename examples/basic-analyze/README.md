# Basic Package Analysis

## Description

This example demonstrates the most basic use of pbuild-ai: analyzing a package source
without making any modifications. It's perfect for understanding what pbuild-ai can
tell you about a package's structure, dependencies, and build requirements.

## Command

```bash
pbuild-ai <source-directory>
```

When run by the test script, this becomes:
```bash
pbuild-ai /path/to/sources/cowsay
```

## Expected Behavior

pbuild-ai will:
1. Read the package spec file and supporting files
2. Analyze the source structure
3. Identify dependencies and build requirements
4. Provide a summary report
5. **Not modify** any files

No build is performed in this mode - it's read-only analysis.

## Source Package

**cowsay** is a fun text formatting utility that generates ASCII art of a cow with a speech bubble. It's chosen because:
- Very small codebase (Perl script)
- Extremely fast to clone and analyze
- Reliable GitHub upstream (no server downtime issues)
- Minimal dependencies
- Good starting point for understanding package analysis

## Notes

- This is the safest pbuild-ai operation - no modifications are made
- Useful for getting familiar with pbuild-ai output format
- Can be run on any package without concerns about changes
- Typical run time: 5-60 seconds depending on AI model and hardware
