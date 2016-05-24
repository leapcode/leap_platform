# install ruby header files and rake
class ruby::devel {
  include ruby
  ensure_packages($ruby::ruby_dev)
}
