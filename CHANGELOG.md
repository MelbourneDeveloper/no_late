# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-15

### Added
- Initial release of `no_late` analyzer plugin
- Detection of uninitialized `late` variables that risk `LateInitializationError`
- Detection of `late` usage with simple literals (strings, numbers, booleans)
- Detection of `late` usage with simple identifiers
- Allows `late` for legitimate lazy initialization patterns:
  - Method calls (e.g., `DateTime.now()`, `Database.connect()`)
  - Constructor calls (e.g., `Random()`, `Timer()`)
  - Complex expressions (e.g., `list.fold()`, `items.where()`)
  - Property access (e.g., `Theme.of(context)`)
- Clear error messages explaining why specific `late` usage is unsafe
- BSD 3-Clause license
- Comprehensive documentation with migration examples
- Support for `// ignore:` and `// ignore_for_file:` suppressions

### Features
- Compile-time prevention of `LateInitializationError` runtime crashes
- Performance optimization by eliminating unnecessary `late` overhead
- Flutter-specific examples and migration patterns
- Integration with VS Code, Android Studio, and other Dart-compatible IDEs
- CI/CD pipeline compatibility

[0.1.0]: https://github.com/christianfindlay/no_late/releases/tag/v0.1.0