# Contributing to Enhanced Root Hiding Module

Thank you for your interest in contributing to the Enhanced Root Hiding Module! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with the following information:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device information (Android version, ROM, Magisk/KernelSU version)
- Logs (if available)

### Suggesting Features

Feature suggestions are welcome! Please create an issue with:
- A clear, descriptive title
- Detailed description of the proposed feature
- Any relevant mockups or examples
- Why this feature would be beneficial

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

#### Pull Request Guidelines

- Follow the existing code style
- Include comments in your code where necessary
- Update documentation if needed
- Test your changes before submitting
- Keep pull requests focused on a single feature or bug fix

## Development Setup

### Prerequisites
- JDK 17+
- Android NDK
- Git

### Build Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/saksham/enhanced-root-hiding.git
   cd enhanced-root-hiding
   ```

2. Build the module:
   ```bash
   ./gradlew build
   ```

3. Create the module zip:
   ```bash
   ./build.sh
   ```

## Testing

Please test your changes on different devices and Android versions if possible. At minimum, test on:
- A device with Magisk
- A device with KernelSU (if available)
- Different Android versions (if possible)

## Documentation

If you're adding new features or making significant changes, please update the relevant documentation:
- README.md
- Any relevant wiki pages
- Code comments

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [GPL-3.0 License](LICENSE).
