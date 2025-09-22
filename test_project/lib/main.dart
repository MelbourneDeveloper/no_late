// ignore_for_file: unused_local_variable, await_in_late_local_variable_initializer

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

  Future<void> initStateAsync() async {
    // OK: these are ok because even if the call fails, you won't be able to
    // access the variable anyway
    late var builtString = await buildAsync();
    late final buildString2 = await buildAsync();
  }

  String build() =>
      'User: $userName, ID: $userId, Count: $count, Active: $isActive';

  Future<String> buildAsync() => Future.value(
      'User: $userName, ID: $userId, Count: $count, Active: $isActive');
}
