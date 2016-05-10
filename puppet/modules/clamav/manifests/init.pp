class clamav {

  include clamav::daemon
  include clamav::milter
  include clamav::unofficial_sigs
  include clamav::freshclam

}
