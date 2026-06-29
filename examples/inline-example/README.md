# Inline Source Example

## Description

This example demonstrates using **inline sources** - where package files are included
directly in the example directory instead of being cloned from a remote repository.

This is useful for:
- Small, self-contained examples
- Teaching examples with minimal files
- Examples that don't need a full package repository
- Faster execution (no cloning needed)

## Command

```bash
pbuild-ai ./package-files
```

## Expected Behavior

pbuild-ai analyzes the package files directly from the example directory.
No cloning or network access required.

## Source Package

This example uses minimal inline files to demonstrate the concept.
For real examples, you would include:
- `*.spec` file
- Source tarballs or files
- Patches
- Supporting files

## Notes

- **Pros**: Fast, self-contained, no network needed, works offline
- **Cons**: Increases repository size, harder to update from upstream
- **Best for**: Small examples, tutorials, minimal test cases
- **Use remote sources for**: Real packages, large tarballs, regularly updated packages

## Structure

```
inline-example/
├── test.yaml
├── README.md
└── package-files/
    ├── package.spec
    └── other files...
```
