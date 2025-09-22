# no_late

**Stop `LateInitializationError` at compile time.**

Dart analyzer plugin that bans unsafe `late` usage. Only allows `late` for lazy initialization. Everything else is a compile error.

## The Problem

`late` without immediate initialization causes runtime exceptions:

```dart
late String name;  // 💣 Bomb waiting to explode
String greet() => 'Hello $name';  // 💥 LateInitializationError!
```

## The Solution

This plugin makes unsafe `late` usage a **compile-time error**:

```dart
late String name;  // ❌ ERROR: Uninitialized late variable
```

## Quick Start

Just add the package and put this in your analysis_options

```yaml
analyzer:
  plugins:
    - custom_lint
```

## What's Blocked

```dart
// ❌ Uninitialized late
late String userName;

// ❌ Simple literals (no lazy benefit)
late String title = "Hello";
late int count = 42;

// ❌ Simple identifiers
late var copy = originalValue;
```

## What's Allowed

```dart
// ✅ Expensive computations
late final primes = calculatePrimes(1000000);

// ✅ Method/constructor calls
late final db = Database.connect();
late final timestamp = DateTime.now();

// ✅ Complex expressions
late final sum = numbers.fold(0, (a, b) => a + b);
```

## Real Example: Flutter

### ❌ Dangerous Pattern

```dart
class _MyWidgetState extends State<MyWidget> {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }
  // If initState fails, controller.dispose() crashes
}
```

### ✅ Safe Pattern

```dart
class _MyWidgetState extends State<MyWidget> {
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller?.dispose();  // Null-safe
    super.dispose();
  }
}
```

## Migration

| Pattern | Before | After |
|---------|--------|-------|
| Uninitialized | `late T value;` | `T? value;` |
| Simple literal | `late T value = literal;` | `T value = literal;` |
| Lazy computation | `late T value = compute();` | Keep as-is ✅ |