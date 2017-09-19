if self.services.include?("tor_exit") || self.services.include?("tor_relay")
  LeapCli.log :error, "service `tor_hidden_service` is not compatible with tor_exit or tor_relay (node #{self.name})."
end
self.tor['type'] = "hidden_service"
