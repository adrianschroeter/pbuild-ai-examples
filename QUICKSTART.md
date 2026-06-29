# Quick Start Guide

Get up and running with pbuild-ai examples in minutes.

## Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/adrianschroeter/pbuild-ai-examples.git
   cd pbuild-ai-examples
   ```

2. **Ensure pbuild-ai is installed**:
   ```bash
   # Clone pbuild-ai if not already installed
   git clone https://github.com/adrianschroeter/pbuild-ai.git
   # Follow pbuild-ai installation instructions
   ```

## Running Examples

### Run a Single Example

```bash
./scripts/run-example.sh examples/basic-analyze
```

This will:
- Clone the source package if needed (automatically handled)
- Execute the pbuild-ai command defined in the example
- Capture output and timing data
- Save results to `results/basic-analyze/<timestamp>/`

**Note**: First run may take longer as sources are cloned. Subsequent runs use cached sources.

### Run All Examples

```bash
./scripts/run-all.sh
```

This runs all examples sequentially and reports pass/fail status.

### View Results

After running examples, generate a benchmark report:

```bash
./scripts/generate-report.sh
```

Then open `docs/benchmark-report.html` in your browser.

## Adding Your Own Example

### Quick Method

```bash
./scripts/new-example.sh my-example
```

This creates:
- `examples/my-example/test.yaml` (test definition)
- `examples/my-example/README.md` (documentation)

### Edit the Files

1. **Edit `test.yaml`** with your test case details:
   - Command to run
   - Expected results
   - Tags

2. **Edit `README.md`** with documentation:
   - What the example demonstrates
   - Why the source package was chosen
   - Expected behavior

3. **Configure source in test.yaml**:
   ```yaml
   source:
     type: remote  # Automatically cloned when example runs
     path: "../../sources/PACKAGE"
     url: "https://src.opensuse.org/pool/PACKAGE"
   ```

### Test Your Example

```bash
./scripts/run-example.sh examples/my-example
```

## Viewing the Website

The website is **static HTML/CSS files** - no server-side processing needed!

### Locally (Testing)

**Option 1**: Open directly in browser
```bash
# Open the file directly
open docs/index.html
# Or: xdg-open docs/index.html (Linux)
# Or: start docs/index.html (Windows)
```

**Option 2**: Test with local server (optional)
```bash
cd docs
python3 -m http.server 8000
# Visit: http://localhost:8000
```

### GitHub Pages (Production)

GitHub Pages serves the static files directly:

1. Push to GitHub
2. Go to Settings → Pages
3. Source: "GitHub Actions" (auto-deploys from workflows)
4. Your site: `https://USERNAME.github.io/pbuild-ai-examples/`

**No server needed** - GitHub serves the HTML/CSS files as-is!

## Example Workflow

Here's a complete workflow for adding and testing an example:

```bash
# 1. Create new example
./scripts/new-example.sh fix-compiler-warning

# 2. Edit the test case (source will be cloned automatically)
vim examples/fix-compiler-warning/test.yaml
vim examples/fix-compiler-warning/README.md

# 4. Test it
./scripts/run-example.sh examples/fix-compiler-warning

# 5. Update benchmark data in test.yaml with actual results

# 6. Commit (sources/ directory is gitignored - not committed)
git add examples/fix-compiler-warning
git commit -m "Add fix-compiler-warning example"

# 7. Generate updated website
./scripts/generate-report.sh

# 8. View locally
cd docs && python3 -m http.server 8000
```

## Directory Structure

```
pbuild-ai-examples/
├── examples/              # Test case directories
│   ├── basic-analyze/
│   │   ├── test.yaml     # Test definition
│   │   └── README.md     # Documentation
│   ├── fix-build-failures/
│   └── update-upstream/
├── sources/               # Cloned packages (gitignored, not committed)
├── docs/                  # Static website
│   ├── index.html
│   └── benchmark-report.html (generated)
├── scripts/               # Helper scripts
│   ├── new-example.sh
│   ├── run-example.sh
│   ├── run-all.sh
│   └── generate-report.sh
└── results/               # Benchmark results
    └── <example>/<timestamp>/
```

## Common Tasks

### Manually Clone a Source Package

If you want to pre-clone sources instead of automatic cloning:

```bash
git clone https://src.opensuse.org/pool/PACKAGE sources/PACKAGE
```

### Update an Example's Source Version

```bash
# Update to a specific commit/tag
./scripts/update-source-ref.sh basic-analyze abc123def

# Or update to latest on a branch
./scripts/update-source-ref.sh basic-analyze main

# Then re-pin to the new commit
./scripts/pin-sources.sh
```

### Pin All Sources to Current Commits

```bash
# After running examples, pin them for reproducibility
./scripts/pin-sources.sh

### Clean Results

```bash
rm -rf results/*
```

### Update All Examples

```bash
./scripts/run-all.sh
./scripts/generate-report.sh
```

## Tips

- Start with **basic-analyze** to understand the simplest use case
- Use **bc** package for initial testing (small, stable)
- Review results in `results/<example>/<timestamp>/output.log`
- Benchmark times vary based on:
  - AI model used
  - System resources
  - Network speed (for upstream fetching)
  - Package complexity

## Troubleshooting

**Example fails with "command not found"**
- Ensure pbuild-ai is installed and in PATH
- Check that pbuild is also installed

**Sources not cloning automatically**
- Check internet connection
- Try manual clone: `git clone <URL> sources/<PACKAGE>`
- Verify `test.yaml` has correct `source.url`

**Website not updating**
- Regenerate report: `./scripts/generate-report.sh`
- Check GitHub Actions logs if using automated deployment

**Test runs too long**
- Use a smaller/simpler package
- Use `--dist tumbleweed` for faster dependency resolution
- Consider disabling network tests in test.yaml

## Next Steps

- Read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines
- Browse existing examples in `examples/`
- Visit the website at `docs/index.html`
- Check [pbuild-ai documentation](https://github.com/adrianschroeter/pbuild-ai)

Happy testing!
