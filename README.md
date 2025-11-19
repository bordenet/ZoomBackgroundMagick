# ZoomBackgroundMagick

Shell scripts for creating Zoom-compatible background videos from panoramic images and photo slideshows using ffmpeg.

## Features

- **createPanoMovies.sh**: Transform panoramic images into scrolling background videos
- **createSlideShow.sh**: Convert images into slideshow videos
- **getDependencies.sh**: Automated dependency installer for macOS

## Requirements

- macOS Catalina (10.15) or newer
- Homebrew package manager
- Zsh shell (default on modern macOS)

## Quick Setup

Run the automated dependency installer:

```bash
chmod +x getDependencies.sh
./getDependencies.sh
```

This installs all required dependencies via Homebrew and verifies the installation.

## Manual Setup

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Dependencies

```bash
brew install ffmpeg coreutils gawk imagemagick graphicsmagick leptonica
```

### 3. Verify Installation

```bash
which ffmpeg ffprobe gm identify convertformat gawk sips md5 bc
```

## Usage

### Creating Panoramic Videos

Place panoramic images (JPG, PNG, WEBP) in the project directory and run:

```bash
chmod +x createPanoMovies.sh
./createPanoMovies.sh
```

**Image Requirements:**
- Width must be at least 3x the height
- Minimum width: 256 pixels
- Supported formats: JPG, JPEG, PNG, WEBP

**Output:**
- Smooth scrolling videos optimized for Zoom (max 1920x1080)
- MP4 files with the same base name as source images

### Creating Slideshow Videos

Place images in the project directory and run:

```bash
chmod +x createSlideShow.sh
./createSlideShow.sh
```

Creates a single `slideshow.mp4` file from all images in the directory.

### Performance Notes

- CPU throttling automatically engages for large panoramas to prevent overheating
- Large images may take considerable time to process
- Hardware acceleration available on supported macOS systems

## Post-Processing

### Speed Up Videos

```bash
# 4x faster
ffmpeg -i input.mp4 -filter:v "setpts=PTS/4" output_4x.mp4

# 2x faster
ffmpeg -i input.mp4 -filter:v "setpts=PTS/2" output_2x.mp4
```

### Other ffmpeg Operations

- Trim/cut video segments
- Splice multiple videos
- Add audio tracks
- Adjust resolution and quality

## Troubleshooting

### Missing Dependencies

Scripts will check for required dependencies and report missing tools. Run `./getDependencies.sh` to install them.

### Slow Performance

CPU throttling is normal for large images. Check Activity Monitor for resource usage and ensure sufficient disk space.

### Installation Issues

If `getDependencies.sh` fails:

1. Update Homebrew: `brew update`
2. Check for issues: `brew doctor`
3. Install dependencies manually (see Manual Setup)

## Technical Details

- **Input Formats**: JPG, JPEG, PNG, WEBP
- **Output Format**: MP4 (H.264)
- **Max Resolution**: 1920x1080 (Zoom requirement)
- **Temporary Files**: Created in `*_tmp` directories, automatically cleaned up

## License

CC0 1.0 Universal - Public Domain. See LICENSE file for details.
