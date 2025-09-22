/// Example showcasing correct and incorrect usage of the `late` keyword
/// that the no_late plugin will detect.
library no_late_example;

void main() {
  // Good examples that no_late allows
  print('✅ Examples that are allowed:');
  final goodExamples = GoodExamples();
  print('Expensive computation: ${goodExamples.expensiveResult}');
  print('Current time: ${goodExamples.timestamp}');
  print('Database connection: ${goodExamples.database}');

  // Bad examples that no_late will flag as errors
  print('\n❌ Examples that will cause compile errors:');
  print('(These are commented out because they would fail to compile)');
  // final badExamples = BadExamples();
}

/// Examples of proper late usage that the plugin allows
class GoodExamples {
  /// ✅ GOOD: Expensive computation deferred until first access
  late final int expensiveResult = _calculateExpensiveResult();

  /// ✅ GOOD: Method call with side effects
  late final DateTime timestamp = DateTime.now();

  /// ✅ GOOD: Constructor call that may be expensive
  late final Database database = Database._connect();

  /// ✅ GOOD: Complex expression with multiple operations
  late final List<int> processedNumbers =
      [1, 2, 3, 4, 5].where((n) => n.isEven).map((n) => n * n).toList();

  /// ✅ GOOD: Property access that depends on context
  late final String contextualValue = _getContextualValue();

  int _calculateExpensiveResult() {
    // Simulate expensive computation
    print('Computing expensive result...');
    var result = 0;
    for (var i = 0; i < 1000000; i++) {
      result += i;
    }
    return result;
  }

  String _getContextualValue() {
    return 'Value computed at ${DateTime.now()}';
  }
}

/// Examples that the no_late plugin will flag as errors
class BadExamples {
  // ❌ ERROR: Uninitialized late variable
  // Uncommenting this will cause a compile error:
  // late String userName;

  // ❌ ERROR: Simple literal initialization
  // Uncommenting these will cause compile errors:
  // late String title = "Hello World";
  // late int count = 42;
  // late bool isActive = true;

  // ❌ ERROR: Simple identifier assignment
  // late String copy = originalValue;

  void initializeValues() {
    // ❌ ERROR: Separate initialization of late variable
    // This pattern is dangerous and will be flagged:
    // userName = "John Doe";
  }
}

/// Mock database class for demonstration
class Database {
  static Database _connect() {
    print('Connecting to database...');
    return Database._();
  }

  Database._();

  @override
  String toString() => 'Database(connected)';
}

/// Migration examples showing how to fix flagged code
class MigrationExamples {
  // ✅ AFTER: Use nullable instead of uninitialized late
  String? userName;

  // ✅ AFTER: Remove late from simple literals
  String title = "Hello World";
  int count = 42;
  bool isActive = true;

  // ✅ AFTER: Use conditional initialization for complex cases
  final String environment = const bool.fromEnvironment('dart.vm.product')
      ? 'production'
      : 'development';

  void initializeUser(String name) {
    userName = name;
  }

  String greetUser() {
    final user = userName;
    return user != null ? 'Hello, $user!' : 'Hello, guest!';
  }
}
