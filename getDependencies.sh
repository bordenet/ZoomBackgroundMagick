#!/bin/zsh

printf "Installing dependencies...\n"

echo "🎬 Installing video processing tools..."
brew install ffmpeg

echo "🛠️  Installing core utilities..."
brew install coreutils gawk

echo "🖼️  Installing image processing libraries..."
brew install imagemagick graphicsmagick

echo "🔄 Installing image conversion tools..."
brew install leptonica

echo "🖥️  Installing terminal utilities..."
brew install imgcat

echo "✅ All dependencies installed!"
echo ""
echo "Verify installation with:"
echo "which ffmpeg ffprobe gm identify convertformat gawk sips md5 bc"
