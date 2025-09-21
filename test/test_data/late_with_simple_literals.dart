class TestClass {
  // expect_lint: no_improper_late_usage
  late String name = "John";
  // expect_lint: no_improper_late_usage
  late int age = 25;
  // expect_lint: no_improper_late_usage
  late bool isActive = true;
}