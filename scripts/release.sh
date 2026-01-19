#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Extract version from build_app.sh
VERSION=$(grep -o 'CFBundleShortVersionString</key>[^<]*<string>[^<]*' scripts/build_app.sh | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

if [ -z "$VERSION" ]; then
    echo "❌ Failed to extract version from build_app.sh"
    exit 1
fi

echo "🚀 Release v$VERSION"

# 1. Build the app
echo "📦 Building app..."
./scripts/build_app.sh

# 2. Package as zip
echo "🗜️  Creating zip..."
rm -f devtools.zip
zip -r devtools.zip DevTools.app

# 3. Check if release already exists
if gh release view "v$VERSION" &>/dev/null; then
    echo "⚠️  Release v$VERSION already exists. Updating..."
    gh release upload "v$VERSION" devtools.zip --clobber
else
    echo "📤 Creating release v$VERSION..."
    gh release create "v$VERSION" devtools.zip \
        --title "v$VERSION" \
        --generate-notes
fi

echo "✅ Done: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/v$VERSION"
