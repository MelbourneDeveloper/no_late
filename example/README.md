# no_late Example

This example demonstrates the proper usage of the `no_late` analyzer plugin.

## Running the Example

1. Install dependencies:
```bash
dart pub get
```

2. Set up the analyzer plugin:
```bash
mkdir -p tools/analyzer_plugin
# Copy the pubspec.yaml and plugin.dart from the main example
```

3. Run the code:
```bash
dart run main.dart
```

## What You'll See

- ✅ **Allowed patterns**: Expensive computations and method calls that benefit from lazy initialization
- ❌ **Blocked patterns**: Simple literals and uninitialized late variables (commented out to prevent compile errors)

The code includes comprehensive examples of both safe and unsafe `late` usage patterns.