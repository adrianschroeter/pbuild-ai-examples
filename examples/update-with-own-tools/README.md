# update-with-own-tools

## Description

Our ollama package is using a helper script to update references to vendored
sources. We instruct pbuild-ai via a AGENTS.md file inside of the package
sources to call it.

Since executing scripts from package sources is a potential danger, it has
to be allowed explicit with additional --allow-tool-scripts parameter.

## Command

```bash
pbuild-ai --update --allow-tool-scripts PACKAGE_NAME
```

## Expected Behavior

Updating the version.

## Source Package

Ollama is a resource hungry package, but also a real life example...

## Notes

