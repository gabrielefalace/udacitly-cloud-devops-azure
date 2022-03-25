from hello import to_you, add, sub

def setup_function(function):
    print("Running Setup %s" % function.__name__)
    function.x = 10

def teardown_function(function):
    print("Running Teardown %s" % function.__name__)
    del function.x

def test_hello_subtract():
    assert sub(test_hello_subtract.x) == 9