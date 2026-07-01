# Cleanup Source

## Description

This example demonstrates the `--modify` flag, which allows you to make targeted changes to a package using a simple text prompt. Unlike `--fix --prompt` combination, `--modify` is a standalone command for quick modifications. It is not executing a test build.

This example shows

## Command

```bash
pbuild-ai --modify "Cleanup the source" <source-directory>
```

When run by the test script, this becomes:
```bash
pbuild-ai --modify 'Cleanup the source' /path/to/sources/owntone
```

## What This Does

The `--modify` flag tells pbuild-ai to:
1. Understand the requested modification from the text prompt
2. Modify the spec file according to its rules

## Use Cases

The `--modify` flag is perfect for:
- **Quick additions**: Add systemd units, config files, or scripts
- **Targeted changes**: Modify specific sections without losing time on building
- **Simple enhancements**: Add documentation, examples, or helper files
- **Prototyping**: Quickly test ideas before committing

## Difference from --prompt

| Flag | Purpose | Requires Other Flags | When to Use |
|------|---------|---------------------|-------------|
| `--modify` | Make specific modifications | No | Quick, targeted changes |
| `--prompt` | Provide custom instructions | Yes (--fix, --update, etc.) | Complex workflows |

## Expected Behavior

For this example, pbuild-ai will:
1. Update just the spec file
2. Report the changes made

## Notes

- The `--modify` flag makes actual changes to your package sources
- Always review changes before committing to git
- The AI will try to follow package best practices
- Works best with clear, specific modification requests
- Typical run time: 1-3 minutes depending on complexity

