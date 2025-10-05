extends Node

# TestBase - Base class for unit tests
# Provides common testing utilities and assertions

class_name TestBase

var test_results = []
var current_test_name = ""

func assert_true(condition: bool, message: String = ""):
    """Assert that a condition is true"""
    if not condition:
        _fail_test("Assertion failed: " + message)

func assert_false(condition: bool, message: String = ""):
    """Assert that a condition is false"""
    if condition:
        _fail_test("Assertion failed (expected false): " + message)

func assert_eq(actual, expected, message: String = ""):
    """Assert that two values are equal"""
    if actual != expected:
        _fail_test("Assertion failed: expected " + str(expected) + ", got " + str(actual) + ". " + message)

func assert_not_null(value, message: String = ""):
    """Assert that a value is not null"""
    if value == null:
        _fail_test("Assertion failed: value is null. " + message)

func assert_null(value, message: String = ""):
    """Assert that a value is null"""
    if value != null:
        _fail_test("Assertion failed: value is not null. " + message)

func _fail_test(message: String):
    """Handle test failure"""
    var error_msg = "FAILED: " + current_test_name + " - " + message
    print(error_msg)
    test_results.append({"test": current_test_name, "result": "FAILED", "message": message})
    push_error(error_msg)

func _pass_test():
    """Handle test success"""
    test_results.append({"test": current_test_name, "result": "PASSED"})

func run_test(test_name: String, test_function: Callable):
    """Run a single test"""
    current_test_name = test_name
    print("Running test: " + test_name)

    var success = true
    var error_message = ""

    # Try to run the test
    if test_function.is_valid():
        test_function.call()
        _pass_test()
        print("✓ " + test_name + " passed")
    else:
        error_message = "Invalid test function"
        success = false

    return success
