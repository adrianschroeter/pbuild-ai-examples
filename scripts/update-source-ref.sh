#!/bin/bash
# Update a specific example's source ref to a new commit/tag/branch

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <example-name> <git-ref>"
    echo ""
    echo "Updates the source ref for an example to a specific commit/tag/branch"
    echo ""
    echo "Examples:"
    echo "  $0 basic-analyze main"
    echo "  $0 basic-analyze abc123def456"
    echo "  $0 fix-build-failures v1.2.3"
    exit 1
fi

EXAMPLE_NAME="$1"
NEW_REF="$2"
TEST_YAML="examples/${EXAMPLE_NAME}/test.yaml"

if [ ! -f "$TEST_YAML" ]; then
    echo "Error: Example not found: $EXAMPLE_NAME"
    echo "Available examples:"
    ls -1 examples/
    exit 1
fi

# Get source path
SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
RELATIVE_PATH="${SOURCE_PATH#../../}"
FULL_SOURCE_PATH="${RELATIVE_PATH}"

echo "Updating source ref for: $EXAMPLE_NAME"
echo "New ref: $NEW_REF"
echo ""

# Update test.yaml
if grep -q "^\s\+ref:" "$TEST_YAML"; then
    sed -i "s|^\(\s\+\)ref:.*|\1ref: \"$NEW_REF\"  # Updated $(date +%Y-%m-%d)|" "$TEST_YAML"
    echo "✓ Updated ref in test.yaml"
else
    sed -i "/^\s\+url:/a\  ref: \"$NEW_REF\"  # Updated $(date +%Y-%m-%d)" "$TEST_YAML"
    echo "✓ Added ref to test.yaml"
fi

# If source exists locally, offer to checkout the new ref
if [ -d "$FULL_SOURCE_PATH" ]; then
    echo ""
    echo "Source exists at: $FULL_SOURCE_PATH"
    echo "Checking out ref: $NEW_REF"

    (cd "$FULL_SOURCE_PATH" && git fetch && git checkout "$NEW_REF") || {
        echo "Warning: Failed to checkout $NEW_REF in local source"
        echo "You may need to update manually"
    }

    COMMIT=$(cd "$FULL_SOURCE_PATH" && git rev-parse HEAD)
    echo "✓ Now at commit: $COMMIT"
fi

echo ""
echo "Done! Test the example:"
echo "  ./scripts/run-example.sh examples/$EXAMPLE_NAME"
