# ZoomBackgroundMagick

Shell scripts to leverage ffmpeg for creating Zoom-compatible background videos from panoramic images and photo slideshows. Originally created during COVID-19 to generate fun assets for Zoom's virtual background feature.

## Features

- **createPanoMovies.sh**: Transform panoramic images into slowly scrolling background videos
- **createSlideShow.sh**: Convert a collection of images into slideshow videos
- **getDependencies.sh**: One-click dependency installer for macOS

## Requirements

- **macOS Catalina (10.15) or newer**
- **Homebrew** package manager
- **Zsh shell** (default on modern macOS)

## Quick Setup

For first-time users, run the automated dependency installer:

```bash
./getDependencies.sh
```

This installs all required dependencies via Homebrew.

## Manual Setup

If you prefer to install dependencies manually:

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Required Dependencies

```bash
# Core video processing
brew install ffmpeg

# Text processing and utilities  
brew install coreutils gawk

# Image processing libraries
brew install imagemagick graphicsmagick

# Image conversion tools
brew install leptonica

# Terminal image preview (optional)
brew install imgcat
```

### 3. Verify Installation

Check that all tools are available:

```bash
# Should return paths for all commands
which ffmpeg ffprobe gm identify convertformat gawk sips md5 bc
```

## Usage

### Creating Panoramic Videos

1. Place your panoramic images (JPG, PNG, WEBP) in the project directory
2. Run the panoramic video generator:

```bash
./createPanoMovies.sh
```

**Requirements for panoramic images:**
- Images must be at least 3x wider than their height
- Minimum width: 256 pixels
- Supported formats: JPG, JPEG, PNG, WEBP

The script will:
- Process only images meeting panoramic criteria
- Generate smooth scrolling videos optimized for Zoom (max 1920x1080)
- Create MP4 files with the same base name as your images

### Creating Slideshow Videos

1. Place your images in the project directory
2. Run the slideshow generator:

```bash
./createSlideShow.sh
```

This creates a single `slideshow.mp4` file from all images in the directory.

### Performance Notes

- **CPU Throttling**: For large panoramas, the script automatically throttles CPU usage to prevent overheating
- **Processing Time**: Large images may take considerable time to process
- **Hardware Acceleration**: macOS hardware acceleration is available for supported systems

## Post-Processing Tips

### Speed Up Videos

Make your background videos scroll faster:

```bash
# 4x faster
ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/4" background_movie_name_4xfaster.mp4

# 3x faster  
ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/3" background_movie_name_3xfaster.mp4

# 2x faster
ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/2" background_movie_name_2xfaster.mp4
```

### Additional ffmpeg Operations

`ffmpeg` supports many other operations including:
- Trimming/cutting video segments
- Splicing multiple videos together
- Adding audio tracks
- Adjusting resolution and quality

## Troubleshooting

### Common Issues

**"gm: command not found"**
- Run `brew install graphicsmagick`
- Restart your terminal

**"gawk: command not found"**  
- Run `brew install gawk`

**"convertformat: command not found"**
- Run `brew install leptonica`

**Scripts hang or run slowly**
- CPU throttling is normal for large images
- Check Activity Monitor for resource usage
- Ensure sufficient disk space for temporary files

### Dependencies Not Installing

If `getDependencies.sh` fails:

1. Update Homebrew: `brew update`
2. Check for Homebrew issues: `brew doctor`
3. Install dependencies manually using the commands above

## Technical Details

- **Supported Image Formats**: JPG, JPEG, PNG, WEBP
- **Output Format**: MP4 with H.264 encoding
- **Max Resolution**: 1920x1080 (Zoom requirement)
- **Temporary Files**: Created in `*_tmp` directories, automatically cleaned up

## License

This project is provided "as-is" with no warranties expressed or implied. Use at your own risk.
