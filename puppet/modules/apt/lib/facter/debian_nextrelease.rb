def debian_release_to_next(release)
  releases = [
    'oldoldoldstable',
    'oldoldstable',
    'oldstable',
    'stable',
    'testing',
    'unstable',
    'experimental',
  ]
  if releases.include? release
    if releases.index(release)+1 < releases.count
      return releases[releases.index(release)+1]
    end
  end
end

Facter.add(:debian_nextrelease) do
  confine :operatingsystem => 'Debian'
  setcode do
    debian_release_to_next(Facter.value('debian_release'))
  end
end
