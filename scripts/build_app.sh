#!/bin/bash

set -e

APP_NAME="DevTools"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🚀 Starting build process for $APP_NAME..."

# 1. Build using Swift Package Manager in Release mode
echo "🔨 Compiling sources..."
swift build -c release

# 2. Create App Bundle Structure
echo "📦 Creating App Bundle structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 3. Copy Binary
echo "📋 Copying binary..."
# Note: SPM output path might vary based on arch, using universal build usually puts it in release
# If building universal fails locally, we fallback to host arch.
if [ -f "$BUILD_DIR/$APP_NAME" ]; then
    cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"
else
    # Fallback for single arch build if universal not explicitly supported by simple swift build on some setups
    cp .build/release/$APP_NAME "$MACOS_DIR/" 2>/dev/null || cp .build/arm64-apple-macosx/release/$APP_NAME "$MACOS_DIR/" 2>/dev/null || cp .build/x86_64-apple-macosx/release/$APP_NAME "$MACOS_DIR/"
fi

# 4. Create Info.plist
echo "📝 Generating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# 5. Create a temporary icon (using a system icon)
# In production, you should replace this with a real .icns file
echo "🎨 Creating placeholder icon..."
# We try to copy a standard system icon just to have something
if [ -f "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Developer.icns" ]; then
    cp "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Developer.icns" "$RESOURCES_DIR/AppIcon.icns"
else
    echo "⚠️  Default icon not found, skipping icon."
fi

# 6. Ad-hoc Code Signing
# Required for running locally on Apple Silicon and modern macOS
echo "🔏 Signing application (Ad-hoc)..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ Build Complete!"
echo "👉 You can find your app at: $PWD/$APP_BUNDLE"
echo "   Run: open $APP_BUNDLE"
