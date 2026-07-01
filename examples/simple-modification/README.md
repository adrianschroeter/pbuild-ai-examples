# Simple Modification

## Description

This example demonstrates the `--modify` flag, which allows you to make targeted changes to a package using a simple text prompt. Unlike `--fix --prompt` combination, `--modify` is a standalone command for quick modifications. It is not executing a test build.

This example shows

## Command

```bash
pbuild-ai --modify "Add a systemd service file for owntone server" <source-directory>
```

When run by the test script, this becomes:
```bash
pbuild-ai --modify 'Add a systemd service file for owntone server' /path/to/sources/owntone
```

## What This Does

The `--modify` flag tells pbuild-ai to:
1. Understand the requested modification from the text prompt
2. Create or modify necessary files (in this case, a systemd service file)
3. Update the spec file to include the new files
4. Apply the changes without requiring additional flags

## Use Cases

The `--modify` flag is perfect for:
- **Quick additions**: Add systemd units, config files, or scripts
- **Targeted changes**: Modify specific sections without loosing time with building
- **Simple enhancements**: Add documentation, examples, or helper files
- **Prototyping**: Quickly test ideas before committing

## Difference from --prompt

| Flag | Purpose | Requires Other Flags | When to Use |
|------|---------|---------------------|-------------|
| `--modify` | Make specific modifications | No | Quick, targeted changes |
| `--prompt` | Provide custom instructions | Yes (--fix, --update, etc.) | Includes build test and possible follow-up fixes |

## Example Scenarios

```bash
# Add a systemd service
pbuild-ai --modify "Add a systemd service file for the daemon"

# Add configuration example
pbuild-ai --modify "Add example configuration file to /etc/myapp/"

# Add bash completion
pbuild-ai --modify "Add bash completion script"

# Modify build flags
pbuild-ai --modify "Enable LTO optimization in build"

# Add documentation
pbuild-ai --modify "Add README.md to package documentation"
```

## Expected Behavior

For this example, pbuild-ai will:
1. Create a systemd service file (e.g., `cowsay.service`)
2. Update `cowsay.spec` to:
   - Install the service file to the correct location
   - Add the service file to `%files` section
   - Add appropriate `%post`/`%preun` scripts if needed
3. Build the package to verify everything works
4. Report the changes made

## Notes

- The `--modify` flag makes actual changes to your package sources
- Always review changes before committing to git
- The AI will try to follow package best practices
- Works best with clear, specific modification requests
- Typical run time: 1-3 minutes depending on complexity

