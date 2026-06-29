# Source Packages Directory

This directory contains source packages for examples. Due to git hash algorithm incompatibility between GitHub (SHA-1) and openSUSE repositories (SHA-256), we cannot use git submodules.

## Source Management Strategies

### Strategy 1: Runtime Cloning (Recommended)

Sources are cloned when examples run. The `test.yaml` specifies the source URL, and scripts handle cloning automatically.

**Pros**: Always gets latest sources, no storage in this repo
**Cons**: Requires network access, slower first run

### Strategy 2: Inline Sources

For small examples, include source files directly in the example directory.

**Pros**: No network needed, fast, fully self-contained
**Cons**: Increases repo size, harder to update

### Strategy 3: Manual Setup

Document source URLs, users clone manually before running examples.

**Pros**: Simple, flexible
**Cons**: Extra setup step for users

## Directory Structure

```
sources/
├── README.md           (this file)
├── .gitignore          (ignore cloned packages)
└── <package-name>/     (cloned at runtime, not committed)
```

## How It Works

When you run an example:

```bash
./scripts/run-example.sh examples/basic-analyze
```

The script:
1. Reads `test.yaml` to find the source URL
2. Checks if `sources/<package>` exists
3. If not, clones it from the specified URL
4. Runs pbuild-ai against the cloned source

## Manual Source Cloning

If you want to pre-clone sources:

```bash
# Clone a package source
git clone https://src.opensuse.org/pool/bc sources/bc

# Or use osc (openSUSE build service command line tool)
cd sources
osc co openSUSE:Factory bc
```

## Cleaning Up

Remove cloned sources:

```bash
rm -rf sources/*/
```

Or clean a specific package:

```bash
rm -rf sources/bc
```
