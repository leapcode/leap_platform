class clamav {

  include clamav::daemon
  include clamav::milter
  include clamav::sanesecurity
  include clamav::freshclam

}
