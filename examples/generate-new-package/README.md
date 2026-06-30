# Generate New Package

## Description

This example demonstrates pbuild-ai's ability to generate a complete package specification
from scratch based on a natural language description. Unlike other examples that work with
existing packages, this creates everything from zero.

## Command

```bash
pbuild-ai --generate "package ripgrep CLI tool"
```

## Expected Behavior

pbuild-ai will:
1. Research the ripgrep project online
2. Find the latest version and source location
3. Generate a complete .spec file with:
   - Proper metadata (Name, Version, Summary, License, URL)
   - Build dependencies
   - Build instructions
   - Installation steps
   - File lists
4. Create a .changes file with initial changelog entry
5. Perform a test build
6. Fix any build issues
7. Verify the package builds successfully

## Notes

- **No source files needed**: This example works without any existing package files
- **AI research**: The AI will fetch information about ripgrep from the internet
- **Complete generation**: Creates all necessary packaging files from scratch
- **Build verification**: Ensures the generated package actually builds
- **Typical run time**: 5-45 minutes depending on AI performance and complexity
- **Use case**: Perfect for quickly packaging new upstream projects

This is the most autonomous mode of pbuild-ai - it handles everything from research
to working package specification.
