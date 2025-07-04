#!/bin/bash
set -e

echo "Building Suno for Android..."

# Build Rust library for Android targets
cd rust_core
cargo ndk -t armeabi-v7a -t arm64-v8a -o ../flutter_app/android/app/src/main/jniLibs build --release

# Build Flutter app
cd ../flutter_app
flutter build apk --release

echo "Android build complete!"