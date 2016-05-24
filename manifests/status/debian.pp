# enable status module on debian
class apache::status::debian {
  ::apache::debian::module { 'status': }
}
