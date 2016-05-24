class rubygems::mysql {
    require ::mysql::devel
    require gcc
    rubygems::gem{'mysql':}
}
