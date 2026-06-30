#!/bin/bash
# Run all example test cases

set -e

EXAMPLES_DIR="examples"
MODEL_FLAG=""

# Parse optional --model argument
while [[ $# -gt 0 ]]; do
    case "$1" in
        --model)
            if [ -z "$2" ]; then
                echo "Error: --model requires a model key argument"
                exit 1
            fi
            MODEL_FLAG="--model $2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--model <key>]"
            echo "Run all example test cases with optional model selection."
            echo ""
            echo "  --model <key>  Use a specific model from models.yaml (default: first model)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

TOTAL=0
PASSED=0
FAILED=0

echo "Running all pbuild-ai examples..."
echo "========================================"
[ -n "$MODEL_FLAG" ] && echo "  Model: $(echo $MODEL_FLAG | cut -d' ' -f2)"
echo ""

for example_dir in "$EXAMPLES_DIR"/*; do
    if [ ! -d "$example_dir" ]; then
        continue
    fi

    if [ ! -f "$example_dir/test.yaml" ]; then
        echo "Skipping $example_dir (no test.yaml)"
        continue
    fi

    TOTAL=$((TOTAL + 1))

    echo "[$TOTAL] Running: $(basename "$example_dir")"

    if ./scripts/run-example.sh $MODEL_FLAG "$example_dir"; then
        PASSED=$((PASSED + 1))
        echo "✓ PASSED"
    else
        FAILED=$((FAILED + 1))
        echo "✗ FAILED"
    fi

    echo ""
done

echo "========================================"
echo "Results: $PASSED passed, $FAILED failed out of $TOTAL total"
echo ""

if [ $FAILED -gt 0 ]; then
    exit 1
fi
