void testFunction() {
  // expect_lint: no_improper_late_usage
  late String name;
  // expect_lint: no_improper_late_usage
  late int count = 42;
  late List<String> items = computeItems();
}

List<String> computeItems() => [];