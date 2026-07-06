#!/bin/bash
# Run a single example test case and collect benchmarks

set -e

usage() {
    echo "Usage: $0 [--model <key>|--all-models] <example-directory>"
    echo "Example: $0 examples/basic-analyze"
    echo "         $0 --model qwen35 examples/basic-analyze"
    echo "         $0 --all-models examples/basic-analyze"
    echo ""
    echo "Options:"
    echo "  --model <key>     Run with specific model from models.yaml"
    echo "  --all-models      Run with all models defined in models.yaml"
    echo ""
    echo "Environment variables:"
    echo "  PBUILD_AI_CMD  Path to pbuild-ai executable (default: from test.yaml)"
    echo "  OLLAMA_HOST    Fallback host (overridden by --model / models.yaml)"
    echo "  OLLAMA_MODEL   Fallback model (overridden by --model / models.yaml)"
    exit 1
}

# Parse optional --model or --all-models argument
MODEL_KEY=""
ALL_MODELS=false
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
        --all-models)
            ALL_MODELS=true
            shift
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
if [ ${#POSITIONAL_ARGS[@]} -eq 0 ]; then
    usage
fi

REPO_ROOT=$(pwd)

# Read model configurations from models.yaml
MODELS_JSON=$(python3 -c 'import json, os, re

def read_yaml_simple(path):
    """Parse YAML with default:, hosts:, and models: sections"""
    data = {"default": None, "hosts": {}, "models": {}}
    current_section = None
    current_key = None

    try:
        with open(path) as f:
            for line in f:
                line = re.sub(r"#.*$", "", line).rstrip()
                if not line:
                    continue

                # Top-level default: key
                if line.startswith("default:"):
                    m = re.match(r"default:\s*\"?([^\"]+)\"?", line)
                    if m:
                        data["default"] = m.group(1)
                    continue

                # Top-level section: hosts: or models:
                if line.startswith("hosts:"):
                    current_section = "hosts"
                    continue
                elif line.startswith("models:"):
                    current_section = "models"
                    continue

                # Entry key: "  keyname:"
                m = re.match(r"^  ([\w.\-][\w.\-]*):\s*$", line)
                if m and current_section:
                    current_key = m.group(1)
                    data[current_section][current_key] = {}
                    continue

                # Property: "    propname: value"
                m = re.match(r"^\s+(\w[\w-]*):\s*(.*)$", line)
                if m and current_section and current_key:
                    val = m.group(2).strip()
                    if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'"'"'":
                        val = val[1:-1]
                    data[current_section][current_key][m.group(1)] = val
    except FileNotFoundError:
        pass
    return data

# Read models.yaml only
config = read_yaml_simple("models.yaml")

# Resolve host references in models
for model_key, model_data in config["models"].items():
    host_key = model_data.get("host", "")
    if host_key and host_key in config["hosts"]:
        # Replace host key with actual URL and metadata
        model_data["host_url"] = config["hosts"][host_key].get("url", "")
        model_data["host_name"] = config["hosts"][host_key].get("name", host_key)
        model_data["host_description"] = config["hosts"][host_key].get("description", "")
    else:
        # No host or unknown host - use empty/fallback
        model_data["host_url"] = ""
        model_data["host_name"] = ""
        model_data["host_description"] = ""

print(json.dumps(config))
' 2>/dev/null || echo "{}")

# Handle --all-models: run for each model key (from models.yaml only, not .local)
if [ "$ALL_MODELS" = true ]; then
    MODEL_KEYS=$(python3 -c 'import json, os, re

def read_yaml_simple(path):
    """Parse YAML with default:, hosts:, and models: sections"""
    data = {"default": None, "hosts": {}, "models": {}}
    current_section = None
    current_key = None

    try:
        with open(path) as f:
            for line in f:
                line = re.sub(r"#.*$", "", line).rstrip()
                if not line:
                    continue

                # Top-level default: key
                if line.startswith("default:"):
                    m = re.match(r"default:\s*\"?([^\"]+)\"?", line)
                    if m:
                        data["default"] = m.group(1)
                    continue

                # Top-level section: hosts: or models:
                if line.startswith("hosts:"):
                    current_section = "hosts"
                    continue
                elif line.startswith("models:"):
                    current_section = "models"
                    continue

                # Entry key: "  keyname:"
                m = re.match(r"^  ([\w.\-][\w.\-]*):\s*$", line)
                if m and current_section:
                    current_key = m.group(1)
                    data[current_section][current_key] = {}
                    continue

                # Property: "    propname: value"
                m = re.match(r"^\s+(\w[\w-]*):\s*(.*)$", line)
                if m and current_section and current_key:
                    val = m.group(2).strip()
                    if len(val) >= 2 and val[0] == val[-1] and val[0] in "\"'"'"'":
                        val = val[1:-1]
                    data[current_section][current_key][m.group(1)] = val
    except FileNotFoundError:
        pass
    return data

# Read only models.yaml, not .local
config = read_yaml_simple("models.yaml")
models = config.get("models", {})
if not models:
    print("default")
else:
    print(" ".join(sorted(models.keys())))
' 2>/dev/null || echo "default")

    OVERALL_EXIT=0
    for EXAMPLE_DIR in "${POSITIONAL_ARGS[@]}"; do
        for model in $MODEL_KEYS; do
            echo ""
            echo "========================================"
            echo "Starting run: $(basename "$EXAMPLE_DIR") with model: $model"
            echo "========================================"
            if ! "$0" --model "$model" "$EXAMPLE_DIR"; then
                echo "⚠ $(basename "$EXAMPLE_DIR") with $model failed!"
                OVERALL_EXIT=1
            fi
        done
    done

    echo ""
    echo "========================================"
    echo "All models completed"
    echo "========================================"
    exit $OVERALL_EXIT
fi

# Determine model key
if [ -z "$MODEL_KEY" ]; then
    MODEL_KEY=$(echo "$MODELS_JSON" | python3 -c "
import json, sys, os
d = json.loads(sys.stdin.read())
models = d.get('models', {})
if not models:
    print('default')
    sys.exit(0)
env_model = os.environ.get('OLLAMA_MODEL', '')
if env_model:
    for k, v in models.items():
        if v.get('model') == env_model:
            print(k)
            sys.exit(0)
# Use configured default if available
default_model = d.get('default')
if default_model and default_model in models:
    print(default_model)
    sys.exit(0)
# Fall back to first model key
print(next(iter(models.keys())))
" 2>/dev/null || echo "default")
fi

# Validate that the model key exists in models.yaml
if [ "$MODEL_KEY" != "default" ]; then
    VALID_MODEL=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
if key in models:
    print('yes')
else:
    print('no')
" "$MODEL_KEY" 2>/dev/null || echo "no")

    if [ "$VALID_MODEL" = "no" ]; then
        echo "Error: Model key '$MODEL_KEY' not found in models.yaml"
        echo "Available model keys: $(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
models = d.get('models', {})
print(', '.join(sorted(models.keys())) if models else 'default')
" 2>/dev/null || echo 'default')"
        exit 1
    fi
fi

MODEL_HOST=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
print(models.get(key, {}).get('host_url', '') or '')
" "$MODEL_KEY" 2>/dev/null || echo "")

MODEL_NAME=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
print(models.get(key, {}).get('model', '') or '')
" "$MODEL_KEY" 2>/dev/null || echo "")

MODEL_HOST_NAME=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
print(models.get(key, {}).get('host_name', '') or '')
" "$MODEL_KEY" 2>/dev/null || echo "")

MODEL_HOST_DESC=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
print(models.get(key, {}).get('host_description', '') or '')
" "$MODEL_KEY" 2>/dev/null || echo "")

MODEL_TIMEOUT=$(echo "$MODELS_JSON" | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
key = sys.argv[1]
models = d.get('models', {})
print(models.get(key, {}).get('timeout', '') or '')
" "$MODEL_KEY" 2>/dev/null || echo "")

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

# Loop over all example directories
OVERALL_EXIT=0
for EXAMPLE_DIR in "${POSITIONAL_ARGS[@]}"; do
    TEST_YAML="${EXAMPLE_DIR}/test.yaml"
    if [ ! -f "$TEST_YAML" ]; then
        echo "Error: Test file not found: $TEST_YAML"
        OVERALL_EXIT=1
        continue
    fi

    EXAMPLE_DIR_ABS="${REPO_ROOT}/${EXAMPLE_DIR}"

    echo "========================================"
    echo "Running example: $EXAMPLE_DIR"
    echo "========================================"
    echo ""

    # Sanitize MODEL_KEY for filesystem (replace : with -)
    MODEL_KEY_SAFE=$(echo "$MODEL_KEY" | tr ':' '-')
    RESULT_DIR="${REPO_ROOT}/docs/results/$(basename "$EXAMPLE_DIR")/${MODEL_KEY_SAFE}/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$RESULT_DIR"

    SOURCE_TYPE=$(grep -E "^\s+type:" "$TEST_YAML" | sed 's/.*type:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
    SOURCE_URL=$(grep -E "^\s+url:" "$TEST_YAML" | sed 's/.*url:\s*//' | sed 's/#.*//' | tr -d '"' | tr -d ' ')
    SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
    SOURCE_REF=$(grep -E "^\s+ref:" "$TEST_YAML" | sed 's/.*ref:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)

    FULL_SOURCE_PATH=""
    if [ "$SOURCE_TYPE" = "none" ]; then
        SOURCE_PATH=$(grep -E "^\s+path:" "$TEST_YAML" | sed 's/.*path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
        if [ -n "$SOURCE_PATH" ]; then
            RELATIVE_PATH="${SOURCE_PATH#../../}"
            FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"
            # Clean directory to ensure diff shows only new generated files
            rm -rf "$FULL_SOURCE_PATH"
            mkdir -p "$FULL_SOURCE_PATH"
            echo "Creating clean directory for generated package: $FULL_SOURCE_PATH"
            echo ""
        else
            echo "Error: --generate mode requires a path field in test.yaml"
            OVERALL_EXIT=1
            continue
        fi
    elif [ "$SOURCE_TYPE" = "inline" ]; then
        if [ -n "$SOURCE_PATH" ]; then
            FULL_SOURCE_PATH="${EXAMPLE_DIR_ABS}/${SOURCE_PATH}"
            echo "Using inline source at: $FULL_SOURCE_PATH"
            echo ""
        fi
    elif [ "$SOURCE_TYPE" = "local" ]; then
        if [ -n "$SOURCE_PATH" ]; then
            LOCAL_PATH=$(grep -E "^\s+local_path:" "$TEST_YAML" | sed 's/.*local_path:\s*//' | sed 's/#.*//' | tr -d '"' | xargs)
            if [ -z "$LOCAL_PATH" ]; then
                echo "Error: local mode requires local_path field in test.yaml"
                OVERALL_EXIT=1
                continue
            fi
            LOCAL_PATH="${LOCAL_PATH/#\~/$HOME}"
            if [[ "$LOCAL_PATH" != /* ]]; then
                LOCAL_PATH="${EXAMPLE_DIR_ABS}/${LOCAL_PATH}"
                LOCAL_PATH=$(cd "$(dirname "$LOCAL_PATH")" 2>/dev/null && pwd)/$(basename "$LOCAL_PATH") || LOCAL_PATH=""
            fi
            if [ -z "$LOCAL_PATH" ] || [ ! -d "$LOCAL_PATH" ]; then
                echo "Error: Local source path does not exist: $LOCAL_PATH"
                OVERALL_EXIT=1
                continue
            fi
            RELATIVE_PATH="${SOURCE_PATH#../../}"
            FULL_SOURCE_PATH="${REPO_ROOT}/${RELATIVE_PATH}"
            echo "Copying local source to temporary location..."
            echo "  From: $LOCAL_PATH"
            echo "  To: $FULL_SOURCE_PATH"
            rm -rf "$FULL_SOURCE_PATH"
            mkdir -p "$(dirname "$FULL_SOURCE_PATH")"
            cp -a "$LOCAL_PATH" "$FULL_SOURCE_PATH"
            echo "✓ Local source copied to clean state"
            echo ""
        fi
    elif [ "$SOURCE_TYPE" = "remote" ] || [ "$SOURCE_TYPE" = "clone" ]; then
        if [ -n "$SOURCE_URL" ] && [ -n "$SOURCE_PATH" ]; then
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
                OVERALL_EXIT=1
                continue
            }
            if [ -n "$SOURCE_REF" ]; then
                echo "Checking out ref: $SOURCE_REF"
                (cd "$FULL_SOURCE_PATH" && git checkout "$SOURCE_REF" 2>&1) || {
                    echo "Warning: failed to checkout ref $SOURCE_REF"
                }
            fi
            echo ""
        fi
    fi

    COMMAND=$(grep "^command:" "$TEST_YAML" | sed 's/command: *//' | tr -d '"')
    if [ -z "$COMMAND" ]; then
        COMMAND="pbuild-ai"
    fi
    if [ -n "$PBUILD_AI_CMD" ]; then
        COMMAND="$PBUILD_AI_CMD"
    fi

    PBUILD_AI_PATH=$(command -v "$COMMAND" 2>/dev/null || echo "$COMMAND")
    cat > "${RESULT_DIR}/metadata.json" <<EOF
{
  "example": "$(basename "$EXAMPLE_DIR")",
  "model_key": "${MODEL_KEY}",
  "model_name": "${MODEL_NAME}",
  "model_host_name": "${MODEL_HOST_NAME}",
  "model_host_description": "${MODEL_HOST_DESC}",
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "repo_root": "${REPO_ROOT}",
  "pbuild_ai_bin": "$PBUILD_AI_PATH"
}
EOF

    OPTIONS_ARRAY=()
    while IFS= read -r line; do
        option=$(echo "$line" | sed 's/^  - *//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
        if [ -n "$option" ]; then
            OPTIONS_ARRAY+=("$option")
        fi
    done < <(awk '/^options:/,/^expected:/ {if ($0 ~ /^  - /) print}' "$TEST_YAML")

    # Add --build-log parameter to capture build logs separately
    # pbuild-ai will replace _NUMBER_ with an auto-incrementing counter
    BUILD_LOG_FILE="${RESULT_DIR}/build-_NUMBER_.log"

    FULL_COMMAND_ARRAY=("$COMMAND" "${OPTIONS_ARRAY[@]}" "--build-log" "$BUILD_LOG_FILE")

    # Add --ollama-timeout if model specifies a timeout
    if [ -n "$MODEL_TIMEOUT" ]; then
        FULL_COMMAND_ARRAY+=("--ollama-timeout" "$MODEL_TIMEOUT")
    fi
    if [ -n "$FULL_SOURCE_PATH" ]; then
        FULL_COMMAND_ARRAY+=("$FULL_SOURCE_PATH")
    fi

    DISPLAY_CMD="$COMMAND"
    for opt in "${OPTIONS_ARRAY[@]}"; do
        if [[ "$opt" =~ [[:space:]] ]]; then
            DISPLAY_CMD="$DISPLAY_CMD \"$opt\""
        else
            DISPLAY_CMD="$DISPLAY_CMD $opt"
        fi
    done
    DISPLAY_CMD="$DISPLAY_CMD --build-log $BUILD_LOG_FILE"
    if [ -n "$MODEL_TIMEOUT" ]; then
        DISPLAY_CMD="$DISPLAY_CMD --ollama-timeout $MODEL_TIMEOUT"
    fi
    if [ -n "$FULL_SOURCE_PATH" ]; then
        DISPLAY_CMD="$DISPLAY_CMD $FULL_SOURCE_PATH"
    fi
    if [ -n "$PBUILD_AI_CMD" ]; then
        echo "Command: $DISPLAY_CMD  (via PBUILD_AI_CMD=$PBUILD_AI_CMD)"
    else
        echo "Command: $DISPLAY_CMD"
    fi
    echo ""

    START_TIME=$(date +%s)

    # Create a backup of the source directory for diff comparison
    BACKUP_DIR=""
    if [ -n "$FULL_SOURCE_PATH" ] && [ -d "$FULL_SOURCE_PATH" ]; then
        BACKUP_DIR="${RESULT_DIR}/source_backup"
        echo "Creating backup of source directory for diff..."
        cp -a "$FULL_SOURCE_PATH" "$BACKUP_DIR"
    fi

    # Run the command and capture output.
    # Enable pipefail so $? reflects pbuild-ai's exit code rather than tee's,
    # otherwise a failed pbuild-ai run would be reported as exit code 0.
    set +e
    set -o pipefail
    (
        cd "$EXAMPLE_DIR_ABS"
        NO_SPINNER=1 "${FULL_COMMAND_ARRAY[@]}" 2>&1 | tee "${RESULT_DIR}/output.log"
    )
    EXIT_CODE=$?
    set +o pipefail
    set -e

    # Record end time
    END_TIME=$(date +%s)
    RUN_TIME=$((END_TIME - START_TIME))

    # Create unified diff between backup and current state
    FILES_CHANGED=0
    DIFF_CONTENT=""
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] && [ -d "$FULL_SOURCE_PATH" ]; then
        echo "Generating diff of changes..."
        DIFF_CONTENT=$(diff -Nur \
            --exclude=".git" \
            --exclude="_build.*" \
            --exclude="*.pyc" \
            --exclude="__pycache__" \
            --exclude=".pbuild" \
            --exclude=".pai.context" \
            "$BACKUP_DIR" "$FULL_SOURCE_PATH" 2>/dev/null || true)

        if [ -n "$DIFF_CONTENT" ]; then
            FILES_CHANGED=$(echo "$DIFF_CONTENT" | grep -c "^diff -Nur" 2>/dev/null || echo "0")
            FILES_CHANGED=$(echo "$FILES_CHANGED" | head -1 | tr -d '\n')

            # Make paths relative to avoid exposing local paths
            BACKUP_BASENAME=$(basename "$BACKUP_DIR")
            SOURCE_PATH_CLEAN=$(echo "$SOURCE_PATH" | sed 's|^\.\./||; s|^\.\./||')
            DIFF_CONTENT_CLEAN=$(echo "$DIFF_CONTENT" | sed "s|$BACKUP_DIR|$BACKUP_BASENAME|g" | sed "s|$FULL_SOURCE_PATH|$SOURCE_PATH_CLEAN|g")

            echo "$DIFF_CONTENT_CLEAN" > "${RESULT_DIR}/diff.patch"
            echo "✓ Captured diff for $FILES_CHANGED file(s)"
        fi

        rm -rf "$BACKUP_DIR"
    fi

    if [ "$FILES_CHANGED" -eq 0 ] 2>/dev/null && [ -f "${RESULT_DIR}/output.log" ]; then
        OUTPUT_FILES=$(grep -c "\[TOOL\] --- Diff for" "${RESULT_DIR}/output.log" 2>/dev/null || echo "0")
        OUTPUT_FILES=$(echo "$OUTPUT_FILES" | head -1 | tr -d '\n')
        if [ -n "$OUTPUT_FILES" ] && [ "$OUTPUT_FILES" -gt 0 ] 2>/dev/null; then
            FILES_CHANGED=$OUTPUT_FILES
            echo "✓ Counted $FILES_CHANGED file modification(s) from output"
        fi
    fi

    AI_MODEL="null"
    AI_CALLS="null"
    AI_TIME="null"
    PBUILD_CALLS="null"
    PBUILD_TIME="null"
    TOTAL_RUNTIME="null"
    PBUILD_AI_VERSION="null"

    if [ -f "${RESULT_DIR}/output.log" ]; then
        VERSION_LINE=$(grep "^\[PBUILD-AI\] Version" "${RESULT_DIR}/output.log" | head -1 || echo "")
        if [ -n "$VERSION_LINE" ]; then
            PBUILD_AI_VERSION=$(echo "$VERSION_LINE" | sed -n 's/.*Version \([0-9.]*\).*/\1/p')
            [ -n "$PBUILD_AI_VERSION" ] && PBUILD_AI_VERSION="\"$PBUILD_AI_VERSION\"" || PBUILD_AI_VERSION="null"
        fi
        STATS_LINE=$(grep "\[STATS\]" "${RESULT_DIR}/output.log" | tail -1 || echo "")
        if [ -n "$STATS_LINE" ]; then
            AI_MODEL=$(echo "$STATS_LINE" | sed -n 's/.*AI model: \([^ |]*\).*/\1/p' | tr -d ' ')
            AI_CALLS=$(echo "$STATS_LINE" | sed -n 's/.*AI calls: \([0-9]*\).*/\1/p')
            AI_TIME=$(echo "$STATS_LINE" | sed -n 's/.*AI time: \([0-9.]*\)s.*/\1/p')
            PBUILD_CALLS=$(echo "$STATS_LINE" | sed -n 's/.*pbuild calls: \([0-9]*\).*/\1/p')
            PBUILD_TIME=$(echo "$STATS_LINE" | sed -n 's/.*pbuild time: \([0-9.]*\)s.*/\1/p')
            TOTAL_RUNTIME=$(echo "$STATS_LINE" | sed -n 's/.*total runtime: \([0-9.]*\)s.*/\1/p')
            [ -n "$AI_MODEL" ] && AI_MODEL="\"$AI_MODEL\"" || AI_MODEL="null"
            [ -z "$AI_CALLS" ] && AI_CALLS="null"
            [ -z "$AI_TIME" ] && AI_TIME="null"
            [ -z "$PBUILD_CALLS" ] && PBUILD_CALLS="null"
            [ -z "$PBUILD_TIME" ] && PBUILD_TIME="null"
            [ -z "$TOTAL_RUNTIME" ] && TOTAL_RUNTIME="null"
        fi
    fi

    if [ $EXIT_CODE -eq 0 ]; then
        STATUS="\"success\""
        SUCCESS="true"
    elif [ $EXIT_CODE -eq 1 ]; then
        STATUS="\"failed\""
        SUCCESS="false"
    else
        STATUS="\"error\""
        SUCCESS="false"
    fi

    cat > "${RESULT_DIR}/benchmark.json" <<EOF
{
  "run_time_seconds": $RUN_TIME,
  "exit_code": $EXIT_CODE,
  "status": $STATUS,
  "success": $SUCCESS,
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

    # Copy source directory on successful run
    if [ $EXIT_CODE -eq 0 ] && [ -n "$FULL_SOURCE_PATH" ] && [ -d "$FULL_SOURCE_PATH" ]; then
        echo "Copying successful source to result directory..."
        SOURCE_COPY_DIR="${RESULT_DIR}/source"
        rsync -a --exclude=.git "$FULL_SOURCE_PATH/" "$SOURCE_COPY_DIR/"
        # Replace larger binary/archive files with placeholder text
        find "$SOURCE_COPY_DIR" -type f \( \
            -name "*.tar" -o -name "*.tar.gz" -o -name "*.tgz" \
            -o -name "*.tar.bz2" -o -name "*.tar.xz" \
            -o -name "*.tar.zst" -o -name "*.zip" \
            -o -name "*.rpm" -o -name "*.deb" -o -name "*.dsc" \
            -o -name "*.iso" -o -name "*.img" \
        \) -exec sh -c 'echo "Empty to save storage space in pbuild-ai-examples" > "$1"' _ {} \;
        echo "Source copied to: $SOURCE_COPY_DIR"
    fi

    if [ $EXIT_CODE -ne 0 ]; then
        OVERALL_EXIT=1
    fi
    echo ""
done

exit $OVERALL_EXIT
