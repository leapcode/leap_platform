# Checks if systems runs inside vagrant
require 'facter'

Facter.add(:vagrant) do
  setcode do
    FileTest.exists?('/vagrant')
  end
end
