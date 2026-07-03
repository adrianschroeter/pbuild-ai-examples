# pbuild-ai Examples and Test Cases

This repository contains examples and test cases for [pbuild-ai](https://github.com/adrianschroeter/pbuild-ai), demonstrating various use cases and serving as a regression test suite.

## Repository Structure

```
pbuild-ai-examples/
├── examples/           # Test case directories
│   ├── basic-analyze/  # Example: basic package analysis
│   ├── fix-build/      # Example: fixing build failures
│   └── update-upstream/# Example: updating to upstream version
├── sources/            # Package sources (cloned at runtime, not committed)
├── docs/               # Static website source
├── scripts/            # Helper scripts
└── results/            # Benchmark results and test outputs
```

## Why Not Git Submodules?

GitHub uses SHA-1 for git repositories, while openSUSE package sources use SHA-256. This hash algorithm incompatibility makes git submodules impossible. Instead, sources are cloned automatically when examples run.

## Test Case Format

Each example directory contains:
- `test.yaml` - Test case definition
- `README.md` - Documentation for this example
- Source code (cloned to `sources/` at runtime, or inline for small examples)

### test.yaml Format

```yaml
name: "Example Name"
description: "What this test case demonstrates"
source:
  # Source type options:
  #   remote: Clone from URL at runtime (to sources/)
  #   local: Copy from local directory (to sources/, changes not committed)
  #   inline: Sources in example dir (changes committed to git)
  #   manual: User provides sources manually
  type: remote
  path: "../../sources/cowsay"
  url: "https://src.opensuse.org/pool/cowsay"
  ref: "abc123def456"  # Git commit/tag/branch - pinned for reproducibility
  # For local type, add: local_path: "~/packages/cowsay"
command: "pbuild-ai"
options:
  - "--fix"
expected:
  success: true
  changes: true  # whether source modifications are expected
  files_modified:
    - "cowsay.spec"
  build_result: "succeeded"
benchmarks:
  run_time_seconds: 120
  build_time_seconds: 45
  ai_time_seconds: 75
  model: "gemma4"
```

### Source Type Details

| Type | Location | Committed | Use Case |
|------|----------|-----------|----------|
| `remote` | `sources/<pkg>/` | ❌ No | Clone from openSUSE/GitHub at runtime |
| `local` | `sources/<pkg>/` | ❌ No | Copy from local dir (AI changes stay local) |
| `inline` | `examples/<name>/` | ✅ Yes | Small demo packages (AI changes committed) |
| `manual` | User provides | ❌ No | Custom testing scenarios |

## Running Examples

Run a single example:
```bash
./scripts/run-example.sh examples/basic-analyze
```

Run all examples and collect benchmarks:
```bash
./scripts/run-all.sh
```

Generate benchmark report:
```bash
./scripts/generate-report.sh
```

## Adding New Examples

1. Create a new directory in `examples/`:
   ```bash
   ./scripts/new-example.sh my-example
   ```

2. Edit `examples/my-example/test.yaml` with your test case
   - Set `source.type` to `remote` for automatic cloning
   - Or set to `inline` and include sources in the example directory

3. Edit `examples/my-example/README.md` with documentation

4. Run the example to verify (sources cloned automatically):
   ```bash
   ./scripts/run-example.sh examples/my-example
   ```

5. Pin source to current commit for reproducibility:
   ```bash
   ./scripts/pin-sources.sh
   ```

6. Commit and push:
   ```bash
   git add examples/my-example
   git commit -m "Add my-example test case"
   ```

## Static Website

The website is **fully static** (pure HTML/CSS) and hosted directly on GitHub Pages - no server required!

**View locally** (optional, for testing):
```bash
# Option 1: Open directly in browser
open docs/index.html
# Or on Linux: xdg-open docs/index.html

# Option 2: Use local web server for testing
cd docs && python3 -m http.server 8000
```

**GitHub Pages deployment**: Files in `docs/` are served as-is by GitHub.

The site showcases all examples with:
- Command used
- Expected vs actual results
- Benchmark comparison
- Source code links

## Contributing

Contributions of new examples are welcome! Please ensure:
- Test case runs successfully
- Includes realistic benchmark data
- Documents what the example demonstrates
- Follows the test.yaml format

Run this command for avoiding merge conflicts on results file.

 # git config local include.path ../.gitconfig-shared

That file will be anyway regenerated via the generate-report.sh script

