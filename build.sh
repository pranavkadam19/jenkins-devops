#!/bin/bash
set -e

echo "📦 Installing dependencies..."
npm install

echo "⚙️ Building React app for production..."
npm run build

echo "✅ Build complete. Output is in ./build"