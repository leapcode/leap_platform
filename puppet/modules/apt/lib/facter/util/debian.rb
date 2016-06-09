module Facter
  module Util
    module Debian
      STABLE = 8
      CODENAMES = {
        "5" => "lenny",
        "6" => "squeeze",
        "7" => "wheezy",
        "8" => "jessie",
        "9" => "stretch",
        "10" => "buster",
      }
      LTS = [
        "squeeze",
      ]
    end
  end
end
