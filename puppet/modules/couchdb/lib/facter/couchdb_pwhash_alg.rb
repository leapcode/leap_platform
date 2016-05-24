require 'facter'

def version_parts ( version )
  # gives back a hash containing major, minor and patch numbers
  # of a give version string

  parts = Hash.new
  first, *rest = version.split(".")
  parts["major"] = first
  parts["minor"] = rest[0]
  parts["patch"] = rest[1]
  return parts
end

def couchdb_pwhash_alg
  # couchdb uses sha1 as pw hash algorithm until v. 1.2,
  # but pbkdf2 from v.1.3 on.
  # see http://docs.couchdb.org/en/1.4.x/configuring.html for
  # details

  couchdb_version = Facter.value(:couchdb_version)
  version = version_parts(couchdb_version)
  major = version["major"].to_i
  alg = case major
    when 0 then alg = 'n/a'
    when 1 then
      minor = version['minor'].to_i
      if minor < 3
        alg = 'sha1'
      else
        alg = 'pbkdf2'
      end
  else
    alg = 'pbkdf2'
  end
  return alg
end

Facter.add(:couchdb_pwhash_alg) do
  setcode do
    couchdb_pwhash_alg
  end
end
