#!/bin/bash

# ==============================================================================
# FkAd Rebranding Script
# Dynamically injects App Identifiers and Names without permanently modifying
# the upstream Git repository. Best used in CI environments before xcodegen.
# ==============================================================================

set -e

# Configuration (from ENV or defaults)
APP_NAME="${APP_NAME:-FkAd}"
APP_BUNDLE_PREFIX="${APP_BUNDLE_PREFIX:-top.ssadtyer}"
APP_GROUP="${APP_GROUP:-group.ssadtyer.top}"
APP_SCHEME="${APP_SCHEME:-fkad}"

echo "🚀 Starting dynamic rebranding for $APP_NAME..."
echo "   - Bundle Prefix: $APP_BUNDLE_PREFIX"
echo "   - App Group: $APP_GROUP"
echo "   - Scheme: $APP_SCHEME"

# 1. Update App Group globally FIRST (so it doesn't get messed up by bundle prefix replacement)
echo "🔐 Updating App Group globally..."
find . -type f \( -name "*.swift" -o -name "*.m" -o -name "*.h" -o -name "*.entitlements" -o -name "project.yml" \) -exec sed -i '' "s/group\.com\.tangzixiang\.meow/$APP_GROUP/g" {} +

# 2. Update project.yml
echo "📦 Updating project.yml..."
sed -i '' "s/bundleIdPrefix: com.tangzixiang.meow/bundleIdPrefix: $APP_BUNDLE_PREFIX/g" project.yml
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER: com.tangzixiang.meow.PacketTunnel/PRODUCT_BUNDLE_IDENTIFIER: $APP_BUNDLE_PREFIX.PacketTunnel/g" project.yml
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER: com.tangzixiang.meow/PRODUCT_BUNDLE_IDENTIFIER: $APP_BUNDLE_PREFIX/g" project.yml

sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" project.yml

sed -i '' "s/CFBundleDisplayName: meow Tunnel/CFBundleDisplayName: $APP_NAME Tunnel/g" project.yml
sed -i '' "s/CFBundleDisplayName: meow/CFBundleDisplayName: $APP_NAME/g" project.yml

sed -i '' "s/CFBundleURLName: com.tangzixiang.meow.deeplink/CFBundleURLName: $APP_BUNDLE_PREFIX.deeplink/g" project.yml
sed -i '' -e '/CFBundleURLSchemes:/!b' -e 'n' -e "s/- meow/- $APP_SCHEME/" project.yml

sed -i '' "s/NSCameraUsageDescription: \"meow uses/NSCameraUsageDescription: \"$APP_NAME uses/g" project.yml

# 3. Update Entitlements (Keychain access groups)
echo "🔐 Updating Keychain Entitlements..."
sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" App/App.entitlements
sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" PacketTunnel/PacketTunnel.entitlements

# 4. Update Source Code Identifiers
echo "🛠 Updating Source Code Identifiers..."
# Replace generic com.tangzixiang.meow occurrences in all source files (Swift, Obj-C, Rust, Plist)
find App/Sources MeowShared/Sources PacketTunnel/Sources core/rust/meow-ios-ffi App -type f \( -name "*.swift" -o -name "*.m" -o -name "*.rs" -o -name "*.plist" \) -exec sed -i '' "s/com.tangzixiang.meow/$APP_BUNDLE_PREFIX/g" {} +

echo "✅ Rebranding complete! Ready for xcodegen."
