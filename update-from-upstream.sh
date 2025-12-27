#!/usr/bin/env bash
# update-from-upstream.sh - Pull updates from original CodexBar and rebuild

set -euo pipefail
cd "$(dirname "$0")"

echo "📥 Fetching updates from upstream..."
git fetch upstream

echo ""
echo "🔍 Checking for new commits..."
NEW_COMMITS=$(git log HEAD..upstream/main --oneline | wc -l | xargs)

if [ "$NEW_COMMITS" -eq "0" ]; then
    echo "✅ Already up to date!"
    exit 0
fi

echo "Found $NEW_COMMITS new commit(s):"
git log HEAD..upstream/main --oneline | head -10

echo ""
read -p "Merge these changes? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

echo ""
echo "🔄 Merging upstream/main into current branch..."
if git merge upstream/main; then
    echo "✅ Merge successful!"
else
    echo "⚠️  Merge conflicts detected!"
    echo ""
    echo "Please resolve conflicts manually:"
    echo "1. Edit conflicted files (git will mark them)"
    echo "2. Run: git add <resolved-files>"
    echo "3. Run: git commit"
    echo "4. Run: ./Scripts/package_app.sh"
    exit 1
fi

echo ""
echo "🔨 Rebuilding CodexBar+ app..."
./Scripts/package_app.sh

echo ""
echo "🎉 Update complete!"
echo ""
echo "To launch the updated app:"
echo "  pkill -x 'CodexBar+' || true"
echo "  open -n 'CodexBar+.app'"
