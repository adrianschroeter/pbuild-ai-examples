#!/bin/bash
# Generate HTML report from benchmark results

set -e

OUTPUT_FILE="docs/benchmark-report.html"
RESULTS_JSON="docs/results.json"
RESULTS_DIR="results"

echo "Generating benchmark report..."

cat > "$OUTPUT_FILE" <<'HTMLHEAD'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Benchmark Report - pbuild-ai Examples</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .benchmark-table {
            width: 100%;
            background: white;
            border-collapse: collapse;
            box-shadow: var(--shadow-md);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }
        .benchmark-table th {
            background: var(--opensuse-dark);
            color: white;
            font-weight: 600;
            padding: 1rem;
            text-align: left;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .benchmark-table td {
            padding: 1rem;
            border-bottom: 1px solid var(--color-border);
        }
        .benchmark-table tr:last-child td {
            border-bottom: none;
        }
        .benchmark-table tr:hover {
            background: var(--color-bg-gray);
        }
        .status-badge {
            display: inline-block;
            padding: 0.375rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 600;
        }
        .status-success {
            background: #d4edda;
            color: #155724;
        }
        .status-failed {
            background: #f8d7da;
            color: #721c24;
        }
        .timing {
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 0.9rem;
            color: var(--color-primary);
            font-weight: 600;
        }
        .trend-cell {
            font-size: 0.875rem;
            white-space: nowrap;
        }
        .timestamp-text {
            color: var(--color-text-light);
            font-size: 0.85rem;
        }
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--color-primary);
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 2rem;
            transition: var(--transition);
        }
        .back-link:hover {
            color: var(--color-primary-dark);
        }
        .back-link svg {
            width: 20px;
            height: 20px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <div class="header-content">
                <div class="logo-section">
                    <svg class="logo-icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    <h1 class="site-title">pbuild-ai Examples</h1>
                </div>
                <nav class="nav">
                    <a href="index.html" class="nav-link">Home</a>
                    <a href="benchmark-report.html" class="nav-link">Benchmarks</a>
                    <a href="https://github.com/adrianschroeter/pbuild-ai" class="nav-link">GitHub</a>
                </nav>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div class="container">
            <a href="index.html" class="back-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
                Back to Examples
            </a>

            <section class="section">
                <div class="section-header">
                    <h2 class="section-title">Benchmark Report</h2>
                    <p class="section-subtitle">Performance metrics for pbuild-ai examples</p>
                    <p class="timestamp-text">Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
                </div>

                <table class="benchmark-table">
                    <thead>
                        <tr>
                            <th>Example</th>
                            <th>Status</th>
                            <th>Run Time</th>
                            <th>Trend</th>
                            <th>Exit Code</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
HTMLHEAD

# Find latest benchmark result per example
if [ -d "$RESULTS_DIR" ]; then
    # Get list of unique example names
    EXAMPLES=$(find "$RESULTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

    for EXAMPLE in $EXAMPLES; do
        # Find all benchmarks for this example (sorted by timestamp)
        ALL_BENCHMARKS=$(find "$RESULTS_DIR/$EXAMPLE" -name "benchmark.json" -type f 2>/dev/null | sort)
        BENCHMARK_COUNT=$(echo "$ALL_BENCHMARKS" | grep -c "benchmark.json" || echo "0")

        # Find the latest benchmark
        LATEST_BENCHMARK=$(echo "$ALL_BENCHMARKS" | tail -1)

        if [ -n "$LATEST_BENCHMARK" ]; then
            TIMESTAMP=$(basename "$(dirname "$LATEST_BENCHMARK")")

            # Parse latest benchmark JSON
            RUN_TIME=$(grep "run_time_seconds" "$LATEST_BENCHMARK" | grep -oE '[0-9.]+' || echo "0")
            SUCCESS=$(grep "\"success\"" "$LATEST_BENCHMARK" | grep -o "true\|false" || echo "false")
            EXIT_CODE=$(grep "exit_code" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "1")

            if [ "$SUCCESS" = "true" ]; then
                STATUS_CLASS="status-success"
                STATUS_TEXT="✓ PASSED"
            else
                STATUS_CLASS="status-failed"
                STATUS_TEXT="✗ FAILED"
            fi

            # Calculate trend if we have multiple results
            TREND_HTML="-"
            if [ "$BENCHMARK_COUNT" -gt 1 ]; then
                # Get the first (oldest) benchmark
                FIRST_BENCHMARK=$(echo "$ALL_BENCHMARKS" | head -1)
                FIRST_RUN_TIME=$(grep "run_time_seconds" "$FIRST_BENCHMARK" | grep -oE '[0-9.]+' || echo "0")

                # Calculate percentage change (using bc-like arithmetic with awk)
                if [ "$FIRST_RUN_TIME" != "0" ] && [ -n "$FIRST_RUN_TIME" ]; then
                    PERCENT_CHANGE=$(awk -v latest="$RUN_TIME" -v first="$FIRST_RUN_TIME" 'BEGIN {
                        if (first > 0) {
                            change = ((latest - first) / first) * 100
                            printf "%.0f", change
                        } else {
                            print "0"
                        }
                    }')

                    # Format the trend display
                    if [ "$PERCENT_CHANGE" -lt 0 ]; then
                        # Speed improvement (negative means faster)
                        ABS_CHANGE=$(echo "$PERCENT_CHANGE" | tr -d '-')
                        TREND_HTML="<span style=\"color: #22c55e; font-weight: 600;\">↓ ${ABS_CHANGE}% faster</span>"
                    elif [ "$PERCENT_CHANGE" -gt 0 ]; then
                        # Speed regression (positive means slower)
                        TREND_HTML="<span style=\"color: #ef4444; font-weight: 600;\">↑ ${PERCENT_CHANGE}% slower</span>"
                    else
                        # No change
                        TREND_HTML="<span style=\"color: #64748b;\">→ same</span>"
                    fi
                fi
            fi

            cat >> "$OUTPUT_FILE" <<EOF
                        <tr>
                            <td><strong>$EXAMPLE</strong></td>
                            <td><span class="status-badge $STATUS_CLASS">$STATUS_TEXT</span></td>
                            <td><span class="timing">${RUN_TIME}s</span></td>
                            <td>$TREND_HTML</td>
                            <td>$EXIT_CODE</td>
                            <td class="timestamp-text">$TIMESTAMP</td>
                        </tr>
EOF
        fi
    done
fi

# If no results, add placeholder
if [ ! -d "$RESULTS_DIR" ] || [ -z "$(find "$RESULTS_DIR" -name "benchmark.json" 2>/dev/null)" ]; then
    cat >> "$OUTPUT_FILE" <<'EOF'
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 3rem; color: var(--color-text-light);">
                                No benchmark results available yet. Run examples to generate data.
                            </td>
                        </tr>
EOF
fi

cat >> "$OUTPUT_FILE" <<'HTMLFOOT'
                    </tbody>
                </table>
            </section>

            <section class="section">
                <div class="cta-card">
                    <h2 class="cta-title">Run Your Own Benchmarks</h2>
                    <p class="cta-text">
                        Clone the repository and run the examples to generate your own benchmark data.
                    </p>
                    <div class="cta-buttons">
                        <a href="https://github.com/adrianschroeter/pbuild-ai-examples" class="btn btn-outline btn-large">
                            Get Started
                        </a>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h4 class="footer-title">pbuild-ai</h4>
                    <p class="footer-text">
                        AI-powered package building for openSUSE
                    </p>
                </div>
                <div class="footer-section">
                    <h4 class="footer-title">Resources</h4>
                    <ul class="footer-links">
                        <li><a href="https://github.com/adrianschroeter/pbuild-ai">pbuild-ai</a></li>
                        <li><a href="https://github.com/adrianschroeter/pbuild-ai-examples">Examples Repo</a></li>
                        <li><a href="https://github.com/openSUSE/obs-build/">pbuild Tool</a></li>
                        <li><a href="https://github.com/openSUSE/pbuild">pbuild GitHub action</a></li>
                    </ul>
                </div>
                <div class="footer-section">
                    <h4 class="footer-title">Community</h4>
                    <ul class="footer-links">
                        <li><a href="https://www.opensuse.org/">openSUSE</a></li>
                        <li><a href="https://github.com/adrianschroeter/pbuild-ai-examples/issues">Report Issues</a></li>
                        <li><a href="https://github.com/adrianschroeter/pbuild-ai-examples">Contribute</a></li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>Part of the openSUSE ecosystem • MIT License</p>
            </div>
        </div>
    </footer>
</body>
</html>
HTMLFOOT

echo "Report generated: $OUTPUT_FILE"

# Generate results.json for JavaScript consumption
echo "Generating results manifest..."

cat > "$RESULTS_JSON" <<'JSONHEAD'
{
  "generated": "TIMESTAMP_PLACEHOLDER",
  "examples": {
JSONHEAD

# Replace timestamp placeholder
sed -i "s/TIMESTAMP_PLACEHOLDER/$(date -Iseconds)/" "$RESULTS_JSON"

# Build JSON data
FIRST=true
if [ -d "$RESULTS_DIR" ]; then
    EXAMPLES=$(find "$RESULTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

    for EXAMPLE in $EXAMPLES; do
        # Find all benchmarks for trend calculation
        ALL_BENCHMARKS=$(find "$RESULTS_DIR/$EXAMPLE" -name "benchmark.json" -type f 2>/dev/null | sort)
        BENCHMARK_COUNT=$(echo "$ALL_BENCHMARKS" | grep -c "benchmark.json" || echo "0")

        LATEST_BENCHMARK=$(echo "$ALL_BENCHMARKS" | tail -1)

        if [ -n "$LATEST_BENCHMARK" ]; then
            RESULT_DIR=$(dirname "$LATEST_BENCHMARK")
            TIMESTAMP=$(basename "$RESULT_DIR")
            OUTPUT_LOG="${RESULT_DIR}/output.log"

            # Parse benchmark data
            RUN_TIME=$(grep "run_time_seconds" "$LATEST_BENCHMARK" | grep -oE '[0-9.]+' || echo "0")
            SUCCESS=$(grep "\"success\"" "$LATEST_BENCHMARK" | grep -o "true\|false" || echo "false")
            EXIT_CODE=$(grep "exit_code" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "1")
            FILES_CHANGED=$(grep "files_changed" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "0")

            # Fallback: If files_changed is 0 but output shows file modifications, count them
            if [ -z "$FILES_CHANGED" ] || [ "$FILES_CHANGED" = "0" ]; then
                if [ -f "$OUTPUT_LOG" ]; then
                    OUTPUT_FILES=$(grep -c "\[TOOL\] --- Diff for" "$OUTPUT_LOG" 2>/dev/null || echo "0")
                    if [ "$OUTPUT_FILES" -gt 0 ] 2>/dev/null; then
                        FILES_CHANGED=$OUTPUT_FILES
                    else
                        FILES_CHANGED=0
                    fi
                fi
            fi

            # Parse new statistics fields
            AI_MODEL=$(grep "\"ai_model\"" "$LATEST_BENCHMARK" | sed 's/.*"ai_model": *//; s/[,"]//g' || echo "null")
            AI_CALLS=$(grep "\"ai_calls\"" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "null")
            AI_TIME=$(grep "\"ai_time_seconds\"" "$LATEST_BENCHMARK" | grep -oE '[0-9.]+' || echo "null")
            PBUILD_CALLS=$(grep "\"pbuild_calls\"" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "null")
            PBUILD_TIME=$(grep "\"pbuild_time_seconds\"" "$LATEST_BENCHMARK" | grep -oE '[0-9.]+' || echo "null")
            TOTAL_RUNTIME=$(grep "\"total_runtime_seconds\"" "$LATEST_BENCHMARK" | grep -oE '[0-9.]+' || echo "null")

            # Calculate trend vs first run
            TREND_PERCENT="null"
            FIRST_RUN_TIME="null"
            if [ "$BENCHMARK_COUNT" -gt 1 ]; then
                FIRST_BENCHMARK=$(echo "$ALL_BENCHMARKS" | head -1)
                FIRST_RUN_TIME=$(grep "run_time_seconds" "$FIRST_BENCHMARK" | grep -oE '[0-9.]+' || echo "0")

                if [ "$FIRST_RUN_TIME" != "0" ] && [ -n "$FIRST_RUN_TIME" ]; then
                    TREND_PERCENT=$(awk -v latest="$RUN_TIME" -v first="$FIRST_RUN_TIME" 'BEGIN {
                        if (first > 0) {
                            change = ((latest - first) / first) * 100
                            printf "%.1f", change
                        } else {
                            print "0"
                        }
                    }')
                fi
            fi

            # Read output log content (properly JSON-encoded via Python)
            OUTPUT_CONTENT=$(python3 -c "
import sys, json
f = sys.argv[1]
try:
    text = open(f).read()
except:
    text = 'No output log available'
# Return raw content (no surrounding quotes) for heredoc insertion
print(json.dumps(text)[1:-1])
" "$OUTPUT_LOG" 2>/dev/null || echo "")

            # Read diff file if present
            DIFF_PATH="${RESULT_DIR}/diff.patch"
            DIFF_CONTENT=$(python3 -c "
import sys, json
try:
    text = open(sys.argv[1]).read()
except:
    text = ''
print(json.dumps(text)[1:-1])
" "$DIFF_PATH" 2>/dev/null || echo "")

            # Add comma separator for all but first entry
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo "," >> "$RESULTS_JSON"
            fi

            # Write JSON entry
            cat >> "$RESULTS_JSON" <<EOF
    "$EXAMPLE": {
      "timestamp": "$TIMESTAMP",
      "run_time_seconds": $RUN_TIME,
      "success": $SUCCESS,
      "exit_code": $EXIT_CODE,
      "files_changed": $FILES_CHANGED,
      "ai_model": "$AI_MODEL",
      "ai_calls": $AI_CALLS,
      "ai_time_seconds": $AI_TIME,
      "pbuild_calls": $PBUILD_CALLS,
      "pbuild_time_seconds": $PBUILD_TIME,
      "total_runtime_seconds": $TOTAL_RUNTIME,
      "trend_percent": $TREND_PERCENT,
      "first_run_time_seconds": $FIRST_RUN_TIME,
      "run_count": $BENCHMARK_COUNT,
      "output": "$OUTPUT_CONTENT",
      "diff": "$DIFF_CONTENT",
      "result_path": "../results/$EXAMPLE/$TIMESTAMP"
    }
EOF
        fi
    done
fi

# Close JSON
cat >> "$RESULTS_JSON" <<'JSONFOOT'

  }
}
JSONFOOT

echo "Results manifest generated: $RESULTS_JSON"
