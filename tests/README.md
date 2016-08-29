What is here?

**server-tests/**

These are the tests run on a provider's servers using the command:

    workstation$ leap test

Or the command:

    server# run_tests

These tests are to confirm that a provider's infrasture is working and to troubleshoot any possible problems.

**example-provider/**

Files to support the command:

   cd leap_platform/tests/example-provider
   vagrant up

For quick booting a pre-configured sample provider, running in a single virtual
machine.

**platform-ci/**

Continous integration tests run for the LEAP Platform. These tests are for the
platform code itself.

