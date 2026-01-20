#!/bin/bash

set -e

APP_NAME="DevTools"
BUILD_DIR=".build"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🚀 Starting Universal Build process for $APP_NAME..."

# 1. Build for Apple Silicon (arm64)
echo "🔨 Compiling for Apple Silicon (arm64)..."
swift build -c release --arch arm64

# 2. Build for Intel (x86_64)
echo "🔨 Compiling for Intel (x86_64)..."
swift build -c release --arch x86_64

# 3. Create Universal Binary
echo "🔗 Creating Universal Binary (Fat Binary)..."
# Create a temporary directory for the universal binary
mkdir -p "$BUILD_DIR/universal"

ARM64_BIN="$BUILD_DIR/arm64-apple-macosx/release/$APP_NAME"
X86_64_BIN="$BUILD_DIR/x86_64-apple-macosx/release/$APP_NAME"
UNIVERSAL_BIN="$BUILD_DIR/universal/$APP_NAME"

lipo -create -output "$UNIVERSAL_BIN" "$ARM64_BIN" "$X86_64_BIN"

# Verify archs
echo "🔎 Verifying architectures:"
lipo -info "$UNIVERSAL_BIN"

# 4. Create App Bundle Structure
echo "📦 Creating App Bundle structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 5. Copy Universal Binary
echo "📋 Copying binary..."
cp "$UNIVERSAL_BIN" "$MACOS_DIR/"

# 6. Create Info.plist
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
    <string>1.0.4</string>
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

# 7. Copy App Icon
echo "🎨 Copying App Icon..."
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
else
    # Fallback to system icon only if our custom icon is missing
    echo "⚠️  Custom icon not found, using system placeholder."
    if [ -f "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Developer.icns" ]; then
        cp "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Developer.icns" "$RESOURCES_DIR/AppIcon.icns"
    fi
fi

# 8. Ad-hoc Code Signing
echo "🔏 Signing application (Ad-hoc)..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ Build Complete!"
echo "👉 You can find your Universal App at: $PWD/$APP_BUNDLE"
echo "   Run: open $APP_BUNDLE"
