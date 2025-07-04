#!/bin/bash
set -e

echo "Building Suno for iOS..."

# Build Rust library for iOS
cd rust_core
cargo lipo --release
cp target/universal/release/libsuno_core.a ../flutter_app/ios/

# Build Flutter app
cd ../flutter_app
flutter build ios --release

echo "iOS build complete!"