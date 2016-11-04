require 'facter'

def deb_installed_version ( name )
  # returns an empty string if package is not installed,
  # otherwise the version

  version = `apt-cache policy #{name} | grep Installed 2>&1`
  version.slice! "  Installed: "
  version.slice! "(none)"
  return version.strip.chomp
end

def couchdb_version
  bigcouch = deb_installed_version("bigcouch")
  if bigcouch.empty?
    couchdb = deb_installed_version("couchdb")
    if couchdb.empty?
      version = 'n/a'
    else
      version =  couchdb
    end
  else
    # bigcouch is currently only available in one version (0.4.2),
    # which includes couchdb 1.1.1
    version = '1.1.1'
  end
  return version
end

Facter.add(:couchdb_version) do
  setcode do
    couchdb_version
  end
end
