# Helper Scripts

This directory contains helper scripts for managing examples and sources.

## Core Scripts

### `new-example.sh`
Create a new example with templates.

```bash
./scripts/new-example.sh <example-name>
```

**Example:**
```bash
./scripts/new-example.sh custom-modification
# Creates examples/custom-modification/ with templates
```

### `run-example.sh`
Run a single example with auto-cloning and ref pinning.

```bash
./scripts/run-example.sh <example-directory>
```

**Example:**
```bash
./scripts/run-example.sh examples/basic-analyze
# Clones source if needed, checks out pinned ref, runs pbuild-ai
```

**What it does:**
- Handles source based on type:
  - `remote`: Clones from URL if not present, checks out pinned ref
  - `local`: Copies from local directory to sources/ (fresh copy each run)
  - `inline`: Uses sources in example directory directly
  - `manual`: User-provided sources
- Runs pbuild-ai command
- Captures output and timing
- Saves results to timestamped directory

**Source Types:**
- **remote**: Clone from URL at runtime (sources/ gitignored)
- **local**: Copy from local dir (sources/ gitignored, no AI changes in original)
- **inline**: Sources in example dir (committed to git, AI changes committed)
- **manual**: User provides sources manually

### `run-all.sh`
Run all examples sequentially.

```bash
./scripts/run-all.sh
```

**Output:**
- Pass/fail status for each example
- Summary of results
- Exits with error if any example fails

### `generate-report.sh`
Generate HTML benchmark report from results.

```bash
./scripts/generate-report.sh
```

**Generates:**
- `docs/benchmark-report.html` with all test results
- Timing data
- Pass/fail status
- Timestamps

## Source Management Scripts

### `pin-sources.sh`
Pin all examples to their current source commits.

```bash
./scripts/pin-sources.sh
```

**What it does:**
- Scans all examples with remote sources
- Reads current git commit from each source
- Updates test.yaml with full commit hash
- Adds timestamp comment

**Use when:**
- After creating new examples
- After updating sources to desired version
- Before committing examples

**Example output:**
```
[basic-analyze] Pinning to commit: abc123def456 (was: main)
           Source: /path/to/sources/bc
           Branch: main
           ✓ Updated test.yaml
```

### `update-source-ref.sh`
Update a specific example to a new git ref.

```bash
./scripts/update-source-ref.sh <example-name> <git-ref>
```

**Arguments:**
- `example-name`: Name of example directory
- `git-ref`: Commit hash, tag, or branch name

**Examples:**
```bash
# Update to specific commit
./scripts/update-source-ref.sh basic-analyze abc123def456

# Update to tag
./scripts/update-source-ref.sh fix-build v2.0.0

# Update to branch tip
./scripts/update-source-ref.sh update-upstream main
```

**What it does:**
- Updates test.yaml ref field
- Checks out the new ref in local source (if exists)
- Shows new commit hash

**Use when:**
- Updating example to newer source version
- Rolling back to older version
- Testing with specific upstream release

## Typical Workflows

### Creating a New Example

```bash
# 1. Create
./scripts/new-example.sh my-example

# 2. Edit test.yaml and README.md
vim examples/my-example/test.yaml
vim examples/my-example/README.md

# 3. Run (clones source)
./scripts/run-example.sh examples/my-example

# 4. Pin to current commit
./scripts/pin-sources.sh

# 5. Commit
git add examples/my-example
git commit -m "Add my-example"
```

### Updating Source Version

```bash
# 1. Update to new version
./scripts/update-source-ref.sh my-example v2.0.0

# 2. Test with new version
./scripts/run-example.sh examples/my-example

# 3. Pin to exact commit
./scripts/pin-sources.sh

# 4. Update benchmarks in test.yaml

# 5. Commit
git commit -am "Update my-example to v2.0.0"
```

### Running All Tests

```bash
# 1. Run all examples
./scripts/run-all.sh

# 2. Generate report
./scripts/generate-report.sh

# 3. View results
firefox docs/benchmark-report.html
```

### Bulk Pin All Examples

```bash
# Run all examples first (to ensure sources exist)
./scripts/run-all.sh

# Pin all to current commits
./scripts/pin-sources.sh

# Review changes
git diff examples/*/test.yaml

# Commit
git add examples/
git commit -m "Pin all examples to current source versions"
```

## Script Details

### Error Handling

All scripts:
- Use `set -e` for fail-fast behavior
- Provide clear error messages
- Exit with non-zero code on failure

### Path Handling

Scripts handle:
- Absolute and relative paths
- Paths with spaces
- Symlinks
- Missing directories (create as needed)

### Git Operations

Git commands:
- Clone with error checking
- Checkout with verification
- Rev-parse for commit hashes
- Graceful fallback if git unavailable

## Tips

1. **Run from repository root**: All scripts expect to be run from the repository root directory

2. **Check git availability**: Scripts require `git` command for cloning and ref management

3. **Review before commit**: Always review changes to test.yaml files before committing:
   ```bash
   git diff examples/*/test.yaml
   ```

4. **Use full hashes for pinning**: While short hashes work, full hashes are more reliable long-term

5. **Document updates**: When updating source refs, document why in the commit message

## See Also

- [QUICKSTART.md](../QUICKSTART.md) - Getting started guide
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [REPRODUCIBILITY.md](../REPRODUCIBILITY.md) - Reproducibility guide
