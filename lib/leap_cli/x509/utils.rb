module LeapCli; module X509

  #
  # TIME HELPERS
  #
  # note: we use 'yesterday' instead of 'today', because times are in UTC, and
  # some people on the planet are behind UTC!
  #

  def self.yesterday
    t = Time.now - 24*24*60
    Time.utc t.year, t.month, t.day
  end

  def self.yesterday_advance(string)
    number, unit = string.split(' ')
    unless ['years', 'months', 'days', 'hours', 'minutes'].include? unit
      bail!("The time property '#{string}' is missing a unit (one of: years, months, days, hours, minutes).")
    end
    unless number.to_i.to_s == number
      bail!("The time property '#{string}' is missing a number.")
    end
    yesterday.advance(unit.to_sym => number.to_i)
  end

end; end