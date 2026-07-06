#!/bin/bash
# Publish script for GitHub Pages deployment
# This script prepares the docs/ directory for GitHub Pages

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Publishing pbuild-ai-examples to GitHub Pages ==="
echo ""

# Generate reports and copy results
echo "1. Generating reports and copying results..."
./scripts/generate-report.sh

echo ""
echo "2. Verifying docs/results exists..."
if [ ! -d "docs/results" ]; then
    echo "ERROR: docs/results was not created!"
    exit 1
fi

RESULTS_SIZE=$(du -sh docs/results | cut -f1)
echo "   Results directory size: $RESULTS_SIZE"

echo ""
echo "3. Files ready for deployment:"
echo "   - docs/index.html"
echo "   - docs/examples.html"
echo "   - docs/matrix.html"
echo "   - docs/results.json"
echo "   - docs/results/ (${RESULTS_SIZE})"
echo ""
echo "Note: results/ symlink at top level points to docs/results"

echo ""
echo "=== Ready to commit and push ==="
echo ""
echo "Next steps:"
echo "  git add docs/ results"
echo "  git commit -m 'Update GitHub Pages'"
echo "  git push"
echo ""
echo "Note: Source copies in docs/results/*/source/ are gitignored"
echo "      to keep the repository size manageable."
