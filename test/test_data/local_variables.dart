// ignore_for_file: unused_local_variable

void testFunction() {
  // expect_lint: no_improper_late_usage
  late String name;
  // expect_lint: no_improper_late_usage
  // ignore: prefer_const_declarations
  late final count = 42;
  late final items = computeItems();
}

List<String> computeItems() => [];
