class BadLateExample {
  // BAD: Separate declaration and initialization
  late String userName;
  late int userId;

  // BAD: Simple literal initialization
  late String title = "Hello World";
  late int count = 42;
  late bool isActive = true;

  late final String test = build();

  void initState() {
    // BAD: Initializing late variables in initState
    userName = "John Doe";
    userId = 123;
  }

  String build() {
    return 'User: $userName, ID: $userId, Count: $count, Active: $isActive';
  }


}