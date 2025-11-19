# Contributing to ZoomBackgroundMagick

## Reporting Issues

If you encounter bugs or have feature requests:

1. Check existing issues to avoid duplicates
2. Provide clear reproduction steps
3. Include your macOS version and dependency versions
4. Attach relevant error messages or logs

## Pull Requests

Contributions are welcome. Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Test your changes thoroughly
4. Ensure scripts pass syntax checks (`zsh -n script.sh`)
5. Update documentation as needed
6. Submit a pull request with a clear description

## Code Standards

- Use consistent shell scripting style
- Add comments for complex logic
- Include error handling
- Test on macOS before submitting
- Follow existing code patterns

## Testing

Before submitting:

```bash
# Syntax check
zsh -n createPanoMovies.sh
zsh -n createSlideShow.sh

# Test with sample images
./createPanoMovies.sh
./createSlideShow.sh
```

## License

By contributing, you agree to license your contributions under CC0 1.0 Universal.

