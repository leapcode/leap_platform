unless ['open', 'invite', 'closed'].include?(self.enrollment_policy)
  LeapCli.log :error, "in provider config" do
    LeapCli.log "The value of enrollment_policy must be one of 'open', 'invite', or 'closed'."
  end
end