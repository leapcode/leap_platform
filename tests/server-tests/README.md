Tests for Server
---------------------------------

The tests in this directory are run against the servers of a live running
provider.

Usage
---------------------------------

To run the tests from a local workstation:

    workstation$ cd <my provider directory>
    workstation$ leap test

To run the tests from the server itself:

    workstation$ leap ssh servername
    servername# run_tests

Notes
---------------------------------

server-tests/white-box/

    These tests are run on the server as superuser. They are for
    troubleshooting any problems with the internal setup of the server.

server-tests/black-box/

    These test are run the user's local machine. They are for troubleshooting
    any external problems with the service exposed by the server.

Additional Files
---------------------------------

server-tests/helpers/

    Utility functions made available to all tests.

server-tests/order.rb

    Configuration file to specify which nodes should be tested in which order.


