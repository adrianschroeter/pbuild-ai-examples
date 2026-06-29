#!/bin/bash
# Create a new example test case

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <example-name>"
    echo "Example: $0 my-new-example"
    exit 1
fi

EXAMPLE_NAME="$1"
EXAMPLE_DIR="examples/${EXAMPLE_NAME}"

if [ -d "$EXAMPLE_DIR" ]; then
    echo "Error: Example '${EXAMPLE_NAME}' already exists"
    exit 1
fi

mkdir -p "$EXAMPLE_DIR"

# Create test.yaml template
cat > "${EXAMPLE_DIR}/test.yaml" <<'EOF'
name: "Example Name"
description: "Brief description of what this test case demonstrates"

source:
  # Type options:
  #   "remote" = clone from URL at runtime
  #   "local" = copy from local directory to sources/ (changes not committed)
  #   "inline" = included in example dir (changes committed to git)
  #   "manual" = user provides
  type: remote
  path: "../../sources/PACKAGE_NAME"
  url: "https://src.opensuse.org/pool/PACKAGE_NAME"
  ref: "main"  # Pin to specific commit/tag/branch for reproducibility
  # For local type, add: local_path: "/path/to/local/package"
  # Note: Cannot use git submodules due to SHA-1 (GitHub) vs SHA-256 (openSUSE) incompatibility

command: "pbuild-ai"
options: []
  # Add flags like --fix, --update, etc.
  # Do NOT add --dist or source paths - pbuild-ai finds sources automatically

expected:
  success: true
  changes: false  # set to true if source modifications expected
  files_modified: []
  build_result: "succeeded"  # succeeded, failed, skipped

benchmarks:
  # Fill in after running the test
  run_time_seconds: null
  build_time_seconds: null
  ai_time_seconds: null
  model: "gemma4"

tags:
  - "basic"  # Tags: basic, advanced, fix, update, generate, analysis
EOF

# Create README template
cat > "${EXAMPLE_DIR}/README.md" <<EOF
# ${EXAMPLE_NAME}

## Description

[Describe what this example demonstrates]

## Command

\`\`\`bash
pbuild-ai [options] PACKAGE_NAME
\`\`\`

## Expected Behavior

[Describe what should happen when this example runs]

## Source Package

[Describe the source package being used and why it's interesting for this test case]

## Notes

[Any special notes about this example]
EOF

echo "Created new example: ${EXAMPLE_DIR}"
echo "Next steps:"
echo "  1. Edit ${EXAMPLE_DIR}/test.yaml"
echo "  2. Edit ${EXAMPLE_DIR}/README.md"
echo "  3. If using remote sources, they'll be cloned automatically"
echo "     Or manually clone: git clone <URL> sources/<PACKAGE>"
echo "  4. Run the test: ./scripts/run-example.sh ${EXAMPLE_DIR}"
