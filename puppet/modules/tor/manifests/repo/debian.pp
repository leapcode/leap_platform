# PRIVATE CLASS: do not use directly
class tor::repo::debian inherits tor::repo {
  apt::source { $tor::repo::source_name:
    ensure      => $::tor::repo::ensure,
    location    => $::tor::repo::location,
    key         => $::tor::repo::key,
    include_src => $::tor::repo::include_src,
  }
}
