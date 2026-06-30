#!/bin/bash
# Run a single example test case and collect benchmarks

set -e

usage() {
    echo "Usage: $0 [--model <key>] <example-directory>"
    echo "Example: $0 examples/basic-analyze"
    echo "         $0 --model qwen35 examples/basic-analyze"
    echo ""
    echo "Environment variables:"
    echo "  PBUILD_AI_CMD  Path to pbuild-ai executable (default: from test.yaml)"
    echo "  OLLAMA_HOST    Fallback host (overridden by --model / models.yaml)"
    echo "  OLLAMA_MODEL   Fallback model (overridden by --model / models.yaml)"
    exit 1
}

# Parse optional --model argument
MODEL_KEY=""
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            if [ -z "$2" ]; then
                echo "Error: --model requires a model key argument"
                usage
            fi
            MODEL_KEY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"

if [ -z "$1" ]; then
    usage
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

# Read model configurations from models.yaml + models.yaml.local
MODELS_JSON=$(python3 << 'PYEOF' 2>/dev/null || echo "{}")
import json, os, re

def read_yaml_simple(path):
    data = {}
    current_model = None
    try:
        with open(path) as f:
            for line in f:
                # Strip comments
                line = re.sub(r'#.*$', '', line).rstrip()
                if not line:
                    continue
                # Model key line: "  gemma4:"
                m = re.match(r'^  ([\w.\-][\w.\-]*):\s*$', line)
                if m:
                    current_model = m.group(1)
                    data[current_model] = {}
                    continue
                # Key-value line: "    host: "value"" or "    model: value"
                m = re.match(r'^\s+(\w[\w-]*):\s*(.*)$', line)
                if m and current_model is not None:
                    val = m.group(2).strip()
                    # Strip surrounding quotes
                    if len(val) >= 2 and val[0] == val[-1] and val[0] in '"\'':
                        val = val[1:-1]
                    data[current_model][m.group(1)] = val
    except FileNotFoundError:
        pass
    return data

config = {}
for yaml_file in ['models.yaml', 'models.yaml.local']:
    if os.path.exists(yaml_file):
        cfg = read_yaml_simple(yaml_file)
        for key, val in cfg.items():
            if key not in config:
                config[key] = {}
            config[key].update(val)

print(json.dumps(config))
PYEOF

# Determine model key
if [ -z "$MODEL_KEY" ]; then
    MODEL_KEY=$(python3 -c "
import json, sys, os
d = json.loads(sys.stdin.read())
if not d:
    print('default')
    sys.exit(0)
# Try to match existing OLLAMA_MODEL env var
env_model = os.environ.get('OLLAMA_MODEL', '')
if env_model:
    for k, v in d.items():
        if v.get('model') == env_model:
            print(k)
            sys.exit(0)
# Fall back to first model key
print(next(iter(d.keys())))
" <<< "$MODELS_JSON" 2>/dev/null || echo "default")
fi

# Get model config values
MODEL_HOST=$(python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
print(d.get(key, {}).get('host', '') or '')
" <<< "$MODELS_JSON" "$MODEL_KEY" 2>/dev/null || echo "")

MODEL_NAME=$(python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
print(d.get(key, {}).get('model', '') or '')
" <<< "$MODELS_JSON" "$MODEL_KEY" 2>/dev/null || echo "")

# Export model environment for pbuild-ai
if [ -n "$MODEL_HOST" ]; then
    export OLLAMA_HOST="$MODEL_HOST"
fi
if [ -n "$MODEL_NAME" ]; then
    export OLLAMA_MODEL="$MODEL_NAME"
fi

echo "  Model key: $MODEL_KEY"
[ -n "$MODEL_NAME" ] && echo "  AI model: $MODEL_NAME"
[ -n "$MODEL_HOST" ] && echo "  AI host: $MODEL_HOST"
echo ""

# Create results directory with per-model nesting
RESULT_DIR="${REPO_ROOT}/results/$(basename "$EXAMPLE_DIR")/${MODEL_KEY}/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULT_DIR"

# Check if source needs to be cloned
# Extract values and remove YAML comments
SOURCE_TYPE=$(grep -E "^\s+type:" "$TEST_YAML" | sed 's/.*type:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
SOURCE_URL=$(grep -E "^\s+url:" "$TEST_YAML" | sed 's/.*url:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
SOURCE_REF=$(grep -E "^\s+ref:" "$TEST_YAML" | sed 's/.*ref:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

if [ "$SOURCE_TYPE" = "none" ]; then
    # For --generate mode, create an empty directory where pbuild-ai will generate the package
    SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
    if [ -n "$SOURCE_PATH" ]; then
        # Convert relative path to absolute from repo root
        RELATIVE_PATH="${SOURCE_PATH#../../}"
        FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"

        # Create empty directory for generated files
        mkdir -p "$FULL_SOURCE_PATH"
        echo "Creating directory for generated package: $FULL_SOURCE_PATH"
        echo ""
    else
        echo "Error: --generate mode requires a path field in test.yaml"
        exit 1
    fi
elif [ "$SOURCE_TYPE" = "inline" ]; then
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

        if [ -d "$FULL_SOURCE_PATH" ]; then
            echo "Removing existing source at: $FULL_SOURCE_PATH"
            rm -rf "$FULL_SOURCE_PATH"
        fi

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
    fi
fi

# Parse test.yaml to get command and options
COMMAND=$(grep "^command:" "$TEST_YAML" | sed 's/command: *//' | tr -d '"')

# Default to pbuild-ai if no command specified
if [ -z "$COMMAND" ]; then
    COMMAND="pbuild-ai"
fi

# Allow override via PBUILD_AI_CMD environment variable
if [ -n "$PBUILD_AI_CMD" ]; then
    COMMAND="$PBUILD_AI_CMD"
fi

# Log test metadata
PBUILD_AI_PATH=$(command -v "$COMMAND" 2>/dev/null || echo "$COMMAND")
cat > "${RESULT_DIR}/metadata.json" <<EOF
{
  "example": "$(basename "$EXAMPLE_DIR")",
  "model_key": "${MODEL_KEY}",
  "model_name": "${MODEL_NAME}",
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "repo_root": "${REPO_ROOT}",
  "pbuild_ai_bin": "$PBUILD_AI_PATH"
}
EOF

# Parse options - only lines between "options:" and the next section (expected:)
# Build as array to preserve multi-word arguments properly
OPTIONS_ARRAY=()
while IFS= read -r line; do
    # Remove leading "- " and outer YAML quotes if present
    option=$(echo "$line" | sed 's/^  - *//' | sed 's/^"\(.*\)"$/\1/')
    if [ -n "$option" ]; then
        OPTIONS_ARRAY+=("$option")
    fi
done < <(awk '/^options:/,/^expected:/ {if ($0 ~ /^  - /) print}' "$TEST_YAML")

# Build full command array with source directory path
FULL_COMMAND_ARRAY=("$COMMAND" "${OPTIONS_ARRAY[@]}")
if [ -n "$FULL_SOURCE_PATH" ]; then
    FULL_COMMAND_ARRAY+=("$FULL_SOURCE_PATH")
fi

# Display command for logging (quote multi-word args)
DISPLAY_CMD="$COMMAND"
for opt in "${OPTIONS_ARRAY[@]}"; do
    if [[ "$opt" =~ [[:space:]] ]]; then
        DISPLAY_CMD="$DISPLAY_CMD \"$opt\""
    else
        DISPLAY_CMD="$DISPLAY_CMD $opt"
    fi
done
if [ -n "$FULL_SOURCE_PATH" ]; then
    DISPLAY_CMD="$DISPLAY_CMD $FULL_SOURCE_PATH"
fi

if [ -n "$PBUILD_AI_CMD" ]; then
    echo "Command: $DISPLAY_CMD  (via PBUILD_AI_CMD=$PBUILD_AI_CMD)"
else
    echo "Command: $DISPLAY_CMD"
fi
echo ""

# Record start time
START_TIME=$(date +%s)

# Create a backup of the source directory for diff comparison
BACKUP_DIR=""
if [ -n "$FULL_SOURCE_PATH" ] && [ -d "$FULL_SOURCE_PATH" ]; then
    BACKUP_DIR="${RESULT_DIR}/source_backup"
    echo "Creating backup of source directory for diff..."
    cp -a "$FULL_SOURCE_PATH" "$BACKUP_DIR"
fi

# Run the command and capture output
set +e
(
    cd "$EXAMPLE_DIR_ABS"
    NO_SPINNER=1 "${FULL_COMMAND_ARRAY[@]}" 2>&1 | tee "${RESULT_DIR}/output.log"
)
EXIT_CODE=$?
set -e

# Record end time
END_TIME=$(date +%s)
RUN_TIME=$((END_TIME - START_TIME))

# Create unified diff between backup and current state
FILES_CHANGED=0
DIFF_CONTENT=""
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] && [ -d "$FULL_SOURCE_PATH" ]; then
    echo "Generating diff of changes..."
    # Use diff to compare, excluding .git and build directories
    DIFF_CONTENT=$(diff -Nur \
        --exclude=".git" \
        --exclude="_build.*" \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        "$BACKUP_DIR" "$FULL_SOURCE_PATH" 2>/dev/null || true)

    if [ -n "$DIFF_CONTENT" ]; then
        # Count number of files changed - ensure single integer value
        FILES_CHANGED=$(echo "$DIFF_CONTENT" | grep -c "^diff -Nur" 2>/dev/null || echo "0")
        FILES_CHANGED=$(echo "$FILES_CHANGED" | head -1 | tr -d '\n')
        echo "$DIFF_CONTENT" > "${RESULT_DIR}/diff.patch"
        echo "✓ Captured diff for $FILES_CHANGED file(s)"
    fi

    # Clean up backup directory to save space
    rm -rf "$BACKUP_DIR"
fi

# If diff didn't capture changes, try counting from pbuild-ai output as fallback
if [ "$FILES_CHANGED" -eq 0 ] 2>/dev/null && [ -f "${RESULT_DIR}/output.log" ]; then
    # Count "[TOOL] --- Diff for" lines which indicate file modifications
    OUTPUT_FILES=$(grep -c "\[TOOL\] --- Diff for" "${RESULT_DIR}/output.log" 2>/dev/null || echo "0")
    # Ensure it's a single integer
    OUTPUT_FILES=$(echo "$OUTPUT_FILES" | head -1 | tr -d '\n')
    if [ -n "$OUTPUT_FILES" ] && [ "$OUTPUT_FILES" -gt 0 ] 2>/dev/null; then
        FILES_CHANGED=$OUTPUT_FILES
        echo "✓ Counted $FILES_CHANGED file modification(s) from output"
    fi
fi

# Parse statistics from output.log if available
AI_MODEL="null"
AI_CALLS="null"
AI_TIME="null"
PBUILD_CALLS="null"
PBUILD_TIME="null"
TOTAL_RUNTIME="null"
PBUILD_AI_VERSION="null"

if [ -f "${RESULT_DIR}/output.log" ]; then
    # Extract pbuild-ai version from [PBUILD-AI] Version line
    VERSION_LINE=$(grep "^\[PBUILD-AI\] Version" "${RESULT_DIR}/output.log" | head -1 || echo "")
    if [ -n "$VERSION_LINE" ]; then
        PBUILD_AI_VERSION=$(echo "$VERSION_LINE" | sed -n 's/.*Version \([0-9.]*\).*/\1/p')
        [ -n "$PBUILD_AI_VERSION" ] && PBUILD_AI_VERSION="\"$PBUILD_AI_VERSION\"" || PBUILD_AI_VERSION="null"
    fi

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
  "files_changed": $FILES_CHANGED,
  "pbuild_ai_version": $PBUILD_AI_VERSION,
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
