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

# 1. Update project.yml
echo "📦 Updating project.yml..."
sed -i '' "s/bundleIdPrefix: com.tangzixiang.meow/bundleIdPrefix: $APP_BUNDLE_PREFIX/g" project.yml
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER: com.tangzixiang.meow.PacketTunnel/PRODUCT_BUNDLE_IDENTIFIER: $APP_BUNDLE_PREFIX.PacketTunnel/g" project.yml
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER: com.tangzixiang.meow/PRODUCT_BUNDLE_IDENTIFIER: $APP_BUNDLE_PREFIX/g" project.yml

sed -i '' "s/group.com.tangzixiang.meow/$APP_GROUP/g" project.yml
sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" project.yml

sed -i '' "s/CFBundleDisplayName: meow Tunnel/CFBundleDisplayName: $APP_NAME Tunnel/g" project.yml
sed -i '' "s/CFBundleDisplayName: meow/CFBundleDisplayName: $APP_NAME/g" project.yml

sed -i '' "s/CFBundleURLName: com.tangzixiang.meow.deeplink/CFBundleURLName: $APP_BUNDLE_PREFIX.deeplink/g" project.yml
sed -i '' "/CFBundleURLSchemes:/!b;n;s/- meow/- $APP_SCHEME/" project.yml

sed -i '' "s/NSCameraUsageDescription: \"meow uses/NSCameraUsageDescription: \"$APP_NAME uses/g" project.yml

# 2. Update Entitlements (App and PacketTunnel)
echo "🔐 Updating Entitlements..."
sed -i '' "s/group.com.tangzixiang.meow/$APP_GROUP/g" App/App.entitlements
sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" App/App.entitlements

sed -i '' "s/group.com.tangzixiang.meow/$APP_GROUP/g" PacketTunnel/PacketTunnel.entitlements
sed -i '' "s/\$(AppIdentifierPrefix)com.tangzixiang.meow/\$(AppIdentifierPrefix)$APP_BUNDLE_PREFIX/g" PacketTunnel/PacketTunnel.entitlements

# Note: The user already manually updated the App Group to group.ssadtyer.top
# in .entitlements previously, so let's also catch that specifically in case
# the environment variable is changed later.
sed -i '' "s/group.ssadtyer.top/$APP_GROUP/g" project.yml 2>/dev/null || true
sed -i '' "s/group.ssadtyer.top/$APP_GROUP/g" App/App.entitlements 2>/dev/null || true
sed -i '' "s/group.ssadtyer.top/$APP_GROUP/g" PacketTunnel/PacketTunnel.entitlements 2>/dev/null || true
sed -i '' "s/group.ssadtyer.top/$APP_GROUP/g" MeowShared/Sources/MeowModels/AppGroup.swift 2>/dev/null || true
sed -i '' "s/group.ssadtyer.top/$APP_GROUP/g" PacketTunnel/Sources/MWAppGroup.m 2>/dev/null || true

# 3. Update VpnManager.swift Hardcode
echo "🛠 Updating VpnManager.swift..."
sed -i '' "s/proto.providerBundleIdentifier = \"com.tangzixiang.meow.PacketTunnel\"/proto.providerBundleIdentifier = \"$APP_BUNDLE_PREFIX.PacketTunnel\"/g" App/Sources/Services/VpnManager.swift

# 4. (Optional) Update Logger Subsystems for cleaner logs
echo "📝 Updating Logger identifiers..."
find App/Sources MeowShared/Sources PacketTunnel/Sources -name "*.swift" -type f -exec sed -i '' "s/com.tangzixiang.meow/$APP_BUNDLE_PREFIX/g" {} +

echo "✅ Rebranding complete! Ready for xcodegen."
