Continuous integration tests for the leap_platform code.

Usage:

    ./setup.sh
    bin/rake test:syntax
    bin/rake test:catalog

For a list of all tasks:

    bin/rake -T

To create a virtual provider, run tests on it, then tear it down:

   ./ci-build.sh
