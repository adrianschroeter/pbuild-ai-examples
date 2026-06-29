#!/bin/bash
# Pin all remote sources to their current git commits for reproducibility

set -e

REPO_ROOT=$(pwd)

echo "Pinning source repositories to current commits..."
echo "=================================================="
echo ""

# Find all test.yaml files
for test_yaml in examples/*/test.yaml; do
    if [ ! -f "$test_yaml" ]; then
        continue
    fi

    EXAMPLE=$(basename "$(dirname "$test_yaml")")

    # Extract source info
    SOURCE_TYPE=$(grep -E "^\s+type:" "$test_yaml" | sed 's/.*type:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
    SOURCE_PATH=$(grep -E "^\s+path:" "$test_yaml" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

    if [ "$SOURCE_TYPE" != "remote" ]; then
        echo "[$EXAMPLE] Skipping (type: $SOURCE_TYPE)"
        continue
    fi

    # Convert relative path to absolute
    RELATIVE_PATH="${SOURCE_PATH#../../}"
    FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"

    if [ ! -d "$FULL_SOURCE_PATH" ]; then
        echo "[$EXAMPLE] Warning: Source not cloned yet at $FULL_SOURCE_PATH"
        echo "           Run: ./scripts/run-example.sh examples/$EXAMPLE"
        echo ""
        continue
    fi

    # Get current commit
    CURRENT_COMMIT=$(cd "$FULL_SOURCE_PATH" && git rev-parse HEAD 2>/dev/null)
    CURRENT_BRANCH=$(cd "$FULL_SOURCE_PATH" && git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ -z "$CURRENT_COMMIT" ]; then
        echo "[$EXAMPLE] Warning: Failed to get git commit"
        continue
    fi

    # Check if already pinned to this commit
    CURRENT_REF=$(grep -E "^\s+ref:" "$test_yaml" | sed 's/.*ref:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

    if [ "$CURRENT_REF" = "$CURRENT_COMMIT" ]; then
        echo "[$EXAMPLE] Already pinned to $CURRENT_COMMIT"
        continue
    fi

    echo "[$EXAMPLE] Pinning to commit: $CURRENT_COMMIT (was: $CURRENT_REF)"
    echo "           Source: $FULL_SOURCE_PATH"
    echo "           Branch: $CURRENT_BRANCH"

    # Update test.yaml with full commit hash
    if grep -q "^\s\+ref:" "$test_yaml"; then
        # Replace existing ref line
        sed -i "s|^\(\s\+\)ref:.*|\1ref: \"$CURRENT_COMMIT\"  # Pinned $(date +%Y-%m-%d)|" "$test_yaml"
    else
        # Add ref line after url line
        sed -i "/^\s\+url:/a\  ref: \"$CURRENT_COMMIT\"  # Pinned $(date +%Y-%m-%d)" "$test_yaml"
    fi

    echo "           ✓ Updated test.yaml"
    echo ""
done

echo "=================================================="
echo "Pinning complete!"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff examples/*/test.yaml"
echo "  2. Test examples still work"
echo "  3. Commit: git add examples/ && git commit -m 'Pin sources to specific commits'"
