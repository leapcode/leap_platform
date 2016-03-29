unless self.services.include? "webapp"
  LeapCli.log :error, "service `monitor` requires service `webapp` on the same node (node #{self.name})."
end
