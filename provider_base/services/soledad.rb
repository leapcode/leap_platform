unless self.services.include? "couchdb"
  LeapCli.log :error, "service `soledad` requires service `couchdb` on the same node (node #{self.name})."
end
