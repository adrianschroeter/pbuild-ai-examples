# Fix Build Failures

## Description

This example demonstrates pbuild-ai's ability to automatically detect and fix
build failures. It performs a test build and if failures occur, analyzes the
build logs and applies appropriate fixes.

**Note:** This example uses `type: local` to copy a package from your local filesystem.
You need to update the `local_path` in `test.yaml` to point to your actual package location.

## Command

```bash
pbuild-ai --fix <source-directory>
```

When run by the test script, this becomes:
```bash
pbuild-ai --fix /path/to/sources/fix-build-example
```

## Setup

This example comes with a `package/` directory that you can use directly or replace with your own package.

### Option 1: Use the example package (default)

The example is pre-configured to use `./package/` directory:

```bash
./scripts/run-example.sh examples/fix-build-failures
```

### Option 2: Use your own package

Replace the contents of `package/` with your own package files:

```bash
cd examples/fix-build-failures/package/
# Replace example.spec with your package files
cp ~/my-package/*.spec .
cp ~/my-package/*.tar.gz .
# etc.
```

### Option 3: Point to an external package

Edit `test.yaml` to use a different location:

```yaml
source:
  type: local
  local_path: "~/packages/mypackage"  # ← Your package location
```

Supported path formats:
- `"./package"` - Relative to example directory (can be committed to git)
- `"../../packages/myapp"` - Relative to repo root
- `"~/packages/myapp"` - Home directory (won't be committed)
- `"/absolute/path/myapp"` - Absolute path (won't be committed)

### How It Works

The script copies your package → `sources/fix-build-example/`:
- AI changes stay in `sources/` (gitignored)
- Your original package files remain untouched
- Fresh copy on each run for clean state

## Expected Behavior

pbuild-ai will:
1. Run a test build using pbuild
2. If the build fails, analyze the build logs
3. Identify the root cause of the failure
4. Generate and apply fixes (patches, spec changes)
5. Rebuild to verify the fix
6. Report the changes made

If the build succeeds initially, no changes are made.

## Source Package

This example uses **local mode** (`type: local`), which means you provide your own package
from a local directory. This is perfect for:
- Testing your own packages with build failures
- Working on packages you're actively developing
- Packages with known compatibility issues
- Demonstrating fixes without committing AI changes to your working directory

The package is copied to `sources/` before running, so your original files remain untouched.

## Notes

- This operation modifies package files - always review changes
- Build time depends on package complexity and dependency resolution
- pbuild-ai automatically detects the package in the current directory
- Typical run time: 2-5 minutes for simple packages
- AI may create patch files and update spec to include them
