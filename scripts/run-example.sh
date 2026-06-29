#!/bin/bash
# Run a single example test case and collect benchmarks

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <example-directory>"
    echo "Example: $0 examples/basic-analyze"
    exit 1
fi

EXAMPLE_DIR="$1"
TEST_YAML="${EXAMPLE_DIR}/test.yaml"

if [ ! -f "$TEST_YAML" ]; then
    echo "Error: Test file not found: $TEST_YAML"
    exit 1
fi

# Store absolute paths
REPO_ROOT=$(pwd)
EXAMPLE_DIR_ABS="${REPO_ROOT}/${EXAMPLE_DIR}"

echo "Running example: $EXAMPLE_DIR"
echo "----------------------------------------"

# Create results directory first (with absolute path)
RESULT_DIR="${REPO_ROOT}/results/$(basename "$EXAMPLE_DIR")/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULT_DIR"

# Check if source needs to be cloned
# Extract values and remove YAML comments
SOURCE_TYPE=$(grep -E "^\s+type:" "$TEST_YAML" | sed 's/.*type:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
SOURCE_URL=$(grep -E "^\s+url:" "$TEST_YAML" | sed 's/.*url:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
SOURCE_REF=$(grep -E "^\s+ref:" "$TEST_YAML" | sed 's/.*ref:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

if [ "$SOURCE_TYPE" = "inline" ]; then
    # For inline sources, path is relative to example directory
    if [ -n "$SOURCE_PATH" ]; then
        FULL_SOURCE_PATH="${EXAMPLE_DIR_ABS}/${SOURCE_PATH}"
        echo "Using inline source at: $FULL_SOURCE_PATH"
        echo ""
    fi
elif [ "$SOURCE_TYPE" = "local" ]; then
    # For local sources, copy from a local directory to sources/ to avoid committing changes
    if [ -n "$SOURCE_PATH" ]; then
        # Parse the local_path field (where to copy from)
        LOCAL_PATH=$(grep -E "^\s+local_path:" "$TEST_YAML" | sed 's/.*local_path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

        if [ -z "$LOCAL_PATH" ]; then
            echo "Error: local mode requires local_path field in test.yaml"
            exit 1
        fi

        # Expand ~ to home directory if present
        LOCAL_PATH="${LOCAL_PATH/#\~/$HOME}"

        # Handle relative paths - make them relative to the example directory
        if [[ "$LOCAL_PATH" != /* ]]; then
            # Relative path - resolve from example directory
            LOCAL_PATH="${EXAMPLE_DIR_ABS}/${LOCAL_PATH}"
            # Normalize the path (resolve .. and .)
            LOCAL_PATH=$(cd "$(dirname "$LOCAL_PATH")" 2>/dev/null && pwd)/$(basename "$LOCAL_PATH") || LOCAL_PATH=""
        fi

        if [ -z "$LOCAL_PATH" ] || [ ! -d "$LOCAL_PATH" ]; then
            echo "Error: Local source path does not exist: $LOCAL_PATH"
            exit 1
        fi

        # Convert relative path to absolute from repo root
        RELATIVE_PATH="${SOURCE_PATH#../../}"
        FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"

        # Always refresh the copy to ensure clean state
        echo "Copying local source to temporary location..."
        echo "  From: $LOCAL_PATH"
        echo "  To: $FULL_SOURCE_PATH"

        # Remove existing copy and create fresh one
        rm -rf "$FULL_SOURCE_PATH"
        mkdir -p "$(dirname "$FULL_SOURCE_PATH")"
        cp -a "$LOCAL_PATH" "$FULL_SOURCE_PATH"

        echo "✓ Local source copied to clean state"
        echo ""
    fi
elif [ "$SOURCE_TYPE" = "remote" ] || [ "$SOURCE_TYPE" = "clone" ]; then
    if [ -n "$SOURCE_URL" ] && [ -n "$SOURCE_PATH" ]; then
        # Convert relative path to absolute from repo root
        # Remove leading ../../ and prepend repo root
        RELATIVE_PATH="${SOURCE_PATH#../../}"
        FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"

        if [ ! -d "$FULL_SOURCE_PATH" ]; then
            echo "Cloning source package..."
            echo "  URL: $SOURCE_URL"
            echo "  Path: $FULL_SOURCE_PATH"
            if [ -n "$SOURCE_REF" ]; then
                echo "  Ref: $SOURCE_REF (pinned for reproducibility)"
            fi

            mkdir -p "$(dirname "$FULL_SOURCE_PATH")"
            git clone "$SOURCE_URL" "$FULL_SOURCE_PATH" || {
                echo "Warning: git clone failed, source may need manual setup"
                echo ""
                exit 1
            }

            # Checkout specific ref if specified
            if [ -n "$SOURCE_REF" ]; then
                echo "Checking out ref: $SOURCE_REF"
                (cd "$FULL_SOURCE_PATH" && git checkout "$SOURCE_REF" 2>&1) || {
                    echo "Warning: failed to checkout ref $SOURCE_REF"
                }
            fi
            echo ""
        else
            echo "Source already exists at: $FULL_SOURCE_PATH"

            # Reset to pinned ref for reproducibility
            if [ -n "$SOURCE_REF" ]; then
                CURRENT_REF=$(cd "$FULL_SOURCE_PATH" && git rev-parse HEAD 2>/dev/null || echo "")

                if [ -z "$CURRENT_REF" ]; then
                    echo "Git not available or not a git repository"
                else
                    echo "Resetting to pinned ref: $SOURCE_REF"
                    (
                        cd "$FULL_SOURCE_PATH" && \
                        git fetch --quiet 2>/dev/null || true && \
                        git checkout "$SOURCE_REF" 2>&1 && \
                        git reset --hard "$SOURCE_REF" 2>&1 && \
                        git clean -fd 2>&1
                    ) || {
                        echo "Warning: failed to reset to ref $SOURCE_REF"
                    }
                    echo "✓ Source reset to clean state at pinned ref"
                fi
            fi
            echo ""
        fi
    fi
fi

# Log test metadata
cat > "${RESULT_DIR}/metadata.json" <<EOF
{
  "example": "$(basename "$EXAMPLE_DIR")",
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "repo_root": "${REPO_ROOT}"
}
EOF

# Parse test.yaml to get command and options
COMMAND=$(grep "^command:" "$TEST_YAML" | sed 's/command: *//' | tr -d '"')

# Parse options - only lines between "options:" and the next section (expected:)
# Keep escaped quotes intact by only removing the outer YAML quotes
OPTIONS=$(awk '/^options:/,/^expected:/ {if ($0 ~ /^  - /) print}' "$TEST_YAML" | sed 's/^  - *//' | sed 's/^"\(.*\)"$/\1/' | tr '\n' ' ')

# Build full command with source directory path
if [ -n "$FULL_SOURCE_PATH" ]; then
    FULL_COMMAND="$COMMAND $OPTIONS $FULL_SOURCE_PATH"
else
    FULL_COMMAND="$COMMAND $OPTIONS"
fi

echo "Command: $FULL_COMMAND"
echo ""

# Record start time
START_TIME=$(date +%s)

# Run the command and capture output
set +e
(
    cd "$EXAMPLE_DIR_ABS"
    eval "$FULL_COMMAND" 2>&1 | tee "${RESULT_DIR}/output.log"
)
EXIT_CODE=$?
set -e

# Record end time
END_TIME=$(date +%s)
RUN_TIME=$((END_TIME - START_TIME))

# Parse statistics from output.log if available
AI_MODEL="null"
AI_CALLS="null"
AI_TIME="null"
PBUILD_CALLS="null"
PBUILD_TIME="null"
TOTAL_RUNTIME="null"

if [ -f "${RESULT_DIR}/output.log" ]; then
    STATS_LINE=$(grep "\[STATS\]" "${RESULT_DIR}/output.log" || echo "")
    if [ -n "$STATS_LINE" ]; then
        AI_MODEL=$(echo "$STATS_LINE" | sed -n 's/.*AI model: \([^ |]*\).*/\1/p' | tr -d ' ')
        AI_CALLS=$(echo "$STATS_LINE" | sed -n 's/.*AI calls: \([0-9]*\).*/\1/p')
        AI_TIME=$(echo "$STATS_LINE" | sed -n 's/.*AI time: \([0-9.]*\)s.*/\1/p')
        PBUILD_CALLS=$(echo "$STATS_LINE" | sed -n 's/.*pbuild calls: \([0-9]*\).*/\1/p')
        PBUILD_TIME=$(echo "$STATS_LINE" | sed -n 's/.*pbuild time: \([0-9.]*\)s.*/\1/p')
        TOTAL_RUNTIME=$(echo "$STATS_LINE" | sed -n 's/.*total runtime: \([0-9.]*\)s.*/\1/p')

        # Only set values if they were successfully parsed
        [ -n "$AI_MODEL" ] && AI_MODEL="\"$AI_MODEL\"" || AI_MODEL="null"
        [ -z "$AI_CALLS" ] && AI_CALLS="null"
        [ -z "$AI_TIME" ] && AI_TIME="null"
        [ -z "$PBUILD_CALLS" ] && PBUILD_CALLS="null"
        [ -z "$PBUILD_TIME" ] && PBUILD_TIME="null"
        [ -z "$TOTAL_RUNTIME" ] && TOTAL_RUNTIME="null"
    fi
fi

# Save benchmark results
cat > "${RESULT_DIR}/benchmark.json" <<EOF
{
  "run_time_seconds": $RUN_TIME,
  "exit_code": $EXIT_CODE,
  "success": $([ $EXIT_CODE -eq 0 ] && echo "true" || echo "false"),
  "ai_model": $AI_MODEL,
  "ai_calls": $AI_CALLS,
  "ai_time_seconds": $AI_TIME,
  "pbuild_calls": $PBUILD_CALLS,
  "pbuild_time_seconds": $PBUILD_TIME,
  "total_runtime_seconds": $TOTAL_RUNTIME
}
EOF

echo ""
echo "----------------------------------------"
echo "Test completed in ${RUN_TIME}s with exit code ${EXIT_CODE}"
echo "Results saved to: $RESULT_DIR"
# TODO: Compare with expected results from test.yaml

exit $EXIT_CODE
