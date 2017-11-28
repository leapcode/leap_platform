
if self.services.include?("tor_exit") || self.services.include?("tor_hidden_service")
  LeapCli.log :error, "service `tor_relay` is not compatible with tor_exit or tor_hidden_service (node #{self.name})."
end
apply_partial("_tor_common")
self.tor['type'] = "relay"
