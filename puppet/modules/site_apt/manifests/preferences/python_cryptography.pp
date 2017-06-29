# Pin python-cryptography to jessie-backports in order to
# satisfy leap-mx dependency (>=17.0)
# see https://0xacab.org/leap/platform/issues/8837
class site_apt::preferences::python_cryptography {

  apt::preferences_snippet { 'python_cryptography':
    package  => 'python-cryptography python-openssl python-pyasn1 python-setuptools python-pkg-resources python-cffi',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

}
