#!/bin/bash
# Run all example test cases

set -e

EXAMPLES_DIR="examples"
TOTAL=0
PASSED=0
FAILED=0

echo "Running all pbuild-ai examples..."
echo "========================================"
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

    if ./scripts/run-example.sh "$example_dir"; then
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
