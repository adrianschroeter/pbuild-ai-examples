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
                            <th>Model</th>
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
            EXIT_CODE=$(grep "exit_code" "$LATEST_BENCHMARK" | grep -oE '[0-9]+' || echo "1")

            # Get status field if available, otherwise derive from success/exit_code
            STATUS=$(grep "\"status\"" "$LATEST_BENCHMARK" | sed 's/.*"status": *"\([^"]*\)".*/\1/' 2>/dev/null || echo "")
            if [ -z "$STATUS" ]; then
                # Fallback: derive from success field for backwards compatibility
                SUCCESS=$(grep "\"success\"" "$LATEST_BENCHMARK" | grep -o "true\|false" || echo "false")
                if [ "$SUCCESS" = "true" ]; then
                    STATUS="success"
                else
                    STATUS="failed"
                fi
            fi

            # Extract AI model from benchmark or metadata
            AI_MODEL=$(grep "\"ai_model\"" "$LATEST_BENCHMARK" | sed 's/.*"ai_model": *//; s/[,"]//g' || echo "?")
            # Try to read model_key from metadata.json for cleaner display
            BENCHMARK_DIR=$(dirname "$LATEST_BENCHMARK")
            METADATA_PATH="${BENCHMARK_DIR}/metadata.json"
            MODEL_DISPLAY=""
            if [ -f "$METADATA_PATH" ]; then
                MODEL_KEY=$(grep "\"model_key\"" "$METADATA_PATH" | sed 's/.*"model_key": *"\([^"]*\)".*/\1/' 2>/dev/null || echo "")
                if [ -n "$MODEL_KEY" ]; then
                    # Try to resolve display name from models.yaml
                    if [ -f "models.yaml" ]; then
                        MODEL_DISPLAY=$(grep -A2 "^\s\+${MODEL_KEY}:" models.yaml | grep "display:" | sed 's/.*display: *"\([^"]*\)".*/\1/' 2>/dev/null || echo "$MODEL_KEY")
                    fi
                    [ -z "$MODEL_DISPLAY" ] && MODEL_DISPLAY="$MODEL_KEY"
                fi
            fi
            [ -z "$MODEL_DISPLAY" ] && MODEL_DISPLAY="$AI_MODEL"

            # Determine display based on status: success (exit 0), failed (exit 1), error (exit >=2)
            if [ "$STATUS" = "success" ]; then
                STATUS_CLASS="status-success"
                STATUS_TEXT="✓ PASSED"
            elif [ "$STATUS" = "failed" ]; then
                STATUS_CLASS="status-failed"
                STATUS_TEXT="✗ FAILED"
            else
                STATUS_CLASS="status-failed"
                STATUS_TEXT="⚠ ERROR"
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

            # Escape MODEL_DISPLAY for HTML
            MODEL_DISPLAY_ESC=$(echo "$MODEL_DISPLAY" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')

            cat >> "$OUTPUT_FILE" <<EOF
                        <tr>
                            <td><strong>$EXAMPLE</strong></td>
                            <td class="timestamp-text">$MODEL_DISPLAY_ESC</td>
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

# Generate results.json for JavaScript consumption (model-aware)
echo "Generating results manifest..."

python3 << 'PYEOF' > "$RESULTS_JSON"
import json, os, re, glob
from collections import OrderedDict

RESULTS_DIR = "results"
config = {}

def read_yaml_simple(path):
    """Parse YAML with hosts: and models: sections"""
    data = {"hosts": {}, "models": {}}
    current_section = None
    current_key = None

    try:
        with open(path) as f:
            for line in f:
                line = re.sub(r'#.*$', '', line).rstrip()
                if not line:
                    continue

                # Top-level section: hosts: or models:
                if line.startswith("hosts:"):
                    current_section = "hosts"
                    continue
                elif line.startswith("models:"):
                    current_section = "models"
                    continue

                # Entry key: "  keyname:"
                m = re.match(r'^  ([\w.\-][\w.\-]*):\s*$', line)
                if m and current_section:
                    current_key = m.group(1)
                    data[current_section][current_key] = {}
                    continue

                # Property: "    propname: value"
                m = re.match(r'^\s+(\w[\w-]*):\s*(.*)$', line)
                if m and current_section and current_key:
                    val = m.group(2).strip()
                    if len(val) >= 2 and val[0] == val[-1] and val[0] in '"\'':
                        val = val[1:-1]
                    data[current_section][current_key][m.group(1)] = val
    except FileNotFoundError:
        pass
    return data

# Merge models.yaml and models.yaml.local
full_config = {"hosts": {}, "models": {}}
for yaml_file in ['models.yaml', 'models.yaml.local']:
    if os.path.exists(yaml_file):
        cfg = read_yaml_simple(yaml_file)
        for section in ["hosts", "models"]:
            for key, val in cfg.get(section, {}).items():
                if key not in full_config[section]:
                    full_config[section][key] = {}
                full_config[section][key].update(val)

# Build models metadata
models_meta = {"default": {"display": "Unknown Model"}}
for key, val in full_config.get("models", {}).items():
    models_meta[key] = {"display": val.get("display", key)}

TIMESTAMP_RE = re.compile(r'^\d{8}_\d{6}$')
result = {
    "generated": "",
    "models": models_meta,
    "examples": OrderedDict()
}

if os.path.isdir(RESULTS_DIR):
    example_dirs = sorted([
        d for d in os.listdir(RESULTS_DIR)
        if os.path.isdir(os.path.join(RESULTS_DIR, d))
    ])

    for example in example_dirs:
        example_path = os.path.join(RESULTS_DIR, example)
        example_models = []

        # Read order from test.yaml if available
        test_yaml_path = os.path.join("examples", example, "test.yaml")
        example_order = 9999  # Default to end if not specified
        if os.path.exists(test_yaml_path):
            try:
                with open(test_yaml_path) as f:
                    for line in f:
                        line = re.sub(r'#.*$', '', line).strip()
                        m = re.match(r'^order:\s*(\d+)', line)
                        if m:
                            example_order = int(m.group(1))
                            break
            except Exception:
                pass

        for subdir in sorted(os.listdir(example_path)):
            subpath = os.path.join(example_path, subdir)
            if not os.path.isdir(subpath):
                continue

            is_timestamp = bool(TIMESTAMP_RE.match(subdir))

            if is_timestamp:
                # Old format: results/example/timestamp/
                model_key = "default"
                ts_dirs = [(subdir, subpath)]
            else:
                # New format: results/example/model/timestamp/
                model_key = subdir
                ts_dirs = []
                for ts in sorted(os.listdir(subpath)):
                    tsp = os.path.join(subpath, ts)
                    if os.path.isdir(tsp):
                        ts_dirs.append((ts, tsp))

            # Find latest benchmark per model
            latest_bm_path = None
            latest_ts = None
            all_bm_paths = []
            for ts, tsp in ts_dirs:
                bm = os.path.join(tsp, "benchmark.json")
                if os.path.exists(bm):
                    all_bm_paths.append((ts, bm))
                    if latest_ts is None or ts > latest_ts:
                        latest_bm_path = bm
                        latest_ts = ts

            if latest_bm_path is None:
                continue

            # Parse benchmark JSON
            with open(latest_bm_path) as f:
                bm = json.load(f)

            run_time = bm.get("run_time_seconds", 0)
            exit_code = bm.get("exit_code", 1)

            # Get status field if available, otherwise derive from success/exit_code
            status = bm.get("status", None)
            if status is None:
                # Fallback for backwards compatibility
                success = bm.get("success", False)
                if success:
                    status = "success"
                else:
                    status = "failed"
            else:
                # Derive success from status for compatibility
                success = (status == "success")
            files_changed = bm.get("files_changed", 0)
            ai_model = bm.get("ai_model", None) or ""
            ai_calls = bm.get("ai_calls", None)
            ai_time = bm.get("ai_time_seconds", None)
            pbuild_calls = bm.get("pbuild_calls", None)
            pbuild_time = bm.get("pbuild_time_seconds", None)
            total_runtime = bm.get("total_runtime_seconds", None)
            pbuild_ai_version = bm.get("pbuild_ai_version", None) or ""

            # Fallback files_changed from output
            output_log = os.path.join(os.path.dirname(latest_bm_path), "output.log")
            if files_changed == 0 and os.path.exists(output_log):
                with open(output_log, encoding="utf-8", errors="replace") as f:
                    content = f.read()
                diff_count = content.count("[TOOL] --- Diff for")
                if diff_count > 0:
                    files_changed = diff_count

            # Trend calculation
            trend_percent = None
            first_run_time = None
            if len(all_bm_paths) > 1:
                first_ts, first_bm = all_bm_paths[0]
                with open(first_bm) as f:
                    first_bm_data = json.load(f)
                first_run_time_val = first_bm_data.get("run_time_seconds", 0)
                if first_run_time_val and float(first_run_time_val) > 0:
                    first_run_time = float(first_run_time_val)
                    if float(run_time) > 0:
                        trend_percent = round((float(run_time) - first_run_time) / first_run_time * 100, 1)

            # Read output log
            output_content = ""
            if os.path.exists(output_log):
                with open(output_log, encoding="utf-8", errors="replace") as f:
                    output_content = f.read()

            # Read diff
            diff_path = os.path.join(os.path.dirname(latest_bm_path), "diff.patch")
            diff_content = ""
            if os.path.exists(diff_path):
                with open(diff_path, encoding="utf-8", errors="replace") as f:
                    diff_content = f.read()

            # Read metadata for model_key if not already known
            meta_path = os.path.join(os.path.dirname(latest_bm_path), "metadata.json")
            meta_model_key = model_key
            meta_host_name = None
            meta_host_desc = None
            if os.path.exists(meta_path):
                with open(meta_path) as f:
                    try:
                        meta = json.load(f)
                        if "model_key" in meta:
                            meta_model_key = meta["model_key"]
                        meta_host_name = meta.get("model_host_name")
                        meta_host_desc = meta.get("model_host_description")
                    except json.JSONDecodeError:
                        pass

            # Build result_path (old format: example/timestamp, new: example/model/timestamp)
            if is_timestamp:
                rel_path = "../results/" + example + "/" + subdir
            else:
                rel_path = "../results/" + example + "/" + subdir + "/" + (latest_ts or "")

            entry = {
                "timestamp": latest_ts,
                "run_time_seconds": run_time,
                "status": status,
                "success": success,
                "exit_code": exit_code,
                "files_changed": files_changed,
                "ai_model": ai_model if ai_model else None,
                "ai_calls": ai_calls,
                "ai_time_seconds": ai_time,
                "pbuild_calls": pbuild_calls,
                "pbuild_time_seconds": pbuild_time,
                "total_runtime_seconds": total_runtime,
                "pbuild_ai_version": pbuild_ai_version if pbuild_ai_version else None,
                "model_host_name": meta_host_name,
                "model_host_description": meta_host_desc,
                "trend_percent": trend_percent,
                "first_run_time_seconds": first_run_time,
                "run_count": len(all_bm_paths),
                "output": output_content,
                "diff": diff_content,
                "result_path": rel_path
            }
            example_models.append((meta_model_key, entry))

        if example_models:
            result["examples"][example] = {
                "order": example_order,
                "models": OrderedDict()
            }
            for mk, entry in example_models:
                result["examples"][example]["models"][mk] = entry

result["generated"] = os.popen("date -Iseconds").read().strip()

print(json.dumps(result, indent=2, ensure_ascii=False))
PYEOF

echo "Results manifest generated: $RESULTS_JSON"
