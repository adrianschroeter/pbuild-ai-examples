# Contributing to pbuild-ai Examples

Thank you for your interest in contributing examples and test cases for pbuild-ai!

## Adding a New Example

### Quick Start

1. Create a new example using the helper script:
   ```bash
   ./scripts/new-example.sh my-example-name
   ```

2. Edit the generated files:
   - `examples/my-example-name/test.yaml` - Test case definition
   - `examples/my-example-name/README.md` - Documentation

3. Configure source in `test.yaml`:
   - Use `type: remote` for automatic cloning at runtime
   - Or use `type: inline` and include small sources in the example directory
   - Or use `type: manual` for sources users must set up themselves

4. Run your example to verify it works:
   ```bash
   ./scripts/run-example.sh examples/my-example-name
   ```

5. Pin source to current commit for reproducibility:
   ```bash
   ./scripts/pin-sources.sh
   ```

6. Update the benchmark data in `test.yaml` with actual results

7. Commit your changes:
   ```bash
   git add examples/my-example-name
   git commit -m "Add my-example-name test case"
   ```

## Example Guidelines

### What Makes a Good Example?

- **Clear purpose**: Demonstrates a specific pbuild-ai feature or use case
- **Reproducible**: Anyone can run it and get similar results
- **Well-documented**: README explains what it does and why it's interesting
- **Realistic**: Uses real packages and realistic scenarios
- **Maintained**: Source packages should be relatively stable

### Example Categories

Consider contributing examples in these categories:

- **Basic**: Simple, introductory examples for new users
- **Fix**: Demonstrating build failure fixes
- **Update**: Upstream version updates
- **Generate**: Creating packages from scratch
- **Advanced**: Complex scenarios, custom modifications
- **Project Mode**: Working with package sets

### test.yaml Requirements

Your `test.yaml` should include:

```yaml
name: "Descriptive Name"
description: "One-line description of what this demonstrates"
source:
  type: remote  # "remote" = auto-clone, "inline" = in example dir, "manual" = user setup
  path: "../../sources/PACKAGE"
  url: "https://src.opensuse.org/pool/PACKAGE"
  ref: "abc123def456"  # Pin to specific commit for reproducibility
command: "pbuild-ai"
options:
  - "--flag"
  - "PACKAGE"
expected:
  success: true
  changes: false
  files_modified: []
  build_result: "succeeded"
benchmarks:
  run_time_seconds: 120
  build_time_seconds: 45
  ai_time_seconds: 75
  model: "gemma4"
tags:
  - "category"
```

### README Requirements

Each example README should include:

1. **Description**: What the example demonstrates
2. **Command**: The exact command used
3. **Expected Behavior**: Step-by-step what should happen
4. **Source Package**: Why this package was chosen
5. **Notes**: Any special considerations or typical timing

## Testing Your Example

Before submitting:

1. Run the example at least once successfully
2. Verify the output matches expectations
3. Update benchmark data with actual timings
4. Test on a clean checkout if possible
5. Ensure documentation is clear

## Benchmark Data

Benchmark data helps users understand:
- How long examples take to run
- Performance across different models
- AI vs build vs total time breakdown

When adding benchmarks:
- Run on a consistent environment
- Note the AI model used
- Include system specs if unusual
- Run multiple times for complex examples

## Source Package Selection

Good source packages for examples:

- **Well-known packages**: bc, ripgrep, htop, etc.
- **Clear upstream**: Active development, clear versioning
- **Appropriate size**: Not too large (long build times)
- **Educational value**: Demonstrates specific challenges or features
- **License**: Open source with clear licensing

Avoid:
- Proprietary or closed-source packages
- Very large packages (>1GB source)
- Deprecated or unmaintained packages
- Packages with complex dependency chains (unless that's the point)

## Source Package Management

**Why not git submodules?** GitHub uses SHA-1, openSUSE repos use SHA-256 - incompatible for submodules.

### Option 1: Remote (Automatic Cloning)

Set in `test.yaml`:
```yaml
source:
  type: remote
  url: "https://src.opensuse.org/pool/PACKAGE"
  path: "../../sources/PACKAGE"
```

Sources are cloned automatically when the example runs. First run is slower, subsequent runs use cached sources.

### Option 2: Inline Sources

For small examples, include sources directly in the example directory:
```yaml
source:
  type: inline
  path: "./package-files"
```

### Option 3: Manual Setup

For complex cases, document setup in README:
```yaml
source:
  type: manual
  path: "../../sources/PACKAGE"
```

## Website Updates

The static website is automatically generated from examples. After adding an example:

1. The example will appear in the examples grid
2. Benchmark data will be included in reports
3. No manual website updates needed

If you want to feature your example prominently:
- Add a note in your pull request
- We may add it to the featured examples section

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b add-example-name`
3. Add your example following the guidelines above
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Open a pull request with:
   - Description of the example
   - What it demonstrates
   - Any special requirements or notes
   - Sample output (optional but helpful)

## Questions?

- Open an issue for questions about contributing
- Check existing examples for reference
- See the main README for repository structure

Thank you for contributing to pbuild-ai examples!
