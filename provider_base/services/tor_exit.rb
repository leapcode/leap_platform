if self.services.include?("hidden_service") || self.services.include?("tor_relay")
  LeapCli.log :error, "service `tor_exit` is not compatible with tor_relay or hidden_service (node #{self.name})."
  exit(1)
end
apply_partial("_tor_common")
self.tor['type'] = "exit"
