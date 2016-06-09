# manage a complete tor
# installation with all the basics
class tor::compact {
  include ::tor
  include tor::polipo
  include tor::torsocks
}
