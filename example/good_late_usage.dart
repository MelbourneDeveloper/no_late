class GoodLateExample {
  // GOOD: Lazy initialization with computed values
  late final String complexString = _computeComplexString();
  late final List<int> expensiveList = _generateExpensiveList();
  late final Map<String, dynamic> config = _loadConfiguration();
  
  // GOOD: Lazy initialization with function calls
  late final DateTime timestamp = DateTime.now();
  late final Random random = Random();
  
  String _computeComplexString() {
    // Some expensive computation
    return "Computed: ${DateTime.now().millisecondsSinceEpoch}";
  }
  
  List<int> _generateExpensiveList() {
    // Some expensive operation
    return List.generate(1000, (index) => index * index);
  }
  
  Map<String, dynamic> _loadConfiguration() {
    // Simulate loading configuration
    return {
      'apiUrl': 'https://api.example.com',
      'timeout': 5000,
      'retries': 3,
    };
  }
}

class Random {
  int nextInt(int max) => 42; // Mock implementation
}