#!/bin/zsh
#
# Dependency installer for ZoomBackgroundMagick
# Installs all required tools via Homebrew
#
set -e

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "❌ Error: This script requires macOS"
  exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "❌ Error: Homebrew is not installed"
  echo ""
  echo "Install Homebrew first:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

echo "Installing dependencies..."
echo ""

echo "🎬 Installing video processing tools..."
brew install ffmpeg || echo "⚠️  ffmpeg installation failed or already installed"

echo "🛠️  Installing core utilities..."
brew install coreutils gawk || echo "⚠️  coreutils/gawk installation failed or already installed"

echo "🖼️  Installing image processing libraries..."
brew install imagemagick graphicsmagick || echo "⚠️  imagemagick/graphicsmagick installation failed or already installed"

echo "🔄 Installing image conversion tools..."
brew install leptonica || echo "⚠️  leptonica installation failed or already installed"

echo "🖥️  Installing terminal utilities (optional)..."
brew install imgcat || echo "⚠️  imgcat installation failed or already installed"

echo ""
echo "✅ Dependency installation complete!"
echo ""
echo "Verifying installation..."
echo ""

# Verify critical dependencies
missing=0
for cmd in ffmpeg ffprobe gm identify convertformat gawk sips md5 bc; do
  if command -v "$cmd" &> /dev/null; then
    echo "✓ $cmd"
  else
    echo "✗ $cmd (missing)"
    ((missing++))
  fi
done

echo ""
if [[ $missing -eq 0 ]]; then
  echo "✅ All required dependencies are installed!"
  exit 0
else
  echo "⚠️  $missing dependencies are missing. Please install them manually."
  exit 1
fi
